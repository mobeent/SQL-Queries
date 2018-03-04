    rem   CS 340 Programming Assignment 1
    rem   Mobeen Tariq
    rem   s17100047

--1
SELECT MAX(age)
FROM STUDENT S, ENROLLED E
WHERE S.major='CS' OR (S.sid=E.sid AND E.cnum = (SELECT C.CNUM
FROM FACULTY F, CLASS C
WHERE F.fid=C.fid AND F.fname='Prof. Brown'));

--2
SELECT cnum
FROM CLASS
WHERE room='115'
UNION
SELECT E.cnum
FROM ENROLLED E
GROUP BY E.cnum
HAVING COUNT(*)>=5;

--3
SELECT DISTINCT(S.sname)
FROM CLASS C1, CLASS C2, STUDENT S, ENROLLED E
WHERE S.sid=E.sid AND E.cnum=C1.cnum AND C1.meets_at=C2.meets_at AND C1.cnum!=C2.cnum;

--4
SELECT DISTINCT(F.fname)
FROM FACULTY F
WHERE NOT EXISTS ((SELECT C.room
	FROM CLASS C)
	MINUS
	(SELECT C1.room
	FROM CLASS C1
	WHERE C1.fid=F.fid));

--5
SELECT A.fname FROM (
SELECT F.fname, 
    COUNT(*) AS num
    FROM FACULTY F
    JOIN CLASS C ON F.fid=C.fid
    JOIN ENROLLED E  ON C.cnum = E.cnum
    JOIN STUDENT S ON S.sid=E.sid
GROUP BY F.fname
ORDER BY num DESC, F.fname DESC) A
WHERE A.num>8;

--6
SELECT S.slevel, AVG(S.age)
FROM STUDENT S
WHERE S.slevel != 'JR'
GROUP BY S.slevel;

--7
SELECT sname FROM (
SELECT S.sname, 
    COUNT(*) AS num
    FROM STUDENT S
    JOIN ENROLLED E  ON S.sid = E.sid
GROUP BY S.sname
ORDER BY num DESC, S.sname DESC)
WHERE ROWNUM<=1;

--8
SELECT DISTINCT(S.sname)
FROM STUDENT S
WHERE NOT EXISTS (SELECT 1
	FROM ENROLLED E
	WHERE S.sid=E.sid);

--9
SELECT S.age, S.slevel
FROM STUDENT S
GROUP BY S.age, S.slevel
HAVING S.slevel IN (SELECT S1.slevel
	FROM STUDENT S1
	WHERE S1.age=S.age
	GROUP BY S1.age, S1.slevel
	HAVING COUNT(*) >= ALL (SELECT COUNT(*)
		FROM STUDENT S2
		WHERE S1.age=S2.age
		GROUP BY S2.slevel, S2.age))
ORDER BY S.age;

--10
SELECT avgee-avgcs
FROM(
SELECT AVG(num) AS avgcs
FROM
(SELECT COUNT(*) AS num
    FROM FACULTY F
    JOIN CLASS C ON C.fid=F.fid
    JOIN ENROLLED E  ON E.cnum=C.cnum
    JOIN STUDENT S ON S.sid=E.sid
WHERE F.dept='CS'
ORDER BY num DESC, F.fname DESC)),
(SELECT AVG(num) AS avgee
FROM
(SELECT COUNT(*) AS num
    FROM FACULTY F
    JOIN CLASS C ON C.fid=F.fid
    JOIN ENROLLED E  ON E.cnum=C.cnum
    JOIN STUDENT S ON S.sid=E.sid
WHERE F.dept='EE'
GROUP BY F.fname, F.dept
ORDER BY num DESC, F.fname DESC));

--11
SELECT fname
FROM
(SELECT F1.fname, COUNT(*) AS enrolledstudents
    FROM FACULTY F1
    JOIN CLASS C1 ON C1.fid=F1.fid
    JOIN ENROLLED E1  ON E1.cnum=C1.cnum
    JOIN STUDENT S1 ON S1.sid=E1.sid
    GROUP BY F1.fname
), (SELECT AVG(num) AS averagestudents
FROM
(SELECT COUNT(*) AS num
    FROM FACULTY F
    JOIN CLASS C ON C.fid=F.fid
    JOIN ENROLLED E  ON E.cnum=C.cnum
    JOIN STUDENT S ON S.sid=E.sid
	WHERE F.dept='EE'
    GROUP BY F.fname))
