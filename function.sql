-- HITUNG PELANGGAN HARI INI
DELIMITER $$
CREATE FUNCTION hitung_pelanggan_hari_ini(p_date DATE) 
RETURNS INTEGER  
DETERMINISTIC
BEGIN 
    DECLARE jumlah_pelanggan_hari_ini INT;

    SELECT COUNT(DISTINCT pelanggan_id_pelanggan)
    INTO jumlah_pelanggan_hari_ini
    FROM TRANSAKSI t
    WHERE DATE(t.tanggal_transaksi) = current_date;

    RETURN jumlah_pelanggan_hari_ini;
END $$
DELIMITER ;


-- #1 CEK MEMBERSHIP PELANGGAN [DONE]
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

--  #2 CEK MASA BERLAKU MEMBERSHIP [DONE]
DELIMITER $$
CREATE FUNCTION promosi_masih_berlaku(p_id CHAR(10))
RETURNS BOOLEAN
BEGIN
    DECLARE status BOOL DEFAULT FALSE;

    SELECT 
        (CURDATE() BETWEEN tanggal_mulai AND tanggal_berakhir)
    INTO 
        status
    FROM 
        PROMOSI
    WHERE 
        id_promosi = p_id;

    RETURN IFNULL(status, FALSE);
END$$
DELIMITER ;
-- SELECT promosi_masih_berlaku('PR001') AS masih_berlaku;
-- SELECT promosi_masih_berlaku('PR014') AS masih_berlaku;

-- #3 Hitung Total Penggunaan Promosi [DONE]
DELIMITER $$
CREATE FUNCTION total_penggunaan_promosi(p_id CHAR(10))
RETURNS INT
BEGIN
    DECLARE total INT DEFAULT 0;

    SELECT COUNT(*) 
    INTO total
    FROM PROMOSI_TRANSAKSI
    WHERE promosi_id_promosi = p_id;

    RETURN total;
END$$
DELIMITER ;
-- INSERT INTO PROMOSI_TRANSAKSI VALUES
-- ('TRX202506100002','PR014'),
-- ('TRX202506110001','PR014'),
-- ('TRX202506120001','PR014'),
-- ('TRX202506130001','PR011');
-- SELECT total_penggunaan_promosi('PR014') AS jumlah_penggunaan;
-- SELECT total_penggunaan_promosi('PR011') AS jumlah_penggunaan;

--- #4. Kalkulasi Harga Setelah Promo [DONE]
DELIMITER $$
CREATE FUNCTION harga_setelah_promo(p_id CHAR(10), harga_awal DECIMAL(10, 2))
RETURNS DECIMAL(10,2)
BEGIN
    DECLARE diskon_persen DECIMAL(5,2);
    DECLARE minimum INT;
    DECLARE harga_akhir DECIMAL(10,2);

    -- Ambil diskon dan syarat minimum_pembelian dari promosi yang masih berlaku
    SELECT diskon, minimum_pembelian
    INTO diskon_persen, minimum
    FROM PROMOSI
    WHERE id_promosi = p_id
      AND CURDATE() BETWEEN tanggal_mulai AND tanggal_berakhir;

    -- Jika promosi tidak ditemukan atau tidak berlaku
    IF diskon_persen IS NULL OR minimum IS NULL THEN
        RETURN harga_awal;
    END IF;

    -- Jika harga tidak memenuhi minimum pembelian, tidak dapat diskon
    IF harga_awal < minimum THEN
        RETURN harga_awal;
    END IF;

    -- Hitung harga akhir setelah diskon
    SET harga_akhir = harga_awal - (harga_awal * (diskon_persen / 100));

    RETURN harga_akhir;
END$$
DELIMITER ;
--- SELECT harga_setelah_promo('PR014', 50000) AS harga_setelah_diskon;
--- SELECT harga_setelah_promo('PR014', 10000) AS harga_setelah_diskon;

-- #5. Kalkulasi Harga Makanan dalam Keranjang [DONE]
DELIMITER $$
CREATE FUNCTION total_harga_keranjang(p_transaksi CHAR(19))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);
    SELECT SUM(m.harga * tm.jumlah)
    INTO total
    FROM TRANSAKSI_MAKANAN tm
    JOIN MAKANAN m ON tm.makanan_id_makanan = m.id_makanan
    WHERE tm.transaksi_id_transaksi = p_transaksi;
    RETURN IFNULL(total, 0);
END$$
DELIMITER ;
-- SELECT total_harga_keranjang('TRX202506100001');
-- SELECT total_harga_keranjang('TRX202506100002');


-- #6.  Cek Poin untuk Free Tiket [FAILED]
-- Mengecek jika poin pelanggan >= 100, maka tiket gratis akan diterapkan.
-- DELIMITER $$
-- CREATE FUNCTION jumlah_tiket_gratis(p_id CHAR(5))
-- RETURNS INT
-- BEGIN
--     DECLARE poin INT DEFAULT 0;

--     SELECT poin INTO poin
--     FROM MEMBERSHIP
--     WHERE TRIM(pelanggan_id_pelanggan) = TRIM(p_id);

--     RETURN FLOOR(poin / 100);
-- END;
-- $$
-- DELIMITER ;


-- SELECT dapat_tiket_gratis('P0001'); ---OUTPUTNYA HARUSNYA 1
-- SELECT dapat_tiket_gratis('P0002');


