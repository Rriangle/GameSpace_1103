# GameSpace MiniGame Area - Complete Database Schema (AI-Optimized)

**Database**: GameSpacedatabase
**Server**: (local)\SQLEXPRESS
**Extraction Date**: 2025-10-31
**Total Tables**: 20 (MiniGame Area Focus)
**Total Records**: ~13,000+

---

## 📋 TABLE SUMMARY

| # | Table | Rows | PK | Description |
|---|-------|------|----|----|
| 1 | User_Wallet | 200 | User_Id | Member wallet balances |
| 2 | WalletHistory | 1,928 | LogID | Wallet transaction log |
| 3 | CouponType | 3 | CouponTypeID | Coupon templates |
| 4 | Coupon | 4,587 | CouponID | Coupon instances (UQ: CouponCode) |
| 5 | EVoucherType | 20 | EVoucherTypeID | E-voucher templates |
| 6 | EVoucher | 355 | EVoucherID | E-voucher instances (UQ: EVoucherCode) |
| 7 | EVoucherToken | 355 | TokenID | E-voucher redemption tokens (UQ: Token) |
| 8 | EVoucherRedeemLog | 800 | RedeemID | E-voucher scan/redeem log |
| 9 | Pet | 200 | PetID | Virtual pet data |
| 10 | PetSkinColorCostSettings | 11 | SettingId | Pet skin color pricing (UQ: ColorCode) |
| 11 | PetBackgroundCostSettings | 11 | SettingId | Pet background pricing (UQ: BackgroundCode) |
| 12 | PetLevelRewardSettings | 25 | SettingId | Pet level-up rewards (UQ: LevelRange) |
| 13 | SignInRule | 10 | Id | Daily check-in rules |
| 14 | UserSignInStats | 2,400 | LogID | User check-in records |
| 15 | MiniGame | 2,000 | PlayID | Game play records |
| 16 | SystemSettings | 56 | SettingId | System config key-value (UQ: SettingKey) |
| 17 | Users | 200 | User_ID | User master table (UQ: User_name, User_Account) |
| 18 | ManagerData | 102 | Manager_Id | Admin accounts (UQ: Manager_Email, Manager_Account) |
| 19 | ManagerRole | 102 | Manager_Id, ManagerRole_Id | Admin role assignments (composite PK) |
| 20 | ManagerRolePermission | 8 | ManagerRole_Id | Role permission definitions |

---

## 🔗 FOREIGN KEY RELATIONSHIPS

### Wallet System
- **User_Wallet**.User_Id → **Users**.User_ID
- **WalletHistory**.UserID → **Users**.User_ID

### Coupon System
- **Coupon**.CouponTypeID → **CouponType**.CouponTypeID
- **Coupon**.UserID → **Users**.User_ID

### E-Voucher System
- **EVoucher**.EVoucherTypeID → **EVoucherType**.EVoucherTypeID
- **EVoucher**.UserID → **Users**.User_ID
- **EVoucherToken**.EVoucherID → **EVoucher**.EVoucherID
- **EVoucherRedeemLog**.EVoucherID → **EVoucher**.EVoucherID
- **EVoucherRedeemLog**.TokenID → **EVoucherToken**.TokenID
- **EVoucherRedeemLog**.UserID → **Users**.User_ID

### Pet System
- **Pet**.UserID → **Users**.User_ID
- **MiniGame**.PetID → **Pet**.PetID
- **MiniGame**.UserID → **Users**.User_ID

### Sign-In System
- **SignInRule**.CouponTypeCode → **CouponType**.Name
- **UserSignInStats**.UserID → **Users**.User_ID

### Settings & Management
- **SystemSettings**.UpdatedBy → **ManagerData**.Manager_Id
- **PetBackgroundCostSettings**.UpdatedBy → **ManagerData**.Manager_Id
- **ManagerRole**.Manager_Id → **ManagerData**.Manager_Id
- **ManagerRole**.ManagerRole_Id → **ManagerRolePermission**.ManagerRole_Id

---

## 📊 DETAILED TABLE SCHEMAS

### 1. **User_Wallet** (6 columns)
Stores member wallet point balances with soft delete support.

| Column | Type | Null | Default | Key | Notes |
|--------|------|------|---------|-----|-------|
| User_Id | int | NO | - | PK, FK→Users | User identifier |
| User_Point | int | NO | 0 | - | Current point balance |
| IsDeleted | bit | NO | 0 | - | Soft delete flag |
| DeletedAt | datetime2(7) | YES | NULL | - | Deletion timestamp (UTC) |
| DeletedBy | int | YES | NULL | - | Deleted by user ID |
| DeleteReason | nvarchar(500) | YES | NULL | - | Deletion reason |

