-- ============================================================
-- UBER SUPPLY DEMAND GAP - SQL ANALYSIS
-- Project   : Uber Supply Demand Gap EDA
-- Author    : Nakshatra Devkar
-- Tool      : SQLite / DB Browser for SQLite
-- Dataset   : Uber Request Data
-- ============================================================

CREATE DATABASE Uber;

-- ============================================================
-- SECTION 1: DATA INTEGRITY CHECK
-- ============================================================
 
-- 1.1 Total record count
SELECT COUNT(*) AS TotalRows FROM uber_requests;

-- 1.2 Count of each status type
SELECT Status, COUNT(*) AS Count,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM uber_requests), 2) AS Percentage
FROM uber_requests
GROUP BY Status
ORDER BY Count DESC;

-- 1.3 Count by pickup point
SELECT "Pickup point", COUNT(*) AS Count,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM uber_requests), 2) AS Percentage
FROM uber_requests
GROUP BY "Pickup point";

-- 1.4 Missing values check
SELECT
    SUM(CASE WHEN "Driver id" IS NULL OR "Driver id" = '' THEN 1 ELSE 0 END) AS Missing_Driver_Id,
    SUM(CASE WHEN "Drop timestamp" IS NULL OR "Drop timestamp" = '' THEN 1 ELSE 0 END) AS Missing_Drop_Timestamp,
    SUM(CASE WHEN "Request timestamp" IS NULL THEN 1 ELSE 0 END) AS Missing_Request_Timestamp,
    SUM(CASE WHEN "Pickup point" IS NULL THEN 1 ELSE 0 END) AS Missing_Pickup_Point,
    SUM(CASE WHEN Status IS NULL THEN 1 ELSE 0 END) AS Missing_Status
FROM uber_requests;

-- 1.5 Duplicate check
SELECT "Request id", COUNT(*) AS DuplicateCount
FROM uber_requests
GROUP BY "Request id"
HAVING COUNT(*) > 1;


-- ============================================================
-- SECTION 2: TIME SLOT ANALYSIS
-- ============================================================
 
-- 2.1 Create a view with time slot feature
-- (Run this once to create a reusable view)
CREATE VIEW uber_with_timeslot AS
SELECT 
    *,
    
    -- Extract hour (MySQL way)
    HOUR(`Request timestamp`) AS Hour,

    -- Time slot classification
    CASE
        WHEN HOUR(`Request timestamp`) BETWEEN 0 AND 4 THEN 'Late Night'
        WHEN HOUR(`Request timestamp`) BETWEEN 5 AND 8 THEN 'Early Morning'
        WHEN HOUR(`Request timestamp`) BETWEEN 9 AND 11 THEN 'Morning'
        WHEN HOUR(`Request timestamp`) BETWEEN 12 AND 16 THEN 'Afternoon'
        WHEN HOUR(`Request timestamp`) BETWEEN 17 AND 20 THEN 'Evening'
        ELSE 'Night'
    END AS TimeSlot,

    -- Gap flag
    CASE 
        WHEN Status <> 'Trip Completed' THEN 1 
        ELSE 0 
    END AS IsGap

FROM uber_requests;

SELECT 
    TimeSlot,
    COUNT(*) AS TotalRequests,
    ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM uber_requests), 1) AS Pct_of_Total
FROM uber_with_timeslot
GROUP BY TimeSlot
ORDER BY TotalRequests DESC;

-- 2.3 Supply-Demand Gap count by time slot
SELECT TimeSlot,
       COUNT(*) AS UnfulfilledRequests,
       ROUND(100.0 * COUNT(*) /
           (SELECT COUNT(*) FROM uber_with_timeslot u2
            WHERE u2.TimeSlot = u.TimeSlot), 1) AS GapRate_Pct
FROM uber_with_timeslot u
WHERE IsGap = 1
GROUP BY TimeSlot
ORDER BY UnfulfilledRequests DESC;
 
-- 2.4 Status breakdown by time slot
SELECT TimeSlot, Status, COUNT(*) AS Count
FROM uber_with_timeslot
GROUP BY TimeSlot, Status
ORDER BY TimeSlot, Count DESC;


-- ============================================================
-- SECTION 3: PICKUP POINT ANALYSIS
-- ============================================================
 
