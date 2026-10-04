/* 
   Marketing A/B Test – Table Creation & Load Notes
   Database : MarketingAB 
   Table    : marketing_AB
*/

-- Create database (run once)
IF DB_ID('MarketingAB') IS NULL
    CREATE DATABASE MarketingAB;
GO

USE MarketingAB;
GO

-- Drop table if it already exists (useful when re-running)
IF OBJECT_ID('dbo.marketing_AB', 'U') IS NOT NULL
    DROP TABLE dbo.marketing_AB;
GO

-- Create the final table
CREATE TABLE dbo.marketing_AB (
    row_id          INT,                -- original CSV index
    user_id         BIGINT,
    test_group      VARCHAR(10),        -- 'ad' or 'psa'
    converted       BIT,                -- 1 = converted, 0 = not converted
    total_ads       INT,
    most_ads_day    VARCHAR(15),
    most_ads_hour   TINYINT
);
GO

/*
   LOADING
*/

--SQL Server Import Wizard (recommended for first load)
-- 1. Right-click database → Tasks → Import Data…
-- 2. Data source = Flat File Source → select marketing_AB.csv
-- 3. Check “Column names in the first data row”
-- 4. Destination = SQL Server Native Client → table marketing_AB
-- 5. Map columns carefully (converted → BIT)
-- 6. Run the package


-- Quick verification after load
SELECT COUNT(*) AS total_rows FROM dbo.marketing_AB;
SELECT TOP 10 * FROM dbo.marketing_AB;