**Indexes**: PK_User_Wallet (CLUSTERED, UNIQUE on User_Id)

---

### 2. **WalletHistory** (11 columns)
Transaction log for all wallet point/coupon/e-voucher changes.

| Column | Type | Null | Default | Key | Notes |
|--------|------|------|---------|-----|-------|
| LogID | int | NO | IDENTITY | PK | Auto-increment |
| UserID | int | NO | - | FK→Users | User who made transaction |
| ChangeType | nvarchar(20) | NO | - | - | Point/Coupon/EVoucher |
| PointsChanged | int | NO | - | - | Delta value (+/-) |
| ItemCode | nvarchar(50) | YES | NULL | - | Related item code |
| Description | nvarchar(500) | NO | - | - | Transaction description |
| ChangeTime | datetime2(7) | NO | sysutcdatetime() | - | Transaction time (UTC) |
| IsDeleted | bit | NO | 0 | - | Soft delete flag |
| DeletedAt | datetime2(7) | YES | NULL | - | Deletion timestamp |
| DeletedBy | int | YES | NULL | - | Deleted by user ID |
| DeleteReason | nvarchar(500) | YES | NULL | - | Deletion reason |

**Indexes**:
- PK_WalletHistory (CLUSTERED, UNIQUE on LogID)
- IX_WalletHistory_ChangeTime (NONCLUSTERED on ChangeTime)
- IX_WalletHistory_UserID (NONCLUSTERED on UserID)

**Check Constraints**:
- CHK_WalletHistory_ChangeType: ChangeType IN ('Point', 'Coupon', 'EVoucher')

---

### 3. **CouponType** (13 columns)
Coupon template definitions (discount rules, expiry, cost).

| Column | Type | Null | Default | Key | Notes |
|--------|------|------|---------|-----|-------|
| CouponTypeID | int | NO | IDENTITY | PK | Auto-increment |
| Name | nvarchar(100) | NO | - | - | Display name |
| DiscountType | nvarchar(20) | NO | - | - | Amount/Percent |
| DiscountValue | decimal(18,2) | YES | NULL | - | Discount value |
| MinSpend | decimal(18,2) | YES | NULL | - | Min purchase amount |
| ValidFrom | datetime2(7) | NO | - | - | Valid start date |
| ValidTo | datetime2(7) | NO | - | - | Valid end date |
| PointsCost | int | NO | - | - | Points to redeem |
| Description | nvarchar(500) | YES | NULL | - | Description |
| IsDeleted | bit | NO | 0 | - | Soft delete flag |
| DeletedAt | datetime2(7) | YES | NULL | - | Deletion timestamp |
| DeletedBy | int | YES | NULL | - | Deleted by user ID |
| DeleteReason | nvarchar(500) | YES | NULL | - | Deletion reason |

**Indexes**: PK_CouponType (CLUSTERED, UNIQUE on CouponTypeID)

**Check Constraints**:
- CHK_CouponType_DiscountType: DiscountType IN ('Amount', 'Percent')
- CHK_CouponType_ValidDates: ValidTo >= ValidFrom

---

### 4. **Coupon** (12 columns)
Individual coupon instances owned by users.

| Column | Type | Null | Default | Key | Notes |
|--------|------|------|---------|-----|-------|
| CouponID | int | NO | IDENTITY | PK | Auto-increment |
| CouponCode | nvarchar(50) | NO | - | UQ | Unique coupon code |
| CouponTypeID | int | NO | - | FK→CouponType | Template reference |
| UserID | int | NO | - | FK→Users | Owner |
| IsUsed | bit | NO | 0 | - | Usage status |
| AcquiredTime | datetime2(7) | NO | sysutcdatetime() | - | Acquisition time (UTC) |
| UsedTime | datetime2(7) | YES | NULL | - | Usage time |
| UsedInOrderID | nvarchar(20) | YES | NULL | - | Order ID if used |
| IsDeleted | bit | NO | 0 | - | Soft delete flag |
| DeletedAt | datetime2(7) | YES | NULL | - | Deletion timestamp |
| DeletedBy | int | YES | NULL | - | Deleted by user ID |
| DeleteReason | nvarchar(500) | YES | NULL | - | Deletion reason |

