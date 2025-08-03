/*
Project Overview:
We are designing and implementing a robust database system tailored for the banking and finance industry. 
The system will efficiently manage customer accounts, financial transactions, loans, employee information, 
and departmental data, while supporting comprehensive financial reporting.
Key Requirements:
- Manage customer accounts, including personal information, account types, and current balances.
- Record and track financial transactions such as deposits, withdrawals, transfers, and payments.
- Maintain detailed loan records, including loan types, principal amounts, interest rates, and repayment schedules.
- Generate accurate financial reports, including balance sheets, income statements, and cash flow statements.
- Implement strong security protocols to safeguard sensitive financial and personal data.
To ensure data consistency and reduce redundancy, the database design will be normalized up to the Third Normal Form
 (3NF), promoting integrity and maintainability throughout the system.
 */

--Creating database--
CREATE DATABASE BankingandFinance; --The database name is BankingandFinance.

--Creating tables into BankingandFinance database system--
--Creating Customers tables--
CREATE TABLE customer(
                      customer_id INT PRIMARY KEY IDENTITY(1,1),
                      first_name  NVARCHAR(15) NOT NULL,
                      last_name NVARCHAR(15) NOT NULL,
                      email NVARCHAR(50) NOT NULL,
                      contact_number VARCHAR(20),
                      address VARCHAR(100) ,
                      date_of_birth DATE NOT NULL,
                      opening_date DATETIME DEFAULT GETDATE()

-- Constraints for data integrity
                      CONSTRAINT UQ_customer_email UNIQUE (email),
                      CONSTRAINT CHK_customer_contact CHECK (contact_number NOT LIKE '%[^0-9+]%'),
                      CONSTRAINT CHK_customer_email CHECK (email LIKE '%@%.%')
                    
);

--Creating Account table--
CREATE TABLE account( 
                     account_id INT PRIMARY KEY IDENTITY(1,1),
                     customer_id INT NOT NULL,
                     account_type NVARCHAR(15) NOT NULL ,
                     account_number VARCHAR(20) NOT NULL,
                     opening_date DATETIME NOT NULL ,
                     balance DECIMAL(18,2) DEFAULT 0.00,
                     closing_date DATETIME NULL

 -- Constraints
                    CONSTRAINT UQ_account_number UNIQUE (account_number),
                    CONSTRAINT CHK_account_type CHECK(account_type IN('Savings','Current','Business','Premium','Student','ISA','Joint','Basic')),
                    CONSTRAINT FK_account_customer FOREIGN KEY (customer_id)
                    REFERENCES customer(customer_id)
                    ON DELETE CASCADE /*The [ON DELETE CASCADE] in our foreign key constraint means
                    that when a record in the parent table is deleted,all related records in the 
                    child table will be automatically deleted too.*/
                    
);

/*Notice DEFAUlT GETDATE was not included in our openingdate column ?
In many banking systems,account opening might be bacdated or scheduled i.e accounts
are created in the system hours or even days after the actual agreement is signed */

--Creating Transacrtion table--
CREATE TABLE bank_transaction ( 

                         transaction_id INT PRIMARY KEY IDENTITY(1,1),
                         account_id INT NOT NULL,
                         transaction_type VARCHAR(20) NOT NULL,
                         amount DECIMAL(18,2) NOT NULL,
                         transaction_date DATETIME DEFAULT GETDATE(),
                         description NVARCHAR(100) NULL,

--Constriants
                         CONSTRAINT FK_transaction_account FOREIGN KEY (account_id)
                         REFERENCES account(account_id)
                         ON DELETE CASCADE,   

 -- Enforcing valid transaction types
                         CONSTRAINT CHK_transaction_type CHECK (
                         transaction_type IN (
                                               'Direct Debit',
                                               'Standing Order',
                                               'Bank Transfer',
                                               'ATM Withdrawal',
                                               'Salary',
                                               'Bill Payment',
                                               'Card Payment',
                                               'Refund'
                                              ))
);

--Creating Loan table --
CREATE TABLE loan(
                  loan_id INT PRIMARY KEY IDENTITY(1,1),
                  customer_id INT NOT NULL,
                  loan_type VARCHAR(20) NOT NULL,            
                  principal_amount DECIMAL(18,2) NOT NULL,
                  interest_rate FLOAT NOT NULL,
                  issue_date DATETIME DEFAULT GETDATE(),
                  due_date DATETIME NULL,
                  loan_status VARCHAR(20) NOT NULL DEFAULT 'Pending',
                 
 --Constraints 
                  CONSTRAINT FK_loan_customer FOREIGN KEY (customer_id) 
                  REFERENCES customer(customer_id)
                  ON DELETE CASCADE,
---- Loan status constraints
                  CONSTRAINT CHK_loan_status CHECK (
                  loan_status IN ( 'Active', 'Closed')
                  )                                               
);

--Creating Repayment
CREATE TABLE repayment(
                       repayment_id INT PRIMARY KEY IDENTITY(1,1),
                       loan_id INT NOT NULL,
                       payment_date DATETIME DEFAULT GETDATE(),
                       amount_paid DECIMAL(18,2) NOT NULL,
                       payment_method NVARCHAR(20) NOT NULL,
                       repayment_status VARCHAR(20) NOT NULL DEFAULT 'Pending'
--Constriants                       
                       CONSTRAINT FK_repayment_loan FOREIGN KEY (loan_id)
                       REFERENCES loan(loan_id)
                       ON DELETE CASCADE,
--Repayment constraints 
                       CONSTRAINT CHK_payment_method check(
                        payment_method in('Bank_Transfer','Direct_Debit','Cash','Online_payment'))

);
--creating Departmnet table for the employee--
CREATE TABLE department(
                        department_id INT PRIMARY KEY IDENTITY(1,1),
                        department_name VARCHAR(50) NOT NULL                       
);

--Creating employee table--
CREATE TABLE employee(
                      employee_id INT PRIMARY KEY IDENTITY(1,1),
                      full_name NVARCHAR(15) NOT NULL,
                      last_name NVARCHAR (15) NOT NULL,
                      contact_number VARCHAR(20),
                      job_title varchar(20) NOT NULL,
                      department_id INT NOT NULL,
                      hire_date DATE DEFAULT GETDATE(),
                      
                      
                      CONSTRAINT FK_employee_department FOREIGN KEY (department_id)
                      REFERENCES department(department_id)
);

--Adding manager_id to department table refrencing employee_id--
ALTER TABLE department
ADD manager_id INT,
     CONSTRAINT fk_department_manager FOREIGN KEY (manager_id)
     REFERENCES employee(employee_id)
     ON DELETE SET NULL;

