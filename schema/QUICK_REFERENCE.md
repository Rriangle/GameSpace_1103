# GameSpace MiniGame Area - Quick Reference Card

**Database**: GameSpacedatabase | **Server**: (local)\SQLEXPRESS | **Tables**: 20 | **Records**: ~13k

---

## 🗂️ TABLE QUICK INDEX

| # | Table | Rows | PK | FKs | Description |
|---|-------|------|----|----|-------------|
| 1 | **User_Wallet** | 200 | User_Id | Users | 💰 Point balances |
| 2 | **WalletHistory** | 1,928 | LogID | Users | 📝 Transaction log |
| 3 | **CouponType** | 3 | CouponTypeID | - | 🎟️ Coupon templates |
| 4 | **Coupon** | 4,587 | CouponID | CouponType, Users | 🎫 User coupons (UQ: CouponCode) |
| 5 | **EVoucherType** | 20 | EVoucherTypeID | - | 🎁 E-voucher templates |
| 6 | **EVoucher** | 355 | EVoucherID | EVoucherType, Users | 🎁 User e-vouchers (UQ: EVoucherCode) |
| 7 | **EVoucherToken** | 355 | TokenID | EVoucher | 🔐 QR tokens (UQ: Token) |
| 8 | **EVoucherRedeemLog** | 800 | RedeemID | EVoucher, EVoucherToken, Users | 📋 Scan log |
| 9 | **Pet** | 200 | PetID | Users | 🐾 Virtual pets |
| 10 | **PetSkinColorCostSettings** | 11 | SettingId | ManagerData | 🎨 Skin pricing (UQ: ColorCode) |
| 11 | **PetBackgroundCostSettings** | 11 | SettingId | ManagerData | 🖼️ BG pricing (UQ: BackgroundCode) |
| 12 | **PetLevelRewardSettings** | 25 | SettingId | - | 📈 Level rewards (UQ: LevelRange) |
| 13 | **SignInRule** | 10 | Id | CouponType | ✅ Check-in rules |
| 14 | **UserSignInStats** | 2,400 | LogID | Users | 📅 Check-in log |
| 15 | **MiniGame** | 2,000 | PlayID | Users, Pet | 🎮 Game records |
| 16 | **SystemSettings** | 56 | SettingId | ManagerData | ⚙️ Config KV (UQ: SettingKey) |
| 17 | **Users** | 200 | User_ID | - | 👤 User master (UQ: User_name, User_Account) |
| 18 | **ManagerData** | 102 | Manager_Id | - | 👨‍💼 Admin master (UQ: Manager_Email, Manager_Account) |
| 19 | **ManagerRole** | 102 | Manager_Id + ManagerRole_Id | ManagerData, ManagerRolePermission | 🔗 Role assign |
| 20 | **ManagerRolePermission** | 8 | ManagerRole_Id | - | 🔐 RBAC roles |

---

## 🔗 KEY RELATIONSHIPS

```
Users (200) ─┬─ User_Wallet (200)           💰 1:1 Wallet
             ├─ WalletHistory (1,928)       📝 1:N Transactions
             ├─ Coupon (4,587)              🎫 1:N Coupons
             ├─ EVoucher (355)              🎁 1:N E-vouchers
             ├─ Pet (200)                   🐾 1:1 Pet
             ├─ UserSignInStats (2,400)     ✅ 1:N Check-ins
             └─ MiniGame (2,000)            🎮 1:N Games

CouponType (3) ─── Coupon (4,587)           🎟️ Template → Instances

EVoucherType (20) ─ EVoucher (355) ─┬─ EVoucherToken (355)      🔐 1:1 Token
                                     └─ EVoucherRedeemLog (800) 📋 1:N Scans

Pet (200) ─── MiniGame (2,000)              🐾 Pet plays games

ManagerData (102) ─ ManagerRole (102) ─ ManagerRolePermission (8)  👨‍💼 RBAC
```

---

## 📊 COMMON COLUMNS

### Soft Delete (All 20 Tables)
- `IsDeleted` bit NOT NULL DEFAULT 0
- `DeletedAt` datetime2(7) NULL
- `DeletedBy` int NULL
- `DeleteReason` nvarchar(500) NULL

### Audit Trail (Most Tables)
- `CreatedAt` datetime2(7) NOT NULL DEFAULT sysutcdatetime()
- `UpdatedAt` datetime2(7) NULL
- `UpdatedBy` int NULL FK→ManagerData

---

## 🎨 CODE FORMATS

| Type | Format | Example |
|------|--------|---------|
| **CouponCode** | CPN-YYMM-XXX### | CPN-2509-SQW964 |
| **EVoucherCode** | EV-CATEGORY-XXXX-###### | EV-MOVIE-SA40-350422 |
| **Token** | TKN-XXXXXXXX-#### | TKN-ZON4F9DZ-5993 |
| **OrderID** | ORD-###### | ORD-114898 |
| **BackgroundCode** | BG### | BG001, BG009 |
| **ColorCode** | #RRGGBB | #000000, #FF0000, #0000FF |

---

## 🎯 ENUM VALUES

### WalletHistory.ChangeType
`'Point'`, `'Coupon'`, `'EVoucher'`

### CouponType.DiscountType
`'Amount'`, `'Percent'`

### EVoucherRedeemLog.Status
`'Approved'`, `'Rejected'`, `'Expired'`, `'AlreadyUsed'`, `'Revoked'`

### MiniGame.Difficulty
`'Easy'`, `'Normal'`, `'Hard'`, `'Expert'`

### Users.Account_Status
`'Active'`, `'Locked'`, `'Suspended'`, `'Pending'`

### SystemSettings.ValueType
`'String'`, `'Int'`, `'Decimal'`, `'Boolean'`, `'JSON'`, `'DateTime'`

