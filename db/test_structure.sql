CREATE TABLE `employers` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `login` varchar(255) default NULL,
  `password` varchar(255) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `ix_employers_login` (`login`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `resumes` (
  `id` int(11) NOT NULL auto_increment,
  `fname` varchar(30) NOT NULL,
  `lname` varchar(30) NOT NULL,
  `city` enum('msk','spb','ekb','nn','nsk') NOT NULL,
  `job_title` varchar(100) NOT NULL,
  `industry` enum('it','finance','transportation','logistics','service','wholesale','manufactoring','restaurant','retail','office','building','hr','marketing','medicine','realty','sales','publishing','insurance','telecom','executives','hospitality','telework','householding','law') NOT NULL,
  `min_salary` int(11) NOT NULL,
  `view_count` int(11) NOT NULL default '0',
  `job_reqs` text,
  `about_me` text,
  `contact_info` text,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `ix_resumes_lname_fname` (`lname`,`fname`),
  KEY `ix_resumes_city` (`city`),
  KEY `ix_resumes_industry` (`industry`),
  KEY `ix_resumes_city_industry` (`city`,`industry`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `schema_info` (
  `version` int(11) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `vacancies` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `external_id` int(11) default NULL,
  `industry` enum('it','finance','transportation','logistics','service','wholesale','manufactoring','restaurant','retail','office','building','hr','marketing','medicine','realty','sales','publishing','insurance','telecom','executives','hospitality','telework','householding','law') NOT NULL,
  `city` enum('msk','spb','ekb','nn','nsk') NOT NULL,
  `salary_min` int(11) default NULL,
  `salary_max` int(11) default NULL,
  `employer_id` int(11) default NULL,
  `employer_name` varchar(255) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `uq_vacancies_external_id` (`external_id`),
  KEY `ix_vacancies_city` (`city`),
  KEY `ix_vacancies_industry` (`industry`),
  KEY `ix_vacancies_city_industry` (`city`,`industry`),
  KEY `fk_vacancies_employers` (`employer_id`),
  CONSTRAINT `fk_vacancies_employers` FOREIGN KEY (`employer_id`) REFERENCES `employers` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO schema_info (version) VALUES (3)