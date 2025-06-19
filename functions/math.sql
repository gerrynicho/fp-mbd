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
CREATE FUNCTION hitung_makanan(p_transaksi CHAR(19))
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
-- SELECT calculate_makanan('TRX202506100001');
-- SELECT calculate_makanan('TRX202506100002');

-- #6.  Cek Poin untuk Free Tiket [FAILED]
-- Mengecek jika poin pelanggan >= 100, maka tiket gratis akan diterapkan.
DELIMITER //
CREATE FUNCTION cek_poin_gratis_tiket(p_id CHAR(5))
RETURNS BOOLEAN
BEGIN
    DECLARE jumlah_poin INT;

    SELECT poin INTO jumlah_poin
    FROM MEMBERSHIP
    WHERE pelanggan_id_pelanggan = p_id;

    -- Jika pelanggan tidak memiliki membership, tidak bisa tiket gratis
    IF jumlah_poin IS NULL THEN
        RETURN FALSE;
    END IF;

    -- Jika poin >= 100, tiket gratis
    IF jumlah_poin >= 100 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
//
DELIMITER ;
-- SELECT cek_poin_gratis_tiket('P0001') AS status_tiket_gratis;

-- #7. Konversi Total Harga Menjadi Poin [DONE]
-- Mengubah total harga transaksi menjadi poin, misalnya setiap Rp25.000 = 1 poin.
DELIMITER //
CREATE FUNCTION konversi_poin_dari_transaksi(p_id_transaksi CHAR(19))
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE total DECIMAL(10,2);
    DECLARE id_pelanggan CHAR(5);
    DECLARE punya_membership BOOL;

    -- Ambil total biaya dan id pelanggan dari transaksi
    SELECT total_biaya, pelanggan_id_pelanggan
    INTO total, id_pelanggan
    FROM TRANSAKSI
    WHERE id_transaksi = p_id_transaksi;

    -- Cek apakah pelanggan memiliki membership
    SELECT EXISTS (
        SELECT 1 FROM MEMBERSHIP WHERE pelanggan_id_pelanggan = id_pelanggan
    ) INTO punya_membership;

    -- Jika tidak punya membership, return 0 poin
    IF NOT punya_membership THEN
        RETURN 0;
    END IF;

    -- Hitung poin: setiap 25.000 = 1 poin
    RETURN FLOOR(total / 25000);
END;
//
DELIMITER ;
-- SELECT konversi_poin_dari_transaksi('TRX202506110001');

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
    SET total = total + subtotal * 0.10;
    
    RETURN IF(total < 0, -1, total);
END$$
DELIMITER ;
-- SELECT hitung_total(100000, 10000, 5000, 'TRX202506100001'); -- Example usage

-- #13. Calculate total for a transaction using only its ID
DELIMITER $$
CREATE FUNCTION fetch_total(transaksi_id CHAR(19))
RETURNS DECIMAL(10,2)
BEGIN
    DECLARE subtotal DECIMAL(10,2);
    DECLARE biaya_admin DECIMAL(10,2) DEFAULT 2000.00; -- Default admin fee
    DECLARE diskon DECIMAL(10,2) DEFAULT 0.00;
    DECLARE total DECIMAL(10,2);
    
    SELECT COALESCE(SUM(k.harga_kursi), 0) 
    INTO subtotal
    FROM DETAIL_TRANSAKSI dt
    JOIN KURSI k ON dt.kursi_id_kursi = k.id_kursi
    WHERE dt.transaksi_id_transaksi = transaksi_id;
    
    -- NOTE: refactor this to only use 1 promosi
    SELECT COALESCE(SUM(p.diskon * subtotal / 100), 0)
    INTO diskon
    FROM PROMOSI_TRANSAKSI pt
    JOIN PROMOSI p ON pt.promosi_id_promosi = p.id_promosi
    WHERE pt.transaksi_id_transaksi = transaksi_id
      AND CURDATE() BETWEEN p.tanggal_mulai AND p.tanggal_berakhir;
    
    SET subtotal = subtotal + hitung_makanan(get_current_trx_id());
    SET total = hitung_total(subtotal, biaya_admin, diskon, transaksi_id);
    
    RETURN total;
END$$
DELIMITER ;
-- SELECT calculate_transaction_total('TRX202506100001') AS total_transaction;