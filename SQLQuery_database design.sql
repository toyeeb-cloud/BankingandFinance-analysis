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
                      date_of_birth DATE NOT NULL,
                      address VARCHAR(100) ,
                      contact_number VARCHAR(20),
                      email NVARCHAR(50) NOT NULL,
                      date_created DATETIME DEFAULT GETDATE()

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
                     closing_date DATETIME

 -- Constraints
                    CONSTRAINT UQ_account_number UNIQUE (account_number),
                    CONSTRAINT CHK_account_type CHECK(account_type IN('Savings','Current','Business'))
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
CREATE TABLE bank_transaction(
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
                         transaction_type IN ('Deposit', 'Withdrawal', 'Transfer', 'Payment'))

);

--Creating Loan table --
CREATE TABLE loan(
                  loan_id INT PRIMARY KEY IDENTITY(1,1),
                  customer_id INT NOT NULL,
                  loan_type VARCHAR(20) NOT NULL,            
                  principal_amount DECIMAL(18,2) NOT NULL,
                  interest_rate FLOAT NOT NULL,
                  start_date DATETIME DEFAULT GETDATE(),
                  loan_status VARCHAR(20) NOT NULL DEFAULT 'Pending',
                  end_date DATETIME NULL,
 --Constraints 
                  CONSTRAINT FK_loan_customer FOREIGN KEY (customer_id) 
                  REFERENCES customer(customer_id)
                  ON DELETE CASCADE,
---- Loan status constraints
                  CONSTRAINT CHK_loan_status CHECK (
                  loan_status IN ('Pending', 'Approved', 'Disbursed', 'Active', 'Closed', 'Defaulted', 'Rejected'))                                               
);

