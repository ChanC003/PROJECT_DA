ALTER TABLE service_data
ADD CONSTRAINT fk_branch_sv
FOREIGN KEY (branch_id) REFERENCES branch_data(Branch_ID)

--DOANH THU THEO LOẠI HÌNH DỊCH VỤ
SELECT department ,SUM(total_revenue) AS TotalRevenue
FROM service_data
GROUP BY department
ORDER BY TotalRevenue DESC;

--DOANH THU THEO KHU VỰC
SELECT b.Region , SUM(s.total_revenue) AS TotalRevenue
FROM service_data s JOIN branch_data b ON s.branch_id = b.Branch_ID
GROUP BY b.Region
ORDER BY TotalRevenue DESC;

-- LOẠI HÌNH DỊCH VỤ MANG LẠI DOANH SỐ CAO NHẤT TRONG TỪNG KHU VỰC KHU VỰC 
WITH RankedServices AS (
  SELECT
    s.service_description,
    b.Region,
   SUM(s.total_revenue) AS total_revenue,
    RANK() OVER (PARTITION BY b.Region ORDER BY SUM(s.total_revenue) DESC) AS rnk
  FROM
    service_data s
  JOIN
    branch_data b ON s.branch_id = b.Branch_ID
	GROUP BY
        s.service_description, b.Region
)
SELECT
 
  Region, service_description,
  total_revenue
FROM
  RankedServices
WHERE
  rnk = 1;

--DOANH THU THEO PHÒNG BAN
SELECT department ,SUM(total_revenue) AS TotalRevenue
FROM service_data
GROUP BY department
ORDER BY TotalRevenue DESC;
 
 --DOANH THU THEO KHÁCH HÀNG
 SELECT client_name AS Client_name  ,SUM(total_revenue) AS TotalRevenue,COUNT(client_name) AS NumberOfTransactions
FROM service_data
GROUP BY client_name
ORDER BY TotalRevenue DESC;

--TỔNG DOANH THU
SELECT SUM(total_revenue) AS TotalRevenue
FROM service_data

--TỔNG LƯỢT DỊCH VỤ ĐÃ CUNG CẤP
SELECT COUNT (*) AS Total 
FROM service_data

--TỔNG GIỜ DỊCH VỤ
SELECT SUM(hours) AS TotalHours
FROM service_data


--TÍNH DOANH THU THEO KHU VỰC TRÊN TỔNG DOANH THU
WITH RevenueRegion AS (SELECT b.Region , SUM(s.total_revenue) AS TotalRevenue
FROM service_data s JOIN branch_data b ON s.branch_id = b.Branch_ID
GROUP BY b.Region )
SELECT Region , ( TotalRevenue /( SELECT SUM( total_revenue) FROM service_data))*100 AS RevenueRegionoverOverallRevenue
FROM RevenueRegion
ORDER BY Region;

--TÍNH PHẦN TRĂM DOANH THU TĂNG THEO THÁNG 
WITH MonthlyRevenue AS (
    SELECT 
        FORMAT(service_date, 'yyyy-MM') AS Month,
        SUM(total_revenue) AS Revenue
    FROM 
        service_data
    GROUP BY 
        FORMAT(service_date, 'yyyy-MM')
),
RevenueComparison AS (
    SELECT 
        Month,
        Revenue,
        LAG(Revenue) OVER (ORDER BY Month) AS PreviousMonthRevenue
    FROM 
        MonthlyRevenue
)
SELECT 
    Month,
    Revenue,
    PreviousMonthRevenue,
    CASE WHEN PreviousMonthRevenue > 0 THEN ((Revenue - PreviousMonthRevenue) / PreviousMonthRevenue) * 100 ELSE NULL END AS RevenuePercentageIncrease
FROM 
    RevenueComparison
WHERE 
    PreviousMonthRevenue IS NOT NULL;
