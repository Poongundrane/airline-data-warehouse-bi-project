USE [Airline_DW]
GO
/****** Object:  Table [dbo].[Airline_Staging]    Script Date: 09-04-2026 22:34:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Airline_Staging](
	[year] [int] NULL,
	[month] [int] NULL,
	[carrier] [varchar](50) NULL,
	[carrier_name] [varchar](100) NULL,
	[airport] [varchar](50) NULL,
	[airport_name] [varchar](255) NULL,
	[arr_flights] [float] NULL,
	[arr_del15] [int] NULL,
	[carrier_ct] [float] NULL,
	[weather_ct] [float] NULL,
	[nas_ct] [float] NULL,
	[security_ct] [float] NULL,
	[late_aircraft_ct] [float] NULL,
	[arr_cancelled] [int] NULL,
	[arr_diverted] [int] NULL,
	[arr_delay] [float] NULL,
	[carrier_delay] [float] NULL,
	[weather_delay] [float] NULL,
	[nas_delay] [float] NULL,
	[security_delay] [float] NULL,
	[late_aircraft_delay] [float] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Arrival_Fact]    Script Date: 09-04-2026 22:34:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Arrival_Fact](
	[FactKey] [int] IDENTITY(1,1) NOT NULL,
	[DateKey] [int] NULL,
	[CarrierKey] [int] NULL,
	[AirportKey] [int] NULL,
	[arr_flights] [float] NULL,
	[arr_del15] [float] NULL,
	[carrier_ct] [float] NULL,
	[weather_ct] [float] NULL,
	[nas_ct] [float] NULL,
	[security_ct] [float] NULL,
	[late_aircraft_ct] [float] NULL,
	[arr_cancelled] [float] NULL,
	[arr_diverted] [float] NULL,
	[arr_delay] [float] NULL,
	[carrier_delay] [float] NULL,
	[weather_delay] [float] NULL,
	[nas_delay] [float] NULL,
	[security_delay] [float] NULL,
	[late_aircraft_delay] [float] NULL,
PRIMARY KEY CLUSTERED 
(
	[FactKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Dim_Airport]    Script Date: 09-04-2026 22:34:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dim_Airport](
	[AirportKey] [int] IDENTITY(1,1) NOT NULL,
	[AirportCode] [varchar](10) NULL,
	[AirportName] [varchar](150) NULL,
PRIMARY KEY CLUSTERED 
(
	[AirportKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Dim_Carrier]    Script Date: 09-04-2026 22:34:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dim_Carrier](
	[CarrierKey] [int] IDENTITY(1,1) NOT NULL,
	[CarrierCode] [varchar](10) NULL,
	[CarrierName] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[CarrierKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Dim_Date]    Script Date: 09-04-2026 22:34:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dim_Date](
	[DateKey] [int] IDENTITY(1,1) NOT NULL,
	[Year] [int] NULL,
	[Month] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[DateKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Arrival_Fact]  WITH CHECK ADD FOREIGN KEY([AirportKey])
REFERENCES [dbo].[Dim_Airport] ([AirportKey])
GO
ALTER TABLE [dbo].[Arrival_Fact]  WITH CHECK ADD FOREIGN KEY([CarrierKey])
REFERENCES [dbo].[Dim_Carrier] ([CarrierKey])
GO
ALTER TABLE [dbo].[Arrival_Fact]  WITH CHECK ADD FOREIGN KEY([DateKey])
REFERENCES [dbo].[Dim_Date] ([DateKey])
GO
/****** Object:  StoredProcedure [dbo].[sp_AirportPerformance_Report2]    Script Date: 09-04-2026 22:34:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_AirportPerformance_Report2]
AS
BEGIN
    SELECT 
        a.AirportCode AS Airport,
        a.AirportName,
        SUM(f.arr_flights) AS TotalFlights,
        SUM(f.arr_del15) AS TotalDelays,
        SUM(f.carrier_ct) AS CarrierDelays,
        SUM(f.weather_ct) AS WeatherDelays,
        SUM(f.nas_ct) AS NASDelays,
        SUM(f.late_aircraft_ct) AS LateAircraftDelays
    FROM dbo.Arrival_Fact f
    JOIN dbo.Dim_Airport a 
        ON f.AirportKey = a.AirportKey
    GROUP BY 
        a.AirportCode,
        a.AirportName
    ORDER BY 
        TotalDelays DESC;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_FlightSummaryByCarrier_Report1]    Script Date: 09-04-2026 22:34:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_FlightSummaryByCarrier_Report1]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.CarrierName,
        d.Year,
        d.Month,
        SUM(f.arr_flights) AS TotalFlights,
        SUM(f.arr_del15) AS FlightsDelayed,
        SUM(f.arr_cancelled) AS CancelledFlights,
        SUM(f.arr_diverted) AS DivertedFlights,
        SUM(f.arr_delay) AS TotalDelayMinutes,

        CAST(SUM(f.arr_del15) AS FLOAT) / 
        NULLIF(SUM(f.arr_flights), 0) AS PctFlightsDelayed

    FROM dbo.Arrival_Fact f
    INNER JOIN dbo.Dim_Carrier c 
        ON f.CarrierKey = c.CarrierKey
    INNER JOIN dbo.Dim_Date d 
        ON f.DateKey = d.DateKey
    GROUP BY c.CarrierName, d.Year, d.Month
    ORDER BY d.Year, d.Month, c.CarrierName;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_MonthlyTrends_Report4]    Script Date: 09-04-2026 22:34:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_MonthlyTrends_Report4]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        d.Year,
        d.Month,
        SUM(f.arr_flights) AS TotalFlights,
        SUM(f.arr_del15) AS TotalDelays,
        SUM(f.carrier_ct) AS CarrierDelays,
        SUM(f.weather_ct) AS WeatherDelays,
        SUM(f.nas_ct) AS NASDelays,
        SUM(f.late_aircraft_ct) AS LateAircraftDelays
    FROM dbo.Arrival_Fact f
    JOIN dbo.Dim_Date d
        ON f.DateKey = d.DateKey
    GROUP BY 
        d.Year,
        d.Month
    ORDER BY 
        d.Year ASC,  -- sorts by year numerically
        d.Month ASC; -- sorts by month numerically
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_Top10Worst_Report3]    Script Date: 09-04-2026 22:34:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Create the stored procedure
CREATE PROCEDURE [dbo].[sp_Top10Worst_Report3]
AS
BEGIN
    SET NOCOUNT ON;

    -- Select the top 10 airports with highest total delays
    SELECT TOP 10
        a.AirportCode AS Airport,
        a.AirportName,
        SUM(f.arr_flights) AS TotalFlights,
        SUM(f.arr_del15) AS TotalDelays,
        SUM(f.carrier_ct) AS CarrierDelays,
        SUM(f.weather_ct) AS WeatherDelays,
        SUM(f.nas_ct) AS NASDelays,
        SUM(f.late_aircraft_ct) AS LateAircraftDelays
    FROM dbo.Arrival_Fact f
    JOIN dbo.Dim_Airport a
        ON f.AirportKey = a.AirportKey
    GROUP BY
        a.AirportCode,
        a.AirportName
    ORDER BY
        TotalDelays DESC;
END;
GO
