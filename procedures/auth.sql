-- Simplified Registration Procedure (no membership required)
DELIMITER $$
CREATE PROCEDURE user_register(
    IN p_nama VARCHAR(50),
    IN p_no_telepon VARCHAR(15),
    IN p_password VARCHAR(50),
    OUT p_result VARCHAR(20),
    OUT p_message VARCHAR(100),
    OUT p_user_id CHAR(5)
)
BEGIN
    DECLARE user_exists INT DEFAULT 0;
    DECLARE new_pelanggan_id CHAR(5);
    DECLARE hashed_pass VARCHAR(100);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result = 'ERROR';
        SET p_message = 'Registration failed due to database error';
        SET p_user_id = NULL;
    END;
    
    -- Validation FIRST - check if phone number already exists
    SELECT COUNT(*) INTO user_exists 
    FROM PELANGGAN 
    WHERE no_telepon = p_no_telepon;
    
    IF user_exists > 0 THEN
        SET p_result = 'ERROR';
        SET p_message = 'Phone number already registered';
        SET p_user_id = NULL;
    ELSE
        -- Start transaction for actual data modification
        START TRANSACTION;
        
        -- Generate new ID
        SET new_pelanggan_id = get_next_pelanggan_id();
        
        -- Hash password
        SET hashed_pass = hash_password(p_password);
        
        -- Insert into PELANGGAN only
        INSERT INTO PELANGGAN (
            id_pelanggan, 
            nama, 
            no_telepon, 
            pass
        ) VALUES (
            new_pelanggan_id,
            p_nama,
            p_no_telepon,
            hashed_pass
        );
        
        SET p_result = 'SUCCESS';
        SET p_message = 'User registered successfully';
        SET p_user_id = new_pelanggan_id;
        
        COMMIT;
    END IF;
END$$
DELIMITER ;

-- Updated Login Procedure (login with phone number instead of email)
DELIMITER $$
CREATE PROCEDURE user_login(
    IN p_no_telepon VARCHAR(15),
    IN p_password VARCHAR(50),
    OUT p_result VARCHAR(20),
    OUT p_message VARCHAR(100),
    OUT p_token VARCHAR(128),
    OUT p_user_data JSON
)
BEGIN
    DECLARE user_count INT DEFAULT 0;
    DECLARE stored_password VARCHAR(100);
    DECLARE user_id CHAR(5);
    DECLARE user_name VARCHAR(50);
    DECLARE user_phone VARCHAR(15);
    DECLARE new_token VARCHAR(128);
    
    -- Check if user exists
    SELECT COUNT(*), 
           pass, 
           id_pelanggan, 
           nama, 
           no_telepon
    INTO user_count, stored_password, user_id, user_name, user_phone
    FROM PELANGGAN
    WHERE no_telepon = p_no_telepon
    LIMIT 1;
    
    IF user_count = 0 THEN
        SET p_result = 'ERROR';
        SET p_message = 'Phone number not found';
        SET p_token = NULL;
        SET p_user_data = NULL;
    ELSEIF NOT verify_password(p_password, stored_password) THEN
        SET p_result = 'ERROR';
        SET p_message = 'Invalid password';
        SET p_token = NULL;
        SET p_user_data = NULL;
    ELSE
        -- Generate token
        SET new_token = generate_token();
        
        -- Store token in sessions table
        INSERT INTO USER_SESSIONS (token, id_pelanggan, expires_at)
        VALUES (new_token, user_id, DATE_ADD(NOW(), INTERVAL 7 DAY));
        
        -- Prepare user data as JSON
        SET p_user_data = JSON_OBJECT(
            'id', user_id,
            'name', user_name,
            'phone', user_phone
        );
        
        SET p_result = 'SUCCESS';
        SET p_message = 'Login successful';
        SET p_token = new_token;
    END IF;
END$$
DELIMITER ;

