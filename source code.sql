create database airplane_crashes;
use airplane_crashes;
select * from airplane_crashes;
set sql_safe_updates =0;
#update data type new date text format to date format
UPDATE airplane_crashes 
SET newdate = STR_TO_DATE(newdate, '%d-%m-%Y');

#For temporal analysis of airplane crashes, create first KPI 
#1. Annual number of crashes: The Total number of airplane crashes for each year highlighting any significant
# fluctuations or trends in the dataset
select year(newdate) as year, count(*) as num_crashes from airplane_crashes group by year(newdate) order by year;

#2. Fatality Rate: calculated as the ratio of total fatalities to the total number of crashes in a given year
# this KPI indicates the severity of incidents and can help assess safety improvements over time
select sum(fatalities) as total_fatalities from airplane_crashes;

# 3. Average fatalities : Average number of fatalities per airplane crash
select avg(fatalities) as average_fatalities_per_crash from airplane_crashes;

#4. total fatalities: total numbre of fatalities from all airplane crashes  to monitor the overall impact of crashes
select sum(fatalities) as total_fatalities from airplane_crashes;

#5. Monthly distribution of crashes: Analyzing the distribution of crashes by month can reveal seasonal patterns or any month with
#consistently higher or lower incident rates
select month(newdate) as month, count(*) as number_of_crashes from airplane_crashes group by month(newdate)
order by month;

#6. time of day analysis: to analyze the time of day distributio of airplane crashes . we create kpi s based on different time intervals
# This query wil provide counts of crashes that occurred during each respective time interval
#morning crashes: 6:00 AM to 12:00 PM
SELECT COUNT(*) AS Morning_Crashes FROM airplane_crashes WHERE TIME >= '06:00:00' AND TIME < '12:00:00';

#Afternoon crashes: 12:00 PM to 6:00 PM
SELECT COUNT(*) AS Afternoon_Crashes FROM airplane_crashes WHERE TIME >= '12:00:00' AND TIME < '18:00:00';

#Evening crashes : 6:00 PM to 12:00 AM
SELECT COUNT(*) AS Evening_Crashes FROM airplane_crashes WHERE TIME >= '18:00:00' AND TIME < '24:00:00';

#Night crashes : 12:00 AM to 6:00 AM
SELECT COUNT(*) AS Night_Crashes FROM airplane_crashes WHERE TIME >= '00:00:00' AND TIME < '06:00:00';

SELECT
    SUM(CASE WHEN TIME >= '06:00:00' AND TIME < '12:00:00' THEN 1 ELSE 0 END) AS Morning_Crashes,
    SUM(CASE WHEN TIME >= '12:00:00' AND TIME < '18:00:00' THEN 1 ELSE 0 END) AS Afternoon_Crashes,
    SUM(CASE WHEN TIME >= '18:00:00' and TIME < '24:00:00' THEN 1 ELSE 0 END) AS Evening_Crashes,
    SUM(CASE WHEN TIME >= '00:00:00' AND TIME < '06:00:00' THEN 1 ELSE 0 END) AS Night_Crashes
FROM airplane_crashes;

#7. Day of the week analsis: analyzing the distribution of crashes by day of week can help identify any patterns related to weekday vs weekends
SELECT
    SUM(CASE WHEN DAYOFWEEK(newDate) = 1 THEN 1 ELSE 0 END) AS Sunday_Crashes,
    SUM(CASE WHEN DAYOFWEEK(newDate) = 2 THEN 1 ELSE 0 END) AS Monday_Crashes,
    SUM(CASE WHEN DAYOFWEEK(newDate) = 3 THEN 1 ELSE 0 END) AS Tuesday_Crashes,
    SUM(CASE WHEN DAYOFWEEK(newDate) = 4 THEN 1 ELSE 0 END) AS Wednesday_Crashes,
    SUM(CASE WHEN DAYOFWEEK(newDate) = 5 THEN 1 ELSE 0 END) AS Thursday_Crashes,
    SUM(CASE WHEN DAYOFWEEK(newDate) = 6 THEN 1 ELSE 0 END) AS Friday_Crashes,
    SUM(CASE WHEN DAYOFWEEK(newDate) = 7 THEN 1 ELSE 0 END) AS Saturday_Crashes
FROM airplane_crashes;

#8. Long-term Trends: This KPI involves analyzing long -terms trends in airplane crashes over the entire dataset period , hightlighting
# any significant changes or patterns over time and allowing you to identify any long-term trends or patterns in crash 
#occurences over time.

# for yearly trends: this query calcuate the total number of airplane crashes for each year
SELECT YEAR(newDate) AS Year, COUNT(*) AS Number_of_Crashes FROM airplane_crashes GROUP BY YEAR(newDate) ORDER BY Year;

