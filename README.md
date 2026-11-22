# SQL Server Data Warehouse Project

A data warehouse built in SQL Server using the Medallion Architecture (Bronze, Silver, Gold). It takes raw CSV files from two source systems (CRM and ERP), cleans them, and models them into a star schema that is ready for reporting and analysis.

> **Credit:** This project is based on the work of **Baraa Khatib Salkini** (*Data With Baraa*). I built it by following his full tutorial, and the original structure, datasets, and ideas come from him. See the [Credits](#-credits-and-acknowledgment) section for the links.

---

## 📌 Table of Contents

- [Architecture](#-architecture)
- [Project Overview](#-project-overview)
- [Repository Structure](#-repository-structure)
- [Requirements](#-requirements)
- [How to Run](#-how-to-run)
- [Data Catalog](#-data-catalog)
- [Credits and Acknowledgment](#-credits-and-acknowledgment)
- [License](#-license)
- [About Me](#-about-me)

---

## 🏗️ Architecture

The warehouse follows the Medallion Architecture:

![Data Architecture](docs/data_architecture.png)

| Layer | Purpose |
|---|---|
| **Bronze** | Raw data loaded as-is from the CSV files into SQL Server. |
| **Silver** | Cleaned, standardized, and normalized data. |
| **Gold** | Business-ready data modeled as a star schema for analytics. |

---

## 📖 Project Overview

1. **Architecture:** design a modern data warehouse with three layers.
2. **ETL:** load the source files and move the data through each layer using SQL scripts and stored procedures.
3. **Modeling:** build dimension and fact tables (star schema).
4. **Analytics:** answer business questions about customers, products, and sales with SQL.

### Specifications

- **Sources:** two systems (CRM and ERP) provided as CSV files.
- **Data quality:** fix quality issues before analysis.
- **Integration:** combine both sources into one model designed for analytical queries.
- **Scope:** latest data only, no historization.
- **Documentation:** the data model is documented for both business and analytics users.

### Analytics goals

- Customer behavior
- Product performance
- Sales trends

---

## 📁 Repository Structure

```
.
├── datasets/             source CSV files
│   ├── source_crm/       CRM files
│   └── source_erp/       ERP files
├── docs/                 architecture diagrams, naming conventions, data catalog
├── scripts/
│   ├── init_database.sql creates the database and schemas (run first)
│   ├── bronze/           raw data loading
│   ├── silver/           cleaning and transformation
│   └── gold/             star schema views/tables
├── tests/                data quality checks for silver and gold
└── README.md
```

> Adjust the folder names above to match your own repository.

---

## 🛠️ Requirements

- SQL Server (Express edition is enough)
- SQL Server Management Studio (SSMS) or Azure Data Studio
- Git and a GitHub account
- [draw.io](https://www.drawio.com/) for diagrams (optional)

---

## 🚀 How to Run

1. Clone the repository.
2. Open SQL Server and run `scripts/init_database.sql` to create the database and the `bronze`, `silver`, and `gold` schemas.
3. Update the file paths in the bronze load script so they point to your local `datasets` folder.
4. Run the bronze scripts, then the silver scripts, then the gold scripts, in that order.
5. Run the quality checks in `tests/` to verify the results.

---

## 📚 Data Catalog

The Gold Layer contains two dimension tables and one fact table:

- `gold.dim_customers`
- `gold.dim_products`
- `gold.fact_sales`

Full column-level details are in [docs/data_catalog.md](docs/data_catalog.md).

---

## 🙏 Credits and Acknowledgment

This project is **not an original idea of mine**. I built it by following the tutorial and using the materials created by **Baraa Khatib Salkini** of *Data With Baraa*. I adapted the documentation and organization in my own words, but all credit for the project concept, the datasets, and the teaching goes to him.

- 🎥 **Original video:** [SQL Data Warehouse Project (full tutorial)](https://youtu.be/9GVqKuTVANE)
- 💻 **Original repository:** [DataWithBaraa/sql-data-warehouse-project](https://github.com/DataWithBaraa/sql-data-warehouse-project)


If you want to learn this properly, please watch the original video and support his work.

---

## 🛡️ License

The original project is released under the **MIT License**. This repository keeps that licenseة, You are free to use, modify, and share this work with attribution.

---

## 👤 About Me

Hi, I'm Zahraa, a data analyst. I'm curious by nature and I like to try new things, so I built this project to explore the data engineering side of the work and see how data gets from raw files to analysis-ready tables.
- GitHub: [zahraasalih0](https://github.com/zahraasalih0)
- LinkedIn: [Zahraa Salih](https://www.linkedin.com/in/zahraa-salih-613921376/)