**Indexes**:
- PK_Coupon (CLUSTERED, UNIQUE on CouponID)
- UQ_Coupon_Code (UNIQUE on CouponCode)
- IX_Coupon_UserID (NONCLUSTERED on UserID)

---

### 5. **EVoucherType** (12 columns)
E-voucher template definitions (gift cards, etc.).

| Column | Type | Null | Default | Key | Notes |
|--------|------|------|---------|-----|-------|
| EVoucherTypeID | int | NO | IDENTITY | PK | Auto-increment |
| Name | nvarchar(100) | NO | - | - | Display name |
| ValueAmount | decimal(18,2) | NO | - | - | Face value |
| ValidFrom | datetime2(7) | NO | - | - | Valid start date |
| ValidTo | datetime2(7) | NO | - | - | Valid end date |
| PointsCost | int | NO | - | - | Points to redeem |
| TotalAvailable | int | NO | - | - | Stock quantity |
| Description | nvarchar(500) | YES | NULL | - | Description |
| IsDeleted | bit | NO | 0 | - | Soft delete flag |
| DeletedAt | datetime2(7) | YES | NULL | - | Deletion timestamp |
| DeletedBy | int | YES | NULL | - | Deleted by user ID |
| DeleteReason | nvarchar(500) | YES | NULL | - | Deletion reason |

**Indexes**: PK_EVoucherType (CLUSTERED, UNIQUE on EVoucherTypeID)

**Check Constraints**:
- CHK_EVoucherType_ValidDates: ValidTo >= ValidFrom

---

### 6. **EVoucher** (11 columns)
Individual e-voucher instances owned by users.

| Column | Type | Null | Default | Key | Notes |
|--------|------|------|---------|-----|-------|
| EVoucherID | int | NO | IDENTITY | PK | Auto-increment |
| EVoucherCode | nvarchar(50) | NO | - | UQ | Unique voucher code |
| EVoucherTypeID | int | NO | - | FK→EVoucherType | Template reference |
| UserID | int | NO | - | FK→Users | Owner |
| IsUsed | bit | NO | 0 | - | Usage status |
| AcquiredTime | datetime2(7) | NO | sysutcdatetime() | - | Acquisition time (UTC) |
| UsedTime | datetime2(7) | YES | NULL | - | Usage time |
| IsDeleted | bit | NO | 0 | - | Soft delete flag |
| DeletedAt | datetime2(7) | YES | NULL | - | Deletion timestamp |
| DeletedBy | int | YES | NULL | - | Deleted by user ID |
| DeleteReason | nvarchar(500) | YES | NULL | - | Deletion reason |

**Indexes**:
- PK_EVoucher (CLUSTERED, UNIQUE on EVoucherID)
- UQ_EVoucher_Code (UNIQUE on EVoucherCode)
- IX_EVoucher_UserID (NONCLUSTERED on UserID)

---

### 7. **EVoucherToken** (9 columns)
Redemption tokens for e-vouchers (QR codes, etc.).

| Column | Type | Null | Default | Key | Notes |
|--------|------|------|---------|-----|-------|
| TokenID | int | NO | IDENTITY | PK | Auto-increment |
| EVoucherID | int | NO | - | FK→EVoucher | Voucher reference |
| Token | nvarchar(64) | NO | - | UQ | Unique token string |
| ExpiresAt | datetime2(7) | NO | - | - | Token expiry |
| IsRevoked | bit | NO | 0 | - | Revocation status |
| IsDeleted | bit | NO | 0 | - | Soft delete flag |
| DeletedAt | datetime2(7) | YES | NULL | - | Deletion timestamp |
| DeletedBy | int | YES | NULL | - | Deleted by user ID |
| DeleteReason | nvarchar(500) | YES | NULL | - | Deletion reason |

**Indexes**:
- PK_EVoucherToken (CLUSTERED, UNIQUE on TokenID)
- UQ_EVoucherToken_Token (UNIQUE on Token)

---

### 8. **EVoucherRedeemLog** (10 columns)
Logs every voucher scan/redemption attempt.

| Column | Type | Null | Default | Key | Notes |
|--------|------|------|---------|-----|-------|
| RedeemID | int | NO | IDENTITY | PK | Auto-increment |
| EVoucherID | int | NO | - | FK→EVoucher | Voucher reference |
| TokenID | int | NO | - | FK→EVoucherToken | Token reference |
| UserID | int | NO | - | FK→Users | Redeemer |
| ScannedAt | datetime2(7) | NO | sysutcdatetime() | - | Scan time (UTC) |
| Status | nvarchar(20) | NO | - | - | Approved/Rejected/etc. |
| IsDeleted | bit | NO | 0 | - | Soft delete flag |
| DeletedAt | datetime2(7) | YES | NULL | - | Deletion timestamp |
| DeletedBy | int | YES | NULL | - | Deleted by user ID |
| DeleteReason | nvarchar(500) | YES | NULL | - | Deletion reason |

