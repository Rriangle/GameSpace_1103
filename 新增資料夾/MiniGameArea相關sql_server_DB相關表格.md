---
**更新記錄**:
- 2025-11-03: 更新驗證日期，確認20張表與資料庫一致，新增SystemSettings配置説明
- 2025-10-28: 驗證所有表格結構與資料庫保持一致，確認20張表完整存在
- 2025-10-27: 驗證日期更新，確認表格清單與實際資料庫一致

---

# MiniGame Area 相關表格

**最後驗證日期**: 2025-11-03
**資料庫伺服器**: DESKTOP-8HQIS1S\SQLEXPRESS
**總表數**: 20 張（16 張主要表格 + 4 張關聯表格）

## MiniGame Area 主要表格 (16 張)

- `dbo.Coupon` - 優惠券實例
- `dbo.CouponType` - 優惠券類型定義
- `dbo.EVoucher` - 電子禮券實例
- `dbo.EVoucherRedeemLog` - 電子禮券核銷記錄
- `dbo.EVoucherToken` - 電子禮券核銷憑證
- `dbo.EVoucherType` - 電子禮券類型定義
- `dbo.MiniGame` - 小遊戲記錄
- `dbo.Pet` - 寵物系統資料
- `dbo.PetBackgroundCostSettings` - 寵物背景價格設定 ✨ **(2025-10-20 新增)**
- `dbo.PetLevelRewardSettings` - 寵物升級獎勵規則 ✨ **(2025-10-20 新增)**
- `dbo.PetSkinColorCostSettings` - 寵物膚色價格設定 ✨ **(2025-10-20 新增)**
- `dbo.SignInRule` - 簽到規則設定
- `dbo.SystemSettings` - 系統設定
- `dbo.User_Wallet` - 會員錢包
- `dbo.UserSignInStats` - 簽到統計記錄
- `dbo.WalletHistory` - 錢包異動歷史

## 使用者 / 權限 相關表格 (4 張)

這些表格與 MiniGame Area 有 FK 關聯，用於管理員權限和使用者資料：

- `dbo.ManagerData` - 管理員基本資料
- `dbo.ManagerRole` - 管理員角色分配
- `dbo.ManagerRolePermission` - 角色權限定義
- `dbo.Users` - 使用者基本資料

---

**完整結構文件**: 請參閱 `MiniGame_Area_資料庫完整結構文件_2025-10-21.md`

---

## 重要更新 (2025-11-03)

### SystemSettings 表的核心地位

**SystemSettings** 表現已成為 MiniGame Area 的配置中心：
- **56 個配置項** 動態管理所有業務規則
- **36 個規則** 100% 從此表讀取
- **後台可調整** 無需重啟應用即可修改配置
- **審計追蹤** 記錄所有配置變更

### 配置分類

**Game 類別 (24 個):**
- 遊戲關卡設定 (Level 1-3)
- 遊戲結果影響 (Win/Lose)
- 每日限制

**Pet 類別 (17 個):**
- 互動效果 (Feed/Bath/Coax/Rest)
- 每日衰減 (Hunger/Mood/Stamina/Cleanliness/Health)
- 升級公式 (JSON)
- 換色/背景成本

**SignIn 類別 (11 個):**
- 平日/假日簽到獎勵
- 連續簽到獎勵
- 全勤獎勵

**Wallet/Coupon/EVoucher 類別 (4 個):**
- 初始點數、上限
- 優惠券/電子券有效期

### 相關服務

**SystemSettingsService:**
- 統一配置讀取介面
- 30 分鐘快取機制
- 支援 Int, String, Bool, Decimal, JSON 類型

**PetDailyDecayBackgroundService:**
- 每日 UTC 00:00 自動執行
- 從 SystemSettings 讀取衰減配置
- 對所有寵物應用衰減
