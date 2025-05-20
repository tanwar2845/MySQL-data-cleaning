-- =================================
-- Making duplicate table for backup
-- =================================

create table layoff2
select * from layoff;

-- ==================
-- Finding duplicates
-- ==================

with row_numb as
	(SELECT 
		*,
		row_number() 
        over(partition by 
					company,
                    location,
                    industry,
                    total_laid_off,
                    percentage_laid_off,
                    date,
                    stage,
                    country,
                    funds_raised_millions) as row_num
	FROM layoff2)
select * 
from row_numb
where row_num > 1;

-- ===================
-- Removing duplicates
-- ===================

create table delete_table
	select * from 
		(with row_numb as
			(SELECT 
				*,
				row_number() 
                over(partition by 
					company,
                    location,
                    industry,
                    total_laid_off,
                    percentage_laid_off,
                    date,
                    stage,
                    country,
                    funds_raised_millions) as row_num
			FROM layoff2)
		select * from row_numb
		where row_num = 1) as dt;
    
 -- ===========================
 -- Renaming table to 'layoff3'
 -- ===========================
 
rename table delete_table to layoff3;

-- ======================
-- Droping row_num column
-- ======================

alter table layoff3
drop row_num;

-- ===================
-- Standerize the data
-- ===================

select distinct(company)
from layoff3;

update layoff3
set company = trim(company);

select distinct(industry)
from layoff3
order by 1;

update layoff3
set industry = 'Crypto'
where industry like 'Crypto%';

select distinct(country)
from layoff3
order by 1;

update layoff3
set country = 'United States'
where country = 'United States.';

select 
STR_TO_DATE(date,'%m/%d/%Y')
from layoff3;

update layoff3
set date = STR_TO_DATE(date,'%m/%d/%Y');

alter table layoff3
modify date date;

-- ========================================
-- Populating industry with relavent values
-- ========================================

select company,industry
from layoff3
where industry is null
or industry = '';

update layoff3
set industry = null
where industry = '';

select tbl_1.company,tbl_1.industry,tbl_2.industry
from layoff3 tbl_1
join layoff3 tbl_2
on tbl_1.company = tbl_2.company
where tbl_1.industry is null and tbl_2.industry is not null;

update layoff3 tbl_1
join layoff3 tbl_2
on tbl_1.company = tbl_2.company
set tbl_1.industry = tbl_2.industry
where tbl_1.industry is null and tbl_2.industry is not null;

-- ======================================================================
-- Removing the rows where total_laid_off and percentage_laid_off is null
-- ======================================================================

select * from layoff3
where total_laid_off is null and percentage_laid_off is null;

delete
from layoff3
where total_laid_off is null and percentage_laid_off is null;

select * from layoff3;
