CREATE TABLE telco_churn (
    customerID VARCHAR(20),
    gender VARCHAR(10),
    SeniorCitizen INT,
    Partner VARCHAR(5),
    Dependents VARCHAR(5),
    tenure INT,
    PhoneService VARCHAR(5),
    MultipleLines VARCHAR(20),
    InternetService VARCHAR(20),
    OnlineSecurity VARCHAR(20),
    OnlineBackup VARCHAR(20),
    DeviceProtection VARCHAR(20),
    TechSupport VARCHAR(20),
    StreamingTV VARCHAR(20),
    StreamingMovies VARCHAR(20),
    Contract VARCHAR(20),
    PaperlessBilling VARCHAR(5),
    PaymentMethod VARCHAR(50),
    MonthlyCharges FLOAT,
    TotalCharges VARCHAR(20),
    Churn VARCHAR(5)
);
-- drop table telco_churn;

select * from telco_churn;

COPY telco_churn
FROM 'D:/telco_churn_cleaned.csv'
DELIMITER ','
CSV HEADER;


1-- Overall churn rate calculate karo
SELECT 
    Churn,
    COUNT(*) as total_customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
FROM telco_churn
GROUP BY Churn;

2-- Contract type ke basis pe churn analyze karo
SELECT 
    Contract,
    Churn,
    COUNT(*) as total_customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(PARTITION BY Contract), 2) as churn_percentage
FROM telco_churn
GROUP BY Contract, Churn
ORDER BY Contract, Churn;

3 
select
   case 
   when tenure < 6 then '0-6 month'
   when tenure < 12 then '6-12 month'
   when tenure < 24 then '1-2 years'
   Else '2+ years'
  END as tenure_group,
   COUNT(*) as total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) as churned,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as churn_rate
FROM telco_churn
GROUP BY tenure_group
ORDER BY churn_rate DESC;

4
-- Churned vs retained customers ki average monthly charges
SELECT 
    Churn,
    ROUND(AVG(MonthlyCharges::numeric), 2) as avg_monthly_charges,
    ROUND(MIN(MonthlyCharges::numeric), 2) as min_charges,
    ROUND(MAX(MonthlyCharges::numeric), 2) as max_charges
FROM telco_churn
GROUP BY Churn;
5 -- Total revenue loss from churned customers
SELECT 
    ROUND(SUM(MonthlyCharges::numeric), 2) as monthly_revenue_loss,
    ROUND(SUM(MonthlyCharges::numeric) * 12, 2) as yearly_revenue_loss
FROM telco_churn
WHERE Churn = 'Yes';
-- Internet service type vs churn
SELECT 
    InternetService,
    Churn,
    COUNT(*) as total_customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(PARTITION BY InternetService), 2) as churn_percentage
FROM telco_churn
GROUP BY InternetService, Churn
ORDER BY InternetService, Churn;

7-- Senior citizen vs churn
SELECT 
    CASE WHEN SeniorCitizen = 1 THEN 'Senior' 
         ELSE 'Non-Senior' 
    END as customer_type,
    COUNT(*) as total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) as churned,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as churn_rate
FROM telco_churn
GROUP BY SeniorCitizen
ORDER BY churn_rate DESC;