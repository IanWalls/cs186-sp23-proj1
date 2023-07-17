-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;
DROP VIEW IF EXISTS CALIFORNIA;
DROP VIEW IF EXISTS lslg;
DROP VIEW IF EXISTS allstarSelect;

-- Question 0
CREATE VIEW q0(era)
AS
  SELECT MAX(era)
  FROM pitching -- replace this line
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE people.weight > 300 -- replace this line
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE people.namefirst REGEXP '.*\s.*'
  ORDER BY people.namefirst ASC, people.namelast ASC
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), COUNT(*)
  FROM people
  GROUP BY birthyear -- replace this line
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), COUNT(*)
  FROM people
  GROUP BY birthyear
  HAVING AVG(height) > 70
  ORDER BY birthyear ASC -- replace this line
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT namefirst, namelast, playerID, yearID
  FROM people P NATURAL JOIN HallofFame H
  WHERE H.inducted = 'Y'
  ORDER BY yearID DESC, playerID ASC
    -- replace this line
;

-- Question 2ii
CREATE VIEW CALIFORNIA(playerid, schoolid)
AS
  SELECT c.playerid, s.schoolID
  FROM collegeplaying c INNER JOIN schools s
  ON c.schoolID = s.schoolID
  WHERE s.schoolState = 'CA'
;

CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT namefirst, namelast, q.playerid, C.schoolid, yearID
  FROM q2i q INNER JOIN CALIFORNIA C
  ON q.playerid = C.playerID
  ORDER BY yearID DESC, schoolID ASC, q.playerid ASC
   -- replace this line
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT q.playerid, q.namefirst, q.namelast, c.schoolID
  FROM q2i q LEFT JOIN collegeplaying c
  ON q.playerid = c.playerid
  ORDER BY q.playerid DESC, c.schoolID ASC -- replace this line
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT p.playerID, p.namefirst, p.namelast, yearID, (1.0*(B.H + B.H2B + B.H3B*2 + B.HR *3))/B.AB AS slg -- replace this line
  FROM people p INNER JOIN batting B
  ON p.playerID = b.playerID
  WHERE B.AB > 50
  ORDER BY slg DESC, yearID ASC, p.playerID ASC
  LIMIT 10
;

-- Question 3ii
CREATE VIEW lslg(playerid, lslg)
AS
  SELECT playerID, (1.0 * (SUM(H) + SUM(H2B) + 2*SUM(H3B) + 3*SUM(HR))) / SUM(AB) as lslg
  FROM batting B
  GROUP BY playerID
  HAVING SUM(AB) > 50
;

CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT p.playerID, namefirst, namelast, l.lslg 
  FROM people p INNER JOIN lslg l
  ON p.playerID = l.playerid
  ORDER BY l.lslg DESC, p.playerID ASC-- replace this line
  LIMIT 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  SELECT namefirst, namelast, l.lslg
  FROM people p INNER JOIN lslg l
  ON p.playerID = l.playerid
  WHERE l.lslg >
    (
      SELECT l1.lslg
      FROM lslg l1
      WHERE l1.playerid = 'mayswi01'
    ) -- replace this line
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT yearid, MIN(salary), MAX(salary), AVG(salary)
  FROM salaries
  GROUP BY yearid 
  ORDER BY yearid ASC -- replace this line
;

-- Question 4ii
-- Helper table for 4ii
DROP TABLE IF EXISTS binids;
CREATE TABLE binids(binid);
INSERT INTO binids VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9)
;

DROP VIEW IF EXISTS bins_statistics;
CREATE VIEW bins_statistics(binstart, binend, width)
AS 
  SELECT MIN(salary), MAX(salary), CAST (((MAX(salary) - MIN(salary))/10) AS INT)
  FROM salaries
;

DROP VIEW IF EXISTS binsgetid;
CREATE VIEW binsgetid(binid, binstart, width)
AS
  SELECT CAST((salary/width) AS INT), binstart, width
  FROM salaries, bins_statistics
  WHERE yearid = 2016
;

CREATE VIEW q4ii(binid, low, high, count)
AS
  SELECT binid, 507500.0+3249250*binid, 3756750.0+3249250*binid, COUNT(*)
  from binids, salaries
  where (salary between 507500.0+3249250*binid and 3756750.0 + 3249250*binid)and yearID='2016'
  group by binid -- replace this line
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  SELECT q2.yearid, q2.min - q1.min as mindiff, q2.max-q1.max as maxdiff, q2.avg - q1.avg as avgdiff
  FROM q4i q1 JOIN q4i q2 ON q1.yearid = q2.yearid-1
  WHERE q2.yearid > 1985
  ORDER BY q2.yearid
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  SELECT p.playerID, p.namefirst, p.namelast, s.salary, s.yearid
  FROM people p NATURAL JOIN salaries s
  WHERE (s.yearid = 2000 OR s.yearid = 2001) AND 
    s.salary IN
    (
      SELECT max 
      FROM q4i
      WHERE (q4i.yearid = 2000 OR q4i.yearid = 2001) AND q4i.yearid = s.yearid
    )  
;
-- Question 4v
CREATE VIEW allstarSelect(playerid, teamid) AS
  SELECT playerID, teamID
  FROM allstarfull
  WHERE yearID = 2016
;

CREATE VIEW q4v(team, diffAvg) AS
  SELECT a.teamid, MAX(s.salary) - MIN(s.salary)
  FROM allstarSelect a JOIN salaries s ON a.playerid = s.playerid
  WHERE s.yearid = 2016
  GROUP BY a.teamid -- replace this line
;

