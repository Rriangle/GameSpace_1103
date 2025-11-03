# MiniGame Area Database Schema - Complete Reference
*Generated: 2025-11-03 (Updated) | Focus: 20 Core Tables | SQL Server 2022*

## 🔧 配置系統架構 (2025-11-03 更新)

### SystemSettings 配置中心

**重要：** MiniGame Area 現採用 SystemSettings 表作為核心配置中心。

**配置統計：**
- **總配置項：** 56 個
- **業務規則：** 36 個（簽到 9 + 寵物 13 + 遊戲 14）
- **管理方式：** 後台 UI 動態修改
- **服務：** SystemSettingsService（Singleton、快取 30 分鐘）

**四大子系統配置：**

| 子系統 | 配置表 | SystemSettings Keys | 說明 |
|--------|-------|---------------------|------|
| 簽到系統 | SignInRule (10 行) | 9 個 | 平日/假日/連續/全勤獎勵 |
| 寵物系統 | PetLevel/Skin/Background (47 行) | 13 個 | 互動效果、每日衰減、升級公式 |
| 遊戲系統 | - | 14 個 | 關卡設定、結果影響 |
| 錢包系統 | - | 4 個 | 初始點數、上限、優惠券/禮券有效期 |

**架構圖：**
```
                    SystemSettings (配置中心)
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
  SignInService      GamePlayService    PetInteractionService
        │                   │                   │
  SignInRule          MiniGame               Pet
  (結構化配置)         (運行數據)            (運行數據)
```

**配置優先級：**
1. SystemSettings 表（動態配置，後台可調）
2. 配置表（SignInRule 等，靜態結構化配置）
3. 代碼默認值（Fallback，僅在讀取失敗時使用）

---

## Overview
The MiniGame Area comprises 4 subsystems spanning 20 database tables:
- **Wallet System:** User_Wallet, WalletHistory, CouponType, Coupon, EVoucherType, EVoucher, EVoucherToken, EVoucherRedeemLog (8 tables)
- **Sign-In System:** SignInRule, UserSignInStats (2 tables)
- **Pet System:** Pet, PetSkinColorCostSettings, PetBackgroundCostSettings, PetLevelRewardSettings (4 tables)
- **Mini-Game System:** MiniGame (1 table)
- **Core Infrastructure:** SystemSettings, Users, ManagerData, ManagerRole, ManagerRolePermission (5 tables)

---

## Quick Reference Matrix

| Table | Rows | PK | FKs | UKs | Checks | Identity | SoftDel |
|-------|------|----|-----|-----|--------|----------|---------|
| User_Wallet | 200 | User_Id | 1 | 0 | 0 | NO | YES |
| WalletHistory | 1928 | LogID | 1 | 0 | 0 | YES | YES |
| CouponType | 3 | CouponTypeID | 0 | 1 | 3 | YES | YES |
| Coupon | 4587 | CouponID | 2 | 1 | 2 | YES | YES |
| EVoucherType | 20 | EVoucherTypeID | 0 | 0 | 0 | YES | YES |
| EVoucher | 355 | EVoucherID | 2 | 1 | 0 | YES | YES |
| EVoucherToken | 355 | TokenID | 1 | 1 | 0 | YES | YES |
| EVoucherRedeemLog | 800 | RedeemID | 3 | 0 | 1 | YES | YES |
| SignInRule | 10 | Id | 1 | 1 | 3 | YES | YES |
| UserSignInStats | 2400 | LogID | 1 | 0 | 0 | YES | YES |
| Pet | 200 | PetID | 1 | 0 | 5 | YES | YES |
| PetSkinColorCostSettings | 11 | SettingId | 0 | 1 | 3 | YES | YES |
| PetBackgroundCostSettings | 11 | SettingId | 1 | 1 | 1 | YES | YES |
| PetLevelRewardSettings | 25 | SettingId | 0 | 1 | 2 | YES | YES |
| MiniGame | 2000 | PlayID | 2 | 0 | 0 | YES | YES |
| SystemSettings | 56 | SettingId | 1 | 1 | 1 | YES | YES |
| Users | 200 | User_ID | 0 | 2 | 0 | YES | NO |
| ManagerData | 102 | Manager_Id | 0 | 2 | 0 | NO | NO |
| ManagerRole | 102 | Manager_Id,ManagerRole_Id | 2 | 0 | 0 | NO | NO |
| ManagerRolePermission | 8 | ManagerRole_Id | 0 | 0 | 0 | NO | NO |

---

## Detailed Table Schemas

### 1. User_Wallet (200 rows)
**Purpose:** Stores user point balance for game rewards, purchases, sign-ins

**Schema:**
```sql
CREATE TABLE User_Wallet (
    User_Id int NOT NULL PRIMARY KEY,           -- FK → Users.User_ID
    User_Point int NOT NULL DEFAULT 0,          -- Current point balance (non-negative)
    IsDeleted bit NOT NULL DEFAULT 0,
    DeletedAt datetime2(7) NULL,
    DeletedBy int NULL,
    DeleteReason nvarchar(500) NULL
);
```

**Columns:**
| Column | Type | Null | Default | Description |
|--------|------|------|---------|-------------|
| User_Id | int | NO | - | Primary key, references Users table |
| User_Point | int | NO | 0 | Current point balance (non-negative) |
| IsDeleted | bit | NO | 0 | Soft delete flag |
| DeletedAt | datetime2(7) | YES | NULL | Soft delete timestamp (UTC) |
| DeletedBy | int | YES | NULL | Manager ID who deleted |
| DeleteReason | nvarchar(500) | YES | NULL | Reason for deletion |

**Keys & Constraints:**
- **PK:** User_Id (CLUSTERED)
- **FK:** User_Id → Users.User_ID (NO_ACTION)
- **UK:** None
- **Indexes:**
  - PK_User_Wallet (CLUSTERED): User_Id
  - IX_User_Wallet_IsDeleted (NONCLUSTERED): IsDeleted

**Sample Data (Top 5):**
```
User_Id|User_Point|IsDeleted|DeletedAt|DeletedBy|DeleteReason
10000001|60030|0|NULL|NULL|NULL
10000002|21666|0|NULL|NULL|NULL
10000003|93043|0|NULL|NULL|NULL
10000004|52743|0|NULL|NULL|NULL
10000005|37320|0|NULL|NULL|NULL
```

**Business Rules:**
- Points can only be modified through WalletHistory transactions
- Cannot go negative (enforced by application layer)
- Soft delete preserves audit trail
- One wallet per user (1:1 relationship with Users)

---

### 2. WalletHistory (1928 rows)
**Purpose:** Transaction log for all point changes (audit trail)

**Schema:**
```sql
CREATE TABLE WalletHistory (
    LogID int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    UserID int NOT NULL,                         -- FK → Users.User_ID
    ChangeType nvarchar(20) NOT NULL,            -- 'Point', 'Coupon', 'EVoucher'
    PointsChanged int NOT NULL,                  -- Can be negative (deduction)
    ItemCode nvarchar(50) NULL,                  -- Coupon/EVoucher code
    Description nvarchar(255) NULL,
    ChangeTime datetime2(7) NOT NULL DEFAULT sysutcdatetime(),
    IsDeleted bit NOT NULL DEFAULT 0,
    DeletedAt datetime2(7) NULL,
    DeletedBy int NULL,
    DeleteReason nvarchar(500) NULL
);
```

**Columns:**
| Column | Type | Null | Default | Description |
|--------|------|------|---------|-------------|
| LogID | int | NO | IDENTITY | Primary key, auto-increment |
| UserID | int | NO | - | References Users.User_ID |
| ChangeType | nvarchar(20) | NO | - | Transaction type: Point, Coupon, EVoucher |
| PointsChanged | int | NO | - | Point delta (can be negative) |
| ItemCode | nvarchar(50) | YES | NULL | Associated coupon/voucher code |
| Description | nvarchar(255) | YES | NULL | Transaction description |
| ChangeTime | datetime2(7) | NO | sysutcdatetime() | UTC timestamp of transaction |
| IsDeleted | bit | NO | 0 | Soft delete flag |
| DeletedAt | datetime2(7) | YES | NULL | Soft delete timestamp |
| DeletedBy | int | YES | NULL | Manager who deleted |
| DeleteReason | nvarchar(500) | YES | NULL | Deletion reason |

**Keys & Constraints:**
- **PK:** LogID (CLUSTERED, IDENTITY)
- **FK:** UserID → Users.User_ID (NO_ACTION)
- **UK:** None
- **Indexes:**
  - PK_WalletHistory (CLUSTERED): LogID
  - IX_WalletHistory_IsDeleted (NONCLUSTERED): IsDeleted
  - IX_WalletHistory_type_time (NONCLUSTERED): ChangeType, ChangeTime
  - IX_WalletHistory_user_time (NONCLUSTERED): UserID, ChangeTime

**Sample Data (Top 5):**
```
LogID|UserID|ChangeType|PointsChanged|ItemCode|Description|ChangeTime
1|10000001|Coupon|0|CPN-2301-HRT805|小遊戲優惠券獲得優惠券|2023-12-08 03:34:50.0000000
2|10000001|Point|-10000|CPN-2310-NCW491|扣除點數兌換優惠券|2023-10-06 18:52:28.0000000
3|10000001|Point|-30000|EV-MOVIE-8JDW-064877|扣除點數兌換電子禮券|2024-10-29 15:17:44.0000000
4|10000001|Coupon|0|CPN-2301-HRT805|活動發送優惠券|2025-09-06 18:34:01.4389762
5|10000001|Coupon|0|CPN-2301-HRT805|每日簽到獲得優惠券|2025-08-24 07:26:36.0000000
```

