CREATE table Atlet AS 
SELECT * FROM Event_1 UNION ALL
SELECT * FROM Event_2 UNION ALL
SELECT * FROM Event_3 UNION ALL
SELECT * FROM Event_4 UNION ALL
SELECT * FROM Event_5 UNION ALL
SELECT * FROM Event_6 UNION ALL
SELECT * FROM Event_7 UNION ALL
SELECT * FROM Event_8 UNION ALL
SELECT * FROM Event_9 UNION ALL
SELECT * FROM Event_10 UNION ALL
SELECT * FROM Event_11_3031 UNION ALL
SELECT * FROM Event_2911 UNION ALL
SELECT * FROM Event_12 UNION ALL
SELECT * FROM Event_13 UNION ALL
SELECT * FROM Event_14


--1. How many olympics games has been held?
select count(distinct Games) Total_Olympics_Games from Atlet;

--2. List down all Olympics games held so far.
select distinct Year, Season, City from Atlet order by Year ASC;

--3. Mention the total no of nations who participated in each olympics game?
select Games, Count(DISTINCT Region) Total_Nation
FROM
(select Atlet.Games, reg.Region from Atlet
left join region reg ON Atlet.NOC = reg.noc)
group by Games
order by Games;

--4. Which year saw the lowest no of countries participating in olympics
Select Games ||"-"|| Total_Nation AS Min_Participant
 FROM
(select Games, Count(DISTINCT Region) Total_Nation
          FROM
        (select Atlet.Games, reg.Region from Atlet
        left join region reg ON Atlet.NOC = reg.noc)
        group by Games
        order by Total_Nation ASC
        LIMIT 1);
        
--4. Which year saw the highest no of countries participating in olympics
Select Games ||"-"|| Total_Nation Max_Participant
 FROM
(select Games, Count(DISTINCT Region) Total_Nation
          FROM
        (select Atlet.Games, reg.Region from Atlet
        left join region reg ON Atlet.NOC = reg.noc)
        group by Games
        order by Total_Nation DESC
        LIMIT 1);

--5.Which nation has participated in all of the olympic games?
Select Region, Total_Olympics_Games FROM
(select Region, count(distinct Games) Total_Olympics_Games FROM
(select reg.Region, atlet.Games FROM Atlet
left join region reg ON atlet.NOC = reg.noc)
group by Region
order by Total_Olympics_Games DESC)
where Total_Olympics_Games = 51;

--6. Identify the sport which was played in all summer olympics!
with t1 AS (Select DISTINCT Games, Sport FROM Atlet WHERE Season = 'Summer'),
      t2 AS (Select COUNT(DISTINCT Games) Total_Games FROM Atlet WHERE Season = 'Summer'),
      t3 AS (Select Sport, COUNT(Sport) Total_Sport FROM t1 GROUP BY Sport)
select t3.*, t2.Total_Games FROM t3
JOIN t2 ON t3.Total_Sport = t2.Total_Games;

--7.Which Sports were just played only once IN the olympics.
SELECT t2.*, t1.Games FROM 
  (SELECT Sport,COUNT(1) AS Total FROM 
    (SELECT DISTINCT(Games), Sport FROM Atlet) AS t1 GROUP BY Sport) AS t2 
    JOIN 
    (SELECT DISTINCT(Games), Sport FROM Atlet) AS t1 ON t1.Sport = t2.Sport 
    WHERE Total=1 ORDER BY Sport ASC;

--8. Fetch the total no of sports played in each olympic games.

select Games, Count(Sport) Total_Sport FROM
(select Distinct Games, Sport from Atlet)
GROUP BY Games
ORDER BY Games;

--10. Fetch the top 5 athletes who have won the most gold medals.

Select Name, COUNT(Medal) Total_Medal_Gold, Team  FROM Atlet
WHERE Medal = "Gold"
GROUP BY Name, Team
ORDER BY Total_Medal_Gold DESC;

--11. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze)

