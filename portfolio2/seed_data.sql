-- Paynest Bank (simulated) - Portfolio 2 seed data
-- All data below is synthetic (randomly generated), not real people.
-- Safe to re-run: it clears the tables first.

TRUNCATE transfers, transactions, accounts, customers, account_types, branches RESTART IDENTITY CASCADE;

INSERT INTO branches (branch_name, city) VALUES
 ('Wuse Branch','Abuja'),
 ('Ikeja Branch','Lagos'),
 ('Port Harcourt Main','Port Harcourt'),
 ('Kano Central','Kano'),
 ('Enugu Main','Enugu');

INSERT INTO account_types (type_name, min_balance, interest_rate) VALUES
 ('Savings',0,3.00),
 ('Current',5000,0.00),
 ('Fixed Deposit',100000,8.00);

-- 50,000 customers
INSERT INTO customers (first_name, last_name, email, phone, date_of_birth, branch_id)
SELECT 'First'||g, 'Last'||g, 'user'||g||'@example.com',
       '080'||lpad(g::text,8,'0'),
       DATE '1960-01-01' + (random()*15000)::int,
       1 + (g % 5)
FROM generate_series(1,50000) g;

-- 80,000 accounts
INSERT INTO accounts (account_number, customer_id, type_id, balance)
SELECT (1000000000 + g)::text, 1 + (g % 50000), 1 + (g % 3),
       round((random()*1000000)::numeric,2)
FROM generate_series(1,80000) g;

-- 500,000 transactions
INSERT INTO transactions (account_id, txn_type, amount, txn_time, reference)
SELECT 1 + (g % 80000),
       (ARRAY['DEPOSIT','WITHDRAWAL','TRANSFER_IN','TRANSFER_OUT'])[1 + (g % 4)],
       round((random()*50000 + 100)::numeric,2),
       NOW() - make_interval(days => (random()*365)::int, mins => (random()*1440)::int),
       'REF'||lpad(g::text,10,'0')
FROM generate_series(1,500000) g;

-- 100,000 transfers
INSERT INTO transfers (from_account, to_account, amount, status, created_at)
SELECT 1 + (g % 80000), 1 + ((g*7 + 1) % 80000),
       round((random()*50000 + 100)::numeric,2),
       (ARRAY['COMPLETED','FAILED','PENDING'])[1 + (g % 3)],
       NOW() - make_interval(days => (random()*365)::int)
FROM generate_series(1,100000) g;

-- Let PostgreSQL learn the new data so it plans queries well
ANALYZE;

-- Check the row counts
SELECT 'branches' AS table_name, COUNT(*) AS rows FROM branches
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'accounts', COUNT(*) FROM accounts
UNION ALL SELECT 'transactions', COUNT(*) FROM transactions
UNION ALL SELECT 'transfers', COUNT(*) FROM transfers;
