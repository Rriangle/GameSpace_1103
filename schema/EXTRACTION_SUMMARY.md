# Database Schema Extraction Summary

**Database**: GameSpacedatabase
**Server**: (local)\SQLEXPRESS (DESKTOP-8HQIS1S\SQLEXPRESS)
**Authentication**: Windows Integrated Security (Trusted_Connection)
**Extraction Date**: 2025-10-31
**Status**: ✅ COMPLETE

---

## 📁 Generated Files

### 1. **MINIGAME_AREA_SCHEMA_AI_OPTIMIZED.md** (Primary Document)
Complete schema documentation for all 20 MiniGame Area tables including:
- Table summaries with row counts
- Full column definitions (name, type, nullable, default, key)
- Primary keys, foreign keys, unique constraints
- Check constraints and business rules
- Indexes and performance optimizations
- Common design patterns (soft delete, audit trail, etc.)
- Data statistics and important notes

**Size**: ~9,500 words
**Format**: Markdown with tables
**Use Case**: Primary reference for AI agents, developers, and database design

---

### 2. **SAMPLE_DATA_REFERENCE.md** (Data Examples)
Sample data from all 20 tables showing:
- First 20 rows per table (representative samples)
- Data patterns and formats
- Code examples (CouponCode, EVoucherCode, Token formats)
- Enum values (Status, ChangeType, Difficulty, etc.)
- User journey walkthrough
- Economy flow explanation
- Key insights and business logic

**Size**: ~4,000 words
**Format**: Markdown with code blocks
**Use Case**: Understanding data patterns, testing, validation

---

### 3. **Supporting SQL Scripts**
Location: `C:\Users\n2029\Desktop\work-1031\schema\`

- `extract_schema.sql` - Initial schema extraction query
- `extract_schema_v2.sql` - Refined schema extraction
- `extract_minigame_tables.sql` - MiniGame Area specific extraction
- `extract_sample_data_v2.sql` - Sample data extraction (20 rows per table)

---

### 4. **Raw Export Files**
- `schema_output.txt` - Raw schema output
- `minigame_schema.txt` - MiniGame tables schema
- `sample_data.txt` - Sample data export
- `columns_detail.csv` - Column details in CSV format
- `primary_keys.txt` - Primary key listing
- `foreign_keys.txt` - Foreign key relationships
- `unique_constraints.txt` - Unique constraint listing
- `row_counts.txt` - Table row counts

---

## 📊 Database Statistics

| Metric | Value |
|--------|-------|
| **Total Tables Extracted** | 20 |
| **Total Columns** | 287 |
| **Total Records** | ~13,000+ |
| **Primary Keys** | 20 |
| **Foreign Keys** | 16 |
| **Unique Constraints** | 13 |
| **Check Constraints** | 14 |
| **Indexes** | 40+ |

---

## 🗂️ Table Breakdown

### Core Systems (20 Tables)

#### 💰 Wallet System (2 tables, 2,128 records)
1. **User_Wallet** - 200 rows - Member wallet balances
2. **WalletHistory** - 1,928 rows - Transaction log

#### 🎫 Coupon System (2 tables, 4,590 records)
3. **CouponType** - 3 rows - Coupon templates
4. **Coupon** - 4,587 rows - Coupon instances

#### 🎁 E-Voucher System (4 tables, 1,510 records)
5. **EVoucherType** - 20 rows - E-voucher templates
6. **EVoucher** - 355 rows - E-voucher instances
7. **EVoucherToken** - 355 rows - Redemption tokens
8. **EVoucherRedeemLog** - 800 rows - Redemption log

#### 🐾 Pet System (4 tables, 247 records)
9. **Pet** - 200 rows - Virtual pet data
10. **PetSkinColorCostSettings** - 11 rows - Skin color pricing
11. **PetBackgroundCostSettings** - 11 rows - Background pricing
12. **PetLevelRewardSettings** - 25 rows - Level-up rewards

#### ✅ Sign-In System (2 tables, 2,410 records)
13. **SignInRule** - 10 rows - Check-in rules
14. **UserSignInStats** - 2,400 rows - Check-in records

#### 🎮 Game & Settings (2 tables, 2,056 records)
15. **MiniGame** - 2,000 rows - Game play records
16. **SystemSettings** - 56 rows - System configuration

#### 👥 User & Admin (4 tables, 410 records)
17. **Users** - 200 rows - User master table
18. **ManagerData** - 102 rows - Admin accounts
19. **ManagerRole** - 102 rows - Role assignments
20. **ManagerRolePermission** - 8 rows - Permission definitions

---

## 🔗 Key Relationships

### User-Centric (Users table as hub)
```
Users (200)
  ├─→ User_Wallet (200) - 1:1
  ├─→ WalletHistory (1,928) - 1:N
  ├─→ Coupon (4,587) - 1:N
  ├─→ EVoucher (355) - 1:N
  ├─→ Pet (200) - 1:1
  ├─→ UserSignInStats (2,400) - 1:N
  └─→ MiniGame (2,000) - 1:N
