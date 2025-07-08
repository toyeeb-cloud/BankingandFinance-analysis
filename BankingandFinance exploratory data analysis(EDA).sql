--Analysing Banking and finance data set after creation --
/* Selecting Data:
1.	Retrieve the account numbers and names of all account holders.
2.	Get the transaction IDs and amounts for all transactions.
3.	Fetch the loan IDs and amounts for all active loans.
4.	Retrieve the employee IDs and names of all bank staff.
5.	Get the balance amounts for all accounts
*/
EXEC sp_rename 'employee.full_name', 'first_name', 'COLUMN';
--1.	Retrieve the account numbers and names of all account holders.
SELECT
       ac.account_number,
       CONCAT(first_name,' ',last_name) AS full_name
FROM account AS ac
JOIN customer cs on ac.customer_id = cs.customer_id;

--2.Get the transaction IDs and amounts for all transactions.
SELECT 
      transaction_id,
      amount
FROM bank_transaction;

--3.Fetch the loan IDs and amounts for all active loans.
SELECT 
      loan_id,
      principal_amount,
      loan_status
FROM loan
WHERE loan_status = 'active';

--4.Retrieve the employee IDs and names of all bank staff.
SELECT 
      employee_id,
      CONCAT(first_name,'',last_name) as full_name
FROM employee;

--5.Get the balance amounts for all accounts
SELECT
     account_number,
     balance
FROM account:

/*--Filtering : 
6. Retrieve the account numbers and names of account holders with a balance greater than £3000 and more than 5 transactions.
7.	Get the transaction IDs and amounts for transactions exceeding £1000 in value and involving accounts with a balance below £5000.
8.	Fetch the loan IDs and amounts for loans with an interest rate above 5% and a remaining balance below $50,000.
9.	Retrieve the employee IDs and names of bank staff with more than 10 years of service and working in the 'Management' department.
10.	Get the balance amounts for accounts opened before January 1, 2010, and with a balance above $50,000.*/

---6. Retrieve the account numbers and names of account holders with a balance greater than £3000 and more than 2 transactions.
SELECT
     ac.account_number,
     CONCAT(cs.first_name,' ',cs.last_name) as full_name
FROM account ac
JOIN customer cs on ac.customer_id = cs.customer_id
JOIN bank_transaction bt on ac.account_id = bt.account_id
WHERE ac.balance > 3000 
GROUP BY ac.account_number,cs.first_name,cs.last_name
HAVING COUNT(bt.transaction_id) > 2 ;

--7.Get the transaction IDs and amounts for transactions exceeding £1000 in value and involving accounts with a balance below £5000.
SELECT
     bt.transaction_id,
     bt.amount,
     ac.balance
FROM bank_transaction bt
JOIN account ac on bt.account_id = ac.account_id
WHERE bt.amount > 1000 AND ac.balance < 5000;

--8.Fetch the loan IDs and amounts for loans with an interest rate above 5% and a remaining balance below £50,000.
SELECT
     l.loan_id,
     l.principal_amount,
     ISNULL(SUM(rp.amount_paid), 0) AS total_repaid,
    (l.principal_amount - ISNULL(SUM(rp.amount_paid), 0)) AS remaining_balance
FROM loan l
JOIN repayment rp on l.loan_id = rp.loan_id
WHERE l.interest_rate > 5.0 
GROUP BY l.loan_id,l.principal_amount
HAVING (l.principal_amount - ISNULL(SUM(rp.amount_paid), 0)) < 50000;

SELECT *
FROM employee;

--9 Retrieve the employee IDs and names of bank staff with more than 2 years of service and working in the 'Management' department.
SELECT
     employee_id,
     CONCAT(first_name,'',last_name) as full_name,
     dp.department_name
FROM employee emp
INNER JOIN department dp on emp.department_id = dp.department_id
WHERE hire_date <  DATEADD(YEAR,-2,GETDATE())
AND dp.department_name ='Data Analytics';

--10.	Get the balance amounts for accounts opened after January 1, 2024, and with a balance above £3000.

SELECT
     account_id,
     balance
FROM account 
where opening_date > 2024-01-01 and balance > 3000;


/*Sorting:
1.	Retrieve the account numbers and names of all account holders, sorted alphabetically by account names.
2.	Get the transaction IDs and amounts for all transactions, sorted in descending order of transaction amounts.
3.	Fetch the loan IDs and amounts for all active loans, sorted in ascending order of loan amounts.
4.	Retrieve the employee IDs and names of all bank staff, sorted alphabetically by employee names.
5.	Get the balance amounts for all accounts, sorted in descending order of balance amounts.*/

--1.Retrieve the account numbers and names of all account holders, sorted alphabetically by account names.

SELECT 
     account_number,
     CONCAT(first_name,' ',last_name) AS full_name
FROM account a
INNER JOIN customer c on a.customer_id = c.customer_id
ORDER BY full_name ASC;

--2.Get the transaction IDs and amounts for all transactions, sorted in descending order of transaction amounts.
SELECT 
     transaction_id,
     amount
FROM bank_transaction
ORDER BY amount DESC;

--3.Fetch the loan IDs and amounts for all active loans, sorted in ascending order of loan amounts.
SELECT
     loan_id,
     principal_amount
FROM loan
WHERE loan_status = 'Active'
ORDER BY principal_amount ASC;

--4.Retrieve the employee IDs and names of all bank staff, sorted alphabetically by employee names.
SELECT 
     employee_id,
     CONCAT(first_name,' ',last_name) AS full_name
FROM employee
ORDER BY full_name ASC;

--5 Get the balance amounts for all accounts, sorted in descending order of balance amounts.
SELECT 
     account_number,
     balance
FROM account
ORDER BY balance DESC;

-- DISTINCT:

--1.Retrieve distinct account types available in the bank.
SELECT
DISTINCT Account_type
FROM account;

--2.Get distinct transaction types for all transactions.
SELECT
DISTINCT transaction_type
FROM bank_transaction;

--3.Fetch distinct loan types for all active loans.
SELECT 
     DISTINCT loan_type
FROM loan
WHERE loan_status = 'active';

--4.Retrieve distinct department names for all bank staff.
SELECT 
     DISTINCT department_name
FROM department;

--5..Get distinct employee roles for all bank staff
SELECT 
    DISTINCT job_title
FROM employee;

--6. Monthly Totalinflow by Account Type
   SELECT 
       FORMAT(transaction_date, 'yyyy-MM') AS Month,
       a.account_type,
       SUM(t.amount) AS Total_Inflow
  FROM bank_transaction t
  JOIN account a ON t.account_id= a.account_id
  WHERE t.transaction_type in ('Payment','Deposit')
  GROUP BY FORMAT(transaction_date, 'yyyy-MM'), a.account_type
  ORDER BY Month;

  
