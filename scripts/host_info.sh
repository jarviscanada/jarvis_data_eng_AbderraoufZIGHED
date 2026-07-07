#!/bin/bash

psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

if [ "$#" -ne 5 ]; then
  echo "Illegal number of parameters"
  exit 1
fi

hostname=$(hostname -f)
lscpu_out=$(lscpu)

cpu_number=$(echo "$lscpu_out" | awk -F: '/^CPU\(s\):/ {print $2}' | xargs)
cpu_architecture=$(echo "$lscpu_out" | awk -F: '/^Architecture:/ {print $2}' | xargs)
cpu_model=$(echo "$lscpu_out" | awk -F: '/Model name:/ {print $2}' | xargs)

cpu_mhz=$(echo "$lscpu_out" | awk -F: '/CPU max MHz:/ {print $2}' | xargs)
if [ -z "$cpu_mhz" ]; then
  cpu_mhz=$(echo "$lscpu_out" | awk -F: '/CPU MHz:/ {print $2}' | xargs)
fi
if [ -z "$cpu_mhz" ]; then
  cpu_mhz=0
fi

l2_cache=$(echo "$lscpu_out" | awk -F: '/L2 cache:/ {print $2}' | xargs | awk '{print $1}')
if [ -z "$l2_cache" ]; then
  l2_cache=0
fi

total_mem=$(free -m | awk '/Mem:/ {print $2}')
timestamp=$(date '+%Y-%m-%d %H:%M:%S')

insert_stmt="
INSERT INTO host_info(
  hostname,
  cpu_number,
  cpu_architecture,
  cpu_model,
  cpu_mhz,
  l2_cache,
  total_mem,
  timestamp
)
VALUES(
  '$hostname',
  $cpu_number,
  '$cpu_architecture',
  '$cpu_model',
  $cpu_mhz,
  $l2_cache,
  $total_mem,
  '$timestamp'
);
"

echo "$insert_stmt"

export PGPASSWORD=$psql_password

psql -h "$psql_host" \
     -p "$psql_port" \
     -d "$db_name" \
     -U "$psql_user" \
     -c "$insert_stmt"

exit $?
