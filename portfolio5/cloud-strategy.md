# Portfolio 5: Distributed and Cloud Database Strategy

**Case Study: Paynest Bank**



## 1\. The Scalability Problem

Paynest Bank currently runs on a single-node PostgreSQL instance (`bankdb`). This architecture is adequate for development and moderate loads, but it becomes a bottleneck under real-world peak traffic patterns common in Nigerian microfinance:

* **Salary week / end-of-month disbursements**: Tens of thousands of concurrent deposits, transfers, and balance enquiries.
* **Bulk agent collections and POS settlements**: High write volume mixed with frequent read queries for statements and reconciliations.
* **Audit and regulatory reporting**: Long-running analytical queries that compete with OLTP traffic.

On a single node these workloads produce:

* Lock contention and increased transaction latency
* CPU and I/O saturation
* Risk of unavailability if the single instance fails

A pure vertical scaling approach (bigger server) eventually hits physical and cost limits. Horizontal scaling and cloud-managed services are therefore required.



## 2\. Primary–Standby (Read Replica) Architecture

The recommended first step is **asynchronous streaming replication**:

|Role|Purpose|Typical Operations|
|-|-|-|
|**Primary**|Single source of truth for writes|Deposits, withdrawals, `transfer\\\\\\\_funds`, account updates|
|**Read Replica(s)**|Offload read traffic|Account statements, balance enquiries, audit reports, KYC lookups|

### 

### Benefits for Paynest

* Write path remains simple and strongly consistent (single primary).
* Read-heavy workloads (customer apps, agent portals, internal reporting) are served by one or more replicas.
* Failover to a replica can be automated, reducing Recovery Time Objective (RTO).
* No application-level sharding required at this stage.

### 

### Implementation notes (PostgreSQL)

* Use physical streaming replication (`hot\\\\\\\_standby = on`).
* Application connection string routing:

  * Writes → Primary endpoint
  * Reads → Load-balanced replica endpoint (or PgBouncer / connection pooler)
* Monitoring: replication lag, WAL generation rate, and disk usage on both primary and replicas.

## 

## 3\. Cloud Deployment Strategy

Rather than operating self-managed primary–replica pairs, migrate to a **managed relational service**:

**Recommended options**

* **AWS RDS for PostgreSQL** (Multi-AZ)
* **Google Cloud SQL for PostgreSQL**
* **Supabase** (PostgreSQL + built-in connection pooling and edge functions) – attractive for rapid prototyping and lower operational overhead

### 

### Key managed features that map directly to Paynest needs



|Requirement|Managed Feature|Benefit|
|-|-|-|
|High availability|Multi-AZ / automatic failover|Survives AZ failure with minimal downtime|
|Point-in-time recovery|Continuous WAL archiving + automated backups|Meet regulatory recovery requirements|
|Elastic scaling|Vertical scaling + read replicas|Handle salary-week spikes without over-provisioning|
|Security \& compliance|Encryption at rest/transit, VPC isolation, IAM|Align with CBN and NDPR expectations|
|Operational simplicity|Automated patching, monitoring, parameter groups|Free DBAs for higher-value work|

### 

### Migration outline



1. Provision Multi-AZ RDS (or equivalent) instance matching current `bankdb` schema and data volume.
2. Use AWS DMS / `pg\\\\\\\_dump` + logical replication or Supabase import tools for initial load.
3. Cut over application connection strings (with a short maintenance window or dual-write if zero-downtime is mandatory).
4. Enable automated backups and configure read replicas for reporting workloads.
5. Retire the on-premises / single-node instance after validation.



## 4\. Future Sharding Considerations



When the bank grows beyond a few million active accounts or expands aggressively across Nigeria, **horizontal partitioning (sharding)** becomes relevant.

**Natural shard key for Paynest**: `branch\\\\\\\_id` or geographic region (e.g., Abuja cluster vs Lagos cluster).

### 

### High-level approach



* **Application-level sharding** or middleware (Citus, Vitess, or custom router).
* Each shard remains a PostgreSQL instance (or managed cluster) with its own primary + replicas.
* Cross-shard transactions (rare for pure branch-local operations) handled via careful application design or two-phase commit where unavoidable.
* Global tables (e.g., `account\\\\\\\_types`, reference data) can be replicated to every shard.

Sharding is **not** required for the immediate Portfolio 5 deliverable; it is documented here as the logical next evolution once Multi-AZ + read replicas are exhausted.

## 

## 5\. Summary Recommendation



|Time Horizon|Architecture|Rationale|
|-|-|-|
|Immediate|Single primary + 1–2 read replicas (managed)|Solves current peak-load and HA pain with minimal code change|
|Short–medium term|Fully managed Multi-AZ service (RDS / Cloud SQL / Supabase)|Removes operational burden, adds automated backups \& failover|
|Long term|Region/branch-based sharding|Supports national scale while preserving ACID guarantees inside each shard|

This strategy keeps the strong consistency and ACID properties required for financial ledgers while providing the elasticity and resilience expected of a modern microfinance platform.