--Creating Reporte Table --
/* This table is designed to store and track financial reports—such as balance sheets, income statements, 
and cash flow statements. These reports are usually generated periodically (monthly, quarterly, yearly) 
and are often tied to regulatory, analytical, or decision-making processes.*/

CREATE TABLE report(
                    report_id INT PRIMARY KEY IDENTITY(1,1),--A unique identitfy for eachb report
                    report_type VARCHAR(30) NOT NULL,--The kind of financial rerport (balance sheet,income statement,e.g)
                    generated_by INT NULL,--A forfeign key refrence to the employee_id in ther employee table 
                    report_date DATETIME DEFAULT GETDATE(),--the date the report was generated 
                    report_data VARCHAR(255) NOT NULL,--This store the content of the file refrencer of the report.

                    CONSTRAINT FK_report_employee FOREIGN key (generated_by)
                    REFERENCES employee(employee_id)
                    ON DELETE SET NULL, /*On delete set null ensure the report isn't deleted if the employee
                                    if the employee record is removed*/
                    CONSTRAINT CHK_report_type check( report_type in 
                    ('Balance Sheet','income Statement','Cash Flow'))
);

--populating data set into our tables (this data was generated with Chatgpt for database purpose only)
--50 UK CUSTOMER SAMPLE DATA SET 
-- Batch Insert: 50 UK Customers --

