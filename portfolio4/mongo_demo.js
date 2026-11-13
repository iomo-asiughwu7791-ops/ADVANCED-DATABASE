// Paynest Bank (simulated) - Portfolio 4: MongoDB
// Same customer and account IDs as the PostgreSQL data (Portfolios 1 to 3):
//   account_id 1 (number 1000000001) belongs to customer_id 2
//   account_id 2 (number 1000000002) belongs to customer_id 3
// Run each numbered section separately in the Compass shell (>_MONGOSH).

// =====================================================
// 1. Select the database and insert customer profiles
// =====================================================
use("bankdb_nosql");

db.customer_profiles.insertMany([
  {
    customer_id: 2,
    name: "First2 Last2",
    email: "user2@example.com",
    branch_id: 3,
    kyc: { id_type: "NIN", verified: true },
    devices: [ { type: "android", last_login: new Date("2026-10-05") } ],
    preferences: { alerts: ["sms", "push"], language: "en" }
  },
  {
    customer_id: 3,
    name: "First3 Last3",
    email: "user3@example.com",
    branch_id: 4,
    kyc: { id_type: "Passport", verified: false },
    devices: [],
    preferences: { alerts: ["email"], language: "ha" }
  }
]);

// =====================================================
// 2. Insert transaction logs (each channel has a different shape)
// =====================================================
db.transaction_logs.insertMany([
  { account_id: 1, account_number: "1000000001", type: "TRANSFER_OUT", amount: 10000,
    channel: "mobile_app", device: { os: "android", ip: "102.89.1.5" },
    ts: new Date("2026-10-06T10:00:00Z") },
  { account_id: 1, account_number: "1000000001", type: "WITHDRAWAL", amount: 20000,
    channel: "ATM", atm: { id: "ATM-045", city: "Port Harcourt" },
    ts: new Date("2026-10-07T12:30:00Z") },
  { account_id: 1, account_number: "1000000001", type: "WITHDRAWAL", amount: 95000,
    channel: "ATM", atm: { id: "ATM-310", city: "Abuja" },
    ts: new Date("2026-10-07T12:45:00Z") },
  { account_id: 2, account_number: "1000000002", type: "POS_PAYMENT", amount: 7500,
    channel: "POS", pos: { merchant: "SuperMart", terminal: "T-99" },
    ts: new Date("2026-10-07T15:10:00Z") },
  { account_id: 2, account_number: "1000000002", type: "DEPOSIT", amount: 50000,
    channel: "branch", branch: { branch_id: 4, teller: "T-12" },
    ts: new Date("2026-10-08T09:20:00Z") }
]);

// =====================================================
// 3. Read (find) queries
// =====================================================
db.transaction_logs.find({ channel: "ATM" });
db.transaction_logs.find({ amount: { $gt: 15000 } });
db.customer_profiles.find({ "kyc.verified": false });

// =====================================================
// 4. Update: flag a suspicious record (two ATMs in different cities, 15 minutes apart)
// =====================================================
db.transaction_logs.updateOne(
  { "atm.id": "ATM-310" },
  { $set: { flagged: true, flag_reason: "Different city within 15 minutes" } }
);
db.transaction_logs.find({ flagged: true });

// =====================================================
// 5. Aggregate: total amount and count per channel
// =====================================================
db.transaction_logs.aggregate([
  { $group: { _id: "$channel", total: { $sum: "$amount" }, count: { $sum: 1 } } },
  { $sort: { total: -1 } }
]);

// =====================================================
// 6. Index and proof that it is used
// =====================================================
db.transaction_logs.createIndex({ account_id: 1, ts: -1 });
db.transaction_logs.find({ account_id: 1 }).sort({ ts: -1 }).explain("executionStats").executionStats;