---

## 💰 POINT ECONOMY

### Earning
- Daily check-in: **10-50** pts (day 1-7, milestones)
- Mini games: **~Score/100** pts
- Pet level-up: **10-50** pts (level-based)

### Spending
- Coupons: **1k-10k** pts
- E-vouchers: **4.2k-36k** pts
- Pet skins: **0-3.5k** pts
- Pet backgrounds: **0-6k** pts

---

## 🔐 RBAC ROLES

| ID | Role | UserStatus | PetRights | Shopping | MiniGame | Permission | GameScore |
|----|------|------------|-----------|----------|----------|------------|-----------|
| 1 | **SuperAdmin** | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 2 | **CS_Agent** | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| 3 | **Manager** | ✓ | ✓ | ✓ | ✓ | ✗ | ✓ |
| 4 | **PetAdmin** | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |
| 5 | **GameAdmin** | ✗ | ✗ | ✗ | ✓ | ✗ | ✓ |

---

## 🐾 PET SYSTEM

### Stats (0-100 range)
- **Hunger**: Decreases over time, restore by feeding
- **Mood**: Affected by games and interactions
- **Stamina**: Used in games, regenerates
- **Cleanliness**: Decreases, clean to restore
- **Health**: Overall wellness (0-100)

### Customization
- **Skin Colors**: 11 options (0-3.5k pts)
- **Backgrounds**: 11 options (0-6k pts)
- **Levels**: 1-50 (exp-based progression)

---

## 🎮 MINI GAMES

### Game Types
WhackAMole, MemoryCard, BubbleShoot, etc.

### Difficulty Levels
Easy (0.8x), Normal (1.0x), Hard (1.2x), Expert (1.5x)

### Scoring
- Points = Score × Difficulty Multiplier / 100
- Pet gains exp based on score
- Pet stats affected (Hunger↓, Mood↑/↓, Stamina↓)

---

## ⚙️ SYSTEM SETTINGS (Examples)

| SettingKey | ValueType | Example |
|------------|-----------|---------|
| MaintenanceMode | Boolean | false |
| MaxLoginAttempts | Int | 5 |
| PointsToRealMoney | Decimal | 0.01 |
| DailyCheckInEnabled | Boolean | true |
| PetMaxLevel | Int | 50 |

---

## 📝 USEFUL QUERIES

### Get user wallet balance
```sql
SELECT u.User_name, w.User_Point
FROM Users u
JOIN User_Wallet w ON u.User_ID = w.User_Id
WHERE u.Account_Status = 'Active' AND w.IsDeleted = 0;
```

### Recent transactions
```sql
SELECT TOP 20 u.User_name, wh.ChangeType, wh.PointsChanged,
       wh.Description, wh.ChangeTime
FROM WalletHistory wh
JOIN Users u ON wh.UserID = u.User_ID
WHERE wh.IsDeleted = 0
ORDER BY wh.ChangeTime DESC;
```

### Active coupons by user
```sql
SELECT u.User_name, ct.Name, c.CouponCode, c.AcquiredTime
FROM Coupon c
JOIN Users u ON c.UserID = u.User_ID
JOIN CouponType ct ON c.CouponTypeID = ct.CouponTypeID
WHERE c.IsUsed = 0 AND c.IsDeleted = 0;
```

### Pet stats summary
```sql
SELECT u.User_name, p.PetName, p.Level, p.Experience,
       p.Hunger, p.Mood, p.Stamina
FROM Pet p
JOIN Users u ON p.UserID = u.User_ID
WHERE p.IsDeleted = 0
ORDER BY p.Level DESC;
```

### Top game scores
```sql
SELECT TOP 10 u.User_name, mg.GameType, mg.Score,
       mg.Difficulty, mg.PlayedAt
FROM MiniGame mg
JOIN Users u ON mg.UserID = u.User_ID
WHERE mg.IsDeleted = 0 AND mg.IsCompleted = 1
ORDER BY mg.Score DESC;
```

---

## 🔍 INDEXES

### High-Performance Indexes
- **WalletHistory**: IX_WalletHistory_UserID, IX_WalletHistory_ChangeTime
- **MiniGame**: IX_MiniGame_UserID, IX_MiniGame_PlayedAt, IX_MiniGame_PetID
- **UserSignInStats**: IX_UserSignInStats_UserID, IX_UserSignInStats_SignInDate
- **Coupon**: IX_Coupon_UserID
- **EVoucher**: IX_EVoucher_UserID

### Unique Indexes
- UQ_Coupon_Code, UQ_EVoucher_Code, UQ_EVoucherToken_Token
- UQ_Users_UserName, UQ_Users_UserAccount
- UQ_ManagerData_Email, UQ_ManagerData_Account
- UQ_SystemSettings_Key

---

## 🚨 DATA VALIDATION

### Check Constraints
```sql
-- Pet stats must be 0-100
CHK_Pet_Hunger: Hunger BETWEEN 0 AND 100
CHK_Pet_Mood: Mood BETWEEN 0 AND 100

-- Valid date ranges
CHK_CouponType_ValidDates: ValidTo >= ValidFrom

-- Enum validation
CHK_WalletHistory_ChangeType: ChangeType IN ('Point','Coupon','EVoucher')
CHK_MiniGame_Difficulty: Difficulty IN ('Easy','Normal','Hard','Expert')
```

---

## 📞 CONNECTION

```powershell
# sqlcmd
sqlcmd -S "(local)\SQLEXPRESS" -d GameSpacedatabase -E

# Connection string
Server=(local)\SQLEXPRESS;Database=GameSpacedatabase;Trusted_Connection=True;TrustServerCertificate=True;
```

---

**Quick Reference v1.0** | Generated 2025-10-31 | GameSpace MiniGame Area