INSERT INTO customer (first_name,last_name,email,contact_number,address,date_of_birth,opening_date )
VALUES ( 'Emily', 'Thomas', 'tbell@yahoo.co.uk', '+44131 4960938', 'Flat 19, Scott place, West Nigel, BS5R 5SP', '1980-10-01', '2022-04-11 19:15:51'),
 ( 'Lesley', 'Williams', 'nelsonlorraine@gmail.com', '+44(0)1144960609', 'Flat 51, Kirsty forges, Port Patrick, W1B 8UE', '1992-02-19', '2023-02-07 01:48:01'),
 ( 'Iain', 'Cole', 'mandyfrench@hotmail.com', '(0151)4960196', '23 Ryan ridge, Aliceland, G2 1XR', '1992-01-18', '2024-12-31 07:22:00'),
 ( 'Zoe', 'Barker', 'cjackson@knowles-turner.com', '+44(0)114 496 0591', 'Flat 30, Hardy forges, Ronaldmouth, TW01 3BY', '1973-04-16', '2025-01-30 04:59:09'),
 ( 'Gail', 'Ford', 'lyndaburke@dickinson.com', '+44(0)113 496 0903', '30 Paige manors, Port Elliotland, E45 2BW', '1995-07-07', '2024-07-05 20:07:39'),
 ( 'Jodie', 'Spencer', 'elliotevans@outlook.com', '0161 496 0923', '5 Hardy mills, North Megan, KA9V 5RL', '1957-03-19', '2021-11-04 03:35:01'),
 ( 'Hollie', 'Brown', 'jordan84@smith.com', '028 9018 0459', 'Studio 6, David ranch, Lake Albert, L37 9SB', '1992-09-06', '2023-12-17 07:30:19'),
 ( 'Kirsty', 'Fletcher', 'katiecollins@fraser.net', '+44(0)20 74960007', 'Studio 0, Kay roads, Port Callumtown, SK65 3AA', '2002-04-18', '2025-01-12 00:37:48'),
 ( 'Nigel', 'Bates', 'leonard21@davis-frost.com', '(0113)4960471', '851 Ricky vista, North Simonborough, EX8N 9BZ', '1996-03-08', '2024-09-28 19:49:22'),
 ( 'Carly', 'Poole', 'shannon23@yahoo.co.uk', '+4420 7496 0402', 'Flat 55T, Declan tunnel, North Mathewburgh, M56 4EU', '2003-01-04', '2022-07-30 06:04:46'),
 ( 'Mohammad', 'Gardner', 'sophie54@griffiths-moore.info', '0161 4960551', '760 Goodwin spur, East Kayleigh, S1B 3JB', '1957-10-26', '2023-10-24 01:57:13'),
 ( 'Nigel', 'North', 'ywall@hotmail.co.uk', '01632960361', '92 Lucas crescent, Port Ritatown, W3B 6LH', '1955-01-26', '2020-11-23 07:36:30'),
 ( 'Sara', 'Lane', 'iowens@webb.info', '0116 4960966', 'Studio 7, Joanna ridge, North Maurice, SW5N 8FL', '1969-03-24', '2021-11-11 21:26:41'),
 ( 'Carole', 'Harris', 'robertsgeorgia@gmail.com', '(0114) 4960320', '52 Abbie mount, Leannefurt, B9B 6HN', '1980-04-29', '2025-02-02 23:49:54'),
 ( 'Helen', 'Mason', 'ojenkins@gmail.com', '029 2018 0024', 'Flat 7, Hewitt hollow, Cooperfurt, G2 4PB', '1995-04-09', '2020-11-04 03:43:10'),
 ( 'Helen', 'Dale', 'jayali@hall.com', '(0113)4960099', 'Flat 8, Chapman tunnel, Griffithston, W9S 1ZN', '1987-04-16', '2021-08-14 10:14:30'),
 ( 'Billy', 'Bell', 'iangill@hyde-bates.com', '+44(0)306 9990100', 'Flat 8, Bernard course, O''Sullivanville, S96 1SD', '1980-11-29', '2021-05-19 18:00:22'),
 ( 'Dean', 'Hunter', 'awilliams@hughes.com', '+441144960511', '52 Dale viaduct, Stevenberg, B31 4QA', '1982-10-14', '2022-07-08 23:49:48'),
 ( 'Christian', 'Price', 'lindsey42@gmail.com', '(0117)4960557', 'Studio 52, Timothy place, Charlesfurt, G35 3GN', '1964-03-10', '2023-09-15 17:04:21'),
 ( 'Cheryl', 'Parker', 'northrita@clarke.net', '+44(0)141 4960296', 'Flat 3, Parkinson route, South Michelletown, SS57 5NU', '1983-02-06', '2021-04-24 09:57:44'),
 ( 'Raymond', 'White', 'lmurray@williams-smith.info', '(0131) 496 0825', '34 Amelia mission, Baileyport, M8 6UD', '1967-02-26', '2024-10-08 17:58:44'),
 ( 'Dale', 'Dunn', 'julia01@hotmail.com', '+44(0)909 8790004', 'Studio 1, Nixon well, New Graham, E4 8PE', '2006-04-05', '2025-01-17 17:47:24'),
 ( 'Ben', 'Townsend', 'maria29@hotmail.co.uk', '(028) 9018381', 'Studio 44C, Pearce dam, North Bethan, S6 2XN', '1971-06-26', '2023-07-20 12:45:57'),
 ( 'Elaine', 'Cox', 'gjones@hughes-hayward.info', '(0121) 4960270', '76 Kerry cliff, Lake Aimeefurt, N0 9AL', '1997-07-20', '2023-01-10 08:38:58'),
 ( 'Julian', 'Davidson', 'stuartwilliams@outlook.com', '0131 496 0625', 'Flat 72, Clarke ferry, Stonefurt, TS76 3TH', '2004-01-06', '2025-07-11 19:09:51'),
 ( 'Adam', 'Howe', 'ashleighcunningham@evans.co.uk', '(029)2018239', '845 Hale roads, Jacksonfort, SO7 5LB', '2002-11-07', '2020-11-28 14:48:15'),
 ( 'Ben', 'Stone', 'davidsonanne@outlook.com', '+441174960968', 'Flat 59, Lynda corner, Brandonside, YO54 8BH', '1958-02-10', '2023-09-04 00:52:15'),
 ( 'Rhys', 'Taylor', 'reecesmith@outlook.com', '+441632960448', 'Studio 5, Samuel inlet, North Kellyfort, LA0P 7TE', '1959-12-27', '2021-04-07 12:16:16'),
 ( 'Cameron', 'Gibson', 'nyoung@osborne-summers.net', '0306 9990602', 'Flat 24, Newton mews, New Mitchellside, M78 8LL', '1960-01-30', '2022-07-05 15:39:20'),
 ( 'Terence', 'Richards', 'elizabethsmith@shaw-turner.com', '+44(0)1632 960 886', '41 Wilson stravenue, Rossbury, M5 5UN', '1955-08-30', '2025-06-27 21:52:04'),
 ( 'Ashley', 'Barker', 'fiona02@yahoo.co.uk', '(0116) 496 0281', '93 Wayne via, Port Jacqueline, PL9 7EZ', '1966-03-13', '2020-10-04 08:04:37'),
 ( 'Jodie', 'Evans', 'james38@outlook.com', '(0116)4960778', '29 Campbell view, Iainfurt, L0 3PT', '1990-05-11', '2022-06-17 09:54:16'),
 ( 'Leigh', 'Davies', 'evanssheila@gmail.com', '+441632 960250', '3 James fork, Josephton, SE6 3TS', '1972-03-26', '2021-09-29 20:41:03'),
 ( 'Graeme', 'Williamson', 'acooper@hotmail.com', '(0191) 4960870', 'Studio 2, Donna dam, North Hugh, G30 8GD', '1978-11-25', '2024-03-03 16:56:40'),
 ( 'Stuart', 'Houghton', 'jaynefoster@hotmail.com', '(0131) 496 0600', '42 Smith knolls, Lake Carol, FK7 0NW', '1995-03-22', '2022-12-28 00:06:53'),
 ( 'Pauline', 'Stewart', 'murphytrevor@yahoo.co.uk', '(0131) 4960700', '94 Debra path, Emmaview, E95 9XQ', '1991-12-29', '2021-12-02 12:58:49'),
 ( 'Mohamed', 'Baker', 'armstrongleigh@harris-harris.info', '+443069990696', '9 Angela crossroad, Johnfort, TW4Y 1XS', '1964-12-13', '2022-11-28 10:12:51'),
 ( 'Melanie', 'Thompson', 'howarthjulia@butler.com', '(0113) 496 0644', 'Flat 62, Denise drives, Evanston, S9U 0QW', '1966-05-13', '2021-11-20 00:09:11'),
 ( 'Gordon', 'Yates', 'elliottfrederick@hotmail.co.uk', '0118 4960426', 'Flat 78, Roy expressway, Bennettchester, IV4M 5ZP', '2000-10-28', '2021-04-23 02:06:18'),
 ( 'Robert', 'Hughes', 'patriciacooper@outlook.com', '(028) 9018609', 'Studio 29, Mills burg, Joneshaven, B19 5AD', '1975-06-06', '2022-02-28 05:23:34'),
 ( 'Jamie', 'Davies', 'mcleanpeter@hotmail.com', '(0141) 4960246', '48 Ben crossroad, South Diana, SP0Y 8RG', '2003-05-07', '2023-06-21 10:52:13'),
 ( 'Jake', 'Francis', 'reece45@walters.info', '(0116) 496 0782', '805 Alex rue, Morrisonmouth, G5S 7XB', '1994-05-28', '2025-02-27 22:19:50'),
 ( 'Maureen', 'Ward', 'rowejay@price.co.uk', '+44115 496 0250', '5 Samuel loop, Lake Graemefurt, G5 6BT', '1960-02-22', '2023-07-23 09:32:51'),
 ( 'Jasmine', 'Davey', 'bali@yahoo.co.uk', '0808 1570436', 'Flat 1, Bruce brooks, South Amber, SA0N 8UU', '1995-08-25', '2021-03-22 11:07:04'),
 ( 'Paula', 'Taylor', 'miahlewis@gmail.com', '0131 4960517', '400 Haynes plaza, East Clive, L95 7RB', '1958-01-20', '2022-06-18 23:48:48'),
 ( 'Heather', 'White', 'jaywilson@hall-hawkins.com', '01414960902', 'Studio 22b, Brandon pass, North Anthonyville, G2S 0SS', '1970-11-20', '2025-05-15 08:42:57'),
 ( 'Brett', 'Ellis', 'denise38@ford-miles.co.uk', '(0131)4960166', 'Studio 3, Smith orchard, Wallland, FY8 8AZ', '2001-03-31', '2024-07-28 21:21:50'),
 ( 'Martyn', 'Thomas', 'grobson@hotmail.co.uk', '+449098790026', 'Studio 66g, Butler estates, West Elaine, CW94 5QF', '1970-08-31', '2023-07-31 14:28:30'),
 ( 'Elaine', 'Yates', 'douglaswilliamson@duncan.net', '01514960064', '22 Molly knolls, North Sharon, S7B 6XX', '2006-09-02', '2021-09-18 04:45:00'),
 ( 'Carl', 'Martin', 'whittakervalerie@lyons-johnson.com', '(01632) 960 516', '85 Nicola streets, Damianfurt, IP7 6SE', '1966-01-19', '2021-11-06 00:27:00');

SELECT *
FROM customer;

