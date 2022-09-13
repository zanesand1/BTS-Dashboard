DECLARE _begin DATE DEFAULT '2022-09-04';
DECLARE _end DATE DEFAULT '2022-09-10';
DECLARE _begin_str STRING DEFAULT '20220904';
DECLARE _end_str STRING DEFAULT '20220910';

CREATE OR REPLACE TABLE `erudite-idea-777.Zane_Reporting.2022BTSWeekly` AS

WITH

installDate AS (
  SELECT MIN(Date) AS installDate,
         UserID
  FROM `erudite-idea-777.analytics_151921982.historical_dau`
  GROUP BY UserID
),

previouslyActive AS (
  SELECT DISTINCT UserID
  FROM `erudite-idea-777.analytics_151921982.historical_dau`
  WHERE Date BETWEEN DATE_SUB(_end, INTERVAL 60 DAY) AND DATE_SUB(_end, INTERVAL 30 DAY)
    AND CountUserEngagement > 0
),

users AS (
  SELECT DISTINCT d.UserID, i.installDate, d.country
  FROM `erudite-idea-777.analytics_151921982.historical_dau` d
  JOIN installDate i ON d.UserID = i.UserID
  WHERE Date BETWEEN _begin AND _end
  AND i.UserID IS NOT NULL
),

newUsers AS (
  SELECT DISTINCT UserID
  FROM users
  WHERE DATE_DIFF(_end, installDate, DAY) <= 30
),

retainedUsers AS (
  SELECT DISTINCT UserID
  FROM users
  WHERE UserID NOT IN (SELECT UserID FROM newUsers)
    AND UserID IN (SELECT UserID FROM previouslyActive)
),

resurrectedUsers AS (
  SELECT DISTINCT UserID
  FROM users
  WHERE UserID NOT IN (SELECT UserID FROM newUsers)
    AND UserID NOT IN (SELECT UserID FROM retainedUsers)
),

userCategory AS (
  SELECT *,
         users.UserID AS user_id,
         CASE WHEN newUsers.UserID IS NOT NULL THEN 'New'
              WHEN retainedUsers.UserID IS NOT NULL THEN 'Retained'
              WHEN resurrectedUsers.UserID IS NOT NULL THEN 'Resurrected' END AS category
  FROM users
  LEFT JOIN newUsers ON users.UserID = newUsers.UserID
  LEFT JOIN retainedUsers ON users.UserID = retainedUsers.UserID
  LEFT JOIN resurrectedUsers ON users.UserID = resurrectedUsers.UserID
),

events AS (
  SELECT user_id,
         event_name,
         (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_number') as session_number
  FROM `erudite-idea-777.analytics_151921982.events_*`
  WHERE _TABLE_SUFFIX BETWEEN _begin_str AND _end_str
    AND user_id IN (SELECT UserID FROM users)
    AND event_name IN ('SolutionShow', 'SolutionButtonClick')
),

event_counts AS (
  SELECT user_id,
         event_name,
         COUNT(event_name) AS event_count,
         COUNT(DISTINCT(session_number)) as count_sessions
  FROM events
  GROUP BY user_id, event_name
),

return AS (
  SELECT userCategory.user_id AS UserID,
        userCategory.category AS Category,
        userCategory.country AS Country,
        MAX(event_counts.count_sessions) AS NumOfSession,
        MAX(CASE WHEN event_counts.event_name = 'SolutionShow' THEN event_counts.event_count END) AS SolutionShow,
        MAX(CASE WHEN event_counts.event_name = 'SolutionButtonClick' THEN event_counts.event_count END) AS SolutionButtonClick
  FROM userCategory
  LEFT JOIN event_counts ON userCategory.user_id = event_counts.user_id
  GROUP BY userCategory.user_id, userCategory.category, userCategory.country
)

SELECT UserID,
       Category,
       Country,
       IFNULL(NumOfSession, 0) AS NumOfSession,
       IFNULL(SolutionShow, 0) AS SolutionShow,
       IFNULL(SolutionButtonClick, 0) AS SolutionButtonClick
FROM return