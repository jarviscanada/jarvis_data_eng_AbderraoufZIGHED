i###### Table Setup (DDL)
-- Create schema
CREATE SCHEMA IF NOT EXISTS cd;

-- Members table
CREATE TABLE cd.members (
    memid INTEGER PRIMARY KEY,
    surname VARCHAR(200),
    firstname VARCHAR(200),
    address VARCHAR(300),
    zipcode INTEGER,
    telephone VARCHAR(20),
    recommendedby INTEGER,
    joindate TIMESTAMP,

    CONSTRAINT fk_recommendedby
        FOREIGN KEY (recommendedby)
        REFERENCES cd.members(memid)
);

-- Facilities table
CREATE TABLE cd.facilities (
    facid INTEGER PRIMARY KEY,
    name VARCHAR(100),
    membercost NUMERIC,
    guestcost NUMERIC,
    initialoutlay NUMERIC,
    monthlymaintenance NUMERIC
);

-- Bookings table
CREATE TABLE cd.bookings (
    bookid INTEGER PRIMARY KEY,
    facid INTEGER,
    memid INTEGER,
    starttime TIMESTAMP,
    slots INTEGER,

    CONSTRAINT fk_facility
        FOREIGN KEY (facid)
        REFERENCES cd.facilities(facid),

    CONSTRAINT fk_member
        FOREIGN KEY (memid)
        REFERENCES cd.members(memid)
);
###### Question 1: Show all members 

```sql
SELECT *
FROM cd.members
```

###### Question 2: Lorem ipsum...

```sql
SELECT blah blah 
```

