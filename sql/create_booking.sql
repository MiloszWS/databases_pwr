-- sql/create_booking.sql
INSERT INTO bookings (slot_id, client_id, status)
SELECT :sid, :cid, 'pending'
FROM slots s
WHERE s.id = :sid
  AND (s.capacity - (SELECT COUNT(*) FROM bookings b WHERE b.slot_id = :sid AND b.status != 'refused')) > 0