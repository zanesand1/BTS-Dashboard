/*
Table that maps countries to marketing regions.

Country | Region
----------------
...     | ...

Regions (col. A): https://docs.google.com/spreadsheets/d/1kEQXS4B1QQKfscRHF8PQ4_GCzUmkzT47nt3iTRwUz9M/edit#gid=1534946732
*/

CREATE OR REPLACE TABLE `erudite-idea-777.Zane_BTSDashboard.CountryRegion` AS

SELECT DISTINCT country AS Country,
       CASE WHEN country = 'United States' THEN 'US (excl. PR)'
            WHEN country = 'Mexico' THEN 'Mexico'
            WHEN country = 'Spain' THEN 'Spain'
            WHEN country = 'Italy' THEN 'Italy'
            WHEN country IN (
              'Venezuela',
              'Uruguay',
              'Puerto Rico',
              'Peru',
              'Paraguay',
              'Panama',
              'Honduras',
              'Guatemala',
              'Guadeloupe',
              'Grenada',
              'Gibraltar',
              'El Salvador',
              'Ecuador',
              'Dominican Republic',
              'Costa Rica',
              'Argentina',
              'Belize',
              'Bolivia',
              'Colombia'
            ) THEN 'Rest of LatAm (excl. BR)'
            ELSE 'Rest of World' END AS Region
FROM `erudite-idea-777.analytics_151921982.historical_dau`