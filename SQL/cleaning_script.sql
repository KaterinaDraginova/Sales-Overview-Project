--This script performs data cleaning and transformation.
--It includes data type conversions, formatting fixes, null replacements, and value standardization to prepare the dataset for analytical use in Power BI.




-- Convert 'Order_Number' column to INTEGER data type
ALTER TABLE pizza
ALTER COLUMN Order_Number INT;

-- Convert 'quantity_ordered' column to INTEGER data type
ALTER TABLE pizza
ALTER COLUMN quantity_ordered INT;

-- Convert 'sales' column to FLOAT
-- First, identify non-numeric entries that could cause conversion issues
SELECT *
FROM pizza
WHERE TRY_CAST(Sales AS FLOAT) IS NULL AND Sales IS NOT NULL;

-- Clean 'sales' column by removing commas
UPDATE pizza
SET Sales = REPLACE(Sales, ',', '');

-- Apply the data type conversion
ALTER TABLE pizza
ALTER COLUMN Sales FLOAT;

-- Convert 'price_each' column to FLOAT
-- First, identify problematic values
SELECT *
FROM pizza
WHERE TRY_CAST(price_each AS FLOAT) IS NULL AND price_each IS NOT NULL;

-- Clean 'price_each' column by removing commas
UPDATE pizza
SET price_each = REPLACE(price_each, ',', '');

-- Apply the data type conversion
ALTER TABLE pizza
ALTER COLUMN price_each FLOAT;

-- Convert 'orderline_number' column to INTEGER
ALTER TABLE pizza
ALTER COLUMN orderline_number INT;

-- Convert 'order_date' column to DATE format
ALTER TABLE pizza
ALTER COLUMN order_date DATE;

-- Convert 'qtr_id' column to INTEGER
ALTER TABLE pizza
ALTER COLUMN qtr_id INT;

-- Convert 'month_id' column to INTEGER
ALTER TABLE pizza
ALTER COLUMN month_id INT;

-- Convert 'year_id' column to INTEGER
ALTER TABLE pizza
ALTER COLUMN year_id INT;

-- Convert 'msrp' column to INTEGER
ALTER TABLE pizza
ALTER COLUMN msrp INT;

-- Standardize 'phone' values by removing special characters and formatting them consistently
UPDATE pizza
SET phone = 
    CASE 
        WHEN phone LIKE '+%' THEN 
            '+' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                phone, '(', ''), ')', ''), '-', ''), '.', ''), ' ', ''), ',', ''), '+', '')
        ELSE 
            '+' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                phone, '(', ''), ')', ''), '-', ''), '.', ''), ' ', ''), ',', ''), '+', '')
    END;


-- Standardize city name
UPDATE pizza
SET city = REPLACE(city, 'NYC', 'New York City');

-- Replace NULL values in 'state' with 'N/A'
UPDATE pizza
SET state = ISNULL(state, 'N/A');

-- Backfill missing state values in 'factsales' based on known city-to-country mappings
UPDATE factsales
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
WHERE state = 'N/A' 
  AND City IN (
    'Paris','Lyon','Marseille','Versailles','Lille','Strasbourg','Reims','Toulouse','Nantes',
    'Frankfurt','Munich','Koln',
    'Helsinki','Espoo','Oulu',
    'Salzburg','Graz',
    'Liverpool','London','Manchester',
    'Aaarhus','Kobenhavn',
    'Bergen','Oslo','Stavern',
    'Torino','Bergamo','Reggio Emilia',
    'Dublin',
    'Charleroi','Bruxelles',
    'Gensve',
    'Barcelona','Madrid','Sevilla',
    'Singapore',
    'Boras',
    'Makati City'
);

