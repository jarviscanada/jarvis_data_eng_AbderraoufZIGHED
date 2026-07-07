# Introduction
London Gift Shop (LGS) is a UK-based online retailer looking to understand customer purchasing behavior to improve marketing campaigns. This project analyzes historical
transaction data to analyze customer shopping patterns and generate insights that support data-driven marketing decisions, such as targeted email campaigns, personalized
promotions, and customer segmentation.

The analytics workflow was implemented in Python using **Pandas** and **NumPy** for data manipulation and numerical operations. The **PostgreSQL** database and **Jupyter Notebook** environment
were both run in  **Docker** containers to ensure a reproducible and isolated setup. Transactional data from the database was loaded into Pandas for cleaning, transformation,
and analysis, and the results are presented in a Jupyter Notebook.

# Implementaion
## Project Architecture
This project follows an analytical architecture suitable for a proof of concept.
1. Customers place orders through the LGS web application.

2. Transactional data is stored in the LGS production database.

3. For the PoC, LGS exports historical transaction data as a SQL dump file.

4. The Jarvis team loads the data into a local PostgreSQL instance.

5. Data analytics and wrangling are performed using Python and Jupyter Notebook.

6. Analytical insights are delivered to the LGS marketing team via notebooks and GitHub.

![Architecture Diagram](./python_data_wrangling/data/LGS-project-architect-diagram.png)

## Data Analytics and Wrangling
You can check the data analytics code here: [Jupyter Notebook](./python_data_wrangling/retail_data_analytics_wrangling.ipynb)

The dataset contains transactional records including invoice numbers, product details, quantities, prices, customer IDs, and countries. During data wrangling and analysis, the following
steps were performed:

- Loaded retail transaction data from a PostgreSQL SQL dump

- Cleaned the data by:

    - Handling cancelled invoices (invoice numbers starting with 'C')

    - Removing invalid quantities and unit prices

    - Managing missing customer IDs

- Created derived metrics such as line-item revenue and invoice totals

- Aggregated data at customer and invoice levels

- Analyzed customer purchasing behavior using **RFM analysis**:

    - Recency

    - Frequency

    - Monetary value

The analytical results can be directly used by the LGS marketing team to **increase revenue** by:

- **Customer Segmentation**:
  Identifying high-value customers for loyalty programs and exclusive promotions.

- **Churn Prevention**:
  Detecting inactive or low-recency customers and targeting them with re-engagement campaigns.

- **Targeted Marketing**:
  Designing personalized email campaigns based on purchase frequency and spending patterns rather than broad, untargeted promotions.

- **Wholesale Optimization**:
  Understanding purchasing behavior of bulk buyers to tailor pricing strategies and incentives.

These insights enable LGS to move from intuition-based marketing to data-driven decision-making.

# Improvements
1. **Automated Data Pipeline**
   Build an automated ETL pipeline to regularly ingest and process new transaction data instead of relying on a one-time SQL dump.

2. **Interactive Dashboards**
   Develop dashboards using tools such as Tableau or Power BI to allow non-technical marketing stakeholders to explore insights interactively.

3. **Analytics Functions**
   Refactor analysis logic (such as distribution plots and summary statistics) into reusable Python functions to improve maintainability and enable reuse across different
   columns or datasets.