select Name , Team, COUNT(Medal) Total_Medal FROM Atlet
WHERE Medal IN ('Gold', 'Silver', 'Bronze')
GROUP BY Name, Team
ORDER BY Total_Medal DESC;

--12.Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won

Select DISTINCT Region, COUNT(Medal) Total_Medal FROM
(with t1 AS 
        (Select NOC, Medal FROM Atlet WHERE Medal IN ('Gold', 'Silver','Bronze')),
      t2 AS
        (Select * FROM region)
Select t1.*, t2.Region FROM t1
LEFT JOIN t2 ON t1.NOC = t2.noc)
GROUP BY Region
ORDER BY Total_Medal DESC
LIMIT 5;

--13. List down total gold, silver and bronze medals won by each country

with Data AS
          (Select t1.NOC, t1.Medal, t2.Region FROM Atlet AS t1
          LEFT JOIN region AS t2 ON t1.NOC = t2.noc),
      Gold AS
          (Select DISTINCT Region, COUNT(Medal) Medal_Gold FROM Data WHERE Medal='Gold' GROUP BY Region),
      Silver AS
          (Select DISTINCT Region, COUNT(Medal) Medal_Silver FROM Data WHERE Medal='Silver' GROUP BY Region),
      Bronze AS
          (Select DISTINCT Region, COUNT(Medal) Medal_Bronze FROM Data WHERE Medal='Bronze' GROUP BY Region)
Select Gold.*, Silver.Medal_Silver, Bronze.Medal_Bronze FROM Gold
LEFT JOIN Silver ON Gold.Region = Silver.Region
LEFT JOIN Bronze ON Gold.Region = Bronze.Region
ORDER BY Medal_Gold DESC;

--14. List down total gold, silver and bronze medals won by each country corresponding to each olympic games.

with Data1 AS (Select t1.Games, t2.Region, COUNT(t1.Medal) Gold FROM Atlet t1
              LEFT JOIN region t2 ON t1.NOC = t2.noc
              Where Medal = 'Gold'
              GROUP BY Games, Region
              ORDER BY Games),
    Data2 AS (Select t1.Games, t2.Region, COUNT(t1.Medal) Silver FROM Atlet t1
              LEFT JOIN region t2 ON t1.NOC = t2.noc
              Where Medal = 'Silver'
              GROUP BY Games, Region
              ORDER BY Games),
    Data3 AS (Select t1.Games, t2.Region, COUNT(t1.Medal) Bronze FROM Atlet t1
              LEFT JOIN region t2 ON t1.NOC = t2.noc
              Where Medal = 'Bronze'
              GROUP BY Games, Region
              ORDER BY Games),
    Data4 AS (Select Data1.*, Data2.Silver, Data3.Bronze FROM Data1
              LEFT JOIN Data2 ON Data1.Games = Data2.Games AND Data1.Region = Data2.Region
              LEFT JOIN Data3 ON Data1.Games = Data3.Games AND Data1.Region = Data3.Region
              ORDER BY Data1.Games)
  select Games,Region,
          IFNULL(Gold, 0) Gold,
          IFNULL(Silver, 0) Silver,
          IFNULL(Bronze, 0) Bronze
          FROM Data4;