--populating data into account table
INSERT INTO account ( customer_id,account_type, account_number, opening_date, balance,closing_date)
VALUES ( 4,'Joint', 'UK10000001', '2022-10-04', 15912.2, NULL),
 ( 5, 'Joint', 'UK10000002', '2025-04-27', 8580.01, NULL),
 ( 6, 'Current', 'UK10000003', '2025-01-09', 2102.09, NULL),
 ( 7,'ISA', 'UK10000004', '2022-10-15', 17120.92, NULL),
 ( 8,'Student', 'UK10000005', '2023-08-09', 1000.16, NULL),
 ( 9,'Savings', 'UK10000006', '2022-01-09', 631.27, NULL),
 ( 10,'Student', 'UK10000007', '2024-12-18', 12166.13, NULL),
 ( 11,'Savings', 'UK10000008', '2021-01-02', 7885.07, NULL),
 ( 12,'Joint', 'UK10000009', '2020-12-04', 16693.5, NULL),
 ( 13,'Savings', 'UK10000010', '2023-02-27', 824.2, NULL),
 ( 14, 'Current', 'UK10000011', '2022-07-24', 3972.36, NULL),
 ( 15, 'ISA', 'UK10000012', '2021-02-26', 14390.46, NULL),
 ( 16,'Basic', 'UK10000013', '2023-03-08', 4290.47, NULL),
 ( 17,'Current', 'UK10000014', '2025-06-29', 18745.69, NULL),
 ( 18,'Current', 'UK10000015', '2021-01-20', 10930.28, NULL),
 ( 19, 'Savings', 'UK10000016', '2020-12-08', 16734.46, NULL),
 ( 20, 'Savings', 'UK10000017', '2022-10-09', 4494.5, NULL),
 ( 21,'Business', 'UK10000018', '2022-03-05', 7070.85, NULL),
 ( 22, 'ISA', 'UK10000019', '2020-09-02', 1314.74, NULL),
 ( 23,'Basic', 'UK10000020', '2025-02-12', 883.64, NULL),
 ( 24,'Savings', 'UK10000021', '2020-09-17', 14016.53, NULL),
 ( 25, 'Premium', 'UK10000022', '2023-06-16', 4067.18, NULL),
 ( 26,'Joint', 'UK10000023', '2023-09-25', 18097.53, NULL),
 ( 27,'Basic', 'UK10000024', '2020-09-16', 16782.7, NULL),
 ( 28,'ISA', 'UK10000025', '2025-06-11', 13984.17, NULL),
 ( 29, 'Student', 'UK10000026', '2023-02-17', 19334.32, NULL),
 ( 30,'Current', 'UK10000027', '2023-07-10', 15794.1, NULL),
 ( 31,'ISA', 'UK10000028', '2024-01-02', 16923.95, NULL),
 ( 32,'Joint', 'UK10000029', '2023-09-17', 10636.54, NULL),
 ( 33,'Savings', 'UK10000030', '2021-09-17', 11976.15, NULL),
 ( 34,'Basic', 'UK10000031', '2022-09-10', 13345.56, NULL),
 ( 35,'Current', 'UK10000032', '2025-03-08', 9485.35, NULL),
 ( 36,'Premium', 'UK10000033', '2024-08-06', 18011.95, NULL),
 ( 37,'Business', 'UK10000034', '2023-07-03', 13013.78, NULL),
 ( 38,'Premium', 'UK10000035', '2024-02-05', 16769.46, NULL),
 ( 39,'Business', 'UK10000036', '2024-03-25', 3152.91, NULL),
 ( 40,'Current', 'UK10000037', '2021-12-15', 9213.29, NULL),
 ( 41,'Savings', 'UK10000038', '2023-02-02', 6784.74, NULL),
 ( 42,'Current', 'UK10000039', '2022-09-09', 10931.96, NULL),
 ( 43,'ISA', 'UK10000040', '2023-11-17', 4878.6, NULL),
 ( 44,'Basic', 'UK10000041', '2025-02-16', 7109.29, NULL),
 ( 45,'Business', 'UK10000042', '2021-04-13', 13500.73, NULL),
 ( 46,'ISA', 'UK10000043', '2021-11-16', 14340.83, NULL),
 ( 47,'Premium', 'UK10000044', '2025-06-07', 14994.87, NULL),
 ( 48,'Savings', 'UK10000045', '2021-03-09', 130.33, NULL),
 ( 49,'Student', 'UK10000046', '2024-05-14', 14001.8, NULL),
 ( 50,'ISA', 'UK10000047', '2021-01-12', 4864.38, NULL),
 ( 51,'Basic', 'UK10000048', '2023-11-01', 7635.1, NULL),
 ( 52,'Premium', 'UK10000049', '2022-04-08', 727.76, NULL),
 ( 53,'Premium', 'UK10000050', '2024-01-22', 15466.5, NULL);


