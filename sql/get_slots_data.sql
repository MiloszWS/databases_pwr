SELECT
    s.id, s.start_time, s.end_time, s.capacity,
    t.full_name AS trainer_name,
    g.name AS gym_name,
    c.name AS city_name,
    sv.name AS service_name,
    -- Pobieramy liczbę rezerwacji (to jest punkt, który będziemy testować pod kątem wydajności)
    (SELECT COUNT(*) FROM bookings b WHERE b.slot_id = s.id AND b.status != 'refused') AS occupied_count
FROM slots s
JOIN trainers t ON s.trainer_id = t.id
JOIN gyms g ON s.gym_id = g.id
JOIN cities c ON g.city_id = c.id
JOIN services sv ON s.service_id = sv.id
LIMIT 50;