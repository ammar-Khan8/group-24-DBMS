-- =====================================================
-- Pet Adoption & Fostering Network  |  CSE3001
-- Schema.sql : database + tables + constraints
-- Run order: Schema.sql -> Views_Indexes_Triggers_Procedures.sql -> Data.sql
-- =====================================================
DROP DATABASE IF EXISTS pet_adoption_network;
CREATE DATABASE pet_adoption_network CHARACTER SET utf8mb4;
USE pet_adoption_network;

CREATE TABLE shelters (
    shelter_id   INT AUTO_INCREMENT PRIMARY KEY,
    name         VARCHAR(100) NOT NULL,
    address      VARCHAR(200),
    city         VARCHAR(60)  NOT NULL,
    phone        VARCHAR(20),
    capacity     INT NOT NULL CHECK (capacity > 0)
);

CREATE TABLE animals (
    animal_id    INT AUTO_INCREMENT PRIMARY KEY,
    name         VARCHAR(60) NOT NULL,
    species      ENUM('Dog','Cat','Rabbit','Bird','Other') NOT NULL,
    breed        VARCHAR(60),
    size         ENUM('Small','Medium','Large') NOT NULL,
    age_months   INT CHECK (age_months >= 0),
    gender       ENUM('Male','Female','Unknown') NOT NULL DEFAULT 'Unknown',
    status       ENUM('Available','Fostered','Adopted','Unavailable') NOT NULL DEFAULT 'Available',
    intake_date  DATE NOT NULL,
    shelter_id   INT NULL,                       -- optional shelter link
    CONSTRAINT fk_animal_shelter FOREIGN KEY (shelter_id)
        REFERENCES shelters(shelter_id) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE adopters (
    adopter_id        INT AUTO_INCREMENT PRIMARY KEY,
    full_name         VARCHAR(100) NOT NULL,
    email             VARCHAR(120) NOT NULL UNIQUE,
    phone             VARCHAR(20),
    address           VARCHAR(200),
    home_type         ENUM('Apartment','House','Farm') DEFAULT 'Apartment',
    preferred_species ENUM('Dog','Cat','Rabbit','Bird','Other'),
    preferred_size    ENUM('Small','Medium','Large')
);

CREATE TABLE foster_homes (
    foster_home_id INT AUTO_INCREMENT PRIMARY KEY,
    name           VARCHAR(100) NOT NULL,
    phone          VARCHAR(20),
    address        VARCHAR(200),
    max_capacity   INT NOT NULL CHECK (max_capacity > 0)
);

CREATE TABLE fostering (
    fostering_id   INT AUTO_INCREMENT PRIMARY KEY,
    animal_id      INT NOT NULL,
    foster_home_id INT NOT NULL,
    start_date     DATE NOT NULL,
    end_date       DATE NULL,
    status         ENUM('Active','Completed','Cancelled') NOT NULL DEFAULT 'Active',
    CONSTRAINT fk_foster_animal FOREIGN KEY (animal_id) REFERENCES animals(animal_id),
    CONSTRAINT fk_foster_home   FOREIGN KEY (foster_home_id) REFERENCES foster_homes(foster_home_id),
    CONSTRAINT chk_foster_dates CHECK (end_date IS NULL OR end_date >= start_date)
);

CREATE TABLE adoption_applications (
    application_id   INT AUTO_INCREMENT PRIMARY KEY,
    adopter_id       INT NOT NULL,
    animal_id        INT NOT NULL,
    application_date DATE NOT NULL,
    status ENUM('Pending','Under Review','Approved','Rejected','Withdrawn') NOT NULL DEFAULT 'Pending',
    CONSTRAINT fk_app_adopter FOREIGN KEY (adopter_id) REFERENCES adopters(adopter_id),
    CONSTRAINT fk_app_animal  FOREIGN KEY (animal_id)  REFERENCES animals(animal_id)
);

CREATE TABLE home_visits (
    visit_id       INT AUTO_INCREMENT PRIMARY KEY,
    application_id INT NOT NULL,
    visit_date     DATE NOT NULL,
    status         ENUM('Scheduled','Completed','Cancelled') NOT NULL DEFAULT 'Scheduled',
    observations   TEXT,
    recommendation ENUM('Recommended','Not Recommended','Pending') NOT NULL DEFAULT 'Pending',
    CONSTRAINT fk_visit_app FOREIGN KEY (application_id)
        REFERENCES adoption_applications(application_id) ON DELETE CASCADE
);

CREATE TABLE adoptions (
    adoption_id    INT AUTO_INCREMENT PRIMARY KEY,
    application_id INT NOT NULL UNIQUE,          -- one adoption per application
    animal_id      INT NOT NULL,
    adopter_id     INT NOT NULL,
    adoption_date  DATE NOT NULL,
    adoption_fee   DECIMAL(8,2) NOT NULL DEFAULT 0 CHECK (adoption_fee >= 0),
    status         ENUM('Completed','Returned') NOT NULL DEFAULT 'Completed',
    CONSTRAINT fk_adopt_app     FOREIGN KEY (application_id) REFERENCES adoption_applications(application_id),
    CONSTRAINT fk_adopt_animal  FOREIGN KEY (animal_id)  REFERENCES animals(animal_id),
    CONSTRAINT fk_adopt_adopter FOREIGN KEY (adopter_id) REFERENCES adopters(adopter_id)
);

CREATE TABLE medical_records (
    record_id         INT AUTO_INCREMENT PRIMARY KEY,
    animal_id         INT NOT NULL,
    exam_date         DATE NOT NULL,
    exam_type         ENUM('Vaccination','Check-up','Deworming','Surgery','Other') NOT NULL,
    diagnosis         VARCHAR(200),
    treatment         VARCHAR(200),
    vet_name          VARCHAR(80),
    next_checkup_date DATE NULL,
    followup_status   ENUM('Pending','Done','Not Required') NOT NULL DEFAULT 'Pending',
    CONSTRAINT fk_med_animal FOREIGN KEY (animal_id) REFERENCES animals(animal_id) ON DELETE CASCADE
);

CREATE TABLE medical_alerts (
    alert_id   INT AUTO_INCREMENT PRIMARY KEY,
    record_id  INT NOT NULL UNIQUE,              -- one alert per record
    alert_date DATE NOT NULL,
    message    VARCHAR(255) NOT NULL,
    CONSTRAINT fk_alert_record FOREIGN KEY (record_id) REFERENCES medical_records(record_id) ON DELETE CASCADE
);
