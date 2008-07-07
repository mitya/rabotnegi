CREATE TABLE `employers` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `login` varchar(255) default NULL,
  `password` varchar(255) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `ix_employers_login` (`login`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `resumes` (
  `id` int(11) NOT NULL auto_increment,
  `fname` varchar(30) NOT NULL,
  `lname` varchar(30) NOT NULL,
  `password` varchar(30) default NULL,
  `city` varchar(255) NOT NULL,
  `job_title` varchar(100) NOT NULL,
  `industry` varchar(255) NOT NULL,
  `min_salary` bigint(11) NOT NULL,
  `view_count` bigint(11) NOT NULL default '0',
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `simple_captcha_data` (
  `id` int(11) NOT NULL auto_increment,
  `key` varchar(40) default NULL,
  `value` varchar(6) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `vacancies` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `external_id` bigint(11) default NULL,
  `industry` varchar(255) NOT NULL,
  `city` varchar(255) NOT NULL,
  `salary_min` bigint(11) default NULL,
  `salary_max` bigint(11) default NULL,
  `employer_id` bigint(11) default NULL,
  `employer_name` varchar(255) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `uq_vacancies_external_id` (`external_id`),
  KEY `ix_vacancies_city` (`city`),
  KEY `ix_vacancies_industry` (`industry`),
  KEY `ix_vacancies_city_industry` (`city`,`industry`),
  KEY `fk_vacancies_employers` (`employer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7329 DEFAULT CHARSET=utf8;

INSERT INTO schema_migrations (version) VALUES ('1');