-- #7. Konversi Total Harga Menjadi Poin [DONE]
-- Mengubah total harga transaksi menjadi poin, misalnya setiap Rp25.000 = 1 poin.
DELIMITER $$
CREATE FUNCTION harga_ke_poin(total DECIMAL(10,2))
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN FLOOR(total / 25000);
END$$
DELIMITER ;
-- SELECT harga_ke_poin(126000); -- Hasil: 5

-- #8, Hitung Pajak
-- Menambahkan pajak (misal 10%) dari subtotal transaksi.
DELIMITER $$
CREATE FUNCTION hitung_pajak(subtotal DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN subtotal * 0.10;
END;
$$
DELIMITER ;
-- SELECT hitung_pajak(100000); -- Hasil: 10000

-- #9. Hitung Refund Pembatalan[DONE]
-- Menghitung nominal refund sesuai kebijakan (misal potongan 20% dari total).
DELIMITER $$
CREATE FUNCTION hitung_refund(total DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN total * 0.80; -- Potongan 20%
END;
$$
DELIMITER ;
-- SELECT hitung_refund(100000); -- Hasil: 80000

-- #10. Hitung Total Transaksi [UPDATED - NO MORE biaya_pajak column]
-- Menjumlahkan subtotal, pajak (calculated), biaya admin, dan dikurangi diskon jika ada.
DELIMITER $$
CREATE FUNCTION hitung_total(
    subtotal DECIMAL(10,2), 
    biaya_admin DECIMAL(10,2), 
    diskon DECIMAL(10,2),
    transaksi_id CHAR(19)    
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);
    DECLARE pajak DECIMAL(10,2);
    DECLARE keranjang_total DECIMAL(10,2);
        
    -- Get total from food cart using total_harga_keranjang function
    SET keranjang_total = total_harga_keranjang(transaksi_id);
    
    -- Calculate total using all helper functions
    SET total = subtotal + biaya_admin - diskon + keranjang_total;
    SET total = total + hitung_pajak(subtotal); -- Add tax to the total
    
    RETURN IF(total < 0, 0, total);
END$$
DELIMITER ;
-- SELECT hitung_total(100000, 10000, 5000, 'TRX202506100001'); -- Example usage

-- #13. Calculate total for a transaction using only its ID
DELIMITER $$
CREATE FUNCTION calculate_transaction_total(transaksi_id CHAR(19))
RETURNS DECIMAL(10,2)
BEGIN
    DECLARE subtotal DECIMAL(10,2);
    DECLARE biaya_admin DECIMAL(10,2) DEFAULT 2000.00; -- Default admin fee
    DECLARE diskon DECIMAL(10,2) DEFAULT 0.00;
    DECLARE total DECIMAL(10,2);
    
    SELECT COALESCE(SUM(dt.harga_kursi), 0) 
    INTO subtotal
    FROM DETAIL_TRANSAKSI dt
    WHERE dt.transaksi_id_transaksi = transaksi_id;
    
    SELECT COALESCE(SUM(p.diskon * subtotal / 100), 0)
    INTO diskon
    FROM PROMOSI_TRANSAKSI pt
    JOIN PROMOSI p ON pt.promosi_id_promosi = p.id_promosi
    WHERE pt.transaksi_id_transaksi = transaksi_id
      AND CURDATE() BETWEEN p.tanggal_mulai AND p.tanggal_berakhir;
    
    SET total = hitung_total(subtotal, biaya_admin, diskon, transaksi_id);
    
    RETURN total;
END$$
DELIMITER ;
-- SELECT calculate_transaction_total('TRX202506100001') AS total_transaction;

DELIMITER $$
CREATE FUNCTION get_next_dt_id()
RETURNS CHAR(5)
BEGIN
    DECLARE max_num INT DEFAULT 0;
    DECLARE next_id CHAR(5);
    
    -- Get the highest existing DT number
    SELECT COALESCE(MAX(CAST(SUBSTRING(id_detail_transaksi, 3) AS UNSIGNED)), 0) 
    INTO max_num
    FROM DETAIL_TRANSAKSI 
    WHERE id_detail_transaksi LIKE 'DT%';
    
    -- Increment by 1 and format with leading zeros (3 digits)
    SET next_id = CONCAT('DT', LPAD(max_num + 1, 3, '0'));
    
    RETURN next_id;
END$$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION get_next_trx_id()
RETURNS CHAR(19)
BEGIN
    DECLARE max_num INT DEFAULT 0;
    DECLARE next_id CHAR(19);
    DECLARE today_prefix CHAR(15);
    
    -- Create today's prefix: TRX + YYYYMMDD format
    SET today_prefix = CONCAT('TRX', DATE_FORMAT(CURDATE(), '%Y%m%d'));
    
    -- Get the highest existing transaction number for today
    SELECT COALESCE(MAX(CAST(SUBSTRING(id_transaksi, 16) AS UNSIGNED)), 0) 
    INTO max_num
    FROM TRANSAKSI 
    WHERE id_transaksi LIKE CONCAT(today_prefix, '%');
    
    -- Increment by 1 and format with leading zeros (4 digits)
    SET next_id = CONCAT(today_prefix, LPAD(max_num + 1, 4, '0'));
    
    RETURN next_id;
END$$
DELIMITER ;