**Indexes**:
- PK_EVoucherRedeemLog (CLUSTERED, UNIQUE on RedeemID)
- IX_EVoucherRedeemLog_EVoucherID (NONCLUSTERED on EVoucherID)
- IX_EVoucherRedeemLog_TokenID (NONCLUSTERED on TokenID)

**Check Constraints**:
- CHK_EVoucherRedeemLog_Status: Status IN ('Approved', 'Rejected', 'Expired', 'AlreadyUsed', 'Revoked')

---

### 9. **Pet** (26 columns)
Virtual pet system with stats, customization, and leveling.

| Column | Type | Null | Default | Key | Notes |
|--------|------|------|---------|-----|-------|
| PetID | int | NO | IDENTITY | PK | Auto-increment |
| UserID | int | NO | - | FK→Users | Pet owner |
| PetName | nvarchar(50) | NO | - | - | Pet name |
| Level | int | NO | 1 | - | Current level |
| LevelUpTime | datetime2(7) | YES | NULL | - | Last level up time |
| Experience | int | NO | 0 | - | Total experience |
| Hunger | int | NO | 50 | - | Hunger stat (0-100) |
| Mood | int | NO | 50 | - | Mood stat (0-100) |
| Stamina | int | NO | 50 | - | Stamina stat (0-100) |
| Cleanliness | int | NO | 50 | - | Cleanliness (0-100) |
| Health | int | NO | 100 | - | Health stat (0-100) |
| SkinColor | nvarchar(7) | NO | '#000000' | - | Hex color code |
| SkinColorChangedTime | datetime2(7) | YES | NULL | - | Last skin change time |
| BackgroundColor | nvarchar(20) | NO | 'BG001' | - | Background code |
| BackgroundColorChangedTime | datetime2(7) | YES | NULL | - | Last BG change time |
| PointsChanged_SkinColor | int | YES | NULL | - | Points spent on skin |
| PointsChanged_BackgroundColor | int | YES | NULL | - | Points spent on BG |
| PointsGained_LevelUp | int | YES | NULL | - | Points from last level |
| PointsGainedTime_LevelUp | datetime2(7) | YES | NULL | - | Last level reward time |
| IsDeleted | bit | NO | 0 | - | Soft delete flag |
| DeletedAt | datetime2(7) | YES | NULL | - | Deletion timestamp |
| DeletedBy | int | YES | NULL | - | Deleted by user ID |
| DeleteReason | nvarchar(500) | YES | NULL | - | Deletion reason |
| CurrentExperience | int | YES | NULL | - | Current level exp |
| ExperienceToNextLevel | int | YES | NULL | - | Exp needed for next level |
| TotalPointsGained_LevelUp | int | YES | NULL | - | Total level-up points |

**Indexes**:
- PK_Pet (CLUSTERED, UNIQUE on PetID)
- IX_Pet_UserID (NONCLUSTERED on UserID)

**Check Constraints**:
- CHK_Pet_Hunger: Hunger BETWEEN 0 AND 100
- CHK_Pet_Mood: Mood BETWEEN 0 AND 100
- CHK_Pet_Stamina: Stamina BETWEEN 0 AND 100
- CHK_Pet_Cleanliness: Cleanliness BETWEEN 0 AND 100
- CHK_Pet_Health: Health BETWEEN 0 AND 100

---

### 10. **PetSkinColorCostSettings** (21 columns)
Pricing configuration for pet skin colors.