-- 3.1 Status breakdown by pickup point
SELECT "Pickup point", Status,
       COUNT(*) AS Count,
       ROUND(100.0 * COUNT(*) /
           SUM(COUNT(*)) OVER (PARTITION BY "Pickup point"), 1) AS Pct_Within_Pickup
FROM uber_requests
GROUP BY "Pickup point", Status
ORDER BY "Pickup point", Count DESC;

-- 3.2 Gap rate by pickup point
SELECT "Pickup point",
       COUNT(*) AS TotalRequests,
       SUM(CASE WHEN Status != 'Trip Completed' THEN 1 ELSE 0 END) AS UnfulfilledRequests,
       ROUND(100.0 * SUM(CASE WHEN Status != 'Trip Completed' THEN 1 ELSE 0 END)
             / COUNT(*), 1) AS GapRate_Pct
FROM uber_requests
GROUP BY "Pickup point";

-- 3.3 Cancellations only by pickup point
SELECT "Pickup point",
       COUNT(*) AS Cancellations
FROM uber_requests
WHERE Status = 'Cancelled'
GROUP BY "Pickup point"
ORDER BY Cancellations DESC;

-- 3.4 No Cars Available by pickup point
SELECT "Pickup point",
       COUNT(*) AS NoCarsAvailable
FROM uber_requests
WHERE Status = 'No Cars Available'
GROUP BY "Pickup point"
ORDER BY NoCarsAvailable DESC;

-- ============================================================
-- SECTION 4: COMBINED PICKUP POINT × TIME SLOT ANALYSIS
-- ============================================================
 
-- 4.1 Request volume — Pickup Point × Time Slot
SELECT "Pickup point", TimeSlot, COUNT(*) AS Requests
FROM uber_with_timeslot
GROUP BY "Pickup point", TimeSlot
ORDER BY "Pickup point", Requests DESC;

-- 4.2 Gap breakdown — Pickup Point × Time Slot × Status
SELECT "Pickup point", TimeSlot, Status, COUNT(*) AS Count
FROM uber_with_timeslot
WHERE IsGap = 1
GROUP BY "Pickup point", TimeSlot, Status
ORDER BY "Pickup point", Count DESC;

-- 4.3 Completion rate — Pickup Point × Time Slot
SELECT "Pickup point", TimeSlot,
       COUNT(*) AS TotalRequests,
       SUM(CASE WHEN Status = 'Trip Completed' THEN 1 ELSE 0 END) AS Completed,
       ROUND(100.0 * SUM(CASE WHEN Status = 'Trip Completed' THEN 1 ELSE 0 END)
             / COUNT(*), 1) AS CompletionRate_Pct
FROM uber_with_timeslot
GROUP BY "Pickup point", TimeSlot
ORDER BY "Pickup point", CompletionRate_Pct DESC;

-- 4.4 Worst combinations (lowest completion rate)
SELECT "Pickup point", TimeSlot,
       ROUND(100.0 * SUM(CASE WHEN Status = 'Trip Completed' THEN 1 ELSE 0 END)
             / COUNT(*), 1) AS CompletionRate_Pct,
       COUNT(*) AS TotalRequests
FROM uber_with_timeslot
GROUP BY "Pickup point", TimeSlot
ORDER BY CompletionRate_Pct ASC
LIMIT 10;

-- ============================================================
-- SECTION 5: HOURLY ANALYSIS
-- ============================================================
 
-- 5.1 Request volume by hour
SELECT Hour,
       COUNT(*) AS TotalRequests,
       SUM(CASE WHEN Status = 'Trip Completed'     THEN 1 ELSE 0 END) AS Completed,
       SUM(CASE WHEN Status = 'Cancelled'          THEN 1 ELSE 0 END) AS Cancelled,
       SUM(CASE WHEN Status = 'No Cars Available'  THEN 1 ELSE 0 END) AS NoCars,
       ROUND(100.0 * SUM(CASE WHEN Status != 'Trip Completed' THEN 1 ELSE 0 END)
             / COUNT(*), 1) AS GapRate_Pct
FROM uber_with_timeslot
GROUP BY Hour
ORDER BY Hour;

-- 5.2 Peak cancellation hours
SELECT Hour,
       COUNT(*) AS Cancellations,
       ROUND(100.0 * COUNT(*) /
           (SELECT COUNT(*) FROM uber_with_timeslot u2 WHERE u2.Hour = u.Hour), 1) AS CancelRate_Pct
