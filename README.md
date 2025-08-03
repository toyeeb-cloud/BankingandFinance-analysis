# Banking and finance SQL Analysis 
## Database Design for Operational Integrity
---
## 1.Introduction 
This project presents a comprehensive overview of the database design and implementation process within a banking and finance context. It outlines the strategic decisions behind schema architecture, data integrity enforcement, and normalization — all tailored to replicate real-world financial operations.
The documentation details the testing strategy used to validate functional accuracy, uphold constraints, and ensure reliable transactional workflows. It includes critical design decisions, defined jurisdiction and scope, core T-SQL statements, and supporting screenshots from SQL Server Management Studio (SSMS) to illustrate each stage of development.

# Project Overview 
This project presents a robust and thoughtfully designed relational database system that mirrors the operational dynamics of a modern banking environment. The is to create a secure and scalable backend architecture, and normalized data infrastructure that accurately reflects real-world financial activities that support customer account management, transactional integrity, loan handling, and real-time reporting.
Leveraging best practices in data normalization and constraint implementation, the system ensures regulatory compliance, audit-readiness, and high performance, also provides a foundational backend for financial analytics, regulatory compliance, and cross-platform integration.
By simulating UK-based customer behaviour using realistic datasets, this system becomes not only a technical demonstration but a practical foundation for strategic analytics and digital transformation in financial services.

### Project Aims
- Design a normalized database schema adhering to **Third Normal Form (3NF)** to ensure minimal redundancy and optimal data integrity  
- Capture essential banking operations: **customer onboarding**, **account lifecycle**, **transaction logging**, and **loan disbursement**  
- Enforce **referential integrity** with primary and foreign keys, including **cascading deletions**  
- Simulate **UK-specific financial behaviors** through realistic datasets 

 ## Database Design and Decisions
The database is efficiently designed to manage critical banking entities such as Customers, Accounts, Transactions, Loans, Repayments, Departments, Employees, and Reports, while supporting workflow coordination across the organization.
 ## Primary Design Consideration:
Normalization and Adherence to Third Normal Form (3NF)
To ensure data integrity, eliminate redundancy, and improve query performance, this system adheres strictly to the principles of Third Normal Form (3NF). The design satisfies 3NF criteria through the following implementations:
-  Atomic Data Structure: Each field holds a single, indivisible value, avoiding repeating groups and composite attributes.
-  Relational Integrity: All non-key attributes are fully functionally dependent on the primary key of their respective tables.
-  Elimination of Transitive Dependencies: Non-key attributes do not depend on other non-key attributes, ensuring clean and logical relationships across entities.
-  Logical Entity Separation: Entities like Customers, Accounts, and Transactions are separated into distinct tables to reflect real-world structures and streamline access control and analytics.
This foundation enables scalable integration with reporting tools (Power BI, SSRS), facilitates automation via Power Platform, and ensures the database remains robust under evolving financial workflows.

## Entity and Table Design 
The database to designed to store and manage data related to Customers,Accounts,Transactions,Loan,Repayments,Departments,Employees,and Reports.
The design follows the relational database model with normalized tables to ensure data integrity and minimize redundancy,
# Tables Created
- **Customers**:  Stores customer personal details and identifiers 
- **Accounts**:   Contains account-level data linked to customers
- **Transactions**: Records financial transactions tied to specific accounts
- **Loans**: Maintains loan application and disbursement details per customer
- **Rapayments**: Tracks repayments made against specific loans
- **Department**: Organizational units within the institution
- **Employmees**: Stores employee data, linked to departments
- **Report**: Aggregated financial or operational summaries (e.g. revenue, loan status)

![Screenshot 2025-07-06 164637](https://github.com/user-attachments/assets/90a78387-1437-44f9-bcc2-81f0f104517d)

## Implementation Process 

# Creating Databsae and Tables
The database schema was implemented using T-SQL (Transact-SQL), providing robust control over structure and constraints. Key steps included:
- Database Initialization: A new SQL Server database was created to house all banking-related entities.
- Table Creation: Normalized tables were designed for core entities such as Customers, Accounts, Transactions, Loans, Repayments, Departments, Employees, and Reports.
- Primary Keys: Each table was assigned a primary key to uniquely identify records and enforce entity integrity.
- Foreign Keys: Relationships between tables were established using foreign key constraints, ensuring referential integrity (e.g. linking Accounts to Customers, Transactions to Accounts, Repayments to Loans).
- Constraints & Validation: Additional constraints such as CHECK, NOT NULL, and UNIQUE were applied to enforce business rules and validate input data.
Example: Creating customer table...
```Sql
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
```
---
## Constraints and Business Rules

To support data integrity and implement realistic business logic, this database includes a range of `CHECK`, `UNIQUE`, and `DEFAULT` constraints in addition to foreign key relationships.

###  Check Constraints

| Constraint | Table       | Description                                                                 |
|------------|-------------|-----------------------------------------------------------------------------|
| `CHK_account_type` | `account`    | Limits values to allowed types such as `('Savings','Current','Business','Premium','Student','ISA','Joint','Basic')`. |
| `CHK_transactions_type` | `bank_transaction`| - Restricts transaction_type values to predefined categories such as `'Direct Deposit'`,`'ATM Withdrawal'`,`'Bank Transfer'`,`'Card Payment'`.
.                          |

###  Unique Constraints

| Constraint               | Table       | Description                                                   |
|--------------------------|-------------|---------------------------------------------------------------|
| `UQ_Customers_Email`     | `Customer` | Ensures email addresses are unique per customer.              |
| `UQ_account_number` | `account` | Guarantees each account number is unique in the system.       |

###  Default Constraints

| Column         | Table        | Default Value | Description                                                    |
|----------------|--------------|----------------|----------------------------------------------------------------|
| `loan_status`| `loan`  | `'pending'`     | Sets new loan to pending untill it got approved .        |
|`opening_date`   | `account`   | `GETDATE()`    | Captures the account creation timestamp.                       |


These constraints align closely with business processes in real-world financial systems—enabling data validation at the schema level and minimizing the risk of inconsistent or invalid entries.

## Sample query and cases 

### 1.Monthly TotalInflow by Account Type
```sql 
   SELECT 
       FORMAT(transaction_date, 'yyyy-MM') AS Month,
       a.account_type,
       SUM(t.amount) AS Total_Inflow
  FROM bank_transaction t
  JOIN account a ON t.account_id= a.account_id
  WHERE t.transaction_type in ('Payment','Deposit')
  GROUP BY FORMAT(Transaction_date, 'yyyy-MM'), a.account_type
  ORDER BY Month;
```
### 2. Fetch the loan IDs and amounts for loans with an interest rate above 5% and a remaining balance below £50,000.
```sql
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
```









