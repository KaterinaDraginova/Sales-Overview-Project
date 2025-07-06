  Script: star_schema_transformation.sql
  Description:
    This script creates a star schema data model from the raw Pizza dataset.
    It involves creating dimension tables (Date, Customer, Product, Location),
    cleaning and enriching location data, and building a fact table (FactSales)
    that links to all dimensions using surrogate keys.
    This transformation improves data quality and enables efficient analytics
    in Power BI or other BI tools.


    
-- Drop the table if it exists
DROP TABLE IF EXISTS DimDate;


-- Create the DimDate table
CREATE TABLE DimDate (
    DateID INT PRIMARY KEY,         
    OrderDate DATE,
    Year INT,
    Quarter INT,
    Month INT,
    MonthName VARCHAR(20),
    Day INT
);

-- Populate DimDate from 2003-01-01 to 2005-12-31
DECLARE @CurrentDate DATE = '2003-01-01';
DECLARE @EndDate DATE = '2005-12-31';

WHILE @CurrentDate <= @EndDate
BEGIN
    INSERT INTO DimDate (
        DateID,
        OrderDate,
        Year,
        Quarter,
        Month,
        MonthName,
        Day
    )
    VALUES (
        CONVERT(INT, FORMAT(@CurrentDate, 'yyyyMMdd')),
        @CurrentDate,
        YEAR(@CurrentDate),
        DATEPART(QUARTER, @CurrentDate),
        MONTH(@CurrentDate),
        DATENAME(MONTH, @CurrentDate),
        DAY(@CurrentDate)
    );

    SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
END;

-- ======================================
-- Create Customer Dimension (DimCustomer)
-- ======================================

CREATE TABLE DimCustomer (
    Customer_ID INT IDENTITY(1,1) PRIMARY KEY,
    Customer_name VARCHAR(100),
    Contact_firstName VARCHAR(50),
    Contact_lastName VARCHAR(50)
);

INSERT INTO DimCustomer (Customer_name, Contact_firstName, Contact_lastName)
SELECT DISTINCT
    customer_name,
    contact_firstname,
    contact_lastname
FROM Pizza;

-- ======================================
-- Create Product Dimension (DimProduct)
-- ======================================

CREATE TABLE DimProduct (
    Product_ID INT IDENTITY(1,1) PRIMARY KEY,
    ProductCode VARCHAR(50),
    ProductLine VARCHAR(50),
    MSRP INT
);

INSERT INTO DimProduct (ProductCode, ProductLine, MSRP)
SELECT DISTINCT
    product_code,
    product_line,
    msrp
FROM Pizza;

-- ======================================
-- Create Location Dimension (DimLocation)
-- ======================================

CREATE TABLE DimLocation (
    Location_ID INT IDENTITY(1,1) PRIMARY KEY,
    City VARCHAR(50),
    State VARCHAR(50),
    PostalCode VARCHAR(20),
    Country VARCHAR(50),
    Territory VARCHAR(20)
);

INSERT INTO DimLocation (City, State, PostalCode, Country, Territory)
SELECT DISTINCT
    city,
    state,
    postal_code,
    country,
    territory
FROM Pizza;

