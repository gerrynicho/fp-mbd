-- DRAFT : edit transaksi + batal transaksi

-- #4 add transaksi
CREATE PROCEDURE create_transaksi(
    IN p_biaya DECIMAL(10, 2),
    IN p_pelanggan_id CHAR(5),
    IN p_jadwal_tayang_id CHAR(7),
    IN p_teater_id CHAR(5),
    IN promosi_id CHAR(10) DEFAULT NULL,
)
BEGIN
    DECLARE new_transaksi_id CHAR(19);
    DECLARE total DECIMAL(10, 2);

    SET new_transaksi_id = get_next_trx_id();
    SET total = calculate_transaction_total(
        p_biaya, -- subtotal
        2000.00, -- biaya admin
        0, -- diskon, bisa diubah sesuai kebutuhan
        new_transaksi_id 
    );

    INSERT INTO TRANSAKSI (
        id_transaksi,
        total_biaya,
        tanggal_transaksi,
        pelanggan_id_pelanggan,
        jadwal_tayang_id_tayang,
        teater_id_teater
    ) VALUES (
        new_transaksi_id,

END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE create_detil_transaksi(
    IN kursi_id CHAR(4)
)
BEGIN
    DECLARE id_dt CHAR(5);
    DECLARE trx_id CHAR(19);

    -- Ambil ID baru untuk detail transaksi
    SET id_dt = get_next_dt_id();
    SET trx_id = get_current_trx_id();
    
    INSERT INTO DETAIL_TRANSAKSI (
        id_detail_transaksi,
        transaksi_id_transaksi,
        kursi_id_kursi
    ) VALUES (
        id_dt,
        trx_id,
        kursi_id
    );
END$$
DELIMITER ;
-- CALL detil_trx('K001');

DELIMITER $$
CREATE PROCEDURE generate_transaksi_id()
BEGIN
    INSERT INTO TRANSAKSI (
        id_transaksi,
        total_biaya,
        tanggal_transaksi,
        pelanggan_id_pelanggan,
        jadwal_tayang_id_tayang,
        teater_id_teater
    ) VALUES (
        get_next_trx_id(),
        -1.00,
        NOW(),
        'P0001',
        'J001',
        'T001'
    );
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE create_makanan_trx(
    IN id_makanan CHAR(4),
    IN jumlah INT,
    IN catatan VARCHAR(100)
)
BEGIN
    INSERT INTO TRANSAKSI_MAKANAN (
        transaksi_id_transaksi,
        makanan_id_makanan,
        tanggal,
        jumlah,
        catatan
    ) VALUES (
        get_current_trx_id(),
        id_makanan,
        NOW(),
        jumlah,
        catatan
    );
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE create_transaksi_promo(
    IN id_promosi CHAR(10)
)
BEGIN
    INSERT INTO PROMOSI_TRANSAKSI (
        transaksi_id_transaksi,
        promosi_id_promosi
    ) VALUES (
        get_current_trx_id(),
        id_promosi
    );
END$$

DELIMITER ;

DELIMITER $$
CREATE PROCEDURE finalize_transaksi(
    IN pelanggan_id CHAR(5),
    IN jadwal_id CHAR(4),
    IN teater_id CHAR(4)
)
BEGIN
    DECLARE total DECIMAL(10,2);
    DECLARE waktu TIMESTAMP;

    SET waktu = NOW();

    -- Total akhir
    SET total = calculate_transaction_total(get_current_trx_id());

    -- Insert ke TRANSAKSI
    UPDATE TRANSAKSI
    SET
        total_biaya = total,
        tanggal_transaksi = waktu,
        pelanggan_id_pelanggan = pelanggan_id,
        jadwal_tayang_id_tayang = jadwal_id,
        teater_id_teater = teater_id
    WHERE id_transaksi = get_current_trx_id();
END$$
DELIMITER ;
-- CALL add_trx("P0001", "J001", "T001");

-- #3 Pelanggan yang transaksi paling banyak
DELIMITER $$
CREATE PROCEDURE pelanggan_transaksi_terbanyak()
BEGIN
    SELECT p.id_pelanggan, p.nama, COUNT(t.id_transaksi) AS jumlah_transaksi
    FROM PELANGGAN p
    JOIN TRANSAKSI t ON p.id_pelanggan = t.pelanggan_id_pelanggan
    GROUP BY p.id_pelanggan
    ORDER BY jumlah_transaksi DESC
END$$
DELIMITER;