| Column | Type | Null | Default | Key | Notes |
|--------|------|------|---------|-----|-------|
| SettingId | int | NO | IDENTITY | PK | Auto-increment |
| ColorCode | nvarchar(7) | NO | - | UQ | Hex color code |
| ColorName | nvarchar(100) | NO | - | - | Display name |
| PointCost | int | NO | 0 | - | Points to unlock |
| UnlockLevel | int | NO | 1 | - | Required pet level |
| IsDefault | bit | NO | 0 | - | Default color flag |
| IsActive | bit | NO | 1 | - | Available for purchase |
| SortOrder | int | NO | 0 | - | Display order |
| CreatedAt | datetime2(7) | NO | sysutcdatetime() | - | Creation time |
| UpdatedAt | datetime2(7) | YES | NULL | - | Last update time |
| UpdatedBy | int | YES | NULL | FK→ManagerData | Updated by admin |
| CategoryTag | nvarchar(50) | YES | NULL | - | Category label |
| SeasonalStartDate | datetime2(7) | YES | NULL | - | Seasonal availability start |
| SeasonalEndDate | datetime2(7) | YES | NULL | - | Seasonal availability end |
| IsDeleted | bit | NO | 0 | - | Soft delete flag |
| DeletedAt | datetime2(7) | YES | NULL | - | Deletion timestamp |
| DeletedBy | int | YES | NULL | - | Deleted by admin |
| DeleteReason | nvarchar(500) | YES | NULL | - | Deletion reason |
| RarityLevel | int | NO | 1 | - | Rarity tier |
| SpecialEffectCode | nvarchar(50) | YES | NULL | - | Special effect code |
| PreviewImageUrl | nvarchar(500) | YES | NULL | - | Preview image URL |

**Indexes**:
- PK_PetSkinColorCostSettings (CLUSTERED, UNIQUE on SettingId)
- UQ_PetSkinColorCostSettings_ColorCode (UNIQUE on ColorCode)

---

### 11. **PetBackgroundCostSettings** (16 columns)
Pricing configuration for pet backgrounds.

| Column | Type | Null | Default | Key | Notes |
|--------|------|------|---------|-----|-------|
| SettingId | int | NO | IDENTITY | PK | Auto-increment |
| BackgroundCode | nvarchar(20) | NO | - | UQ | Background code |
| BackgroundName | nvarchar(100) | NO | - | - | Display name |
| PointCost | int | NO | 0 | - | Points to unlock |
| UnlockLevel | int | NO | 1 | - | Required pet level |
| IsDefault | bit | NO | 0 | - | Default background flag |
| IsActive | bit | NO | 1 | - | Available for purchase |
| SortOrder | int | NO | 0 | - | Display order |
| CreatedAt | datetime2(7) | NO | sysutcdatetime() | - | Creation time |
| UpdatedAt | datetime2(7) | YES | NULL | - | Last update time |
| UpdatedBy | int | YES | NULL | FK→ManagerData | Updated by admin |
| IsDeleted | bit | NO | 0 | - | Soft delete flag |
| DeletedAt | datetime2(7) | YES | NULL | - | Deletion timestamp |
| DeletedBy | int | YES | NULL | - | Deleted by admin |
| DeleteReason | nvarchar(500) | YES | NULL | - | Deletion reason |
| PreviewImageUrl | nvarchar(500) | YES | NULL | - | Preview image URL |

**Indexes**:
- PK_PetBackgroundCostSettings (CLUSTERED, UNIQUE on SettingId)
- UQ_PetBackgroundCostSettings_BackgroundCode (UNIQUE on BackgroundCode)

---

### 12. **PetLevelRewardSettings** (14 columns)
Reward configuration for pet level-ups.

| Column | Type | Null | Default | Key | Notes |
|--------|------|------|---------|-----|-------|
| SettingId | int | NO | IDENTITY | PK | Auto-increment |
| LevelRangeStart | int | NO | - | UQ (composite) | Level range start |
| LevelRangeEnd | int | NO | - | UQ (composite) | Level range end |
| RewardPoints | int | NO | 0 | - | Points rewarded |
| BonusPoints | int | NO | 0 | - | Bonus points |
| RewardType | nvarchar(50) | YES | NULL | - | Reward type |
| RewardDescription | nvarchar(500) | YES | NULL | - | Reward description |
| IsActive | bit | NO | 1 | - | Active status |
| CreatedAt | datetime2(7) | NO | sysutcdatetime() | - | Creation time |
| IsDeleted | bit | NO | 0 | - | Soft delete flag |
| DeletedAt | datetime2(7) | YES | NULL | - | Deletion timestamp |
| DeletedBy | int | YES | NULL | - | Deleted by admin |
| DeleteReason | nvarchar(500) | YES | NULL | - | Deletion reason |
| SortOrder | int | NO | 0 | - | Display order |

**Indexes**:
- PK_PetLevelRewardSettings (CLUSTERED, UNIQUE on SettingId)
- UQ_PetLevelRewardSettings_Range (UNIQUE on LevelRangeStart, LevelRangeEnd)

**Check Constraints**:
- CHK_PetLevelRewardSettings_Range: LevelRangeEnd >= LevelRangeStart

