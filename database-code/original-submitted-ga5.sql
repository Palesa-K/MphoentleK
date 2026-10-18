-- Original 2025 submitted coursework SQL, preserved for reference.
-- It assumes CapeTownMaintenance already exists and includes a JOIN
-- on a column not defined in MaintenanceRequests. See portfolio-replay.sql
-- for an independently runnable sample using the same nine request rows.

show databases;
use CapeTownMaintenance;
CREATE TABLE MaintenanceRequests (
    request_id INT AUTO_INCREMENT PRIMARY KEY,
    type VARCHAR(50),         
    description VARCHAR(255),
    location VARCHAR(100),
    status VARCHAR(50),        
    reported_date DATE
);
INSERT INTO MaintenanceRequests (type, description, location, status, reported_date)
VALUES
('Burst Pipe', 'Pipe burst on Main Road', 'Zone 1', 'Pending', '2025-09-01'),
('Pothole', 'Large pothole near taxi rank', 'Zone 3', 'Pending', '2025-08-28'),
('Faulty Streetlight', 'Streetlight not working', 'Zone 4', 'Completed', '2025-09-25'),
('Pothole', 'Small pothole in residential street', 'Zone 1', 'Pending', '2025-09-12'),
('Burst Pipe', 'Water leak near hospital', 'Zone 2', 'Pending', '2025-09-14'),
('Burst Pipe', 'Low water pressure', 'Zone 3', 'Completed', '2025-09-09'),
('Faulty Streetlight', 'Power outage in a neighbourhood', 'Zone 1', 'Pending', '2025-09-16'),
('Faulty Streetlight', 'Damaged electrical substation', 'Zone 3', 'Completed', '2025-09-20'),
('Public Toilets', 'Broken public toilet facilities', 'Zone 4', 'Pending', '2025-08-14');
SELECT * FROM MaintenanceRequests;
CREATE TABLE Locations (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    zone VARCHAR(50) NOT NULL
);
CREATE TABLE ServiceTeams (
    team_id INT AUTO_INCREMENT PRIMARY KEY,
    team_name VARCHAR(100) NOT NULL,
    specialty VARCHAR(100) NOT NULL
);
CREATE TABLE Assets (
    asset_id INT AUTO_INCREMENT PRIMARY KEY,
    asset_type VARCHAR(100) NOT NULL,
    status VARCHAR(50) NOT NULL,
    location_id INT,
    FOREIGN KEY (location_id) REFERENCES Locations(location_id)
);
INSERT INTO Locations (name, zone) VALUES
('Main Road', 'Zone 1'),
('Hospital Area', 'Zone 2'),
('Taxi Rank', 'Zone 3'),
('Residential Area', 'Zone 1'),
('Substation Area', 'Zone 3'),
('Neighbourhood A', 'Zone 1'),
('Public Park', 'Zone 4');
INSERT INTO ServiceTeams (team_name, specialty) VALUES
('Water Management Team', 'Water'),
('Roads and Transport Team', 'Roads'),
('Electrical Team', 'Electricity'),
('Sanitation Team', 'Public Facilities');
INSERT INTO Assets (asset_type, status, location_id) VALUES
('Pipe', 'Damaged', 1),    
('Pipe', 'Leaking', 2),    
('Road', 'Damaged', 3),    
('Road', 'Damaged', 4),   
('Streetlight', 'Not working', 7), 
('Substation', 'Damaged', 5),     
('Toilet', 'Broken', 7);          
SELECT * FROM Locations;
SELECT * FROM ServiceTeams;
SELECT * FROM Assets;
SELECT L.zone, COUNT(*) AS pending_issues
FROM MaintenanceRequests MR
JOIN Locations L ON MR.location_id = L.location_id
WHERE MR.status = 'Pending'
GROUP BY L.zone
ORDER BY pending_issues DESC;
SELECT location, COUNT(*) AS pending_issues
FROM MaintenanceRequests
WHERE status = 'Pending'
GROUP BY location
ORDER BY pending_issues DESC;
SELECT status, COUNT(*) AS total_requests
FROM MaintenanceRequests
GROUP BY status
ORDER BY total_requests DESC;
SELECT type, COUNT(*) AS issue_count
FROM MaintenanceRequests
GROUP BY type
ORDER BY issue_count DESC;
SELECT request_id, type, description, status, reported_date, location
FROM MaintenanceRequests
WHERE status = 'Completed'
  AND reported_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);
SELECT request_id, type, description, location, reported_date
FROM MaintenanceRequests
WHERE status = 'Pending'
  AND reported_date < DATE_SUB(CURDATE(), INTERVAL 14 DAY);





