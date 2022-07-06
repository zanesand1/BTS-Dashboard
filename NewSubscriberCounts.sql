/*
New Subscriber Counts by User Category and Market

Date (week) | Market | UserCategory | Plan | Count
--------------------------------------------------
...         | ...    | ...          | ...  | ...

Dashboard: https://datastudio.google.com/reporting/b0ea098f-343e-4e50-8e3d-6dee640c0167
*/

CREATE OR REPLACE TABLE `erudite-idea-777.Zane_BTSDashboard.NewSubscriberCounts` AS

WITH

subscriptionInfo AS (
  SELECT LAST_DAY(event_date, WEEK(Saturday)) AS Date,
         length AS Plan,
         CASE WHEN a.iam IS NULL THEN 'Student' ELSE a.iam END AS UserCategory,
         b.Region AS Market,
         a.device_id AS UserID
  FROM `erudite-idea-777.analytics_151921982.sub_length_iam_breakdown` a
  JOIN `erudite-idea-777.analytics_151921982.country_code_mapping` c
    ON CASE WHEN LENGTH(a.country) = 2 THEN c.Alpha_2_code ELSE c.Alpha_3_code END = a.country
  JOIN `erudite-idea-777.Zane_BTSDashboard.CountryRegion` b
    ON c.country = b.Country
  WHERE event_name = 'Conversions'
)

SELECT Date,
       Market,
       UserCategory,
       Plan,
       COUNT(DISTINCT UserID) AS Count
FROM subscriptionInfo
GROUP BY Date, Market, UserCategory, Plan
