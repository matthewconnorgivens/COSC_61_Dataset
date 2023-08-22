INSERT INTO population (Date, Population)
SELECT date, population
FROM popest;

ALTER TABLE popest
ADD helper_id INT AUTO_INCREMENT PRIMARY KEY;


INSERT INTO population_over_18 (date_id, population_over_18, percent_over_18)
SELECT helper_id, population_over18, cast(pc_over18 as decimal(5,3))
FROM popest
WHERE population_over18 > 1;