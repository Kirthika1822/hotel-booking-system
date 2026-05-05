-- ============================================================
--   HOTEL BOOKING SYSTEM - MySQL Full Project
-- ============================================================

CREATE DATABASE IF NOT EXISTS hotel_booking;
USE hotel_booking;

-- ============================================================
-- 1. SCHEMA / TABLE DEFINITIONS
-- ============================================================

-- Hotels
CREATE TABLE hotels (
    hotel_id      INT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(100) NOT NULL,
    city          VARCHAR(50)  NOT NULL,
    state         VARCHAR(50),
    country       VARCHAR(50)  NOT NULL,
    star_rating   TINYINT      CHECK (star_rating BETWEEN 1 AND 5),
    phone         VARCHAR(20),
    email         VARCHAR(100),
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Room Types (e.g., Single, Double, Suite)
CREATE TABLE room_types (
    room_type_id  INT AUTO_INCREMENT PRIMARY KEY,
    type_name     VARCHAR(50)    NOT NULL,
    description   TEXT,
    max_occupancy TINYINT        NOT NULL,
    base_price    DECIMAL(10,2)  NOT NULL
);

-- Rooms
CREATE TABLE rooms (
    room_id       INT AUTO_INCREMENT PRIMARY KEY,
    hotel_id      INT            NOT NULL,
    room_type_id  INT            NOT NULL,
    room_number   VARCHAR(10)    NOT NULL,
    floor         TINYINT,
    is_available  BOOLEAN        DEFAULT TRUE,
    FOREIGN KEY (hotel_id)     REFERENCES hotels(hotel_id),
    FOREIGN KEY (room_type_id) REFERENCES room_types(room_type_id),
    UNIQUE (hotel_id, room_number)
);

-- Guests
CREATE TABLE guests (
    guest_id      INT AUTO_INCREMENT PRIMARY KEY,
    first_name    VARCHAR(50)  NOT NULL,
    last_name     VARCHAR(50)  NOT NULL,
    email         VARCHAR(100) NOT NULL UNIQUE,
    phone         VARCHAR(20),
    nationality   VARCHAR(50),
    id_proof_type VARCHAR(30),   -- Passport / Aadhar / DL
    id_proof_no   VARCHAR(50),
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bookings
CREATE TABLE bookings (
    booking_id    INT AUTO_INCREMENT PRIMARY KEY,
    guest_id      INT            NOT NULL,
    room_id       INT            NOT NULL,
    check_in      DATE           NOT NULL,
    check_out     DATE           NOT NULL,
    num_guests    TINYINT        NOT NULL DEFAULT 1,
    status        ENUM('confirmed','cancelled','checked_in','checked_out') DEFAULT 'confirmed',
    total_amount  DECIMAL(10,2),
    booked_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (guest_id) REFERENCES guests(guest_id),
    FOREIGN KEY (room_id)  REFERENCES rooms(room_id),
    CHECK (check_out > check_in)
);

-- Payments
CREATE TABLE payments (
    payment_id    INT AUTO_INCREMENT PRIMARY KEY,
    booking_id    INT            NOT NULL,
    amount        DECIMAL(10,2)  NOT NULL,
    payment_date  DATETIME       DEFAULT CURRENT_TIMESTAMP,
    method        ENUM('cash','card','upi','net_banking') NOT NULL,
    status        ENUM('pending','completed','refunded')  DEFAULT 'completed',
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);

-- Staff
CREATE TABLE staff (
    staff_id      INT AUTO_INCREMENT PRIMARY KEY,
    hotel_id      INT          NOT NULL,
    first_name    VARCHAR(50)  NOT NULL,
    last_name     VARCHAR(50)  NOT NULL,
    role          VARCHAR(50)  NOT NULL,  -- Manager, Receptionist, Housekeeping, etc.
    email         VARCHAR(100) UNIQUE,
    phone         VARCHAR(20),
    hire_date     DATE,
    salary        DECIMAL(10,2),
    FOREIGN KEY (hotel_id) REFERENCES hotels(hotel_id)
);

-- Services (extra services guests can order)
CREATE TABLE services (
    service_id    INT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(100)   NOT NULL,
    description   TEXT,
    price         DECIMAL(10,2)  NOT NULL
);

-- Booking Services (which services a booking used)
CREATE TABLE booking_services (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    booking_id    INT           NOT NULL,
    service_id    INT           NOT NULL,
    quantity      INT           DEFAULT 1,
    requested_at  DATETIME      DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),
    FOREIGN KEY (service_id) REFERENCES services(service_id)
);

-- Reviews
CREATE TABLE reviews (
    review_id     INT AUTO_INCREMENT PRIMARY KEY,
    booking_id    INT     NOT NULL UNIQUE,
    rating        TINYINT CHECK (rating BETWEEN 1 AND 5),
    comments      TEXT,
    reviewed_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);


-- ============================================================
-- 2. SAMPLE DATA
-- ============================================================

-- Hotels
INSERT INTO hotels (name, city, state, country, star_rating, phone, email) VALUES
('The Grand Palace',   'Mumbai',    'Maharashtra', 'India', 5, '+91-22-10001111', 'info@grandpalace.com'),
('Seaside Comfort Inn','Chennai',   'Tamil Nadu',  'India', 3, '+91-44-20002222', 'stay@seasideinn.com'),
('Mountain View Resort','Shimla',   'Himachal Pradesh','India',4,'+91-177-3000333','contact@mvresort.com'),
('Heritage Haveli',    'Jaipur',    'Rajasthan',   'India', 4, '+91-141-4000444', 'hello@heritagehaveli.com'),
('Metro Stay',         'Bangalore', 'Karnataka',   'India', 3, '+91-80-5000555',  'book@metrostay.com');

-- Room Types
INSERT INTO room_types (type_name, description, max_occupancy, base_price) VALUES
('Single',  'Cozy room for solo travellers',          1,  1500.00),
('Double',  'Spacious room for couples',              2,  2500.00),
('Deluxe',  'Premium room with city view',            2,  4000.00),
('Suite',   'Luxury suite with living area',          4,  8000.00),
('Family',  'Large room perfect for families',        4,  5500.00);

-- Rooms
INSERT INTO rooms (hotel_id, room_type_id, room_number, floor) VALUES
(1, 1, '101', 1),(1, 2, '102', 1),(1, 3, '201', 2),(1, 4, '301', 3),(1, 5, '302', 3),
(2, 1, '101', 1),(2, 2, '102', 1),(2, 3, '201', 2),
(3, 2, '101', 1),(3, 3, '201', 2),(3, 4, '301', 3),
(4, 3, '101', 1),(4, 4, '201', 2),(4, 5, '202', 2),
(5, 1, '101', 1),(5, 2, '102', 1),(5, 3, '201', 2);

-- Guests
INSERT INTO guests (first_name, last_name, email, phone, nationality, id_proof_type, id_proof_no) VALUES
('Arjun',    'Sharma',    'arjun.sharma@email.com',   '+91-9000000001', 'Indian', 'Aadhar', 'XXXX-XXXX-0001'),
('Priya',    'Nair',      'priya.nair@email.com',     '+91-9000000002', 'Indian', 'Passport','P1234001'),
('Rahul',    'Verma',     'rahul.verma@email.com',    '+91-9000000003', 'Indian', 'Aadhar', 'XXXX-XXXX-0003'),
('Sneha',    'Iyer',      'sneha.iyer@email.com',     '+91-9000000004', 'Indian', 'DL',     'TN-DL-0004'),
('Vikram',   'Singh',     'vikram.singh@email.com',   '+91-9000000005', 'Indian', 'Passport','P1234005'),
('Ananya',   'Das',       'ananya.das@email.com',     '+91-9000000006', 'Indian', 'Aadhar', 'XXXX-XXXX-0006'),
('Karthik',  'Raj',       'karthik.raj@email.com',    '+91-9000000007', 'Indian', 'Aadhar', 'XXXX-XXXX-0007'),
('Meera',    'Pillai',    'meera.pillai@email.com',   '+91-9000000008', 'Indian', 'Passport','P1234008'),
('Siddharth','Bose',      'siddharth.bose@email.com', '+91-9000000009', 'Indian', 'DL',     'WB-DL-0009'),
('Divya',    'Menon',     'divya.menon@email.com',    '+91-9000000010', 'Indian', 'Aadhar', 'XXXX-XXXX-0010');

-- Bookings
INSERT INTO bookings (guest_id, room_id, check_in, check_out, num_guests, status, total_amount) VALUES
(1,  3,  '2025-05-01', '2025-05-04', 2, 'checked_out',  12000.00),
(2,  4,  '2025-05-05', '2025-05-08', 3, 'checked_out',  24000.00),
(3,  7,  '2025-05-10', '2025-05-12', 2, 'checked_out',   5000.00),
(4,  11, '2025-05-15', '2025-05-18', 2, 'confirmed',    12000.00),
(5,  12, '2025-05-20', '2025-05-22', 2,  'confirmed',    8000.00),
(6,  1,  '2025-06-01', '2025-06-03', 1, 'confirmed',     3000.00),
(7,  9,  '2025-06-05', '2025-06-07', 2, 'cancelled',     5000.00),
(8,  14, '2025-06-10', '2025-06-15', 4, 'confirmed',    27500.00),
(9,  16, '2025-06-12', '2025-06-14', 2, 'confirmed',     5000.00),
(10, 17, '2025-06-20', '2025-06-25', 2, 'confirmed',    20000.00);

-- Payments
INSERT INTO payments (booking_id, amount, method, status) VALUES
(1,  12000.00, 'card',        'completed'),
(2,  24000.00, 'net_banking', 'completed'),
(3,   5000.00, 'upi',         'completed'),
(4,  12000.00, 'card',        'completed'),
(5,   8000.00, 'upi',         'completed'),
(6,   3000.00, 'cash',        'pending'),
(7,   5000.00, 'card',        'refunded'),
(8,  27500.00, 'net_banking', 'completed'),
(9,   5000.00, 'upi',         'completed'),
(10, 20000.00, 'card',        'pending');

-- Staff
INSERT INTO staff (hotel_id, first_name, last_name, role, email, phone, hire_date, salary) VALUES
(1, 'Rohan',   'Kapoor',  'Manager',       'rohan@grandpalace.com',   '+91-9100000001', '2020-01-15', 75000.00),
(1, 'Sunita',  'Mehta',   'Receptionist',  'sunita@grandpalace.com',  '+91-9100000002', '2021-03-10', 30000.00),
(2, 'Deepak',  'Rao',     'Manager',       'deepak@seasideinn.com',   '+91-9100000003', '2019-06-01', 60000.00),
(2, 'Lavanya', 'Kumar',   'Housekeeping',  'lavanya@seasideinn.com',  '+91-9100000004', '2022-01-20', 22000.00),
(3, 'Amit',    'Thakur',  'Manager',       'amit@mvresort.com',       '+91-9100000005', '2018-11-05', 65000.00),
(4, 'Geeta',   'Agarwal', 'Receptionist',  'geeta@heritagehaveli.com','+91-9100000006', '2021-07-15', 28000.00),
(5, 'Naveen',  'Reddy',   'Manager',       'naveen@metrostay.com',    '+91-9100000007', '2020-09-01', 55000.00);

-- Services
INSERT INTO services (name, description, price) VALUES
('Room Service',     'Food & beverages delivered to room',   300.00),
('Airport Pickup',   'Car pickup from nearest airport',     1200.00),
('Spa & Massage',    'Relaxing full-body spa session',      2000.00),
('Laundry',          'Per kg laundry service',               150.00),
('Tour Package',     'Local sightseeing guided tour',       2500.00),
('Extra Bed',        'Additional bed in the room',           500.00);

-- Booking Services
INSERT INTO booking_services (booking_id, service_id, quantity) VALUES
(1, 1, 2),(1, 3, 1),
(2, 2, 1),(2, 5, 1),
(3, 1, 1),(3, 4, 2),
(8, 1, 3),(8, 3, 2),(8, 6, 1);

-- Reviews
INSERT INTO reviews (booking_id, rating, comments) VALUES
(1, 5, 'Outstanding stay! The deluxe room was immaculate and the staff were incredible.'),
(2, 4, 'Great suite, very comfortable. Room service could be a bit faster.'),
(3, 3, 'Decent hotel but the room felt a bit small. Good value for money though.');


-- ============================================================
-- 3. USEFUL QUERIES
-- ============================================================

-- Q1: List all available rooms with hotel name, room type, and price
SELECT 
    h.name         AS hotel_name,
    h.city,
    r.room_number,
    rt.type_name   AS room_type,
    rt.max_occupancy,
    rt.base_price
FROM rooms r
JOIN hotels    h  ON r.hotel_id     = h.hotel_id
JOIN room_types rt ON r.room_type_id = rt.room_type_id
WHERE r.is_available = TRUE
ORDER BY h.name, rt.base_price;

-- Q2: View all bookings with guest details and room info
SELECT 
    b.booking_id,
    CONCAT(g.first_name,' ',g.last_name) AS guest_name,
    h.name         AS hotel,
    r.room_number,
    rt.type_name   AS room_type,
    b.check_in,
    b.check_out,
    DATEDIFF(b.check_out, b.check_in)    AS nights,
    b.status,
    b.total_amount
FROM bookings b
JOIN guests     g  ON b.guest_id     = g.guest_id
JOIN rooms      r  ON b.room_id      = r.room_id
JOIN hotels     h  ON r.hotel_id     = h.hotel_id
JOIN room_types rt ON r.room_type_id = rt.room_type_id
ORDER BY b.check_in;

-- Q3: Total revenue per hotel
SELECT 
    h.name         AS hotel_name,
    COUNT(b.booking_id)     AS total_bookings,
    SUM(p.amount)           AS total_revenue
FROM hotels h
JOIN rooms    r  ON h.hotel_id   = r.hotel_id
JOIN bookings b  ON r.room_id    = b.room_id
JOIN payments p  ON b.booking_id = p.booking_id
WHERE p.status = 'completed'
  AND b.status != 'cancelled'
GROUP BY h.hotel_id, h.name
ORDER BY total_revenue DESC;

-- Q4: Most booked room types
SELECT 
    rt.type_name,
    COUNT(b.booking_id) AS total_bookings,
    SUM(b.total_amount) AS total_revenue
FROM bookings b
JOIN rooms      r  ON b.room_id      = r.room_id
JOIN room_types rt ON r.room_type_id = rt.room_type_id
WHERE b.status != 'cancelled'
GROUP BY rt.room_type_id, rt.type_name
ORDER BY total_bookings DESC;

-- Q5: Guest booking history with payment method
SELECT 
    CONCAT(g.first_name,' ',g.last_name) AS guest_name,
    g.email,
    b.check_in,
    b.check_out,
    b.status         AS booking_status,
    b.total_amount,
    p.method         AS payment_method,
    p.status         AS payment_status
FROM guests g
JOIN bookings b ON g.guest_id    = b.guest_id
JOIN payments p ON b.booking_id  = p.booking_id
ORDER BY g.last_name, b.check_in;

-- Q6: Bookings happening in a specific date range (next 30 days)
SELECT 
    b.booking_id,
    CONCAT(g.first_name,' ',g.last_name) AS guest,
    h.name     AS hotel,
    b.check_in,
    b.check_out,
    b.status
FROM bookings b
JOIN guests g ON b.guest_id  = g.guest_id
JOIN rooms  r ON b.room_id   = r.room_id
JOIN hotels h ON r.hotel_id  = h.hotel_id
WHERE b.check_in BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 30 DAY)
  AND b.status != 'cancelled'
