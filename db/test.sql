CREATE TABLE vacancies (
	`id` int(11) DEFAULT NULL auto_increment PRIMARY KEY,
	`title` varchar(255) NOT NULL, `description` text NOT NULL,
		 `external_id` int(11) DEFAULT NULL,
			 `industry` enum NOT NULL, `city` enum NOT NULL,
			 `salary_min` int(11) DEFAULT NULL, `salary_max` int(11) DEFAULT NULL, `employer_id` int(11) DEFAULT NULL, `employer_name` varchar(255) DEFAULT NULL, `created_at` datetime NOT NULL, `updated_at` datetime NOT NULL) ENGINE=InnoDB