--15. Identify which country won the most gold, most silver and most bronze medals in each olympic games.
with Data1 AS (Select t1.Games, t2.Region, COUNT(t1.Medal) Gold FROM Atlet t1
              LEFT JOIN region t2 ON t1.NOC = t2.noc
              Where Medal = 'Gold'
              GROUP BY Games, Region
              ORDER BY Games),
    Data2 AS (Select t1.Games, t2.Region, COUNT(t1.Medal) Silver FROM Atlet t1
              LEFT JOIN region t2 ON t1.NOC = t2.noc
              Where Medal = 'Silver'
              GROUP BY Games, Region
              ORDER BY Games),
    Data3 AS (Select t1.Games, t2.Region, COUNT(t1.Medal) Bronze FROM Atlet t1
              LEFT JOIN region t2 ON t1.NOC = t2.noc
              Where Medal = 'Bronze'
              GROUP BY Games, Region
              ORDER BY Games),
    Data4 AS (Select Data1.*, Data2.Silver, Data3.Bronze FROM Data1
              LEFT JOIN Data2 ON Data1.Games = Data2.Games AND Data1.Region = Data2.Region
              LEFT JOIN Data3 ON Data1.Games = Data3.Games AND Data1.Region = Data3.Region
              ORDER BY Data1.Games),
    Data5 AS (select Games,Region,
              IFNULL(Gold, 0) Gold,
              IFNULL(Silver, 0) Silver,
              IFNULL(Bronze, 0) Bronze
              FROM Data4),
    Data6 AS (Select Games, Region, Gold , RANK() OVER(PARTITION BY Games ORDER BY Games ASC, Gold DESC) Ranking FROM Data5),
    Data7 AS (Select Games, Region, Silver , RANK() OVER(PARTITION BY Games ORDER BY Games ASC, Silver DESC) Ranking FROM Data5),
    Data8 AS (Select Games, Region, Bronze , RANK() OVER(PARTITION BY Games ORDER BY Games ASC, Bronze DESC) Ranking FROM Data5),
    Data9 AS (Select Games, Region||"-"||Gold AS Gold FROM
    (Select Games, Region, Gold FROM Data6 WHERE Ranking = 1 ORDER BY Games)),
    Data10 AS (Select Games, Region||"-"||Silver AS Silver FROM
    (Select Games, Region, Silver FROM Data7 WHERE Ranking = 1 ORDER BY Games)),
    Data11 AS (Select Games, Region||"-"||Bronze AS Bronze FROM
    (Select Games, Region, Bronze FROM Data8 WHERE Ranking = 1 ORDER BY Games))

    Select Data9.*, Data10.Silver, Data11.Bronze FROM Data9
    LEFT JOIN Data10 ON Data9.Games = Data10.Games
    LEFT JOIN Data11 ON Data9.Games = Data11.Games
    ORDER BY Games;

--16. Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.

with Data1 AS (Select t1.Games, t2.Region, COUNT(t1.Medal) Gold FROM Atlet t1
              LEFT JOIN region t2 ON t1.NOC = t2.noc
              Where Medal = 'Gold'
              GROUP BY Games, Region
              ORDER BY Games),
    Data2 AS (Select t1.Games, t2.Region, COUNT(t1.Medal) Silver FROM Atlet t1
              LEFT JOIN region t2 ON t1.NOC = t2.noc
              Where Medal = 'Silver'
              GROUP BY Games, Region
              ORDER BY Games),
    Data3 AS (Select t1.Games, t2.Region, COUNT(t1.Medal) Bronze FROM Atlet t1
              LEFT JOIN region t2 ON t1.NOC = t2.noc
              Where Medal = 'Bronze'
              GROUP BY Games, Region
              ORDER BY Games),
    Data31 AS (Select t1.Games, t2.Region, COUNT(t1.Medal) All_Medals FROM Atlet t1
              LEFT JOIN region t2 ON t1.NOC = t2.noc
              WHERE Medal IN ('Gold','Silver','Bronze')
              GROUP BY Games, Region
              ORDER BY Games),
    Data4 AS (Select Data1.*, Data2.Silver, Data3.Bronze, Data31.All_Medals FROM Data1
              LEFT JOIN Data2 ON Data1.Games = Data2.Games AND Data1.Region = Data2.Region
              LEFT JOIN Data3 ON Data1.Games = Data3.Games AND Data1.Region = Data3.Region
              LEFT JOIN Data31 ON Data1.Games = Data31.Games AND Data1.Region = Data31.Region
              ORDER BY Data1.Games),
    Data5 AS (select Games,Region,
              IFNULL(Gold, 0) Gold,
              IFNULL(Silver, 0) Silver,
              IFNULL(Bronze, 0) Bronze,
              IFNULL(All_Medals, 0) All_Medals
              FROM Data4),
    Data6 AS (Select Games, Region, Gold , RANK() OVER(PARTITION BY Games ORDER BY Games ASC, Gold DESC) Ranking FROM Data5),
    Data7 AS (Select Games, Region, Silver , RANK() OVER(PARTITION BY Games ORDER BY Games ASC, Silver DESC) Ranking FROM Data5),
    Data8 AS (Select Games, Region, Bronze , RANK() OVER(PARTITION BY Games ORDER BY Games ASC, Bronze DESC) Ranking FROM Data5),
    Data81 AS (Select Games, Region, All_Medals , RANK() OVER(PARTITION BY Games ORDER BY Games ASC, All_Medals DESC) Ranking FROM Data5),
    Data9 AS (Select Games, Region||"-"||Gold AS Gold FROM
    (Select Games, Region, Gold FROM Data6 WHERE Ranking = 1 ORDER BY Games)),
    Data10 AS (Select Games, Region||"-"||Silver AS Silver FROM
    (Select Games, Region, Silver FROM Data7 WHERE Ranking = 1 ORDER BY Games)),
    Data11 AS (Select Games, Region||"-"||Bronze AS Bronze FROM
    (Select Games, Region, Bronze FROM Data8 WHERE Ranking = 1 ORDER BY Games)),
    Data12 AS (Select Games, Region||"-"||All_Medals AS All_Medals FROM
    (Select Games, Region, All_Medals FROM Data81 WHERE Ranking = 1 ORDER BY Games))

    Select Data9.*, Data10.Silver, Data11.Bronze, Data12.All_Medals FROM Data9
    LEFT JOIN Data10 ON Data9.Games = Data10.Games
    LEFT JOIN Data11 ON Data9.Games = Data11.Games
    LEFT JOIN Data12 ON Data9.Games = Data12.Games
    ORDER BY Games;

