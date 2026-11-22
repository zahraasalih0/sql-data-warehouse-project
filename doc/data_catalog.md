# Gold Layer Data Catalog

## Overview

The Gold Layer is where data becomes ready for the business. It's organized for analysis and reporting, and it's made up of **dimension tables** (the "who" and "what") and **fact tables** (the measurable events).

## Tables

- [gold.dim_customers](#1-golddim_customers)
- [gold.dim_products](#2-golddim_products)
- [gold.fact_sales](#3-goldfact_sales)

---

## 1. gold.dim_customers

**What it's for:** One place to find who your customers are, including demographic and location details.

| Column | Type | What it means |
|---|---|---|
| `customer_key` | `INT` | Surrogate key. It uniquely identifies each customer row in this table. |
| `customer_id` | `INT` | The numeric ID given to each customer. |
| `customer_number` | `NVARCHAR(50)` | An alphanumeric code for the customer, used for tracking and lookups. |
| `first_name` | `NVARCHAR(50)` | Customer's first name as stored in the system. |
| `last_name` | `NVARCHAR(50)` | Customer's last (family) name. |
| `country` | `NVARCHAR(50)` | Country where the customer lives (e.g., `'Australia'`). |
| `marital_status` | `NVARCHAR(50)` | Customer's marital status (e.g., `'Married'`, `'Single'`). |
| `gender` | `NVARCHAR(50)` | Customer's gender (e.g., `'Male'`, `'Female'`, `'n/a'`). |
| `birthdate` | `DATE` | Date of birth in `YYYY-MM-DD` format (e.g., `1971-10-06`). |
| `create_date` | `DATE` | When the customer record was created in the system. |

---

## 2. gold.dim_products

**What it's for:** Describes each product and its attributes.

| Column | Type | What it means |
|---|---|---|
| `product_key` | `INT` | Surrogate key. It uniquely identifies each product row in this table. |
| `product_id` | `INT` | Internal unique ID for the product, used for tracking and referencing. |
| `product_number` | `NVARCHAR(50)` | Structured alphanumeric product code, often used for categorization or inventory. |
| `product_name` | `NVARCHAR(50)` | Product name, with key details like type, color, and size. |
| `category_id` | `NVARCHAR(50)` | ID of the product's category, linking it to its high-level classification. |
| `category` | `NVARCHAR(50)` | Broad grouping of the product (e.g., `Bikes`, `Components`). |
| `subcategory` | `NVARCHAR(50)` | A finer grouping within the category, such as the product type. |
| `maintenance` | `NVARCHAR(50)` | Whether the product needs maintenance (e.g., `'Yes'`, `'No'`). |
| `cost` | `INT` | Base cost or price of the product, in monetary units. |
| `product_line` | `NVARCHAR(50)` | The product line or series it belongs to (e.g., `Road`, `Mountain`). |
| `start_date` | `DATE` | When the product became available for sale or use. |

---

## 3. gold.fact_sales

**What it's for:** Holds the sales transactions used for analysis.

| Column | Type | What it means |
|---|---|---|
| `order_number` | `NVARCHAR(50)` | Unique alphanumeric ID for each sales order (e.g., `'SO54496'`). |
| `product_key` | `INT` | Surrogate key that links the order to the product dimension. |
| `customer_key` | `INT` | Surrogate key that links the order to the customer dimension. |
| `order_date` | `DATE` | Date the order was placed. |
| `shipping_date` | `DATE` | Date the order was shipped to the customer. |
| `due_date` | `DATE` | Date the payment was due. |
| `sales_amount` | `INT` | Total sale value for the line item, in whole currency units (e.g., `25`). |
| `quantity` | `INT` | Number of units ordered on the line item (e.g., `1`). |
| `price` | `INT` | Price per unit for the line item, in whole currency units (e.g., `25`). |

---

## Relationships

- `gold.fact_sales.customer_key` → `gold.dim_customers.customer_key`
- `gold.fact_sales.product_key` → `gold.dim_products.product_key`
