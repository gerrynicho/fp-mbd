-- #6 Kembalikan Stok Makanan [HARUSNYA FUNCTION TAPI KU COBA JADI PROCEDURE]

DELIMITER $$
CREATE PROCEDURE kembalikan_stok_makanan(p_transaksi CHAR(19))
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE makanan_id CHAR(5);
    DECLARE jumlah INT;
    DECLARE cur CURSOR FOR
        SELECT makanan_id_makanan, jumlah
        FROM TRANSAKSI_MAKANAN
        WHERE transaksi_id_transaksi = p_transaksi;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO makanan_id, jumlah;
        IF done THEN
            LEAVE read_loop;
        END IF;
        UPDATE MAKANAN
        SET stok = stok + jumlah
        WHERE id_makanan = makanan_id;
    END LOOP;
    CLOSE cur;
END$$
DELIMITER ;

-- CALL kembalikan_stok_makanan('TRX202506100001');
-- CALL kembalikan_stok_makanan('TRX202506100002');


-- #1 Top 3 makanan terlaris per kategori
DELIMITER $$
CREATE PROCEDURE top_makanan_terlaris_per_kategori()
BEGIN
    SELECT m.klasifikasi, m.nama, SUM(tm.jumlah) AS total_terjual
    FROM MAKANAN m
    JOIN TRANSAKSI_MAKANAN tm ON m.id_makanan = tm.makanan_id_makanan
    GROUP BY m.klasifikasi, m.nama
    ORDER BY total_terjual DESC
    LIMIT 3;
END $$
DELIMITER ;