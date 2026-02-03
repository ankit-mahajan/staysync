-- Production Seed Data
-- 1. Seed Countries (ISO 3166-1 alpha-2)
INSERT INTO countries (code, name) VALUES
('US', 'United States'),
('FR', 'France'),
('GB', 'United Kingdom'),
('IN', 'India'),
('AE', 'United Arab Emirates')
ON CONFLICT (code) DO NOTHING;

-- 2. Seed Cities
-- (Add production-safe cities if needed)
