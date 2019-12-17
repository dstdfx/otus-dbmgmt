USE otusdb;

LOAD DATA INFILE '/var/lib/mysql-files/countries.csv'
    INTO TABLE countries
    FIELDS TERMINATED BY ','
    ENCLOSED BY '\"'
    LINES TERMINATED BY '\n'
    (@id, @created_at, @updated_at, @deleted_at, name)
    SET id = UUID_TO_BIN(@id),
        created_at = IF(@created_at = '', NULL, CAST(@created_at AS DATETIME)),
        updated_at = IF(@updated_at = '', NULL, CAST(@updated_at AS DATETIME)),
        deleted_at = IF(@deleted_at = '', NULL, CAST(@deleted_at AS DATETIME));
