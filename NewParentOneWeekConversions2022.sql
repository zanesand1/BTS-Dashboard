/*
Table to pull whether or not a parent has converted within 2 weeks of install & 
the average conversion rate for parents during BTS season last year (2021).

Date | Market | Converted | Goal
--------------------------------
...  | ...    | ...       | ...

Dashboard: https://datastudio.google.com/reporting/b0ea098f-343e-4e50-8e3d-6dee640c0167
*/

CREATE OR REPLACE TABLE `erudite-idea-777.Zane_BTSDashboard.NewParentOneWeekConversions2022` AS

WITH

newParentInstalls AS (
  SELECT cr.Region,
         d.DEVICE_ID AS UserID,
         EXTRACT(DATE FROM d.FIRST_APP_INSTALLATION_DT) AS InstallDate
  FROM `photomath-dwh-prod.DWH.TBL_D_DEVICE` d
  JOIN `erudite-idea-777.Zane_BTSDashboard.CountryRegion` cr
    ON d.COUNTRY_ID = cr.CountryID
  WHERE d.IAM = 'Parent'
),

newParentConversions AS (
    SELECT EXTRACT(DATE FROM f.EVENT_DT) AS EventDate,
           f.DEVICE_ID AS UserID
    FROM `photomath-dwh-prod.DWH.TBL_F_SUBSCRIPTION_EVENT` AS f
    JOIN `photomath-dwh-prod.DWH.TBL_D_DEVICE` AS d
      ON d.DEVICE_ID = f.DEVICE_ID
    WHERE event_name IN (
      'ConversionFromBillingRetry',
      'ConversionToPurchase'
    )
      AND d.IAM IN (
      'Parent'
    )
),

parentConvertedInFirstWeek AS (
  SELECT newParentInstalls.InstallDate,
         newParentInstalls.Region,
         CASE WHEN newParentConversions.UserID IS NOT NULL AND DATE_DIFF(newParentConversions.EventDate, newParentInstalls.InstallDate, DAY) <= 14 THEN 1 ELSE 0 END AS Converted
  FROM newParentInstalls
  LEFT JOIN newParentConversions
    ON newParentInstalls.UserID = newParentConversions.UserID
),

bts2021ParentConversions AS (
  SELECT SUM(Converted) / COUNT(Converted) AS ConversionRate
  FROM parentConvertedInFirstWeek
  WHERE InstallDate >= DATE(2021, 08, 01)
    AND InstallDate <= DATE(2021, 10, 31)
)

SELECT InstallDate AS Date,
       Region AS Market,
       Converted,
       (SELECT ConversionRate FROM bts2021ParentConversions) AS Goal
FROM parentConvertedInFirstWeek
WHERE InstallDate >= DATE(2022, 01, 01)