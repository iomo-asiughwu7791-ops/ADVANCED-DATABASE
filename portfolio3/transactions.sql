-- Paynest Bank (simulated) - Portfolio 3: Transactions and Concurrency
-- Run each numbered block separately in the pgAdmin Query Tool (highlight, then F5).
-- Requires: schema.sql, seed_data.sql and transfer_procedure.sql already run on bankdb.


UPDATE accounts SET balance = 50000 WHERE account_id IN (1,2);
SELECT account_id, balance FROM accounts WHERE account_id IN (1,2) ORDER BY account_id;
-- Expected: both accounts at 50000.00


-- =====================================================
-- Demo 1: successful transfer (COMMIT)
-- =====================================================

-- 1A. Start the transfer (not saved yet)
BEGIN;
CALL transfer_funds(1, 2, 10000);
SELECT account_id, balance FROM accounts WHERE account_id IN (1,2) ORDER BY account_id;
-- Expected: account 1 = 40000.00, account 2 = 60000.00 (inside the transaction)

-- 1B. Save it
COMMIT;

-- 1C. Prove it was saved
SELECT account_id, balance FROM accounts WHERE account_id IN (1,2) ORDER BY account_id;

SELECT txn_id, account_id, txn_type, amount, reference
FROM transactions
ORDER BY txn_id DESC
LIMIT 2;
-- Expected: one TRANSFER_OUT (account 1) and one TRANSFER_IN (account 2)

SELECT * FROM transfers ORDER BY transfer_id DESC LIMIT 1;
-- Expected: status = COMPLETED


-- =====================================================
-- Demo 2: failed transfer (ROLLBACK)
-- =====================================================

-- 2A. Check the starting balances
SELECT account_id, balance FROM accounts WHERE account_id IN (1,2) ORDER BY account_id;
-- Expected: 40000.00 and 60000.00

-- 2B. Try to send more money than the account has
BEGIN;
CALL transfer_funds(1, 2, 999999999);
-- Expected: ERROR: Insufficient funds in account 1

-- 2C. Undo everything
ROLLBACK;

SELECT account_id, balance FROM accounts WHERE account_id IN (1,2) ORDER BY account_id;
-- Expected: balances unchanged (40000.00 and 60000.00)


-- =====================================================
-- Demo 2 (manual): change a balance, then ROLLBACK
-- =====================================================
BEGIN;
UPDATE accounts SET balance = 0 WHERE account_id = 1;
SELECT account_id, balance FROM accounts WHERE account_id = 1;
-- Expected: 0.00 (inside the transaction only)

ROLLBACK;
SELECT account_id, balance FROM accounts WHERE account_id = 1;
-- Expected: back to 40000.00


-- =====================================================
-- Demo 3: lost update (the problem)
-- Tab A and Tab B are two separate Query Tool sessions (two tellers).
-- Run each step in the tab shown, in this exact order.
-- =====================================================

-- Reset (Tab A)
UPDATE accounts SET balance = 1000 WHERE account_id = 1;
SELECT account_id, balance FROM accounts WHERE account_id = 1;
-- Expected: 1000.00

-- Step 1 (Tab A): start a transaction and read the balance
BEGIN;
SELECT balance FROM accounts WHERE account_id = 1;
-- Expected: 1000.00

-- Step 2 (Tab B): also start a transaction and read the balance
BEGIN;
SELECT balance FROM accounts WHERE account_id = 1;
-- Expected: 1000.00 (A has not saved anything yet)

-- Step 3 (Tab A): withdraw 800 and save
UPDATE accounts SET balance = 1000 - 800 WHERE account_id = 1;
COMMIT;

-- Step 4 (Tab B): withdraw 300 using the old balance it read earlier, and save
UPDATE accounts SET balance = 1000 - 300 WHERE account_id = 1;
COMMIT;

