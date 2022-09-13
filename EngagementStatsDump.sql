WITH

base AS (
  SELECT DISTINCT Country, Category, COUNT(UserID) AS Sample
  FROM `erudite-idea-777.Zane_Reporting.2022BTSWeekly`
  GROUP BY Country, Category
),

medianSession AS (
  SELECT Country,
         Category,
         ANY_VALUE(Median) AS MedianNumOfSession,
         COUNT(UserID) AS MedianNumOfSession_SampleSize
  FROM (
    SELECT UserID,
           Category,
           Country,
           PERCENTILE_DISC(NumOfSession, 0.5) OVER (PARTITION BY Category, Country) AS Median
    FROM `erudite-idea-777.Zane_Reporting.2022BTSWeekly`
    WHERE NumOfSession >= 1
  ) AS f
  GROUP BY Country, Category
),

medianSolutionShow AS (
  SELECT Country,
         Category,
         ANY_VALUE(Median) AS MedianSolutionShow,
         COUNT(UserID) AS MedianSolutionShow_SampleSize
  FROM (
    SELECT UserID,
           Category,
           Country,
           PERCENTILE_DISC(SolutionShow, 0.5) OVER (PARTITION BY Category, Country) AS Median
    FROM `erudite-idea-777.Zane_Reporting.2022BTSWeekly`
    WHERE SolutionShow >= 1
  ) AS f
  GROUP BY Country, Category
),

medianSolutionButtonClick AS (
  SELECT Country,
         Category,
         ANY_VALUE(Median) AS MedianSolutionButtonClick,
         COUNT(UserID) AS MedianSolutionButtonClick_SampleSize
  FROM (
    SELECT UserID,
           Category,
           Country,
           PERCENTILE_DISC(SolutionButtonClick, 0.5) OVER (PARTITION BY Category, Country) AS Median
    FROM `erudite-idea-777.Zane_Reporting.2022BTSWeekly`
    WHERE SolutionButtonClick	>= 1
  ) AS f
  GROUP BY Country, Category
),

pctSolutionShow AS (
  SELECT Country,
         Category,
         COUNT(UserID) AS countOverOne
  FROM `erudite-idea-777.Zane_Reporting.2022BTSWeekly`
  WHERE SolutionShow >= 1
  GROUP BY Country, Category
),

pctSolutionClick AS (
  SELECT Country,
         Category,
         COUNT(UserID) AS countOverOne
  FROM `erudite-idea-777.Zane_Reporting.2022BTSWeekly`
  WHERE SolutionButtonClick >= 1
  GROUP BY Country, Category
)

SELECT base.Country,
       base.Category,
       base.Sample,
       medianSession.MedianNumOfSession,
       medianSession.MedianNumOfSession_SampleSize,
       medianSolutionShow.MedianSolutionShow,
       medianSolutionShow.MedianSolutionShow_SampleSize,
       medianSolutionButtonClick.MedianSolutionButtonClick,
       medianSolutionButtonClick.MedianSolutionButtonClick_SampleSize,
       pctSolutionShow.countOverOne / base.Sample AS PctSolutionShowOverOne,
       pctSolutionShow.countOverOne AS PctSolutionShowOverOne_SampleSize,
       pctSolutionClick.countOverOne / base.Sample AS PctSolutionClickOverOne,
       pctSolutionClick.countOverOne AS PctSolutionClickOverOne_SampleSize
FROM base
LEFT JOIN medianSession
  ON base.Country = medianSession.Country
 AND base.Category = medianSession.Category
LEFT JOIN medianSolutionShow
  ON base.Country = medianSolutionShow.Country
 AND base.Category = medianSolutionShow.Category
LEFT JOIN medianSolutionButtonClick
  ON base.Country = medianSolutionButtonClick.Country
 AND base.Category = medianSolutionButtonClick.Category
LEFT JOIN pctSolutionShow
  ON base.Country = pctSolutionShow.Country
 AND base.Category = pctSolutionShow.Category
LEFT JOIN pctSolutionClick
  ON base.Country = pctSolutionClick.Country
 AND base.Category = pctSolutionClick.Category
ORDER BY base.Country, base.Category