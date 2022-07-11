/*
Monthly Active Users by Week

Date (week) | Market | ActualMAU | TargetMAU
--------------------------------------------
...         | ...    | ...       | ...

Dashboard: https://datastudio.google.com/reporting/b0ea098f-343e-4e50-8e3d-6dee640c0167
*/

CREATE OR REPLACE TABLE `erudite-idea-777.Zane_BTSDashboard.WeeklyMAU` AS

WITH

historicalDAU AS (
  SELECT Date AS EventDate,
         c.Region AS Market,
         UserID
  FROM `erudite-idea-777.analytics_151921982.historical_dau` h
  JOIN `erudite-idea-777.Zane_BTSDashboard.CountryRegion` c
    ON h.country = c.Country
  WHERE CountUserEngagement > 0
    AND Date >= '2020-12-01'
),

dates AS (
  SELECT Date
  FROM UNNEST(
    GENERATE_DATE_ARRAY(DATE('2021-01-01'), DATE('2022-12-31'), INTERVAL 7 DAY)
  ) Date
),

eventsWithDate AS (
  SELECT dates.Date AS EventDate,
         historicalDAU.Market,
         historicalDAU.UserID
  FROM historicalDAU
  JOIN dates
    ON DATE_DIFF(dates.Date, historicalDAU.EventDate, DAY) <= 30
   AND DATE_DIFF(dates.Date, historicalDAU.EventDate, DAY) >= 0
),

MAU2022 AS (
  SELECT EventDate,
         Market,
         COUNT(DISTINCT UserID) AS ActualMAU
  FROM eventsWithDate
  WHERE EXTRACT(YEAR FROM eventsWithDate.EventDate) = 2022
  GROUP BY EventDate, Market
),

MAU2021 AS (
  SELECT EventDate,
         Market,
         COUNT(DISTINCT UserID) AS ActualMAU
  FROM eventsWithDate
  WHERE EXTRACT(YEAR FROM eventsWithDate.EventDate) = 2021
  GROUP BY EventDate, Market
),

TargetMAU2022 AS (
  SELECT EventDate,
         Market,
         ActualMAU * 1.4 AS TargetMAU
  FROM MAU2021
)

SELECT DATE_ADD(TargetMAU2022.EventDate, INTERVAL 1 YEAR) AS Date,
       MAU2022.Market,
       MAU2022.ActualMAU,
       TargetMAU2022.TargetMAU
FROM TargetMAU2022
LEFT JOIN MAU2022
  ON EXTRACT(WEEK FROM MAU2022.EventDate) = EXTRACT(WEEK FROM TargetMAU2022.EventDate)
 AND MAU2022.Market = TargetMAU2022.Market