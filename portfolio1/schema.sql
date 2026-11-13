-- Paynest Bank (simulated) - Portfolio 1 schema
-- Run this in the bankdb database.

DROP TABLE IF EXISTS transfers, transactions, accounts, customers, account_types, branches CASCADE;

CREATE TABLE branches (
  branch_id   SERIAL PRIMARY KEY,
  branch_name VARCHAR(80) NOT NULL UNIQUE,
  city        VARCHAR(60) NOT NULL
);

CREATE TABLE customers (
  customer_id   SERIAL PRIMARY KEY,
  first_name    VARCHAR(50)  NOT NULL,
  last_name     VARCHAR(50)  NOT NULL,
  email         VARCHAR(100) NOT NULL UNIQUE CHECK (email LIKE '%@%'),
  phone         VARCHAR(15)  NOT NULL,
  date_of_birth DATE         NOT NULL,
  branch_id     INT          NOT NULL REFERENCES branches(branch_id),
  created_at    TIMESTAMP    NOT NULL DEFAULT NOW()
);

CREATE TABLE account_types (
  type_id       SERIAL PRIMARY KEY,
  type_name     VARCHAR(30) NOT NULL UNIQUE,
  min_balance   NUMERIC(15,2) NOT NULL DEFAULT 0 CHECK (min_balance >= 0),
  interest_rate NUMERIC(5,2)  NOT NULL DEFAULT 0 CHECK (interest_rate >= 0)
);

CREATE TABLE accounts (
  account_id     BIGSERIAL PRIMARY KEY,
  account_number CHAR(10) NOT NULL UNIQUE,
  customer_id    INT NOT NULL REFERENCES customers(customer_id),
  type_id        INT NOT NULL REFERENCES account_types(type_id),
  balance        NUMERIC(15,2) NOT NULL DEFAULT 0 CHECK (balance >= 0),
  status         VARCHAR(10) NOT NULL DEFAULT 'ACTIVE'
                 CHECK (status IN ('ACTIVE','FROZEN','CLOSED')),
  opened_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE transactions (
  txn_id     BIGSERIAL PRIMARY KEY,
  account_id BIGINT NOT NULL REFERENCES accounts(account_id),
  txn_type   VARCHAR(15) NOT NULL
             CHECK (txn_type IN ('DEPOSIT','WITHDRAWAL','TRANSFER_IN','TRANSFER_OUT')),
  amount     NUMERIC(15,2) NOT NULL CHECK (amount > 0),
  txn_time   TIMESTAMP NOT NULL DEFAULT NOW(),
  reference  VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE transfers (
  transfer_id  BIGSERIAL PRIMARY KEY,
  from_account BIGINT NOT NULL REFERENCES accounts(account_id),
  to_account   BIGINT NOT NULL REFERENCES accounts(account_id),
  amount       NUMERIC(15,2) NOT NULL CHECK (amount > 0),
  status       VARCHAR(10) NOT NULL DEFAULT 'PENDING'
               CHECK (status IN ('PENDING','COMPLETED','FAILED')),
  created_at   TIMESTAMP NOT NULL DEFAULT NOW(),
  CHECK (from_account <> to_account)
);