-- Updated Get User Profile (for phone-based auth)
DELIMITER $$
CREATE PROCEDURE get_user_profile(
    IN p_token VARCHAR(128),
    OUT p_result VARCHAR(20),
    OUT p_message VARCHAR(100),
    OUT p_user_data JSON
)
BEGIN
    -- Simple token validation (in production, use proper session management)
    IF LENGTH(p_token) < 20 THEN
        SET p_result = 'ERROR';
        SET p_message = 'Invalid token';
        SET p_user_data = NULL;
    ELSE
        -- For demo, return first user (in production, decode token properly)
        SELECT JSON_OBJECT(
            'id', id_pelanggan,
            'name', nama,
            'phone', no_telepon
        )
        INTO p_user_data
        FROM PELANGGAN
        LIMIT 1;
        
        SET p_result = 'SUCCESS';
        SET p_message = 'Profile retrieved successfully';
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE get_user_by_token(
    IN p_token VARCHAR(128),
    OUT p_result VARCHAR(20),
    OUT p_message VARCHAR(100),
    OUT p_user_data JSON
)
BEGIN
    DECLARE user_count INT DEFAULT 0;
    DECLARE user_id CHAR(5);
    DECLARE user_name VARCHAR(50);
    DECLARE user_phone VARCHAR(15);
    DECLARE token_expired BOOLEAN DEFAULT FALSE;
    
    -- Check if token exists and is valid
    SELECT COUNT(*), 
           s.id_pelanggan,
           p.nama,
           p.no_telepon,
           (s.expires_at < NOW()) as is_expired
    INTO user_count, user_id, user_name, user_phone, token_expired
    FROM USER_SESSIONS s
    JOIN PELANGGAN p ON s.id_pelanggan = p.id_pelanggan
    WHERE s.token = p_token 
      AND s.is_active = TRUE
    LIMIT 1;
    
    IF user_count = 0 THEN
        SET p_result = 'ERROR';
        SET p_message = 'Invalid or expired token';
        SET p_user_data = NULL;
    ELSEIF token_expired THEN
        -- Deactivate expired token
        UPDATE USER_SESSIONS 
        SET is_active = FALSE 
        WHERE token = p_token;
        
        SET p_result = 'ERROR';
        SET p_message = 'Token has expired';
        SET p_user_data = NULL;
    ELSE
        -- Update last activity
        UPDATE USER_SESSIONS 
        SET created_at = NOW() 
        WHERE token = p_token;
        
        -- Prepare user data as JSON
        SET p_user_data = JSON_OBJECT(
            'id', user_id,
            'name', user_name,
            'phone', user_phone
        );
        
        SET p_result = 'SUCCESS';
        SET p_message = 'User profile retrieved successfully';
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE user_logout(
    IN p_token VARCHAR(128),
    OUT p_result VARCHAR(20),
    OUT p_message VARCHAR(100)
)
BEGIN
    DECLARE token_count INT DEFAULT 0;
    
    -- Check if token exists
    SELECT COUNT(*) INTO token_count
    FROM USER_SESSIONS
    WHERE token = p_token AND is_active = TRUE;
    
    IF token_count = 0 THEN
        SET p_result = 'ERROR';
        SET p_message = 'Token not found';
    ELSE
        -- Deactivate the token
        UPDATE USER_SESSIONS 
        SET is_active = FALSE 
        WHERE token = p_token;
        
        SET p_result = 'SUCCESS';
        SET p_message = 'Logout successful';
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE get_pelanggan_with_membership(
    IN p_id_pelanggan CHAR(5),
    OUT p_result VARCHAR(20),
    OUT p_message VARCHAR(100),
    OUT p_user_data JSON
)
BEGIN
    DECLARE user_count INT DEFAULT 0;
    DECLARE has_membership BOOLEAN DEFAULT FALSE;
    
    -- Check if user exists
    SELECT COUNT(*) INTO user_count
    FROM PELANGGAN
    WHERE id_pelanggan = p_id_pelanggan;
    
    IF user_count = 0 THEN
        SET p_result = 'ERROR';
        SET p_message = 'User not found';
        SET p_user_data = NULL;
    ELSE
        -- Check if user has membership
        SET has_membership = cek_membership(p_id_pelanggan);
        
        IF has_membership THEN
            -- Return all data from PELANGGAN and MEMBERSHIP (except IDs)
            SELECT JSON_OBJECT(
                'nama', p.nama,
                'no_telepon', p.no_telepon,
                'email', m.email,
                'jenis_kelamin', m.jenis_kelamin,
                'tanggal_lahir', m.tanggal_lahir,
                'poin', m.poin,
                'has_membership', TRUE
            ) INTO p_user_data
            FROM PELANGGAN p
            JOIN MEMBERSHIP m ON p.id_pelanggan = m.pelanggan_id_pelanggan
            WHERE p.id_pelanggan = p_id_pelanggan;
        ELSE
            -- Return only name and phone number
            SELECT JSON_OBJECT(
                'nama', p.nama,
                'no_telepon', p.no_telepon,
                'has_membership', FALSE
            ) INTO p_user_data
            FROM PELANGGAN p
            WHERE p.id_pelanggan = p_id_pelanggan;
        END IF;
        
        SET p_result = 'SUCCESS';
        SET p_message = 'User data retrieved successfully';
    END IF;
END$$
DELIMITER ;