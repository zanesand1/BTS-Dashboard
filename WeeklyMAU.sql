/*
Monthly Active Users by Week
Date (every Sunday) | Market | Actual | Target
----------------------------------------------
...                 | ...    | ...    | ...
Dashboard: https://datastudio.google.com/reporting/b0ea098f-343e-4e50-8e3d-6dee640c0167
*/

CREATE OR REPLACE TABLE `erudite-idea-777.Zane_BTSDashboard.WeeklyMAU` AS

WITH

historicalDAU AS (
  SELECT h.Date,
         CASE WHEN c.CountryID IS NULL THEN 'Rest of World' ELSE c.Region END AS Region,
         h.UserID
  FROM `erudite-idea-777.analytics_151921982.historical_dau` h
  LEFT JOIN `photomath-dwh-prod.DWH.TBL_D_DEVICE` d
    ON h.UserID = d.DEVICE_ID
  LEFT JOIN `erudite-idea-777.Zane_BTSDashboard.CountryRegion` c
    ON d.COUNTRY_ID = c.CountryID
  WHERE CountUserEngagement > 0
    AND EXTRACT(YEAR FROM Date) >= 2021
),

dates AS (
  SELECT date
  FROM UNNEST(
    GENERATE_DATE_ARRAY(
      DATE('2021-01-01'), DATE('2022-12-31'), INTERVAL 1 DAY
    ) 
  ) date
),

daily_MAU AS (
  SELECT dates.Date AS DATE,
        historicalDAU.Region,
        COUNT(DISTINCT historicalDAU.UserID) AS MAU
  FROM historicalDAU
  JOIN dates
    ON DATE_DIFF(historicalDAU.Date, dates.Date, DAY) <= 30
  AND DATE_DIFF(historicalDAU.Date, dates.Date, DAY) >= 0
  GROUP BY dates.Date, historicalDAU.Region
),

MAU2022 AS (
  SELECT *
  FROM daily_MAU
  WHERE EXTRACT(YEAR FROM DATE) = 2022
),

TargetMAU2022 AS (
  SELECT DATE_ADD(DATE, INTERVAL 1 YEAR) AS DATE,
         Region,
         MAU * 1.4 AS TargetMAU
  FROM daily_MAU
  WHERE EXTRACT(YEAR FROM DATE) = 2021
)

SELECT TargetMAU2022.DATE AS Date,
       TargetMAU2022.Region AS Market,
       MAU2022.MAU AS Actual,
       TargetMAU2022.TargetMAU AS Target
FROM TargetMAU2022
LEFT JOIN MAU2022
  ON TargetMAU2022.DATE = MAU2022.DATE
 AND TargetMAU2022.Region = MAU2022.Region
WHERE EXTRACT(DAYOFWEEK FROM TargetMAU2022.DATE) = 1;