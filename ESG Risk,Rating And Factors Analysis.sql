use etl;
select*from esg_rating_data;

--                                               ESG Risk Ratings and Factors Analysis 



/* About the Dataset ---
This dataset is dedicated to featuring companies listed in the S&P 500 index, offering a valuable resource for researchers, investors, analysts,
 and policy-makers interested in understanding the sustainability and governance practices of these prominent corporations. Whether you're 
 examining trends, evaluating ESG performance, or making investment choices, this dataset provides insights into the ESG performance and 
 risk profiles of S&P 500 companies.                                                                                                          */
 
 /* Objective of this Project ---
 Conducted comprehensive performance assessments of companies within the dataset, evaluating their ESG scores and benchmarking them against 
 industry standards to provide actionable insights for investment decision-making.                                                           */
 
 desc esg_rating_data;
 
 -- Basic Descriptive Analysis:
/* What are the minimum, maximum, and average values of the Total ESG Risk Score, Environment Risk Score, Governance Risk Score, and 
Social Risk Score? */

select min(`Total ESG Risk score`) as  `Min ESG score`, max(`Total ESG Risk score`) as `Max ESG score`,
round(avg(`Total ESG Risk score`)) as `Avg ESG score`,min(`Environment Risk Score`) as `min Environment Risk Score`,
max(`Environment Risk Score`) as `MAX Environment Risk Score`,round(avg(`Environment Risk Score`)) as `Avg Environment Risk Score`,
min(`Governance Risk Score`) as ` Min Governance Risk Score` ,max(`Governance Risk Score`) as `Max Governance Risk Score` ,
round(avg(`Governance Risk Score`)) as `Avg Governance Risk Score`,min(`Social Risk Score`) as `Min Social Risk Score` ,
max(`Social Risk Score`) as ` Max Social Risk Score` ,round(avg(`Social Risk Score`)) as `Avg Social Risk Score` from esg_rating_data;

-- How many unique companies are included in the dataset?
select COUNT(DISTINCT(Name)) as unique_companies from esg_rating_data; 

-- Show the description of companies with a high governance risk score.
select Name,Description,`Controversy Score` from esg_rating_data order by `Controversy Score` desc limit 0,10;  

-- Calculate the average environment risk score for each industry.
select industry,round(avg(`Environment Risk Score`)) from esg_rating_data group by industry having round(avg(`Environment Risk Score`));

-- Find companies with a high controversy level and low governance risk score.
select name,`governance risk score`,(select `Controversy Score` from esg_rating_data order by `Controversy Score` desc limit 1) 
as Max_con_score from esg_rating_data order by `governance risk score` limit 1;

-- Find the average total ESG risk score for companies in the same sector as the company with the highest controversy score.
select name,sector,`Controversy Score`,(select round(avg(`Environment Risk Score`)) from esg_rating_data) as avg_esg_score 
from esg_rating_data order by `Controversy Score` desc limit 1;

/*Retrieve the names and descriptions of companies that have a higher total ESG risk score than 
the average ESG risk score across all companies.*/
select name,Description,`Environment Risk Score` from esg_rating_data
 where `Environment Risk Score`>(select round(avg(`Environment Risk Score`)) from esg_rating_data);
 
 /*Retrieve the names and sector of companies that have a higher total ESG risk score than 
the Minmum ESG risk score across all companies.*/
select Name,sector,`Environment Risk Score` from esg_rating_data 
where `Environment Risk Score`>(select round(min(`Environment Risk Score`)) from esg_rating_data); 

-- Sector and Industry Analysis:

-- Which sectors and industries have the highest average Total ESG Risk Score?
select sector,industry,`Total ESG Risk score` from esg_rating_data 
where `Total ESG Risk score` > (select avg(`Total ESG Risk score`) from esg_rating_data);

-- Are there any sectors or industries that consistently perform poorly as per ESG risk level ?
select sector,industry,`ESG Risk Level` from esg_rating_data where `ESG Risk Level`='low';

-- Controversy Analysis:
-- How many companies have a Controversy Level above a certain threshold (e.g., Moderate or high)?
select name,`Controversy Level` from esg_rating_data where `Controversy Level`='high' or `Controversy Level`='Moderate';

-- Is there any correlation between the Controversy Score and the Total ESG Risk Score?
select (AVG(`Controversy Score` * `Total ESG Risk score`) - AVG(`Controversy Score`) * AVG(`Total ESG Risk score`)) / 
(STDDEV(`Controversy Score`) * STDDEV(`Total ESG Risk score`)) AS `correlation of Controversy score and Total ESG Risk Score`
FROM esg_rating_data;

-- ESG Risk Percentile Analysis:

-- What percentage of companies fall within each percentile range of ESG Risk Percentile?
with RankedCompanies as(select Name,`ESG Risk Percentile`,percent_rank() over (order by `ESG Risk Percentile`) 
as PercentileRank from esg_rating_data) select CONCAT(ROUND(PercentileRank * 100, 2),'% - ',ROUND((PercentileRank + 0.01) * 100, 2),'%')
 as PercentileRange,count(*) as name from RankedCompanies group by PercentileRange order by PercentileRange;

-- Are there any sectors or industries that are overrepresented in the lower percentiles?
select sector,industry,`ESG Risk Percentile` from esg_rating_data where `ESG Risk Percentile` in 
(select min(`ESG Risk Percentile`) from esg_rating_data);

-- Comparison Across Risk Categories:
-- How do the distributions of Environment, Social, and Governance Risk Scores vary across different sectors?
select sector,round(avg(`Total ESG Risk score`)) AS avg_esg_score,min(`Total ESG Risk score`) AS min_esg_score,
max(`Total ESG Risk score`) as max_esg_score from esg_rating_data group by sector;

-- Company Size Analysis:

-- Is there a correlation between the size of a company (measured by Full Time Employees) and its Total ESG Risk Score?
select (AVG(`Full Time Employees` * `Total ESG Risk score`) - AVG(`Full Time Employees`) * AVG(`Total ESG Risk score`)) / 
(STDDEV(`Full Time Employees`) * STDDEV(`Total ESG Risk score`)) AS `correlation of Full Time Employees and Total ESG Risk Score`
FROM esg_rating_data;

-- Ranking and Benchmarking:

-- Can you identify the top-performing companies by total ESG risk ?
select name,`Total ESG Risk score`from esg_rating_data order by `Total ESG Risk score` desc limit 0,10;  

-- Can you identify the top-performing companies by Controversy Score ?
select name,`Controversy Score` from esg_rating_data order by `Controversy Score` desc limit 0,10;

-- How does the performance of specific companies compare to industry 'Entertainment' or 'Semiconductors'?
select name,industry,`Total ESG Risk score` from esg_rating_data where industry='Entertainment' or industry='Semiconductors' 
order by `Total ESG Risk score` desc limit 0,10;
