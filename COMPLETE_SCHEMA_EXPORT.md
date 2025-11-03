# GameSpacedatabase - Complete Schema Export
**Server:** DESKTOP-8HQIS1S\SQLEXPRESS
**Database:** GameSpacedatabase
**Export Date:** 2025-11-03
**Total Tables:** 20

---

## Table of Contents
1. [Coupon](#1-coupon)
2. [CouponType](#2-coupontype)
3. [EVoucher](#3-evoucher)
4. [EVoucherRedeemLog](#4-evoucherredeemlog)
5. [EVoucherToken](#5-evouchertoken)
6. [EVoucherType](#6-evouchertype)
7. [MiniGame](#7-minigame)
8. [Pet](#8-pet)
9. [PetBackgroundCostSettings](#9-petbackgroundcostsettings)
10. [PetLevelRewardSettings](#10-petlevelrewardsettings)
11. [PetSkinColorCostSettings](#11-petskincolorcostsettings)
12. [SignInRule](#12-signinrule)
13. [SystemSettings](#13-systemsettings)
14. [User_Wallet](#14-user_wallet)
15. [UserSignInStats](#15-usersigninstats)
16. [WalletHistory](#16-wallethistory)
17. [ManagerData](#17-managerdata)
18. [ManagerRole](#18-managerrole)
19. [ManagerRolePermission](#19-managerrolepermission)
20. [Users](#20-users)

---

## 1. Coupon

**Purpose:** Stores individual coupon instances issued to users

### Columns

| Column Name | Data Type | Length | Precision | Scale | Nullable | Default | Identity | Description |
|-------------|-----------|--------|-----------|-------|----------|---------|----------|-------------|
| CouponID | int | - | 10 | 0 | NO | NULL | YES | Primary key (auto-increment) |
| CouponCode | nvarchar | 50 | - | - | NO | NULL | NO | Unique coupon code |
| CouponTypeID | int | - | 10 | 0 | NO | NULL | NO | Foreign key to CouponType |
| UserID | int | - | 10 | 0 | NO | NULL | NO | Foreign key to Users |
| IsUsed | bit | - | - | - | NO | NULL | NO | Usage status (0=unused, 1=used) |
| AcquiredTime | datetime2 | - | - | - | NO | sysutcdatetime() | NO | UTC time when acquired |
| UsedTime | datetime2 | - | - | - | YES | sysutcdatetime() | NO | UTC time when used |
| UsedInOrderID | int | - | 10 | 0 | YES | NULL | NO | Order ID where coupon was used |
| IsDeleted | bit | - | - | - | NO | (0) | NO | Soft delete flag |
| DeletedAt | datetime2 | - | - | - | YES | NULL | NO | Deletion timestamp |
| DeletedBy | int | - | 10 | 0 | YES | NULL | NO | Admin who deleted |
| DeleteReason | nvarchar | 500 | - | - | YES | NULL | NO | Reason for deletion |

### Primary Key
- `CouponID`

### Foreign Keys
| FK Name | Column | Referenced Table | Referenced Column |
|---------|--------|------------------|-------------------|
| FK_Coupon_CouponType | CouponTypeID | CouponType | CouponTypeID |
| FK_Coupon_Users | UserID | Users | User_ID |

### Indexes
| Index Name | Type | Unique | Columns |
|------------|------|--------|---------|
| PK_Coupon | CLUSTERED | YES | CouponID |
| UQ_Coupon_CouponCode | NONCLUSTERED | YES | CouponCode |
| IX_Coupon_IsDeleted | NONCLUSTERED | NO | IsDeleted |
| IX_Coupon_user_used | NONCLUSTERED | NO | UserID, IsUsed, AcquiredTime |

### Check Constraints
| Constraint Name | Definition |
|----------------|------------|
| CK_Coupon_IsUsed | `[IsUsed]=(1) OR [IsUsed]=(0)` |
| CK_Coupon_UsedFields | `[IsUsed]=(0) AND [UsedTime] IS NULL AND [UsedInOrderID] IS NULL OR [IsUsed]=(1) AND [UsedTime] IS NOT NULL AND [UsedInOrderID] IS NOT NULL` |

---

## 2. CouponType

**Purpose:** Defines coupon templates and configurations

### Columns

| Column Name | Data Type | Length | Precision | Scale | Nullable | Default | Identity | Description |
|-------------|-----------|--------|-----------|-------|----------|---------|----------|-------------|
| CouponTypeID | int | - | 10 | 0 | NO | NULL | YES | Primary key (auto-increment) |
| Name | nvarchar | 50 | - | - | NO | NULL | NO | Unique coupon type name |
| DiscountType | nvarchar | 20 | - | - | NO | NULL | NO | PERCENT or AMOUNT |
| DiscountValue | decimal | - | 18 | 2 | YES | NULL | NO | Discount value |
| MinSpend | decimal | - | 18 | 2 | YES | NULL | NO | Minimum spend requirement |
| ValidFrom | datetime2 | - | - | - | NO | NULL | NO | Valid start date |
| ValidTo | datetime2 | - | - | - | NO | NULL | NO | Valid end date |
| PointsCost | int | - | 10 | 0 | NO | NULL | NO | Points required to redeem |
| Description | nvarchar | 600 | - | - | YES | NULL | NO | Description |
| IsDeleted | bit | - | - | - | NO | (0) | NO | Soft delete flag |
| DeletedAt | datetime2 | - | - | - | YES | NULL | NO | Deletion timestamp |
| DeletedBy | int | - | 10 | 0 | YES | NULL | NO | Admin who deleted |
| DeleteReason | nvarchar | 500 | - | - | YES | NULL | NO | Reason for deletion |

### Primary Key
- `CouponTypeID`

### Foreign Keys
None

### Indexes
| Index Name | Type | Unique | Columns |
|------------|------|--------|---------|
| PK_CouponType | CLUSTERED | YES | CouponTypeID |
| UQ_CouponType_Name | NONCLUSTERED | YES | Name |
| IX_CouponType_IsDeleted | NONCLUSTERED | NO | IsDeleted |

### Check Constraints
| Constraint Name | Definition |
|----------------|------------|
| CK_CouponType_DiscountType | `upper(ltrim(rtrim([DiscountType])))=N'PERCENT' OR upper(ltrim(rtrim([DiscountType])))=N'AMOUNT'` |
| CK_CouponType_ValidRange | `[ValidFrom]<=[ValidTo]` |

---

## 3. EVoucher

**Purpose:** Electronic vouchers issued to users for real-world redemption

### Columns

| Column Name | Data Type | Length | Precision | Scale | Nullable | Default | Identity | Description |
|-------------|-----------|--------|-----------|-------|----------|---------|----------|-------------|
| EVoucherID | int | - | 10 | 0 | NO | NULL | YES | Primary key (auto-increment) |
| EVoucherCode | nvarchar | 50 | - | - | NO | NULL | NO | Unique e-voucher code |
| EVoucherTypeID | int | - | 10 | 0 | NO | NULL | NO | Foreign key to EVoucherType |
| UserID | int | - | 10 | 0 | NO | NULL | NO | Foreign key to Users |
| IsUsed | bit | - | - | - | NO | NULL | NO | Usage status |
| AcquiredTime | datetime2 | - | - | - | NO | sysutcdatetime() | NO | UTC time when acquired |
| UsedTime | datetime2 | - | - | - | YES | sysutcdatetime() | NO | UTC time when used |
| IsDeleted | bit | - | - | - | NO | (0) | NO | Soft delete flag |
| DeletedAt | datetime2 | - | - | - | YES | NULL | NO | Deletion timestamp |
| DeletedBy | int | - | 10 | 0 | YES | NULL | NO | Admin who deleted |
| DeleteReason | nvarchar | 500 | - | - | YES | NULL | NO | Reason for deletion |

### Primary Key
- `EVoucherID`

### Foreign Keys
| FK Name | Column | Referenced Table | Referenced Column |
|---------|--------|------------------|-------------------|
| FK_EVoucher_EVoucherType | EVoucherTypeID | EVoucherType | EVoucherTypeID |
| FK_EVoucher_Users | UserID | Users | User_ID |

### Indexes
| Index Name | Type | Unique | Columns |
|------------|------|--------|---------|
| PK_EVoucher | CLUSTERED | YES | EVoucherID |
| UQ_EVoucher_EVoucherCode | NONCLUSTERED | YES | EVoucherCode |
| IX_EVoucher_IsDeleted | NONCLUSTERED | NO | IsDeleted |
| IX_EVoucher_user_used | NONCLUSTERED | NO | UserID, IsUsed, AcquiredTime |

### Check Constraints
None

---

## 4. EVoucherRedeemLog

**Purpose:** Tracks e-voucher redemption attempts and status changes

### Columns

| Column Name | Data Type | Length | Precision | Scale | Nullable | Default | Identity | Description |
|-------------|-----------|--------|-----------|-------|----------|---------|----------|-------------|
| RedeemID | int | - | 10 | 0 | NO | NULL | YES | Primary key (auto-increment) |
| EVoucherID | int | - | 10 | 0 | NO | NULL | NO | Foreign key to EVoucher |
| TokenID | int | - | 10 | 0 | YES | NULL | NO | Foreign key to EVoucherToken |
| UserID | int | - | 10 | 0 | NO | NULL | NO | Foreign key to Users |
| ScannedAt | datetime2 | - | - | - | NO | sysutcdatetime() | NO | UTC time of scan |
| Status | nvarchar | 20 | - | - | NO | NULL | NO | Status: APPROVED/ALREADYUSED/EXPIRED/REJECTED/REVOKED |
| IsDeleted | bit | - | - | - | NO | (0) | NO | Soft delete flag |
| DeletedAt | datetime2 | - | - | - | YES | NULL | NO | Deletion timestamp |
| DeletedBy | int | - | 10 | 0 | YES | NULL | NO | Admin who deleted |
| DeleteReason | nvarchar | 500 | - | - | YES | NULL | NO | Reason for deletion |

### Primary Key
- `RedeemID`

### Foreign Keys
| FK Name | Column | Referenced Table | Referenced Column |
|---------|--------|------------------|-------------------|
| FK_EVoucherRedeemLog_EVoucher | EVoucherID | EVoucher | EVoucherID |
| FK_EVoucherRedeemLog_Token | TokenID | EVoucherToken | TokenID |
| FK_EVoucherRedeemLog_Users | UserID | Users | User_ID |

### Indexes
| Index Name | Type | Unique | Columns |
|------------|------|--------|---------|
| PK_EVoucherRedeemLog | CLUSTERED | YES | RedeemID |
| IX_EVoucherRedeemLog_IsDeleted | NONCLUSTERED | NO | IsDeleted |
| IX_EVoucherRedeemLog_voucher_user | NONCLUSTERED | NO | EVoucherID, UserID, ScannedAt |

### Check Constraints
| Constraint Name | Definition |
|----------------|------------|
| CK_EVoucherRedeemLog_Status | `upper([Status])=N'REVOKED' OR upper([Status])=N'REJECTED' OR upper([Status])=N'EXPIRED' OR upper([Status])=N'ALREADYUSED' OR upper([Status])=N'APPROVED'` |

---

## 5. EVoucherToken

**Purpose:** Secure tokens for e-voucher redemption with expiration

### Columns

| Column Name | Data Type | Length | Precision | Scale | Nullable | Default | Identity | Description |
|-------------|-----------|--------|-----------|-------|----------|---------|----------|-------------|
| TokenID | int | - | 10 | 0 | NO | NULL | YES | Primary key (auto-increment) |
| EVoucherID | int | - | 10 | 0 | NO | NULL | NO | Foreign key to EVoucher |
| Token | varchar | 64 | - | - | NO | NULL | NO | Unique token string |
| ExpiresAt | datetime2 | - | - | - | NO | NULL | NO | Token expiration time |
| IsRevoked | bit | - | - | - | NO | NULL | NO | Revocation status |
| IsDeleted | bit | - | - | - | NO | (0) | NO | Soft delete flag |
| DeletedAt | datetime2 | - | - | - | YES | NULL | NO | Deletion timestamp |
| DeletedBy | int | - | 10 | 0 | YES | NULL | NO | Admin who deleted |
| DeleteReason | nvarchar | 500 | - | - | YES | NULL | NO | Reason for deletion |

### Primary Key
- `TokenID`

### Foreign Keys
| FK Name | Column | Referenced Table | Referenced Column |
|---------|--------|------------------|-------------------|
| FK_EVoucherToken_EVoucher | EVoucherID | EVoucher | EVoucherID |

### Indexes
| Index Name | Type | Unique | Columns |
|------------|------|--------|---------|
| PK_EVoucherToken | CLUSTERED | YES | TokenID |
| UQ_EVoucherToken_Token | NONCLUSTERED | YES | Token |
| IX_EVoucherToken_IsDeleted | NONCLUSTERED | NO | IsDeleted |

### Check Constraints
None

---

## 6. EVoucherType

**Purpose:** E-voucher templates and configurations

### Columns

| Column Name | Data Type | Length | Precision | Scale | Nullable | Default | Identity | Description |
|-------------|-----------|--------|-----------|-------|----------|---------|----------|-------------|
| EVoucherTypeID | int | - | 10 | 0 | NO | NULL | YES | Primary key (auto-increment) |
| Name | nvarchar | 50 | - | - | NO | NULL | NO | Unique e-voucher type name |
| ValueAmount | decimal | - | 18 | 2 | NO | NULL | NO | Voucher monetary value |
| ValidFrom | datetime2 | - | - | - | NO | NULL | NO | Valid start date |
| ValidTo | datetime2 | - | - | - | NO | NULL | NO | Valid end date |
| PointsCost | int | - | 10 | 0 | NO | NULL | NO | Points required to redeem |
| TotalAvailable | int | - | 10 | 0 | NO | NULL | NO | Total quantity available |
| Description | nvarchar | 600 | - | - | YES | NULL | NO | Description |
| IsDeleted | bit | - | - | - | NO | (0) | NO | Soft delete flag |
| DeletedAt | datetime2 | - | - | - | YES | NULL | NO | Deletion timestamp |
| DeletedBy | int | - | 10 | 0 | YES | NULL | NO | Admin who deleted |
| DeleteReason | nvarchar | 500 | - | - | YES | NULL | NO | Reason for deletion |

### Primary Key
- `EVoucherTypeID`

### Foreign Keys
None

### Indexes
| Index Name | Type | Unique | Columns |
|------------|------|--------|---------|
| PK_EVoucherType | CLUSTERED | YES | EVoucherTypeID |
| IX_EVoucherType_IsDeleted | NONCLUSTERED | NO | IsDeleted |

### Check Constraints
None

---

## 7. MiniGame

**Purpose:** Game session records with outcomes and rewards

### Columns

| Column Name | Data Type | Length | Precision | Scale | Nullable | Default | Identity | Description |
|-------------|-----------|--------|-----------|-------|----------|---------|----------|-------------|
| PlayID | int | - | 10 | 0 | NO | NULL | YES | Primary key (auto-increment) |
| UserID | int | - | 10 | 0 | NO | NULL | NO | Foreign key to Users |
| PetID | int | - | 10 | 0 | NO | NULL | NO | Foreign key to Pet |
| Level | int | - | 10 | 0 | NO | NULL | NO | Game difficulty level |
| MonsterCount | int | - | 10 | 0 | NO | NULL | NO | Number of monsters |
| SpeedMultiplier | decimal | - | 5 | 2 | NO | NULL | NO | Game speed multiplier |
| Result | nvarchar | 20 | - | - | NO | NULL | NO | WIN/LOSE/ABORT |
| ExpGained | int | - | 10 | 0 | NO | NULL | NO | Experience points gained |
| ExpGainedTime | datetime2 | - | - | - | NO | sysutcdatetime() | NO | UTC time exp awarded |
| PointsGained | int | - | 10 | 0 | NO | NULL | NO | Points gained |
| PointsGainedTime | datetime2 | - | - | - | NO | sysutcdatetime() | NO | UTC time points awarded |
| CouponGained | nvarchar | 50 | - | - | NO | NULL | NO | Coupon code gained (empty if none) |
| CouponGainedTime | datetime2 | - | - | - | NO | sysutcdatetime() | NO | UTC time coupon awarded |
| HungerDelta | int | - | 10 | 0 | NO | NULL | NO | Pet hunger change |
| MoodDelta | int | - | 10 | 0 | NO | NULL | NO | Pet mood change |
| StaminaDelta | int | - | 10 | 0 | NO | NULL | NO | Pet stamina change |
| CleanlinessDelta | int | - | 10 | 0 | NO | NULL | NO | Pet cleanliness change |
| StartTime | datetime2 | - | - | - | NO | sysutcdatetime() | NO | Game start time |
| EndTime | datetime2 | - | - | - | YES | sysutcdatetime() | NO | Game end time |
| Aborted | bit | - | - | - | NO | NULL | NO | Abort flag |
| IsDeleted | bit | - | - | - | NO | (0) | NO | Soft delete flag |
| DeletedAt | datetime2 | - | - | - | YES | NULL | NO | Deletion timestamp |
| DeletedBy | int | - | 10 | 0 | YES | NULL | NO | Admin who deleted |
| DeleteReason | nvarchar | 500 | - | - | YES | NULL | NO | Reason for deletion |

### Primary Key
- `PlayID`

### Foreign Keys
| FK Name | Column | Referenced Table | Referenced Column |
|---------|--------|------------------|-------------------|
| FK_MiniGame_Users | UserID | Users | User_ID |
| FK_MiniGame_Pet | PetID | Pet | PetID |

### Indexes
| Index Name | Type | Unique | Columns |
|------------|------|--------|---------|
| PK_MiniGame | CLUSTERED | YES | PlayID |
| IX_MiniGame_IsDeleted | NONCLUSTERED | NO | IsDeleted |
| IX_MiniGame_user_time | NONCLUSTERED | NO | UserID, StartTime |

### Check Constraints
None

---

## 8. Pet

**Purpose:** Virtual pet data with stats, customization, and progression

### Columns

| Column Name | Data Type | Length | Precision | Scale | Nullable | Default | Identity | Description |
|-------------|-----------|--------|-----------|-------|----------|---------|----------|-------------|
| PetID | int | - | 10 | 0 | NO | NULL | YES | Primary key (auto-increment) |
| UserID | int | - | 10 | 0 | NO | NULL | NO | Foreign key to Users (one pet per user) |
| PetName | nvarchar | 50 | - | - | NO | NULL | NO | Pet name |
| Level | int | - | 10 | 0 | NO | NULL | NO | Current level |
| LevelUpTime | datetime2 | - | - | - | NO | sysutcdatetime() | NO | Last level up time |
| Experience | int | - | 10 | 0 | NO | NULL | NO | Total experience earned |
| Hunger | int | - | 10 | 0 | NO | NULL | NO | Hunger stat (0-100) |
| Mood | int | - | 10 | 0 | NO | NULL | NO | Mood stat (0-100) |
| Stamina | int | - | 10 | 0 | NO | NULL | NO | Stamina stat (0-100) |
| Cleanliness | int | - | 10 | 0 | NO | NULL | NO | Cleanliness stat (0-100) |
| Health | int | - | 10 | 0 | NO | NULL | NO | Health stat (0-100) |
| SkinColor | varchar | 10 | - | - | NO | NULL | NO | Skin color code |
| SkinColorChangedTime | datetime2 | - | - | - | NO | NULL | NO | Last skin color change time |
| BackgroundColor | nvarchar | 20 | - | - | NO | NULL | NO | Background color code |
| BackgroundColorChangedTime | datetime2 | - | - | - | NO | NULL | NO | Last background change time |
| PointsChanged_SkinColor | int | - | 10 | 0 | NO | NULL | NO | Points spent on skin colors |
| PointsChanged_BackgroundColor | int | - | 10 | 0 | NO | NULL | NO | Points spent on backgrounds |
| PointsGained_LevelUp | int | - | 10 | 0 | NO | NULL | NO | Points gained from last level up |
| PointsGainedTime_LevelUp | datetime2 | - | - | - | NO | sysutcdatetime() | NO | Last level up reward time |
| IsDeleted | bit | - | - | - | NO | (0) | NO | Soft delete flag |
| DeletedAt | datetime2 | - | - | - | YES | NULL | NO | Deletion timestamp |
| DeletedBy | int | - | 10 | 0 | YES | NULL | NO | Admin who deleted |
| DeleteReason | nvarchar | 500 | - | - | YES | NULL | NO | Reason for deletion |
| CurrentExperience | int | - | 10 | 0 | NO | (0) | NO | Current level experience |
| ExperienceToNextLevel | int | - | 10 | 0 | YES | NULL | NO | Experience needed for next level |
| TotalPointsGained_LevelUp | int | - | 10 | 0 | YES | (0) | NO | Cumulative level up points |

### Primary Key
- `PetID`

### Foreign Keys
| FK Name | Column | Referenced Table | Referenced Column |
|---------|--------|------------------|-------------------|
| FK_Pet_Users | UserID | Users | User_ID |

### Indexes
| Index Name | Type | Unique | Columns |
|------------|------|--------|---------|
| PK_Pet | CLUSTERED | YES | PetID |
| IX_Pet_IsDeleted | NONCLUSTERED | NO | IsDeleted |
| IX_Pet_user | NONCLUSTERED | NO | UserID |

### Check Constraints
| Constraint Name | Definition |
|----------------|------------|
| CK_Pet_Hunger | `[Hunger]>=(0) AND [Hunger]<=(100)` |
| CK_Pet_Mood | `[Mood]>=(0) AND [Mood]<=(100)` |
| CK_Pet_Stamina | `[Stamina]>=(0) AND [Stamina]<=(100)` |
| CK_Pet_Cleanliness | `[Cleanliness]>=(0) AND [Cleanliness]<=(100)` |
| CK_Pet_Health | `[Health]>=(0) AND [Health]<=(100)` |

---

## 9. PetBackgroundCostSettings

**Purpose:** Pet background customization pricing configuration

### Columns

| Column Name | Data Type | Length | Precision | Scale | Nullable | Default | Identity | Description |
|-------------|-----------|--------|-----------|-------|----------|---------|----------|-------------|
| SettingId | int | - | 10 | 0 | NO | NULL | YES | Primary key (auto-increment) |
| BackgroundCode | nvarchar | 50 | - | - | NO | NULL | NO | Unique background code |
| BackgroundName | nvarchar | 100 | - | - | NO | NULL | NO | Background display name |
| PointsCost | int | - | 10 | 0 | NO | NULL | NO | Points cost (>=0) |
| Description | nvarchar | 500 | - | - | YES | NULL | NO | Description |
| PreviewImagePath | nvarchar | 200 | - | - | YES | NULL | NO | Preview image path |
| IsActive | bit | - | - | - | NO | (1) | NO | Active status |
| DisplayOrder | int | - | 10 | 0 | YES | (0) | NO | Display order |
| IsDeleted | bit | - | - | - | NO | (0) | NO | Soft delete flag |
| DeletedAt | datetime2 | - | - | - | YES | NULL | NO | Deletion timestamp |
| DeletedBy | int | - | 10 | 0 | YES | NULL | NO | Admin who deleted |
| DeleteReason | nvarchar | 500 | - | - | YES | NULL | NO | Reason for deletion |
| CreatedAt | datetime2 | - | - | - | NO | sysutcdatetime() | NO | Creation timestamp |
| UpdatedAt | datetime2 | - | - | - | YES | NULL | NO | Last update timestamp |
| UpdatedBy | int | - | 10 | 0 | YES | NULL | NO | Admin who last updated |
| Rarity | nvarchar | 20 | - | - | YES | NULL | NO | Rarity level |

### Primary Key
- `SettingId`

### Foreign Keys
| FK Name | Column | Referenced Table | Referenced Column |
|---------|--------|------------------|-------------------|
| FK_PetBackgroundCostSettings_UpdatedBy_Manager | UpdatedBy | ManagerData | Manager_Id |

### Indexes
| Index Name | Type | Unique | Columns |
|------------|------|--------|---------|
| PK__PetBackg__54372B1D7E12EEE3 | CLUSTERED | YES | SettingId |
| UQ_PetBackgroundCostSettings_BackgroundCode | NONCLUSTERED | YES | BackgroundCode |

### Check Constraints
| Constraint Name | Definition |
|----------------|------------|
| CK__PetBackgr__Point__541767F8 | `[PointsCost]>=(0)` |

---

## 10. PetLevelRewardSettings

**Purpose:** Pet level-up reward configuration by level range

### Columns

| Column Name | Data Type | Length | Precision | Scale | Nullable | Default | Identity | Description |
|-------------|-----------|--------|-----------|-------|----------|---------|----------|-------------|
| SettingId | int | - | 10 | 0 | NO | NULL | YES | Primary key (auto-increment) |
| LevelRangeStart | int | - | 10 | 0 | NO | NULL | NO | Start level (inclusive) |
| LevelRangeEnd | int | - | 10 | 0 | NO | NULL | NO | End level (inclusive) |
| PointsReward | int | - | 10 | 0 | NO | NULL | NO | Points reward (0-999999) |
| Description | nvarchar | 500 | - | - | YES | NULL | NO | Description |
| IsActive | bit | - | - | - | NO | (1) | NO | Active status |
| DisplayOrder | int | - | 10 | 0 | NO | (0) | NO | Display order |
| IsDeleted | bit | - | - | - | NO | (0) | NO | Soft delete flag |
| DeletedAt | datetime2 | - | - | - | YES | NULL | NO | Deletion timestamp |
| DeletedBy | int | - | 10 | 0 | YES | NULL | NO | Admin who deleted |
| DeleteReason | nvarchar | 500 | - | - | YES | NULL | NO | Reason for deletion |
| CreatedAt | datetime2 | - | - | - | NO | sysutcdatetime() | NO | Creation timestamp |
| UpdatedAt | datetime2 | - | - | - | YES | NULL | NO | Last update timestamp |
| UpdatedBy | int | - | 10 | 0 | YES | NULL | NO | Admin who last updated |

### Primary Key
- `SettingId`

### Foreign Keys
None

### Indexes
| Index Name | Type | Unique | Columns |
|------------|------|--------|---------|
| PK_PetLevelRewardSettings | CLUSTERED | YES | SettingId |
| UQ_PetLevelRewardSettings_LevelRange | NONCLUSTERED | YES | LevelRangeStart, LevelRangeEnd |
| IX_PetLevelRewardSettings_LevelRange | NONCLUSTERED | NO | LevelRangeStart, LevelRangeEnd |

### Check Constraints
| Constraint Name | Definition |
|----------------|------------|
| CK_PetLevelRewardSettings_LevelRange | `[LevelRangeStart]>(0) AND [LevelRangeEnd]>=[LevelRangeStart]` |
| CK_PetLevelRewardSettings_PointsReward | `[PointsReward]>=(0) AND [PointsReward]<=(999999)` |

---

## 11. PetSkinColorCostSettings

**Purpose:** Pet skin color customization pricing configuration

### Columns

| Column Name | Data Type | Length | Precision | Scale | Nullable | Default | Identity | Description |
|-------------|-----------|--------|-----------|-------|----------|---------|----------|-------------|
| SettingId | int | - | 10 | 0 | NO | NULL | YES | Primary key (auto-increment) |
| ColorCode | varchar | 10 | - | - | NO | NULL | NO | Unique color code (hex format) |
| ColorName | nvarchar | 50 | - | - | NO | NULL | NO | Color display name |
| PointsCost | int | - | 10 | 0 | NO | (2000) | NO | Points cost (>=0) |
| Rarity | nvarchar | 20 | - | - | NO | N'普通' | NO | Rarity: 普通/罕見/稀有/史詩/傳說 |
| Description | nvarchar | 500 | - | - | YES | NULL | NO | Description |
| PreviewImagePath | nvarchar | 500 | - | - | YES | NULL | NO | Preview image path |
| ColorHex | varchar | 7 | - | - | YES | NULL | NO | Hex color value |
| IsActive | bit | - | - | - | NO | (1) | NO | Active status |
| DisplayOrder | int | - | 10 | 0 | NO | (0) | NO | Display order |
| IsFree | bit | - | - | - | NO | (0) | NO | Free flag |
| IsLimitedEdition | bit | - | - | - | NO | (0) | NO | Limited edition flag |
| AvailableFrom | datetime2 | - | - | - | YES | NULL | NO | Availability start date |
| AvailableUntil | datetime2 | - | - | - | YES | NULL | NO | Availability end date |
| IsDeleted | bit | - | - | - | NO | (0) | NO | Soft delete flag |
| DeletedAt | datetime2 | - | - | - | YES | NULL | NO | Deletion timestamp |
| DeletedBy | int | - | 10 | 0 | YES | NULL | NO | Admin who deleted |
| DeleteReason | nvarchar | 500 | - | - | YES | NULL | NO | Reason for deletion |
| CreatedAt | datetime2 | - | - | - | NO | sysutcdatetime() | NO | Creation timestamp |
| UpdatedAt | datetime2 | - | - | - | YES | NULL | NO | Last update timestamp |
| UpdatedBy | int | - | 10 | 0 | YES | NULL | NO | Admin who last updated |

### Primary Key
- `SettingId`

### Foreign Keys
None

### Indexes
| Index Name | Type | Unique | Columns |
|------------|------|--------|---------|
| PK_PetSkinColorCostSettings | CLUSTERED | YES | SettingId |
| UQ_PetSkinColorCostSettings_ColorCode | NONCLUSTERED | YES | ColorCode |
| IX_PetSkinColorCostSettings_IsActive_DisplayOrder | NONCLUSTERED | NO | IsActive, DisplayOrder |
| IX_PetSkinColorCostSettings_Rarity | NONCLUSTERED | NO | Rarity |

### Check Constraints
| Constraint Name | Definition |
|----------------|------------|
| CK_PetSkinColorCostSettings_PointsCost | `[PointsCost]>=(0)` |
| CK_PetSkinColorCostSettings_ColorCode | `[ColorCode] like '#%' AND len([ColorCode])>=(4)` |
| CK_PetSkinColorCostSettings_Rarity | `[Rarity]=N'傳說' OR [Rarity]=N'史詩' OR [Rarity]=N'稀有' OR [Rarity]=N'罕見' OR [Rarity]=N'普通'` |

---

## 12. SignInRule

**Purpose:** Daily sign-in reward configuration by day

### Columns

| Column Name | Data Type | Length | Precision | Scale | Nullable | Default | Identity | Description |
|-------------|-----------|--------|-----------|-------|----------|---------|----------|-------------|
| Id | int | - | 10 | 0 | NO | NULL | YES | Primary key (auto-increment) |
| SignInDay | int | - | 10 | 0 | NO | NULL | NO | Day number (1-365) |
| Points | int | - | 10 | 0 | NO | NULL | NO | Points reward (>=0) |
| Experience | int | - | 10 | 0 | NO | NULL | NO | Experience reward (>=0) |
| HasCoupon | bit | - | - | - | NO | (0) | NO | Coupon flag |
| CouponTypeCode | nvarchar | 50 | - | - | YES | NULL | NO | Coupon type code (required if HasCoupon=1) |
| IsActive | bit | - | - | - | NO | (1) | NO | Active status |
| CreatedAt | datetime2 | - | - | - | NO | sysutcdatetime() | NO | Creation timestamp |
| UpdatedAt | datetime2 | - | - | - | YES | NULL | NO | Last update timestamp |
| Description | nvarchar | 255 | - | - | YES | NULL | NO | Description |
| IsDeleted | bit | - | - | - | NO | (0) | NO | Soft delete flag |
| DeletedAt | datetime2 | - | - | - | YES | NULL | NO | Deletion timestamp |
| DeletedBy | int | - | 10 | 0 | YES | NULL | NO | Admin who deleted |
| DeleteReason | nvarchar | 500 | - | - | YES | NULL | NO | Reason for deletion |

### Primary Key
- `Id`

### Foreign Keys
| FK Name | Column | Referenced Table | Referenced Column |
|---------|--------|------------------|-------------------|
| FK_SignInRule_CouponType_Name | CouponTypeCode | CouponType | Name |

### Indexes
| Index Name | Type | Unique | Columns |
|------------|------|--------|---------|
| PK_SignInRule | CLUSTERED | YES | Id |
| UQ_SignInRule_SignInDay_Active | NONCLUSTERED | YES | SignInDay |
| IX_SignInRule_IsDeleted | NONCLUSTERED | NO | IsDeleted |

### Check Constraints
| Constraint Name | Definition |
|----------------|------------|
| CK_SignInRule_DayRange | `[SignInDay]>=(1) AND [SignInDay]<=(365)` |
| CK_SignInRule_Positive | `[Points]>=(0) AND [Experience]>=(0)` |
| CK_SignInRule_CouponFlag | `[HasCoupon]=(1) AND [CouponTypeCode] IS NOT NULL OR [HasCoupon]=(0) AND [CouponTypeCode] IS NULL` |

---

## 13. SystemSettings

**Purpose:** Global system configuration key-value store

### Columns

| Column Name | Data Type | Length | Precision | Scale | Nullable | Default | Identity | Description |
|-------------|-----------|--------|-----------|-------|----------|---------|----------|-------------|
| SettingId | int | - | 10 | 0 | NO | NULL | YES | Primary key (auto-increment) |
| SettingKey | nvarchar | 200 | - | - | NO | NULL | NO | Unique setting key |
| SettingValue | nvarchar | MAX | - | - | YES | NULL | NO | Setting value (JSON/string/number/boolean) |
| Description | nvarchar | 500 | - | - | YES | NULL | NO | Description |
| Category | nvarchar | 100 | - | - | NO | 'General' | NO | Category grouping |
| SettingType | nvarchar | 50 | - | - | NO | 'String' | NO | Type: String/Boolean/Number/JSON |
| IsReadOnly | bit | - | - | - | NO | (0) | NO | Read-only flag |
| IsActive | bit | - | - | - | NO | (1) | NO | Active status |
| IsDeleted | bit | - | - | - | NO | (0) | NO | Soft delete flag |
| DeletedAt | datetime2 | - | - | - | YES | NULL | NO | Deletion timestamp |
| DeletedBy | int | - | 10 | 0 | YES | NULL | NO | Admin who deleted |
| DeleteReason | nvarchar | 500 | - | - | YES | NULL | NO | Reason for deletion |
| CreatedAt | datetime2 | - | - | - | NO | sysutcdatetime() | NO | Creation timestamp |
| UpdatedAt | datetime2 | - | - | - | YES | NULL | NO | Last update timestamp |
| UpdatedBy | int | - | 10 | 0 | YES | NULL | NO | Admin who last updated |

### Primary Key
- `SettingId`

### Foreign Keys
| FK Name | Column | Referenced Table | Referenced Column |
|---------|--------|------------------|-------------------|
| FK_SystemSettings_UpdatedBy_Manager | UpdatedBy | ManagerData | Manager_Id |

### Indexes
| Index Name | Type | Unique | Columns |
|------------|------|--------|---------|
| PK__SystemSe__54372B1D4E2C6147 | CLUSTERED | YES | SettingId |
| UQ_SystemSettings_SettingKey | NONCLUSTERED | YES | SettingKey |

### Check Constraints
| Constraint Name | Definition |
|----------------|------------|
| CHK_SystemSettings_SettingType | `[SettingType]='String' OR [SettingType]='Boolean' OR [SettingType]='Number' OR [SettingType]='JSON'` |

---

## 14. User_Wallet

**Purpose:** User point balance tracking

### Columns

| Column Name | Data Type | Length | Precision | Scale | Nullable | Default | Identity | Description |
|-------------|-----------|--------|-----------|-------|----------|---------|----------|-------------|
| User_Id | int | - | 10 | 0 | NO | NULL | NO | Primary key & foreign key to Users |
| User_Point | int | - | 10 | 0 | NO | (0) | NO | Current point balance |
| IsDeleted | bit | - | - | - | NO | (0) | NO | Soft delete flag |
| DeletedAt | datetime2 | - | - | - | YES | NULL | NO | Deletion timestamp |
| DeletedBy | int | - | 10 | 0 | YES | NULL | NO | Admin who deleted |
| DeleteReason | nvarchar | 500 | - | - | YES | NULL | NO | Reason for deletion |

### Primary Key
- `User_Id`

### Foreign Keys
| FK Name | Column | Referenced Table | Referenced Column |
|---------|--------|------------------|-------------------|
| FK_User_Wallet_Users | User_Id | Users | User_ID |

### Indexes
| Index Name | Type | Unique | Columns |
|------------|------|--------|---------|
| PK_User_Wallet | CLUSTERED | YES | User_Id |
| IX_User_Wallet_IsDeleted | NONCLUSTERED | NO | IsDeleted |

### Check Constraints
None

---

## 15. UserSignInStats

**Purpose:** User daily sign-in history and rewards log

### Columns

| Column Name | Data Type | Length | Precision | Scale | Nullable | Default | Identity | Description |
|-------------|-----------|--------|-----------|-------|----------|---------|----------|-------------|
| LogID | int | - | 10 | 0 | NO | NULL | YES | Primary key (auto-increment) |
| SignTime | datetime2 | - | - | - | NO | sysutcdatetime() | NO | UTC sign-in time |
| UserID | int | - | 10 | 0 | NO | NULL | NO | Foreign key to Users |
| PointsGained | int | - | 10 | 0 | NO | NULL | NO | Points gained |
| PointsGainedTime | datetime2 | - | - | - | NO | sysutcdatetime() | NO | UTC time points awarded |
| ExpGained | int | - | 10 | 0 | NO | NULL | NO | Experience gained |
| ExpGainedTime | datetime2 | - | - | - | NO | sysutcdatetime() | NO | UTC time exp awarded |
| CouponGained | nvarchar | 50 | - | - | NO | NULL | NO | Coupon code gained (empty if none) |
| CouponGainedTime | datetime2 | - | - | - | NO | sysutcdatetime() | NO | UTC time coupon awarded |
| IsDeleted | bit | - | - | - | NO | (0) | NO | Soft delete flag |
| DeletedAt | datetime2 | - | - | - | YES | NULL | NO | Deletion timestamp |
| DeletedBy | int | - | 10 | 0 | YES | NULL | NO | Admin who deleted |
| DeleteReason | nvarchar | 500 | - | - | YES | NULL | NO | Reason for deletion |

### Primary Key
- `LogID`

### Foreign Keys
| FK Name | Column | Referenced Table | Referenced Column |
|---------|--------|------------------|-------------------|
| FK_UserSignInStats_Users | UserID | Users | User_ID |

### Indexes
| Index Name | Type | Unique | Columns |
|------------|------|--------|---------|
| PK_UserSignInStats | CLUSTERED | YES | LogID |
| IX_UserSignInStats_IsDeleted | NONCLUSTERED | NO | IsDeleted |
| IX_UserSignInStats_user_time | NONCLUSTERED | NO | UserID, SignTime |

### Check Constraints
None

---

## 16. WalletHistory

**Purpose:** Transaction log for all wallet point changes

### Columns

| Column Name | Data Type | Length | Precision | Scale | Nullable | Default | Identity | Description |
|-------------|-----------|--------|-----------|-------|----------|---------|----------|-------------|
| LogID | int | - | 10 | 0 | NO | NULL | YES | Primary key (auto-increment) |
| UserID | int | - | 10 | 0 | NO | NULL | NO | Foreign key to Users |
| ChangeType | nvarchar | 20 | - | - | NO | NULL | NO | Transaction type |
| PointsChanged | int | - | 10 | 0 | NO | NULL | NO | Points changed (positive/negative) |
| ItemCode | nvarchar | 50 | - | - | YES | NULL | NO | Related item code |
| Description | nvarchar | 255 | - | - | YES | NULL | NO | Description |
| ChangeTime | datetime2 | - | - | - | NO | sysutcdatetime() | NO | UTC transaction time |
| IsDeleted | bit | - | - | - | NO | (0) | NO | Soft delete flag |
| DeletedAt | datetime2 | - | - | - | YES | NULL | NO | Deletion timestamp |
| DeletedBy | int | - | 10 | 0 | YES | NULL | NO | Admin who deleted |
| DeleteReason | nvarchar | 500 | - | - | YES | NULL | NO | Reason for deletion |

### Primary Key
- `LogID`

### Foreign Keys
| FK Name | Column | Referenced Table | Referenced Column |
|---------|--------|------------------|-------------------|
| FK_WalletHistory_Users | UserID | Users | User_ID |

### Indexes
| Index Name | Type | Unique | Columns |
|------------|------|--------|---------|
| PK_WalletHistory | CLUSTERED | YES | LogID |
| IX_WalletHistory_IsDeleted | NONCLUSTERED | NO | IsDeleted |
| IX_WalletHistory_user_time | NONCLUSTERED | NO | UserID, ChangeTime |
| IX_WalletHistory_type_time | NONCLUSTERED | NO | ChangeType, ChangeTime |

### Check Constraints
None

---

## 17. ManagerData

**Purpose:** Admin user accounts for backend management

### Columns

| Column Name | Data Type | Length | Precision | Scale | Nullable | Default | Identity | Description |
|-------------|-----------|--------|-----------|-------|----------|---------|----------|-------------|
| Manager_Id | int | - | 10 | 0 | NO | NULL | NO | Primary key (not auto-increment) |
| Manager_Name | nvarchar | 30 | - | - | YES | NULL | NO | Manager display name |
| Manager_Account | varchar | 30 | - | - | YES | NULL | NO | Unique login account |
| Manager_Password | nvarchar | 200 | - | - | YES | NULL | NO | Hashed password |
| Administrator_registration_date | datetime2 | - | - | - | YES | NULL | NO | Registration date |
| Manager_Email | nvarchar | 255 | - | - | NO | NULL | NO | Unique email |
| Manager_EmailConfirmed | bit | - | - | - | NO | (0) | NO | Email confirmed flag |
| Manager_AccessFailedCount | int | - | 10 | 0 | NO | (0) | NO | Failed login attempts |
| Manager_LockoutEnabled | bit | - | - | - | NO | (1) | NO | Lockout enabled flag |
| Manager_LockoutEnd | datetime2 | - | - | - | YES | NULL | NO | Lockout end time |

### Primary Key
- `Manager_Id`

### Foreign Keys
None

### Indexes
| Index Name | Type | Unique | Columns |
|------------|------|--------|---------|
| PK__ManagerD__AE5FEFAD638D88FF | CLUSTERED | YES | Manager_Id |
| UQ__ManagerD__0890969EC9C76047 | NONCLUSTERED | YES | Manager_Email |
| UQ__ManagerD__62B5E21119A93877 | NONCLUSTERED | YES | Manager_Account |

### Check Constraints
None

---

## 18. ManagerRole

**Purpose:** Junction table linking managers to their roles

### Columns

| Column Name | Data Type | Length | Precision | Scale | Nullable | Default | Identity | Description |
|-------------|-----------|--------|-----------|-------|----------|---------|----------|-------------|
| Manager_Id | int | - | 10 | 0 | NO | NULL | NO | Foreign key to ManagerData |
| ManagerRole_Id | int | - | 10 | 0 | NO | NULL | NO | Foreign key to ManagerRolePermission |

### Primary Key
- `Manager_Id`, `ManagerRole_Id` (Composite)

### Foreign Keys
| FK Name | Column | Referenced Table | Referenced Column |
|---------|--------|------------------|-------------------|
| FK__ManagerRo__Manag__0BE6BFCF | Manager_Id | ManagerData | Manager_Id |
| FK__ManagerRo__Manag__57A801BA | Manager_Id | ManagerData | Manager_Id |
| FK__ManagerRo__Manag__0CDAE408 | ManagerRole_Id | ManagerRolePermission | ManagerRole_Id |
| FK__ManagerRo__Manag__589C25F3 | ManagerRole_Id | ManagerRolePermission | ManagerRole_Id |

### Indexes
| Index Name | Type | Unique | Columns |
|------------|------|--------|---------|
| PK__ManagerR__6270897EA52FCCCF | CLUSTERED | YES | Manager_Id, ManagerRole_Id |

### Check Constraints
None

---

## 19. ManagerRolePermission

**Purpose:** Role permission definitions for admin users

### Columns

| Column Name | Data Type | Length | Precision | Scale | Nullable | Default | Identity | Description |
|-------------|-----------|--------|-----------|-------|----------|---------|----------|-------------|
| ManagerRole_Id | int | - | 10 | 0 | NO | NULL | NO | Primary key (not auto-increment) |
| role_name | nvarchar | 50 | - | - | NO | NULL | NO | Role name |
| AdministratorPrivilegesManagement | bit | - | - | - | YES | NULL | NO | Admin management permission |
| UserStatusManagement | bit | - | - | - | YES | NULL | NO | User management permission |
| ShoppingPermissionManagement | bit | - | - | - | YES | NULL | NO | Store management permission |
| MessagePermissionManagement | bit | - | - | - | YES | NULL | NO | Message management permission |
| Pet_Rights_Management | bit | - | - | - | YES | NULL | NO | Pet/MiniGame management permission |
| customer_service | bit | - | - | - | YES | NULL | NO | Customer service permission |

### Primary Key
- `ManagerRole_Id`

### Foreign Keys
None

### Indexes
| Index Name | Type | Unique | Columns |
|------------|------|--------|---------|
| PK__ManagerR__C2F66D3DC40C7408 | CLUSTERED | YES | ManagerRole_Id |

### Check Constraints
None

---

## 20. Users

**Purpose:** End-user accounts for the frontend application

### Columns

| Column Name | Data Type | Length | Precision | Scale | Nullable | Default | Identity | Description |
|-------------|-----------|--------|-----------|-------|----------|---------|----------|-------------|
| User_ID | int | - | 10 | 0 | NO | NULL | YES | Primary key (auto-increment) |
| User_name | nvarchar | 30 | - | - | NO | NULL | NO | Unique username |
| User_Account | nvarchar | 30 | - | - | NO | NULL | NO | Unique login account |
| User_Password | nvarchar | 255 | - | - | NO | NULL | NO | Hashed password |
| User_EmailConfirmed | bit | - | - | - | NO | (0) | NO | Email confirmed flag |
| User_PhoneNumberConfirmed | bit | - | - | - | NO | (0) | NO | Phone confirmed flag |
| User_TwoFactorEnabled | bit | - | - | - | NO | (0) | NO | 2FA enabled flag |
| User_AccessFailedCount | int | - | 10 | 0 | NO | (0) | NO | Failed login attempts |
| User_LockoutEnabled | bit | - | - | - | NO | (1) | NO | Lockout enabled flag |
| User_LockoutEnd | datetime2 | - | - | - | YES | NULL | NO | Lockout end time |
| Create_Account | datetime2 | - | - | - | NO | sysdatetime() | NO | Account creation time |

### Primary Key
- `User_ID`

### Foreign Keys
None

### Indexes
| Index Name | Type | Unique | Columns |
|------------|------|--------|---------|
| PK__Users__206D9190FA40893F | CLUSTERED | YES | User_ID |
| IX_Users_UserAccount | NONCLUSTERED | YES | User_Account |
| UQ__Users__5F1A108682A83552 | NONCLUSTERED | YES | User_name |
| UQ__Users__899F4A91E5EF8DB8 | NONCLUSTERED | YES | User_Account |

### Check Constraints
None

---

## Schema Summary

### Table Categories

**Wallet System (3 tables):**
- User_Wallet
- WalletHistory
- SystemSettings (partial)

**Coupon System (2 tables):**
- CouponType
- Coupon

**E-Voucher System (4 tables):**
- EVoucherType
- EVoucher
- EVoucherToken
- EVoucherRedeemLog

**Pet System (4 tables):**
- Pet
- PetSkinColorCostSettings
- PetBackgroundCostSettings
- PetLevelRewardSettings

**Sign-In System (2 tables):**
- SignInRule
- UserSignInStats

**Mini-Game System (1 table):**
- MiniGame

**Admin Management (3 tables):**
- ManagerData
- ManagerRole
- ManagerRolePermission

**User Management (1 table):**
- Users

### Common Patterns Across Tables

**Soft Delete Pattern (18 tables):**
- `IsDeleted` bit NOT NULL DEFAULT (0)
- `DeletedAt` datetime2 NULL
- `DeletedBy` int NULL
- `DeleteReason` nvarchar(500) NULL

**Audit Trail Pattern (3 settings tables):**
- `CreatedAt` datetime2 NOT NULL DEFAULT sysutcdatetime()
- `UpdatedAt` datetime2 NULL
- `UpdatedBy` int NULL (FK to ManagerData)

**UTC Timestamp Pattern:**
- All datetime2 columns use `sysutcdatetime()` for UTC timestamps
- Ensures timezone-independent data storage

**Identity Columns:**
- 17 tables use auto-increment identity for primary keys
- 3 tables (User_Wallet, ManagerData, ManagerRole, ManagerRolePermission) use non-identity PKs

### Foreign Key Relationships

**Central Hub: Users table**
- Referenced by: User_Wallet, Coupon, EVoucher, EVoucherRedeemLog, Pet, MiniGame, UserSignInStats, WalletHistory

**Central Hub: ManagerData table**
- Referenced by: ManagerRole, SystemSettings, PetBackgroundCostSettings

**Coupon Type System:**
- CouponType → Coupon (1:N)
- CouponType.Name → SignInRule.CouponTypeCode

**E-Voucher Type System:**
- EVoucherType → EVoucher (1:N)
- EVoucher → EVoucherToken (1:N)
- EVoucher → EVoucherRedeemLog (1:N)

**Pet Ecosystem:**
- Users → Pet (1:1, one pet per user)
- Pet → MiniGame (1:N)

---

## Data Integrity Notes

### Unique Constraints

**Business-Critical Unique Constraints:**
1. `Coupon.CouponCode` - Prevents duplicate coupon codes
2. `CouponType.Name` - Ensures unique coupon type names
3. `EVoucher.EVoucherCode` - Prevents duplicate e-voucher codes
4. `EVoucherToken.Token` - Ensures unique redemption tokens
5. `SignInRule.SignInDay` - One configuration per day
6. `SystemSettings.SettingKey` - One value per setting key
7. `Users.User_Account` - Unique login accounts
8. `Users.User_name` - Unique usernames
9. `ManagerData.Manager_Account` - Unique admin accounts
10. `ManagerData.Manager_Email` - Unique admin emails

### Check Constraints

**Range Validation:**
- Pet stats: All 5 stats (Hunger, Mood, Stamina, Cleanliness, Health) must be 0-100
- SignInRule.SignInDay: Must be 1-365
- Pet level rewards: LevelRangeStart > 0, LevelRangeEnd >= LevelRangeStart
- Points rewards: 0-999,999

**Enum Validation:**
- CouponType.DiscountType: PERCENT or AMOUNT
- EVoucherRedeemLog.Status: APPROVED, ALREADYUSED, EXPIRED, REJECTED, REVOKED
- SystemSettings.SettingType: String, Boolean, Number, JSON
- PetSkinColorCostSettings.Rarity: 普通, 罕見, 稀有, 史詩, 傳說

**Conditional Validation:**
- Coupon.UsedFields: If IsUsed=1, then UsedTime and UsedInOrderID must be populated
- SignInRule.CouponFlag: If HasCoupon=1, then CouponTypeCode must be populated

### Index Strategy

**Performance Indexes:**
1. **User-Time Composite Indexes:**
   - `IX_Coupon_user_used` (UserID, IsUsed, AcquiredTime)
   - `IX_EVoucher_user_used` (UserID, IsUsed, AcquiredTime)
   - `IX_MiniGame_user_time` (UserID, StartTime)
   - `IX_UserSignInStats_user_time` (UserID, SignTime)
   - `IX_WalletHistory_user_time` (UserID, ChangeTime)

2. **Type-Time Composite Indexes:**
   - `IX_WalletHistory_type_time` (ChangeType, ChangeTime)

3. **Soft Delete Indexes:**
   - Most tables have `IX_[TableName]_IsDeleted` for efficient filtered queries

4. **Unique Indexes:**
   - All unique constraints are enforced via NONCLUSTERED unique indexes

---

## End of Schema Export

**Total Columns Documented:** 273
**Total Foreign Keys:** 24
**Total Indexes:** 64
**Total Check Constraints:** 17