--17. Which countries have never won gold medal but have won silver/bronze medals
with Data AS
          (Select t1.NOC, t1.Medal, t2.Region FROM Atlet AS t1
          LEFT JOIN region AS t2 ON t1.NOC = t2.noc),
      Gold AS
          (Select DISTINCT Region, COUNT(Medal) Medal_Gold FROM Data WHERE Medal='Gold' GROUP BY Region),
      Silver AS
          (Select DISTINCT Region, COUNT(Medal) Medal_Silver FROM Data WHERE Medal='Silver' GROUP BY Region),
      Bronze AS
          (Select DISTINCT Region, COUNT(Medal) Medal_Bronze FROM Data WHERE Medal='Bronze' GROUP BY Region)
Select Gold.Region, 
IFNULL(Gold.Medal_Gold,0) AS Medal_Gold,
IFNULL(Silver.Medal_Silver,0) AS Medal_Silver,
IFNULL(Bronze.Medal_Bronze,0) AS Medal_Bronze FROM Gold
LEFT JOIN Silver ON Gold.Region = Silver.Region
LEFT JOIN Bronze ON Gold.Region = Bronze.Region
ORDER BY Medal_Gold ASC;

--18. In which Sport/event, Indonesia has won highest medals.

WITH DATA1 AS (select t2.Region, t1.Sport, t1.Medal FROM Atlet t1 
              LEFT JOIN region t2 ON t1.NOC = t2.noc WHERE Region = 'Indonesia')
      Select Sport, COUNT(Medal) Total_Medal FROM DATA1 WHERE Medal <> 'NA' 
      GROUP BY Sport ORDER BY Total_Medal DESC
              LIMIT 1;

--19. Break down all olympic games where Indonesia won medal for Badminton and how many medals in each olympic games

WITH DATA1 AS (select t2.Region, t1.Sport, t1.Games, t1.Medal FROM Atlet t1 
              LEFT JOIN region t2 ON t1.NOC = t2.noc WHERE Region = 'Indonesia')
      Select Region, Sport, Games, COUNT(Medal) Total_Medal FROM DATA1 WHERE Medal <> 'NA' 
      AND Sport = 'Badminton' GROUP BY Region,Sport,Games ORDER BY Games;