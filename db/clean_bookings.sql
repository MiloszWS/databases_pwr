USE booksy_db;

-- Wyłączenie sprawdzania kluczy obcych na czas czyszczenia (dla pewności i szybkości)
SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE payments;

TRUNCATE TABLE bookings;

-- Włączenie sprawdzania kluczy obcych z powrotem
SET FOREIGN_KEY_CHECKS = 1;

SELECT 'Data cleaned: Bookings and payments removed. Slots remain intact.' AS Status;