--inserting data into our bank_transasction table --
INSERT INTO bank_transaction (account_id, transaction_type, amount, transaction_date, description)
VALUES   (25, 'Card Payment', 2276.28, '2025-06-17 02:24:34', 'HMRC tax refund'),
 (17, 'Refund', 2896.74, '2024-11-26 12:39:24', 'Local pub'),
 (20, 'Bill Payment', 2903.72, '2025-04-24 02:19:58', 'Parking fine'),
 (14, 'Salary', 1519.01, '2025-02-22 17:35:14', 'Train ticket purchase'),
 (49, 'Salary', 293.54, '2024-12-22 05:55:23', 'Savings transfer'),
 (46, 'Bank Transfer', 2432.55, '2024-02-10 15:00:20', 'Amazon UK order'),
 (7, 'Bill Payment', 2192.2, '2024-09-04 13:45:04', 'Credit card payment'),
 (36, 'Card Payment', 311.1, '2025-03-16 03:57:26', 'NHS charge'),
 (40, 'ATM Withdrawal', 1924.87, '2025-02-06 00:00:23', 'Savings transfer'),
 (31, 'Salary', 1333.65, '2024-01-30 21:26:10', 'HMRC tax refund'),
 (36, 'Standing Order', 2748.82, '2024-09-29 11:17:16', 'Local pub'),
 (46, 'Direct Debit', 2476.29, '2025-01-19 14:59:33', 'E.ON Energy bill'),
 (32, 'Bill Payment', 2485.91, '2023-12-15 14:04:41', 'Mobile phone top-up'),
 (47, 'Standing Order', 982.36, '2025-02-16 00:50:25', 'Utility bill'),
 (37, 'Bank Transfer', 672.89, '2024-09-24 20:26:42', 'Savings transfer'),
 (29, 'Bill Payment', 282.74, '2023-11-24 00:51:42', 'Mortgage payment'),
 (32, 'Salary', 336.08, '2024-05-13 01:46:45', 'Netflix subscription'),
 (36, 'ATM Withdrawal', 1004.92, '2023-08-04 19:46:53', 'E.ON Energy bill'),
 (36, 'Refund', 1766.98, '2025-02-24 04:36:10', 'Council Tax payment'),
 (39, 'Bill Payment', 2395.83, '2024-07-14 19:24:53', 'Parking fine'),
 (16, 'ATM Withdrawal', 878.09, '2025-02-20 00:24:53', 'Salary from employer'),
 (10, 'Salary', 1842.19, '2025-07-06 22:25:36', 'Credit card payment'),
 (5, 'Bank Transfer', 278.57, '2023-11-25 19:12:49', 'Train ticket purchase'),
 (19, 'Card Payment', 2528.96, '2024-11-18 18:06:36', 'Mortgage payment'),
 (18, 'ATM Withdrawal', 1570.15, '2025-05-28 22:22:09', 'Utility bill'),
 (44, 'Card Payment', 1773.51, '2025-05-28 19:41:34', 'Parking fine'),
 (18, 'Bill Payment', 1357.18, '2023-12-20 14:52:13', 'Council Tax payment'),
 (21, 'Refund', 1842.22, '2024-05-26 12:48:16', 'Parking fine'),
 (41, 'ATM Withdrawal', 1012.46, '2024-11-11 09:07:26', 'Mobile phone top-up'),
 (24, 'Standing Order', 2197.15, '2025-06-05 02:06:20', 'Mobile phone top-up'),
 (24, 'Bill Payment', 2385.8, '2024-03-02 22:06:30', 'Gym membership'),
 (4, 'Bank Transfer', 310.82, '2024-10-04 06:02:04', 'Mobile phone top-up'),
 (6, 'Standing Order', 2453.19, '2025-03-31 12:20:12', 'Tesco groceries'),
 (8, 'Standing Order', 1908.65, '2024-09-04 19:59:37', 'Local pub'),
 (6, 'Standing Order', 1116.72, '2023-11-27 06:41:23', 'HMRC tax refund'),
 (39, 'Bank Transfer', 74.69, '2023-09-08 02:05:27', 'Netflix subscription'),
 (31, 'Direct Debit', 639.62, '2024-12-19 11:17:05', 'Tesco groceries'),
 (35, 'Standing Order', 1282.6, '2023-09-12 03:23:20', 'Barclays ATM withdrawal'),
 (5, 'Salary', 670.28, '2023-09-11 04:49:54', 'Insurance payment'),
 (28, 'Refund', 549.15, '2023-08-23 02:01:52', 'HMRC tax refund'),
 (39, 'Card Payment', 311.75, '2025-07-05 09:17:53', 'Utility bill'),
 (17, 'Refund', 1082.08, '2025-01-22 15:20:59', 'Parking fine'),
 (11, 'ATM Withdrawal', 2096.11, '2025-01-09 04:08:28', 'HMRC tax refund'),
 (44, 'Bank Transfer', 483.04, '2025-04-28 15:26:11', 'NHS charge'),
 (34, 'Refund', 759.56, '2025-05-15 04:18:32', 'Salary from employer'),
 (7, 'Card Payment', 1420.16, '2024-03-23 06:47:45', 'Parking fine'),
 (33, 'Bill Payment', 2753.36, '2024-04-24 09:14:43', 'Local pub'),
 (43, 'Direct Debit', 760.29, '2024-10-30 14:23:06', 'Charity donation'),
 (48, 'Direct Debit', 246.43, '2024-11-21 01:13:54', 'Savings transfer'),
 (18, 'Refund', 413.16, '2024-08-21 08:42:05', 'Insurance payment');

--populating loan table with 25 customer data set

INSERT INTO loan (customer_id, loan_type, principal_amount, interest_rate, issue_date,due_date,loan_status)
VALUES ( 29, 'Personal', 13702.12, 4.13, '2024-06-11', '2027-04-20', 'Closed'),
 ( 39, 'Buy-to-Let', 1003.39, 3.66, '2023-02-21', '2030-06-08', 'Closed'),
 ( 30, 'Personal', 40643.25, 7.0, '2022-12-07', '2027-06-07', 'Closed'),
 ( 36, 'Debt Consolidation', 48950.02, 6.85,'2022-12-03', '2026-01-11', 'Active'),
 ( 26, 'Debt Consolidation', 21456.77, 3.51, '2023-04-04', '2024-06-02', 'Active'),
 ( 49, 'Personal', 49031.99, 6.2, '2023-05-23', '2032-06-07', 'Active'),
 ( 8, 'Business', 32814.01, 6.99, '2023-11-15', '2027-01-03', 'Closed'),
 ( 12, 'Personal', 24304.67, 7.19, '2023-02-06', '2031-10-27', 'Active'),
 ( 18, 'Education', 40191.4, 3.96, '2023-07-10', '2024-10-06', 'Closed'),
 ( 42, 'Business', 41046.39, 6.08, '2024-02-06', '2026-08-05', 'Active'),
 ( 18, 'Buy-to-Let', 1910.14, 3.66, '2024-01-18', '2026-10-11', 'Closed'),
 ( 21, 'Auto', 46983.5, 7.14, '2023-01-26', '2030-05-01', 'Active'),
 ( 45, 'Business', 33112.73, 6.35, '2022-09-19', '2032-02-12', 'Closed'),
 ( 28, 'Auto', 43699.13, 4.21, '2023-09-04', '2031-11-08', 'Closed'),
 ( 19, 'Personal', 7784.39, 4.59, '2024-07-06', '2032-02-04', 'Closed'),
 ( 24, 'Debt Consolidation', 5591.67, 6.62, '2022-07-29', '2032-06-05', 'Active'),
 ( 18, 'Home', 8321.39, 5.83, '2023-12-29', '2025-06-14', 'Closed'),
 ( 36, 'Home', 15376.94, 5.41, '2022-07-26', '2027-12-29', 'Active'),
 ( 20, 'Home', 42994.79, 6.41, '2023-11-12', '2025-05-27', 'Closed'),
 ( 22, 'Auto', 21321.36, 3.9, '2022-08-06', '2028-02-12', 'Closed'),
 ( 22, 'Buy-to-Let', 40095.84, 6.75, '2023-08-07', '2029-11-29', 'Active'),
 ( 8, 'Debt Consolidation', 25388.99, 3.65, '2024-06-18', '2030-11-01', 'Closed'),
 ( 44, 'Home', 46064.75, 6.01, '2023-09-04', '2032-11-29', 'Closed'),
 ( 6, 'Personal', 40580.86, 4.29, '2023-08-11', '2031-10-09', 'Active'),
 ( 25, 'Personal', 5805.75, 5.73, '2023-12-13', '2025-08-19', 'Closed'),
 ( 32, 'Buy-to-Let', 29659.55, 6.22, '2023-09-29','2029-10-09', 'Closed'),
 ( 24, 'Home', 49434.49, 4.54, '2022-11-05', '2024-10-12', 'Active'),
 ( 13, 'Auto', 6635.61, 6.79, '2022-12-17', '2028-10-17', 'Active'),
 ( 29, 'Buy-to-Let', 34169.13, 3.98, '2024-06-08', '2031-05-01', 'Closed'),
 ( 14, 'Debt Consolidation', 3062.97, 7.29, '2022-08-07', '2026-06-22', 'Active'),
 ( 10, 'Personal', 10700.53, 5.01, '2023-10-16', '2031-10-12', 'Active'),
 ( 39, 'Education', 8271.7, 5.12, '2024-06-06', '2026-08-09', 'Closed'),
 ( 32, 'Debt Consolidation', 45935.29, 4.79, '2022-09-07', '2029-07-11', 'Closed'),
 ( 41, 'Debt Consolidation', 43860.25, 5.67, '2023-11-28', '2030-07-01', 'Active'),
 ( 22, 'Debt Consolidation', 48165.76, 7.1, '2024-06-10', '2025-07-19', 'Closed'),
 ( 34, 'Home', 43849.68, 5.91, '2023-01-12', '2024-06-05', 'Active'),
 ( 38, 'Auto', 36188.45, 6.73, '2024-05-17', '2029-08-16', 'Active'),
 ( 6, 'Business', 43575.87, 3.66, '2024-01-07', '2033-12-26', 'Active'),
 ( 20, 'Auto', 1748.97, 6.88, '2023-02-25', '2025-08-12', 'Closed'),
 ( 10, 'Buy-to-Let', 33148.1, 7.37, '2022-09-04', '2025-06-23', 'Closed'),
 ( 33, 'Personal', 29119.75, 6.21, '2023-06-17', '2030-05-26', 'Active'),
 ( 28, 'Buy-to-Let', 11099.14, 5.64, '2022-07-17', '2031-12-01', 'Closed'),
 ( 25, 'Business', 29733.03, 6.91, '2022-09-02', '2029-01-28', 'Active'),
 ( 4, 'Debt Consolidation', 9916.48, 5.53, '2023-02-28', '2031-07-12', 'Closed'),
 ( 5, 'Education', 43134.29, 7.27, '2023-11-01', '2028-07-24', 'Closed'),
 ( 27, 'Education', 40691.84, 3.75, '2023-07-16', '2033-03-14', 'Active'),
 ( 19, 'Debt Consolidation', 41667.09, 3.72, '2023-12-30', '2027-09-03', 'Active'),
 ( 27, 'Home', 25099.72, 6.95, '2023-07-31', '2029-12-22', 'Active'),
 ( 45, 'Home', 40704.14, 4.91, '2022-08-28', '2031-03-17', 'Active'),
 ( 30, 'Education', 23485.23, 3.91, '2022-09-03', '2030-07-13', 'Active');

