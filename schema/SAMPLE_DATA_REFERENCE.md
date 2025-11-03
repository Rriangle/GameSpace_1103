# GameSpace MiniGame Area - Sample Data Reference

**Database**: GameSpacedatabase
**Extraction Date**: 2025-10-31
**Purpose**: Quick reference for understanding data patterns

---

## 📊 SAMPLE DATA OVERVIEW

### 1. User_Wallet (200 rows total)
Current point balances for users.

```
User_Id | User_Point | IsDeleted
--------|------------|----------
10000001| 60,030     | 0
10000002| 21,666     | 0
10000003| 93,043     | 0
```

**Pattern**: Users have varying point balances. All active (IsDeleted=0).

---

### 2. WalletHistory (1,928 rows total)
Transaction log showing point changes, coupon issuance, voucher redemptions.

```
LogID | UserID   | ChangeType | PointsChanged | ItemCode           | Description
------|----------|------------|---------------|--------------------|--------------------------
1928  | 10000200 | Point      | +107          | NULL               | 贈送積分點數
1927  | 10000200 | Point      | +120          | ORD-114898         | 訂單退貨返還積分點數
1926  | 10000200 | Coupon     | 0             | CPN-2409-FTH318    | 贈送優惠券碼
1921  | 10000200 | Point      | -2000         | CPN-2409-FTH318    | 積分點數兌換優惠券碼
1920  | 10000199 | Point      | -30000        | EV-MOVIE-H1YT...   | 積分點數兌換電子禮券
```

**Pattern**: Tracks all point additions (+), deductions (-), coupon grants, and e-voucher redemptions.

---

### 3. CouponType (3 rows total)
Coupon templates with discount rules.

```
ID | Name          | DiscountType | DiscountValue | MinSpend | PointsCost
---|---------------|--------------|---------------|----------|------------
1  | 免費折扣      | Amount       | NULL          | NULL     | 10,000
2  | 限時85折      | Percent      | 0.15          | 1,500    | 1,000
3  | 滿$500折$50   | Amount       | 50.00         | 500      | 5,000
```

**Pattern**:
- Type 1: Free coupon (10k points)
- Type 2: 15% off with $1,500 min spend (1k points)
- Type 3: $50 off when spending $500+ (5k points)

---

### 4. Coupon (4,587 rows total)
Individual coupon instances owned by users.

```
CouponID | CouponCode      | CouponTypeID | UserID   | IsUsed | AcquiredTime
---------|-----------------|--------------|----------|--------|-------------------------
9422     | CPN-2509-SQW964 | 1            | 10000106 | 0      | 2025-09-05 18:34:01
9421     | CPN-2508-VDB651 | 3            | 10000063 | 0      | 2023-05-05 23:13:41
9420     | CPN-2508-KKL322 | 1            | 10000044 | 0      | 2024-04-25 07:16:47
```

**Pattern**: Format `CPN-YYMM-XXX###`. Most unused (IsUsed=0).

---

### 5. EVoucherType (20 rows total)
E-voucher templates (gift cards, meal vouchers, etc.).

```
ID | Name                        | ValueAmount | PointsCost | TotalAvailable
---|-----------------------------|-----------:|------------|---------------
1  | 7-11禮券$100                | 100        | 10,000     | 468
2  | 7-11禮券$200                | 200        | 20,000     | 437
7  | 威秀影城電影票              | 360        | 36,000     | 356
10 | 路易莎大杯美式咖啡          | 78         | 7,800      | 296
16 | Mister Donut甜甜圈(一入)    | 42         | 4,200      | 361
```

**Pattern**: Convenience store vouchers, movie tickets, food/beverage items. Stock tracked.

---

### 6. EVoucher (355 rows total)
Individual e-voucher instances.

