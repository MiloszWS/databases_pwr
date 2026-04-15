-- ==========================================================
-- SKRYPT CZYSZCZENIA REZERWACJI I PŁATNOŚCI
-- (Zostawia sloty, trenerów, siłownie i miasta)
-- ==========================================================

USE booksy_db;

-- Wyłączenie sprawdzania kluczy obcych na czas czyszczenia (dla pewności i szybkości)
SET FOREIGN_KEY_CHECKS = 0;

-- 1. Czyścimy płatności
TRUNCATE TABLE payments;

-- 2. Czyścimy rezerwacje
TRUNCATE TABLE bookings;

-- Włączenie sprawdzania kluczy obcych z powrotem
SET FOREIGN_KEY_CHECKS = 1;

-- Resetujemy liczniki ID (opcjonalne, TRUNCATE robi to automatycznie w MariaDB)
-- Dzięki temu pierwsza nowa rezerwacja znów będzie miała ID = 1.

-- Informacja dla użytkownika (widoczna w konsoli bazy)
SELECT 'Data cleaned: Bookings and payments removed. Slots remain intact.' AS Status;