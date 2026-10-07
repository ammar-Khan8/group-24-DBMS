# group-24-DBMS
# Pet Adoption & Fostering Network (CSE3001)

A MySQL 8.0 database project for managing animals, shelters, adopters, adoption applications, home visits, foster placements, adoptions, and medical follow-ups.

## Files
| File | Purpose |
|---|---|
| `Schema.sql` | Creates the `pet_adoption_network` database, 10 tables, keys, checks, enums |
| `Views_Indexes_Triggers_Procedures.sql` | 3 views, 5 indexes, 6 triggers, 4 stored procedures |
| `Data.sql` | Sample data and demo calls |
| `pet_adoption_dataset.csv` | Animal intake dataset (10 rows) |
| `Design.md` | ER diagram, business rules, normalization notes |

## Requirements
- MySQL 8.0 (window functions and CHECK constraints are used)
- MySQL Workbench or the `mysql` command-line client

## Setup
Run the scripts in this order:

```sql
SOURCE Schema.sql;
SOURCE Views_Indexes_Triggers_Procedures.sql;
SOURCE Data.sql;
```

Or from a terminal:

```bash
mysql -u root -p < Schema.sql
mysql -u root -p < Views_Indexes_Triggers_Procedures.sql
mysql -u root -p < Data.sql
```

> `Schema.sql` drops and recreates `pet_adoption_network`. Do not run it on a database you want to keep.

## Quick start
```sql
USE pet_adoption_network;

SELECT * FROM Available_Animals_View;
SELECT * FROM Adoption_Application_Summary_View;
SELECT * FROM Medical_Followup_View;
SELECT species, COUNT(*) FROM animals GROUP BY species;

CALL Animal_Availability_Report();
CALL Match_Animals_For_Adopter(1);
CALL Generate_Overdue_Medical_Alerts();
```

## Testing the adoption procedure
| Call | Expected result |
|---|---|
| `CALL Approve_Adoption(3);` | Succeeds, records the adoption, animal becomes Adopted |
| `CALL Approve_Adoption(6);` | Fails: home visit did not recommend adoption |
| `CALL Approve_Adoption(5);` | Fails: application is not Approved |

## Key behaviors
- **Triggers run on row changes only.** A date passing does not fire anything; run `Generate_Overdue_Medical_Alerts()` to catch records that became overdue later.
- **Foster capacity** is enforced by trigger; inserting or reactivating a placement in a full home raises an error.
- **Completed adoption** sets the animal to Adopted; **completed fostering** returns it to Available.
- **Approve_Adoption** runs in a transaction with row locks and rolls back if any prerequisite fails.
- Follow-up states (Overdue/Upcoming) depend on `CURDATE()`, so results change over time.

## Troubleshooting
| Symptom | Check |
|---|---|
| Script errors on `DELIMITER` | Run in Workbench or the mysql client, not a tool that ignores DELIMITER |
| `CHECK` constraint not enforced | Confirm you are on MySQL 8.0.16 or later |
| No matching animals | Animal must be `Available` and match the adopter's species and size |
| Overdue alert missing | Follow-up must be `Pending` with a past check-up date; run the alert procedure |
| Procedure rejects adoption | Needs Approved application, Completed and Recommended visit, animal not adopted |

## Data note
The sample data is for learning and demonstration only. Back up before using this against real records.
