-- 1
CREATE TABLE `trainers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `full_name` varchar(100) DEFAULT NULL,
  `email` varchar(150) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 2
CREATE TABLE `clients` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(150) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 3 
CREATE TABLE `gyms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 4 
CREATE TABLE `services` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `default_duration` int(11) DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `is_group` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 5 (wymaga trainers, gyms, services)
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

-- 6 (wymaga slots, clients)
CREATE TABLE `bookings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `slot_id` int(11) DEFAULT NULL,
  `client_id` int(11) DEFAULT NULL,
  `payment_status` enum('paid','unpaid') DEFAULT 'unpaid',
  `notes` varchar(255) DEFAULT NULL,
  `status` enum('confirmed','pending','refused') DEFAULT 'pending',
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_bookings_slot` FOREIGN KEY (`slot_id`) REFERENCES `slots` (`id`),
  CONSTRAINT `fk_bookings_client` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 7 Łączy trainers z gyms (wiele do wielu)
CREATE TABLE `trainer_gyms` (
  `trainer_id` int(11) NOT NULL,
  `gym_id` int(11) NOT NULL,
  PRIMARY KEY (`trainer_id`,`gym_id`),
  CONSTRAINT `fk_tg_trainer` FOREIGN KEY (`trainer_id`) REFERENCES `trainers` (`id`),
  CONSTRAINT `fk_tg_gym` FOREIGN KEY (`gym_id`) REFERENCES `gyms` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 8 Łączy trainers z services (wiele do wielu)
CREATE TABLE `trainer_services` (
  `trainer_id` int(11) NOT NULL,
  `service_id` int(11) NOT NULL,
  PRIMARY KEY (`trainer_id`,`service_id`),
  CONSTRAINT `fk_ts_trainer` FOREIGN KEY (`trainer_id`) REFERENCES `trainers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ts_service` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;