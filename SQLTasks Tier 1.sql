/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to 
setup your local SQLite connection in PART 2 of the case study. 

The questions in the case study are exactly the same as with Tier 2. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

/*A1
SELECT membercost
FROM `Facilities`
WHERE membercost <>0

/* Q2: How many facilities do not charge a fee to members? */

/*A2
SELECT COUNT( membercost )
FROM Facilities
WHERE membercost <>0


/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */


/*A3:
SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost <> 0 
AND membercost < 0.2*monthlymaintenance


/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

/*A4
SELECT *
FROM Facilities
WHERE facid
IN ( 1, 5 )

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

/*A5
SELECT name, monthlymaintenance, IF(monthlymaintenance>100,'expensive','cheap') as 'category'
FROM Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

/* A6 
-- Signed up members in the last day
SELECT m.firstname, m.surname, t.starttime
FROM Members AS m
INNER JOIN ( SELECT b.starttime, b.memid
FROM Bookings AS b, (SELECT MAX( starttime ) AS st
FROM Bookings) AS mx
WHERE YEAR( b.starttime ) >= YEAR( mx.st )
AND MONTH( b.starttime ) >= MONTH( mx.st )
AND DAY( b.starttime ) >= DAY( mx.st )
) AS t 
ON m.memid = t.memid
WHERE m.firstname NOT LIKE '%GUEST%'
ORDER BY t.starttime DESC;
*/

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */


/* A7
SELECT DISTINCT concat(m.firstname,' ',m.surname) AS Member_Name, f.name AS Facility
FROM Bookings as b
INNER JOIN Members as m
USING(memid)
INNER JOIN Facilities as f
USING (facid)
WHERE f.name IN (SELECT name FROM Facilities WHERE name LIKE '%Tennis Court%')
AND m.firstname<>'GUEST'
ORDER BY Member_Name
*/


/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

/* A8:
SELECT concat(m.firstname,' ',m.surname), f.name, IF(surname = 'GUEST', f.guestcost*b.slots, f.membercost*b.slots) AS Cost
FROM Bookings as b
LEFT JOIN Members as m
On m.memid = b.memid
LEFT JOIN Facilities as f
ON b.facid = f.facid
WHERE DATE(starttime)='2012-09-14'
AND (IF(surname = 'GUEST', f.guestcost*b.slots>30, f.membercost*b.slots>30))
ORDER BY Cost DESC;
*/

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

/*
SELECT concat(m.firstname,' ',m.surname), f.name, IF(surname = 'GUEST', f.guestcost*b.slots, f.membercost*b.slots) AS Cost
FROM (SELECT facid, memid, slots, starttime FROM Bookings WHERE DATE(starttime)='2012-09-14') as b
LEFT JOIN Members as m
On m.memid = b.memid
LEFT JOIN Facilities as f
ON b.facid = f.facid
WHERE (IF(surname = 'GUEST', f.guestcost*b.slots>30, f.membercost*b.slots>30))
ORDER BY Cost DESC;
*/


/* PART 2: SQLite
/* We now want you to jump over to a local instance of the database on your machine. 

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output.
 
QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

/*A10
SELECT name, SUM(Total_Cost) AS Revenue
FROM (SELECT f.facid,f.name, IF(b.memid = 0, f.guestcost*b.slots, f.membercost*b.slots) AS Total_Cost
     FROM Bookings as b
     INNER JOIN Facilities as f
     ON f.facid = b.facid) AS x
GROUP BY facid
HAVING SUM(Total_Cost)<1000
ORDER BY Revenue;
*/

/*A10 When the IF statement is not accepted:
SELECT name, SUM(Total_Cost) AS Revenue
     FROM (SELECT f.facid,f.name, (CASE WHEN b.memid = 0 THEN f.guestcost*b.slots ELSE f.membercost*b.slots END) AS Total_Cost
     FROM Bookings as b
     INNER JOIN Facilities as f
     ON f.facid = b.facid) AS x
GROUP BY facid
HAVING SUM(Total_Cost)<1000
ORDER BY Revenue;
*/

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

/*A11
SELECT concat(m.firstname,' ', m.surname) AS Member, concat(n.firstname,' ', n.surname) AS Recommended_by
FROM Members AS m
INNER JOIN Members AS n
ON m.recommendedby = n.memid
WHERE m.memid<>0
ORDER BY m.firstname, m.surname
*/

SQLITE DOES NOT SUPPORT concat STATEMENT
SELECT (m.firstname||' '|| m.surname) AS Member, (n.firstname||' '||n.surname) AS Recommended_by
FROM Members AS m
INNER JOIN Members AS n
ON m.recommendedby = n.memid
WHERE m.memid<>0
ORDER BY m.firstname, m.surname
*/

/* Q12: Find the facilities with their usage by member, but not guests */

/*A12
SELECT name, M_Name,SUM(slots) AS num_usage
FROM (SELECT f.name, b.slots,concat(firstname,' ',surname) AS M_Name
     FROM Facilities as f
     LEFT JOIN Bookings as b
     ON f.facid=b.facid
     LEFT JOIN Members as m
     ON b.memid = m.memid
     WHERE b.memid<>0) AS x
GROUP BY name, M_Name; 

FOR SQLITE
     SELECT name, M_Name,SUM(slots) AS num_usage
     FROM (SELECT f.name, b.slots,(firstname||' '||surname) AS M_Name
         FROM Facilities as f
         LEFT JOIN Bookings as b
         ON f.facid=b.facid
         LEFT JOIN Members as m
         ON b.memid = m.memid
         WHERE b.memid<>0) AS x
     GROUP BY name, M_Name; 
*/

/* Q13: Find the facilities usage by month, but not guests */

/*A13
SELECT fac_name, year, month, SUM(slots) AS us
FROM (SELECT f.name AS fac_name, YEAR(b.starttime) AS year, MONTH(b.starttime) AS month, b.slots
     FROM Bookings AS b
     LEFT JOIN Facilities as f
     ON f.facid = b.facid) AS x
GROUP BY fac_name, month
ORDER BY month, fac_name;

FOR SQLITE
     SELECT fac_name, year, month, SUM(slots) AS us
         FROM (SELECT f.name AS fac_name, strftime('%Y',b.starttime) AS year,strftime('%m',b.starttime) AS month, b.slots
         FROM Bookings AS b
         LEFT JOIN Facilities as f
         ON f.facid = b.facid) AS x
     GROUP BY fac_name, month
     ORDER BY month, fac_name;
*/