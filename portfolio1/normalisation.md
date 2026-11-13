# Normalisation Explanation - Paynest Bank (simulated)

## 1\. Starting point: one messy table

Imagine the bank first stored everything in a single table:

|txn\_id|customer\_name|customer\_phones|account\_number|account\_type|branch\_name|branch\_city|amount|
|-|-|-|-|-|-|-|-|
|1|Ada Obi|0801111111, 0802222222|1000000001|Savings|Wuse Branch|Abuja|10000|
|2|Ada Obi|0801111111, 0802222222|1000000001|Savings|Wuse Branch|Abuja|5000|

Problems: Ada's details are repeated on every row, changing her phone number means editing many rows, and one cell holds two phone numbers.

## 2\. First Normal Form (1NF)

Rule: every cell holds one value, and there are no repeating groups.

`customer\\\_phones` holds two numbers in one cell, which breaks 1NF. In my design, each customer has one `phone` value, so every cell holds a single value.

## 3\. Second Normal Form (2NF)

Rule: it must be in 1NF, and every non-key column must depend on the whole primary key, not just part of it.

Customer details (name, phone) depend on the customer, not on the transaction. So I moved them into a separate `customers` table. Account details (account number, balance, status) moved to `accounts`. Each transaction now only stores `account\\\_id` and its own facts (type, amount, time, reference).

## 4\. Third Normal Form (3NF)

Rule: it must be in 2NF, and no non-key column should depend on another non-key column.

`branch\\\_city` depends on `branch\\\_name`, not on the customer. So branches live in their own `branches` table, and `customers` only stores `branch\\\_id`. In the same way, `min\\\_balance` and `interest\\\_rate` depend on the account type, so they live in `account\\\_types`.

## 5\. How my final tables follow these rules

|Table|Primary key|Foreign keys|What it stores|
|-|-|-|-|
|branches|branch\_id|none|Branch name and city|
|customers|customer\_id|branch\_id|Personal details|
|account\_types|type\_id|none|Type name, minimum balance, interest rate|
|accounts|account\_id|customer\_id, type\_id|Account number, balance, status|
|transactions|txn\_id|account\_id|Each deposit, withdrawal or transfer leg|
|transfers|transfer\_id|from\_account, to\_account|Transfer requests and their status|

Each fact is stored in one place only, so updating it once updates it everywhere.

## 6\. One deliberate exception

`accounts.balance` could be calculated by adding up all of an account's transactions, so storing it is technically redundant. I store it on purpose because reading one value is much faster than summing a very large ledger every time. To keep it trustworthy, I will check it with an audit query that compares each balance to the sum of its transactions.

## 7\. Keys and constraints (summary)

* Primary keys give every row a unique ID.
* Foreign keys stop a record pointing at something that doesn't exist (for example, an account for a customer who isn't in the database).
* `NOT NULL` makes sure important fields are filled in.
* `UNIQUE` on email, account number and transaction reference prevents duplicates.
* `CHECK` rules block bad data: no negative balances, no zero or negative amounts, only valid statuses and transaction types, and no transfer from an account to itself.

