# Sales-Overview-Project

![image](https://github.com/user-attachments/assets/16fde0f7-3063-4000-80bc-4972887d7254)



## Case Study: Data-Driven Sales Optimization in the Automotive & Motorcycle Industry

In a competitive and fast-changing market, companies in the automotive and motorcycle sector must rely on data to drive smarter decisions. This project analyzes sales data across multiple regions, customer segments, and product types (cars and motorcycles) to uncover actionable insights.

By examining key metrics such as units sold, sales value, geographic distribution, and customer behavior, we aim to:

*  Identify top-performing products and regions

* Spot high-value customers

* Understand deal sizes and pricing strategies

* Detect sales trends over time

Using SQL for data transformation and Power BI for visualization, this project transforms raw sales data into a clean, interactive dashboard that helps business stakeholders track performance and make informed, data-driven decisions.

## The Process

The dataset was sourced from Kaggle and initially downloaded as a CSV file. Since the raw data required significant cleaning and normalization, it was first reviewed and modified in Google Sheets. This included correcting inconsistent data types, formatting numerical columns appropriately, and ensuring date values were properly structured. The file was loaded to SQL Server.

<img width="1208" alt="image" src="https://github.com/user-attachments/assets/d9e0645d-8246-4188-b3a5-99c253ba8c2d" />

## 1. Data Cleaning & Type Correction in SQL Server
* **Data Types Standardized**: Data was imported in SQL Server and converted into string columns containing numeric values (e.g., sales, price_each, order_number, quantity_ordered) into appropriate types like **FLOAT** and **INT**, enabling accurate aggregation and filtering.

* **Date Handling**: Converted text-based date columns into the **DATE** type to allow time-based analysis and sorting.

* **Null Handling**: Filled or replaced missing values in columns like state.

💡 For full details on data cleaning logic, please refer to the [cleaning_script](SQL/cleaning_script.sql) included in this repository.

## 2. Data Modeling (Star Schema)
To optimize the dataset for analytical queries, a star schema model was designed. This structure simplifies the querying process and improves performance in Power BI.

### **Fact Table**:  
 
**FactSales** - Contains core transactional data: Order number, Quantity ordered, Price each, Sales value, Deal size, Orderline number, Foreign keys to dimension tables

### **Dimension Tables**:  

**DimDate** – Contains one row per calendar day (used for time-series analysis). Includes fields like DateID, OrderDate, Year, Quarter, Month, and MonthName.
The teble was created using SQL to enable flexible and accurate time-based analysis (e.g., group by quarter, year, etc.), which is not possible with raw date fields alone.

**DimCustomer** Contains – Unique customers and their contact names.

**DimProduct** Conatins – Products, product lines, and MSRP values.

**DimLocation** Contains – City, state, territory.

This star schema promotes data integrity, efficient joins, and allows for clear slicing and filtering in Power BI.

💡 For full details on data cleaning logic, please refer to the [data_modeling_start_schema](SQL/data_modeling_star_schema.sql) included in this repository.


