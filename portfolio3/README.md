# Portfolio 3 - Transactions and Concurrency



Case study: Paynest Bank (simulated)
Database: PostgreSQL 18, database `bankdb`

## 

## Files

|File|What it is|
|-|-|
|transfer\_procedure.sql|The `transfer\\\\\\\\\\\\\\\_funds` stored procedure: a safe transfer between two accounts|
|transactions.sql|Every demo below, in order, with the expected result of each step|
|01 to 18 screenshots (.png)|Evidence for each demo (listed below)|

## 

## How to run

1. Run `schema.sql` (Portfolio 1) and `seed\\\\\\\\\\\\\\\_data.sql` (Portfolio 2) on `bankdb`.
2. Run `transfer\\\\\\\\\\\\\\\_procedure.sql`.
3. Open `transactions.sql` in the pgAdmin Query Tool and run it **one block at a time** (highlight, then F5). Do not run the whole file at once.
4. Demos 3 to 5 need two Query Tool tabs open at the same time, called Tab A and Tab B. Each tab is a separate database session.

## 

## Demos and evidence

|Demo|Screenshots|What I did|What it proves|
|-|-|-|-|
|Setup|01|Reset accounts 1 and 2 to 50000.|A known starting point for every demo.|
|1. COMMIT|02, 03|Ran `transfer\\\\\\\\\\\\\\\_funds(1, 2, 10000)` inside BEGIN, then COMMIT. Checked balances, the two ledger rows and the transfer record.|Durability and atomicity: the balance changes, ledger rows and transfer record were saved together.|
|2. ROLLBACK|04 to 07|Tried to transfer more than the balance (error), then ROLLBACK. Also changed a balance manually and rolled it back.|Atomicity: a failed or cancelled transaction leaves no trace.|
|3. Lost update|08, 08a, 08b, 09|Two tabs both read 1000. Tab A withdrew 800 and committed. Tab B withdrew 300 using its stale 1000.|Without control, the final balance was 700 and Tab A's update was lost.|
|4. FOR UPDATE|10, 11, 12|Tab A locked the row with `SELECT ... FOR UPDATE`. Tab B waited, then saw 200.|Isolation: the lock made Tab B wait. Final balance was 200 (correct).|
|5. Isolation levels|13 to 18|Compared REPEATABLE READ with READ COMMITTED while the other tab changed the balance.|REPEATABLE READ keeps a stable snapshot and refuses an unsafe update. READ COMMITTED shows the latest saved data.|

## 

## Key points in my own words

the lost update happened because Both tabs read 1000 before either one saved. Tab A saved 200. Tab B then calculated from its old 1000 and saved 700, overwriting A. FOR UPDATE fixed it when Tab A locked the row, so Tab B had to wait. When B continued, it saw the real balance of 200 instead of the stale 1000. REPEATABLE READ gives a stable snapshot, and refuses an update if the row changed (you got the "could not serialize access" error). It suits reports or checks that must see consistent data, as long as the application can retry. READ COMMITTED shows the latest saved data and is fine for simple everyday work.



A challenge I faced

Tab B showed 1000 right away instead of waiting, because the lock wasn't in place. i checked that Tab A had run BEGIN and FOR UPDATE together, and redid it. also

my computer shut down during the demos, which rolled back the open transactions, and i had to reopen everything and restart the demo.

