
DROP TABLE IF EXISTS `appointment`;
CREATE TABLE `appointment` (
  `appointment_ID` int(11) NOT NULL AUTO_INCREMENT,
  `patient_ID` int(11) NOT NULL,
  `staff_ID` int(11) NOT NULL,
  `appointment _start` datetime NOT NULL,
  `reason_for_visit` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `treatment_ID` int(11) DEFAULT NULL,
  PRIMARY KEY (`appointment_ID`),
  KEY `patient_ID` (`patient_ID`),
  KEY `staff_ID` (`staff_ID`),
  KEY `treatment_ID` (`treatment_ID`),
  CONSTRAINT `appointment_ibfk_1` FOREIGN KEY (`patient_ID`) REFERENCES `patient` (`patient_id`),
  CONSTRAINT `appointment_ibfk_2` FOREIGN KEY (`staff_ID`) REFERENCES `staff` (`staff_ID`),
  CONSTRAINT `appointment_ibfk_3` FOREIGN KEY (`treatment_ID`) REFERENCES `treatment` (`treatment_ID`)
) ;

DROP TABLE IF EXISTS `bill_payment`;
CREATE TABLE `bill_payment` (
  `bill_ID` int(11) NOT NULL AUTO_INCREMENT,
  `bill_amount` float(12,2) NOT NULL,
  `bill_paid` tinyint(1) NOT NULL,
  `patient_ID` int(11) NOT NULL,
  PRIMARY KEY (`bill_ID`),
  KEY `patient_ID` (`patient_ID`),
  CONSTRAINT `bill_payment_ibfk_1` FOREIGN KEY (`patient_ID`) REFERENCES `patient` (`patient_id`)
);

DROP TABLE IF EXISTS `diagnoses`;
CREATE TABLE `diagnoses` (
  `diagnosis_ID` int(11) NOT NULL AUTO_INCREMENT,
  `patient_ID` int(11) NOT NULL,
  `staff_ID` int(11) NOT NULL,
  `description` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`diagnosis_ID`),
  KEY `staff_ID` (`staff_ID`),
  KEY `patient_ID` (`patient_ID`),
  CONSTRAINT `diagnoses_ibfk_1` FOREIGN KEY (`staff_ID`) REFERENCES `staff` (`staff_ID`),
  CONSTRAINT `diagnoses_ibfk_2` FOREIGN KEY (`patient_ID`) REFERENCES `patient` (`patient_id`)
);

DROP TABLE IF EXISTS `insurance_provider`;
CREATE TABLE `insurance_provider` (
  `provider_ID` int(11) NOT NULL AUTO_INCREMENT,
  `provider_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`provider_ID`)
);

DROP TABLE IF EXISTS `lab_results`;
CREATE TABLE `lab_results` (
  `lab_ID` int(11) NOT NULL AUTO_INCREMENT,
  `patient_ID` int(11) NOT NULL,
  `requesting_staff_ID` int(11) NOT NULL,
  `description` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `results` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `testing_staff_ID` int(11) NOT NULL,
  PRIMARY KEY (`lab_ID`),
  KEY `patient_ID` (`patient_ID`),
  KEY `requesting_staff_ID` (`requesting_staff_ID`),
  KEY `testing_staff_ID` (`testing_staff_ID`),
  CONSTRAINT `lab_results_ibfk_1` FOREIGN KEY (`patient_ID`) REFERENCES `patient` (`patient_id`),
  CONSTRAINT `lab_results_ibfk_2` FOREIGN KEY (`requesting_staff_ID`) REFERENCES `staff` (`staff_ID`),
  CONSTRAINT `lab_results_ibfk_3` FOREIGN KEY (`testing_staff_ID`) REFERENCES `staff` (`staff_ID`)
);

DROP TABLE IF EXISTS `medication`;
CREATE TABLE `medication` (
  `medication_ID` int(11) NOT NULL AUTO_INCREMENT,
  `medication_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `medication_description` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `medication_dose` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`medication_ID`)
);