```
ID  | EVoucherCode            | EVoucherTypeID | UserID   | IsUsed | AcquiredTime        | UsedTime
----|-------------------------|----------------|----------|--------|---------------------|--------------------
355 | EV-MOVIE-SA40-350422    | 12             | 10000200 | 1      | 2023-12-12 14:01:30 | 2025-07-28 17:32:54
354 | EV-COFFEE-VUPB-736511   | 10             | 10000200 | 0      | 2023-08-09 01:09:58 | NULL
353 | EV-COFFEE-GI35-816947   | 20             | 10000200 | 1      | 2024-04-14 05:15:29 | 2024-04-30 01:15:26
```

**Pattern**: Format `EV-CATEGORY-XXXX-######`. Tracks acquisition and usage time.

---

### 7. EVoucherToken (355 rows total)
Redemption tokens (QR codes) for e-vouchers.

```
TokenID | EVoucherID | Token                | ExpiresAt           | IsRevoked
--------|------------|----------------------|---------------------|----------
355     | 355        | TKN-ZON4F9DZ-5993    | 2024-05-02 07:04:29 | 0
354     | 354        | TKN-3KN6GFN3-7672    | 2025-07-08 05:37:11 | 0
343     | 343        | TKN-9BRIZKEI-2206    | 2023-06-01 04:41:18 | 1
```

**Pattern**: Format `TKN-XXXXXXXX-####`. One token per voucher. Can be revoked.

---

### 8. EVoucherRedeemLog (800 rows total)
Logs every voucher scan attempt.

```
RedeemID | EVoucherID | TokenID | UserID   | ScannedAt           | Status
---------|------------|---------|----------|---------------------|----------
800      | 252        | 252     | 10000109 | 2023-08-27 02:37:03 | Revoked
799      | 54         | 54      | 10000117 | 2024-03-30 12:22:29 | Rejected
798      | 51         | 51      | 10000027 | 2025-04-18 15:52:43 | Approved
797      | 103        | 103     | 10000134 | 2024-07-19 13:24:59 | Revoked
796      | 110        | 110     | 10000181 | 2024-09-04 21:37:42 | AlreadyUsed
```

**Status Values**: Approved, Rejected, Expired, AlreadyUsed, Revoked

---

### 9. Pet (200 rows total)
Virtual pet data with stats and customization.

```
PetID | UserID   | PetName | Level | Experience | Hunger | Mood | Stamina | SkinColor | BackgroundColor
------|----------|---------|-------|------------|--------|------|---------|-----------|----------------
200   | 10000200 | 多多??  | 44    | 2,734      | 85     | 10   | 63      | #000000   | BG001
199   | 10000199 | 黑喵??  | 12    | 1,495      | 58     | 80   | 36      | #0000FF   | BG009
198   | 10000198 | 寶貝    | 35    | 4,397      | 80     | 69   | 58      | #000000   | BG007
```

