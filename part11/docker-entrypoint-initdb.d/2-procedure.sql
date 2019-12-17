USE otusdb;

DROP PROCEDURE IF EXISTS update_customer_email_with_log;
DELIMITER //

CREATE PROCEDURE update_customer_email_with_log(
    customer_id BINARY(16),
    new_email VARCHAR(255))
BEGIN
    -- Rollback tx in case of errors
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
        END;

    -- Transaction body
    START TRANSACTION;

    -- Extract old customer's email
    SELECT email INTO @old_email FROM customers WHERE customers.id = customer_id;

    -- Update customer email
    UPDATE customers
    SET customers.email = new_email
    WHERE customers.id = customer_id;

    -- Store log info
    INSERT INTO `log_actions` (id, customer_id, operation, description)
    VALUES (UUID_TO_BIN(UUID()),
            customer_id,
            'CHANGE_PERSONAL_INFO',
            CONCAT('Customer has changed email',' ','from:',' ',@old_email,' ','to:',' ', new_email));
    COMMIT;
END //

DELIMITER ;
