-- Shootings data table importation commands and data cleanup queries --

-- create table to load the data into
CREATE TABLE Shootings_uncleaned (
    CaseName VARCHAR(255),
    Location VARCHAR(255),
    IncidentDate DATE,
    IncidentYear INT,
    Summary TEXT,
    Fatalities INT,
    Injured INT,
    TotalVictims INT,
    Venue VARCHAR(255),
    PriorMentalHealthIssues VARCHAR(50),
    MentalHealthDetails TEXT,
    WeaponsObtainedLegally VARCHAR(100),
    WhereObtained VARCHAR(255),
    WeaponType TEXT,
    WeaponDetails TEXT,
    SuspectRace VARCHAR(50),
    SuspectGender VARCHAR(20),
    Latitude FLOAT,
    Longitude FLOAT,
    IncidentType VARCHAR(20)
);

-- Load the data into the table from the csv file
LOAD DATA INFILE 'C:\shootings_reconverted.csv' INTO TABLE shootings_uncleaned
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- add primary key id to the uncleaned table
ALTER TABLE shootings_uncleaned
ADD helper_id INT AUTO_INCREMENT PRIMARY KEY;

-- fill shooting table
INSERT INTO shooting (case_id, case_name)
SELECT helper_id, CaseName
FROM shootings_uncleaned;

-- fill summary table
INSERT INTO summary (case_id, summary, type)
SELECT case_id, Summary, IncidentType
FROM shootings_uncleaned
	JOIN shooting
		ON case_id = helper_id;

-- fill victims table
INSERT INTO victims (case_id, fatalaties, injured, total_victims)
SELECT case_id, Fatalities, Injured, TotalVictims
FROM shootings_uncleaned
	JOIN shooting
		ON case_id = helper_id;
        
        
-- fill shooting situational attributes table
INSERT INTO shooting_situational_attributes (`case_id`, `date`, `location`, `venue`)
SELECT case_id, IncidentDate, Location, Venue
FROM shootings_uncleaned
	JOIN shooting
		ON case_id = helper_id;
        
        
-- fill shooting situational attributes table
INSERT INTO shooting_long_lat (`case_id`, `longitude`, `latitude`)
SELECT `case_id`, `Longitude`, `Latitude`
FROM shootings_uncleaned
	JOIN shooting
		ON case_id = helper_id;
        
-- remove tuples where the longitude and latitude are unknown
DELETE FROM shooting_long_lat
WHERE longitude = 0;

-- fill weapons table
INSERT INTO weapon_details (`case_id`, `obtained_legally`, `where_obtained`, `weapon_type`, `extended_details`)
SELECT `case_id`, `WeaponsObtainedLegally`, `WhereObtained`, `WeaponType`, `WeaponDetails`
FROM shootings_uncleaned
	JOIN shooting
		ON case_id = helper_id;

-- fill mental health table        
INSERT INTO mental_health (`case_id`, `prior_signs_reported`, `has_details`)
SELECT `case_id`, PriorMentalHealthIssues, 'yes'
FROM shootings_uncleaned
	JOIN shooting
		ON case_id = helper_id;      

-- fill mental health details table
INSERT INTO mental_health_details (`case_id`, `mental_health_detailscol`)
SELECT `case_id`, MentalHealthDetails
FROM shootings_uncleaned
	JOIN shooting
		ON case_id = helper_id; 

-- clear tuples from mental health details that don't have any details
DELETE FROM mental_health_details
WHERE mental_health_detailscol = 'Unclear';

-- update mental_health table to show whether or not a case has mental health details avaliable
UPDATE mental_health
SET `has_details` = 'no'
WHERE `has_details` = 'yes'
AND case_id NOT IN (SELECT case_id FROM mental_health_details);



-- fill perpetrator table        
INSERT INTO perpetrator (`case_id`, `shooter_number`)
SELECT `case_id`, 1
FROM shootings_uncleaned
	JOIN shooting
		ON case_id = helper_id; 
        
-- fill perpetrator table        
INSERT INTO perpetrator_details (`case_id`, `shooter_number`, `race`, `gender`)
SELECT `case_id`, shooter_number, SuspectRace, SuspectGender
FROM shootings_uncleaned
	JOIN perpetrator
		ON case_id = helper_id; 

-- drop the uncleaned data table
DROP TABLE shootings_uncleaned;
        