**Pattern**:
- Stats range 0-100 (Hunger, Mood, Stamina, Cleanliness, Health)
- SkinColor in hex (#RRGGBB)
- BackgroundColor as codes (BG001-BG010)

---

### 10. PetSkinColorCostSettings (11 rows)
Pricing for pet skin colors.

```
SettingId | ColorCode | ColorName | PointCost | UnlockLevel | IsDefault
----------|-----------|-----------|-----------|-------------|----------
1         | #000000   | 黑色      | 0         | 1           | 1
2         | #FFFFFF   | 白色      | 0         | 1           | 0
3         | #FF0000   | 紅色      | 0         | 1           | 0
4         | #0000FF   | 藍色      | 2,000     | 5           | 0
5         | #800080   | 紫色      | 3,500     | 10          | 0
6         | #FFA500   | 橘色      | 2,000     | 8           | 0
```

**Pattern**: Free colors (0 points) available at level 1. Premium colors cost 2k-3.5k points.

---

### 11. PetBackgroundCostSettings (11 rows)
Pricing for pet backgrounds.

```
SettingId | BackgroundCode | BackgroundName | PointCost | UnlockLevel | IsDefault
----------|----------------|----------------|-----------|-------------|----------
1         | BG001          | 預設背景       | 0         | 1           | 1
2         | BG002          | 星空背景       | 0         | 1           | 0
3         | BG003          | 森林背景       | 0         | 5           | 0
4         | BG004          | 海洋背景       | 2,000     | 10          | 0
5         | BG005          | 城市背景       | 2,500     | 15          | 0
```

**Pattern**: Similar to skin colors. Free backgrounds + premium unlockables.

---

### 12. PetLevelRewardSettings (25 rows)
Rewards for pet level-ups.

```
SettingId | LevelRangeStart | LevelRangeEnd | RewardPoints | BonusPoints
----------|-----------------|---------------|--------------|------------
1         | 1               | 5             | 10           | 0
2         | 6               | 10            | 20           | 0
3         | 11              | 15            | 30           | 5
4         | 16              | 20            | 40           | 10
5         | 21              | 25            | 50           | 15
```

**Pattern**: Higher levels = more points. Bonus points kick in after level 10.

---

### 13. SignInRule (10 rows)
Daily check-in reward rules.

```
Id | DayNumber | PointReward | BonusMultiplier | IsMilestone | CouponTypeCode
---|-----------|-------------|-----------------|-------------|---------------
1  | 1         | 10          | 1.00            | 0           | NULL
2  | 2         | 10          | 1.00            | 0           | NULL
3  | 3         | 10          | 1.00            | 0           | NULL
7  | 7         | 25          | 1.00            | 1           | 限時85折
14 | 14        | 50          | 1.50            | 1           | 限時85折
```

**Pattern**: Days 1-6 = 10 points. Day 7 = 25 points + coupon (milestone).

---

### 14. UserSignInStats (2,400 rows)
User check-in records.

```
LogID | UserID   | SignInDate | PointsGained | CouponGained | CurrentStreak | LongestStreak
------|----------|------------|--------------|--------------|---------------|---------------
2400  | 10000200 | 2025-10-30 | 10           | NULL         | 15            | 45
2399  | 10000199 | 2025-10-30 | 10           | NULL         | 8             | 20
2398  | 10000198 | 2025-10-30 | 25           | CPN-...      | 7             | 30
```

**Pattern**: Tracks daily check-ins, streaks, and rewards earned.

---

### 15. MiniGame (2,000 rows)
Game play records.

```
PlayID | UserID   | PetID | GameType    | Score  | PointsEarned | Difficulty | PetExperienceGained
-------|----------|-------|-------------|--------|--------------|------------|--------------------
2000   | 10000200 | 200   | WhackAMole  | 15,230 | 152          | Normal     | 50
1999   | 10000199 | 199   | MemoryCard  | 8,450  | 84           | Hard       | 80
1998   | 10000198 | 198   | BubbleShoot | 22,100 | 221          | Normal     | 60
```

**Pattern**:
- GameType: WhackAMole, MemoryCard, BubbleShoot, etc.
- Difficulty: Easy, Normal, Hard, Expert
- Points ~= Score / 100

---

### 16. SystemSettings (56 rows)
System-wide configuration.

```
SettingId | SettingKey              | SettingValue | ValueType | Category
----------|-------------------------|--------------|-----------|----------
1         | MaintenanceMode         | false        | Boolean   | System
2         | MaxLoginAttempts        | 5            | Int       | Security
3         | PointsToRealMoney       | 0.01         | Decimal   | Economy
4         | DailyCheckInEnabled     | true         | Boolean   | Features
5         | PetMaxLevel             | 50           | Int       | Pet
```

**Pattern**: Key-value store for feature flags, limits, and business rules.

---

### 17. Users (200 rows)
User master table.

```
User_ID  | User_name | User_Account     | User_Email            | Registration_Date   | Account_Status
---------|-----------|------------------|-----------------------|---------------------|---------------
10000001 | Alice     | alice123         | alice@example.com     | 2023-01-15 08:30:00 | Active
10000002 | Bob       | bob_gamer        | bob@example.com       | 2023-02-20 14:45:00 | Active
10000003 | Charlie   | charlie_chen     | charlie@example.com   | 2023-03-10 10:20:00 | Active
```

**Pattern**: User_ID starts at 10000001. All currently Active.

---

### 18. ManagerData (102 rows)
Admin accounts.

```
Manager_Id | Manager_Name | Manager_Account | Manager_Email         | IsLocked | CreatedAt
-----------|--------------|-----------------|------------------------|----------|-------------------------
1          | Admin        | admin001        | admin@gamespace.com    | 0        | 2023-01-01 00:00:00
2          | CS_Agent1    | cs_agent001     | cs1@gamespace.com      | 0        | 2023-01-05 09:00:00
3          | CS_Agent2    | cs_agent002     | cs2@gamespace.com      | 0        | 2023-01-05 09:15:00
```

**Pattern**: Admin and CS agents. None currently locked.

---

### 19. ManagerRole (102 rows)
Admin role assignments (Many-to-Many).

```
Manager_Id | ManagerRole_Id
-----------|----------------
1          | 1              (Admin = SuperAdmin role)
2          | 2              (CS_Agent1 = CS role)
3          | 2              (CS_Agent2 = CS role)
4          | 3              (Manager = Manager role)
```

**Pattern**: One admin can have multiple roles. Role IDs reference ManagerRolePermission.

---

### 20. ManagerRolePermission (8 rows)
Role permission definitions.

```
ManagerRole_Id | role_name     | UserStatusMgmt | PetRightsMgmt | ShoppingPermMgmt | MiniGameMgmt | PermissionMgmt | GameScoreMgmt
---------------|---------------|----------------|---------------|------------------|--------------|----------------|---------------
1              | SuperAdmin    | 1              | 1             | 1                | 1            | 1              | 1
2              | CS_Agent      | 1              | 0             | 1                | 0            | 0              | 0
3              | Manager       | 1              | 1             | 1                | 1            | 0              | 1
4              | PetAdmin      | 0              | 1             | 0                | 0            | 0              | 0
5              | GameAdmin     | 0              | 0             | 0                | 1            | 0              | 1
```

**Pattern**:
- SuperAdmin: All permissions
- CS_Agent: User + Shopping only
- Manager: Most permissions except Permission_Management
- Specialized admins: Pet or Game focused

---

## 🎯 KEY INSIGHTS

### User Journey
1. **Registration** → Users table (User_ID, Account_Status: Active)
2. **Wallet Creation** → User_Wallet (initial 0 points)
3. **Daily Check-In** → UserSignInStats (earn points, track streaks)
4. **Pet Adoption** → Pet (create virtual pet, start at level 1)
5. **Play Games** → MiniGame (earn points, pet gains exp)
6. **Redeem Rewards** → Coupon/EVoucher (spend points)
7. **Use Vouchers** → EVoucherToken, EVoucherRedeemLog

### Economy Flow
- **Earn Points**: Daily check-in (10-50), Games (score/100), Pet level-up (10-50)
- **Spend Points**: Coupons (1k-10k), E-vouchers (4k-36k), Pet customization (2k-4.5k)
- **Transaction Log**: WalletHistory records all changes

### Gamification
- **Pet System**: Level 1-50, 5 stats (Hunger/Mood/Stamina/Cleanliness/Health), Customization
- **Mini Games**: Multiple game types, difficulty levels, score → points conversion
- **Check-In Streaks**: Daily rewards, milestone bonuses (day 7, 14)

### Admin Control
- **RBAC**: 8 roles, 6 permission types
- **Audit Trail**: All changes tracked with UpdatedBy → ManagerData
- **Soft Delete**: Full history preserved, no hard deletes

---

**End of Sample Data Reference**
*Generated: 2025-10-31*
