# Introduction

This project is created to simulate a real-world SQL development environment and strengthen practical database skills using **PostgreSQL**. It focuses on designing, defining, and manipulating relational data through hands-on exercises that cover essential SQL topics.

A **PostgreSQL server** is set up in a **Docker container**, and **pgAdmin** is used to connect and manage the database visually. The environment is initialized using the `clubdata.sql` file, which defines the database structure and loads realistic sample data for a club membership system.
Executing this file creates a new database (`exercises`), sets up the `cd` schema, and populates it with the following tables:

- **members**: stores information about members and their relationships

- **facilities**: contains available facilities and related costs

- **bookings**: records facility reservations made by members

The project demonstrates end-to-end SQL concepts, including:

- **Data modeling** and defining relationships using **DDL** statements (CREATE, ALTER, etc.)

- **Data manipulation** with **DML** statements (INSERT, UPDATE, DELETE)

- **CRUD operations, JOINs, aggregations, string functions, subqueries**, and **window functions**

- Applying **primary/foreign key constraints**

- Exploring **query optimization** techniques such as **indexing (B-tree indexes)** for performance improvement

Each question documented along with its corresponding SQL solution for clarity and future reference.

# SQL Queries

###### Table Setup (DDL)

```sql
CREATE TABLE cd.members (
    memid INTEGER NOT NULL,
    surname VARCHAR(200) NOT NULL,
    firstname VARCHAR(200) NOT NULL,
    address VARCHAR(300) NOT NULL,
    zipcode INTEGER NOT NULL,
    telephone VARCHAR(20) NOT NULL,
    recommendedby INTEGER,
    joindate TIMESTAMP NOT NULL,
    CONSTRAINT members_pk PRIMARY KEY (memid),
    CONSTRAINT fk_members_recommendedby FOREIGN KEY (recommendedby) 
        REFERENCES cd.members(memid) ON DELETE SET NULL
);

CREATE TABLE cd.facilities (
    facid INTEGER NOT NULL,
    name VARCHAR(100) NOT NULL,
    membercost NUMERIC NOT NULL,
    guestcost NUMERIC NOT NULL,
    initialoutlay NUMERIC NOT NULL,
    monthlymaintenance NUMERIC NOT NULL,
    CONSTRAINT facilities_pk PRIMARY KEY (facid)
);

CREATE TABLE cd.bookings (
    bookid INTEGER NOT NULL,
    facid INTEGER NOT NULL,
    memid INTEGER NOT NULL,
    starttime TIMESTAMP NOT NULL,
    slots INTEGER NOT NULL,
    CONSTRAINT bookings_pk PRIMARY KEY (bookid),
    CONSTRAINT fk_bookings_facid FOREIGN KEY (facid) 
        REFERENCES cd.facilities(facid),
    CONSTRAINT fk_bookings_memid FOREIGN KEY (memid) 
        REFERENCES cd.members(memid)
);
```
###### Question 1: The club is adding a new facility - a spa. We need to add it into the facilities table.

```sql
INSERT INTO cd.facilities 
	(facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
VALUES (9, 'Spa', 20, 30, 100000, 800);
```

###### Question 2: We want to automatically generate the value for the next facid, rather than specifying it as a constant.

```sql
INSERT INTO cd.facilities
    (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
SELECT (SELECT MAX(facid) FROM cd.facilities)+1, 'Spa', 20, 30, 100000, 800; 
```

###### Question 3: We made a mistake when entering the data for the second tennis court. The initial outlay was 10000 rather than 8000: you need to alter the data to fix the error.

```sql
UPDATE cd.facilities 
SET initialoutlay = 10000 
WHERE facid = 1;
```

###### Question 4: We want to alter the price of the second tennis court so that it costs 10% more than the first one. Try to do this without using constant values for the prices, so that we can reuse the statement if we want to.

```sql
UPDATE cd.facilities
SET 
	membercost = (SELECT membercost * 1.1 FROM cd.facilities WHERE facid = 0),
	guestcost = (SELECT guestcost * 1.1 FROM cd.facilities WHERE facid = 0)
WHERE facid = 1;
```

###### Question 5: As part of a clearout of our database, we want to delete all bookings from the cd.bookings table. How can we accomplish this?

```sql
DELETE FROM cd.bookings;
```

###### Question 6: We want to remove member 37, who has never made a booking, from our database. How can we achieve that?

```sql
DELETE FROM cd.members WHERE memid = 37;
```

###### Question 7: How can you produce a list of facilities that charge a fee to members, and that fee is less than 1/50th of the monthly maintenance cost? Return the facid, facility name, member cost, and monthly maintenance of the facilities in question.

```sql
SELECT facid, name, membercost, monthlymaintenance
FROM cd.facilities
WHERE membercost > 0 AND membercost < (monthlymaintenance/50);
```

###### Question 8: How can you produce a list of all facilities with the word 'Tennis' in their name?

```sql
SELECT *
FROM cd.facilities
WHERE name LIKE '%Tennis%';
```

###### Question 9: How can you retrieve the details of facilities with ID 1 and 5? Try to do it without using the OR operator.

```sql
SELECT *
FROM cd.facilities
WHERE facid IN (1, 5);
```

###### Question 10: How can you produce a list of members who joined after the start of September 2012? Return the memid, surname, firstname, and joindate of the members in question.

```sql
SELECT memid, surname, firstname, joindate
FROM cd.members
WHERE joindate >= '2012-09-01';
```

###### Question 11: You, for some reason, want a combined list of all surnames and all facility names. Yes, this is a contrived example :-). Produce that list!