**Business Rules:**
- Immutable after creation (soft delete only)
- Used for audit trail and point balance reconciliation
- ChangeType must match ItemCode pattern (if present)
- PointsChanged can be negative (deductions) or positive (additions)

---

### 3. CouponType (3 rows)
**Purpose:** Defines reusable coupon templates with discount rules

**Schema:**
```sql
CREATE TABLE CouponType (
    CouponTypeID int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Name nvarchar(50) NOT NULL,                  -- UNIQUE
    DiscountType nvarchar(20) NOT NULL,          -- 'PERCENT' or 'AMOUNT'
    DiscountValue decimal(18,2) NULL,            -- Percentage (0.15) or Amount (50.00)
    MinSpend decimal(18,2) NULL,                 -- Minimum order amount
    ValidFrom datetime2(7) NOT NULL,
    ValidTo datetime2(7) NOT NULL,
    PointsCost int NOT NULL,                     -- Points required to redeem
    Description nvarchar(600) NULL,
    IsDeleted bit NOT NULL DEFAULT 0,
    DeletedAt datetime2(7) NULL,
    DeletedBy int NULL,
    DeleteReason nvarchar(500) NULL
);
```

**Columns:**
| Column | Type | Null | Default | Description |
|--------|------|------|---------|-------------|
| CouponTypeID | int | NO | IDENTITY | Primary key |
| Name | nvarchar(50) | NO | - | Coupon type name (UNIQUE) |
| DiscountType | nvarchar(20) | NO | - | 'PERCENT' or 'AMOUNT' |
| DiscountValue | decimal(18,2) | YES | NULL | Discount value (percentage or amount) |
| MinSpend | decimal(18,2) | YES | NULL | Minimum order amount to use |
| ValidFrom | datetime2(7) | NO | - | Start of validity period |
| ValidTo | datetime2(7) | NO | - | End of validity period |
| PointsCost | int | NO | - | Points required to redeem |
| Description | nvarchar(600) | YES | NULL | Coupon description |
| IsDeleted | bit | NO | 0 | Soft delete flag |
| DeletedAt | datetime2(7) | YES | NULL | Soft delete timestamp |
| DeletedBy | int | YES | NULL | Manager who deleted |
| DeleteReason | nvarchar(500) | YES | NULL | Deletion reason |

**Keys & Constraints:**
- **PK:** CouponTypeID (CLUSTERED, IDENTITY)
- **FK:** None
- **UK:** UQ_CouponType_Name (Name)
- **Indexes:**
  - PK_CouponType (CLUSTERED): CouponTypeID
  - UQ_CouponType_Name (NONCLUSTERED): Name
  - IX_CouponType_IsDeleted (NONCLUSTERED): IsDeleted
- **Check Constraints:**
  - CK_CouponType_DiscountType: DiscountType IN ('PERCENT', 'AMOUNT')
  - CK_CouponType_ValidRange: ValidFrom <= ValidTo

**Sample Data (Top 3):**
```
CouponTypeID|Name|DiscountType|DiscountValue|MinSpend|ValidFrom|ValidTo|PointsCost|Description
1|免運券|Amount|NULL|NULL|2023-10-26 02:09:44|2026-06-30 23:59:59|10000|台幣優惠券專屬
2|全站85折|Percent|.15|1500.00|2023-01-25 14:06:52|2026-06-30 23:59:59|1000|台幣優惠券專屬
3|滿$500折$50|Amount|50.00|500.00|2024-11-13 10:37:53|2026-06-30 23:59:59|5000|台幣優惠券專屬
```

**Business Rules:**
- Name must be unique across all coupon types
- DiscountType determines interpretation of DiscountValue
- ValidFrom must be <= ValidTo
- Used as template to generate Coupon instances

---

### 4. Coupon (4587 rows)
**Purpose:** Individual coupon instances owned by users

**Schema:**
```sql
CREATE TABLE Coupon (
    CouponID int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    CouponCode nvarchar(50) NOT NULL,            -- UNIQUE, format: CPN-YYMM-XXXXXX
    CouponTypeID int NOT NULL,                   -- FK → CouponType.CouponTypeID
    UserID int NOT NULL,                         -- FK → Users.User_ID
    IsUsed bit NOT NULL,                         -- 0 or 1
    AcquiredTime datetime2(7) NOT NULL DEFAULT sysutcdatetime(),
    UsedTime datetime2(7) NULL DEFAULT sysutcdatetime(),
    UsedInOrderID int NULL,
    IsDeleted bit NOT NULL DEFAULT 0,
    DeletedAt datetime2(7) NULL,
    DeletedBy int NULL,
    DeleteReason nvarchar(500) NULL
);
```

**Columns:**
| Column | Type | Null | Default | Description |
|--------|------|------|---------|-------------|
| CouponID | int | NO | IDENTITY | Primary key |
| CouponCode | nvarchar(50) | NO | - | Unique coupon code (CPN-YYMM-XXXXXX) |
| CouponTypeID | int | NO | - | References CouponType |
| UserID | int | NO | - | Owner user ID |
| IsUsed | bit | NO | - | 0=unused, 1=used |
| AcquiredTime | datetime2(7) | NO | sysutcdatetime() | When user acquired coupon |
| UsedTime | datetime2(7) | YES | sysutcdatetime() | When coupon was used (NULL if unused) |
| UsedInOrderID | int | YES | NULL | Order ID where coupon was used |
| IsDeleted | bit | NO | 0 | Soft delete flag |
| DeletedAt | datetime2(7) | YES | NULL | Soft delete timestamp |
| DeletedBy | int | YES | NULL | Manager who deleted |
| DeleteReason | nvarchar(500) | YES | NULL | Deletion reason |

**Keys & Constraints:**
- **PK:** CouponID (CLUSTERED, IDENTITY)
- **FK:**
  - CouponTypeID → CouponType.CouponTypeID (NO_ACTION)
  - UserID → Users.User_ID (NO_ACTION)
- **UK:** UQ_Coupon_CouponCode (CouponCode)
- **Indexes:**
  - PK_Coupon (CLUSTERED): CouponID
  - UQ_Coupon_CouponCode (NONCLUSTERED): CouponCode
  - IX_Coupon_IsDeleted (NONCLUSTERED): IsDeleted
  - IX_Coupon_user_used (NONCLUSTERED): UserID, IsUsed, AcquiredTime
- **Check Constraints:**
  - CK_Coupon_IsUsed: IsUsed IN (0, 1)
  - CK_Coupon_UsedFields: (IsUsed=0 AND UsedTime IS NULL AND UsedInOrderID IS NULL) OR (IsUsed=1 AND UsedTime IS NOT NULL AND UsedInOrderID IS NOT NULL)

**Sample Data (Top 5):**
```
CouponID|CouponCode|CouponTypeID|UserID|IsUsed|AcquiredTime|UsedTime|UsedInOrderID
1|CPN-2310-NCW491|1|10000148|0|2023-10-06 18:52:28|NULL|NULL
5|CPN-2302-MRH896|1|10000013|0|2023-02-04 07:25:30|NULL|NULL
18|CPN-2410-YYW366|3|10000178|0|2024-10-22 11:32:12|NULL|NULL
20|CPN-2501-MTQ878|3|10000079|0|2025-01-25 05:16:18|NULL|NULL
39|CPN-2410-AUK161|2|10000001|0|2024-10-19 23:07:46|NULL|NULL
```

**Business Rules:**
- CouponCode must be unique across all coupons
- Once IsUsed=1, must have UsedTime and UsedInOrderID
- Cannot be "un-used" after being used
- Inherits validity period from CouponType

---

### 5. EVoucherType (20 rows)
**Purpose:** Defines reusable e-voucher templates (gift cards, store credits)

**Schema:**
```sql
CREATE TABLE EVoucherType (
    EVoucherTypeID int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Name nvarchar(50) NOT NULL,
    ValueAmount decimal(18,2) NOT NULL,          -- Face value in currency
    ValidFrom datetime2(7) NOT NULL,
    ValidTo datetime2(7) NOT NULL,
    PointsCost int NOT NULL,                     -- Points to redeem
    TotalAvailable int NOT NULL,                 -- Inventory control
    Description nvarchar(600) NULL,
    IsDeleted bit NOT NULL DEFAULT 0,
    DeletedAt datetime2(7) NULL,
    DeletedBy int NULL,
    DeleteReason nvarchar(500) NULL
);
```

**Columns:**
| Column | Type | Null | Default | Description |
|--------|------|------|---------|-------------|
| EVoucherTypeID | int | NO | IDENTITY | Primary key |
| Name | nvarchar(50) | NO | - | E-voucher type name |
| ValueAmount | decimal(18,2) | NO | - | Face value (e.g., $100) |
| ValidFrom | datetime2(7) | NO | - | Start of validity |
| ValidTo | datetime2(7) | NO | - | End of validity |
| PointsCost | int | NO | - | Points required to redeem |
| TotalAvailable | int | NO | - | Total inventory available |
| Description | nvarchar(600) | YES | NULL | Description |
| IsDeleted | bit | NO | 0 | Soft delete flag |
| DeletedAt | datetime2(7) | YES | NULL | Soft delete timestamp |
| DeletedBy | int | YES | NULL | Manager who deleted |
| DeleteReason | nvarchar(500) | YES | NULL | Deletion reason |

**Keys & Constraints:**
- **PK:** EVoucherTypeID (CLUSTERED, IDENTITY)
- **FK:** None
- **UK:** None
- **Indexes:**
  - PK_EVoucherType (CLUSTERED): EVoucherTypeID
  - IX_EVoucherType_IsDeleted (NONCLUSTERED): IsDeleted

