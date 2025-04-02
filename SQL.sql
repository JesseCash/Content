-- Create the database
CREATE DATABASE db_rolsa;
USE db_rolsa;

-- Create the EV Stations table
CREATE TABLE EV_Stations (
    StationID INT AUTO_INCREMENT PRIMARY KEY,
    StationName VARCHAR(255) NOT NULL,
    StationLatitude DECIMAL(10, 6) NOT NULL,
    StationLongitude DECIMAL(10, 6) NOT NULL,
    StationAvailability ENUM('Spaces', 'No Spaces') NOT NULL,
    StationAppPayment BOOLEAN NOT NULL,
    ConnectorTypes VARCHAR(255) NOT NULL,
    OperatingHours VARCHAR(50) NOT NULL,
    AdditionalFacilities VARCHAR(255) NOT NULL
);

-- Insert sample EV charging stations in Warrington, Manchester, and Liverpool
INSERT INTO EV_Stations (StationName, StationLatitude, StationLongitude, StationAvailability, StationAppPayment, ConnectorTypes, OperatingHours, AdditionalFacilities) VALUES
('Warrington Central Station', 53.390045, -2.596950, 'Spaces', 1, 'CCS, Type 2', '24/7', 'Café, Restroom, Wi-Fi'),
('Golden Square Shopping Centre', 53.388300, -2.596200, 'No Spaces', 1, 'CCS, CHAdeMO', '07:00-23:00', 'Shops, Restroom'),
('Stockton Heath Car Park', 53.374600, -2.580000, 'Spaces', 0, 'Type 2', '24/7', 'Restroom'),
('Manchester Piccadilly', 53.477500, -2.231900, 'Spaces', 1, 'CCS, CHAdeMO', '24/7', 'Café, Wi-Fi'),
('Trafford Centre', 53.465300, -2.349200, 'No Spaces', 1, 'CCS, Type 2', '06:00-00:00', 'Shops, Restroom, Wi-Fi'),
('Liverpool One Car Park', 53.403900, -2.985200, 'Spaces', 1, 'CCS, CHAdeMO', '24/7', 'Café, Shops, Wi-Fi'),
('Albert Dock Charging Hub', 53.401000, -2.995600, 'Spaces', 0, 'Type 2', '08:00-22:00', 'Café, Restroom');

-- Verify data
SELECT * FROM EV_Stations;

-- Create a stored procedure to find nearby EV stations using bounding box
DELIMITER //
CREATE PROCEDURE GetNearbyStations(
    IN userLat DECIMAL(10,6),
    IN userLng DECIMAL(10,6),
    IN rangeKm DECIMAL(10,6)
)
BEGIN
    DECLARE latDiff DECIMAL(10,6);
    DECLARE lngDiff DECIMAL(10,6);
    
    SET latDiff = rangeKm / 111.32; -- Rough conversion for latitude degrees
    SET lngDiff = rangeKm / (111.32 * COS(RADIANS(userLat))); -- Adjust for longitude
    
    SELECT *, 
           (6371 * ACOS(
               COS(RADIANS(userLat)) * COS(RADIANS(StationLatitude)) * 
               COS(RADIANS(StationLongitude) - RADIANS(userLng)) + 
               SIN(RADIANS(userLat)) * SIN(RADIANS(StationLatitude))
           )) AS distance
    FROM EV_Stations
    WHERE StationLatitude BETWEEN (userLat - latDiff) AND (userLat + latDiff)
    AND StationLongitude BETWEEN (userLng - lngDiff) AND (userLng + lngDiff)
    HAVING distance <= rangeKm
    ORDER BY distance ASC;
END //
DELIMITER ;
