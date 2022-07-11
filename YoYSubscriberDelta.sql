/*
New Subscriber Counts by User Category and Market

Date | Market | UserCategory | Plan | YoYDelta
----------------------------------------------
...  | ...    | ...          | ...  | ...

Dashboard: https://datastudio.google.com/reporting/b0ea098f-343e-4e50-8e3d-6dee640c0167
*/

CREATE OR REPLACE TABLE `erudite-idea-777.Zane_BTSDashboard.NewSubscriberYearDelta` AS

WITH

subscriptionInfo AS (
  SELECT event_date AS Date,
         length AS Plan,
         CASE WHEN a.iam IS NULL THEN 'Student' ELSE a.iam END AS UserCategory,
         b.Region AS Market,
         CASE WHEN a.device_id IS NULL THEN '123' ELSE a.device_id END AS UserID
  FROM `erudite-idea-777.analytics_151921982.sub_length_iam_breakdown` a
  LEFT JOIN `erudite-idea-777.analytics_151921982.country_code_mapping` c
    ON CASE WHEN LENGTH(a.country) = 2 THEN c.Alpha_2_code ELSE c.Alpha_3_code END = a.country
  LEFT JOIN `erudite-idea-777.Zane_BTSDashboard.CountryRegion` b
    ON c.country = b.Country
  WHERE event_name = 'Conversions'
    AND event_date >= '2021-01-01'
),

data2022 AS (
  SELECT Date,
         Market,
         UserCategory,
         Plan,
         COUNT(DISTINCT UserID) AS Count
  FROM subscriptionInfo
  WHERE Date >= '2022-01-01'
    AND Date <= '2022-12-31'
  GROUP BY Date, Market, UserCategory, Plan
),

data2021 AS (
  SELECT Date,
         Market,
         UserCategory,
         Plan,
         COUNT(DISTINCT UserID) AS Count
  FROM subscriptionInfo
  WHERE Date >= '2021-01-01'
    AND Date <= '2021-12-31'
  GROUP BY Date, Market, UserCategory, Plan
)

SELECT data2022.Date,
       data2022.Market,
       data2022.UserCategory,
       data2022.Plan,
       (data2022.Count - data2021.Count) / data2021.Count AS YoYDelta
FROM data2022
JOIN data2021
  ON EXTRACT(DAYOFYEAR FROM data2022.Date) = EXTRACT(DAYOFYEAR FROM data2021.Date)
 AND data2022.Market = data2021.Market
 AND data2022.UserCategory = data2021.UserCategory
 AND data2022.Plan = data2021.Plan

