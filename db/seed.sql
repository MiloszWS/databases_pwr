-- Upewnijmy się, że używamy odpowiedniej bazy
USE booksy_db;

-- 1. Dodawanie województw (wymagane dla miast)
INSERT INTO voivodeships (name) VALUES
('Dolnośląskie'),
('Mazowieckie'),
('Małopolskie');

-- 2. Dodawanie miast (wymagane dla siłowni)
INSERT INTO cities (name, voivodeship_id) VALUES
('Wrocław', 1),
('Warszawa', 2),
('Kraków', 3);

-- 3. Dodawanie trenerów
INSERT INTO trainers (full_name, email, password_hash, phone) VALUES
('Jan Kowalski', 'jan.kowalski@example.com', 'hashed_pass_1', '123456789'),
('Anna Nowak', 'anna.nowak@example.com', 'hashed_pass_2', '987654321'),
('Piotr Wiśniewski', 'piotr.w@example.com', 'hashed_pass_3', '555666777');

-- 4. Dodawanie klientów
INSERT INTO clients (name, phone, email, password_hash) VALUES
('Michał Wójcik', '111222333', 'michal.w@example.com', 'hashed_client_1'),
('Katarzyna Kamińska', '444555666', 'kasia.k@example.com', 'hashed_client_2'),
('Tomasz Lewandowski', '777888999', 'tomek.l@example.com', 'hashed_client_3');

-- 5. Dodawanie siłowni (z city_id i street_address)
INSERT INTO gyms (name, city_id, street_address) VALUES
('FitMax Centrum', 1, 'ul. Długa 5'),
('PowerGym', 1, 'ul. Krótka 10'),
('Warsaw Fitness', 2, 'Al. Jerozolimskie 100');

-- 6. Dodawanie usług
INSERT INTO services (name, description, default_duration, price, is_group) VALUES
('Trening Personalny', 'Indywidualny trening 1 na 1', 60, 150.00, 0),
('Konsultacja Dietetyczna', 'Układanie planu żywieniowego', 45, 100.00, 0),
('Zajęcia grupowe - Joga', 'Relaks i rozciąganie', 60, 40.00, 1);

-- 7. Przypisywanie trenerów do siłowni
INSERT INTO trainer_gyms (trainer_id, gym_id) VALUES
(1, 1), (1, 2), (2, 1), (3, 2);

-- 8. Przypisywanie trenerów do usług
INSERT INTO trainer_services (trainer_id, service_id) VALUES
(1, 1), (1, 2), (2, 1), (2, 3), (3, 1);

-- 9. Tworzenie slotów (w tym WOLNE SLOTY do testów bookingu)
INSERT INTO slots (trainer_id, gym_id, service_id, start_time, end_time, capacity, is_group_class) VALUES
-- Slot zajęty (1/1)
(1, 1, 1, '2026-04-15 10:00:00', '2026-04-15 11:00:00', 1, 0),
-- Slot WOLNY (0/1) - idealny do testu rezerwacji indywidualnej
(1, 1, 1, '2026-04-15 12:00:00', '2026-04-15 13:00:00', 1, 0),
-- Slot grupowy z miejscami (2/15) - do testu rezerwacji grupowej
(2, 1, 3, '2026-04-16 18:00:00', '2026-04-16 19:00:00', 15, 1),
-- Kolejny wolny slot indywidualny
(3, 2, 1, '2026-04-17 15:00:00', '2026-04-17 16:00:00', 1, 0);

-- 10. Tworzenie rezerwacji (statusy zgodne z enum: confirmed, pending, refused)
-- Rezerwujemy pierwszy slot (Jan Kowalski, FitMax), aby go zapełnić
INSERT INTO bookings (slot_id, client_id, notes, status) VALUES
(1, 1, 'Boli mnie prawe kolano', 'confirmed'),
-- Rezerwacje na zajęcia grupowe (slot_id 3)
(3, 2, 'Pierwszy raz na jodze!', 'pending'),
(3, 3, NULL, 'confirmed');

-- 11. Dodawanie płatności (zamiast starego payment_status w bookings)
INSERT INTO payments (booking_id, amount, payment_method, status) VALUES
(1, 150.00, 'card', 'completed'),
(3, 40.00, 'blik', 'completed');