--Creating Repayment
CREATE TABLE repayment(
                       repayment_id INT PRIMARY KEY IDENTITY(1,1),
                       loan_id INT NOT NULL,
                       payment_date DATETIME DEFAULT GETDATE(),
                       amount_paid DECIMAL(18,2) NOT NULL,
                       payment_method NVARCHAR(20) NOT NULL,
--Constriants                       
                       CONSTRAINT FK_repayment_loan FOREIGN KEY (loan_id)
                       REFERENCES loan(loan_id)
                       ON DELETE CASCADE,
--Repayment constraints 
                       CONSTRAINT CHK_payment_method check(
                        payment_method in('Bank_Transfer', 'Card', 'Direct_Debit', 'Mobile_Pay', 'Cheque', 'Cash'))

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
                      job_title varchar(20) NOT NULL,
                      department_id INT NOT NULL,
                      hire_date DATE DEFAULT GETDATE(),
                      contact_number VARCHAR(20),
                      
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

--populating data set into our tables (this data was generated with Capilot for database purpose only)
--50 UK CUSTOMER SAMPLE DATA SET 
-- Batch Insert: 50 UK Customers --

INSERT INTO customer (first_name, last_name, date_of_birth, address, contact_number, email)
VALUES
('Olivia', 'Wilson', '1990-04-15', '22 High Street, London, SW1A 1AA', '07400112233', 'olivia.wilson@example.com'),
('James', 'Smith', '1985-09-03', '10 Queen’s Road, Manchester, M1 1AE', '07790123456', 'james.smith@example.com'),
('Amelia', 'Khan', '1998-02-22', '8 George St, Birmingham, B3 1QG', '07599775544', 'amelia.khan@example.com'),
('Thomas', 'Davies', '1978-12-11', '14 Castle Lane, Cardiff, CF10 1BX', '07812345678', 'thomas.davies@example.com'),
('Chloe', 'Patel', '1995-06-30', '35 Jubilee Ave, Leeds, LS9 7TY', '07654321098', 'chloe.patel@example.com'),
('Harry', 'Clark', '1983-07-09', '41 Kingsway, Liverpool, L1 8JQ', '07700551122', 'harry.clark@example.com'),
('Emily', 'Robinson', '1991-01-28', '7 Victoria Road, Sheffield, S10 1TY', '07411223344', 'emily.robinson@example.com'),
('Jacob', 'Thompson', '1987-11-12', '23 Princess St, Newcastle, NE1 3DF', '07555667788', 'jacob.thompson@example.com'),
('Isla', 'Ahmed', '1994-08-05', '55 Bridge End, Cambridge, CB2 1UA', '07880909090', 'isla.ahmed@example.com'),
('Leo', 'Scott', '1980-06-17', '12 Park View, Glasgow, G3 7YT', '07666554433', 'leo.scott@example.com'),
('Ava', 'Campbell', '2000-03-03', '89 Parkfield Rd, Southampton, SO17 3SG', '07332211005', 'ava.campbell@example.com'),
('Benjamin', 'Shaw', '1986-10-25', '10 Greenhill Close, Leicester, LE2 3UF', '07722334455', 'benjamin.shaw@example.com'),
('Freya', 'Walker', '1993-04-20', '2 Albion Place, Bristol, BS1 4RW', '07999332211', 'freya.walker@example.com'),
('Lucas', 'Morgan', '1979-09-01', '66 York Street, Belfast, BT1 1AA', '07551112233', 'lucas.morgan@example.com'),
('Sophie', 'Owen', '1997-12-30', '31 West End Lane, Brighton, BN1 4GG', '07444778899', 'sophie.owen@example.com'),
('George', 'Evans', '1992-02-10', '19 Abbey Road, Nottingham, NG1 5JW', '07882223344', 'george.evans@example.com'),
('Grace', 'Stewart', '1984-05-11', '5 London Road, York, YO1 9FY', '07366778899', 'grace.stewart@example.com'),
('Noah', 'Morris', '1996-06-06', '14 Riverside Drive, Swansea, SA1 3HD', '07997775533', 'noah.morris@example.com'),
('Lily', 'White', '1989-10-13', '17 Moor Lane, Chelmsford, CM1 1LL', '07655443322', 'lily.white@example.com'),
('Oscar', 'Reid', '1995-08-22', '21 Market Street, Norwich, NR2 1BH', '07433445566', 'oscar.reid@example.com'),
('Hannah', 'Knight', '1990-01-05', '44 Meadow Way, Oxford, OX1 3QT', '07455667788', 'hannah.knight@example.com'),
('Callum', 'Hughes', '1988-04-19', '29 Lincoln Drive, Derby, DE1 2PA', '07888990011', 'callum.hughes@example.com'),
('Poppy', 'Ellis', '1993-09-07', '12 College Rd, Coventry, CV1 5DF', '07577889900', 'poppy.ellis@example.com'),
('Finley', 'Green', '1985-06-24', '2 Trinity St, Wolverhampton, WV1 1JR', '07333445566', 'finley.green@example.com'),
('Millie', 'Watson', '1996-11-14', '6 Grosvenor Rd, Reading, RG1 8JX', '07677881234', 'millie.watson@example.com'),
('Theo', 'Marshall', '1991-10-12', '78 Clyde Street, Dundee, DD2 1DY', '07499887766', 'theo.marshall@example.com'),
('Maya', 'Sullivan', '1999-08-26', '91 Windmill Lane, Exeter, EX4 6AJ', '07992228855', 'maya.sullivan@example.com'),
('Ethan', 'Barnes', '1984-05-10', '55 Mill Road, Cambridge, CB1 2AW', '07233445522', 'ethan.barnes@example.com'),
('Jessica', 'Griffin', '1992-07-01', '14 Beacon Hill, Plymouth, PL4 7DA', '07551100999', 'jessica.griffin@example.com'),
('Reuben', 'Wallace', '1987-03-17', '20 Western Ave, York, YO10 4NN', '07477112233', 'reuben.wallace@example.com'),
('Phoebe', 'Barker', '1994-12-09', '11 Millstone Way, Canterbury, CT1 2NF', '07322334455', 'phoebe.barker@example.com'),
('Mason', 'Rhodes', '1990-02-28', '66 Springfield Road, Luton, LU2 7BZ', '07981234567', 'mason.rhodes@example.com'),
('Zara', 'Long', '1982-08-15', '4 Station Parade, Maidstone, ME14 1QD', '07745678912', 'zara.long@example.com'),
('Louis', 'Murray', '1997-01-30', '7 Elgar Crescent, Slough, SL1 1AP', '07600998877', 'louis.murray@example.com'),
('Layla', 'Hayes', '1995-04-04', '19 Maple Close, Woking, GU22 7QS', '07412349876', 'layla.hayes@example.com'),
('Imogen', 'Field', '1986-09-29', '3 Hamilton Rd, Basingstoke, RG21 6AX', '07570011223', 'imogen.field@example.com'),
('Kai', 'Parsons', '1983-11-11', '18 Market Hill, St Albans, AL1 3ZY', '07455667700', 'kai.parsons@example.com'),
('Ellie', 'Hopkins', '1990-06-16', '20 Tyndall Rd, Bristol, BS8 1TQ', '07390011234', 'ellie.hopkins@example.com'),
('Harvey', 'Sanders', '1998-02-19', '77 Church Street, Durham, DH1 3DF', '07889900112', 'harvey.sanders@example.com'),
('Sienna', 'Roberts', '1984-12-04', '55 Main Road, Lincoln, LN2 1AD', '07478789922', 'sienna.roberts@example.com'),
('Riley', 'Cunningham', '1991-03-23', '9 Watling St, Staines, TW18 4AL', '07665544338', 'riley.cunningham@example.com'),
('Georgia', 'Bailey', '1996-07-13', '6 Deansgate, Bolton, BL1 1HL', '07556667888', 'georgia.bailey@example.com'),
('Nathan', 'Perry', '1982-01-08', '25 Grafton St, Milton Keynes, MK9 1AA', '07788992244', 'nathan.perry@example.com'),
('Florence', 'Jordan', '1989-05-06', '33 Newton Rd, Peterborough, PE1 5PD', '07333221100', 'florence.jordan@example.com'),
('Jude', 'Saunders', '1993-08-29', '14 Canal Street, Lancaster, LA1 1AX', '07888776655', 'Jude.saunders@example.com');

SELECT *
FROM customer;

--populating data into account table
INSERT INTO account (customer_id, account_type, account_number, opening_date, balance)
VALUES
(1, 'Savings', 'ACC100001', '2024-06-01', 2500.00),
(2, 'Current', 'ACC100002', '2024-06-02', 4200.00),
(3, 'Savings', 'ACC100003', '2024-06-03', 1800.00),
(4, 'Business', 'ACC100004', '2024-06-04', 7000.00),
(5, 'Current', 'ACC100005', '2024-06-05', 3250.00),
(6, 'Savings', 'ACC100006', '2024-06-06', 1980.50),
(7, 'Current', 'ACC100007', '2024-06-07', 3660.00),
(8, 'Savings', 'ACC100008', '2024-06-08', 1555.75),
(9, 'Business', 'ACC100009', '2024-06-09', 8600.00),
(10, 'Savings', 'ACC100010', '2024-06-10', 2200.00),
(11, 'Savings', 'ACC100011', '2024-06-11', 1975.00),
(12, 'Current', 'ACC100012', '2024-06-12', 4150.50),
(13, 'Business', 'ACC100013', '2024-06-13', 11000.00),
(14, 'Savings', 'ACC100014', '2024-06-14', 2650.75),
(15, 'Current', 'ACC100015', '2024-06-15', 3820.20),
(16, 'Savings', 'ACC100016', '2024-06-16', 1890.90),
(17, 'Current', 'ACC100017', '2024-06-17', 4055.55),
(18, 'Business', 'ACC100018', '2024-06-18', 9800.00),
(19, 'Savings', 'ACC100019', '2024-06-19', 2100.00),
(20, 'Current', 'ACC100020', '2024-06-20', 3300.00),
(21, 'Savings', 'ACC100021', '2024-06-21', 2480.80),
(22, 'Current', 'ACC100022', '2024-06-22', 3005.90),
(23, 'Business', 'ACC100023', '2024-06-23', 10500.00),
(24, 'Savings', 'ACC100024', '2024-06-24', 2220.00),
(25, 'Current', 'ACC100025', '2024-06-25', 3775.75),
(26, 'Savings', 'ACC100026', '2024-06-26', 1999.99),
(27, 'Current', 'ACC100027', '2024-06-27', 3450.10),
(28, 'Business', 'ACC100028', '2024-06-28', 9150.00),
(29, 'Savings', 'ACC100029', '2024-06-29', 2310.25),
(30, 'Current', 'ACC100030', '2024-06-30', 3600.00),
(31, 'Savings', 'ACC100031', '2024-07-01', 2550.00),
(32, 'Current', 'ACC100032', '2024-07-02', 3025.40),
(33, 'Business', 'ACC100033', '2024-07-03', 8600.00),
(34, 'Savings', 'ACC100034', '2024-07-04', 2780.00),
(35, 'Current', 'ACC100035', '2024-07-05', 3925.00),
(36, 'Savings', 'ACC100036', '2024-07-06', 1850.60),
(37, 'Current', 'ACC100037', '2024-07-07', 3420.90),
(38, 'Business', 'ACC100038', '2024-07-08', 9700.00),
(39, 'Savings', 'ACC100039', '2024-07-09', 2090.00),
(40, 'Current', 'ACC100040', '2024-07-10', 3188.88),
(41, 'Savings', 'ACC100041', '2024-07-11', 2644.40),
(42, 'Current', 'ACC100042', '2024-07-12', 4100.50),
(43, 'Business', 'ACC100043', '2024-07-13', 8800.00),
(44, 'Savings', 'ACC100044', '2024-07-14', 2360.00),
(45, 'Current', 'ACC100045', '2024-07-15', 3555.00);

SELECT *
FROM account;
--ADDing  three closing date to our account table for better real life data experience 
UPDATE account
SET closing_date = CASE account_number
                   WHEN 'ACC100026' THEN '2025-06-30'
                   WHEN 'ACC100015' THEN '2025-03-18'
                   WHEN 'ACC100012' THEN '2025-05-22'
                   ELSE closing_date 
                   END
                   WHERE account_number IN ('ACC100026', 'ACC100015', 'ACC100012');


--inserting data into our bank_transasction table --
INSERT INTO bank_transaction (account_id, transaction_type, amount, transaction_date, description)
VALUES (11, 'Deposit', 1850.00, '2025-06-30', 'Monthly Pay - Admin Staff'),
(11, 'Withdrawal', 120.00, '2025-07-02', 'ATM - East Croydon'),
(11, 'Payment', 290.00, '2025-07-05', 'Council Tax Payment'),
(12, 'Deposit', 2400.00, '2025-06-29', 'Nursing Salary - NHS'),
(12, 'Payment', 180.00, '2025-07-01', 'Internet & TV - Virgin Media'),
(12, 'Withdrawal', 90.00, '2025-07-03', 'ATM - High Street'),
(13, 'Deposit', 2900.00, '2025-06-28', 'Small Business Income'),
(13, 'Transfer', 850.00, '2025-07-01', 'Rent - Commercial Unit'),
(13, 'Payment', 340.00, '2025-07-04', 'Wholesale Supply Invoice'),
(14, 'Deposit', 1350.00, '2025-06-30', 'Part-Time Salary'),
(14, 'Withdrawal', 110.00, '2025-07-02', 'Cash for Holiday'),
(14, 'Payment', 45.00, '2025-07-03', 'Train Travel - LNER'),
(15, 'Deposit', 2200.00, '2025-06-30', 'Freelance - Photography'),
(15, 'Payment', 320.00, '2025-07-01', 'Camera Equipment Rental'),
(15, 'Withdrawal', 160.00, '2025-07-03', 'ATM - Soho Square'),
(16, 'Deposit', 1750.00, '2025-06-30', 'Shift Work - Tesco'),
(16, 'Transfer', 500.00, '2025-07-02', 'Mum Allowance'),
(16, 'Payment', 215.00, '2025-07-04', 'Fuel + Insurance'),
(17, 'Deposit', 1950.00, '2025-06-28', 'Education Admin'),
(17, 'Payment', 330.00, '2025-07-01', 'Phone + Utilities'),
(17, 'Withdrawal', 100.00, '2025-07-03', 'ATM - Manchester Piccadilly'),
(18, 'Deposit', 3100.00, '2025-06-29', 'Building Contractor Pay'),
(18, 'Transfer', 1000.00, '2025-07-02', 'Mortgage Payment'),
(18, 'Payment', 280.00, '2025-07-04', 'DIY Tools - Screwfix'),
(19, 'Deposit', 1280.00, '2025-06-30', 'Caregiver Wage'),
(19, 'Payment', 55.00, '2025-07-01', 'GP Visit + Meds'),
(19, 'Transfer', 275.00, '2025-07-03', 'Credit Card Repayment'),
(20, 'Deposit', 2200.00, '2025-06-30', 'Retail Sales Bonus'),
(20, 'Payment', 160.00, '2025-07-01', 'Mobile Plan - O2'),
(20, 'Withdrawal', 80.00, '2025-07-03', 'Cash - ATM Newcastle'),
(21, 'Deposit', 1520.00, '2025-06-30', 'University Payroll'),
(21, 'Transfer', 480.00, '2025-07-02', 'Housing Deposit'),
(21, 'Payment', 200.00, '2025-07-04', 'Grocery - Aldi'),
(22, 'Deposit', 1850.00, '2025-06-30', 'Warehouse Shift Payment'),
(22, 'Payment', 85.00, '2025-07-01', 'Gym Membership - PureGym'),
(22, 'Withdrawal', 70.00, '2025-07-03', 'ATM - Liverpool Lime Street'),
(23, 'Deposit', 2750.00, '2025-06-30', 'Freelance IT Consulting'),
(23, 'Transfer', 900.00, '2025-07-01', 'Rent to Agent'),
(23, 'Payment', 310.00, '2025-07-03', 'Laptop Parts'),
(24, 'Deposit', 2000.00, '2025-06-30', 'NHS Junior Doctor'),
(24, 'Payment', 150.00, '2025-07-02', 'Travel Card'),
(24, 'Withdrawal', 125.00, '2025-07-04', 'ATM - Reading Station'),
(25, 'Deposit', 2300.00, '2025-06-29', 'Apprenticeship Pay'),
(25, 'Transfer', 300.00, '2025-07-01', 'Bike Purchase'),
(25, 'Payment', 60.00, '2025-07-03', 'Phone Bill'),
(26, 'Deposit', 1650.00, '2025-06-30', 'Retail Worker Salary'),
(26, 'Withdrawal', 90.00, '2025-07-01', 'ATM - Cardiff Bay'),
(26, 'Payment', 120.00, '2025-07-03', 'Streaming Subscriptions'),
(27, 'Deposit', 1870.00, '2025-06-30', 'Shift Supervisor Pay'),
(27, 'Transfer', 540.00, '2025-07-01', 'House Utilities Shared'),
(27, 'Payment', 190.00, '2025-07-04', 'Food - Lidl Superstore'),
(28, 'Deposit', 3000.00, '2025-06-30', 'Freelance Interior Design'),
(28, 'Withdrawal', 250.00, '2025-07-01', 'ATM - Walthamstow Central'),
(28, 'Payment', 450.00, '2025-07-03', 'Client Materials'),
(29, 'Deposit', 2150.00, '2025-06-30', 'Project Assistant Salary'),
(29, 'Transfer', 380.00, '2025-07-01', 'Saving Account Transfer'),
(29, 'Payment', 145.00, '2025-07-04', 'Shoes + Outfit'),
(30, 'Deposit', 1950.00, '2025-06-30', 'Graphic Designer Income'),
(30, 'Payment', 110.00, '2025-07-02', 'Software Subscription'),
(30, 'Withdrawal', 75.00, '2025-07-03', 'ATM - Bristol Temple Meads'),
(31, 'Deposit', 2650.00, '2025-06-30', 'Dental Assistant Salary'),
(31, 'Payment', 130.00, '2025-07-01', 'Pet Insurance'),
(31, 'Withdrawal', 90.00, '2025-07-02', 'ATM - Leeds Centre'),
(32, 'Deposit', 2850.00, '2025-06-30', 'Civil Engineer Pay'),
(32, 'Transfer', 700.00, '2025-07-01', 'Mortgage Repayment'),
(32, 'Payment', 95.00, '2025-07-03', 'Streaming Services'),
(33, 'Deposit', 3400.00, '2025-06-29', 'IT Consultant Invoice'),
(33, 'Withdrawal', 200.00, '2025-07-01', 'ATM - Hackney'),
(33, 'Payment', 440.00, '2025-07-03', 'Office Furniture'),
(34, 'Deposit', 1700.00, '2025-06-30', 'Part-Time Tutor Wages'),
(34, 'Payment', 60.00, '2025-07-02', 'Education Apps'),
(34, 'Transfer', 300.00, '2025-07-03', 'Savings Account Transfer'),
(35, 'Deposit', 1950.00, '2025-06-30', 'Clothing Sales'),
(35, 'Withdrawal', 130.00, '2025-07-01', 'ATM - Liverpool Street'),
(35, 'Payment', 210.00, '2025-07-03', 'Stock Resupply'),
(36, 'Deposit', 2450.00, '2025-06-30', 'Graphic Design Invoice'),
(36, 'Payment', 180.00, '2025-07-02', 'Adobe License Fee'),
(36, 'Transfer', 500.00, '2025-07-03', 'Business Savings'),
(37, 'Deposit', 1500.00, '2025-06-29', 'Graduate Salary'),
(37, 'Transfer', 200.00, '2025-07-01', 'Student Loan Repayment'),
(37, 'Withdrawal', 75.00, '2025-07-03', 'ATM - York Gate'),
(38, 'Deposit', 3050.00, '2025-06-30', 'Interior Architect Payment'),
(38, 'Payment', 500.00, '2025-07-01', 'Furniture Supply'),
(38, 'Withdrawal', 150.00, '2025-07-02', 'ATM - London Victoria'),
(39, 'Deposit', 1900.00, '2025-06-30', 'Temp Staffing Agency'),
(39, 'Payment', 160.00, '2025-07-01', 'Monthly Gym Fee'),
(39, 'Transfer', 350.00, '2025-07-03', 'Mum Support Transfer'),
(40, 'Deposit', 2850.00, '2025-06-29', 'Accountant Monthly Pay'),
(40, 'Withdrawal', 200.00, '2025-07-01', 'ATM - Slough High St'),
(40, 'Payment', 120.00, '2025-07-02', 'Utility - SSE Energy'),
(41, 'Deposit', 2500.00, '2025-06-30', 'Estate Agent Wages'),
(41, 'Transfer', 600.00, '2025-07-01', 'Partner Rent Support'),
(41, 'Payment', 140.00, '2025-07-02', 'Spotify Family Plan'),
(42, 'Deposit', 1700.00, '2025-06-30', 'Warehouse Driver Shift'),
(42, 'Payment', 85.00, '2025-07-01', 'Phone Bill - EE'),
(42, 'Withdrawal', 60.00, '2025-07-02', 'ATM - Canterbury'),
(43, 'Deposit', 3250.00, '2025-06-30', 'Sole Trader Income'),
(43, 'Payment', 900.00, '2025-07-01', 'Quarterly Tax'),
(43, 'Transfer', 300.00, '2025-07-03', 'Family Transfer'),
(44, 'Deposit', 1350.00, '2025-06-29', 'Support Worker Wage'),
(24, 'Withdrawal', 80.00, '2025-07-01', 'ATM - Basingstoke'),
(44, 'Payment', 50.00, '2025-07-03', 'Netflix & Amazon Prime'),
(45, 'Deposit', 2850.00, '2025-06-30', 'Creative Director Income'),
(33, 'Transfer', 950.00, '2025-07-01', 'Freelancer Payout'),
(45, 'Payment', 110.00, '2025-07-02', 'Software Tools'),
(27, 'Deposit', 2750.00, '2025-06-29', 'HR Consultant'),
(34, 'Transfer', 450.00, '2025-07-01', 'Pension Contribution'),
(42, 'Payment', 200.00, '2025-07-03', 'Healthcare Insurance'),
(23, 'Deposit', 1800.00, '2025-06-30', 'Bakery Cash Flow'),
(19, 'Withdrawal', 150.00, '2025-07-01', 'ATM - High Street'),
(42, 'Payment', 75.00, '2025-07-02', 'Baking Supplies'),
(17, 'Deposit', 3100.00, '2025-06-30', 'Fashion Store Sales'),
(40, 'Transfer', 800.00, '2025-07-01', 'Stock Restock'),
(34, 'Payment', 220.00, '2025-07-02', 'Website Hosting');

--populating loan table with 25 customer data set

INSERT INTO loan (customer_id, loan_type, principal_amount, interest_rate, start_date, loan_status, end_date)
VALUES(1, 'Personal', 5000.00, 5.5, '2024-06-01', 'Active', '2026-06-01'),
(2, 'Auto', 12000.00, 4.3, '2023-09-15', 'Approved', NULL),
(3, 'Mortgage', 150000.00, 3.2, '2023-01-10', 'Disbursed', '2043-01-10'),
(4, 'Business', 25000.00, 6.5, '2024-03-12', 'Active', '2029-03-12'),
(5, 'Education', 15000.00, 4.8, '2022-09-01', 'Closed', '2025-09-01'),
(6, 'Personal', 3000.00, 5.0, '2025-02-14', 'Pending', NULL),
(7, 'Auto', 10000.00, 3.9, '2024-07-20', 'Active', '2028-07-20'),
(8, 'Business', 18000.00, 6.2, '2023-05-01', 'Defaulted', NULL),
(9, 'Mortgage', 180000.00, 3.5, '2023-11-01', 'Active', '2043-11-01'),
(10, 'Education', 12000.00, 5.1, '2024-01-01', 'Disbursed', '2026-01-01'),
(11, 'Personal', 2500.00, 6.0, '2025-05-01', 'Rejected', NULL),
(12, 'Auto', 14500.00, 4.0, '2023-04-20', 'Active', '2028-04-20'),
(13, 'Business', 22000.00, 5.7, '2024-09-01', 'Approved', NULL),
(14, 'Personal', 4500.00, 6.8, '2024-03-15', 'Closed', '2026-03-15'),
(15, 'Education', 10000.00, 4.9, '2023-06-01', 'Active', '2027-06-01'),
(16, 'Auto', 15500.00, 3.6, '2024-10-01', 'Disbursed', '2029-10-01'),
(17, 'Mortgage', 175000.00, 3.1, '2022-12-01', 'Active', '2042-12-01'),
(18, 'Business', 30000.00, 5.9, '2024-06-01', 'Approved', NULL),
(19, 'Education', 13000.00, 4.5, '2025-01-10', 'Pending', NULL),
(20, 'Personal', 3500.00, 6.3, '2024-04-01', 'Closed', '2026-04-01'),
(21, 'Auto', 14000.00, 4.4, '2023-08-15', 'Active', '2028-08-15'),
(22, 'Business', 27500.00, 6.6, '2022-07-01', 'Defaulted', NULL),
(23, 'Mortgage', 160000.00, 3.0, '2023-05-01', 'Active', '2043-05-01'),
(24, 'Education', 11000.00, 5.2, '2023-09-10', 'Disbursed', '2026-09-10'),
(25, 'Personal', 4000.00, 5.4, '2025-02-28', 'Approved', NULL);

--populating data set into repayment table--

INSERT INTO repayment (loan_id, payment_date, amount_paid, payment_method)
VALUES (1, '2025-06-01', 250.00, 'Bank_Transfer'),
(1, '2025-07-01', 250.00, 'Bank_Transfer'),
(2, '2025-06-18', 400.00, 'Direct_Debit'),
-- Loan 3 - Mortgage
(3, '2025-05-01', 800.00, 'Direct_Debit'),
(3, '2025-06-01', 800.00, 'Direct_Debit'),

-- Loan 4 - Business
(4, '2025-03-12', 1200.00, 'Cheque'),
(4, '2025-06-12', 1200.00, 'Bank_Transfer'),

-- Loan 5 - Education (Closed)
(5, '2024-07-01', 500.00, 'Cash'),
(5, '2025-01-01', 500.00, 'Card'),

-- Loan 6 - Pending (no repayment expected)
-- (No entry)

-- Loan 7 - Auto
(7, '2025-07-20', 350.00, 'Direct_Debit'),

-- Loan 8 - Business (Defaulted)
(8, '2024-09-01', 700.00, 'Bank_Transfer'),

-- Loan 9 - Mortgage
(9, '2025-06-01', 900.00, 'Direct_Debit'),
(9, '2025-07-01', 900.00, 'Direct_Debit'),

-- Loan 10 - Education
(10, '2025-02-15', 300.00, 'Bank_Transfer'),

-- Loan 11 - Rejected (no payment)
-- (No entry)

-- Loan 12 - Auto
(12, '2025-05-20', 420.00, 'Mobile_Pay'),
(12, '2025-06-20', 420.00, 'Mobile_Pay'),

-- Loan 13 - Business (Approved, not disbursed)
-- (No entry)

-- Loan 14 - Personal (Closed)
(14, '2024-10-15', 250.00, 'Card'),
(14, '2025-01-15', 250.00, 'Bank_Transfer'),

-- Loan 15 - Education
(15, '2025-06-10', 400.00, 'Bank_Transfer'),

-- Loan 16 - Auto
(16, '2025-07-01', 450.00, 'Direct_Debit'),

-- Loan 17 - Mortgage
(17, '2025-05-01', 950.00, 'Direct_Debit'),
(17, '2025-06-01', 950.00, 'Direct_Debit'),

-- Loan 18 - Business (Approved, not disbursed)
-- (No entry)

-- Loan 19 - Education (Pending)
-- (No entry)

-- Loan 20 - Personal (Closed)
(20, '2024-06-01', 300.00, 'Cash'),
(20, '2024-12-01', 300.00, 'Card'),

-- Loan 21 - Auto
(21, '2025-06-15', 410.00, 'Direct_Debit'),

-- Loan 22 - Business (Defaulted)
(22, '2023-03-01', 700.00, 'Cheque'),

-- Loan 23 - Mortgage
(23, '2025-06-01', 920.00, 'Direct_Debit'),
(23, '2025-07-01', 920.00, 'Direct_Debit'),

-- Loan 24 - Education
(24, '2025-01-01', 260.00, 'Bank_Transfer'),
(24, '2025-07-01', 260.00, 'Card'),

-- Loan 25 - Personal
(25, '2025-06-28', 200.00, 'Mobile_Pay');



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
ADD  date_of_birth DATE;


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