**Sample Data (Top 5):**
```
EVoucherTypeID|Name|ValueAmount|ValidFrom|ValidTo|PointsCost|TotalAvailable|Description
1|7-11禮券$100|100.00|2024-07-24 08:01:15|9999-12-31 06:10:00|10000|468|無使用期限
2|7-11禮券$200|200.00|2025-01-08 20:24:24|9999-12-31 06:10:00|20000|437|無使用期限
3|電影禮券$100|100.00|2024-03-05 01:55:47|9999-12-31 06:10:00|10000|194|無使用期限
4|電影禮券$200|200.00|2024-03-30 16:44:49|9999-12-31 06:10:00|20000|438|無使用期限
5|7-11特殊限定美式商品券|65.00|2024-05-06 09:52:59|9999-12-31 06:10:00|6500|433|無使用期限/不可退換
```

**Business Rules:**
- TotalAvailable decrements when users redeem
- Used as template for EVoucher instances
- ValueAmount is face value in currency (not points)

---

### 6. EVoucher (355 rows)
**Purpose:** Individual e-voucher instances owned by users

**Schema:**
```sql
CREATE TABLE EVoucher (
    EVoucherID int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    EVoucherCode nvarchar(50) NOT NULL,          -- UNIQUE, format: EV-XXXX-XXXX-XXXXXX
    EVoucherTypeID int NOT NULL,                 -- FK → EVoucherType.EVoucherTypeID
    UserID int NOT NULL,                         -- FK → Users.User_ID
    IsUsed bit NOT NULL,
    AcquiredTime datetime2(7) NOT NULL DEFAULT sysutcdatetime(),
    UsedTime datetime2(7) NULL DEFAULT sysutcdatetime(),
    IsDeleted bit NOT NULL DEFAULT 0,
    DeletedAt datetime2(7) NULL,
    DeletedBy int NULL,
    DeleteReason nvarchar(500) NULL
);
```

**Columns:**
| Column | Type | Null | Default | Description |
|--------|------|------|---------|-------------|
| EVoucherID | int | NO | IDENTITY | Primary key |
| EVoucherCode | nvarchar(50) | NO | - | Unique voucher code (EV-XXXX-XXXX-XXXXXX) |
| EVoucherTypeID | int | NO | - | References EVoucherType |
| UserID | int | NO | - | Owner user ID |
| IsUsed | bit | NO | - | 0=unused, 1=used |
| AcquiredTime | datetime2(7) | NO | sysutcdatetime() | When user acquired voucher |
| UsedTime | datetime2(7) | YES | sysutcdatetime() | When voucher was redeemed (NULL if unused) |
| IsDeleted | bit | NO | 0 | Soft delete flag |
| DeletedAt | datetime2(7) | YES | NULL | Soft delete timestamp |
| DeletedBy | int | YES | NULL | Manager who deleted |
| DeleteReason | nvarchar(500) | YES | NULL | Deletion reason |

**Keys & Constraints:**
- **PK:** EVoucherID (CLUSTERED, IDENTITY)
- **FK:**
  - EVoucherTypeID → EVoucherType.EVoucherTypeID (NO_ACTION)
  - UserID → Users.User_ID (NO_ACTION)
- **UK:** UQ_EVoucher_EVoucherCode (EVoucherCode)
- **Indexes:**
  - PK_EVoucher (CLUSTERED): EVoucherID
  - UQ_EVoucher_EVoucherCode (NONCLUSTERED): EVoucherCode
  - IX_EVoucher_IsDeleted (NONCLUSTERED): IsDeleted
  - IX_EVoucher_user_used (NONCLUSTERED): UserID, IsUsed, AcquiredTime

**Sample Data (Top 5):**
```
EVoucherID|EVoucherCode|EVoucherTypeID|UserID|IsUsed|AcquiredTime|UsedTime
1|EV-MOVIE-8JDW-064877|3|10000001|1|2024-10-29 15:17:44|2025-05-30 23:53:14
2|EV-CASH-VR2G-969669|12|10000001|0|2025-01-14 07:58:55|NULL
3|EV-STORE-BNXR-252844|4|10000001|0|2024-11-18 08:13:38|NULL
4|EV-CASH-G7HA-253496|15|10000002|1|2023-08-07 16:08:59|2023-11-24 09:25:43
5|EV-CASH-JE6Z-035950|5|10000003|0|2024-05-20 17:31:58|NULL
```

**Business Rules:**
- EVoucherCode must be unique
- Can be redeemed at physical locations (via EVoucherToken)
- Inherits value and validity from EVoucherType

---

### 7. EVoucherToken (355 rows)
**Purpose:** Temporary tokens for e-voucher redemption (QR codes, scan codes)

**Schema:**
```sql
CREATE TABLE EVoucherToken (
    TokenID int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    EVoucherID int NOT NULL,                     -- FK → EVoucher.EVoucherID
    Token varchar(64) NOT NULL,                  -- UNIQUE, format: TKN-XXXXXXXX-XXXX
    ExpiresAt datetime2(7) NOT NULL,             -- Token expiration (short-lived)
    IsRevoked bit NOT NULL,                      -- Can be revoked by admin
    IsDeleted bit NOT NULL DEFAULT 0,
    DeletedAt datetime2(7) NULL,
    DeletedBy int NULL,
    DeleteReason nvarchar(500) NULL
);
```

**Columns:**
| Column | Type | Null | Default | Description |
|--------|------|------|---------|-------------|
| TokenID | int | NO | IDENTITY | Primary key |
| EVoucherID | int | NO | - | References EVoucher |
| Token | varchar(64) | NO | - | UNIQUE token string (TKN-XXXXXXXX-XXXX) |
| ExpiresAt | datetime2(7) | NO | - | Token expiration time (short-lived) |
| IsRevoked | bit | NO | - | Admin can revoke token |
| IsDeleted | bit | NO | 0 | Soft delete flag |
| DeletedAt | datetime2(7) | YES | NULL | Soft delete timestamp |
| DeletedBy | int | YES | NULL | Manager who deleted |
| DeleteReason | nvarchar(500) | YES | NULL | Deletion reason |

**Keys & Constraints:**
- **PK:** TokenID (CLUSTERED, IDENTITY)
- **FK:** EVoucherID → EVoucher.EVoucherID (NO_ACTION)
- **UK:** UQ_EVoucherToken_Token (Token)
- **Indexes:**
  - PK_EVoucherToken (CLUSTERED): TokenID
  - UQ_EVoucherToken_Token (NONCLUSTERED): Token
  - IX_EVoucherToken_IsDeleted (NONCLUSTERED): IsDeleted

**Sample Data (Top 5):**
```
TokenID|EVoucherID|Token|ExpiresAt|IsRevoked
1|1|TKN-GFWZIUGU-7603|2024-12-09 15:17:44|0
2|2|TKN-0AFNJ3IW-7410|2025-04-08 07:58:55|0
3|3|TKN-QBHYOJ30-9972|2025-08-05 09:01:17|0
4|4|TKN-L62G3NV4-9235|2025-05-21 15:30:47|1
5|5|TKN-86JLK23E-7006|2024-08-03 17:31:58|0
```

**Business Rules:**
- Tokens are short-lived (typically minutes to hours)
- Used for QR code redemption at physical locations
- Can be revoked by admin if suspicious activity detected
- One-time use (tracked in EVoucherRedeemLog)

---

### 8. EVoucherRedeemLog (800 rows)
**Purpose:** Audit log for e-voucher redemption attempts

**Schema:**
```sql
CREATE TABLE EVoucherRedeemLog (
    RedeemID int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    EVoucherID int NOT NULL,                     -- FK → EVoucher.EVoucherID
    TokenID int NULL,                            -- FK → EVoucherToken.TokenID
    UserID int NOT NULL,                         -- FK → Users.User_ID
    ScannedAt datetime2(7) NOT NULL DEFAULT sysutcdatetime(),
    Status nvarchar(20) NOT NULL,                -- 'Approved', 'Rejected', 'Revoked', 'Expired', 'AlreadyUsed'
    IsDeleted bit NOT NULL DEFAULT 0,
    DeletedAt datetime2(7) NULL,
    DeletedBy int NULL,
    DeleteReason nvarchar(500) NULL
);
```

**Columns:**
| Column | Type | Null | Default | Description |
|--------|------|------|---------|-------------|
| RedeemID | int | NO | IDENTITY | Primary key |
| EVoucherID | int | NO | - | References EVoucher |
| TokenID | int | YES | NULL | References EVoucherToken (if token used) |
| UserID | int | NO | - | User attempting redemption |
| ScannedAt | datetime2(7) | NO | sysutcdatetime() | Redemption attempt timestamp |
| Status | nvarchar(20) | NO | - | Redemption status |
| IsDeleted | bit | NO | 0 | Soft delete flag |
| DeletedAt | datetime2(7) | YES | NULL | Soft delete timestamp |
| DeletedBy | int | YES | NULL | Manager who deleted |
| DeleteReason | nvarchar(500) | YES | NULL | Deletion reason |

**Keys & Constraints:**
- **PK:** RedeemID (CLUSTERED, IDENTITY)
- **FK:**
  - EVoucherID → EVoucher.EVoucherID (CASCADE)
  - TokenID → EVoucherToken.TokenID (NO_ACTION)
  - UserID → Users.User_ID (NO_ACTION)
- **UK:** None
- **Indexes:**
  - PK_EVoucherRedeemLog (CLUSTERED): RedeemID
  - IX_EVoucherRedeemLog_IsDeleted (NONCLUSTERED): IsDeleted
  - IX_EVoucherRedeemLog_voucher_user (NONCLUSTERED): EVoucherID, UserID, ScannedAt
