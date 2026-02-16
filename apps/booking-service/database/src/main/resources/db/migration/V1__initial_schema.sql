-- 1. Prerequisites & Extensions
-- btree_gist is required for Exclusion Constraints on standard types (like room_id)
CREATE EXTENSION IF NOT EXISTS btree_gist;
-- postgis is required for spatial types and geographical calculations
CREATE EXTENSION IF NOT EXISTS postgis;

-- 2. Master Data: Geography
CREATE TABLE countries (
    code CHAR(2) PRIMARY KEY, -- ISO 3166-1 alpha-2
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE cities (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country_code CHAR(2) NOT NULL REFERENCES countries(code),
    postal_code VARCHAR(20),
    UNIQUE(name, country_code)
);

-- 3. Hotel Core (Merged with Latitude/Longitude)
CREATE TABLE hotels (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    city_id BIGINT NOT NULL REFERENCES cities(id),
    address_line TEXT NOT NULL,
    star_rating INT CHECK (star_rating BETWEEN 1 AND 5),
    description TEXT,
    -- Basic coordinates for API consumption
    latitude NUMERIC(9,6),
    longitude NUMERIC(9,6),
    -- PostGIS Geography type for spatial math (distance/geofencing)
    location_geog GEOGRAPHY(POINT, 4326),
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
    UNIQUE(hotel_id, room_number)
);

-- 5. Booking & Temporal Integrity
CREATE TABLE bookings (
    id BIGSERIAL PRIMARY KEY,
    room_id BIGINT NOT NULL REFERENCES rooms(id),
    guest_email VARCHAR(255) NOT NULL,
    stay_duration DATERANGE NOT NULL,
    total_price NUMERIC(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'CONFIRMED', 
    
    -- EXCLUSION CONSTRAINT: Iron-clad double-booking prevention
    CONSTRAINT no_overlapping_bookings EXCLUDE USING gist (
        room_id WITH =,
        stay_duration WITH &&
    ) WHERE (status != 'CANCELLED')
);

-- 6. Spatial Automation (Syncs lat/long to location_geog automatically)
CREATE OR REPLACE FUNCTION sync_hotel_geog() 
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.latitude IS NOT NULL AND NEW.longitude IS NOT NULL THEN
        NEW.location_geog = ST_SetSRID(ST_Point(NEW.longitude, NEW.latitude), 4326)::geography;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_sync_hotel_geog
BEFORE INSERT OR UPDATE OF latitude, longitude ON hotels
FOR EACH ROW EXECUTE FUNCTION sync_hotel_geog();

-- 7. Performance Indexes
CREATE INDEX idx_hotels_city ON hotels(city_id);
CREATE INDEX idx_rooms_hotel ON rooms(hotel_id);
-- Spatial Index for "Find hotels near me" queries
CREATE INDEX idx_hotels_location_geog ON hotels USING GIST (location_geog);
-- GIST Index for temporal queries (find bookings in a specific month)
CREATE INDEX idx_bookings_duration ON bookings USING gist (stay_duration);