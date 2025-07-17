--- Data Exploring Project ---

Use [World Layoffs]

Select *
From layoffs_staging2


Select Max(total_laid_off), Max(percentage_laid_off)
From layoffs_staging2

--- LOOKING AT WHICH COMPANIES HAD THE HIGHEST LAY OFF PERCENTAGE --
Select *
From layoffs_staging2
Where percentage_laid_off = '1'
Order by total_laid_off DESC

--- LOOKING AT THE TOTAL LAID OFF BY COMPANY ---

Select company, Sum(total_laid_off) as Total_Employees_Let_Go
From layoffs_staging2
Group by company
Order by 2 DESC

--- LOOKINAT AT TOTAL LAID OFF BY INDUSTRY ---

Select industry, Sum(total_laid_off) as Total_Employees_Let_Go
From layoffs_staging2
Group by industry
Order by 2 DESC

--- LOOKING AT TOTAL LAID OFF BY COUNTRY ---

Select country, Sum(total_laid_off) as Total_Employees_Let_Go
From layoffs_staging2
Group by country
Order by 2 DESC

--- LOOKING AT TOTAL LAID OFF BY YEAR ---

Select Year(date), Sum(total_laid_off) as Total_Employees_Let_Go
From layoffs_staging2
Group by Year(date)
Order by 2 DESC

--- LOOKING AT TOTAL LAID OFF BY THE MONTH ---

SELECT SUBSTRING(CONVERT(VARCHAR, [date], 120), 1, 7) AS Month, Sum(total_laid_off)
FROM layoffs_staging2
WHERE [date] IS NOT NULL
GROUP BY SUBSTRING(CONVERT(VARCHAR, [date], 120), 1, 7)
ORDER BY Month ASC;

--- CREATING A ROLLING TOTAL COLUMN OF PEOPLE LAID OFF BY MONTH ---

With Rolling_Total As
(
SELECT SUBSTRING(CONVERT(VARCHAR, [date], 120), 1, 7) AS Month, Sum(total_laid_off) as total_off
FROM layoffs_staging2
WHERE [date] IS NOT NULL
GROUP BY SUBSTRING(CONVERT(VARCHAR, [date], 120), 1, 7)
)
Select Month, total_off, Sum(total_off) Over(Order by Month) as rolling_total
From Rolling_Total

--- LOOKING AT THE TOTAL LAY OFFS PER YEAR BY EACH COMPANY ---

Select company, Year(date), Sum(total_laid_off) as Total_Employees_Let_Go
From layoffs_staging2
Group by company, Year(date)
Order by 3 desc

--- RANKING EACH COMPANY BY HOW MANY EMPLOYEES THEY LAID OFF PER YEAR AND DISPLAYING THE TOP 5 PER YEAR ---

WITH company_year (company, years, total_laid_off) AS (
    SELECT 
        company, 
        YEAR([date]) AS layoff_year, 
        SUM(total_laid_off) AS Total_Employees_Let_Go
    FROM layoffs_staging2
    GROUP BY company, YEAR([date])
), company_year_rank As 
(SELECT *, Dense_Rank() Over(Partition by years order by total_laid_off desc) as Ranking
FROM company_year
Where years is not null
)
Select *
From company_year_rank
Where Ranking <= 5

--- CTE 1(company_year) GIVES THE TOTAL LAY OFFS BY COMPANY PER YEAR ---
--- CTE 2(company_year_rank) RANKS THE COMPANY BY TOTAL LAY OFFS PER YEAR ---

