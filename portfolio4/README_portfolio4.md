# Portfolio 4 - NoSQL and Advanced Data Models



Case study: Paynest Bank (simulated)
Database: MongoDB Community Server, database `bankdb\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_nosql` (document model)



## Files

|File|What it is|
|-|-|
|mongo-model.md|The document model, why MongoDB suits this data, and where SQL is better|
|mongo\_demo.js|All the commands I ran (insert, find, update, aggregate, index)|
|Screenshots 01 to 14 (.png)|Evidence for each step (listed below)|

## 

## How to run

1. Install MongoDB Community Server and MongoDB Compass.
2. In Compass, connect to `mongodb://localhost:27017`, then open the MongoDB shell from the connection.
3. Paste the numbered sections of `mongo\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_demo.js` into the shell one at a time.

## 

## Evidence

|Screenshots|What it shows|
|-|-|
|01|Compass connected to Local MongoDB|
|02, 03|Inserting the customer profiles and the transaction logs|
|04, 05|The two collections and their documents|
|06, 07, 08|Find queries: ATM transactions, amount above 15000, unverified customers|
|09, 10|Update: flagging a suspicious withdrawal|
|11|Aggregation: total amount per channel|
|12, 13, 14|Query plan before the index, creating the index, and the plan after|

## 

## Why MongoDB for this part of the bank

In MongoDB I stored the customer profiles and the transaction logs of the Paynest bank. I chose MongoDB for these because their structure changes from record to record. A profile holds KYC details, devices and alert preferences that differ between customers, and each log has different fields depending on the channel: ATM logs have an atm field, POS logs have a pos field, and branch deposits have a branch field. In PostgreSQL this would need many empty columns or several extra tables. I kept balances, transfers and the ledger in PostgreSQL because money needs strict rules such as ACID transactions, foreign keys and CHECK constraints, which Portfolio 3 showed. When I flagged the ATM-310 withdrawal, I added the flagged and flag\_reason fields to that one document without changing any other document, which would have meant altering the whole table in SQL.

## 

## A challenge I faced

When I started Portfolio 4, the MongoDB download page did not show the Windows version, so I had to change the platform and package options and download the Windows installer. After installing, Compass opened on a welcome screen and I could not find the shell, because it was not at the bottom of the window as I expected. I found it by opening the shell from the connection's menu, and I checked it worked by running db.version(). After inserting the data, the new database did not appear in the sidebar because there was no refresh button, so I confirmed the inserts from the shell by counting the documents and listing the collections. I learned that a database tool can look different between versions, and that I can check my work from the command line when the interface does not update.