- **Check Constraints:**
  - CK_EVoucherRedeemLog_Status: Status IN ('Approved', 'Rejected', 'Revoked', 'Expired', 'AlreadyUsed')

**Sample Data (Top 5):**
```
RedeemID|EVoucherID|TokenID|UserID|ScannedAt|Status
1|1|1|10000042|2025-05-30 23:53:14|Approved
2|1|1|10000030|2025-01-28 16:20:55|AlreadyUsed
3|2|2|10000185|2024-06-07 03:53:06|Revoked
4|4|4|10000073|2024-08-13 14:38:26|Approved
5|5|5|10000056|2024-05-23 11:32:50|Rejected
```

**Business Rules:**
- Every redemption attempt (success or failure) is logged
- Status determines if voucher was successfully redeemed
- Multiple attempts for same voucher can be logged
- Used for fraud detection and audit trail

---

### 9. SignInRule (10 rows)
**Purpose:** Defines daily sign-in rewards (points, experience, coupons)

**Schema:**
```sql
CREATE TABLE SignInRule (
    Id int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    SignInDay int NOT NULL,                      -- UNIQUE, day number (1-365)
    Points int NOT NULL,                         -- Points reward >= 0
    Experience int NOT NULL,                     -- Pet experience >= 0
    HasCoupon bit NOT NULL DEFAULT 0,
    CouponTypeCode nvarchar(50) NULL,            -- FK → CouponType.Name
    IsActive bit NOT NULL DEFAULT 1,
    CreatedAt datetime2(7) NOT NULL DEFAULT sysutcdatetime(),
    UpdatedAt datetime2(7) NULL,
    Description nvarchar(255) NULL,
    IsDeleted bit NOT NULL DEFAULT 0,
    DeletedAt datetime2(7) NULL,
    DeletedBy int NULL,
    DeleteReason nvarchar(500) NULL
);
```

**Columns:**
| Column | Type | Null | Default | Description |
|--------|------|------|---------|-------------|
| Id | int | NO | IDENTITY | Primary key |
| SignInDay | int | NO | - | Day number (1-365), UNIQUE |
| Points | int | NO | - | Points reward (non-negative) |
| Experience | int | NO | - | Pet experience reward (non-negative) |
| HasCoupon | bit | NO | 0 | Whether coupon is awarded |
| CouponTypeCode | nvarchar(50) | YES | NULL | References CouponType.Name |
| IsActive | bit | NO | 1 | Rule is active |
| CreatedAt | datetime2(7) | NO | sysutcdatetime() | Creation timestamp |
| UpdatedAt | datetime2(7) | YES | NULL | Last update timestamp |
| Description | nvarchar(255) | YES | NULL | Rule description |
| IsDeleted | bit | NO | 0 | Soft delete flag |
| DeletedAt | datetime2(7) | YES | NULL | Soft delete timestamp |
| DeletedBy | int | YES | NULL | Manager who deleted |
| DeleteReason | nvarchar(500) | YES | NULL | Deletion reason |

**Keys & Constraints:**
- **PK:** Id (CLUSTERED, IDENTITY)
- **FK:** CouponTypeCode → CouponType.Name (NO_ACTION)
- **UK:** UQ_SignInRule_SignInDay_Active (SignInDay)
- **Indexes:**
  - PK_SignInRule (CLUSTERED): Id
  - UQ_SignInRule_SignInDay_Active (NONCLUSTERED): SignInDay
  - IX_SignInRule_IsDeleted (NONCLUSTERED): IsDeleted
- **Check Constraints:**
  - CK_SignInRule_DayRange: SignInDay BETWEEN 1 AND 365
  - CK_SignInRule_Positive: Points >= 0 AND Experience >= 0
  - CK_SignInRule_CouponFlag: (HasCoupon=1 AND CouponTypeCode IS NOT NULL) OR (HasCoupon=0 AND CouponTypeCode IS NULL)

**Sample Data (Top 5):**
```
Id|SignInDay|Points|Experience|HasCoupon|CouponTypeCode|IsActive|CreatedAt|Description
1|1|20|0|0|NULL|1|2025-10-23 10:32:52.0961026|第 1 天簽到獎勵
2|2|20|0|0|NULL|1|2025-10-23 10:32:52.0961026|第 2 天簽到獎勵
3|3|20|0|0|NULL|1|2025-10-23 10:32:52.0961026|第 3 天簽到獎勵
4|4|20|0|0|NULL|1|2025-10-23 10:32:52.0961026|第 4 天簽到獎勵
5|5|20|0|0|NULL|1|2025-10-23 10:32:52.0961026|第 5 天簽到獎勵
```

**Business Rules:**
- SignInDay must be unique (1-365)
- If HasCoupon=1, CouponTypeCode must be provided
- Points and Experience must be non-negative
- Used to generate UserSignInStats records

---

### 10. UserSignInStats (2400 rows)
**Purpose:** Tracks user sign-in history and rewards claimed

**Schema:**
```sql
CREATE TABLE UserSignInStats (
    LogID int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    SignTime datetime2(7) NOT NULL DEFAULT sysutcdatetime(),
    UserID int NOT NULL,                         -- FK → Users.User_ID
    PointsGained int NOT NULL,
    PointsGainedTime datetime2(7) NOT NULL DEFAULT sysutcdatetime(),
    ExpGained int NOT NULL,
    ExpGainedTime datetime2(7) NOT NULL DEFAULT sysutcdatetime(),
    CouponGained nvarchar(50) NOT NULL,
    CouponGainedTime datetime2(7) NOT NULL DEFAULT sysutcdatetime(),
    IsDeleted bit NOT NULL DEFAULT 0,
    DeletedAt datetime2(7) NULL,
    DeletedBy int NULL,
    DeleteReason nvarchar(500) NULL
);
```

**Columns:**
| Column | Type | Null | Default | Description |
|--------|------|------|---------|-------------|
| LogID | int | NO | IDENTITY | Primary key |
| SignTime | datetime2(7) | NO | sysutcdatetime() | Sign-in timestamp |
| UserID | int | NO | - | References Users.User_ID |
| PointsGained | int | NO | - | Points awarded |
| PointsGainedTime | datetime2(7) | NO | sysutcdatetime() | Points award timestamp |
| ExpGained | int | NO | - | Experience awarded to pet |
| ExpGainedTime | datetime2(7) | NO | sysutcdatetime() | Experience award timestamp |
| CouponGained | nvarchar(50) | NO | - | Coupon code generated (if any) |
| CouponGainedTime | datetime2(7) | NO | sysutcdatetime() | Coupon award timestamp |
| IsDeleted | bit | NO | 0 | Soft delete flag |
| DeletedAt | datetime2(7) | YES | NULL | Soft delete timestamp |
| DeletedBy | int | YES | NULL | Manager who deleted |
| DeleteReason | nvarchar(500) | YES | NULL | Deletion reason |

**Keys & Constraints:**
- **PK:** LogID (CLUSTERED, IDENTITY)
- **FK:** UserID → Users.User_ID (NO_ACTION)
- **UK:** None
- **Indexes:**
  - PK_UserSignInStats (CLUSTERED): LogID
  - IX_UserSignInStats_IsDeleted (NONCLUSTERED): IsDeleted
  - IX_UserSignInStats_user_time (NONCLUSTERED): UserID, SignTime

**Sample Data (Top 5):**
```
LogID|SignTime|UserID|PointsGained|ExpGained|CouponGained
1|2023-04-13 10:56:22|10000001|15|0|AUTO-SIGN-000000000001
2|2023-06-02 08:24:29|10000001|15|20|AUTO-SIGN-000000000002
3|2023-06-21 10:03:48|10000001|20|5|AUTO-SIGN-000000000003
4|2023-07-18 10:44:32|10000001|10|5|AUTO-SIGN-000000000004
5|2023-08-10 09:36:22|10000001|5|10|AUTO-SIGN-000000000005
```

**Business Rules:**
- One record per user per day
- Rewards granted based on SignInRule for that day
- CouponGained stores coupon code generated (or placeholder if no coupon)
- Points and experience distributed to User_Wallet and Pet tables

---

### 11. Pet (200 rows)
**Purpose:** Virtual pet system with stats, customization, and leveling

**Schema:**
```sql
CREATE TABLE Pet (
    PetID int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    UserID int NOT NULL,                         -- FK → Users.User_ID
    PetName nvarchar(50) NOT NULL,
    Level int NOT NULL,
    LevelUpTime datetime2(7) NOT NULL DEFAULT sysutcdatetime(),
    Experience int NOT NULL,
    Hunger int NOT NULL,                         -- 0-100
    Mood int NOT NULL,                           -- 0-100
    Stamina int NOT NULL,                        -- 0-100
    Cleanliness int NOT NULL,                    -- 0-100
    Health int NOT NULL,                         -- 0-100
    SkinColor varchar(10) NOT NULL,              -- Hex color code
    SkinColorChangedTime datetime2(7) NOT NULL,
    BackgroundColor nvarchar(20) NOT NULL,       -- Background code
    BackgroundColorChangedTime datetime2(7) NOT NULL,
    PointsChanged_SkinColor int NOT NULL,
    PointsChanged_BackgroundColor int NOT NULL,
    PointsGained_LevelUp int NOT NULL,
    PointsGainedTime_LevelUp datetime2(7) NOT NULL DEFAULT sysutcdatetime(),
    IsDeleted bit NOT NULL DEFAULT 0,
    DeletedAt datetime2(7) NULL,
    DeletedBy int NULL,
    DeleteReason nvarchar(500) NULL,
    CurrentExperience int NOT NULL DEFAULT 0,
    ExperienceToNextLevel int NULL,
    TotalPointsGained_LevelUp int NULL DEFAULT 0
);
```