# for monthly trends: this query calcuate the total number of airplane crashes for each month
SELECT CONCAT(YEAR(newDate), '-', LPAD(MONTH(newDate), 2, '0')) AS Month, COUNT(*) AS Number_of_Crashes
FROM airplane_crashes GROUP BY YEAR(newDate), MONTH(newDate), newDate ORDER BY Month;

# 9. Severity of Crashes: This KPI categorizes crashes based on severity 
#(e.g., minor, moderate, severe) and tracks changes in the distribution of severity levels over time.
select year(newdate) as year , sum(case when fatalities =0 and ground=0 then 1 else 0 end) as minor_crashes,
sum(case when fatalities > 0 and fatalities <= 10 then 1 else 0 end) as Moderate_crashes,
sum(case when fatalities > 10 and fatalities <= 100 then 1 else 0 end) as severe_crashes,
sum(case when fatalities > 100 then 1 else 0 end) as catastrophic_crashes
from airplane_crashes group by year(newdate) order by year;

# For Geospatial Analysis:
# 1.Total Crashes by country: total crashes in each country
Select (location) as country, count(*) as total_crashes from airplane_crashes group by country order by total_crashes desc;

#2.	Crashes per Million Flights: Calculate the number of crashes per million flights for each country, providing a normalized measure.
#Crashes per million flights = (total number of crashes /  total number of flights) * 10^6
# Total number of crashes for each country
Select (location) as country, count(*) as total_crashes from airplane_crashes group by country order by total_crashes desc;
#update column name flight
ALTER TABLE airplane_crashes CHANGE `flight #` flight VARCHAR(255);
# Total number of flights for each country
select count(flight) as total_flights from airplane_crashes;

#3. Crashes by region: Analyze the distribution of crashes by geographical regions (e.g., continents, sub-regions)
# to identify areas with higher incident rates.
select location, count(*) as total_crashes from airplane_crashes group by location;

#4.	Fatality Rate by Country: Calculate the fatality rate (number of fatalities divided by the total number of crashes) for each country.
SELECT location,SUM(Fatalities) AS Total_Fatalities, SUM(Aboard) AS Total_Aboard,(SUM(Fatalities) / SUM(Aboard)) * 100 AS Fatality_Rate
FROM airplane_crashes
GROUP BY location;

#5 Route analysis by country: Analyze the distribution of crashes by flight route for each country 
#to identify routes with higher incident rates.
SELECT SUBSTRING_INDEX(Location, ',', 1) AS Country, Route, COUNT(*) AS Number_of_Crashes FROM airplane_crashes
GROUP BY Country, Route ORDER BY Country, Number_of_Crashes DESC;


#6 Ground Casualities by country: Calculate the total number of ground casualties (if any) for each country 
#to assess the impact of crashes on the ground.
SELECT SUBSTRING_INDEX(Location, ',', 1) AS Country,SUM(Ground) AS Total_Ground_Casualties
FROM airplane_crashes GROUP BY Country ORDER BY Total_Ground_Casualties DESC;

# For Operator Performance:

#1. incident Frequency:Calculate the total number of incidents involving each operator to identify operators with higher incident rates.
SELECT Operator, COUNT(*) AS Incident_Frequency FROM airplane_crashes GROUP BY Operator ORDER BY Incident_Frequency DESC;

#2. Fatality Rate: Determine the ratio of total fatalities to the total number of incidents for each operator 
#to assess the severity of incidents associated with each operator.
SELECT Operator,COUNT(*) AS Total_Incidents,SUM(Fatalities) AS Total_Fatalities,SUM(Fatalities) / COUNT(*) AS Fatality_Rate
FROM airplane_crashes WHERE Fatalities > 0 GROUP BY Operator ORDER BY Fatality_Rate DESC;

#3. Passenger Safety Score: Evaluate the safety performance of operators based on the ratio of passenger fatalities 
#to the total number of passengers involved in incidents.
set sql_safe_updates =0;
# update columns name
ALTER TABLE airplane_crashes CHANGE `Ac Type` AC_Type VARCHAR(255);
ALTER TABLE airplane_crashes CHANGE `Aboard Passangers` Aboard_Passengers VARCHAR(255);
ALTER TABLE airplane_crashes CHANGE `Aboard Crew` Aboard_Crew VARCHAR(255);
ALTER TABLE airplane_crashes CHANGE `Fatalities Passangers` Fatalities_Passangers VARCHAR(255);
ALTER TABLE airplane_crashes CHANGE `Fatalities Crew` Fatalities_Crew VARCHAR(255);

