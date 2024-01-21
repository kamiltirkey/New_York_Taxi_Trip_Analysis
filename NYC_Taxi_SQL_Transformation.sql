DROP TABLE IF EXISTS dbo.total_nyc_trips_OUTPUT
GO

WITH total_taxi_trips AS (
SELECT *, NULL AS congestion_surcharge FROM [dbo].[2017_taxi_trips]
UNION ALL
SELECT *, NULL AS congestion_surcharge FROM [dbo].[2018_taxi_trips]
UNION ALL
SELECT * FROM [dbo].[2019_taxi_trips]
UNION ALL
SELECT * FROM [dbo].[2020_taxi_trips]
),

swappingDatetimes AS (
	SELECT *
			,(CASE WHEN [lpep_dropoff_datetime]<[lpep_pickup_datetime] 
		   			THEN [lpep_dropoff_datetime] 
		 			ELSE [lpep_pickup_datetime] 
					END) AS final_pickup_date --If a pickup date/time is AFTER the drop-off date/time, let’s swap them
			,(CASE WHEN [lpep_dropoff_datetime]<[lpep_pickup_datetime] 
					THEN [lpep_pickup_datetime] 
					ELSE [lpep_dropoff_datetime] 
					END) AS final_dropoff_date --If a pickup date/time is AFTER the drop-off date/time, let’s swap them
	FROM total_taxi_trips
),

conditionFiltering AS (
	SELECT [VendorID]
			,[final_pickup_date]
			,[final_dropoff_date]
			,[store_and_fwd_flag]
			,[RatecodeID]
			,[PULocationID]
			,[DOLocationID]
			,[passenger_count]
			,[trip_distance]
			,ABS([fare_amount]) AS [fare_amount]
			,[extra]
			,ABS([mta_tax]) AS [mta_tax]
			,[tip_amount]
			,[tolls_amount]
			,ABS([improvement_surcharge]) AS [improvement_surcharge]
			,[total_amount]
			,[payment_type]
			,[trip_type]
			,ABS([congestion_surcharge]) AS [congestion_surcharge]
	FROM swappingDatetimes
	WHERE [store_and_fwd_flag] = '"N"' 
	AND trip_type = '1' --Let’s stick to trips that were NOT sent via “store and forward”
	AND payment_type IN ('1','2') --I’m only interested in street-hailed trips paid by card or cash
	AND [RatecodeID] = '1' -- trips paid with a standard rate
	AND DATEPART(year, [lpep_pickup_datetime]) BETWEEN '2017' AND '2020' --remove any trips with dates before 2017 or after 2020
	AND DATEPART(year, [lpep_dropoff_datetime]) BETWEEN '2017' AND '2020'--remove any trips with dates before 2017 or after 2020
	AND  [PULocationID] NOT IN ('264','265') -- removed trips with pickups or drop-offs into unknown zones
	AND  [DOLocationID] NOT IN ('264','265') -- removed trips with pickups or drop-offs into unknown zones
	AND [passenger_count] NOT IN ('', ' ') AND [passenger_count] IS NOT NULL -- any trips with no recorded passengers had 1 passenger
	AND  DATEDIFF(hour, final_pickup_date, final_dropoff_date) * 1.00 <=24 --remove trips lasting longer than a day
	AND NOT (trip_distance='0' AND fare_amount='0') --any trips which show both a distance and fare amount of 0
)
	
SELECT * INTO [dbo].[total_nyc_trips_OUTPUT]
FROM (
	SELECT   [VendorID]
			,[final_pickup_date]
			,[final_dropoff_date]
			,[store_and_fwd_flag]
			,[RatecodeID]
			,[PULocationID]
			,[DOLocationID]
			,[passenger_count]
			,CASE WHEN fare_amount IS NOT NULL AND trip_distance='0'
				  THEN (CONVERT(FLOAT, fare_amount)-2.50)/2.50    
				  ELSE (CONVERT(FLOAT,trip_distance))
				  END AS trip_distance
			,CASE WHEN trip_distance IS NOT NULL AND [fare_amount] = '0'
				   THEN 2.5 + (CONVERT(FLOAT,trip_distance)*2.5)
				   ELSE (CONVERT(FLOAT, fare_amount))
				   END AS fare_amount
			,[extra]
			,[mta_tax]
			,[tip_amount]
			,[tolls_amount]
			,[improvement_surcharge]
			,[total_amount]
			,[payment_type]
			,[trip_type]
			,[congestion_surcharge]
	FROM conditionFiltering
) temp