ORDER BY b.check_in;

-- Q7: Average review rating per hotel
SELECT 
    h.name             AS hotel_name,
    COUNT(rv.review_id) AS total_reviews,
    ROUND(AVG(rv.rating), 2) AS avg_rating
FROM hotels h
JOIN rooms    r  ON h.hotel_id   = r.hotel_id
JOIN bookings b  ON r.room_id    = b.room_id
JOIN reviews  rv ON b.booking_id = rv.booking_id
GROUP BY h.hotel_id, h.name
ORDER BY avg_rating DESC;

-- Q8: Services used per booking with total cost
SELECT 
    b.booking_id,
    CONCAT(g.first_name,' ',g.last_name) AS guest,
    s.name             AS service,
    bs.quantity,
    (s.price * bs.quantity) AS service_cost
FROM booking_services bs
JOIN bookings b ON bs.booking_id = b.booking_id
JOIN guests   g ON b.guest_id    = g.guest_id
JOIN services s ON bs.service_id = s.service_id
ORDER BY b.booking_id;

-- Q9: Cancelled bookings and refund status
SELECT 
    b.booking_id,
    CONCAT(g.first_name,' ',g.last_name) AS guest,
    b.total_amount,
    p.status AS payment_status,
    b.booked_at
FROM bookings b
JOIN guests   g ON b.guest_id    = g.guest_id
JOIN payments p ON b.booking_id  = p.booking_id
WHERE b.status = 'cancelled';

-- Q10: Staff list per hotel with salary
SELECT 
    h.name        AS hotel,
    CONCAT(s.first_name,' ',s.last_name) AS staff_name,
    s.role,
    s.hire_date,
    s.salary
FROM staff s
JOIN hotels h ON s.hotel_id = h.hotel_id
ORDER BY h.name, s.role;

-- ============================================================
-- END OF PROJECT
-- ============================================================
