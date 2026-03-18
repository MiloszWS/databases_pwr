-- Upewnijmy się, że używamy odpowiedniej bazy
USE booksy_db;

-- 1. Dodawanie trenerów
INSERT INTO trainers (full_name, email, password_hash, phone) VALUES
('Jan Kowalski', 'jan.kowalski@example.com', 'hashed_pass_1', '123456789'),
('Anna Nowak', 'anna.nowak@example.com', 'hashed_pass_2', '987654321'),
('Piotr Wiśniewski', 'piotr.w@example.com', 'hashed_pass_3', '555666777');

-- 2. Dodawanie klientów
INSERT INTO clients (name, phone, email, password_hash) VALUES
('Michał Wójcik', '111222333', 'michal.w@example.com', 'hashed_client_1'),
('Katarzyna Kamińska', '444555666', 'kasia.k@example.com', 'hashed_client_2'),
('Tomasz Lewandowski', '777888999', 'tomek.l@example.com', 'hashed_client_3');

-- 3. Dodawanie siłowni
INSERT INTO gyms (name, address) VALUES
('FitMax Centrum', 'ul. Długa 5, Wrocław'),
('PowerGym', 'ul. Krótka 10, Wrocław');

-- 4. Dodawanie usług
INSERT INTO services (name, description, default_duration, price, is_group) VALUES
('Trening Personalny', 'Indywidualny trening 1 na 1', 60, 150.00, 0),
('Konsultacja Dietetyczna', 'Układanie planu żywieniowego', 45, 100.00, 0),
('Zajęcia grupowe - Joga', 'Relaks i rozciąganie', 60, 40.00, 1);

-- 5. Przypisywanie trenerów do siłowni (relacja wiele do wielu)
INSERT INTO trainer_gyms (trainer_id, gym_id) VALUES
(1, 1), -- Jan trenuje w FitMax
(1, 2), -- Jan trenuje również w PowerGym
(2, 1), -- Anna trenuje w FitMax
(3, 2); -- Piotr trenuje w PowerGym

-- 6. Przypisywanie trenerów do usług (relacja wiele do wielu)
INSERT INTO trainer_services (trainer_id, service_id) VALUES
(1, 1), (1, 2), -- Jan prowadzi treningi i diety
(2, 1), (2, 3), -- Anna prowadzi treningi i jogę
(3, 1);         -- Piotr prowadzi tylko treningi

-- 7. Tworzenie slotów (dostępnych terminów w kalendarzu)
INSERT INTO slots (trainer_id, gym_id, service_id, start_time, end_time, capacity, is_group_class) VALUES
(1, 1, 1, '2026-04-01 10:00:00', '2026-04-01 11:00:00', 1, 0),
(1, 1, 1, '2026-04-01 11:30:00', '2026-04-01 12:30:00', 1, 0),
(2, 1, 3, '2026-04-02 18:00:00', '2026-04-02 19:00:00', 15, 1),
(3, 2, 1, '2026-04-03 15:00:00', '2026-04-03 16:00:00', 1, 0);

-- 8. Tworzenie rezerwacji (klienci rezerwują sloty)
INSERT INTO bookings (slot_id, client_id, payment_status, notes, status) VALUES
(1, 1, 'paid', 'Boli mnie prawe kolano, proszę uważać', 'confirmed'),
(3, 2, 'unpaid', 'Pierwszy raz na jodze!', 'pending'),
(3, 3, 'paid', NULL, 'confirmed');