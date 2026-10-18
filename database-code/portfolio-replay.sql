-- PORTFOLIO REPLAY: adapted from Mphoentle Keikabile's 2025 GA5 SQL assignment.
-- This is a standalone, locally runnable reconstruction for demonstrating the project.
-- It is not the unmodified submitted script and is NOT connected to any city database.
-- Use an isolated, empty MySQL instance; repeat runs will insert duplicate example rows.
CREATE DATABASE IF NOT EXISTS CapeTownMaintenancePortfolio;
USE CapeTownMaintenancePortfolio;

CREATE TABLE IF NOT EXISTS Locations (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    zone VARCHAR(50) NOT NULL
);
CREATE TABLE IF NOT EXISTS ServiceTeams (
    team_id INT AUTO_INCREMENT PRIMARY KEY,
    team_name VARCHAR(100) NOT NULL,
    specialty VARCHAR(100) NOT NULL
);
CREATE TABLE IF NOT EXISTS Assets (
    asset_id INT AUTO_INCREMENT PRIMARY KEY,
    asset_type VARCHAR(100) NOT NULL,
    status VARCHAR(50) NOT NULL,
    location_id INT,
    FOREIGN KEY (location_id) REFERENCES Locations(location_id)
);
CREATE TABLE IF NOT EXISTS MaintenanceRequests (
    request_id INT AUTO_INCREMENT PRIMARY KEY,
    type VARCHAR(50), description VARCHAR(255),
    location VARCHAR(100), status VARCHAR(50), reported_date DATE
);

INSERT INTO Locations (name,zone) VALUES
('Main Road','Zone 1'), ('Hospital Area','Zone 2'), ('Taxi Rank','Zone 3'),
('Residential Area','Zone 1'), ('Substation Area','Zone 3'),
('Neighbourhood A','Zone 1'), ('Public Park','Zone 4');
INSERT INTO ServiceTeams (team_name,specialty) VALUES
('Water Management Team','Water'), ('Roads and Transport Team','Roads'),
('Electrical Team','Electricity'), ('Sanitation Team','Public Facilities');
INSERT INTO Assets (asset_type,status,location_id) VALUES
('Pipe','Damaged',1), ('Pipe','Leaking',2), ('Road','Damaged',3),
('Road','Damaged',4), ('Streetlight','Not working',7),
('Substation','Damaged',5), ('Toilet','Broken',7);
INSERT INTO MaintenanceRequests (type,description,location,status,reported_date) VALUES
('Burst Pipe','Pipe burst on Main Road','Zone 1','Pending','2025-09-01'),
('Pothole','Large pothole near taxi rank','Zone 3','Pending','2025-08-28'),
('Faulty Streetlight','Streetlight not working','Zone 4','Completed','2025-09-25'),
('Pothole','Small pothole in residential street','Zone 1','Pending','2025-09-12'),
('Burst Pipe','Water leak near hospital','Zone 2','Pending','2025-09-14'),
('Burst Pipe','Low water pressure','Zone 3','Completed','2025-09-09'),
('Faulty Streetlight','Power outage in a neighbourhood','Zone 1','Pending','2025-09-16'),
('Faulty Streetlight','Damaged electrical substation','Zone 3','Completed','2025-09-20'),
('Public Toilets','Broken public toilet facilities','Zone 4','Pending','2025-08-14');

-- Queries adapted to match the implemented schema.
SELECT location AS zone, COUNT(*) AS pending_requests
FROM MaintenanceRequests WHERE status='Pending'
GROUP BY location ORDER BY pending_requests DESC,zone;
SELECT status, COUNT(*) AS request_count FROM MaintenanceRequests GROUP BY status;
SELECT type, COUNT(*) AS issue_count FROM MaintenanceRequests
GROUP BY type ORDER BY issue_count DESC,type;
-- Anchor historical 2025 reporting to a 2025 review date, rather than today's date.
SELECT * FROM MaintenanceRequests
WHERE status='Pending' AND reported_date < DATE_SUB('2025-10-01',INTERVAL 14 DAY);
SELECT * FROM MaintenanceRequests
WHERE status='Completed' AND reported_date >= DATE_SUB('2025-10-01',INTERVAL 30 DAY);
-- A valid JOIN where a foreign key exists in the submitted table definitions.
SELECT A.asset_id, A.asset_type, A.status, L.name AS location_name, L.zone
FROM Assets A JOIN Locations L ON A.location_id=L.location_id;
