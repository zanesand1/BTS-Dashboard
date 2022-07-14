/*
New Subscriber Counts by User Category and Market

Date | Region | Plan | CumulativeNewSubscriptions | Goal
----------------------------------------------------------
...  | ...    | ...  | ...                        | 115000

Dashboard: https://datastudio.google.com/reporting/b0ea098f-343e-4e50-8e3d-6dee640c0167
*/

CREATE OR REPLACE TABLE `erudite-idea-777.Zane_BTSDashboard.NewParentSubscriptionsByRegion2022` AS

WITH

parentSubscriptionEvents2022 AS (
    SELECT EXTRACT(DATE FROM f.EVENT_DT) AS EventDate,
           c.Region,
           CASE WHEN f.PRODUCT_ID LIKE '%one_month%' THEN 'one month'
                WHEN f.PRODUCT_ID LIKE '%six_month%' THEN 'six month'
                WHEN f.PRODUCT_ID LIKE '%monthly%' THEN 'monthly'
                WHEN f.PRODUCT_ID LIKE '%year%' THEN 'yearly'
                ELSE f.PRODUCT_ID END AS PlanType,
           f.DEVICE_ID AS UserID
    FROM `photomath-dwh-prod.DWH.TBL_F_SUBSCRIPTION_EVENT` AS f
    JOIN `photomath-dwh-prod.DWH.TBL_D_DEVICE` AS d
      ON d.DEVICE_ID = f.DEVICE_ID
    JOIN `erudite-idea-777.Zane_BTSDashboard.CountryRegion` c
      ON d.COUNTRY_ID = c.CountryID
    WHERE event_name IN (
      'ConversionFromBillingRetry',
      'ConversionToPurchase'
    )
      AND d.IAM IN (
      'Parent'
    )
      AND EXTRACT(YEAR FROM f.EVENT_DT) = 2022
),

dailyNewParentSubscribersByRegion AS (
  SELECT EventDate,
         PlanType,
         Region,
         COUNT(DISTINCT UserID) AS NewSubscriptions
  FROM parentSubscriptionEvents2022
  GROUP BY EventDate, PlanType, Region
)

SELECT EventDate,
       PlanType,
       Region,
       SUM(NewSubscriptions) OVER (PARTITION BY PlanType, Region ORDER BY EventDate ASC) AS CumulativeNewSubscriptions,
       115000 AS Goal
FROM dailyNewParentSubscribersByRegion