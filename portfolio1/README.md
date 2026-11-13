# Portfolio 1 - Database Design

Case study: Paynest Bank (simulated)



## What is in this folder

|File|Description|
|-|-|
|case-study.md|the bank, its users, data and operations|
|er-diagram.drawio / er-diagram.png|ER diagram of the six tables|
|schema.sql|SQL that creates the tables, keys and constraints|
|normalisation.md|Explanation of 1NF, 2NF and 3NF for my design|
|01-bankdb-created.png|A screenshot of the bankdb database created in pgAdmin|
|02-tables-created.png|A Screenshot of the six tables created|

## 

## How I built and tested it

1. I created a PostgreSQL database called bankdb in pgAdmin 4.
2. I drew the ER diagram in draw.io.
3. I opened schema.sql in the pgAdmin Query Tool on bankdb and pressed F5.
4. I refreshed the Tables list and checked that all six tables appeared.

## 

## Keys and constraints

* Primary keys: every table has an ID column that is unique for each row.
* Foreign keys: customers link to branches, accounts link to customers and account types, transactions link to accounts, transfers link to two accounts.
* NOT NULL: important fields such as names and amounts cannot be empty.
* UNIQUE: email, account number and transaction reference cannot repeat.
* CHECK: balance cannot be negative, amounts must be above zero, and status values must be valid.

## 

## A challenge I faced

After installing PostgreSQL, pgAdmin 4 showed the error "pgAdmin server could not be contacted". I learned that pgAdmin runs its own helper server separate from the database, so the error did not mean PostgreSQL itself was broken. I worked through the suggested fixes (relaunching and waiting, restarting the laptop) until pgAdmin opened and connected. i restarted my computer and ran it as an administrator to fix.

Earlier, when cloning my private GitHub repository, the sign-in page said I was already logged in and showed no Authorize button, and Git kept waiting for authentication in the browser. I learned that a private repository needs Git to be authenticated, not just the browser, and I completed the sign-in so the clone could finish.