Select * from airplane_crashes;
SELECT Operator,COUNT(*) AS Total_Incidents,SUM(Fatalities) AS Total_Fatalities,SUM(Fatalities_Passangers) AS Passenger_Fatalities,
(SUM(Fatalities_Passangers) / SUM(Fatalities)) * 100 AS Passenger_Fatality_Rate FROM airplane_crashes
WHERE Fatalities > 0 GROUP BY Operator ORDER BY Passenger_Fatality_Rate DESC;

#3. Passenger Safety Score: Evaluate the safety performance of operators based on the ratio of passenger fatalities
# to the total number of passengers involved in incidents.

Select Operator, count(*) as Total_Incidents, Sum(Aboard_Passengers) as Total_Passengers, sum(Fatalities_Passangers) as Passenger_Fatalities,
(1-(sum(Fatalities_Passangers)/sum(aboard_Passengers)))*100 as Passengers_safety_score from airplane_crashes
where aboard_Passengers >0 group by operator order by Passengers_safety_score desc;

#4 Crew Safety Score: Assess the safety performance of operators based on the ratio of crew member fatalities 
#to the total number of crew members involved in incidents.
SELECT Operator, COUNT(*) AS Total_Incidents, SUM(Aboard_Crew) AS Total_Crew, SUM(Fatalities_Crew) AS Crew_Fatalities, 
(1 - (SUM(Fatalities_Crew) / SUM(Aboard_Crew))) * 100 AS Crew_Safety_Score FROM airplane_crashes 
WHERE Aboard_Crew > 0 GROUP BY Operator ORDER BY Crew_Safety_Score DESC;

#5 Incident Severity Index: Develop an index that considers the severity of incidents (e.g., total fatalities, total injuries) and
#the frequency of incidents to rank operators based on their overall safety performance.
#This query calculates the Incident Severity Index for each operator by dividing the total number of fatalities by the total number of individuals involved in the incidents, 
#then multiplying by 100 to get a percentage.
SELECT Operator,COUNT(*) AS Total_Incidents,SUM(Aboard) AS Total_Individuals,SUM(Fatalities) AS Total_Fatalities,
(SUM(Fatalities) / SUM(Aboard)) * 100 AS Incident_Severity_Index FROM airplane_crashes GROUP BY Operator
ORDER BY Incident_Severity_Index DESC;

#6. Incident Trend Analysis: Analyze the trend of incidents over time for each operator to identify improvements
# or deteriorations in safety performance.
SELECT YEAR(newDate) AS Year,MONTH(newDate) AS Month,COUNT(*) AS Total_Incidents FROM airplane_crashes
GROUP BY YEAR(newDate), MONTH(newDate) ORDER BY Year, Month;

# Aircraft Analysis
#1.Total Incidents by Aircraft Type: This KPI provides the total number of incidents associated with each aircraft type,
 #helping to identify which types are involved in the most incidents.
SELECT AC_Type AS Aircraft_Type, COUNT(*) AS Total_Incidents FROM airplane_crashes GROUP BY AC_Type ORDER BY Total_Incidents DESC;

#2.	Fatal Incidents by Aircraft Type: Similar to the first KPI, this KPI focuses specifically on fatal incidents, 
#highlighting which aircraft types are associated with the highest number of fatalities.
SELECT AC_Type AS Aircraft_Type, COUNT(*) AS Total_Incidents, SUM(Fatalities) AS Total_Fatalities
FROM airplane_crashes WHERE Fatalities > 0 GROUP BY AC_Type ORDER BY Total_Fatalities DESC;

#3.Fatalities per Incident by Aircraft Type: This KPI calculates the average number of fatalities per incident for each aircraft type, 
#providing insight into the severity of incidents involving different aircraft.
SELECT AC_Type AS Aircraft_Type,COUNT(*) AS Total_Incidents,SUM(Fatalities) AS Total_Fatalities,AVG(Fatalities) AS Avg_Fatalities_Per_Incident
FROM airplane_crashes WHERE Fatalities > 0 GROUP BY AC_Type ORDER BY Avg_Fatalities_Per_Incident DESC;

#4.	Passenger Safety Score by Aircraft Type: This KPI evaluates passenger safety by considering 
#factors such as the number of passengers aboard during incidents and the number of fatalities among passengers.
#It calculates a safety score for each aircraft type based on these factors.
SELECT AC_Type AS Aircraft_Type, COUNT(*) AS Total_Incidents, SUM(Aboard_Passengers) AS Total_Passengers, SUM(Fatalities_Passangers)
AS Passenger_Fatalities, ROUND((1 - (SUM(Fatalities_Passangers) / SUM(Aboard_Passengers))) * 100, 2) AS Passenger_Safety_Score
FROM airplane_crashes WHERE Aboard_Passengers > 0 GROUP BY AC_Type ORDER BY Passenger_Safety_Score DESC;

