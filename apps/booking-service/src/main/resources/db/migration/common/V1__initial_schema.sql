-- 1. Prerequisites
CREATE EXTENSION IF NOT EXISTS btree_gist;

-- 2. Master Data: Geography
CREATE TABLE countries (
                           code CHAR(2) PRIMARY KEY, -- ISO 3166-1 alpha-2 (e.g., 'US', 'FR')
                           name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE cities (
                        id BIGSERIAL PRIMARY KEY,
                        name VARCHAR(100) NOT NULL,
                        country_code CHAR(2) NOT NULL REFERENCES countries(code),
                        postal_code VARCHAR(20),
                        UNIQUE(name, country_code) -- Prevent duplicate cities in the same country
);

-- 3. Hotel Core
CREATE TABLE hotels (
                        id BIGSERIAL PRIMARY KEY,
                        name VARCHAR(255) NOT NULL,
                        city_id BIGINT NOT NULL REFERENCES cities(id),
                        address_line TEXT NOT NULL,
                        star_rating INT CHECK (star_rating BETWEEN 1 AND 5),
                        description TEXT,
                        created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
                        updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. Room Configuration
CREATE TYPE room_category AS ENUM ('STANDARD', 'DELUXE', 'SUITE', 'PENTHOUSE');

CREATE TABLE rooms (
                       id BIGSERIAL PRIMARY KEY,
                       hotel_id BIGINT NOT NULL REFERENCES hotels(id) ON DELETE CASCADE,
                       room_number VARCHAR(10) NOT NULL,
                       category room_category DEFAULT 'STANDARD',
                       capacity INT NOT NULL DEFAULT 2,
                       price_per_night NUMERIC(10, 2) NOT NULL,
                       is_active BOOLEAN DEFAULT TRUE,
                       UNIQUE(hotel_id, room_number) -- Ensure room numbers are unique per hotel
);

-- 5. Booking & Temporal Integrity
CREATE TABLE bookings (
                          id BIGSERIAL PRIMARY KEY,
                          room_id BIGINT NOT NULL REFERENCES rooms(id),
                          guest_email VARCHAR(255) NOT NULL,
                          stay_duration DATERANGE NOT NULL,
                          total_price NUMERIC(10, 2) NOT NULL,
                          status VARCHAR(20) DEFAULT 'CONFIRMED', -- e.g., PENDING, CONFIRMED, CANCELLED

    -- EXCLUSION CONSTRAINT: Prevent double-booking for the same room
    -- We use '&&' to check for range overlaps and '=' for the same room_id
                          CONSTRAINT no_overlapping_bookings EXCLUDE USING gist (
        room_id WITH =,
        stay_duration WITH &&
    ) WHERE (status != 'CANCELLED') -- Allow re-booking if previous was cancelled
);

-- 6. Indexes for Performance
CREATE INDEX idx_hotels_city ON hotels(city_id);
CREATE INDEX idx_rooms_hotel ON rooms(hotel_id);
CREATE INDEX idx_bookings_duration ON bookings USING gist (stay_duration);