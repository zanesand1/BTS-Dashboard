/*
Table that maps countries to marketing regions.

CountryID | Region
------------------
...       | ...
*/

CREATE OR REPLACE TABLE `erudite-idea-777.Zane_BTSDashboard.CountryRegion` AS

SELECT COUNTRY_ID AS CountryID,
       CASE WHEN COUNTRY_NAME IN (
         'Canada',
         'United States of America'
       ) THEN 'US, CA'
            WHEN COUNTRY_NAME IN (
          'Italy'
       ) THEN 'Italy'
            ELSE 'Rest of World' END AS Region
FROM `photomath-dwh-prod.DWH.TBL_D_COUNTRY` AS country