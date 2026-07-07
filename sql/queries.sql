--Q1
INSERT INTO cd.facilities
	(facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
VALUES (9, 'Spa', 20, 30, 100000, 800);

--Q2
INSERT INTO cd.facilities
    (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
SELECT (SELECT MAX(facid) FROM cd.facilities)+1, 'Spa', 20, 30, 100000, 800;

--Q3
UPDATE cd.facilities
SET initialoutlay = 10000
WHERE facid = 1;

--Q4
UPDATE cd.facilities
SET
	membercost = (SELECT membercost * 1.1 FROM cd.facilities WHERE facid = 0),
	guestcost = (SELECT guestcost * 1.1 FROM cd.facilities WHERE facid = 0)
WHERE facid = 1;

--Q5
DELETE FROM cd.bookings;

--Q6
DELETE FROM cd.members WHERE memid = 37;

--Q7
SELECT facid, name, membercost, monthlymaintenance
FROM cd.facilities
WHERE membercost > 0 AND membercost < (monthlymaintenance/50);

--Q8
SELECT *
FROM cd.facilities
WHERE name LIKE '%Tennis%';

--Q9
SELECT *
FROM cd.facilities
WHERE facid IN (1, 5);

--Q10
SELECT memid, surname, firstname, joindate
FROM cd.members
WHERE joindate >= '2012-09-01';

--Q11
SELECT surname FROM cd.members
UNION
SELECT name FROM cd.facilities;

--Q12
SELECT b.starttime
FROM cd.bookings b
JOIN cd.members m ON b.memid = m.memid
WHERE m.firstname = 'David' AND m.surname = 'Farrell';

--Q13
SELECT b.starttime, f.name
FROM cd.bookings b
JOIN cd.facilities f ON b.facid = f.facid
WHERE f.name LIKE '%Tennis Court%'
	AND b.starttime >= '2012-09-21'
	AND b.starttime < '2012-09-22'
ORDER BY b.starttime;

--Q14
SELECT m.firstname, m.surname, r.firstname AS rec_fname, r.surname AS rec_sname
FROM cd.members m
LEFT JOIN cd.members r ON m.recommendedby = r.memid
ORDER BY m.surname, m.firstname;

--Q15
SELECT DISTINCT r.firstname, r.surname
FROM cd.members m
JOIN cd.members r ON m.recommendedby = r.memid
ORDER BY r.surname, r.firstname;

--Q16
SELECT DISTINCT m.firstname || ' ' || m.surname AS member,
	(SELECT r.firstname || ' ' || r.surname AS recommender
	 FROM cd.members r
	 WHERE m.recommendedby = r.memid)
FROM cd.members m
ORDER BY member;

--Q17
SELECT recommendedby, COUNT(*)
FROM cd.members
WHERE recommendedby IS NOT NULL
GROUP BY recommendedby
ORDER BY recommendedby;

--Q18
SELECT facid, SUM(slots) AS "Total Slots"
FROM cd.bookings
GROUP BY facid
ORDER BY facid;

--Q19
SELECT facid, SUM(slots) AS "Total Slots"
FROM cd.bookings
WHERE starttime >= '2012-09-01' AND starttime < '2012-10-01'
GROUP BY facid
ORDER BY "Total Slots";

--Q20
SELECT facid, EXTRACT(month FROM starttime) AS "month", SUM(slots) AS "Total Slots"
FROM cd.bookings
WHERE starttime >= '2012-01-01' AND starttime < '2013-01-01'
GROUP BY facid, month
ORDER BY facid, month;

--Q21
SELECT COUNT(DISTINCT memid)
FROM cd.bookings;

--Q22
SELECT m.surname, m.firstname, m.memid, MIN(b.starttime)
FROM cd.members m
JOIN cd.bookings b ON m.memid = b.memid
WHERE b.starttime >= '2012-09-01'
GROUP BY m.memid, m.surname, m.firstname
ORDER BY m.memid;

--Q23
SELECT (SELECT COUNT(memid) FROM cd.members), firstname, surname
FROM cd.members;

--Q24
SELECT ROW_NUMBER() OVER(ORDER BY joindate) AS "row_number", firstname, surname
FROM cd.members
ORDER BY joindate;

--Q25
SELECT facid, SUM(slots) AS total
FROM cd.bookings
GROUP BY facid
HAVING SUM(slots) = (
  SELECT MAX(total_slots)
  FROM (
    SELECT SUM(slots) AS total_slots
    FROM cd.bookings
    GROUP BY facid
  ) AS sub
);

--Q26
SELECT surname || ', ' || firstname AS name
FROM cd.members;

--27
SELECT memid, telephone
FROM cd.members
WHERE telephone SIMILAR TO '%[()]%';
--WHERE telephone LIKE '%(%' OR telephone LIKE '%)%';

--28
SELECT SUBSTR(surname, 1, 1) AS letter, COUNT(*) as "count"
FROM cd.members
GROUP BY letter
ORDER BY letter;