--populating data set into repayment table--

INSERT INTO repayment (loan_id, payment_date, amount_paid, payment_method,repayment_status)
VALUES ( 34, '2024-04-09', 896.03, 'Cash', 'Pending'),
( 7, '2023-07-27', 759.22, 'Online_payment', 'Pending'),
( 49, '2025-06-13', 688.92, 'Direct_Debit', 'Failed'),
( 18, '2024-11-14', 83.68, 'Online_payment', 'Pending'),
( 35, '2023-10-11', 372.9, 'Direct_Debit', 'Completed'),
( 5, '2023-10-04', 444.09, 'Online_payment', 'Pending'),
( 34, '2024-08-05', 177.7, 'Direct_Debit', 'Failed'),
( 7, '2024-12-22', 440.26, 'Cash', 'Failed'),
( 50, '2024-07-13', 908.84, 'Online_payment', 'Pending'),
( 29, '2025-04-06', 403.21, 'Direct_Debit', 'Completed'),
( 8, '2024-06-17', 712.18, 'Cash', 'Pending'),
( 38, '2024-10-10', 494.55, 'Online_payment', 'Pending'),
( 41, '2023-11-23', 499.03, 'Cash', 'Completed'),
( 31, '2025-04-07', 514.42, 'Online_payment', 'Pending'),
( 42, '2024-06-03', 960.5, 'Cash', 'Pending'),
( 10, '2024-03-09', 757.95, 'Bank_Transfer', 'Failed'),
( 14, '2025-05-01', 74.27, 'Cash', 'Pending'),
( 4,  '2024-08-19', 853.91, 'Bank_Transfer', 'Failed'),
( 6, '2023-08-25', 701.98, 'Cash', 'Completed'),
( 24, '2024-01-24', 89.12, 'Bank_Transfer', 'Pending'),
( 41, '2025-05-11', 714.7, 'Direct_Debit', 'Completed'),
( 49, '2023-11-22', 594.21, 'Direct_Debit', 'Completed'),
( 28, '2025-04-27', 487.85, 'Online_payment', 'Pending'),
( 11, '2025-01-02', 364.16, 'Cash', 'Completed'),
( 29, '2025-06-28', 936.57, 'Direct_Debit', 'Failed'),
( 21, '2023-08-08', 172.76, 'Direct_Debit', 'Pending'),
( 23, '2023-08-08', 799.87, 'Cash', 'Pending'),
( 32, '2024-10-22', 420.06, 'Direct_Debit', 'Completed'),
( 29, '2023-12-08', 943.03, 'Bank_Transfer', 'Pending'),
( 19, '2024-08-29', 272.33, 'Bank_Transfer', 'Completed'),
( 24, '2024-04-01', 104.14, 'Direct_Debit', 'Completed'),
( 40, '2024-06-14', 332.65, 'Bank_Transfer', 'Failed'),
( 33, '2023-10-19', 763.92, 'Online_payment', 'Pending'),
( 30, '2024-02-09', 101.24, 'Cash', 'Failed'),
( 30, '2024-06-16', 515.69, 'Cash', 'Completed'),
( 22, '2025-05-30', 302.58, 'Bank_Transfer', 'Completed'),
( 11, '2023-11-16', 382.31, 'Online_payment', 'Failed'),
( 5, '2025-06-11', 183.39, 'Cash', 'Failed'),
( 15, '2024-10-20', 972.14, 'Cash', 'Failed'),
( 15, '2024-03-16', 481.02, 'Online_payment', 'Failed'),
( 7, '2023-12-24', 626.04, 'Bank_Transfer', 'Pending'),
( 21, '2024-10-19', 559.11, 'Online_payment', 'Pending'),
( 6, '2023-11-04', 545.89, 'Direct_Debit', 'Pending'),
( 8, '2024-02-01', 249.11, 'Online_payment', 'Completed'),
( 13, '2025-04-26', 288.71, 'Online_payment', 'Pending'),
( 34, '2023-10-04', 866.99, 'Online_payment', 'Pending'),
( 23, '2023-08-28', 878.38, 'Direct_Debit', 'Completed'),
( 20, '2023-11-19', 937.47, 'Bank_Transfer', 'Completed'),
( 30, '2024-09-24', 520.54, 'Cash', 'Completed'),
( 27, '2025-06-16', 979.95, 'Cash', 'Pending');