```sql
SELECT surname FROM cd.members
UNION
SELECT name FROM cd.facilities; 
```

###### Question 12: How can you produce a list of the start times for bookings by members named 'David Farrell'?

```sql
SELECT b.starttime
FROM cd.bookings b
JOIN cd.members m ON b.memid = m.memid
WHERE m.firstname = 'David' AND m.surname = 'Farrell';
```

###### Question 13: How can you produce a list of the start times for bookings for tennis courts, for the date '2012-09-21'? Return a list of start time and facility name pairings, ordered by the time.

```sql
SELECT b.starttime, f.name
FROM cd.bookings b
JOIN cd.facilities f ON b.facid = f.facid
WHERE f.name LIKE '%Tennis Court%' 
	AND b.starttime >= '2012-09-21' 
	AND b.starttime < '2012-09-22'
ORDER BY b.starttime;
```

###### Question 14: How can you output a list of all members, including the individual who recommended them (if any)? Ensure that results are ordered by (surname, firstname).

```sql
SELECT m.firstname, m.surname, r.firstname AS rec_fname, r.surname AS rec_sname
FROM cd.members m
LEFT JOIN cd.members r ON m.recommendedby = r.memid
ORDER BY m.surname, m.firstname;
```

###### Question 15: How can you output a list of all members who have recommended another member? Ensure that there are no duplicates in the list, and that results are ordered by (surname, firstname).

```sql
SELECT DISTINCT r.firstname, r.surname
FROM cd.members m
JOIN cd.members r ON m.recommendedby = r.memid
ORDER BY r.surname, r.firstname;
```

###### Question 16: How can you output a list of all members, including the individual who recommended them (if any), without using any joins? Ensure that there are no duplicates in the list, and that each firstname + surname pairing is formatted as a column and ordered.

```sql
SELECT DISTINCT m.firstname || ' ' || m.surname AS member, 
	(SELECT r.firstname || ' ' || r.surname AS recommender 
	 FROM cd.members r 
	 WHERE m.recommendedby = r.memid)
FROM cd.members m
ORDER BY member;
```

###### Question 17: Produce a count of the number of recommendations each member has made. Order by member ID.

```sql
SELECT recommendedby, COUNT(*)
FROM cd.members
WHERE recommendedby IS NOT NULL
GROUP BY recommendedby
ORDER BY recommendedby;
```

###### Question 18: Produce a list of the total number of slots booked per facility. For now, just produce an output table consisting of facility id and slots, sorted by facility id.

```sql
SELECT facid, SUM(slots) AS "Total Slots"
FROM cd.bookings
GROUP BY facid
ORDER BY facid;
```

###### Question 19: Produce a list of the total number of slots booked per facility in the month of September 2012. Produce an output table consisting of facility id and slots, sorted by the number of slots.

```sql
SELECT facid, SUM(slots) AS "Total Slots"
FROM cd.bookings
WHERE starttime >= '2012-09-01' AND starttime < '2012-10-01'
GROUP BY facid
ORDER BY "Total Slots";
```

###### Question 20: Produce a list of the total number of slots booked per facility per month in the year of 2012. Produce an output table consisting of facility id and slots, sorted by the id and month.

```sql
SELECT facid, EXTRACT(month FROM starttime) AS "month", SUM(slots) AS "Total Slots"
FROM cd.bookings
WHERE starttime >= '2012-01-01' AND starttime < '2013-01-01'
GROUP BY facid, month
ORDER BY facid, month;
```

###### Question 21: Find the total number of members (including guests) who have made at least one booking.

```sql
SELECT COUNT(DISTINCT memid)
FROM cd.bookings;
```

###### Question 22: Produce a list of each member name, id, and their first booking after September 1st 2012. Order by member ID.

```sql
SELECT m.surname, m.firstname, m.memid, MIN(b.starttime)
FROM cd.members m
JOIN cd.bookings b ON m.memid = b.memid
WHERE b.starttime >= '2012-09-01'
GROUP BY m.memid, m.surname, m.firstname
ORDER BY m.memid;
```

###### Question 23: Produce a list of member names, with each row containing the total member count. Order by join date, and include guest members.

```sql
SELECT (SELECT COUNT(memid) FROM cd.members), firstname, surname
FROM cd.members;
```

###### Question 24: Produce a monotonically increasing numbered list of members (including guests), ordered by their date of joining. Remember that member IDs are not guaranteed to be sequential.

```sql
SELECT ROW_NUMBER() OVER(ORDER BY joindate) AS "row_number", firstname, surname
FROM cd.members
ORDER BY joindate;
```

###### Question 25: Output the facility id that has the highest number of slots booked. Ensure that in the event of a tie, all tieing results get output.

```sql
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
```

###### Question 26: Output the names of all members, formatted as 'Surname, Firstname'

```sql
SELECT surname || ', ' || firstname AS name
FROM cd.members;
```

###### Question 27: You've noticed that the club's member table has telephone numbers with very inconsistent formatting. You'd like to find all the telephone numbers that contain parentheses, returning the member ID and telephone number sorted by member ID.

```sql
SELECT memid, telephone
FROM cd.members
WHERE telephone SIMILAR TO '%[()]%';
--WHERE telephone LIKE '%(%' OR telephone LIKE '%)%';
```

###### Question 28: You'd like to produce a count of how many members you have whose surname starts with each letter of the alphabet. Sort by the letter, and don't worry about printing out a letter if the count is 0.

```sql
SELECT SUBSTR(surname, 1, 1) AS letter, COUNT(*) as "count"
FROM cd.members
GROUP BY letter
ORDER BY letter;
```