FROM uber_with_timeslot u
WHERE Status = 'Cancelled'
GROUP BY Hour
ORDER BY CancelRate_Pct DESC
LIMIT 10;

-- 5.3 Peak No Cars Available hours
SELECT Hour,
       COUNT(*) AS NoCarsCount,
       ROUND(100.0 * COUNT(*) /
           (SELECT COUNT(*) FROM uber_with_timeslot u2 WHERE u2.Hour = u.Hour), 1) AS NoCarsRate_Pct
FROM uber_with_timeslot u
WHERE Status = 'No Cars Available'
GROUP BY Hour
ORDER BY NoCarsRate_Pct DESC
LIMIT 10;

-- 5.4 Hourly demand — Airport vs City
SELECT Hour, "Pickup point", COUNT(*) AS Requests
FROM uber_with_timeslot
GROUP BY Hour, "Pickup point"
ORDER BY Hour, "Pickup point";

-- ============================================================
-- SECTION 6: DRIVER ANALYSIS
-- ============================================================
 
-- 6.1 Top 15 most active drivers
SELECT "Driver id",
       COUNT(*) AS TripsHandled,
       SUM(CASE WHEN Status = 'Trip Completed' THEN 1 ELSE 0 END) AS Completed,
       SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) AS Cancelled,
       ROUND(100.0 * SUM(CASE WHEN Status = 'Trip Completed' THEN 1 ELSE 0 END)
             / COUNT(*), 1) AS CompletionRate_Pct
FROM uber_requests
WHERE "Driver id" IS NOT NULL AND "Driver id" != ''
GROUP BY "Driver id"
ORDER BY TripsHandled DESC
LIMIT 15;

-- 6.2 Drivers with highest cancellation rates (min 5 trips)
SELECT "Driver id",
       COUNT(*) AS TotalTrips,
       SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) AS Cancellations,
       ROUND(100.0 * SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END)
             / COUNT(*), 1) AS CancelRate_Pct
FROM uber_requests
WHERE "Driver id" IS NOT NULL AND "Driver id" != ''
GROUP BY "Driver id"
HAVING TotalTrips >= 5
ORDER BY CancelRate_Pct DESC
LIMIT 15;

-- 6.3 Number of requests with no driver assigned
SELECT Status, COUNT(*) AS Count
FROM uber_requests
WHERE "Driver id" IS NULL OR "Driver id" = ''
GROUP BY Status;

-- ============================================================
-- SECTION 7: SUMMARY INSIGHTS
-- ============================================================
 
-- 7.1 Overall summary statistics
SELECT
    COUNT(*) AS TotalRequests,
    SUM(CASE WHEN Status = 'Trip Completed'    THEN 1 ELSE 0 END) AS TripCompleted,
    SUM(CASE WHEN Status = 'No Cars Available' THEN 1 ELSE 0 END) AS NoCarsAvailable,
    SUM(CASE WHEN Status = 'Cancelled'         THEN 1 ELSE 0 END) AS Cancelled,
    ROUND(100.0 * SUM(CASE WHEN Status = 'Trip Completed' THEN 1 ELSE 0 END)
          / COUNT(*), 1) AS CompletionRate_Pct,
    ROUND(100.0 * SUM(CASE WHEN Status != 'Trip Completed' THEN 1 ELSE 0 END)
          / COUNT(*), 1) AS GapRate_Pct
FROM uber_requests;

-- 7.2 The single biggest problem: Airport + Night + No Cars
SELECT "Pickup point", TimeSlot, Status, COUNT(*) AS Count
FROM uber_with_timeslot
WHERE IsGap = 1
GROUP BY "Pickup point", TimeSlot, Status
ORDER BY Count DESC
LIMIT 10;
 
-- 7.3 Best performing time slot + pickup point
SELECT "Pickup point", TimeSlot,
       ROUND(100.0 * SUM(CASE WHEN Status = 'Trip Completed' THEN 1 ELSE 0 END)
             / COUNT(*), 1) AS CompletionRate_Pct
FROM uber_with_timeslot
GROUP BY "Pickup point", TimeSlot
ORDER BY CompletionRate_Pct DESC
LIMIT 5;
 
-- ============================================================
-- END OF SQL ANALYSIS
-- Project : Uber Supply Demand Gap EDA
-- Author  : Nakshatra Devkar
-- ============================================================