--populating data into department table 
INSERT INTO department (department_name)
VALUES ('Finance'),
('Risk & Compliance'),
('Customer Service'),
('IT & Infrastructure'),
('Loans & Credit'),
('Marketing'),
('Operations'),
('Human Resources'),
('Data Analytics'),
('Treasury & Investments');


--populating employee data into employee table 
INSERT INTO employee (first_name, last_name, job_title, department_id, hire_date, contact_number)
VALUES ('Sarah', 'Tunde', 'Financial Analyst', 1, '2022-03-15', '07123456789'),-- Finance
('Jamie', 'Bennett', 'Senior Accountant', 1, '2020-06-18', '07455667788'),
('Elsie', 'Allen', 'Payroll Officer', 1, '2023-02-08', '07770998855'),
('Kamal', 'Adeyemi', 'Accountant', 1, '2024-09-10', '07334566778'),

-- Risk & Compliance
('Omar', 'Musa', 'Credit Risk Officer', 2, '2024-01-15', '07711223344'),
('Chika', 'Onye', 'Risk Analyst', 2, '2023-12-15', '07345678901'),
('Liam', 'Howard', 'Compliance Specialist', 2, '2021-05-01', '07422993344'),
('Salma', 'Nabi', 'Internal Auditor', 2, '2022-10-12', '07588122345'),

-- Customer Service
('Greg', 'Harper', 'Customer Rep', 3, '2023-05-20', '07234567890'),
('Grace', 'Foster', 'Customer Rep', 3, '2024-03-11', '07422113344'),
('Tayo', 'George', 'Service Manager', 3, '2022-07-15', '07118882345'),
('Kelly', 'Price', 'Helpdesk Officer', 3, '2024-01-09', '07366778899'),

-- IT & Infrastructure
('David', 'Cole', 'IT Support Officer', 4, '2021-08-10', '07987654321'),
('Henry', 'Williams', 'Database Administrator', 4, '2022-04-14', '07666334477'),
('Amrit', 'Chopra', 'Systems Engineer', 4, '2023-11-30', '07128765432'),
('Monica', 'Grant', 'Network Security Analyst', 4, '2024-06-05', '07544332100'),

-- Loans & Credit
('Lola', 'Chambers', 'Loan Advisor', 5, '2022-11-05', '07599887766'),
('Noah', 'Davis', 'Loan Processor', 5, '2024-06-01', '07993322110'),
('Victor', 'Owusu', 'Loan Underwriter', 5, '2023-08-01', '07701234567'),
('Freya', 'Nolan', 'Credit Support Officer', 5, '2023-01-20', '07244335511'),

-- Marketing
('Yasmin', 'Shah', 'Marketing Lead', 6, '2022-10-07', '07887776655'),
('Zara', 'Holmes', 'UX Designer', 6, '2024-02-18', '07338889900'),
('Josh', 'Carter', 'Campaign Manager', 6, '2023-06-12', '07651239876'),
('Abigail', 'Murray', 'Social Media Strategist', 6, '2024-05-14', '07455669988'),

-- Operations
('Anita', 'Kapoor', 'Operations Manager', 7, '2023-03-01', '07890123456'),
('Elijah', 'Reed', 'Facilities Coordinator', 7, '2022-05-25', '07115566778'),
('Sophie', 'Dixon', 'Logistics Officer', 7, '2023-07-01', '07321119900'),
('Ahmed', 'Mustafa', 'Operations Analyst', 7, '2024-02-27', '07224431155'),

-- Human Resources
('Emma', 'Watts', 'HR Assistant', 8, '2023-09-12', '07333445566'),
('Amira', 'Jones', 'Compensation Officer', 8, '2023-11-09', '07277665544'),
('Lewis', 'Taylor', 'Recruitment Lead', 8, '2022-08-18', '07491234576'),
('Renee', 'Douglas', 'Employee Relations Advisor', 8, '2024-04-10', '07188443322'),

-- Data Analytics
('Marcus', 'Obi', 'Data Analyst', 9, '2024-02-01', '07112233445'),
('Leo', 'Turner', 'Junior Analyst', 9, '2025-01-05', '07800112233'),
('Maya', 'Palmer', 'BI Developer', 9, '2023-06-30', '07577665511'),
('Stephen', 'Quinn', 'Data Quality Officer', 9, '2022-01-05', '07400998877'),

-- Treasury & Investments
('Rita', 'Mensah', 'Treasury Officer', 10, '2021-04-25', '07001112233'),
('Daniel', 'Okeke', 'Investment Officer', 10, '2021-07-22', '07991234567'),
('Lauren', 'Peters', 'Wealth Advisor', 10, '2023-09-01', '07233445500'),
('Tyler', 'Bates', 'Treasury Assistant', 10, '2024-06-14', '07345611228');

--we get an error message when trying to insert employee data into employee tabke
/* Msg 2628, Level 16, State 1, Line 1
String or binary data would be truncated in table 'BankingandFinance.dbo.employee', column 'job_title'. Truncated value: 'Compliance Specialis'.
The statement has been terminated.*/

/*This means -- the job_title column in employee table is defined with a length that’s too short to hold one or more of the job titles being 
inserted—specifically, 'Compliance Specialist', which is getting cut off.so we will have to change the to adjust the column length*/

--Adjusting column length 
ALTER TABLE employee
ALTER COLUMN job_title VARCHAR(50);

--Now we go back to run the employee table again
SELECT *
FROM department;
/*Employee_id start from (8) reason for this is because ones a transaction went or roll back it can be change 
While inserting data into the employee it fails from employee id 8 due to string length with job_title
SQL Server still consumed those identity values even though the rows weren’t saved.*/

