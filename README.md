# Linux Cluster Monitoring Agent

## Introduction

Managing a Linux server cluster without visibility into resource consumption is like flying blind — you never know when a node is struggling until it's too late. This project solves that problem by deploying a lightweight monitoring agent across every node in the cluster to continuously capture hardware specs and live resource metrics.

Each node runs a set of Bash scripts that harvest CPU, memory, and disk data directly from the Linux kernel. That data flows into a centralized PostgreSQL database every minute, creating a time-series record that teams can query to spot trends, investigate incidents, or plan capacity upgrades.

The primary users are infrastructure and DevOps engineers who need an always-on view of cluster health without relying on heavyweight monitoring platforms. The stack is intentionally lean: **Bash** for scripting, **PostgreSQL** for storage, **Docker** for containerizing the database, **crontab** for scheduling, and **Git/GitHub** for version control.

---

## Quick Start

```bash
# 1. Start a PostgreSQL instance using Docker
./scripts/psql_docker.sh create postgres mypassword
./scripts/psql_docker.sh start

# 2. Create the database tables
psql -h localhost -U postgres -d host_agent -f sql/ddl.sql

# 3. Collect and insert this node's hardware specs (run once per node)
./scripts/host_info.sh localhost 5432 host_agent postgres mypassword

# 4. Collect and insert current resource usage (run manually or via crontab)
./scripts/host_usage.sh localhost 5432 host_agent postgres mypassword

# 5. Automate resource usage collection every minute with crontab
crontab -e
# Add the following line:
* * * * * bash /home/your_user/linux_sql/scripts/host_usage.sh localhost 5432 host_agent postgres mypassword > /tmp/host_usage.log
```

---

## Implementation

### Architecture

The diagram below shows three Linux nodes in a cluster. Each node runs the host agent scripts locally. The collected data is sent over the network to a PostgreSQL instance running inside a Docker container on one of the nodes.

> **Note:** Architecture diagram saved at `assets/architecture.png` (created via draw.io)

![Cluster Architecture](assets/architecture.png)

Node 1 acts as both an agent and the database host. Nodes 2 and 3 are pure agents — they run the scripts and push data to Node 1's database over the internal network. Every node runs `host_info.sh` once at setup time and `host_usage.sh` every minute via crontab.

---

### Scripts

#### `psql_docker.sh`

Manages the lifecycle of the PostgreSQL Docker container. Accepts `create`, `start`, or `stop` as the first argument. When creating, a username and password must be supplied. The script verifies whether Docker is running and whether the container already exists before taking action, printing meaningful error messages when preconditions are not met.

```bash
# Create a new container
./scripts/psql_docker.sh create [db_username] [db_password]

# Start an existing container
./scripts/psql_docker.sh start

# Stop a running container
./scripts/psql_docker.sh stop
```

---

#### `host_info.sh`

Collects the static hardware profile of the host — CPU count, architecture, model, clock speed, cache size, and total memory — and inserts one row into the `host_info` table. Since hardware does not change under normal circumstances, this script is designed to be executed a single time per node during initial setup.

```bash
./scripts/host_info.sh [psql_host] [psql_port] [db_name] [psql_user] [psql_password]

# Example
./scripts/host_info.sh localhost 5432 host_agent postgres mypassword
```

---

#### `host_usage.sh`

Takes a real-time snapshot of the node's resource consumption — free memory, CPU idle percentage, kernel CPU usage, disk I/O activity, and available disk space — and appends it to the `host_usage` table. This script runs every minute via crontab, producing a continuous time-series record for each node.

```bash
./scripts/host_usage.sh [psql_host] [psql_port] [db_name] [psql_user] [psql_password]

# Example
./scripts/host_usage.sh localhost 5432 host_agent postgres mypassword
```

---

#### crontab

The crontab entry schedules `host_usage.sh` to execute every minute on each node. Output is redirected to a log file so that failures can be inspected without needing to watch the terminal.

```bash
# Open the crontab editor
crontab -e

# Schedule host_usage.sh to run every minute
* * * * * bash /path/to/linux_sql/scripts/host_usage.sh localhost 5432 host_agent postgres mypassword > /tmp/host_usage.log

# Confirm the job is registered
crontab -l
```

---

#### `queries.sql`

Contains two analytical SQL queries that turn the raw time-series data into actionable insights for the operations team.

**Query 1 — Hardware inventory grouped by CPU count**
Answers the business question: *"How is total memory distributed across nodes with different CPU configurations?"* This helps capacity planners understand whether high-memory nodes are aligned with high-CPU nodes or whether there is a mismatch worth addressing.

