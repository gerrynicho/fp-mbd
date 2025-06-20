DELIMITER $$

CREATE PROCEDURE RegisterUser(
    IN p_id CHAR(5),
    IN p_nama VARCHAR(50),
    IN p_telepon VARCHAR(15),
    IN p_password VARCHAR(50)
)
BEGIN
    INSERT INTO PELANGGAN (id_pelanggan, nama, no_telepon, pass)
    VALUES (p_id, p_nama, p_telepon, p_password);
END$$

DELIMITER ;
