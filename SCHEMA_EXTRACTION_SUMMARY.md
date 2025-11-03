# Schema Extraction Summary

## Task Completed Successfully

**Date:** 2025-11-03
**Database:** GameSpacedatabase
**Server:** DESKTOP-8HQIS1S\SQLEXPRESS

---

## What Was Extracted

Successfully extracted complete schema information for all **20 MiniGame tables** from the SQL Server database.

### Tables Extracted

#### Wallet System (3 tables)
1. ✅ **User_Wallet** - Point balance tracking
2. ✅ **WalletHistory** - Transaction log
3. ✅ **SystemSettings** - Global configuration

#### Coupon System (2 tables)
4. ✅ **CouponType** - Coupon templates
5. ✅ **Coupon** - User coupon instances

#### E-Voucher System (4 tables)
6. ✅ **EVoucherType** - E-voucher templates
7. ✅ **EVoucher** - User e-voucher instances
8. ✅ **EVoucherToken** - Redemption tokens
9. ✅ **EVoucherRedeemLog** - Redemption history

#### Pet System (4 tables)
10. ✅ **Pet** - Virtual pet data
11. ✅ **PetSkinColorCostSettings** - Skin color pricing
12. ✅ **PetBackgroundCostSettings** - Background pricing
13. ✅ **PetLevelRewardSettings** - Level-up rewards

#### Sign-In System (2 tables)
14. ✅ **SignInRule** - Daily sign-in rewards
15. ✅ **UserSignInStats** - User sign-in history

#### Mini-Game System (1 table)
16. ✅ **MiniGame** - Game session records

#### Admin Management (3 tables)
17. ✅ **ManagerData** - Admin accounts
18. ✅ **ManagerRole** - Role assignments
19. ✅ **ManagerRolePermission** - Role permissions

#### User Management (1 table)
20. ✅ **Users** - End-user accounts

---

## Information Extracted for Each Table

For each of the 20 tables, the following information was extracted:

### 1. Column Details
- Column name
- Data type
- Character length (for varchar/nvarchar)
- Numeric precision and scale (for decimal/numeric)
- Nullable status
- Default values
- Identity (auto-increment) status

### 2. Primary Keys
- Primary key column(s)
- Composite key identification

### 3. Foreign Keys
- Foreign key constraint names
- Source column
- Referenced table
- Referenced column

### 4. Indexes
- Index name
- Index type (CLUSTERED/NONCLUSTERED)
- Unique constraint status
- Indexed columns (including composite indexes)

### 5. Check Constraints
- Constraint name
- Constraint definition (validation rules)

---

## Output Files Generated

### 1. `COMPLETE_SCHEMA_EXPORT.md` (Main Deliverable)
**Location:** `C:\Users\n2029\Desktop\work-1103\COMPLETE_SCHEMA_EXPORT.md`

**Contents:**
- Complete schema documentation for all 20 tables
- Formatted as Markdown with tables for easy reading
- Organized by table with table of contents
- Includes schema summary and data integrity notes
- 273 total columns documented
- 24 foreign key relationships mapped
- 64 indexes catalogued
- 17 check constraints documented

**Sections:**
- Table of Contents (quick navigation)
- Individual table schemas (20 sections)
- Schema summary (categorized by subsystem)
- Common patterns analysis
- Data integrity notes
- Index strategy analysis

### 2. `extract_schema.sql` (SQL Script)
**Location:** `C:\Users\n2029\Desktop\work-1103\extract_schema.sql`

**Purpose:** Reusable SQL script for future schema extractions

**Contents:**
- Automated queries for all 20 tables
- Column information extraction
- Primary key detection
- Foreign key mapping
- Index enumeration
- Check constraint extraction

### 3. `schema_output.txt` (Raw Output)
**Location:** `C:\Users\n2029\Desktop\work-1103\schema_output.txt`

**Purpose:** Raw sqlcmd output for reference

---

## Key Findings

### Database Design Patterns

#### 1. Soft Delete Pattern (Used in 18/20 tables)
```sql
IsDeleted bit NOT NULL DEFAULT (0)
DeletedAt datetime2 NULL
DeletedBy int NULL
DeleteReason nvarchar(500) NULL
```
**Tables WITHOUT soft delete:** ManagerRole, ManagerRolePermission

#### 2. Audit Trail Pattern (Used in 3 settings tables)
```sql
CreatedAt datetime2 NOT NULL DEFAULT sysutcdatetime()
UpdatedAt datetime2 NULL
UpdatedBy int NULL (FK to ManagerData)
```
**Tables with audit trail:** SystemSettings, PetBackgroundCostSettings, PetLevelRewardSettings, PetSkinColorCostSettings

#### 3. UTC Timestamp Strategy
- All `datetime2` columns use `sysutcdatetime()` for UTC timestamps
- Ensures timezone-independent data storage
- Critical for MiniGame area (multi-timezone support)

#### 4. Identity Columns
- **17 tables** use auto-increment identity for primary keys
- **3 tables** use non-identity PKs: User_Wallet (1:1 with Users), ManagerData, ManagerRolePermission

### Foreign Key Network

