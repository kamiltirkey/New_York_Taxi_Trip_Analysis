
SELECT [VendorID]
      ,[lpep_pickup_datetime]
      ,[lpep_dropoff_datetime]
      ,[store_and_fwd_flag]
      ,[RatecodeID]
      ,[PULocationID]
      ,[DOLocationID]
      ,[passenger_count]
      ,[trip_distance]
      ,[fare_amount]
      ,[extra]
      ,[mta_tax]
      ,[tip_amount]
      ,[tolls_amount]
      ,[improvement_surcharge]
      ,[total_amount]
      ,[payment_type]
      ,[trip_type]
      ,[congestion_surcharge]
	  ,(CASE WHEN [lpep_dropoff_datetime]<[lpep_pickup_datetime] 
		   	 THEN [lpep_dropoff_datetime] 
		 	 ELSE [lpep_pickup_datetime] 
			 END) AS final_pickup_date --If a pickup date/time is AFTER the drop-off date/time, let’s swap them
	  ,(CASE WHEN [lpep_dropoff_datetime]<[lpep_pickup_datetime] 
			 THEN [lpep_pickup_datetime] 
			 ELSE [lpep_dropoff_datetime] 
			 END) AS final_dropoff_date --If a pickup date/time is AFTER the drop-off date/time, let’s swap them

FROM [dbo].[2019_taxi_trips]
WHERE [store_and_fwd_flag] = '"N"' 
AND trip_type = '1' --Let’s stick to trips that were NOT sent via “store and forward”
AND payment_type IN ('1','2') --I’m only interested in street-hailed trips paid by card or cash
AND [RatecodeID] = '1' -- trips paid with a standard rate
AND DATEPART(year, [lpep_pickup_datetime]) BETWEEN '2017' AND '2020' --remove any trips with dates before 2017 or after 2020
AND DATEPART(year, [lpep_dropoff_datetime]) BETWEEN '2017' AND '2020'--remove any trips with dates before 2017 or after 2020
AND  [PULocationID] NOT IN ('264','265') -- removed trips with pickups or drop-offs into unknown zones
AND  [DOLocationID] NOT IN ('264','265') -- removed trips with pickups or drop-offs into unknown zones
AND [passenger_count] NOT IN ('', ' ') AND [passenger_count] IS NOT NULL -- any trips with no recorded passengers had 1 passenger


ORDER BY [lpep_pickup_datetime]