--Updating department table by assigning one manager par department
UPDATE department
SET manager_id = CASE department_id
                 WHEN 1 THEN 8   -- Sarah Tunde – Financial Analyst
                 WHEN 2 THEN 12  -- Omar Musa – Credit Risk Officer
                 WHEN 3 THEN 16   -- Greg Harper – Customer Rep
                 WHEN 4 THEN 20  -- David Cole – IT Support Officer
                 WHEN 5 THEN 24  -- Lola Chambers – Loan Advisor
                 WHEN 6 THEN 28  -- Yasmin Shah – Marketing Lead
                 WHEN 7 THEN 32  -- Anita Kapoor – Operations Manager
                 WHEN 8 THEN 36  -- Emma Watts – HR Assistant
                 WHEN 9 THEN 40 -- Marcus Obi – Data Analyst
                 WHEN 10 THEN 44 -- Rita Mensah – Treasury Officer
                 ELSE manager_id
END;

--Inserting into report table
INSERT INTO report (report_type, generated_by, report_date, report_data)
VALUES ('Balance Sheet', 8, '2025-06-30', 'Q2_BalanceSheet_2025.pdf'),
('Income Statement',19 , '2025-07-01', 'June_Income_Statement_2025.xlsx'),
('Cash Flow', 10, '2025-07-02', 'CashFlow_June25_Report.csv'),
('Balance Sheet', 12, '2025-06-29', 'BranchBal_Summary_North.pdf'),
('Income Statement', 9, '2025-07-01', 'RetailDivision_IncomeReport.docx'),
('Cash Flow', 15, '2025-06-30', 'Forecasted_CashFlow_July.csv'),
('Balance Sheet', 20, '2025-07-01', 'TreasuryAssets_Q2.pdf'),
('Cash Flow', 33, '2025-07-02', 'CashFlowRegionals_West.csv'),
('Income Statement', 27, '2025-06-28', 'Ops_IncomeSnapshot_Q2.pdf'),
('Balance Sheet', 37, '2025-07-01', 'InvestmentPortfolio_Balance_June.xlsx'),
('Balance Sheet', 11, '2025-07-03', 'BalanceSheet_Regional_UnitA.pdf'),
('Income Statement', 17, '2025-07-04', 'Monthly_Income_KPI.xlsx'),
('Cash Flow', 21, '2025-07-05', 'CashOverview_Midlands.csv'),
('Balance Sheet', 29, '2025-07-03', 'HRDept_FinancialSnapshot_June.pdf'),
('Income Statement', 13, '2025-07-04', 'RiskDepartment_Income.xlsx'),
('Cash Flow', 35, '2025-07-02', 'DataAnalytics_CashProjection.csv'),
('Balance Sheet', 40, '2025-07-05', 'TreasuryAssets_Q3.pdf'),
('Income Statement', 25, '2025-07-06', 'Ops_Unit_Earnings_July2025.xlsx'),
('Cash Flow', 18, '2025-07-04', 'LoanCashPosition_Report.csv'),
('Balance Sheet', 16, '2025-07-01', 'Finance_Admin_BalSheet.docx');

--employee table doesn't have date of birth for this purpose we will create a column and populate it 

ALTER TABLE employee
ADD date_of_birth DATE;

--populating data into date of birth column--

UPDATE employee SET date_of_birth = '1992-04-10' WHERE employee_id = 8;
UPDATE employee SET date_of_birth = '1987-08-22' WHERE employee_id = 9;
UPDATE employee SET date_of_birth = '1990-06-15' WHERE employee_id = 10;
UPDATE employee SET date_of_birth = '1985-02-11' WHERE employee_id = 11;
UPDATE employee SET date_of_birth = '1996-12-03' WHERE employee_id = 12;
UPDATE employee SET date_of_birth = '1982-10-19' WHERE employee_id = 13;
UPDATE employee SET date_of_birth = '1994-07-28' WHERE employee_id = 14;
UPDATE employee SET date_of_birth = '1991-01-09' WHERE employee_id = 15;
UPDATE employee SET date_of_birth = '1989-11-26' WHERE employee_id = 16;
UPDATE employee SET date_of_birth = '1997-05-05' WHERE employee_id = 17;
UPDATE employee SET date_of_birth = '1993-09-17' WHERE employee_id = 18;
UPDATE employee SET date_of_birth = '1988-03-08' WHERE employee_id = 19;
UPDATE employee SET date_of_birth = '1992-02-14' WHERE employee_id = 20;
UPDATE employee SET date_of_birth = '1990-07-12' WHERE employee_id = 47;
UPDATE employee SET date_of_birth = '1986-05-23' WHERE employee_id = 44;
UPDATE employee SET date_of_birth = '1994-10-02' WHERE employee_id = 46;
UPDATE employee SET date_of_birth = '1985-01-20' WHERE employee_id = 41;
UPDATE employee SET date_of_birth = '1995-06-09' WHERE employee_id = 42;
UPDATE employee SET date_of_birth = '1987-12-30' WHERE employee_id = 43;
UPDATE employee SET date_of_birth = '1993-04-27' WHERE employee_id = 45;
UPDATE employee SET date_of_birth = '1986-09-02' WHERE employee_id = 21;
UPDATE employee SET date_of_birth = '1995-03-10' WHERE employee_id = 22;
UPDATE employee SET date_of_birth = '1989-08-04' WHERE employee_id = 23;
UPDATE employee SET date_of_birth = '1996-11-13' WHERE employee_id = 24;
UPDATE employee SET date_of_birth = '1983-04-17' WHERE employee_id = 25;
UPDATE employee SET date_of_birth = '1991-07-06' WHERE employee_id = 26;
UPDATE employee SET date_of_birth = '1990-01-25' WHERE employee_id = 27;
UPDATE employee SET date_of_birth = '1988-05-30' WHERE employee_id = 28;
UPDATE employee SET date_of_birth = '1992-08-29' WHERE employee_id = 29;
UPDATE employee SET date_of_birth = '1996-03-03' WHERE employee_id = 30;
UPDATE employee SET date_of_birth = '1985-09-14' WHERE employee_id = 31;
UPDATE employee SET date_of_birth = '1997-04-21' WHERE employee_id = 32;
UPDATE employee SET date_of_birth = '1984-10-01' WHERE employee_id = 33;
UPDATE employee SET date_of_birth = '1990-06-18' WHERE employee_id = 34;
UPDATE employee SET date_of_birth = '1994-01-16' WHERE employee_id = 35;
UPDATE employee SET date_of_birth = '1992-12-22' WHERE employee_id = 36;
UPDATE employee SET date_of_birth = '1986-02-08' WHERE employee_id = 37;
UPDATE employee SET date_of_birth = '1993-07-04' WHERE employee_id = 38;
UPDATE employee SET date_of_birth = '1989-02-28' WHERE employee_id = 39;
UPDATE employee SET date_of_birth = '1995-10-07' WHERE employee_id = 40;