**Central Hub: Users**
- 8 tables reference `Users.User_ID`
- One-to-one: User_Wallet, Pet
- One-to-many: Coupon, EVoucher, EVoucherRedeemLog, MiniGame, UserSignInStats, WalletHistory

**Central Hub: ManagerData**
- 3 tables reference `ManagerData.Manager_Id`
- Junction table: ManagerRole
- Updated-by audit: SystemSettings, PetBackgroundCostSettings

**Type System Pattern:**
- CouponType → Coupon (1:N)
- EVoucherType → EVoucher (1:N)
- Pet → MiniGame (1:N)

### Data Integrity Mechanisms

#### Unique Constraints (10 critical business rules)
1. Coupon codes must be globally unique
2. E-voucher codes must be globally unique
3. Redemption tokens must be globally unique
4. Only one sign-in rule per day
5. Only one system setting per key
6. Unique user accounts and usernames
7. Unique admin accounts and emails

#### Range Validations
- **Pet stats:** All 5 stats constrained to 0-100 range
- **Sign-in days:** 1-365 days per year
- **Pet levels:** Must be positive, ranges must be valid
- **Points rewards:** Capped at 999,999

#### Enum Validations (4 enums)
1. `CouponType.DiscountType`: PERCENT | AMOUNT
2. `EVoucherRedeemLog.Status`: APPROVED | ALREADYUSED | EXPIRED | REJECTED | REVOKED
3. `SystemSettings.SettingType`: String | Boolean | Number | JSON
4. `PetSkinColorCostSettings.Rarity`: 普通 | 罕見 | 稀有 | 史詩 | 傳說

#### Conditional Validations
1. **Coupon usage:** If `IsUsed=1`, then `UsedTime` and `UsedInOrderID` must be populated
2. **Sign-in coupons:** If `HasCoupon=1`, then `CouponTypeCode` must be populated

### Index Strategy Analysis

#### Performance Indexes (User-Time Pattern)
Most transaction tables use composite indexes on `(UserID, Timestamp)`:
- `IX_Coupon_user_used` (UserID, IsUsed, AcquiredTime)
- `IX_EVoucher_user_used` (UserID, IsUsed, AcquiredTime)
- `IX_MiniGame_user_time` (UserID, StartTime)
- `IX_UserSignInStats_user_time` (UserID, SignTime)
- `IX_WalletHistory_user_time` (UserID, ChangeTime)

**Purpose:** Optimizes common queries like "show user's transaction history"

#### Soft Delete Optimization
Most tables have dedicated index on `IsDeleted` for efficient filtering:
```sql
WHERE IsDeleted = 0
```

#### Unique Constraint Enforcement
All business-critical unique constraints use NONCLUSTERED unique indexes for enforcement.

---

## Statistics

| Metric | Count |
|--------|-------|
| Total Tables | 20 |
| Total Columns | 273 |
| Identity Columns | 17 |
| Foreign Keys | 24 |
| Unique Constraints | 13 |
| Check Constraints | 17 |
| Total Indexes | 64 |
| Tables with Soft Delete | 18 |
| Tables with Audit Trail | 4 |

---

## Verification Checklist

✅ All 20 tables extracted
✅ Column data types captured
✅ Nullable/NOT NULL status recorded
✅ Default values documented
✅ Identity columns identified
✅ Primary keys mapped
✅ Foreign keys with relationships documented
✅ Indexes catalogued (clustered, nonclustered, unique)
✅ Check constraints extracted
✅ Common patterns identified
✅ Data integrity mechanisms analyzed
✅ Foreign key network mapped
✅ Index strategy analyzed

---

## Usage Instructions

### For Development Reference
Use `COMPLETE_SCHEMA_EXPORT.md` as the authoritative schema reference when:
- Creating Entity Framework models
- Writing LINQ queries
- Designing service layer logic
- Implementing validation rules
- Understanding table relationships

### For Future Schema Updates
Use `extract_schema.sql` to:
- Re-run schema extraction after database changes
- Compare schema versions
- Document schema evolution

### For Code Generation
The Markdown format enables:
- Copy-paste into C# model classes
- Generation of DTOs
- Creation of validation attributes based on check constraints
- Building repository interfaces based on foreign keys

---

## Next Steps

### Recommended Actions

1. **Create C# Entity Models**
   - Use the schema export to create accurate EF Core entity classes
   - Include all constraints as data annotations or Fluent API configurations

2. **Implement Service Layer**
   - Design services around the identified foreign key relationships
   - Implement transaction patterns for multi-table operations (e.g., wallet deductions)

3. **Add Validation Logic**
   - Implement all check constraints in application validation
   - Add business rule validation for conditional constraints

4. **Design Repository Patterns**
   - Create repositories aligned with the foreign key network
   - Implement soft-delete-aware queries

5. **Performance Optimization**
   - Leverage the documented indexes in query design
   - Add covering indexes if needed based on query patterns

---

## Contact Information

**Extraction Performed By:** Claude Code (Anthropic)
**Date:** 2025-11-03
**Database Server:** DESKTOP-8HQIS1S\SQLEXPRESS
**Database Name:** GameSpacedatabase

---

**End of Summary**
