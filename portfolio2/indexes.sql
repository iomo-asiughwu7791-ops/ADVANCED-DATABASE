-- Paynest Bank (simulated) - Portfolio 2 indexes

-- Helps Q1: find one account's transactions, newest first
CREATE INDEX idx_txn_account_time ON transactions (account_id, txn_time DESC);

-- Helps Q2: filter transactions by time
CREATE INDEX idx_txn_time ON transactions (txn_time);

-- Helps joins from accounts to customers
CREATE INDEX idx_accounts_customer ON accounts (customer_id);

-- Helps Q5: only failed transfers (partial index = smaller and faster)
CREATE INDEX idx_transfers_failed ON transfers (created_at) WHERE status = 'FAILED';

-- Tell PostgreSQL to refresh its statistics
ANALYZE;