---

### 13. **SignInRule** (14 columns)
Daily check-in rules and reward configuration.

| Column | Type | Null | Default | Key | Notes |
|--------|------|------|---------|-----|-------|
| Id | int | NO | IDENTITY | PK | Auto-increment |
| DayNumber | int | NO | - | - | Check-in day number |
| PointReward | int | NO | 0 | - | Points rewarded |
| BonusMultiplier | decimal(18,2) | NO | 1.00 | - | Bonus multiplier |
| IsMilestone | bit | NO | 0 | - | Milestone flag |
| CouponTypeCode | nvarchar(100) | YES | NULL | FK→CouponType.Name | Coupon reward |
| Description | nvarchar(500) | YES | NULL | - | Description |
| IsActive | bit | NO | 1 | - | Active status |
| CreatedAt | datetime2(7) | NO | sysutcdatetime() | - | Creation time |
| UpdatedAt | datetime2(7) | YES | NULL | - | Last update time |
| IsDeleted | bit | NO | 0 | - | Soft delete flag |
| DeletedAt | datetime2(7) | YES | NULL | - | Deletion timestamp |
| DeletedBy | int | YES | NULL | - | Deleted by admin |
| DeleteReason | nvarchar(500) | YES | NULL | - | Deletion reason |

**Indexes**: PK_SignInRule (CLUSTERED, UNIQUE on Id)

---

### 14. **UserSignInStats** (13 columns)
User daily check-in records and streak tracking.

| Column | Type | Null | Default | Key | Notes |
|--------|------|------|---------|-----|-------|
| LogID | int | NO | IDENTITY | PK | Auto-increment |
| UserID | int | NO | - | FK→Users | User reference |
| SignInDate | date | NO | - | - | Check-in date |
| PointsGained | int | NO | 0 | - | Points earned |
| BonusApplied | decimal(18,2) | NO | 0.00 | - | Bonus applied |
| CouponGained | nvarchar(50) | YES | NULL | - | Coupon code gained |
| CurrentStreak | int | NO | 1 | - | Current streak days |
| LongestStreak | int | NO | 1 | - | Longest streak days |
| CreatedAt | datetime2(7) | NO | sysutcdatetime() | - | Record creation time |
| IsDeleted | bit | NO | 0 | - | Soft delete flag |
| DeletedAt | datetime2(7) | YES | NULL | - | Deletion timestamp |
| DeletedBy | int | YES | NULL | - | Deleted by admin |
| DeleteReason | nvarchar(500) | YES | NULL | - | Deletion reason |

**Indexes**:
- PK_UserSignInStats (CLUSTERED, UNIQUE on LogID)
- IX_UserSignInStats_UserID (NONCLUSTERED on UserID)
- IX_UserSignInStats_SignInDate (NONCLUSTERED on SignInDate)

---

### 15. **MiniGame** (24 columns)
Game play records with pet interaction and scoring.

| Column | Type | Null | Default | Key | Notes |
|--------|------|------|---------|-----|-------|
| PlayID | int | NO | IDENTITY | PK | Auto-increment |
| UserID | int | NO | - | FK→Users | Player reference |
| PetID | int | YES | NULL | FK→Pet | Pet used in game |
| GameType | nvarchar(50) | NO | - | - | Game type identifier |
| Score | int | NO | 0 | - | Final score |
| PointsEarned | int | NO | 0 | - | Points earned |
| BonusPoints | int | NO | 0 | - | Bonus points |
| Duration | int | YES | NULL | - | Game duration (seconds) |
| Difficulty | nvarchar(20) | NO | 'Normal' | - | Difficulty level |
| IsCompleted | bit | NO | 0 | - | Completion status |
| PlayedAt | datetime2(7) | NO | sysutcdatetime() | - | Play time (UTC) |
| PetHungerChange | int | NO | 0 | - | Pet hunger change |
| PetMoodChange | int | NO | 0 | - | Pet mood change |
| PetStaminaChange | int | NO | 0 | - | Pet stamina change |
| PetExperienceGained | int | NO | 0 | - | Pet exp gained |
| AchievementsUnlocked | nvarchar(500) | YES | NULL | - | Achievements JSON |
| Multiplier | decimal(18,2) | NO | 1.00 | - | Score multiplier |
| GameVersion | nvarchar(20) | YES | NULL | - | Game version |
| IsDeleted | bit | NO | 0 | - | Soft delete flag |
| DeletedAt | datetime2(7) | YES | NULL | - | Deletion timestamp |
| DeletedBy | int | YES | NULL | - | Deleted by admin |
| DeleteReason | nvarchar(500) | YES | NULL | - | Deletion reason |
| RankAchieved | nvarchar(20) | YES | NULL | - | Rank achieved |
| ComboCount | int | NO | 0 | - | Max combo count |

