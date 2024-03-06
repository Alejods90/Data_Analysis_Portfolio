
--Those are the databases I'm using for this Portfolio

SELECT *
FROM InternationalTouristTrips

SELECT *
FROM NumberIndividualsEmployed

SELECT *
FROM TourismGdpProportion

-- I wanted to join them by the Entity key and the Year key since they have different periods.

CREATE VIEW TourismData AS

(SELECT inter.Entity,inter.Year, [inbound arrivals (tourists)],
[Employment (total) per 1000 people],  [Tourism GDP as a proportion of Total], 
([Employment (total) per 1000 people]/1000)/[inbound arrivals (tourists)] as EmploymentProportion
FROM InternationalTouristTrips inter
JOIN NumberIndividualsEmployed number
ON inter.Entity = number.Entity AND inter.Year = number.Year 
JOIN TourismGdpProportion gdp
ON inter.Entity = gdp.Entity AND inter.YEAR = gdp.YEAR)

SELECT *
FROM TourismData

--Let's explore the total of arrivals per year

SELECT Year, SUM([inbound arrivals (tourists)]) as TotalArrivals
FROM TourismData
GROUP BY Year
ORDER BY Year

--This query shows us how much was the total GPD per country

SELECT Entity, SUM([Tourism GDP as a proportion of Total]) as TotalGdp
FROM TourismData
GROUP BY Entity

SELECT Entity, year,[Tourism GDP as a proportion of Total], SUM([Tourism GDP as a proportion of Total]) 
OVER (partition by Entity order by Entity, Year) as TotalGdp
FROM TourismData


--And this one shows us the average GDP per country

SELECT Entity, AVG([Tourism GDP as a proportion of Total]) as AVGGdp
FROM TourismData
GROUP BY Entity

--What if we pull out average GDP and Total GDP group by Country...

SELECT TourismData.Entity, AVG([Tourism GDP as a proportion of Total]) as AVGGdp, (SELECT SUM([Tourism GDP as a proportion of Total]) 
FROM TourismData ) as TotalGdp
FROM TourismData
GROUP BY TourismData.Entity

-- Now the average GDP and Total GDP proportion group by Country...

SELECT TourismData.Entity, AVG([Tourism GDP as a proportion of Total]) as AVGGdp, (SELECT SUM([Tourism GDP as a proportion of Total]) 
FROM TourismData ) as TotalGdp,
((SELECT SUM([Tourism GDP as a proportion of Total]) FROM TourismData)/EntityGDP.GDPEntity) as EntGdpProportion
FROM TourismData JOIN (SELECT Entity, AVG([Tourism GDP as a proportion of Total]) as GDPEntity FROM TourismData GROUP BY Entity) EntityGDP
ON TourismData.Entity = EntityGDP.Entity
GROUP BY TourismData.Entity, EntityGDP.GDPEntity
ORDER BY TourismData.Entity

-- Let's see how many tourists arrive per Country

SELECT Entity, AVG( [inbound arrivals (tourists)]) as AVGTourists
FROM TourismData
GROUP BY Entity

--Here I want to find out the proportion between inbound arrivals and the employment generated in the tourism field

SELECT Entity,Year, [inbound arrivals (tourists)],
[Employment (total) per 1000 people], [Tourism GDP as a proportion of Total], 
([Employment (total) per 1000 people]/[inbound arrivals (tourists)]) as EmploymentProportionPer1000
FROM TourismData

--Now take a look of the proportion above grouped by per country but selecting the year when this value was at its maximum.

SELECT Entity, Year,max(([Employment (total) per 1000 people]/1000)/[inbound arrivals (tourists)]) as EmploymentProportion
FROM TourismData
GROUP BY Entity, Year

--To have a bigger idea of how strong the tourism GDP is in a specific country, I'm pulling out the year when the GDP value 
--was bigger than the average GDP per Country

SELECT TourismData.Entity,TourismData.Year, TourismData.[Tourism GDP as a proportion of Total],AVGGdpEnt.AVGGdp FROM TourismData
JOIN (SELECT Entity, AVG([Tourism GDP as a proportion of Total]) as AVGGdp
FROM TourismData 
GROUP By Entity)  as AVGGdpEnt
ON TourismData.Entity = AVGGdpEnt.Entity
Where TourismData.[Tourism GDP as a proportion of Total]>AVGGdpEnt.AVGGdp

--Now, if we wanted to perform the same query but without using a view or CTE this is how it'd look like:

SELECT inter.Entity, inter.Year, gdp.[Tourism GDP as a proportion of Total], AVGGdpEnt.AVGGdp
FROM
    InternationalTouristTrips inter
    JOIN NumberIndividualsEmployed number ON inter.Entity = number.Entity AND inter.Year = number.Year
    JOIN TourismGdpProportion gdp ON inter.Entity = gdp.Entity AND inter.YEAR = gdp.YEAR
JOIN (SELECT inter.Entity, AVG(gdp.[Tourism GDP as a proportion of Total]) as AVGGdp
FROM 
    InternationalTouristTrips inter
    JOIN NumberIndividualsEmployed number ON inter.Entity = number.Entity AND inter.Year = number.Year
    JOIN TourismGdpProportion gdp ON inter.Entity = gdp.Entity AND inter.YEAR = gdp.YEAR
GROUP By inter.Entity) AVGGdpEnt
ON inter.Entity = AVGGdpEnt.Entity
Where gdp.[Tourism GDP as a proportion of Total] >  AVGGdpEnt.AVGGdp