-- Authentication Functions and Procedures
-- Add these to your function.sql file

-- Function to hash password (simple example - in production use bcrypt)
DELIMITER $$
CREATE FUNCTION hash_password(plain_password VARCHAR(50))
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    -- Simple hash using SHA2 (in production, use proper bcrypt)
    RETURN SHA2(CONCAT(plain_password, 'cinema_salt'), 256);
END$$
DELIMITER ;

-- Function to verify password
DELIMITER $$
CREATE FUNCTION verify_password(plain_password VARCHAR(50), hashed_password VARCHAR(100))
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    RETURN hashed_password = hash_password(plain_password);
END$$
DELIMITER ;

-- Function to generate session token (simple UUID-like)
DELIMITER $$
CREATE FUNCTION generate_token()
RETURNS VARCHAR(128)
BEGIN
    RETURN CONCAT(
        UUID(), 
        '-', 
        UNIX_TIMESTAMP(), 
        '-', 
        SUBSTRING(MD5(RAND()), 1, 8)
    );
END$$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION cek_membership(p_id CHAR(5))
RETURNS BOOLEAN
BEGIN
    DECLARE status BOOL;
    SELECT EXISTS (
        SELECT 1 
        FROM MEMBERSHIP 
        WHERE pelanggan_id_pelanggan = p_id
    ) INTO status;

    RETURN status;
END$$
DELIMITER ;
-- SELECT cek_membership('P0001') AS status_membership;
-- SELECT cek_membership('P0025') AS status_membership;