**Query 2 — Average free memory per node over 5-minute windows**
Answers the business question: *"Which nodes are consistently running low on memory?"* By averaging memory snapshots over 5-minute intervals, short spikes are smoothed out and genuine sustained pressure becomes visible, giving teams an early warning before a node runs out of memory.

---

### Database Modeling

#### `host_info`

| Column | Data Type | Constraints | Description |
|---|---|---|---|
| `id` | SERIAL | PRIMARY KEY | Auto-incremented unique identifier for each node |
| `hostname` | VARCHAR | NOT NULL, UNIQUE | Fully qualified domain name of the host |
| `cpu_number` | INT2 | NOT NULL | Total number of logical CPUs on the node |
| `cpu_architecture` | VARCHAR | NOT NULL | Processor architecture (e.g. x86_64) |
| `cpu_model` | VARCHAR | NOT NULL | Full model name of the processor |
| `cpu_mhz` | FLOAT8 | NOT NULL | Clock speed of the processor in MHz |
| `l2_cache` | INT4 | NOT NULL | Size of the L2 cache in kilobytes |
| `total_mem` | INT4 | NULL | Total installed RAM in kilobytes |
| `timestamp` | TIMESTAMP | NULL | UTC time when the record was inserted |

---

#### `host_usage`

| Column | Data Type | Constraints | Description |
|---|---|---|---|
| `timestamp` | TIMESTAMP | NOT NULL | UTC time when the snapshot was taken |
| `host_id` | INT4 | NOT NULL, FK → host_info(id) | References the node that produced this record |
| `memory_free` | INT4 | NOT NULL | Available free memory in megabytes |
| `cpu_idle` | INT2 | NOT NULL | Percentage of CPU time spent idle |
| `cpu_kernel` | INT2 | NOT NULL | Percentage of CPU time spent in kernel mode |
| `disk_io` | INT4 | NOT NULL | Number of disk I/O operations currently in progress |
| `disk_available` | INT4 | NOT NULL | Free disk space on the root partition in megabytes |

---

## Test

Each Bash script was tested manually by executing it directly from the terminal with known input arguments and then querying the database to verify the expected row was inserted correctly.

For `host_info.sh`, the test involved running the script once on a single node and then running `SELECT * FROM host_info;` in the psql shell to confirm that a single row appeared with values that matched the output of `lscpu` and `hostname -f` on that machine.

For `host_usage.sh`, the script was executed several times manually and after each run `SELECT * FROM host_usage ORDER BY timestamp DESC LIMIT 5;` was used to confirm a new row with a fresh timestamp and accurate metric values had been appended.

For `psql_docker.sh`, each subcommand (`create`, `start`, `stop`) was tested in sequence including edge cases such as attempting to create a container that already existed and attempting to start a container that had not yet been created — both cases returned the correct error messages and non-zero exit codes.

The `ddl.sql` file was tested by running it twice in a row on the same database. Because both `CREATE TABLE` statements use `IF NOT EXISTS`, the second run completed without errors and did not duplicate or alter the existing tables.

All tests passed and the data visible in the database matched the expected values from the host system.

---

## Deployment

The application is deployed across three components:

**GitHub** — all source code is version-controlled using the GitFlow branching strategy. Each feature is developed on a dedicated `feature/` branch, reviewed via a pull request, and merged into the `develop` branch before being promoted to `master`.

**Docker** — the PostgreSQL database runs inside a Docker container (`jrvs-psql`) using the official `postgres:9.6-alpine` image. A named Docker volume (`pgdata`) ensures that all data persists across container restarts and is not lost if the container is removed.

**crontab** — the `host_usage.sh` script is registered as a crontab job on every node in the cluster, configured to fire every minute. This provides a continuous stream of resource snapshots with no manual intervention required after the initial setup.

---

## Improvements

1. **Handle hardware updates automatically** — currently `host_info.sh` is designed to run only once per node. If a node receives a hardware upgrade (additional RAM, a new CPU), there is no mechanism to update the existing record. A future improvement would detect changes and perform an `UPDATE` rather than failing silently or inserting a duplicate.

2. **Add a failure alert when a node stops reporting** — if a node goes down or crontab is misconfigured, `host_usage` simply stops receiving rows for that node. Adding a monitoring query that triggers an alert when no new row has been received from a node within the last 2 minutes would allow the team to detect outages proactively.

3. **Extend metrics to include network I/O** — the current schema captures CPU, memory, and disk but omits network throughput, which is often the bottleneck in distributed data workloads. Adding inbound and outbound bytes per second to the `host_usage` table would give a more complete picture of node health.