**Indexes**:
- PK_MiniGame (CLUSTERED, UNIQUE on PlayID)
- IX_MiniGame_UserID (NONCLUSTERED on UserID)
- IX_MiniGame_PlayedAt (NONCLUSTERED on PlayedAt)
- IX_MiniGame_PetID (NONCLUSTERED on PetID)

**Check Constraints**:
- CHK_MiniGame_Difficulty: Difficulty IN ('Easy', 'Normal', 'Hard', 'Expert')

---

### 16. **SystemSettings** (15 columns)
System-wide configuration key-value store.

| Column | Type | Null | Default | Key | Notes |
|--------|------|------|---------|-----|-------|
| SettingId | int | NO | IDENTITY | PK | Auto-increment |
| SettingKey | nvarchar(100) | NO | - | UQ | Unique setting key |
| SettingValue | nvarchar(MAX) | YES | NULL | - | Setting value (JSON/text) |
| ValueType | nvarchar(50) | NO | 'String' | - | Data type |
| Category | nvarchar(100) | YES | NULL | - | Setting category |
| Description | nvarchar(500) | YES | NULL | - | Description |
| IsEncrypted | bit | NO | 0 | - | Encryption flag |
| IsActive | bit | NO | 1 | - | Active status |
| CreatedAt | datetime2(7) | NO | sysutcdatetime() | - | Creation time |
| UpdatedAt | datetime2(7) | YES | NULL | - | Last update time |
| UpdatedBy | int | YES | NULL | FK→ManagerData | Updated by admin |
| IsDeleted | bit | NO | 0 | - | Soft delete flag |
| DeletedAt | datetime2(7) | YES | NULL | - | Deletion timestamp |
| DeletedBy | int | YES | NULL | - | Deleted by admin |
| DeleteReason | nvarchar(500) | YES | NULL | - | Deletion reason |

**Indexes**:
- PK_SystemSettings (CLUSTERED, UNIQUE on SettingId)
- UQ_SystemSettings_Key (UNIQUE on SettingKey)

**Check Constraints**:
- CHK_SystemSettings_ValueType: ValueType IN ('String', 'Int', 'Decimal', 'Boolean', 'JSON', 'DateTime')

---

### 17. **Users** (11 columns)
User master table with authentication and profile data.

| Column | Type | Null | Default | Key | Notes |
|--------|------|------|---------|-----|-------|
| User_ID | int | NO | IDENTITY | PK | Auto-increment |
| User_name | nvarchar(450) | NO | - | UQ | Display name |
| User_Account | nvarchar(100) | NO | - | UQ | Login account |
| User_Password | nvarchar(256) | NO | - | - | Hashed password |
| User_Email | nvarchar(100) | NO | - | - | Email address |
| Registration_Date | datetime2(7) | NO | sysutcdatetime() | - | Registration time (UTC) |
| Account_Status | nvarchar(50) | NO | 'Active' | - | Active/Locked/etc. |
| IsDeleted | bit | NO | 0 | - | Soft delete flag |
| DeletedAt | datetime2(7) | YES | NULL | - | Deletion timestamp |
| DeletedBy | int | YES | NULL | - | Deleted by admin |
| DeleteReason | nvarchar(500) | YES | NULL | - | Deletion reason |

**Indexes**:
- PK_Users (CLUSTERED, UNIQUE on User_ID)
- UQ_Users_UserName (UNIQUE on User_name)
- UQ_Users_UserAccount (UNIQUE on User_Account)

**Check Constraints**:
- CHK_Users_AccountStatus: Account_Status IN ('Active', 'Locked', 'Suspended', 'Pending')

---

### 18. **ManagerData** (10 columns)
Admin account master table.

| Column | Type | Null | Default | Key | Notes |
|--------|------|------|---------|-----|-------|
| Manager_Id | int | NO | IDENTITY | PK | Auto-increment |
| Manager_Name | nvarchar(100) | NO | - | - | Display name |
| Manager_Account | nvarchar(100) | NO | - | UQ | Login account |
| Manager_Password | nvarchar(256) | NO | - | - | Hashed password |
| Manager_Email | nvarchar(100) | NO | - | UQ | Email address |
| IsLocked | bit | NO | 0 | - | Account lock status |
| CreatedAt | datetime2(7) | NO | sysutcdatetime() | - | Creation time (UTC) |
| IsDeleted | bit | NO | 0 | - | Soft delete flag |
| DeletedAt | datetime2(7) | YES | NULL | - | Deletion timestamp |
| DeleteReason | nvarchar(500) | YES | NULL | - | Deletion reason |

