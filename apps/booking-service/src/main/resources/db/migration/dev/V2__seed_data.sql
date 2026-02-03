-- 1. Seed Countries (ISO 3166-1 alpha-2)
INSERT INTO countries (code, name) VALUES
('US', 'United States'),
('FR', 'France'),
('GB', 'United Kingdom'),
('IN', 'India'),
('AE', 'United Arab Emirates');

-- 2. Seed Cities
INSERT INTO cities (name, country_code, postal_code) VALUES
('New York', 'US', '10001'),
('Paris', 'FR', '75001'),
('London', 'GB', 'SW1A'),
('Mumbai', 'IN', '400001'),
('Dubai', 'AE', '00000');

-- 3. Seed Hotels
INSERT INTO hotels (name, city_id, address_line, star_rating, description) VALUES
('The Grand Starlight', 1, '123 Broadway, Manhattan', 5, 'Luxury hotel in the heart of NYC'),
('Eiffel View Suites', 2, '15 Rue de la Paix', 4, 'Boutique hotel with views of the tower'),
('Royal Thames stay', 3, '45 Westminster Bridge Rd', 5, 'Classic British luxury by the river'),
('Marine Drive Palace', 4, '89 Marine Drive', 4, 'Iconic hotel overlooking the Arabian Sea');

-- 4. Seed Rooms
-- Linking rooms to 'The Grand Starlight' (Hotel ID 1)
INSERT INTO rooms (hotel_id, room_number, category, capacity, price_per_night) VALUES
(1, '101', 'STANDARD', 2, 250.00),
(1, '102', 'DELUXE', 2, 450.00),
(1, 'PH-01', 'PENTHOUSE', 4, 1500.00);

-- Linking rooms to 'Eiffel View Suites' (Hotel ID 2)
INSERT INTO rooms (hotel_id, room_number, category, capacity, price_per_night) VALUES
(2, '201', 'STANDARD', 2, 300.00),
(2, '202', 'SUITE', 3, 650.00);

-- 5. Seed Initial Bookings
-- Note: daterange format '[YYYY-MM-DD, YYYY-MM-DD)' 
-- '[' is inclusive, ')' is exclusive (check-out day doesn't count as a night)
INSERT INTO bookings (room_id, guest_email, stay_duration, total_price, status) VALUES
(1, 'guest1@example.com', '[2026-05-01, 2026-05-05)', 1000.00, 'CONFIRMED'),
(1, 'guest2@example.com', '[2026-05-10, 2026-05-15)', 1250.00, 'CONFIRMED'),
(2, 'traveler@world.com', '[2026-06-01, 2026-06-07)', 2700.00, 'CONFIRMED');