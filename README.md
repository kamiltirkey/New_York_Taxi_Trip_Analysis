# New_York_Taxi_Trip_Analysis

<h3>Objective</h3> To clean and prep NYC taxi trips data using 4 tables consisting of data from 2017 to 2020.

<h3>Data Description</h3> The 4 Taxi Trips tables contain a total of 28 million Green Taxi trips in New York City from 2017 to 2020. Each record represents one trip, with fields containing details about the pick-up/drop-off times and locations, distances, fares, passengers, and more

<h3>Problem Statements</h3>

- Let’s stick to trips that were NOT sent via “store and forward”
- I’m only interested in street-hailed trips paid by card or cash, with a standard rate
- We can remove any trips with dates before 2017 or after 2020, along with any trips with pickups or drop-offs into unknown zones
- Let’s assume any trips with no recorded passengers had 1 passenger
- If a pickup date/time is AFTER the drop-off date/time, let’s swap them



![carbon (1)](https://github.com/kamiltirkey/New_York_Taxi_Trip_Analysis/assets/149951494/7d73db92-44ba-4c02-b914-c1d990825a22)

