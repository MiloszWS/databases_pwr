-- ==========================================================
-- SKRYPT CAŁKOWITEGO RESETU BAZY DANYCH BOOKSY_DB
-- ==========================================================

-- 1. Całkowite usunięcie bazy, jeśli istnieje
DROP DATABASE IF EXISTS booksy_db;

-- 2. Tworzenie świeżej bazy danych
CREATE DATABASE booksy_db;
USE booksy_db;

-- ==========================================================
-- CZĘŚĆ 1: STRUKTURA TABEL (na podstawie booksy_db.sql)
-- ==========================================================

CREATE TABLE `voivodeships` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL UNIQUE,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `cities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `voivodeship_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_cities_voivodeship` FOREIGN KEY (`voivodeship_id`) REFERENCES `voivodeships` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `trainers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `full_name` varchar(100) DEFAULT NULL,
  `email` varchar(150) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `clients` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(150) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `gyms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `city_id` int(11) DEFAULT NULL,
  `street_address` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_gyms_city` FOREIGN KEY (`city_id`) REFERENCES `cities` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `services` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `default_duration` int(11) DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `is_group` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `slots` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `trainer_id` int(11) DEFAULT NULL,
  `gym_id` int(11) DEFAULT NULL,
  `service_id` int(11) DEFAULT NULL,
  `start_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `capacity` int(11) DEFAULT 1,
  `is_group_class` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_slots_trainer` FOREIGN KEY (`trainer_id`) REFERENCES `trainers` (`id`),
  CONSTRAINT `fk_slots_gym` FOREIGN KEY (`gym_id`) REFERENCES `gyms` (`id`),
  CONSTRAINT `fk_slots_service` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `bookings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `slot_id` int(11) DEFAULT NULL,
  `client_id` int(11) DEFAULT NULL,
  `notes` varchar(255) DEFAULT NULL,
  `status` enum('confirmed','pending','refused') DEFAULT 'pending',
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_bookings_slot` FOREIGN KEY (`slot_id`) REFERENCES `slots` (`id`),
  CONSTRAINT `fk_bookings_client` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `trainer_gyms` (
  `trainer_id` int(11) NOT NULL,
  `gym_id` int(11) NOT NULL,
  PRIMARY KEY (`trainer_id`,`gym_id`),
  CONSTRAINT `fk_tg_trainer` FOREIGN KEY (`trainer_id`) REFERENCES `trainers` (`id`),
  CONSTRAINT `fk_tg_gym` FOREIGN KEY (`gym_id`) REFERENCES `gyms` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `trainer_services` (
  `trainer_id` int(11) NOT NULL,
  `service_id` int(11) NOT NULL,
  PRIMARY KEY (`trainer_id`,`service_id`),
  CONSTRAINT `fk_ts_trainer` FOREIGN KEY (`trainer_id`) REFERENCES `trainers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ts_service` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `payments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `booking_id` int(11) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `payment_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `payment_method` enum('card', 'cash', 'transfer', 'blik') NOT NULL,
  `status` enum('completed', 'pending', 'refunded', 'failed') DEFAULT 'pending',
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_payments_booking` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 3. Tworzenie widoku dostępności
CREATE OR REPLACE VIEW available_slots_view AS
SELECT 
    s.id AS slot_id,
    s.start_time,
    s.end_time,
    s.capacity,
    t.full_name AS trainer_name,
    g.name AS gym_name,
    c.name AS city_name,
    sv.name AS service_name,
    (SELECT COUNT(*) FROM bookings b WHERE b.slot_id = s.id AND b.status != 'refused') AS current_reservations,
    (s.capacity - (SELECT COUNT(*) FROM bookings b WHERE b.slot_id = s.id AND b.status != 'refused')) AS remaining_capacity
FROM slots s
JOIN trainers t ON s.trainer_id = t.id
JOIN gyms g ON s.gym_id = g.id
JOIN cities c ON g.city_id = c.id
JOIN services sv ON s.service_id = sv.id;

-- ==========================================================
-- CZĘŚĆ 2: DANE TESTOWE (na podstawie seed.sql)
-- ==========================================================

INSERT INTO voivodeships (name) VALUES ('Dolnośląskie'), ('Mazowieckie'), ('Małopolskie');

INSERT INTO cities (name, voivodeship_id) VALUES ('Wrocław', 1), ('Warszawa', 2), ('Kraków', 3);

INSERT INTO trainers (full_name, email, password_hash, phone) VALUES
('Jan Kowalski', 'jan.kowalski@example.com', 'hashed_pass_1', '123456789'),
('Anna Nowak', 'anna.nowak@example.com', 'hashed_pass_2', '987654321'),
('Piotr Wiśniewski', 'piotr.w@example.com', 'hashed_pass_3', '555666777');

INSERT INTO clients (name, phone, email, password_hash) VALUES
('Michał Wójcik', '111222333', 'michal.w@example.com', 'hashed_client_1'),
('Katarzyna Kamińska', '444555666', 'kasia.k@example.com', 'hashed_client_2'),
('Tomasz Lewandowski', '777888999', 'tomek.l@example.com', 'hashed_client_3');

INSERT INTO gyms (name, city_id, street_address) VALUES
('FitMax Centrum', 1, 'ul. Długa 5'),
('PowerGym', 1, 'ul. Krótka 10'),
('Warsaw Fitness', 2, 'Al. Jerozolimskie 100');

INSERT INTO services (name, description, default_duration, price, is_group) VALUES
('Trening Personalny', 'Indywidualny trening 1 na 1', 60, 150.00, 0),
('Konsultacja Dietetyczna', 'Układanie planu żywieniowego', 45, 100.00, 0),
('Zajęcia grupowe - Joga', 'Relaks i rozciąganie', 60, 40.00, 1);

INSERT INTO trainer_gyms (trainer_id, gym_id) VALUES (1, 1), (1, 2), (2, 1), (3, 2);

INSERT INTO trainer_services (trainer_id, service_id) VALUES (1, 1), (1, 2), (2, 1), (2, 3), (3, 1);

INSERT INTO slots (trainer_id, gym_id, service_id, start_time, end_time, capacity, is_group_class) VALUES
(1, 1, 1, '2026-04-15 10:00:00', '2026-04-15 11:00:00', 1, 0),
(1, 1, 1, '2026-04-15 12:00:00', '2026-04-15 13:00:00', 1, 0),
(2, 1, 3, '2026-04-16 18:00:00', '2026-04-16 19:00:00', 15, 1),
(3, 2, 1, '2026-04-17 15:00:00', '2026-04-17 16:00:00', 1, 0);

INSERT INTO bookings (slot_id, client_id, notes, status) VALUES
(1, 1, 'Boli mnie prawe kolano', 'confirmed'),
(3, 2, 'Pierwszy raz na jodze!', 'pending'),
(3, 3, NULL, 'confirmed');

INSERT INTO payments (booking_id, amount, payment_method, status) VALUES
(1, 150.00, 'card', 'completed'),
(3, 40.00, 'blik', 'completed');