**Indexes**:
- PK_ManagerData (CLUSTERED, UNIQUE on Manager_Id)
- UQ_ManagerData_Email (UNIQUE on Manager_Email)
- UQ_ManagerData_Account (UNIQUE on Manager_Account)

---

### 19. **ManagerRole** (2 columns)
Admin role assignment junction table (Many-to-Many).

| Column | Type | Null | Default | Key | Notes |
|--------|------|------|---------|-----|-------|
| Manager_Id | int | NO | - | PK (composite), FK→ManagerData | Manager reference |
| ManagerRole_Id | int | NO | - | PK (composite), FK→ManagerRolePermission | Role reference |

**Indexes**:
- PK_ManagerRole (CLUSTERED, UNIQUE on Manager_Id, ManagerRole_Id)

---

### 20. **ManagerRolePermission** (8 columns)
Role permission definitions (RBAC).

| Column | Type | Null | Default | Key | Notes |
|--------|------|------|---------|-----|-------|
| ManagerRole_Id | int | NO | IDENTITY | PK | Auto-increment |
| role_name | nvarchar(50) | NO | - | - | Role name |
| UserStatusManagement | bit | NO | 0 | - | Can manage user status |
| Pet_Rights_Management | bit | NO | 0 | - | Can manage pet system |
| ShoppingPermissionManagement | bit | NO | 0 | - | Can manage shopping |
| MiniGame_Management | bit | NO | 0 | - | Can manage mini games |
| Permission_Management | bit | NO | 0 | - | Can manage permissions |
| Game_Score_Management | bit | NO | 0 | - | Can manage game scores |

**Indexes**: PK_ManagerRolePermission (CLUSTERED, UNIQUE on ManagerRole_Id)

---

## 🎯 COMMON DESIGN PATTERNS

### Soft Delete (All Tables)
Every table implements soft delete with 4 columns:
- `IsDeleted` (bit, default 0)
- `DeletedAt` (datetime2, nullable)
- `DeletedBy` (int, nullable)
- `DeleteReason` (nvarchar(500), nullable)

### Audit Trail (Most Tables)
Common audit columns:
- `CreatedAt` (datetime2, default sysutcdatetime())
- `UpdatedAt` (datetime2, nullable)
- `UpdatedBy` (int, FK to ManagerData)

### Identity Columns
All primary keys use `IDENTITY(1,1)` except:
- **User_Wallet**: PK is User_Id (FK to Users)
- **ManagerRole**: Composite PK (no identity)

### Timestamp Strategy
All timestamps use `datetime2(7)` with UTC time (`sysutcdatetime()`)

---

## 📈 DATA STATISTICS

| Category | Count | Notes |
|----------|-------|-------|
| Total Tables | 20 | MiniGame Area focus |
| Total Columns | 287 | Average ~14 cols/table |
| Primary Keys | 20 | All tables have PK |
| Foreign Keys | 16 | Strong referential integrity |
| Unique Constraints | 13 | Business rule enforcement |
| Check Constraints | 14 | Data validation rules |
| Indexes | 40+ | Performance optimization |
| Total Records | ~13,000 | Across all 20 tables |

---

## 🔍 IMPORTANT NOTES

### Security
- All passwords stored as hashed values (nvarchar(256))
- Manager and User accounts have separate authentication
- RBAC implemented via ManagerRole + ManagerRolePermission

### Data Integrity
- Extensive use of CHECK constraints for enum-like fields
- Unique constraints on business-critical codes (CouponCode, EVoucherCode, Token, etc.)
- Foreign keys enforce referential integrity

### Performance
- Strategic indexes on frequently queried columns (UserID, dates)
- Clustered indexes on all primary keys
- Nonclustered indexes on foreign keys

### Business Logic
- Points system: Users earn/spend points via wallet
- Gamification: Pet leveling, mini games, daily check-ins
- Reward system: Coupons, e-vouchers, points from various activities
- Soft delete everywhere: No hard deletes, full audit trail

---

**End of Schema Document**
*Generated: 2025-10-31 for AI consumption*