-- Step 5 (either tab): check the result
SELECT account_id, balance FROM accounts WHERE account_id = 1;
-- Expected: 700.00. A total of 1100 was withdrawn from an account holding 1000,
-- so Tab A's update was lost. This is the lost update problem.


-- =====================================================
-- Demo 4: the fix using SELECT ... FOR UPDATE (row locking)
-- Tab A takes the lock first; Tab B has to wait for it.
-- =====================================================

-- Before starting: run ROLLBACK; in both tabs, then reset (Tab A)
UPDATE accounts SET balance = 1000 WHERE account_id = 1;
SELECT account_id, balance FROM accounts WHERE account_id = 1;
-- Expected: 1000.00

-- Step 1 (Tab A): start a transaction and lock the row
BEGIN;
SELECT balance FROM accounts WHERE account_id = 1 FOR UPDATE;
-- Expected: 1000.00 (row is now locked by Tab A)

-- Step 2 (Tab B): try to lock the same row
BEGIN;
SELECT balance FROM accounts WHERE account_id = 1 FOR UPDATE;
-- Expected: no result yet. Tab B waits because Tab A holds the lock.

-- Step 3 (Tab A): withdraw 800 and release the lock
UPDATE accounts SET balance = 200 WHERE account_id = 1;
COMMIT;

-- Step 4 (Tab B): nothing to type. The waiting query finishes by itself.
-- Expected: Tab B now shows 200.00 (not the old 1000.00)

-- Step 5 (Tab B): 300 cannot be withdrawn from 200, so cancel
ROLLBACK;

-- Step 6: check the final balance
SELECT account_id, balance FROM accounts WHERE account_id = 1;
-- Expected: 200.00. No update was lost. Compare with Demo 3, which ended at 700.00.


-- =====================================================
-- Demo 5: isolation levels
-- Same two tabs. Compare REPEATABLE READ with the default READ COMMITTED.
-- =====================================================

-- Setup: run ROLLBACK; in both tabs, then reset (Tab A)
UPDATE accounts SET balance = 1000 WHERE account_id = 1;
SELECT account_id, balance FROM accounts WHERE account_id = 1;
-- Expected: 1000.00

-- ---------- Part 1: REPEATABLE READ ----------

-- Step 1 (Tab A): start with a frozen snapshot and read
BEGIN ISOLATION LEVEL REPEATABLE READ;
SELECT balance FROM accounts WHERE account_id = 1;
-- Expected: 1000.00

-- Step 2 (Tab B): change the balance (auto-saved, no BEGIN)
UPDATE accounts SET balance = 500 WHERE account_id = 1;
SELECT balance FROM accounts WHERE account_id = 1;
-- Expected: 500.00

-- Step 3 (Tab A): read again
SELECT balance FROM accounts WHERE account_id = 1;
-- Expected: still 1000.00 (Tab A sees its own snapshot)

-- Step 4 (Tab A): try to change the row
UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
-- Expected: ERROR: could not serialize access due to concurrent update

-- Step 5 (Tab A): clean up
ROLLBACK;

-- ---------- Part 2: READ COMMITTED (default) ----------

-- Reset (Tab A)
UPDATE accounts SET balance = 1000 WHERE account_id = 1;
SELECT account_id, balance FROM accounts WHERE account_id = 1;
-- Expected: 1000.00

-- Step 1 (Tab A): start a normal transaction and read
BEGIN;
SELECT balance FROM accounts WHERE account_id = 1;
-- Expected: 1000.00

-- Step 2 (Tab B): change the balance (auto-saved)
UPDATE accounts SET balance = 500 WHERE account_id = 1;

-- Step 3 (Tab A): read again
SELECT balance FROM accounts WHERE account_id = 1;
-- Expected: 500.00 (Tab A sees Tab B's saved change)

-- Step 4 (Tab A): clean up
ROLLBACK;

-- Put the test accounts back to a clean state
UPDATE accounts SET balance = 50000 WHERE account_id IN (1,2);