```

### Coupon Flow
```
CouponType (3)
  └─→ Coupon (4,587)
      └─→ WalletHistory (track redemption)
```

### E-Voucher Flow
```
EVoucherType (20)
  └─→ EVoucher (355)
      └─→ EVoucherToken (355) - 1:1
          └─→ EVoucherRedeemLog (800) - 1:N
```

### Pet & Game Flow
```
Pet (200)
  └─→ MiniGame (2,000) - 1:N
      └─→ WalletHistory (track rewards)
```

### Admin RBAC
```
ManagerData (102)
  └─→ ManagerRole (102) - M:N
      └─→ ManagerRolePermission (8)
```

---

## 🎯 Design Patterns

### 1. Soft Delete (Universal)
Every table implements soft delete with 4 columns:
- `IsDeleted` (bit, default 0)
- `DeletedAt` (datetime2, nullable)
- `DeletedBy` (int, nullable)
- `DeleteReason` (nvarchar(500), nullable)

**Benefit**: Complete audit trail, data recovery, historical analysis

### 2. Audit Trail (Most Tables)
Common audit columns:
- `CreatedAt` (datetime2, default sysutcdatetime())
- `UpdatedAt` (datetime2, nullable)
- `UpdatedBy` (int, FK to ManagerData)

**Benefit**: Track who changed what and when

### 3. UTC Timestamps
All timestamps use `datetime2(7)` with UTC time (`sysutcdatetime()`)

**Benefit**: Timezone-independent, accurate to 100 nanoseconds

### 4. IDENTITY Primary Keys
All tables use auto-increment PKs except:
- **User_Wallet**: PK is User_Id (FK to Users)
- **ManagerRole**: Composite PK (no identity)

**Benefit**: Simple, efficient, globally unique

### 5. Unique Business Codes
Strategic unique constraints on:
- CouponCode, EVoucherCode, Token (prevent duplicates)
- User_name, User_Account, Manager_Account (authentication)
- SettingKey (configuration)
- ColorCode, BackgroundCode (customization)

**Benefit**: Data integrity, business rule enforcement

### 6. Enum-like Check Constraints
Validation on text fields:
- ChangeType: 'Point', 'Coupon', 'EVoucher'
- DiscountType: 'Amount', 'Percent'
- Status: 'Approved', 'Rejected', 'Expired', 'AlreadyUsed', 'Revoked'
- Difficulty: 'Easy', 'Normal', 'Hard', 'Expert'
- Account_Status: 'Active', 'Locked', 'Suspended', 'Pending'

**Benefit**: Type safety without enums, database-level validation

---

## 💡 Business Logic Insights

### Points Economy
**Earning Points**:
- Daily check-in: 10-50 points (based on day number)
- Mini games: ~Score / 100 points
- Pet level-up: 10-50 points (based on level)
- Order returns: Variable points (from WalletHistory)

**Spending Points**:
- Coupons: 1,000-10,000 points
- E-vouchers: 4,200-36,000 points
- Pet skin colors: 0-3,500 points
- Pet backgrounds: 0-6,000 points

**Total Circulation**: 200 users × avg 50k points = ~10M points

### Gamification Strategy
1. **Daily Engagement**: Check-in system with streaks and milestones
2. **Pet Bonding**: Virtual pet with 5 stats, leveling, customization
3. **Skill-Based Rewards**: Mini games with difficulty levels
4. **Loyalty Rewards**: Coupons and e-vouchers for real-world value

### Security & Access Control
- **Password Storage**: Hashed (nvarchar(256))
- **RBAC**: 8 roles, 6 permission types
- **Account Locking**: Manager accounts can be locked
- **Soft Delete**: Prevent accidental data loss

---

## 🚀 Connection Information

### SQL Server Connection String
```
Server=(local)\SQLEXPRESS;Database=GameSpacedatabase;Trusted_Connection=True;TrustServerCertificate=True;MultipleActiveResultSets=True
```

### sqlcmd Command Line
```powershell
sqlcmd -S "(local)\SQLEXPRESS" -d GameSpacedatabase -E -Q "SELECT * FROM Users"
```

### Alternative Server Names
- `(local)\SQLEXPRESS`
- `DESKTOP-8HQIS1S\SQLEXPRESS`
- `tcp:DESKTOP-8HQIS1S\SQLEXPRESS,1433` (TCP with port)

---

## 📋 Extraction Methodology

### Tools Used
- **sqlcmd**: Microsoft SQL Server command-line utility
- **SQL Queries**: INFORMATION_SCHEMA views, system catalogs
- **PowerShell**: Script automation

### Queries Executed
1. Table listing with column counts
2. Column details (type, nullable, default, identity)
3. Primary keys extraction
4. Foreign keys with source/target mapping
5. Unique constraints
6. Check constraints
7. Indexes (type, columns, uniqueness)
8. Row counts (using sys.partitions)
9. Sample data (TOP 20 per table)

### Data Validation
- ✅ All 20 tables confirmed present
- ✅ Primary keys identified (20/20)
- ✅ Foreign keys mapped (16 relationships)
- ✅ Unique constraints verified (13)
- ✅ Check constraints documented (14)
- ✅ Sample data extracted successfully

---

## 📝 Usage Guide

### For AI Agents
**Primary Reference**: `MINIGAME_AREA_SCHEMA_AI_OPTIMIZED.md`
- Use for understanding table structure
- Reference for query generation
- Validate data types and constraints

**Data Patterns**: `SAMPLE_DATA_REFERENCE.md`
- Use for understanding data formats
- Reference for test data generation
- Validate business logic assumptions

### For Developers
**Schema Design**: Study the 6 design patterns
**Database Access**: Use connection strings provided
**Testing**: Use sample data as fixtures
**Validation**: Reference check constraints for enum values

### For Database Administrators
**Maintenance**: All tables have soft delete, no hard cleanup needed
**Performance**: Review indexes for optimization opportunities
**Security**: Audit trail tracks all changes via UpdatedBy
**Backup**: ~13k records, minimal storage requirements

---

## ⚠️ Important Notes

### Data Sensitivity
- User passwords are hashed (nvarchar(256))
- Admin credentials stored separately (ManagerData)
- No PII in sample exports (anonymized where needed)

### Schema Stability
- Last verified: 2025-10-28 (per guide document)
- All 20 tables confirmed stable
- No schema migrations detected since initial extraction

### Future Enhancements
Consider adding:
- Full-text search indexes on Description fields
- Computed columns for point balances
- Materialized views for reporting
- Partitioning for large transaction tables (WalletHistory, MiniGame)

---

## ✅ Verification Checklist

- [x] All 20 tables extracted
- [x] Column details complete (name, type, nullable, default, key)
- [x] Primary keys documented
- [x] Foreign keys mapped
- [x] Unique constraints identified
- [x] Check constraints listed
- [x] Indexes cataloged
- [x] Row counts confirmed
- [x] Sample data extracted (20 rows per table)
- [x] Design patterns documented
- [x] Business logic explained
- [x] Connection info verified
- [x] AI-optimized format (<10,000 words)

---

## 📚 Documentation Index

1. **MINIGAME_AREA_SCHEMA_AI_OPTIMIZED.md** - Complete schema reference
2. **SAMPLE_DATA_REFERENCE.md** - Data examples and patterns
3. **EXTRACTION_SUMMARY.md** (this file) - Overview and metadata
4. **SQL_Server_連線操作完整手冊_AI適用.md** - Connection guide (Chinese)

---

**Extraction Complete!**
*Total Documentation: ~15,000 words*
*Format: AI-optimized, compact, structured*
*Ready for: AI agents, developers, DBAs*

---

**Generated**: 2025-10-31
**Extracted by**: Claude Code AI Agent
**Database**: GameSpacedatabase
**Server**: (local)\SQLEXPRESS
**Status**: ✅ Production-Ready