DROP TABLE IF EXISTS `on_call`;
CREATE TABLE `on_call` (
  `shift_ID` int(11) NOT NULL AUTO_INCREMENT,
  `shift_start` datetime NOT NULL,
  `shift_end` datetime NOT NULL,
  `on_call_staff_ID` int(11) NOT NULL,
  PRIMARY KEY (`shift_ID`),
  KEY `on_call_staff_ID` (`on_call_staff_ID`),
  CONSTRAINT `on_call_ibfk_1` FOREIGN KEY (`on_call_staff_ID`) REFERENCES `staff` (`staff_ID`)
);

DROP TABLE IF EXISTS `patient`;
CREATE TABLE `patient` (
  `patient_id` int(11) NOT NULL AUTO_INCREMENT,
  `patient_first_name` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `patient_last_name` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `patient_age` int(11) NOT NULL,
  `patient_date_of_birth` date NOT NULL,
  `insurance_provider_ID` int(11) NOT NULL,
  PRIMARY KEY (`patient_id`),
  KEY `insurance_provider_ID` (`insurance_provider_ID`),
  CONSTRAINT `patient_ibfk_2` FOREIGN KEY (`insurance_provider_ID`) REFERENCES `insurance_provider` (`provider_ID`)
);

DROP TABLE IF EXISTS `prescription`;
CREATE TABLE `prescription` (
  `prescription_ID` int(11) NOT NULL AUTO_INCREMENT,
  `prescriber_ID` int(11) NOT NULL,
  `patient_ID` int(11) NOT NULL,
  `medication_ID` int(11) NOT NULL,
  `regimen` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`prescription_ID`),
  KEY `prescriber_ID` (`prescriber_ID`),
  KEY `patient_ID` (`patient_ID`),
  KEY `medication_ID` (`medication_ID`),
  CONSTRAINT `prescription_ibfk_1` FOREIGN KEY (`prescriber_ID`) REFERENCES `staff` (`staff_ID`),
  CONSTRAINT `prescription_ibfk_2` FOREIGN KEY (`patient_ID`) REFERENCES `patient` (`patient_id`),
  CONSTRAINT `prescription_ibfk_3` FOREIGN KEY (`medication_ID`) REFERENCES `medication` (`medication_ID`)
);

DROP TABLE IF EXISTS `referals`;
CREATE TABLE `referals` (
  `referal_ID` int(11) NOT NULL,
  `patient_ID` int(11) NOT NULL,
  `refering_staff_ID` int(11) NOT NULL,
  `refered_staff_ID` int(11) NOT NULL,
  PRIMARY KEY (`referal_ID`),
  KEY `patient_ID` (`patient_ID`),
  KEY `refering_staff_ID` (`refering_staff_ID`),
  KEY `refered_staff_ID` (`refered_staff_ID`),
  CONSTRAINT `referals_ibfk_1` FOREIGN KEY (`patient_ID`) REFERENCES `patient` (`patient_id`),
  CONSTRAINT `referals_ibfk_2` FOREIGN KEY (`refering_staff_ID`) REFERENCES `staff` (`staff_ID`),
  CONSTRAINT `referals_ibfk_3` FOREIGN KEY (`refered_staff_ID`) REFERENCES `staff` (`staff_ID`)
);

DROP TABLE IF EXISTS `staff`;
CREATE TABLE `staff` (
  `staff_ID` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `field` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`staff_ID`)
);

DROP TABLE IF EXISTS `treatment`;
CREATE TABLE `treatment` (
  `treatment_ID` int(11) NOT NULL AUTO_INCREMENT,
  `medication_ID` int(11) NOT NULL,
  `description` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`treatment_ID`),
  KEY `medication_ID` (`medication_ID`),
  CONSTRAINT `treatment_ibfk_1` FOREIGN KEY (`medication_ID`) REFERENCES `medication` (`medication_ID`)
);
