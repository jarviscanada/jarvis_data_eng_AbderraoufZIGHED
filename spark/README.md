# World Development Indicators (WDI) – Spark & Zeppelin Project

This project analyzes World Development Indicators **(WDI)** data using Apache **Spark** with both **Spark SQL** and PySpark inside Apache **Zeppelin**. This project simulates a real-world big data workflow.

This project includes:
- Loading Parquet-formatted data
- Performing analytical queries
- Organizing results as structured tables for further analysis
- Comparing SQL vs PySpark transformations
- Performing distributed sorting and partitioning concepts

## Environment Setup
1. Install Spark and Zeppline
2. Start Zeppline `bin/zeppelin-daemon.sh start`
3. Open in browser: `http://localhost:8080`
4. Ingest raw parquet data and run all queries
5. At the end stop Zeppline: `bin/zeppelin-daemon.sh stop`

## Future Improvements

- Deploy to cloud cluster (Hadoop)
- Add data validation and quality checks
- Add visualization dashboard
- Automate data ingestion and transformation pipeline
