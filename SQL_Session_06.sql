-- CTEs -> common table experssion (virtual table or a subset of a large data set
use bootcamp;
SELECT 
    *
FROM
    employee_dataset;
-- identify top three job roles among phd holders
with phd_holders as (select * from employee_dataset where Education = "PHD")
select JobRole, count(*) as count_employees from phd_holders group by JobRole
order by count_job_roles desc limit 3;


-- avg monthly income for job roles who have left the company
with employee_left as (select * from employee_dataset where Attrition = "Yes")
select JobRole, avg(MonthlyIncome) as avg_monthly_income from employee_left group by JobRole;

-- Identify the percentage of employees who worked over time in each department
with OverTimeCount as 
( select Department, 
count(*) as OverTimeCount
 from employee_dataset
 where OverTime = "Yes" 
 group by Department),
TotalCount as 
( select Department, 
count(*) as TotalCount
 from employee_dataset
 group by Department)
 select o.Department, o.OverTimeCount, t.TotalCount, 
 (o.OverTimeCount / t.TotalCount) * 100 as percent_over_time
 
 from TotalCount t join OverTimeCount o on o.Department = t.Department;
 
 
 -- what are the top three job role with highest avg job satisfaction who traveled most frequently
 -- (hint check who traveled frequently and then find the top three highest avg jobsatisfaction)
with frequent_travel as (select JobRole,
 avg(JobSatisfaction) as avg_job_satisfaction 
 from 
 employee_dataset 
 where BusinessTravel = 'Travel_Rarely'
 group by JobRole)
 select * from frequent_travel order by avg_job_satisfaction desc limit 3;
 
 with frequent_travel as (select *
 from 
 employee_dataset 
 where BusinessTravel = 'Travel_Rarely')
 select JobRole,
 avg(JobSatisfaction) as AvgJobSatisfaction
 from frequent_travel 
 group by JobRole
 order by AvgJobSatisfaction desc limit 3;
 
 
-- window functions
select first_name, last_name, gender , count(*) over(partition by gender) as gender_count from customer;

-- partition by
-- find avg salary of each department and order employees within the department by age
select Employee_ID,
 Age, Department, gender, 
 avg(MonthlyIncome) 
 over (partition by Department order by Age) 
 as avg_salary_per_department 
 from employee_dataset;
 
 -- find the avg performence rating within each department
 select Employee_ID, 
 Age, Department, gender,
 round(avg(PerformanceRating) 
 over (partition by Department))
 as avg_performence_rating
 from employee_dataset;
 
 
 -- what is the running total of sales for each product id ordered by sales
 select *,
 sum(total_amount)
 over (partition by product_id order by purchase_date)
 as running_total_sales 
 from purchase_history;
 
 -- rank each prodcut by its price_per_unit 
 select *,
 dense_rank() over (order by price_per_unit desc) as price_dense_rank from products;
 
  -- rank each prodcut by its price_per_unit in each brand
 select *,
 dense_rank() over (partition by brand order by price_per_unit desc) as price_dense_rank from products;
 
 -- rank employees by their monthly income within each departmet
 select Employee_ID, 
 Department, MonthlyIncome ,
 dense_rank() 
 over (partition by Department order by MonthlyIncome desc)
 as RankBySalary
 from employee_dataset;
 
 
 -- rank employees by years at the company within each jobrole
 select Employee_ID, 
 JobRole, YearsAtCompany,
 dense_rank() 
 over (partition by JobRole order by YearsAtCompany desc)
 as RankBYExperience
 from employee_dataset;
 
 
 -- row number
 -- in each department who are the employees with highest salaries
 -- and how do the rank compared with other in their department
 select 
 row_number() over (partition  by Department order by MonthlyIncome) as row_no,
 Employee_ID, Department, MonthlyIncome,
 rank() over (partition  by Department order by MonthlyIncome) as rank_salary,
 dense_rank() over (partition  by Department order by MonthlyIncome) as dense_salary
 from employee_dataset;
 
 
 -- how can you retrieve each prodcuts name along with
 -- the name of next prodcut within the same catagory within the products table
 select *,
 lead(product_name) over (partition by category) as next_product from products;
 
 
 -- interval between purchases in terms of days
 select * from purchase_history;
 select customer_id, purchase_id, purchase_date,
 lead(purchase_date)
 over (partition by customer_id order by purchase_date) 
 as next_date,
 datediff(lead(purchase_date)
 over (partition by customer_id order by purchase_date), purchase_date) as interval_between_purchase
 from purchase_history;
 
 
 -- calculate monthly increase or decrease in quantity sold in purchase 
with monthy_sales as (select Year(purchase_date) as sales_year,
month(purchase_date) as sales_month,
sum(quantity) as total_quantity_sold,
lag(sum(quantity)) over (order by Year(purchase_date), month(purchase_date)) as previous_month_quantity
 from purchase_history
group by Year(purchase_date), month(purchase_date) 
order by sales_year, sales_month)
select *,
case 
when previous_month_quantity < total_quantity_sold then "Increase"
when previous_month_quantity > total_quantity_sold then "Decrease"
else Null
end as quantity_incr_decr from monthy_sales
;