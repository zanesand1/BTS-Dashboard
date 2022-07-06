/*
Monthly Active Users by Week

Date (week) | Market | Count
-----------------------------
...         | ...     | ...

Dashboard: https://datastudio.google.com/reporting/b0ea098f-343e-4e50-8e3d-6dee640c0167
*/

CREATE OR REPLACE TABLE `erudite-idea-777.Zane_BTSDashboard.WeeklyMAU` AS

WITH

historicalDau AS (
  SELECT Date AS EventDate,
         c.Region AS Market,
         UserID
  FROM `erudite-idea-777.analytics_151921982.historical_dau` h
  JOIN `erudite-idea-777.Zane_BTSDashboard.CountryRegion` c
    ON h.country = c.Country
  WHERE CountUserEngagement > 0
),

dates AS (
  -- assumes there are 0 days where no one uses the app
  SELECT DISTINCT LAST_DAY(EventDate, WEEK(Saturday)) AS Date
  FROM historicalDau
),

eventsWithDate AS (
  SELECT dates.Date,
         historicalDau.Market,
         historicalDau.UserID
  FROM historicalDau
  JOIN dates
    ON DATE_DIFF(dates.Date, historicalDau.EventDate, DAY) <= 30
   AND DATE_DIFF(dates.Date, historicalDau.EventDate, DAY) >= 0
)

SELECT Date,
       Market,
       COUNT(DISTINCT UserID) AS Count
FROM eventsWithDate
GROUP BY Date, Market