#4.	Passenger Safety Score by Aircraft Type: This KPI evaluates passenger safety by considering factors 
#such as the number of passengers aboard during incidents and the number of fatalities among passengers.
#It calculates a safety score for each aircraft type based on these factors.
SELECT AC_Type AS Aircraft_Type, COUNT(*) AS Total_Incidents, SUM(Aboard_Passengers) AS Total_Passengers, SUM(Fatalities_Passangers)
AS Passenger_Fatalities, ROUND((1 - (SUM(Fatalities_Passangers) / SUM(Aboard_Passengers))) * 100, 2) AS Passenger_Safety_Score
FROM airplane_crashes WHERE Aboard_Passengers > 0 GROUP BY AC_Type ORDER BY Passenger_Safety_Score DESC;

#5.	Incident Severity Index by Aircraft Type: This KPI combines various factors such as fatalities, injuries, and property damage to
#create an incident severity index for each aircraft type, allowing for comparison of incident severity across different types.

SELECT AC_Type AS Aircraft_Type, COUNT(*) AS Total_Incidents, SUM(Aboard_Passengers) AS Total_Passengers, SUM(Fatalities) AS Total_Fatalities,
ROUND((SUM(Fatalities) / SUM(Aboard_Passengers)) * 100, 2) AS Incident_Severity_Index FROM airplane_crashes WHERE Aboard_Passengers > 0
GROUP BY AC_Type ORDER BY Incident_Severity_Index DESC;

#6.	Trend Analysis by Aircraft Type: This KPI examines trends in incident frequency, severity, or other relevant metrics over time for 
#each aircraft type, helping to identify patterns or changes in aircraft performance or safety.
SELECT AC_Type AS Aircraft_Type, YEAR(newDate) AS Incident_Year, COUNT(*) AS Total_Incidents FROM airplane_crashes
GROUP BY AC_Type, YEAR(newDate) ORDER BY AC_Type, Incident_Year;

# Fatality Trends:
#1. Total fatalities over time:
SELECT YEAR(newDate) AS Incident_Year, SUM(Fatalities) AS Total_Fatalities FROM airplane_crashes GROUP BY YEAR(newDate)
ORDER BY Incident_Year;

#2.Fatality Distributon by operator:
SELECT Operator, SUM(Fatalities) AS Total_Fatalities FROM airplane_crashes GROUP BY Operator ORDER BY Total_Fatalities DESC;

#3. Fatality distribution by aircraft type
SELECT AC_Type AS Aircraft_Type, SUM(Fatalities) AS Total_Fatalities FROM airplane_crashes 
GROUP BY Aircraft_Type ORDER BY Total_Fatalities DESC;

#Fatality distribution by location
SELECT Location, SUM(Fatalities) AS Total_Fatalities FROM airplane_crashes GROUP BY Location ORDER BY Total_Fatalities DESC;

#6. Route Analysis:
#Total number of incidents by route:
SELECT Route, COUNT(*) AS Total_Incidents FROM airplane_crashes GROUP BY Route ORDER BY Total_Incidents DESC;

#Total fatalities by route
SELECT Route, SUM(Fatalities) AS Total_Fatalities FROM airplane_crashes GROUP BY Route ORDER BY Total_Fatalities DESC;

#Average number of fatalities per incident by rate
SELECT Route, AVG(Fatalities) AS Avg_Fatalities_Per_Incident FROM airplane_crashes GROUP BY Route
ORDER BY Avg_Fatalities_Per_Incident DESC;

# Route with the highest number of incidents involving ground casualities
SELECT Route, COUNT(*) AS Total_Incidents_Ground_Casualties FROM airplane_crashes WHERE Ground > 0
GROUP BY Route ORDER BY Total_Incidents_Ground_Casualties DESC;


use airplane_crashes;
select * from airplane_crashes;

#more crashes done in year
SELECT YEAR(newDate) AS Year, COUNT(*) AS NumCrashes
FROM airplane_crashes
GROUP BY YEAR(newDate)
ORDER BY NumCrashes DESC
LIMIT 1;

#most fatalities done in year
SELECT YEAR(newDate) AS Year, SUM(Fatalities) AS TotalFatalities
FROM airplane_crashes
GROUP BY YEAR(newDate)
ORDER BY TotalFatalities DESC
LIMIT 1;

#most crashes done by operator
SELECT YEAR(newDate) AS Year, Operator, COUNT(*) AS TotalCrashes
FROM airplane_crashes
GROUP BY YEAR(newDate), Operator
ORDER BY TotalCrashes DESC
LIMIT 1;
#most fatalities done by route	
SELECT Route, SUM(Fatalities) AS TotalFatalities
FROM airplane_crashes
GROUP BY Route
ORDER BY TotalFatalities DESC
LIMIT 1;