WHERE enrolledstudents>averagestudents;

--12
SELECT F.fname
FROM FACULTY F
WHERE NOT EXISTS(
SELECT DISTINCT(F2.fname)
FROM CLASS C1, CLASS C2, FACULTY F1, FACULTY F2
WHERE F1.fname='Prof. Wasfi' AND F1.fname!=F2.fname AND F1.dept=F2.dept AND C1.fid=F1.fid AND C2.fid=F2.fid AND C1.fid!=C2.fid AND C1.meets_at=C2.meets_at);

--13
SELECT DISTINCT(S.sname)
FROM STUDENT S
WHERE S.sid IN (SELECT E.sid
FROM ENROLLED E, PREREQUISITE P
WHERE E.cnum NOT IN (SELECT P2.cnum
	FROM ENROLLED E2, PREREQUISITE P2
	WHERE E2.cnum=P2.prereq));

--14
SELECT DISTINCT(C1.cnum)
FROM CLASS C1, CLASS C2, PREREQUISITE P
WHERE C1.cnum=P.cnum AND C2.cnum=P.prereq AND C1.meets_at!=C2.meets_at AND C1.cnum!=C2.cnum;

--15
SELECT DISTINCT(F.fname)
FROM CLASS C1, CLASS C2, PREREQUISITE P, FACULTY F
WHERE C1.cnum=P.cnum AND C2.cnum=P.prereq AND C2.fid=C1.fid AND C1.fid=F.fid AND C1.cnum!=C2.cnum;

--16
SELECT DISTINCT C.cnum
FROM CLASS C
WHERE C.cnum IN (SELECT P1.cnum
	FROM PREREQUISITE P1
	WHERE EXISTS (SELECT P1.cnum
		FROM PREREQUISITE P2
		WHERE P1.prereq=P2.cnum AND EXISTS (SELECT P2.cnum
			FROM PREREQUISITE P3
			WHERE P2.prereq=P3.cnum AND NOT EXISTS (SELECT P3.cnum
				FROM PREREQUISITE P4
				WHERE P3.prereq=P4.cnum))))
UNION
SELECT DISTINCT C.cnum
FROM CLASS C
WHERE C.cnum IN (SELECT P1.cnum
	FROM PREREQUISITE P1
	WHERE EXISTS (SELECT P1.cnum
		FROM PREREQUISITE P2
		WHERE P1.prereq=P2.cnum AND NOT EXISTS (SELECT P2.cnum
			FROM PREREQUISITE P3
			WHERE P2.prereq=P3.cnum)))
UNION
SELECT DISTINCT C.cnum
FROM CLASS C
WHERE C.cnum IN (SELECT P1.cnum
	FROM PREREQUISITE P1
	WHERE NOT EXISTS (SELECT P1.cnum
		FROM PREREQUISITE P2
		WHERE P1.prereq=P2.cnum))
UNION
SELECT DISTINCT C.cnum
FROM CLASS C
WHERE C.cnum NOT IN (SELECT P1.cnum
	FROM PREREQUISITE P1);

--17
SELECT DISTINCT S.sname, E.cnum, P1.prereq
FROM STUDENT S, ENROLLED E, PREREQUISITE P1
WHERE S.sid=E.sid AND E.cnum IN (SELECT P1.cnum
	FROM STUDENT S1
	WHERE NOT EXISTS (SELECT P1.cnum
		FROM PREREQUISITE P2
		WHERE P1.prereq=P2.cnum));

--VIEWA
SELECT F.fid, F.fname, C.cnum
FROM FACULTY F, CLASS C
WHERE F.fid=C.fid
ORDER BY F.fid;

--VIEWB
SELECT S.sid, S.sname, E.cnum
FROM STUDENT S, ENROLLED E
WHERE S.sid=E.sid
UNION
SELECT S.sid, S.sname, NULL
FROM STUDENT S
WHERE NOT EXISTS (SELECT *
	FROM ENROLLED E
	WHERE S.sid=E.sid);
