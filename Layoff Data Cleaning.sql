---DATA CLEANING PROJECT---

Use [World Layoffs]

Select *
From layoffs

--- Step 1. Remove duplicates
--- Step 2. Standardize Data
--- Step 3. NULL values or blank values
--- Step 4. Remove unnecessary columns

--- Creating a duplicate table---

Select * 
Into layoffs_staging
From layoffs
Where 1=0

Insert layoffs_staging
Select *
From layoffs

Select *
From layoffs_staging

--- STEP 1. REMOVING DUPLICATES ---

Select *
From layoffs_staging

SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY company, industry, total_laid_off, percentage_laid_off, [date]
           ORDER BY [date]
       ) AS row_num
FROM layoffs_staging;

---If row number is 2 or above there are duplicates---

With duplicate_cte As
(
SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, [date], stage, country, funds_raised_millions
           ORDER BY [date]
       ) AS row_num
FROM layoffs_staging
)
Select *
From duplicate_cte
Where row_num > 1

Select *
From layoffs_staging
Where company = 'Casper'

--- Creating a copy of all columns including row_num into a new table to prepare to delete the duplicates---
CREATE TABLE [dbo].[layoffs_staging2](
	[company] [nvarchar](255) NULL,
	[location] [nvarchar](255) NULL,
	[industry] [nvarchar](255) NULL,
	[total_laid_off] [float] NULL,
	[percentage_laid_off] [nvarchar](255) NULL,
	[date] [datetime] NULL,
	[stage] [nvarchar](255) NULL,
	[country] [nvarchar](255) NULL,
	[funds_raised_millions] [float] NULL,
	[row_num] [INT]
)

Insert into layoffs_staging2
SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY company, industry, total_laid_off, percentage_laid_off, [date]
           ORDER BY [date]
       ) AS row_num
FROM layoffs_staging;

select * 
from layoffs_staging2


---Deleting Duplicates---

Delete 
From layoffs_staging2
Where row_num > 1


--- STEP 2. STANDARDIZING DATA ---

--- Standardizing the spacing---
Select company, trim(company)
From layoffs_staging2

Update layoffs_staging2
Set company = trim(company)

--- Standardizing group names(industry in this case)---

Select *
From layoffs_staging2
Where industry like 'Crypto%'

Update layoffs_staging2
Set industry = 'Crypto'
Where industry like 'Crypto%'

Select distinct industry
From layoffs_staging2
order by 1

--- Fixing Country Name (There was an entry with a period after United States) ---

Select distinct country, trim(Trailing '.' From Country )
From layoffs_staging2
Order by 1

Update layoffs_staging2
Set Country = trim(Trailing '.' From Country)
Where country like 'United States%'

--- Updating date formatting ---

SELECT 
    [date],
    TRY_CONVERT(DATE, [date], 101) AS formatted_date
FROM layoffs_staging2;

---Changing the date values in table---
UPDATE layoffs_staging2
SET [date] = TRY_CONVERT(DATE, [date], 101);


--- Changing the column type---
ALTER TABLE layoffs_staging2
ALTER COLUMN [date] DATE;

--- STEP 3. WORKING WITH NULL AND BLANK VALUES ---

Select *
From layoffs_staging2
Where total_laid_off Is Null
And percentage_laid_off is Null

Select *
From layoffs_staging2
Where industry is null

Select *
From layoffs_staging2
Where company = 'Airbnb'

Select *
From layoffs_staging2 t1
Join layoffs_staging2 t2
    On t1.company=t2.company
    And t1.location=t2.location
Where t1.industry is NULL
And t2.industry is not NULL


--- Updates the table so that any rows with the same company and same location also have the same industry ---
UPDATE t1
SET t1.industry = t2.industry
FROM layoffs_staging2 t1
INNER JOIN layoffs_staging2 t2
    ON t1.company = t2.company
   AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
  AND t2.industry IS NOT NULL;


--- STEP 4. REMOVE UNNECESSARY COLUMNS --- 
Alter table layoffs_staging2
Drop column row_num

Select * from layoffs_staging2

