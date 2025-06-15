-- HITUNG PELANGGAN HARI INI
DELIMITER $$
-- 
CREATE FUNCTION hitung_pelanggan_hari_ini(DATE current_date) 
RETURNS INTEGER  
DETERMINISTIC
BEGIN 
    DECLARE jumlah_pelanggan_hari_ini INT;

    SELECT COUNT(
        DISTINCT pelanggan_id_pelanggan 
    )
    INTO jumlah_pelanggan_hari_ini
    FROM TRANSAKSI t
    WHERE t.tanggal = current_date;

    RETURN jumlah_pelanggan_hari_ini;
END
$$
DELIMITER ;

-- #1 CEK MEMBERSHIP PELANGGAN [DONE]
DELIMITER //
CREATE FUNCTION cek_membership(p_id CHAR(5))
-- gk bisa deterministic gara" bisa aja function call before bikin membership baru
-- trus pas user bikin membership
-- function ini klo deterministic bakal kasi info salah
RETURNS BOOLEAN
BEGIN
    DECLARE status BOOL;
    SELECT EXISTS (
        SELECT 1 FROM MEMBERSHIP WHERE pelanggan_id_pelanggan = p_id
    ) INTO status;
    RETURN status;
END;
//
DELIMITER ;
-- SELECT cek_membership('P0001');
-- SELECT cek_membership('P0021');

--  #2 CEK MASA BERLAKU MEMBERSHIP [TENTATIVE]
DELIMITER //
CREATE FUNCTION promosi_masih_berlaku(p_id CHAR(10))
-- gk bisa deterministic karena tergantung tanggal saat ini
RETURNS BOOLEAN
BEGIN
    DECLARE status BOOL;
    SELECT ( CURDATE() BETWEEN tanggal_mulai AND tanggal_berakhir )
    INTO status
    FROM PROMOSI
    WHERE id_promosi = p_id;
    RETURN status;
END;
//
DELIMITER ;

-- SELECT promosi_masih_berlaku('PR001');
-- SELECT promosi_masih_berlaku('PR014');

-- #3 Hitung Total Penggunaan Promosi [DONE]
DELIMITER //
CREATE FUNCTION total_penggunaan_promosi(p_id CHAR(10))
-- gk bisa deterministiic gara" bisa aja ada transaksi baru
-- yang menggunakan promosi ini
RETURNS INT
BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total
    FROM PROMOSI_TRANSAKSI
    WHERE promosi_id_promosi = p_id;
    RETURN total;
END;
//
DELIMITER ;


-- SELECT total_penggunaan_promosi('PR001');
-- SELECT total_penggunaan_promosi('PR014');


--- #4. Kalkulasi Harga Setelah Promo [DONE]
DELIMITER //
CREATE FUNCTION harga_setelah_diskon(harga DECIMAL(10,2), diskon DECIMAL(5,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC -- deterministic gara" cuma basic math operation
BEGIN
    RETURN harga - (harga * diskon / 100);
END;
//
DELIMITER ;

--- SELECT harga_setelah_diskon(100000, 10); -- Hasil: 90000


-- #5. Kalkulasi Harga Makanan dalam Keranjang [DONE]

DELIMITER //
CREATE FUNCTION total_harga_keranjang(p_transaksi CHAR(19))
DETERMINISTIC -- determministic gara" transaksi gk bakal berubah
RETURNS DECIMAL(10,2)
BEGIN
    DECLARE total DECIMAL(10,2);
    SELECT SUM(m.harga * tm.jumlah)
    INTO total
    FROM TRANSAKSI_MAKANAN tm
    JOIN MAKANAN m ON tm.makanan_id_makanan = m.id_makanan
    WHERE tm.transaksi_id_transaksi = p_transaksi;
    RETURN IFNULL(total, 0);
END;
//
DELIMITER ;


-- SELECT total_harga_keranjang('TRX202506100001');
-- SELECT total_harga_keranjang('TRX202506100002');


-- #7.  Cek Poin untuk Free Tiket [FAILED]
-- Mengecek jika poin pelanggan >= 100, maka tiket gratis akan diterapkan.
DELIMITER //
CREATE FUNCTION jumlah_tiket_gratis(p_id CHAR(5))
RETURNS INT
BEGIN
    DECLARE poin INT DEFAULT 0;

    SELECT poin INTO poin
    FROM MEMBERSHIP
    WHERE TRIM(pelanggan_id_pelanggan) = TRIM(p_id);

    RETURN FLOOR(poin / 100);
END;
//
DELIMITER ;


-- SELECT dapat_tiket_gratis('P0001'); ---OUTPUTNYA HARUSNYA 1
-- SELECT dapat_tiket_gratis('P0002');


-- #8. Konversi Total Harga Menjadi Poin [DONE]
-- Mengubah total harga transaksi menjadi poin, misalnya setiap Rp25.000 = 1 poin.
DELIMITER //
CREATE FUNCTION harga_ke_poin(total DECIMAL(10,2))
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN FLOOR(total / 25000);
END;
//
DELIMITER ;

-- SELECT harga_ke_poin(126000); -- Hasil: 5

-- #9, Hitung Pajak
-- Menambahkan pajak (misal 10%) dari subtotal transaksi.
DELIMITER //
CREATE FUNCTION hitung_pajak(subtotal DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN subtotal * 0.10;
END;
//
DELIMITER ;

-- SELECT hitung_pajak(100000); -- Hasil: 10000

-- #10. Hitung Refund Pembatalan[DONE]
-- Menghitung nominal refund sesuai kebijakan (misal potongan 20% dari total).
DELIMITER //
CREATE FUNCTION hitung_refund(total DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN total * 0.80; -- Potongan 20%
END;
//
DELIMITER ;

-- SELECT hitung_refund(100000); -- Hasil: 80000



-- #11. Hitung Total Transaksi [DONE]
-- Menjumlahkan subtotal, pajak, biaya admin, dan dikurangi diskon jika ada.

DELIMITER //
CREATE FUNCTION hitung_total(subtotal DECIMAL(10,2), pajak DECIMAL(10,2), biaya_admin DECIMAL(10,2), diskon DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN subtotal + pajak + biaya_admin - diskon;
END;
//
DELIMITER ;


-- SELECT hitung_total(100000, 10000, 5000, 15000); -- Hasil: 100000

-- #12. Hitung Harga Kursi [DONE]
-- Mengembalikan harga berdasarkan banyaknya kursi yang dipesan.

DELIMITER //
CREATE FUNCTION harga_kursi(jumlah_kursi INT, harga_per_kursi DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN jumlah_kursi * harga_per_kursi;
END;
//
DELIMITER ;

-- SELECT harga_kursi(3, 45000); -- Hasil: 135000
