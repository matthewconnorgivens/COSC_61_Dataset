CREATE TABLE `enhancement_table` (
  `case_id` int NOT NULL,
  `latitude` varchar(50) COLLATE utf8mb3_bin DEFAULT NULL,
  `longitude` varchar(50) COLLATE utf8mb3_bin DEFAULT NULL,
  `case_name` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `summary` varchar(500) COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`case_id`),
  CONSTRAINT `enhancement_id` FOREIGN KEY (`case_id`) REFERENCES `shooting_long_lat` (`case_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

INSERT INTO enhancement_table (case_id, latitude, longitude)
SELECT case_id, latitude, longitude
FROM shooting_long_lat;

UPDATE enhancement_table et
JOIN summary s ON et.case_id = s.case_id
SET et.summary = s.summary;

UPDATE enhancement_table et
JOIN shooting s ON et.case_id = s.case_id
SET et.case_name = s.case_name;
