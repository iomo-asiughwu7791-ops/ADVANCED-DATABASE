# Portfolio 5 – Distributed and Cloud Database Exercise

**Paynest Bank**



## Folder Contents



|File|Description|
|-|-|
|`cloud-strategy.md`|Full technical write-up covering scalability challenges, primary–standby replication, managed cloud deployment options, and future sharding considerations.|
|`architecture-diagram.png`|Visual representation of the recommended high-level architecture (Client → Load Balancer → Primary + Read Replica).|
|`README.md`|This file.|

## 

## Implementation Approach



This portfolio deliberately adopts a **documentation-and-strategy** focus rather than standing up a local multi-node Docker cluster. The rationale is:

1. The core relational and NoSQL work has already been demonstrated in Portfolios 1–4.
2. Real-world production systems for a regulated microfinance institution will use managed cloud services (AWS RDS, Cloud SQL, Supabase, etc.) rather than self-managed container clusters.
3. The learning objectives—understanding scalability limits, read/write separation, high availability, and horizontal scaling—are fully addressed through the strategy document and architecture diagram.

## 

## How to Use



1. Read `cloud-strategy.md` for the complete analysis and recommendations.
2. Refer to `architecture-diagram.png` for the visual overview of the proposed topology.
3. The strategy can be used as the basis for a real migration plan should Paynest move from a single-node PostgreSQL instance to a production-grade managed service.

