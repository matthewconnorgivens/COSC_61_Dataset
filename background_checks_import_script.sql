-- Background checks table importation commands and data cleanup queries --

-- Create a table to hold all of the raw data
CREATE TABLE background_checks_uncleaned (
    month date,
    state VARCHAR(255),
    permit INT,
    permit_recheck INT,
    handgun INT,
    long_gun INT,
    other INT,
    multiple INT,
    admin INT,
    prepawn_handgun INT,
    prepawn_long_gun INT,
    prepawn_other INT,
    redemption_handgun INT,
    redemption_long_gun INT,
    redemption_other INT,
    returned_handgun INT,
    returned_long_gun INT,
    returned_other INT,
    rentals_handgun INT,
    rentals_long_gun INT,
    private_sale_handgun INT,
    private_sale_long_gun INT,
    private_sale_other INT,
    return_to_seller_handgun INT,
    return_to_seller_long_gun INT,
    return_to_seller_other INT,
    totals INT
);

-- Load the data into the table from the csv file
LOAD DATA INFILE 'C:/nics-firearm-background-checks.csv' INTO TABLE background_checks_uncleaned
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- Add a primary key to the raw data table to help disperse the data into the various tables
ALTER TABLE background_checks_uncleaned
ADD helper_id INT AUTO_INCREMENT PRIMARY KEY;

-- Fill background_check_data_instance table
INSERT INTO background_check_data_instance (date_state_id, date, state)
SELECT helper_id, month, state
FROM background_checks_uncleaned;


-- Fill permits table
INSERT INTO permits (stat_id, permit, permit_recheck)
SELECT date_state_id, permit, permit_recheck
FROM background_checks_uncleaned
	JOIN background_check_data_instance
		ON date_state_id = helper_id;
        
-- Fill permits_type table
INSERT INTO permit_type (stat_id, handgun, longgun, other, multiple, admin)
SELECT stat_id, handgun, long_gun, other, multiple, admin
FROM background_checks_uncleaned
	JOIN permits
		ON stat_id = helper_id;
        
-- Fill prepawn table
INSERT INTO prepawn (stat_id, handgun, longgun, other)
SELECT date_state_id, prepawn_handgun, prepawn_long_gun, prepawn_other
FROM background_checks_uncleaned
	JOIN background_check_data_instance
		ON date_state_id = helper_id;
        
-- Fill redemption table
INSERT INTO redemption (stat_id, handgun, longgun, other)
SELECT date_state_id, redemption_handgun, redemption_long_gun, redemption_other
FROM background_checks_uncleaned
	JOIN background_check_data_instance
		ON date_state_id = helper_id;


-- Fill returned table
INSERT INTO returned (stat_id, handgun, longgun, other)
SELECT date_state_id, returned_handgun, returned_long_gun, returned_other
FROM background_checks_uncleaned
	JOIN background_check_data_instance
		ON date_state_id = helper_id;

-- Fill rentals table
INSERT INTO rentals (stat_id, handgun, longgun)
SELECT date_state_id, rentals_handgun, rentals_long_gun
FROM background_checks_uncleaned
	JOIN background_check_data_instance
		ON date_state_id = helper_id;

-- Fill private_sale table
INSERT INTO private_sale (stat_id, handgun, longgun, other)
SELECT date_state_id, private_sale_handgun, private_sale_long_gun, private_sale_other
FROM background_checks_uncleaned
	JOIN background_check_data_instance
		ON date_state_id = helper_id;
        
        
-- Fill return to seller table
INSERT INTO return_to_seller (stat_id, handgun, longgun, other)
SELECT date_state_id, return_to_seller_handgun, return_to_seller_long_gun, return_to_seller_other
FROM background_checks_uncleaned
	JOIN background_check_data_instance
		ON date_state_id = helper_id;
        

-- fill totals table
INSERT INTO totals (stat_id, total)
SELECT date_state_id, totals
FROM background_checks_uncleaned
	JOIN background_check_data_instance
		ON date_state_id = helper_id;
       
-- Get rid of uncleaned data table
DROP table background_checks_uncleaned;





