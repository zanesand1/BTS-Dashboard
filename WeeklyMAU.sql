/*
Monthly Active Users by Week

Date (every Sunday) | Market | Actual | Target
----------------------------------------------
...                 | ...    | ...    | ...

Dashboard: https://datastudio.google.com/reporting/b0ea098f-343e-4e50-8e3d-6dee640c0167
*/

CREATE OR REPLACE TABLE `erudite-idea-777.Zane_BTSDashboard.WeeklyMAU` AS

WITH

daily_MAU AS (
  SELECT mau_tbl.DATE,
         CASE WHEN cr.Region IS NULL THEN 'Rest of World' ELSE cr.Region END AS Region,
         SUM(mau_tbl.MAU) AS MAU
  FROM `photomath-dwh-prod.DWH.TBL_M_APP_MAU` AS mau_tbl
  LEFT JOIN `erudite-idea-777.Zane_BTSDashboard.CountryRegion` AS cr
    ON mau_tbl.COUNTRY_NAME = cr.Country
  GROUP BY mau_tbl.DATE, cr.Region
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
WHERE EXTRACT(DAYOFWEEK FROM TargetMAU2022.DATE) = 1