-- Enrich Location Data: Fill missing or incorrect state codes based on city
UPDATE DimLocation
SET state = 
    CASE City
        WHEN 'Paris' THEN 'FR'
        WHEN 'Lyon' THEN 'FR'
        WHEN 'Marseille' THEN 'FR'
        WHEN 'Versailles' THEN 'FR'
        WHEN 'Lille' THEN 'FR'
        WHEN 'Strasbourg' THEN 'FR'
        WHEN 'Reims' THEN 'FR'
        WHEN 'Toulouse' THEN 'FR'
        WHEN 'Nantes' THEN 'FR'
        WHEN 'Frankfurt' THEN 'DE'
        WHEN 'Munich' THEN 'DE'
        WHEN 'Koln' THEN 'DE'
        WHEN 'Helsinki' THEN 'FI'
        WHEN 'Espoo' THEN 'FI'
        WHEN 'Oulu' THEN 'FI'
        WHEN 'Salzburg' THEN 'AT'
        WHEN 'Graz' THEN 'AT'
        WHEN 'Liverpool' THEN 'GB'
        WHEN 'London' THEN 'GB'
        WHEN 'Manchester' THEN 'GB'
        WHEN 'Aaarhus' THEN 'DK'
        WHEN 'Kobenhavn' THEN 'DK'
        WHEN 'Bergen' THEN 'NO'
        WHEN 'Oslo' THEN 'NO'
        WHEN 'Stavern' THEN 'NO'
        WHEN 'Torino' THEN 'IT'
        WHEN 'Bergamo' THEN 'IT'
        WHEN 'Reggio Emilia' THEN 'IT'
        WHEN 'Dublin' THEN 'IE'
        WHEN 'Charleroi' THEN 'BE'
        WHEN 'Bruxelles' THEN 'BE'
        WHEN 'Gensve' THEN 'CH'
        WHEN 'Barcelona' THEN 'ES'
        WHEN 'Madrid' THEN 'ES'
        WHEN 'Sevilla' THEN 'ES'
        WHEN 'Singapore' THEN 'SG'
        WHEN 'Boras' THEN 'SE'
        WHEN 'Makati City' THEN 'PH'
        ELSE state
    END
WHERE state = 'N/A';

-- Fix overly long or country-level state entries
UPDATE DimLocation
SET state = 
    CASE state
        WHEN 'Isle of Wight' THEN 'GB'
        WHEN 'Osaka'         THEN 'JP'
        WHEN 'Tokyo'         THEN 'JP'
        WHEN 'Quebec'        THEN 'CA'
        WHEN 'Queensland'    THEN 'AU'
        WHEN 'Victoria'      THEN 'AU'
        ELSE state
    END;

-- ======================================
-- Create Fact Table (FactSales)
-- ======================================

CREATE TABLE FactSales (
    sales_ID INT IDENTITY(1,1) PRIMARY KEY,
    order_Number VARCHAR(50),
    dateID INT FOREIGN KEY REFERENCES DimDate(DateID),
    customer_ID INT FOREIGN KEY REFERENCES DimCustomer(Customer_ID),
    product_ID INT FOREIGN KEY REFERENCES DimProduct(Product_ID),
    location_ID INT FOREIGN KEY REFERENCES DimLocation(Location_ID),
    quantity_Ordered INT,
    price_Each DECIMAL(10,2),
    sales DECIMAL(10,2),
    orderline_Number INT,
    status VARCHAR(50),
    deal_size VARCHAR(20)
);

-- Populate FactSales by joining all dimensions to the Pizza source table
INSERT INTO FactSales (
    order_Number,
    dateID,
    customer_ID,
    product_ID,
    location_ID,
    quantity_Ordered,
    price_Each,
    sales,
    orderline_Number,
    status,
    deal_size
)
SELECT
    p.order_number,
    d.DateID,
    c.Customer_ID,
    pr.Product_ID,
    l.Location_ID,
    p.quantity_ordered,
    p.price_each,
    p.sales,
    p.orderline_number,
    p.status,
    p.deal_size
FROM PizzaSales.dbo.Pizza p
JOIN DimDate d
    ON p.order_date = d.OrderDate
JOIN DimCustomer c
    ON p.customer_name = c.Customer_name
   AND p.contact_firstname = c.Contact_firstName
   AND p.contact_lastname = c.Contact_lastName
JOIN DimProduct pr
    ON p.product_code = pr.ProductCode
JOIN DimLocation l
    ON p.city = l.City
   AND p.state = l.State
   AND p.postal_code = l.PostalCode
   AND p.country = l.Country;

-- Final validation queries (optional)
SELECT * FROM FactSales;
SELECT * FROM Pizza;