**Columns:**
| Column | Type | Null | Default | Description |
|--------|------|------|---------|-------------|
| PetID | int | NO | IDENTITY | Primary key |
| UserID | int | NO | - | References Users.User_ID |
| PetName | nvarchar(50) | NO | - | Pet's custom name |
| Level | int | NO | - | Current level |
| LevelUpTime | datetime2(7) | NO | sysutcdatetime() | Last level-up timestamp |
| Experience | int | NO | - | Total accumulated experience |
| Hunger | int | NO | - | Hunger stat (0-100) |
| Mood | int | NO | - | Mood stat (0-100) |
| Stamina | int | NO | - | Stamina stat (0-100) |
| Cleanliness | int | NO | - | Cleanliness stat (0-100) |
| Health | int | NO | - | Health stat (0-100) |
| SkinColor | varchar(10) | NO | - | Hex color code (e.g., #FF0000) |
| SkinColorChangedTime | datetime2(7) | NO | - | Last skin color change |
| BackgroundColor | nvarchar(20) | NO | - | Background code (e.g., BG001) |
| BackgroundColorChangedTime | datetime2(7) | NO | - | Last background change |
| PointsChanged_SkinColor | int | NO | - | Points spent on current skin color |
| PointsChanged_BackgroundColor | int | NO | - | Points spent on current background |
| PointsGained_LevelUp | int | NO | - | Points from last level-up |
| PointsGainedTime_LevelUp | datetime2(7) | NO | sysutcdatetime() | Last level-up points timestamp |
| IsDeleted | bit | NO | 0 | Soft delete flag |
| DeletedAt | datetime2(7) | YES | NULL | Soft delete timestamp |
| DeletedBy | int | YES | NULL | Manager who deleted |
| DeleteReason | nvarchar(500) | YES | NULL | Deletion reason |
| CurrentExperience | int | NO | 0 | Experience progress in current level |
| ExperienceToNextLevel | int | YES | NULL | Experience needed for next level |
| TotalPointsGained_LevelUp | int | YES | 0 | Total points gained from all level-ups |

**Keys & Constraints:**
- **PK:** PetID (CLUSTERED, IDENTITY)
- **FK:** UserID → Users.User_ID (NO_ACTION)
- **UK:** None
- **Indexes:**
  - PK_Pet (CLUSTERED): PetID
  - IX_Pet_IsDeleted (NONCLUSTERED): IsDeleted
  - IX_Pet_user (NONCLUSTERED): UserID
- **Check Constraints:**
  - CK_Pet_Hunger: Hunger BETWEEN 0 AND 100
  - CK_Pet_Mood: Mood BETWEEN 0 AND 100
  - CK_Pet_Stamina: Stamina BETWEEN 0 AND 100
  - CK_Pet_Cleanliness: Cleanliness BETWEEN 0 AND 100
  - CK_Pet_Health: Health BETWEEN 0 AND 100

**Sample Data (Top 5):**
```
PetID|UserID|PetName|Level|Experience|Hunger|Mood|Stamina|Cleanliness|Health|SkinColor|BackgroundColor|CurrentExperience|ExperienceToNextLevel|TotalPointsGained_LevelUp
1|10000001|多多|4|656|14|58|89|25|100|#FFFF00|BG005|53|220|40
2|10000002|小小|38|4019|55|15|57|14|94|#800080|BG008|649|1535|920
3|10000003|波波|19|2947|58|51|76|70|78|#800080|BG002|28|668|280
4|10000004|阿財|39|4377|76|44|67|56|89|#FFFFFF|BG003|427|1596|960
5|10000005|Milo|44|7209|55|33|61|31|83|#6F4E37|BG009|317|1928|1200
```

**Business Rules:**
- Five stats (Hunger, Mood, Stamina, Cleanliness, Health) must be 0-100
- Stats decay over time and are affected by interactions
- Level-up rewards points (tracked in TotalPointsGained_LevelUp)
- Skin color and background can be customized (point cost tracked)
- One pet per user

---

### 12. PetSkinColorCostSettings (11 rows)
**Purpose:** Defines purchasable skin colors for pets

**Schema:**
```sql
CREATE TABLE PetSkinColorCostSettings (
    SettingId int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ColorCode varchar(10) NOT NULL,              -- UNIQUE, hex format (e.g., #FF0000)
    ColorName nvarchar(50) NOT NULL,
    PointsCost int NOT NULL DEFAULT 2000,        -- Points required
    Rarity nvarchar(20) NOT NULL DEFAULT N'普通',
    Description nvarchar(500) NULL,
    PreviewImagePath nvarchar(500) NULL,
    ColorHex varchar(7) NULL,
    IsActive bit NOT NULL DEFAULT 1,
    DisplayOrder int NOT NULL DEFAULT 0,
    IsFree bit NOT NULL DEFAULT 0,
    IsLimitedEdition bit NOT NULL DEFAULT 0,
    AvailableFrom datetime2(7) NULL,
    AvailableUntil datetime2(7) NULL,
    IsDeleted bit NOT NULL DEFAULT 0,
    DeletedAt datetime2(7) NULL,
    DeletedBy int NULL,
    DeleteReason nvarchar(500) NULL,
    CreatedAt datetime2(7) NOT NULL DEFAULT sysutcdatetime(),
    UpdatedAt datetime2(7) NULL,
    UpdatedBy int NULL
);
```

**Columns:**
| Column | Type | Null | Default | Description |
|--------|------|------|---------|-------------|
| SettingId | int | NO | IDENTITY | Primary key |
| ColorCode | varchar(10) | NO | - | UNIQUE hex color code |
| ColorName | nvarchar(50) | NO | - | Display name |
| PointsCost | int | NO | 2000 | Points to unlock (0 if free) |
| Rarity | nvarchar(20) | NO | '普通' | Rarity tier |
| Description | nvarchar(500) | YES | NULL | Description |
| PreviewImagePath | nvarchar(500) | YES | NULL | Preview image URL |
| ColorHex | varchar(7) | YES | NULL | Alternative hex format |
| IsActive | bit | NO | 1 | Available for purchase |
| DisplayOrder | int | NO | 0 | Display order in UI |
| IsFree | bit | NO | 0 | Free (no points required) |
| IsLimitedEdition | bit | NO | 0 | Limited time availability |
| AvailableFrom | datetime2(7) | YES | NULL | Limited edition start date |
| AvailableUntil | datetime2(7) | YES | NULL | Limited edition end date |
| IsDeleted | bit | NO | 0 | Soft delete flag |
| DeletedAt | datetime2(7) | YES | NULL | Soft delete timestamp |
| DeletedBy | int | YES | NULL | Manager who deleted |
| DeleteReason | nvarchar(500) | YES | NULL | Deletion reason |
| CreatedAt | datetime2(7) | NO | sysutcdatetime() | Creation timestamp |
| UpdatedAt | datetime2(7) | YES | NULL | Last update timestamp |
| UpdatedBy | int | YES | NULL | Manager who last updated |

**Keys & Constraints:**
- **PK:** SettingId (CLUSTERED, IDENTITY)
- **FK:** None
- **UK:** UQ_PetSkinColorCostSettings_ColorCode (ColorCode)
- **Indexes:**
  - PK_PetSkinColorCostSettings (CLUSTERED): SettingId
  - UQ_PetSkinColorCostSettings_ColorCode (NONCLUSTERED): ColorCode
  - IX_PetSkinColorCostSettings_IsActive_DisplayOrder (NONCLUSTERED): IsActive, DisplayOrder
  - IX_PetSkinColorCostSettings_Rarity (NONCLUSTERED): Rarity
- **Check Constraints:**
  - CK_PetSkinColorCostSettings_PointsCost: PointsCost >= 0
  - CK_PetSkinColorCostSettings_ColorCode: ColorCode LIKE '#%' AND LEN(ColorCode) >= 4
  - CK_PetSkinColorCostSettings_Rarity: Rarity IN ('普通', '罕見', '稀有', '史詩', '傳說')

**Sample Data (Top 5):**
```
SettingId|ColorCode|ColorName|PointsCost|Rarity|Description|IsFree
1|#FFFFFF|白色|0|普通|純淨的白色,寵物預設色|1
2|#000000|黑色|0|普通|經典的黑色,寵物預設色|1
3|#FF0000|紅色|0|普通|鮮豔的紅色,寵物預設色|1
4|#FFA500|橘色|2000|普通|溫暖陽光的橘色|0
5|#FFFF00|黃色|2000|普通|明亮開朗的黃色|0
```

**Business Rules:**
- ColorCode must be unique and in hex format
- IsFree=1 means PointsCost should be 0 (default colors)
- Rarity affects display and availability
- Limited edition colors have AvailableFrom/AvailableUntil dates

---

### 13. PetBackgroundCostSettings (11 rows)
**Purpose:** Defines purchasable backgrounds for pet display

**Schema:**
```sql
CREATE TABLE PetBackgroundCostSettings (
    SettingId int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    BackgroundCode nvarchar(50) NOT NULL,        -- UNIQUE (e.g., BG001)
    BackgroundName nvarchar(100) NOT NULL,
    PointsCost int NOT NULL,                     -- Points required
    Description nvarchar(500) NULL,
    PreviewImagePath nvarchar(200) NULL,
    IsActive bit NOT NULL DEFAULT 1,
    DisplayOrder int NULL DEFAULT 0,
    IsDeleted bit NOT NULL DEFAULT 0,
    DeletedAt datetime2(7) NULL,
    DeletedBy int NULL,                          -- FK → ManagerData.Manager_Id
    DeleteReason nvarchar(500) NULL,
    CreatedAt datetime2(7) NOT NULL DEFAULT sysutcdatetime(),
    UpdatedAt datetime2(7) NULL,
    UpdatedBy int NULL,
    Rarity nvarchar(20) NULL
);
```

**Columns:**
| Column | Type | Null | Default | Description |
|--------|------|------|---------|-------------|
| SettingId | int | NO | IDENTITY | Primary key |
| BackgroundCode | nvarchar(50) | NO | - | UNIQUE code (e.g., BG001) |
| BackgroundName | nvarchar(100) | NO | - | Display name |
| PointsCost | int | NO | - | Points to unlock |
| Description | nvarchar(500) | YES | NULL | Description |
| PreviewImagePath | nvarchar(200) | YES | NULL | Preview image URL |
| IsActive | bit | NO | 1 | Available for purchase |
| DisplayOrder | int | YES | 0 | Display order in UI |
| IsDeleted | bit | NO | 0 | Soft delete flag |
| DeletedAt | datetime2(7) | YES | NULL | Soft delete timestamp |
| DeletedBy | int | YES | NULL | Manager who deleted |
| DeleteReason | nvarchar(500) | YES | NULL | Deletion reason |
| CreatedAt | datetime2(7) | NO | sysutcdatetime() | Creation timestamp |
| UpdatedAt | datetime2(7) | YES | NULL | Last update timestamp |
| UpdatedBy | int | YES | NULL | Manager who last updated |
| Rarity | nvarchar(20) | YES | NULL | Rarity tier |

**Keys & Constraints:**
- **PK:** SettingId (CLUSTERED, IDENTITY)
- **FK:** UpdatedBy → ManagerData.Manager_Id (NO_ACTION)
- **UK:** UQ_PetBackgroundCostSettings_BackgroundCode (BackgroundCode)
- **Indexes:**
  - PK_PetBackgroundCostSettings (CLUSTERED): SettingId
  - UQ_PetBackgroundCostSettings_BackgroundCode (NONCLUSTERED): BackgroundCode
- **Check Constraints:**
  - CK_PetBackgroundCostSettings_PointsCost: PointsCost >= 0

**Sample Data (Top 5):**
```
SettingId|BackgroundCode|BackgroundName|PointsCost|Description|PreviewImagePath
19|BG001|萬聖節南瓜|0|充滿萬聖節氣氛的南瓜背景,免費特色場景|/images/backgrounds/halloween-pumpkin.jpg
20|BG002|教堂彩窗|0|華麗莊嚴的教堂彩窗背景,神聖氣息濃厚|/images/backgrounds/stained-glass-church.jpg
21|BG003|珊瑚沙灘|0|晴天海灘與珊瑚礁,陽光與海令人心曠神怡|/images/backgrounds/coral-beach.jpg
22|BG004|清新森林|2000|鮮綠的大自然清新森林,清爽自然|/images/backgrounds/fresh-forest.jpg
23|BG005|叢林瀑布|2500|熱帶叢林深處的壯麗瀑布,壯觀自然|/images/backgrounds/rainforest-waterfall.jpg
```

**Business Rules:**
- BackgroundCode must be unique
- Free backgrounds (PointsCost=0) are available by default
- Backgrounds displayed in Pet interface

---

### 14. PetLevelRewardSettings (25 rows)
**Purpose:** Defines point rewards for pet level-ups (tier-based)

**Schema:**
```sql
CREATE TABLE PetLevelRewardSettings (
    SettingId int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    LevelRangeStart int NOT NULL,                -- Start level (inclusive)
    LevelRangeEnd int NOT NULL,                  -- End level (inclusive)
    PointsReward int NOT NULL,                   -- Points awarded per level-up in range
    Description nvarchar(500) NULL,
    IsActive bit NOT NULL DEFAULT 1,
    DisplayOrder int NOT NULL DEFAULT 0,
    IsDeleted bit NOT NULL DEFAULT 0,
    DeletedAt datetime2(7) NULL,
    DeletedBy int NULL,
    DeleteReason nvarchar(500) NULL,
    CreatedAt datetime2(7) NOT NULL DEFAULT sysutcdatetime(),
    UpdatedAt datetime2(7) NULL,
    UpdatedBy int NULL
);
```

**Columns:**
| Column | Type | Null | Default | Description |
|--------|------|------|---------|-------------|
| SettingId | int | NO | IDENTITY | Primary key |
| LevelRangeStart | int | NO | - | Start level (inclusive) |
| LevelRangeEnd | int | NO | - | End level (inclusive) |
| PointsReward | int | NO | - | Points per level-up in this range |
| Description | nvarchar(500) | YES | NULL | Description |
| IsActive | bit | NO | 1 | Active rule |
| DisplayOrder | int | NO | 0 | Display order |
| IsDeleted | bit | NO | 0 | Soft delete flag |
| DeletedAt | datetime2(7) | YES | NULL | Soft delete timestamp |
| DeletedBy | int | YES | NULL | Manager who deleted |
| DeleteReason | nvarchar(500) | YES | NULL | Deletion reason |
| CreatedAt | datetime2(7) | NO | sysutcdatetime() | Creation timestamp |
| UpdatedAt | datetime2(7) | YES | NULL | Last update timestamp |
| UpdatedBy | int | YES | NULL | Manager who last updated |

**Keys & Constraints:**
- **PK:** SettingId (CLUSTERED, IDENTITY)
- **FK:** None
- **UK:** UQ_PetLevelRewardSettings_LevelRange (LevelRangeStart, LevelRangeEnd)
- **Indexes:**
  - PK_PetLevelRewardSettings (CLUSTERED): SettingId
  - UQ_PetLevelRewardSettings_LevelRange (NONCLUSTERED): LevelRangeStart, LevelRangeEnd
  - IX_PetLevelRewardSettings_LevelRange (NONCLUSTERED): LevelRangeStart, LevelRangeEnd
- **Check Constraints:**
  - CK_PetLevelRewardSettings_LevelRange: LevelRangeStart > 0 AND LevelRangeEnd >= LevelRangeStart
  - CK_PetLevelRewardSettings_PointsReward: PointsReward BETWEEN 0 AND 999999

**Sample Data (Top 5):**
```
SettingId|LevelRangeStart|LevelRangeEnd|PointsReward|Description
1|1|10|10|新手階段(Level 1-10)
2|11|20|20|進階階段(Level 11-20)
3|21|30|30|高級階段(Level 21-30)
4|31|40|40|專家階段(Level 31-40)
5|41|50|50|大師階段(Level 41-50)
```

**Business Rules:**
- Level ranges must not overlap
- LevelRangeStart must be > 0
- LevelRangeEnd must be >= LevelRangeStart
- Points awarded to User_Wallet when pet levels up

---

### 15. MiniGame (2000 rows)
**Purpose:** Records mini-game play sessions with rewards and pet stat changes

**Schema:**
```sql
CREATE TABLE MiniGame (
    PlayID int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    UserID int NOT NULL,                         -- FK → Users.User_ID
    PetID int NOT NULL,                          -- FK → Pet.PetID
    Level int NOT NULL,                          -- Game difficulty level (1-3)
    MonsterCount int NOT NULL,                   -- Monsters defeated
    SpeedMultiplier decimal(5,2) NOT NULL,       -- Game speed multiplier
    Result nvarchar(20) NOT NULL,                -- 'Win' or 'Lose'
    ExpGained int NOT NULL,                      -- Experience awarded to pet
    ExpGainedTime datetime2(7) NOT NULL DEFAULT sysutcdatetime(),
    PointsGained int NOT NULL,                   -- Points awarded to user
    PointsGainedTime datetime2(7) NOT NULL DEFAULT sysutcdatetime(),
    CouponGained nvarchar(50) NOT NULL,          -- Coupon code generated (if any)
    CouponGainedTime datetime2(7) NOT NULL DEFAULT sysutcdatetime(),
    HungerDelta int NOT NULL,                    -- Change in Hunger stat
    MoodDelta int NOT NULL,                      -- Change in Mood stat
    StaminaDelta int NOT NULL,                   -- Change in Stamina stat
    CleanlinessDelta int NOT NULL,               -- Change in Cleanliness stat
    StartTime datetime2(7) NOT NULL DEFAULT sysutcdatetime(),
    EndTime datetime2(7) NULL DEFAULT sysutcdatetime(),
    Aborted bit NOT NULL,                        -- Game was aborted
    IsDeleted bit NOT NULL DEFAULT 0,
    DeletedAt datetime2(7) NULL,
    DeletedBy int NULL,
    DeleteReason nvarchar(500) NULL
);
```

**Columns:**
| Column | Type | Null | Default | Description |
|--------|------|------|---------|-------------|
| PlayID | int | NO | IDENTITY | Primary key |
| UserID | int | NO | - | References Users.User_ID |
| PetID | int | NO | - | References Pet.PetID |
| Level | int | NO | - | Game difficulty (1-3) |
| MonsterCount | int | NO | - | Monsters defeated in session |
| SpeedMultiplier | decimal(5,2) | NO | - | Game speed multiplier |
| Result | nvarchar(20) | NO | - | 'Win' or 'Lose' |
| ExpGained | int | NO | - | Experience awarded to pet |
| ExpGainedTime | datetime2(7) | NO | sysutcdatetime() | Experience award timestamp |
| PointsGained | int | NO | - | Points awarded to user |
| PointsGainedTime | datetime2(7) | NO | sysutcdatetime() | Points award timestamp |
| CouponGained | nvarchar(50) | NO | - | Coupon code (or placeholder) |
| CouponGainedTime | datetime2(7) | NO | sysutcdatetime() | Coupon award timestamp |
| HungerDelta | int | NO | - | Change in pet Hunger (-/+) |
| MoodDelta | int | NO | - | Change in pet Mood (-/+) |
| StaminaDelta | int | NO | - | Change in pet Stamina (-/+) |
| CleanlinessDelta | int | NO | - | Change in pet Cleanliness (-/+) |
| StartTime | datetime2(7) | NO | sysutcdatetime() | Game start timestamp |
| EndTime | datetime2(7) | YES | sysutcdatetime() | Game end timestamp |
| Aborted | bit | NO | - | Game was aborted before completion |
| IsDeleted | bit | NO | 0 | Soft delete flag |
| DeletedAt | datetime2(7) | YES | NULL | Soft delete timestamp |
| DeletedBy | int | YES | NULL | Manager who deleted |
| DeleteReason | nvarchar(500) | YES | NULL | Deletion reason |

**Keys & Constraints:**
- **PK:** PlayID (CLUSTERED, IDENTITY)
- **FK:**
  - UserID → Users.User_ID (NO_ACTION)
  - PetID → Pet.PetID (NO_ACTION)
- **UK:** None
- **Indexes:**
  - PK_MiniGame (CLUSTERED): PlayID
  - IX_MiniGame_IsDeleted (NONCLUSTERED): IsDeleted
  - IX_MiniGame_user_time (NONCLUSTERED): UserID, StartTime

**Sample Data (Top 5):**
```
PlayID|UserID|PetID|Level|MonsterCount|SpeedMultiplier|Result|ExpGained|PointsGained|CouponGained|HungerDelta|MoodDelta|StaminaDelta|CleanlinessDelta|StartTime|EndTime|Aborted
1|10000001|1|3|10|2.00|Lose|0|0|CPN-5553-121B690001|-7|-3|6|5|2024-09-03 09:36:58|2024-09-03 09:52:58|0
2|10000001|1|2|8|1.50|Win|200|20|CPN-1603-9C4A620002|4|8|-8|-2|2025-06-30 10:46:31|2025-06-30 10:59:31|0
3|10000001|1|3|10|2.00|Win|300|30|CPN-4809-7519BC0003|-2|3|-1|-4|2023-07-01 13:44:35|2023-07-01 13:49:35|0
4|10000001|1|3|10|2.00|Lose|0|0|CPN-3231-6365550004|-5|0|0|-4|2023-12-10 03:41:43|2023-12-10 03:52:43|0
5|10000001|1|2|8|1.50|Lose|0|0|CPN-6286-72F0BD0005|0|8|-6|3|2025-06-22 23:39:35|2025-06-23 00:04:35|0
```

**Business Rules:**
- Result must be 'Win' or 'Lose'
- Win grants ExpGained and PointsGained (Lose grants 0)
- Pet stats affected by deltas (can be positive or negative)
- Daily play limit enforced at application layer (default: 3 plays/day)
- Aborted games don't grant rewards

---

### 16. SystemSettings (56 rows)
**Purpose:** Global system configuration key-value store

**Schema:**
```sql
CREATE TABLE SystemSettings (
    SettingId int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    SettingKey nvarchar(200) NOT NULL,           -- UNIQUE
    SettingValue nvarchar(MAX) NULL,             -- JSON, String, Number, Boolean
    Description nvarchar(500) NULL,
    Category nvarchar(100) NOT NULL DEFAULT 'General',
    SettingType nvarchar(50) NOT NULL DEFAULT 'String',  -- 'String', 'Number', 'Boolean', 'JSON'
    IsReadOnly bit NOT NULL DEFAULT 0,
    IsActive bit NOT NULL DEFAULT 1,
    IsDeleted bit NOT NULL DEFAULT 0,
    DeletedAt datetime2(7) NULL,
    DeletedBy int NULL,                          -- FK → ManagerData.Manager_Id
    DeleteReason nvarchar(500) NULL,
    CreatedAt datetime2(7) NOT NULL DEFAULT sysutcdatetime(),
    UpdatedAt datetime2(7) NULL,
    UpdatedBy int NULL
);
```

**Columns:**
| Column | Type | Null | Default | Description |
|--------|------|------|---------|-------------|
| SettingId | int | NO | IDENTITY | Primary key |
| SettingKey | nvarchar(200) | NO | - | UNIQUE configuration key |
| SettingValue | nvarchar(MAX) | YES | NULL | Configuration value (JSON/String/Number/Boolean) |
| Description | nvarchar(500) | YES | NULL | Setting description |
| Category | nvarchar(100) | NO | 'General' | Category grouping |
| SettingType | nvarchar(50) | NO | 'String' | Data type of value |
| IsReadOnly | bit | NO | 0 | Prevent editing via UI |
| IsActive | bit | NO | 1 | Setting is active |
| IsDeleted | bit | NO | 0 | Soft delete flag |
| DeletedAt | datetime2(7) | YES | NULL | Soft delete timestamp |
| DeletedBy | int | YES | NULL | Manager who deleted |
| DeleteReason | nvarchar(500) | YES | NULL | Deletion reason |
| CreatedAt | datetime2(7) | NO | sysutcdatetime() | Creation timestamp |
| UpdatedAt | datetime2(7) | YES | NULL | Last update timestamp |
| UpdatedBy | int | YES | NULL | Manager who last updated |

**Keys & Constraints:**
- **PK:** SettingId (CLUSTERED, IDENTITY)
- **FK:** UpdatedBy → ManagerData.Manager_Id (NO_ACTION)
- **UK:** UQ_SystemSettings_SettingKey (SettingKey)
- **Indexes:**
  - PK_SystemSettings (CLUSTERED): SettingId
  - UQ_SystemSettings_SettingKey (NONCLUSTERED): SettingKey
- **Check Constraints:**
  - CHK_SystemSettings_SettingType: SettingType IN ('String', 'Number', 'Boolean', 'JSON')

**Sample Data (Top 5):**
```
SettingId|SettingKey|SettingValue|Description|Category|SettingType
1|Game.DefaultDailyLimit|3|Default daily game limit|Game|Number
2|Game.Levels.Configuration|{"levels":[{"level":1,"monsterCount":6,"speedMultiplier":1.0,...}]|Game level configuration (3 levels)|Game|JSON
3|Game.Level1.MonsterCount|6|Level 1 monster count|Game|Number
4|Game.Level2.MonsterCount|8|Level 2 monster count|Game|Number
5|Game.Level3.MonsterCount|10|Level 3 monster count|Game|Number
```

**Business Rules:**
- SettingKey must be unique
- SettingType determines how SettingValue is parsed
- IsReadOnly prevents editing via admin UI (code-only changes)
- Used for feature flags, game configuration, rate limits, etc.

---

### 17. Users (200 rows)
**Purpose:** Core user authentication and account management

**Schema:**
```sql
CREATE TABLE Users (
    User_ID int IDENTITY(10000001,1) NOT NULL PRIMARY KEY,
    User_name nvarchar(30) NOT NULL,             -- UNIQUE
    User_Account nvarchar(30) NOT NULL,          -- UNIQUE
    User_Password nvarchar(255) NOT NULL,        -- Hashed password
    User_EmailConfirmed bit NOT NULL DEFAULT 0,
    User_PhoneNumberConfirmed bit NOT NULL DEFAULT 0,
    User_TwoFactorEnabled bit NOT NULL DEFAULT 0,
    User_AccessFailedCount int NOT NULL DEFAULT 0,
    User_LockoutEnabled bit NOT NULL DEFAULT 1,
    User_LockoutEnd datetime2(7) NULL,
    Create_Account datetime2(7) NOT NULL DEFAULT sysdatetime()
);
```

**Columns:**
| Column | Type | Null | Default | Description |
|--------|------|------|---------|-------------|
| User_ID | int | NO | IDENTITY(10000001,1) | Primary key, starts at 10000001 |
| User_name | nvarchar(30) | NO | - | Display name (UNIQUE) |
| User_Account | nvarchar(30) | NO | - | Login account (UNIQUE) |
| User_Password | nvarchar(255) | NO | - | Hashed password |
| User_EmailConfirmed | bit | NO | 0 | Email verified |
| User_PhoneNumberConfirmed | bit | NO | 0 | Phone verified |
| User_TwoFactorEnabled | bit | NO | 0 | 2FA enabled |
| User_AccessFailedCount | int | NO | 0 | Failed login attempts |
| User_LockoutEnabled | bit | NO | 1 | Account lockout enabled |
| User_LockoutEnd | datetime2(7) | YES | NULL | Lockout expiration |
| Create_Account | datetime2(7) | NO | sysdatetime() | Account creation timestamp |

**Keys & Constraints:**
- **PK:** User_ID (CLUSTERED, IDENTITY)
- **FK:** None
- **UK:**
  - UQ_Users_User_name (User_name)
  - UQ_Users_User_Account (User_Account)
- **Indexes:**
  - PK_Users (CLUSTERED): User_ID
  - UQ_Users_User_name (NONCLUSTERED): User_name
  - UQ_Users_User_Account (NONCLUSTERED): User_Account
  - IX_Users_UserAccount (NONCLUSTERED): User_Account

**Sample Data (Top 5):**
```
User_ID|User_name|User_Account|User_Password|User_EmailConfirmed|User_PhoneNumberConfirmed|Create_Account
10000001|DragonKnight88|dragonknight88|AQAAAAIAAYagAAAAEBQzmmebk9Q0dlggNxtik...|1|1|2025-10-23 16:14:43
10000002|TechGuru92|tech_guru_92|AQAAAAIAAYagAAAAEEfji0DAJ0v0/OkQ53fT...|1|1|2025-10-23 16:14:43
10000003|CoffeeAddict|coffee_addict|CoffeePwd003!|1|1|2025-10-23 16:14:43
10000004|YogaMaster|yoga_master|YogaLife004$|1|1|2025-10-23 16:14:43
10000005|BookLover|book_lover_95|ReadMore005%|1|1|2025-10-23 16:14:43
```

**Business Rules:**
- User_ID starts at 10000001 (human-friendly IDs)
- User_name and User_Account must be unique
- Password stored as hashed (bcrypt/PBKDF2)
- Lockout prevents login attempts when triggered
- Referenced by all user-related tables in MiniGame Area

---

### 18. ManagerData (102 rows)
**Purpose:** Admin/manager authentication and account management

**Schema:**
```sql
CREATE TABLE ManagerData (
    Manager_Id int NOT NULL PRIMARY KEY,         -- NOT IDENTITY (manually assigned)
    Manager_Name nvarchar(30) NULL,
    Manager_Account varchar(30) NULL,            -- UNIQUE
    Manager_Password nvarchar(200) NULL,         -- Hashed password
    Administrator_registration_date datetime2(7) NULL,
    Manager_Email nvarchar(255) NOT NULL,        -- UNIQUE
    Manager_EmailConfirmed bit NOT NULL DEFAULT 0,
    Manager_AccessFailedCount int NOT NULL DEFAULT 0,
    Manager_LockoutEnabled bit NOT NULL DEFAULT 1,
    Manager_LockoutEnd datetime2(7) NULL
);
```

**Columns:**
| Column | Type | Null | Default | Description |
|--------|------|------|---------|-------------|
| Manager_Id | int | NO | - | Primary key (manually assigned) |
| Manager_Name | nvarchar(30) | YES | NULL | Manager display name |
| Manager_Account | varchar(30) | YES | NULL | Login account (UNIQUE) |
| Manager_Password | nvarchar(200) | YES | NULL | Hashed password |
| Administrator_registration_date | datetime2(7) | YES | NULL | Registration timestamp |
| Manager_Email | nvarchar(255) | NO | - | Email (UNIQUE) |
| Manager_EmailConfirmed | bit | NO | 0 | Email verified |
| Manager_AccessFailedCount | int | NO | 0 | Failed login attempts |
| Manager_LockoutEnabled | bit | NO | 1 | Lockout enabled |
| Manager_LockoutEnd | datetime2(7) | YES | NULL | Lockout expiration |

**Keys & Constraints:**
- **PK:** Manager_Id (CLUSTERED)
- **FK:** None
- **UK:**
  - UQ_ManagerData_Manager_Email (Manager_Email)
  - UQ_ManagerData_Manager_Account (Manager_Account)
- **Indexes:**
  - PK_ManagerData (CLUSTERED): Manager_Id
  - UQ_ManagerData_Manager_Email (NONCLUSTERED): Manager_Email
  - UQ_ManagerData_Manager_Account (NONCLUSTERED): Manager_Account

**Sample Data (Top 5):**
```
Manager_Id|Manager_Name|Manager_Account|Manager_Password|Administrator_registration_date|Manager_Email
30000001|Milk Hung|zhang_zhiming_01|AdminPass001@|2019-01-15 08:30:00|zhang.zhiming@company.com
30000002|李小華|li_xiaohua_02|SecurePass002#|2019-01-16 09:15:00|li.xiaohua@company.com
30000003|王美玲|wang_meiling_03|StrongPwd003!|2019-01-17 10:45:00|wang.meiling@company.com
30000004|陳大偉|chen_dawei_04|SafeLogin004$|2019-01-18 11:20:00|chen.dawei@company.com
30000005|林雅婷|lin_yating_05|Manager005%|2019-01-19 14:30:00|lin.yating@company.com
```

**Business Rules:**
- Manager_Id is manually assigned (not auto-increment)
- Manager_Account and Manager_Email must be unique
- Used for GameSpace admin authentication
- Referenced by audit fields (DeletedBy, UpdatedBy) in MiniGame tables

---

### 19. ManagerRole (102 rows)
**Purpose:** Many-to-many relationship between managers and roles

**Schema:**
```sql
CREATE TABLE ManagerRole (
    Manager_Id int NOT NULL,                     -- FK → ManagerData.Manager_Id
    ManagerRole_Id int NOT NULL,                 -- FK → ManagerRolePermission.ManagerRole_Id
    PRIMARY KEY (Manager_Id, ManagerRole_Id)
);
```

**Columns:**
| Column | Type | Null | Default | Description |
|--------|------|------|---------|-------------|
| Manager_Id | int | NO | - | References ManagerData.Manager_Id |
| ManagerRole_Id | int | NO | - | References ManagerRolePermission.ManagerRole_Id |

**Keys & Constraints:**
- **PK:** (Manager_Id, ManagerRole_Id) (CLUSTERED, COMPOSITE)
- **FK:**
  - Manager_Id → ManagerData.Manager_Id (NO_ACTION)
  - ManagerRole_Id → ManagerRolePermission.ManagerRole_Id (NO_ACTION)
- **UK:** None
- **Indexes:**
  - PK_ManagerRole (CLUSTERED): Manager_Id, ManagerRole_Id

**Sample Data (Top 5):**
```
Manager_Id|ManagerRole_Id
30000001|1
30000002|2
30000003|3
30000004|4
30000005|5
```

**Business Rules:**
- One manager can have one or more roles
- One role can be assigned to multiple managers
- Used for authorization checks in GameSpace

---

### 20. ManagerRolePermission (8 rows)
**Purpose:** Defines permission sets for manager roles

**Schema:**
```sql
CREATE TABLE ManagerRolePermission (
    ManagerRole_Id int NOT NULL PRIMARY KEY,     -- NOT IDENTITY
    role_name nvarchar(50) NOT NULL,
    AdministratorPrivilegesManagement bit NULL,
    UserStatusManagement bit NULL,
    ShoppingPermissionManagement bit NULL,
    MessagePermissionManagement bit NULL,
    Pet_Rights_Management bit NULL,
    customer_service bit NULL
);
```

**Columns:**
| Column | Type | Null | Default | Description |
|--------|------|------|---------|-------------|
| ManagerRole_Id | int | NO | - | Primary key (manually assigned) |
| role_name | nvarchar(50) | NO | - | Role display name |
| AdministratorPrivilegesManagement | bit | YES | NULL | Can manage admin privileges |
| UserStatusManagement | bit | YES | NULL | Can manage user status |
| ShoppingPermissionManagement | bit | YES | NULL | Can manage shopping permissions |
| MessagePermissionManagement | bit | YES | NULL | Can manage messaging |
| Pet_Rights_Management | bit | YES | NULL | Can manage pet system |
| customer_service | bit | YES | NULL | Customer service access |

**Keys & Constraints:**
- **PK:** ManagerRole_Id (CLUSTERED)
- **FK:** None
- **UK:** None
- **Indexes:**
  - PK_ManagerRolePermission (CLUSTERED): ManagerRole_Id

**Sample Data (Top 5):**
```
ManagerRole_Id|role_name|AdministratorPrivilegesManagement|UserStatusManagement|ShoppingPermissionManagement|MessagePermissionManagement|Pet_Rights_Management|customer_service
1|最高權限管理人員|1|1|1|1|1|1
2|使用者與商城管理專責|0|1|0|1|0|1
3|優惠與禮券管理專責|0|0|1|0|1|0
4|使用者權限管理人員|0|1|0|0|0|0
5|活動權限管理人員|0|0|1|0|0|0
```

**Business Rules:**
- ManagerRole_Id is manually assigned
- Permissions are boolean flags (1=allowed, 0=denied, NULL=not applicable)
- Pet_Rights_Management controls access to MiniGame Area admin features
- Referenced by ManagerRole for role assignments

---

## Relationships Map

```
Users (1) ─────< (∞) User_Wallet
          ├─────< (∞) WalletHistory
          ├─────< (∞) Coupon
          ├─────< (∞) EVoucher
          ├─────< (∞) EVoucherRedeemLog
          ├─────< (∞) UserSignInStats
          ├─────< (∞) Pet ─────< (∞) MiniGame
          └─────< (∞) MiniGame

CouponType (1) ─────< (∞) Coupon
           └─────< (1) SignInRule (via Name)

EVoucherType (1) ───< (∞) EVoucher (1) ───< (∞) EVoucherToken
                                       └───< (∞) EVoucherRedeemLog

Pet (1) ────────────< (∞) MiniGame

ManagerData (1) ────< (∞) ManagerRole (∞) ───> (1) ManagerRolePermission
            ├───────< (∞) PetBackgroundCostSettings (UpdatedBy)
            └───────< (∞) SystemSettings (UpdatedBy, DeletedBy)

(Soft Delete Audit Fields: DeletedBy → ManagerData.Manager_Id for all MiniGame tables)
```

---

## Connection String

**SQL Server:**
```
Server=DESKTOP-8HQIS1S\SQLEXPRESS;Database=GameSpacedatabase;Trusted_Connection=True;TrustServerCertificate=True;
```

**Notes:**
- All timestamps use UTC (`sysutcdatetime()`)
- All tables implement soft delete pattern (except Users, ManagerData, ManagerRole, ManagerRolePermission)
- IDENTITY seeds: Users starts at 10000001, others start at 1
- All foreign keys use NO_ACTION (except EVoucherRedeemLog → EVoucher uses CASCADE)

---

## Summary Statistics

| Metric | Value |
|--------|-------|
| **Total Tables** | 20 |
| **Total Rows** | 12,934 |
| **Total Columns** | 331 |
| **Primary Keys** | 20 |
| **Foreign Keys** | 16 |
| **Unique Constraints** | 13 |
| **Check Constraints** | 28 |
| **Indexes (Total)** | 61 |
| **Soft Delete Enabled** | 16 tables |

---

*End of Complete Schema Reference*
