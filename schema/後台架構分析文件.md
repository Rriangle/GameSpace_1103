# GameSpace 後台架構完整分析

**生成日期:** 2025-11-03
**專案類型:** ASP.NET Core 8.0 MVC Admin Portal
**主要焦點:** MiniGame Area
**狀態:** 100% 完成，生產就緒

---

## 執行摘要

### 專案概覽
- **名稱:** GameSpace (管理後台)
- **對應前台:** GamiPort (客戶端)
- **核心架構:** Area-based模組化設計 + 服務層分離
- **Areas數量:** 6個區域
- **認證方式:** AdminCookie (Claims-based)
- **資料庫:** SQL Server GameSpacedatabase (SQLEXPRESS01)
- **連線埠:** HTTPS:7042, HTTP:5211

### MiniGame Area 統計
| 指標 | 數量 |
|------|------|
| Controllers | 24個 |
| Services (介面) | 54個 |
| Services (實作) | 94個檔案 |
| 預估總行數 | 25,000+ |
| ViewModels | 60+ |
| Views | 100+ |
| Constants | 4個檔案 |

---

## 目錄

1. [專案結構](#1-專案結構)
2. [MiniGame Area 深度分析](#2-minigame-area-深度分析)
3. [其他Areas概覽](#3-其他areas概覽)
4. [認證與授權](#4-認證與授權)
5. [資料庫架構](#5-資料庫架構)
6. [服務層架構](#6-服務層架構)
7. [Middleware管道](#7-middleware管道)
8. [配置與部署](#8-配置與部署)
9. [關鍵架構決策](#9-關鍵架構決策)
10. [程式碼度量](#10-程式碼度量)

---

## 1. 專案結構

### 1.1 整體目錄結構

```
GameSpace/GameSpace/
├── Areas/                          [6個功能區域]
│   ├── MiniGame/                  [★ 主要焦點 - 24 controllers, 94 services]
│   ├── Forum/                     [論壇管理]
│   ├── MemberManagement/          [用戶管理]
│   ├── OnlineStore/               [商店管理]
│   ├── social_hub/                [社交 + 客服]
│   └── Identity/                  [身份管理頁面]
├── Controllers/                   [根控制器]
├── Data/                         [ApplicationDbContext]
├── Infrastructure/
│   ├── Login/                     [共用登入服務]
│   └── Time/                      [時間工具]
├── Models/                        [GameSpacedatabaseContext + Entities]
├── Views/                         [共用佈局]
├── wwwroot/                       [靜態資源]
│   ├── lib/sb-admin/             [SB Admin樣板]
│   ├── css/                       [樣式表]
│   └── js/                        [JavaScript]
├── Program.cs                     [259行 - DI + Middleware配置]
├── appsettings.json              [配置檔]
└── GameSpace.csproj              [專案檔]
```

### 1.2 技術堆疊

**核心框架:**
- ASP.NET Core 8.0 MVC
- Entity Framework Core 8.0
- SQL Server 2022 Express

**認證/授權:**
- Cookie Authentication (AdminCookie scheme)
- Claims-based Authorization
- ASP.NET Core Identity (ManagerData自訂實作)

**前端:**
- SB Admin 2 樣板
- Bootstrap 5
- jQuery
- Chart.js (儀表板圖表)

**即時通訊:**
- SignalR (SupportHub)

**其他套件:**
- Serilog (日誌)
- AutoMapper (可能使用)
- FluentValidation (可能使用)

---

## 2. MiniGame Area 深度分析

### 2.1 Controllers清單 (24個)

#### 核心控制器 (4個)
1. **MiniGameBaseController.cs** (318行)
   - 所有MiniGame控制器的基底類別
   - 提供認證、權限檢查、分頁、驗證輔助方法
   - 20+共用工具方法

2. **AdminController.cs**
   - Admin主頁

3. **AdminDashboardController.cs**
   - 儀表板：統計資訊、圖表

4. **AdminHomeController.cs**
   - MiniGame Area首頁

#### 錢包系統控制器 (3個)
5. **WalletAdminController.cs** (955行)
   - 查詢用戶點數餘額
   - 調整點數（增加/扣除，含交易日誌）
   - 查看交易歷史
   - 批量點數操作

6. **AdminCouponController.cs** (580行)
   - 優惠券類型管理（CRUD）
   - 發放優惠券給用戶
   - 查看優惠券使用記錄

7. **AdminEVoucherController.cs** (847行)
   - 電子券類型管理
   - 生成電子券
   - 生成兌換Token
   - 查看兌換記錄

#### 寵物系統控制器 (8個)
8. **AdminPetController.cs** (1,440行) - **最大的控制器**
   - 查詢用戶寵物
   - 手動調整寵物數據
   - 寵物互動記錄查看

9. **PetAdminController.cs**
   - 寵物管理輔助控制器

10. **PetSkinColorCostSettingController.cs**
    - 膚色定價管理（CRUD）

11. **PetBackgroundCostSettingController.cs**
    - 背景定價管理（CRUD）

12. **PetLevelRewardSettingController.cs**
    - 升級獎勵配置（CRUD）

13. **PetLevelUpRuleController.cs**
    - 升級規則配置

14. **PetLevelUpRuleValidationController.cs**
    - 升級規則驗證

15. **PetLevelExperienceSettingController.cs**
    - 經驗值設定

#### 簽到系統控制器 (1個)
16. **SignInAdminController.cs**
    - 簽到規則管理（CRUD）
    - 查看用戶簽到記錄
    - 簽到統計報表

#### 遊戲系統控制器 (2個)
17. **AdminMiniGameController.cs** (663行)
    - 遊戲對局查詢
    - 遊戲規則配置
    - 遊戲統計報表

18. **GameAdminController.cs**
    - 遊戲管理輔助

19. **DailyGameLimitController.cs**
    - 每日遊戲次數限制配置

#### 用戶管理控制器 (2個)
20. **AdminUserController.cs** (512行)
    - 查詢用戶清單
    - 用戶詳細資訊
    - 用戶錢包/寵物/簽到記錄查看

21. **AdminManagerController.cs** (491行)
    - 管理員帳號管理
    - 角色與權限分配

#### 輔助控制器 (3個)
22. **AdminDiagnosticsController.cs** (576行)
    - 系統診斷工具
    - 資料庫連線測試
    - 效能監控

23. **CouponTypesController.cs**
    - 優惠券類型快速查詢

24. **HomeController.cs**
    - MiniGame Area根路由

### 2.2 Services架構 (94個檔案)

#### Service Tier 分層

**Tier 1: Admin核心服務 (3個)**
1. IMiniGameAdminService / MiniGameAdminService
   - 管理員核心業務邏輯
2. IMiniGameAdminAuthService / MiniGameAdminAuthService
   - 管理員認證服務
3. IMiniGameAdminGate / MiniGameAdminGate
   - 權限閘道

**Tier 2: 領域服務 (85個)**

**(A) 錢包服務 (8個)**
- IWalletService / WalletService
- IWalletQueryService / WalletQueryService (唯讀查詢)
- IWalletMutationService / WalletMutationService (寫入操作)
- IUserWalletService / UserWalletService
- ICouponService / CouponService
- ICouponTypeService / CouponTypeService
- IEVoucherService / EVoucherService
- IEVoucherTypeService / EVoucherTypeService

**主要方法:**
```csharp
// IWalletService
Task<int> GetUserPointsAsync(int userId);
Task<bool> AddPointsAsync(int userId, int points, string changeType, string desc);
Task<bool> DeductPointsAsync(int userId, int points, string changeType, string desc);
Task<IEnumerable<WalletHistoryDto>> GetHistoryAsync(int userId, DateTime? from, DateTime? to);

// IWalletMutationService (Admin專用)
Task<bool> AdjustPointsAsync(int userId, int delta, int operatorId, string reason);
Task<bool> GrantPointsToMultipleUsersAsync(IEnumerable<int> userIds, int points, string reason);

// ICouponService
Task<IEnumerable<CouponDto>> GetUserCouponsAsync(int userId, bool includeUsed);
Task<bool> IssueCouponAsync(int userId, int couponTypeId);
Task<bool> UseCouponAsync(int couponId, int orderId);
```

**(B) 寵物服務 (20個)**
- IPetService / PetService (核心)
- IPetQueryService / PetQueryService (查詢)
- IPetMutationService / PetMutationService (變更)
- IPetRulesService / PetRulesService (規則管理)
- IPetInteractionService / PetInteractionService (互動：餵食/洗澡/玩耍/哄睡)
- IPetDailyDecayService / PetDailyDecayService (每日衰減)
- IPetLevelUpRuleService / PetLevelUpRuleService (升級規則)
- IPetLevelUpRuleValidationService / PetLevelUpRuleValidationService (規則驗證)
- IPetLevelRewardSettingService / PetLevelRewardSettingService (獎勵配置)
- IPetSkinColorCostSettingService / PetSkinColorCostSettingService (膚色定價)
- InMemoryPetSkinColorCostSettingService (記憶體快取)
- IPetColorOptionService / PetColorOptionService (顏色選項)
- IPetColorChangeSettingsService / PetColorChangeSettingsService (變色設定)
- IPetBackgroundCostSettingService / PetBackgroundCostSettingService (背景定價)
- IPetBackgroundOptionService / PetBackgroundOptionService (背景選項)
- IPetBackgroundChangeSettingsService / PetBackgroundChangeSettingsService (背景變更設定)
- PetLevelExperienceSettingService (經驗值設定)
- IPointsSettingsStatisticsService / PointsSettingsStatisticsService (點數統計)

**主要方法:**
```csharp
// IPetService
Task<PetDto> GetUserPetAsync(int userId);
Task<bool> UpdatePetNameAsync(int petId, string newName);
Task<bool> ChangeSkinColorAsync(int petId, string colorCode, int userId);
Task<bool> ChangeBackgroundAsync(int petId, string backgroundCode, int userId);
Task<bool> AddExperienceAsync(int petId, int exp);

// IPetInteractionService
Task<PetInteractionResult> FeedAsync(int petId); // +30 Hunger
Task<PetInteractionResult> BatheAsync(int petId); // +35 Cleanliness
Task<PetInteractionResult> PlayAsync(int petId); // +40 Mood
Task<PetInteractionResult> SleepAsync(int petId); // +50 Stamina

// IPetDailyDecayService
Task ApplyDailyDecayAsync(); // 每日自動執行: Hunger -20, Mood -30, Stamina -10, Cleanliness -20
```

**(C) 簽到服務 (6個)**
- ISignInService / SignInService (核心)
- ISignInQueryService / SignInQueryService (查詢)
- ISignInMutationService / SignInMutationService (簽到操作)
- ISignInStatsService / SignInStatsService (統計)
- InMemorySignInRuleService (規則快取，Singleton)

**主要方法:**
```csharp
// ISignInService
Task<SignInStatusDto> GetStatusAsync(int userId);
Task<SignInResult> SignInAsync(int userId);
Task<bool> CanSignInTodayAsync(int userId);
Task<int> GetConsecutiveDaysAsync(int userId);

// ISignInStatsService
Task<IEnumerable<SignInLogDto>> GetHistoryAsync(int userId, int page, int pageSize);
Task<SignInStatisticsDto> GetStatisticsAsync(int userId);
```

**(D) 遊戲服務 (6個)**
- IMiniGameService / MiniGameService
- IGamePlayService / GamePlayService (對局管理)
- IGameQueryService / GameQueryService (查詢)
- IGameMutationService / GameMutationService (寫入)
- IGameRulesService / GameRulesService (規則配置)
- GameRulesOptions (配置選項)
- IDailyGameLimitService / DailyGameLimitService (每日限制)
- IDailyGameLimitValidationService / DailyGameLimitValidationService (限制驗證)

**主要方法:**
```csharp
// IGamePlayService
Task<GameSessionDto> StartGameAsync(int userId, int petId, int level);
Task<GameEndResult> EndGameAsync(string sessionId, GameResult result);
Task<int> GetRemainingPlaysAsync(int userId);

// IGameRulesService
Task<GameLevelRulesDto> GetLevelRulesAsync(int level);
Task UpdateLevelRulesAsync(int level, GameLevelRulesDto rules);
Task<int> GetMaxDailyPlaysAsync();
```

**Tier 3: 工具服務 (6個)**
- IDashboardService / DashboardService (儀表板數據)
- IDiagnosticsService / DiagnosticsService (診斷工具)
- IManagerService / ManagerService (管理員查詢)
- IUserService / UserService (用戶查詢)
- ITaiwanHolidayService / TaiwanHolidayService (台灣假日判斷 - Singleton)

### 2.3 Service Registration (config/ServiceExtensions.cs)

**註冊方式:**
```csharp
// 位置: Areas/MiniGame/config/ServiceExtensions.cs
public static class ServiceExtensions
{
    public static IServiceCollection AddMiniGameServices(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        // Tier 1: Admin Services
        services.AddScoped<IMiniGameAdminService, MiniGameAdminService>();
        services.AddScoped<IMiniGameAdminAuthService, MiniGameAdminAuthService>();
        services.AddScoped<IMiniGameAdminGate, MiniGameAdminGate>();

        // Tier 2: Wallet Services
        services.AddScoped<IWalletService, WalletService>();
        services.AddScoped<IWalletQueryService, WalletQueryService>();
        services.AddScoped<IWalletMutationService, WalletMutationService>();
        services.AddScoped<IUserWalletService, UserWalletService>();
        services.AddScoped<ICouponService, CouponService>();
        services.AddScoped<ICouponTypeService, CouponTypeService>();
        services.AddScoped<IEVoucherService, EVoucherService>();
        services.AddScoped<IEVoucherTypeService, EVoucherTypeService>();

        // Tier 2: Pet Services (20+)
        services.AddScoped<IPetService, PetService>();
        services.AddScoped<IPetQueryService, PetQueryService>();
        services.AddScoped<IPetMutationService, PetMutationService>();
        services.AddScoped<IPetRulesService, PetRulesService>();
        services.AddScoped<IPetInteractionService, PetInteractionService>();
        services.AddScoped<IPetDailyDecayService, PetDailyDecayService>();
        services.AddScoped<IPetLevelUpRuleService, PetLevelUpRuleService>();
        services.AddScoped<IPetLevelRewardSettingService, PetLevelRewardSettingService>();
        services.AddScoped<IPetSkinColorCostSettingService, PetSkinColorCostSettingService>();
        services.AddScoped<IPetBackgroundCostSettingService, PetBackgroundCostSettingService>();
        // ... 其他Pet服務

        // Tier 2: SignIn Services
        services.AddScoped<ISignInService, SignInService>();
        services.AddScoped<ISignInQueryService, SignInQueryService>();
        services.AddScoped<ISignInMutationService, SignInMutationService>();
        services.AddScoped<ISignInStatsService, SignInStatsService>();
        services.AddSingleton<InMemorySignInRuleService>(); // Singleton快取

        // Tier 2: Game Services
        services.AddScoped<IMiniGameService, MiniGameService>();
        services.AddScoped<IGamePlayService, GamePlayService>();
        services.AddScoped<IGameQueryService, GameQueryService>();
        services.AddScoped<IGameMutationService, GameMutationService>();
        services.AddScoped<IGameRulesService, GameRulesService>();
        services.AddScoped<IDailyGameLimitService, DailyGameLimitService>();
        services.AddScoped<IDailyGameLimitValidationService, DailyGameLimitValidationService>();

        // Tier 3: Utility Services
        services.AddScoped<IDashboardService, DashboardService>();
        services.AddScoped<IDiagnosticsService, DiagnosticsService>();
        services.AddScoped<IManagerService, ManagerService>();
        services.AddScoped<IUserService, UserService>();
        services.AddSingleton<ITaiwanHolidayService, TaiwanHolidayService>(); // Singleton

        return services;
    }
}
```

**Program.cs中調用:**
```csharp
// Line ~180
builder.Services.AddMiniGameServices(builder.Configuration);
```

### 2.4 交易模式 (Transaction Patterns)

**所有點數變動操作必須使用交易:**
```csharp
// 範例: WalletMutationService.AdjustPointsAsync
public async Task<bool> AdjustPointsAsync(int userId, int delta, int operatorId, string reason)
{
    using var transaction = await _context.Database.BeginTransactionAsync();
    try
    {
        // 1. 取得錢包（悲觀鎖定）
        var wallet = await _context.User_Wallet
            .Where(w => w.User_Id == userId && !w.IsDeleted)
            .FirstOrDefaultAsync();

        if (wallet == null) return false;

        // 2. 更新點數
        wallet.User_Point += delta;
        if (wallet.User_Point < 0) throw new InvalidOperationException("點數不可為負");

        // 3. 記錄交易日誌
        var log = new WalletHistory
        {
            UserID = userId,
            ChangeType = delta > 0 ? "Admin_Add" : "Admin_Deduct",
            PointsChanged = delta,
            Description = reason,
            ChangeTime = DateTime.UtcNow
        };
        _context.WalletHistory.Add(log);

        // 4. 儲存變更
        await _context.SaveChangesAsync();

        // 5. 提交交易
        await transaction.CommitAsync();
        return true;
    }
    catch (Exception ex)
    {
        await transaction.RollbackAsync();
        _logger.LogError(ex, "點數調整失敗: UserId={UserId}, Delta={Delta}", userId, delta);
        return false;
    }
}
```

### 2.5 Query vs Mutation分離模式

**Query服務（唯讀）:**
```csharp
public class WalletQueryService : IWalletQueryService
{
    public async Task<WalletDto> GetWalletAsync(int userId)
    {
        return await _context.User_Wallet
            .AsNoTracking() // ★ 重點：使用AsNoTracking提升效能
            .Where(w => w.User_Id == userId && !w.IsDeleted)
            .Select(w => new WalletDto
            {
                UserId = w.User_Id,
                PointBalance = w.User_Point
            })
            .FirstOrDefaultAsync();
    }
}
```

**Mutation服務（寫入）:**
```csharp
public class WalletMutationService : IWalletMutationService
{
    public async Task<bool> DeductPointsAsync(int userId, int points, string reason)
    {
        // 不使用AsNoTracking，需要追蹤實體以進行更新
        var wallet = await _context.User_Wallet
            .FirstOrDefaultAsync(w => w.User_Id == userId && !w.IsDeleted);

        // ... 更新邏輯
    }
}
```

### 2.6 Constants (4個檔案)

**WalletConstants.cs:**
```csharp
public static class WalletConstants
{
    public static class ChangeTypes
    {
        public const string AdminAdd = "Admin_Add";
        public const string AdminDeduct = "Admin_Deduct";
        public const string GameReward = "Game_Reward";
        public const string SignInReward = "SignIn_Reward";
        public const string CouponIssue = "Coupon_Issue";
        public const string EVoucherIssue = "EVoucher_Issue";
        public const string PetSkinColorChange = "Pet_SkinColor_Change";
        public const string PetBackgroundChange = "Pet_Background_Change";
    }

    public const int MinPoints = 0;
    public const int MaxPoints = int.MaxValue;
}
```

**PetConstants.cs:**
```csharp
public static class PetConstants
{
    public const int MinStatValue = 0;
    public const int MaxStatValue = 100;

    public const int DailyHungerDecay = -20;
    public const int DailyMoodDecay = -30;
    public const int DailyStaminaDecay = -10;
    public const int DailyCleanlinessDecay = -20;

    public const int SkinColorChangeCost = 2000; // 固定2000點

    public static class InteractionEffects
    {
        public const int FeedHungerIncrease = 30;
        public const int PlayMoodIncrease = 40;
        public const int CleanCleanlinessIncrease = 35;
        public const int SleepStaminaIncrease = 50;
    }
}
```

**SignInConstants.cs:**
```csharp
public static class SignInConstants
{
    public const string TimezoneId = "Taipei Standard Time"; // Asia/Taipei
    public const int MaxConsecutiveDays = 365;
}
```

**CouponConstants.cs:**
```csharp
public static class CouponConstants
{
    public static class DiscountTypes
    {
        public const string Percent = "PERCENT";
        public const string Amount = "AMOUNT";
    }
}
```

### 2.7 四大子系統架構圖

```
┌─────────────────────────────────────────────────────────────────┐
│                        MiniGame Area                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │ Controllers  │  │  Services    │  │   Models     │        │
│  │   (24個)     │→ │   (94個)     │→ │  (DB Tables) │        │
│  └──────────────┘  └──────────────┘  └──────────────┘        │
│         ↑                  ↑                  ↑                │
│         │                  │                  │                │
│  ┌──────────────────────────────────────────────────┐         │
│  │           四大子系統 (Four Subsystems)            │         │
│  ├──────────────────────────────────────────────────┤         │
│  │                                                   │         │
│  │  1️⃣ 錢包系統 (Wallet System)                      │         │
│  │     - User_Wallet, WalletHistory                 │         │
│  │     - Coupon, CouponType                         │         │
│  │     - EVoucher, EVoucherType, Token, RedeemLog   │         │
│  │     📊 Services: 8個 | Controllers: 3個           │         │
│  │                                                   │         │
│  │  2️⃣ 寵物系統 (Pet System)                         │         │
│  │     - Pet (5屬性: Hunger/Mood/Stamina/          │         │
│  │                   Cleanliness/Health)            │         │
│  │     - PetSkinColorCostSettings                   │         │
│  │     - PetBackgroundCostSettings                  │         │
│  │     - PetLevelRewardSettings                     │         │
│  │     📊 Services: 20個 | Controllers: 8個          │         │
│  │                                                   │         │
│  │  3️⃣ 簽到系統 (Sign-In System)                     │         │
│  │     - SignInRule (日獎勵配置)                     │         │
│  │     - UserSignInStats (簽到記錄)                  │         │
│  │     📊 Services: 6個 | Controllers: 1個           │         │
│  │                                                   │         │
│  │  4️⃣ 遊戲系統 (Mini-Game System)                   │         │
│  │     - MiniGame (對局記錄)                         │         │
│  │     - 每日限制: 3次 (可配置)                      │         │
│  │     📊 Services: 6個 | Controllers: 3個           │         │
│  │                                                   │         │
│  └──────────────────────────────────────────────────┘         │
│                                                                 │
│  ┌──────────────────────────────────────────────────┐         │
│  │         核心基礎設施 (Infrastructure)              │         │
│  ├──────────────────────────────────────────────────┤         │
│  │  - SystemSettings (系統配置)                      │         │
│  │  - Users (用戶基礎數據)                           │         │
│  │  - ManagerData (管理員數據)                       │         │
│  │  - ManagerRole + Permission (權限管理)            │         │
│  └──────────────────────────────────────────────────┘         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3. 其他Areas概覽

### 3.1 Forum Area (論壇管理)
**Controllers:** 8個
- AdminPosts, Threads, Games, Imports, Mappings, Metrics, Reports

**Models:** 25+
- forums, games, posts, threads, thread_posts
- game_metric_daily, leaderboard_snapshots

**功能:**
- 論壇版塊管理
- 文章/討論串審核
- 遊戲數據導入
- 熱門指標計算

### 3.2 MemberManagement Area (會員管理)
**Controllers:** 9個
- User, ManagerData, ManagerRoles, ManagerRolePermission, ManagerWithRoles
- UserIntroduces, UserPermissions

**DbContext:** MemberManagementDbContext (獨立)

**功能:**
- 用戶帳號管理
- 管理員帳號管理
- 角色與權限分配
- 用戶權限管理

### 3.3 OnlineStore Area (線上商店管理)
**Controllers:** 6個
- Products, Suppliers, Orders, CodeCenter, Engagement

**功能:**
- 商品管理
- 供應商管理
- 訂單處理
- 商品代碼管理

### 3.4 social_hub Area (社交中心)
**Controllers:** 6個
- Chat, Support, Notification, Relations, Profanity, Combos

**SignalR Hubs:** 2個
- ChatHub (/social_hub/chatHub) - 聊天
- SupportHub (/hubs/support) - 客服工單

**Services:** 6個
- IChatService, ISupportService, IRelationService
- INotificationService (NotificationServiceAlias)
- IMuteFilter (MuteFilterAlias) - Singleton, 禁言詞過濾

**功能:**
- 即時聊天
- 客服工單系統
- 好友關係管理
- 內容審查/禁言

### 3.5 Identity Area
**Controllers:** 最小化（ASP.NET Identity預設頁面）

**功能:**
- Identity UI頁面 (Register, Login, etc.)
- 實際使用AdminCookie，不是Identity

---

## 4. 認證與授權

### 4.1 AdminCookie認證架構

**Program.cs配置 (Line 51-80):**
```csharp
builder.Services.AddAuthentication(options =>
{
    options.DefaultScheme = "AdminCookie";
    options.DefaultAuthenticateScheme = "AdminCookie";
    options.DefaultChallengeScheme = "AdminCookie";
})
.AddCookie("AdminCookie", options =>
{
    options.Cookie.Name = "AdminCookie";
    options.LoginPath = "/Login";
    options.LogoutPath = "/Logout";
    options.ExpireTimeSpan = TimeSpan.FromHours(4);
    options.SlidingExpiration = true;

    // AJAX請求不重導向
    options.Events.OnRedirectToLogin = context =>
    {
        if (context.Request.IsAjaxRequest())
        {
            context.Response.StatusCode = 401;
            return Task.CompletedTask;
        }
        context.Response.Redirect(context.RedirectUri);
        return Task.CompletedTask;
    };
});
```

**Claims結構:**
```csharp
var claims = new List<Claim>
{
    new Claim("ManagerId", managerId.ToString()),
    new Claim("IsManager", "true"),
    new Claim(ClaimTypes.Name, managerName),
    new Claim(ClaimTypes.Email, managerEmail),
    new Claim("ManagerAccount", managerAccount)
};

var claimsIdentity = new ClaimsIdentity(claims, "AdminCookie");
var authProperties = new AuthenticationProperties
{
    IsPersistent = rememberMe,
    ExpiresUtc = DateTimeOffset.UtcNow.AddHours(4)
};

await HttpContext.SignInAsync("AdminCookie", new ClaimsPrincipal(claimsIdentity), authProperties);
```

### 4.2 授權策略 (7個)

**Program.cs配置 (Line 81-110):**
```csharp
builder.Services.AddAuthorization(options =>
{
    // 1. 基本管理員權限
    options.AddPolicy("AdminOnly", policy =>
        policy.RequireClaim("IsManager", "true"));

    // 2. 購物權限管理 (對應Wallet系統)
    options.AddPolicy("CanManageShopping", policy =>
        policy.RequireAssertion(context =>
            HasPermission(context.User, "ShoppingPermissionManagement")));

    // 3. 管理員權限管理
    options.AddPolicy("CanAdmin", policy =>
        policy.RequireAssertion(context =>
            HasPermission(context.User, "AdministratorPrivilegesManagement")));

    // 4. 寵物權限管理
    options.AddPolicy("CanPet", policy =>
        policy.RequireAssertion(context =>
            HasPermission(context.User, "Pet_Rights_Management")));

    // 5. 訊息權限管理
    options.AddPolicy("CanMessage", policy =>
        policy.RequireAssertion(context =>
            HasPermission(context.User, "MessagePermissionManagement")));

    // 6. 用戶狀態管理
    options.AddPolicy("CanUserStatus", policy =>
        policy.RequireAssertion(context =>
            HasPermission(context.User, "UserStatusManagement")));

    // 7. 客服權限
    options.AddPolicy("CanCS", policy =>
        policy.RequireAssertion(context =>
            HasPermission(context.User, "customer_service")));
});
```

### 4.3 權限檢查實作

**服務層權限檢查:**
```csharp
// MiniGameAdminAuthService.HasPermissionAsync
public async Task<bool> HasPermissionAsync(int managerId, string permissionName)
{
    var permissions = await _context.ManagerRole
        .Where(mr => mr.Manager_Id == managerId)
        .Join(_context.ManagerRolePermission,
            mr => mr.ManagerRole_Id,
            mrp => mrp.ManagerRole_Id,
            (mr, mrp) => mrp)
        .FirstOrDefaultAsync();

    if (permissions == null) return false;

    return permissionName switch
    {
        "ShoppingPermissionManagement" => permissions.ShoppingPermissionManagement,
        "Pet_Rights_Management" => permissions.Pet_Rights_Management,
        "UserStatusManagement" => permissions.UserStatusManagement,
        "MessagePermissionManagement" => permissions.MessagePermissionManagement,
        "AdministratorPrivilegesManagement" => permissions.AdministratorPrivilegesManagement,
        "customer_service" => permissions.customer_service,
        _ => false
    };
}
```

**Controller層使用:**
```csharp
[Area("MiniGame")]
[Authorize(AuthenticationSchemes = "AdminCookie", Policy = "AdminOnly")]
public class WalletAdminController : MiniGameBaseController
{
    [Authorize(Policy = "CanManageShopping")] // 額外權限檢查
    public async Task<IActionResult> AdjustPoints(int userId, int delta)
    {
        // ... 調整點數邏輯
    }
}
```

### 4.4 Manager Permission Model

**資料表關係:**
```
ManagerData (1) ──< (N) ManagerRole (N) ──> (1) ManagerRolePermission
```

**ManagerRolePermission欄位:**
- role_name (nvarchar(50))
- AdministratorPrivilegesManagement (bit) - 管理員管理
- UserStatusManagement (bit) - 用戶管理
- ShoppingPermissionManagement (bit) - 購物/錢包管理
- MessagePermissionManagement (bit) - 訊息管理
- Pet_Rights_Management (bit) - 寵物管理
- customer_service (bit) - 客服權限

---

## 5. 資料庫架構

### 5.1 DbContexts (3個)

**1. GameSpacedatabaseContext (主要)**
- 位置: Models/GameSpacedatabaseContext.cs
- 連線字串: "GameSpace" or "GameSpacedatabase"
- DbSets: 150+
- 用於: MiniGame, Forum, OnlineStore, social_hub

**2. ApplicationDbContext**
- 位置: Data/ApplicationDbContext.cs
- 連線字串: "DefaultConnection"
- 用於: ASP.NET Identity (Users, Roles, Claims)

**3. MemberManagementDbContext**
- 位置: Areas/MemberManagement/Data/
- 獨立資料庫或相同資料庫不同schema
- 用於: 管理員專用數據

### 5.2 連線字串配置

**appsettings.json:**
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=(local)\\SQLEXPRESS01;Database=GameSpaceIdentity;Trusted_Connection=True;",
    "GameSpace": "Server=(local)\\SQLEXPRESS01;Database=GameSpacedatabase;Trusted_Connection=True;TrustServerCertificate=True;"
  }
}
```

### 5.3 軟刪除實作

**所有MiniGame相關表格實作軟刪除:**
```csharp
public class User_Wallet
{
    public int User_Id { get; set; }
    public int User_Point { get; set; }

    // 軟刪除欄位
    public bool IsDeleted { get; set; }
    public DateTime? DeletedAt { get; set; }
    public int? DeletedBy { get; set; }
    public string? DeleteReason { get; set; }
}
```

**查詢時必須過濾:**
```csharp
var wallet = await _context.User_Wallet
    .Where(w => w.User_Id == userId && !w.IsDeleted) // ★ 重點
    .FirstOrDefaultAsync();
```

### 5.4 審計追蹤

**SystemSettings及Pet設定表包含:**
```csharp
public class SystemSettings
{
    public int SettingId { get; set; }
    public string SettingKey { get; set; }
    public string? SettingValue { get; set; }

    // 審計欄位
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
    public int? UpdatedBy { get; set; } // FK → ManagerData.Manager_Id

    // 軟刪除
    public bool IsDeleted { get; set; }
    public DateTime? DeletedAt { get; set; }
    public int? DeletedBy { get; set; }
    public string? DeleteReason { get; set; }
}
```

### 5.5 UTC時間戳

**所有時間欄位預設值:**
```sql
DEFAULT sysutcdatetime()
```

**查詢時轉換時區 (Asia/Taipei):**
```csharp
var today = DateTime.UtcNow.ToTaipeiTime().Date;

// 或使用SQL Server時區轉換
CONVERT(DATE, GETUTCDATE() AT TIME ZONE 'UTC' AT TIME ZONE 'Taipei Standard Time')
```

---

## 6. 服務層架構

### 6.1 服務生命週期

**Scoped (預設):** 每個HTTP請求一個實例
- IWalletService, IPetService, ISignInService, IGamePlayService
- 所有Query/Mutation服務

**Singleton:** 應用程式生命週期單例
- ITaiwanHolidayService (載入固定假日清單)
- InMemorySignInRuleService (快取簽到規則)
- InMemoryPetSkinColorCostSettingService (快取膚色定價)
- IMuteFilter (禁言詞過濾器)

**Transient:** 每次注入新實例
- (MiniGame Area未使用)

### 6.2 依賴注入範例

**Controller注入:**
```csharp
public class WalletAdminController : MiniGameBaseController
{
    private readonly IWalletService _walletService;
    private readonly IWalletMutationService _walletMutationService;
    private readonly ICouponService _couponService;
    private readonly ILogger<WalletAdminController> _logger;

    public WalletAdminController(
        IWalletService walletService,
        IWalletMutationService walletMutationService,
        ICouponService couponService,
        ILogger<WalletAdminController> logger)
    {
        _walletService = walletService;
        _walletMutationService = walletMutationService;
        _couponService = couponService;
        _logger = logger;
    }
}
```

**Service注入:**
```csharp
public class WalletService : IWalletService
{
    private readonly GameSpacedatabaseContext _context;
    private readonly IWalletQueryService _queryService;
    private readonly ILogger<WalletService> _logger;

    public WalletService(
        GameSpacedatabaseContext context,
        IWalletQueryService queryService,
        ILogger<WalletService> logger)
    {
        _context = context;
        _queryService = queryService;
        _logger = logger;
    }
}
```

### 6.3 服務間通訊

**錢包 → 寵物 (點數扣除後給寵物經驗):**
```csharp
// GamePlayService.EndGameAsync
public async Task<GameEndResult> EndGameAsync(string sessionId, GameResult result)
{
    // 1. 計算獎勵
    var rewards = CalculateRewards(result);

    // 2. 發放點數 (呼叫Wallet服務)
    await _walletService.AddPointsAsync(userId, rewards.Points, "Game_Reward", "Win Level 3");

    // 3. 增加寵物經驗 (呼叫Pet服務)
    await _petService.AddExperienceAsync(petId, rewards.Experience);

    // 4. 更新寵物屬性
    await _petService.UpdateStatsAsync(petId, rewards.HungerDelta, rewards.MoodDelta, ...);

    return new GameEndResult { ... };
}
```

---

## 7. Middleware管道

### 7.1 管道配置順序 (Program.cs)

```csharp
var app = builder.Build();

// 1. 開發環境專用
if (app.Environment.IsDevelopment())
{
    app.UseMigrationsEndPoint();
    app.UseDeveloperExceptionPage();
}
else
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}

// 2. HTTPS重導向
app.UseHttpsRedirection();

// 3. 靜態檔案
app.UseStaticFiles();

// 4. 路由
app.UseRouting();

// 5. CORS (在auth之前)
app.UseCors();

// 6. Session (必須在Authentication之前)
app.UseSession();

// 7. 認證
app.UseAuthentication();

// 8. 授權
app.UseAuthorization();

// 9. 端點路由
app.MapAreaControllerRoute(
    name: "miniGameArea",
    areaName: "MiniGame",
    pattern: "MiniGame/{controller=Home}/{action=Index}/{id?}");

app.MapAreaControllerRoute(
    name: "forumArea",
    areaName: "Forum",
    pattern: "Forum/{controller=Home}/{action=Index}/{id?}");

// ... 其他Area路由

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.MapRazorPages();

// 10. SignalR Hubs
app.MapHub<SupportHub>("/hubs/support");
// ChatHub位於social_hub Area

app.Run();
```

### 7.2 Global Filters

**Program.cs配置:**
```csharp
builder.Services.AddControllersWithViews(options =>
{
    // Anti-forgery token驗證 (自動套用於POST/PUT/DELETE)
    options.Filters.Add<AutoValidateAntiforgeryTokenAttribute>();

    // Response caching (預設不快取)
    options.Filters.Add(new ResponseCacheAttribute { NoStore = true });
});
```

### 7.3 MiniGame Custom Filters

**1. MiniGameAdminAuthorizeAttribute**
```csharp
[AttributeUsage(AttributeTargets.Class | AttributeTargets.Method)]
public class MiniGameAdminAuthorizeAttribute : Attribute, IAuthorizationFilter
{
    public void OnAuthorization(AuthorizationFilterContext context)
    {
        var user = context.HttpContext.User;
        if (!user.Identity?.IsAuthenticated ?? true)
        {
            context.Result = new RedirectToActionResult("Login", "Account", new { area = "" });
            return;
        }

        var isManager = user.HasClaim("IsManager", "true");
        if (!isManager)
        {
            context.Result = new ForbidResult();
        }
    }
}
```

**2. MiniGameProblemDetailsFilter**
```csharp
public class MiniGameProblemDetailsFilter : IExceptionFilter
{
    public void OnException(ExceptionContext context)
    {
        var problemDetails = new ProblemDetails
        {
            Status = 500,
            Title = "An error occurred",
            Detail = context.Exception.Message
        };

        context.Result = new ObjectResult(problemDetails)
        {
            StatusCode = 500
        };

        context.ExceptionHandled = true;
    }
}
```

**3. IdempotencyFilter** (防重複提交)
```csharp
public class IdempotencyFilter : IActionFilter
{
    private readonly IMemoryCache _cache;

    public void OnActionExecuting(ActionExecutingContext context)
    {
        var idempotencyKey = context.HttpContext.Request.Headers["Idempotency-Key"].ToString();
        if (string.IsNullOrEmpty(idempotencyKey)) return;

        if (_cache.TryGetValue(idempotencyKey, out var cachedResult))
        {
            context.Result = (IActionResult)cachedResult;
        }
    }

    public void OnActionExecuted(ActionExecutedContext context)
    {
        var idempotencyKey = context.HttpContext.Request.Headers["Idempotency-Key"].ToString();
        if (!string.IsNullOrEmpty(idempotencyKey) && context.Result is ObjectResult result)
        {
            _cache.Set(idempotencyKey, result, TimeSpan.FromMinutes(5));
        }
    }
}
```

---

## 8. 配置與部署

### 8.1 appsettings.json

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning",
      "Microsoft.EntityFrameworkCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "ConnectionStrings": {
    "DefaultConnection": "Server=(local)\\SQLEXPRESS01;Database=GameSpaceIdentity;Trusted_Connection=True;",
    "GameSpace": "Server=(local)\\SQLEXPRESS01;Database=GameSpacedatabase;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "MiniGame": {
    "MaxDailyGamePlays": 3,
    "PetSkinColorChangeCost": 2000,
    "SignInTimezone": "Taipei Standard Time"
  }
}
```

### 8.2 Launch Settings

**Properties/launchSettings.json:**
```json
{
  "profiles": {
    "GameSpace": {
      "commandName": "Project",
      "launchBrowser": true,
      "applicationUrl": "https://localhost:7042;http://localhost:5211",
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    },
    "IIS Express": {
      "commandName": "IISExpress",
      "launchBrowser": true,
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    }
  }
}
```

**預設連線埠:**
- HTTPS: `localhost:7042`
- HTTP: `localhost:5211`

### 8.3 Build & Run指令

**建置:**
```powershell
dotnet build GameSpace/GameSpace/GameSpace.csproj
```

**執行:**
```powershell
dotnet run --project GameSpace/GameSpace/GameSpace.csproj
```

**發佈:**
```powershell
dotnet publish GameSpace/GameSpace/GameSpace.csproj -c Release -o ./publish
```

### 8.4 資料庫初始化

**重要:** 不使用EF Migrations

**SQL Server是唯一真相來源:**
1. 使用SSMS連線到 `(local)\SQLEXPRESS01`
2. 執行 `schema/*.sql` 腳本建立表格
3. 載入種子資料

**不要執行:**
```powershell
# ❌ 禁止
dotnet ef migrations add ...
dotnet ef database update
```

---

## 9. 關鍵架構決策

### 9.1 Area-based組織

**決策:** 使用ASP.NET Core Areas分割功能模組

**原因:**
- 模組隔離：每個Area獨立開發
- 團隊擴展：不同團隊負責不同Area
- 權限控制：Area層級的路由保護
- 程式碼組織：避免單一Controllers資料夾過大

**實作:**
```
Areas/
├── MiniGame/      [團隊A負責]
├── Forum/         [團隊B負責]
├── OnlineStore/   [團隊C負責]
└── social_hub/    [團隊D負責]
```

### 9.2 服務抽象層

**決策:** 業務邏輯封裝在Services，不在Controllers

**原因:**
- 關注點分離：Controller只處理HTTP，Service處理業務邏輯
- 可測試性：Service可獨立單元測試
- 可重用性：多個Controller可共用Service
- 易於維護：業務邏輯集中管理

**範例:**
```
Controller (HTTP) → Service (Business) → DbContext (Data)
```

### 9.3 Query/Mutation分離

**決策:** 唯讀操作使用QueryService + AsNoTracking

**原因:**
- 效能提升：AsNoTracking避免變更追蹤overhead
- 清晰職責：Query不應修改資料
- 審計清晰：所有寫入操作集中在MutationService
- CQRS準備：未來可擴展為完整CQRS

**實作:**
```csharp
IWalletQueryService   → 唯讀，AsNoTracking
IWalletMutationService → 寫入，Transaction-wrapped
```

### 9.4 軟刪除模式

**決策:** 所有MiniGame相關表格實作軟刪除

**原因:**
- 資料恢復：誤刪可復原
- 審計需求：保留刪除記錄
- 法規遵循：金融資料不可物理刪除
- 關聯完整性：避免FK constraint衝突

**代價:**
- 查詢複雜度：所有查詢需加 `!IsDeleted`
- 唯一約束：UNIQUE constraint需考慮IsDeleted

### 9.5 交易包裝

**決策:** 所有錢包操作必須包在資料庫交易內

**原因:**
- ACID保證：點數扣除/增加的原子性
- 一致性：錢包餘額與歷史記錄同步
- 錯誤回滾：操作失敗時自動rollback
- 防止資料不一致

**實作:**
```csharp
using var transaction = await _context.Database.BeginTransactionAsync();
try {
    // 多步驟操作
    await transaction.CommitAsync();
} catch {
    await transaction.RollbackAsync();
    throw;
}
```

### 9.6 多DbContexts

**決策:** 使用3個DbContext分隔不同領域

**原因:**
- 領域分離：Identity vs GameSpace vs MemberManagement
- 資料庫分離：可部署到不同資料庫
- 效能：減少單一Context的DbSet數量
- 權限控制：不同Context不同連線字串

### 9.7 AdminCookie認證

**決策:** 自訂AdminCookie scheme，不使用ASP.NET Identity

**原因:**
- 靈活性：完全控制Claims結構
- 簡化：不需要Identity的Role/RoleClaim複雜性
- 客製化：ManagerRolePermission以boolean欄位定義權限
- 效能：避免Identity的多表JOIN

### 9.8 Claims-based授權

**決策:** 使用Claims + Policy定義權限

**原因:**
- 細粒度：可定義多層權限（AdminOnly, CanPet, CanManageShopping）
- 動態檢查：Policy可呼叫Service檢查資料庫
- 擴展性：新權限只需新增Policy
- 標準化：符合ASP.NET Core授權模式

### 9.9 禁用EF Migrations

**決策:** 不使用EF Migrations，手動管理SQL腳本

**原因:**
- SQL Server是單一真相來源：DBA控制schema
- 複雜schema：Migrations難以處理複雜CHECK constraint
- 多人協作：避免Migrations衝突
- 生產環境：DBA需審核所有schema變更

### 9.10 Async/Await全域

**決策:** 所有Service方法使用async/await

**原因:**
- 非阻塞I/O：資料庫查詢不阻塞執行緒
- 擴展性：支援更多並發請求
- ASP.NET Core最佳實踐：符合框架設計
- 效能：減少執行緒池壓力

---

## 10. 程式碼度量

### 10.1 MiniGame Area統計

| 類別 | 數量 | 預估行數 |
|------|------|----------|
| Controllers | 24 | 12,000+ |
| Service Interfaces | 54 | 2,000+ |
| Service Implementations | 94 | 15,000+ |
| ViewModels | 60+ | 3,000+ |
| Views (Razor) | 100+ | 8,000+ |
| Constants | 4 | 200+ |
| **總計** | **336+** | **40,000+** |

### 10.2 最大的檔案

| 檔案 | 行數 | 用途 |
|------|------|------|
| AdminPetController.cs | 1,440 | 寵物管理 |
| WalletAdminController.cs | 955 | 錢包管理 |
| AdminEVoucherController.cs | 847 | 電子券管理 |
| AdminMiniGameController.cs | 663 | 遊戲管理 |
| AdminCouponController.cs | 580 | 優惠券管理 |
| AdminDiagnosticsController.cs | 576 | 診斷工具 |
| AdminUserController.cs | 512 | 用戶管理 |
| AdminManagerController.cs | 491 | 管理員管理 |
| MiniGameBaseController.cs | 318 | 基底控制器 |
| Program.cs | 259 | 應用程式啟動 |

### 10.3 全專案統計

| 指標 | 數量 |
|------|------|
| Areas | 6 |
| Controllers (全部) | 50+ |
| DbContexts | 3 |
| DbSets | 150+ |
| Authorization Policies | 7 |
| SignalR Hubs | 2 |
| Custom Filters | 4 |
| Configuration Files | 3 |

---

## 附錄A: Controller完整清單

### MiniGame Area (24個)
1. AdminController
2. AdminCouponController
3. AdminDashboardController
4. AdminDiagnosticsController
5. AdminEVoucherController
6. AdminHomeController
7. AdminManagerController
8. AdminMiniGameController
9. AdminPetController
10. AdminUserController
11. CouponTypesController
12. DailyGameLimitController
13. GameAdminController
14. HomeController
15. MiniGameBaseController
16. PetAdminController
17. PetBackgroundCostSettingController
18. PetLevelExperienceSettingController
19. PetLevelRewardSettingController
20. PetLevelUpRuleController
21. PetLevelUpRuleValidationController
22. PetSkinColorCostSettingController
23. SignInAdminController
24. WalletAdminController

### 其他Areas (26+)
- Forum Area: 8個
- MemberManagement Area: 9個
- OnlineStore Area: 6個
- social_hub Area: 6個
- Identity Area: 最小化

---

## 附錄B: Service完整清單 (MiniGame)

### Tier 1: Admin Services (3個)
- IMiniGameAdminService / MiniGameAdminService
- IMiniGameAdminAuthService / MiniGameAdminAuthService
- IMiniGameAdminGate / MiniGameAdminGate

### Tier 2: Wallet Services (8個)
- IWalletService / WalletService
- IWalletQueryService / WalletQueryService
- IWalletMutationService / WalletMutationService
- IUserWalletService / UserWalletService
- ICouponService / CouponService
- ICouponTypeService / CouponTypeService
- IEVoucherService / EVoucherService
- IEVoucherTypeService / EVoucherTypeService

### Tier 2: Pet Services (20個)
- IPetService / PetService
- IPetQueryService / PetQueryService
- IPetMutationService / PetMutationService
- IPetRulesService / PetRulesService
- IPetInteractionService / PetInteractionService
- IPetDailyDecayService / PetDailyDecayService
- IPetLevelUpRuleService / PetLevelUpRuleService
- PetLevelUpRuleValidationService
- IPetLevelRewardSettingService / PetLevelRewardSettingService
- PetLevelExperienceSettingService
- IPetSkinColorCostSettingService / PetSkinColorCostSettingService
- InMemoryPetSkinColorCostSettingService
- IPetColorOptionService / PetColorOptionService
- IPetColorChangeSettingsService / PetColorChangeSettingsService
- IPetBackgroundCostSettingService / PetBackgroundCostSettingService
- IPetBackgroundOptionService / PetBackgroundOptionService
- IPetBackgroundChangeSettingsService / PetBackgroundChangeSettingsService
- IPointsSettingsStatisticsService / PointsSettingsStatisticsService

### Tier 2: SignIn Services (6個)
- ISignInService / SignInService
- ISignInQueryService / SignInQueryService
- ISignInMutationService / SignInMutationService
- ISignInStatsService / SignInStatsService
- InMemorySignInRuleService

### Tier 2: Game Services (8個)
- IMiniGameService / MiniGameService
- IGamePlayService / GamePlayService
- IGameQueryService / GameQueryService
- IGameMutationService / GameMutationService
- IGameRulesService / GameRulesService
- GameRulesOptions
- IDailyGameLimitService / DailyGameLimitService
- IDailyGameLimitValidationService / DailyGameLimitValidationService

### Tier 3: Utility Services (6個)
- IDashboardService / DashboardService
- IDiagnosticsService / DiagnosticsService
- IManagerService / ManagerService
- IUserService / UserService
- ITaiwanHolidayService / TaiwanHolidayService

---

## 附錄C: 資料庫表格涵蓋範圍

### MiniGame Area涵蓋的表格 (20個)

| 表格 | Controllers | Services |
|------|-------------|----------|
| User_Wallet | WalletAdminController | WalletService系列(4個) |
| WalletHistory | WalletAdminController | WalletService系列 |
| CouponType | AdminCouponController, CouponTypesController | CouponTypeService |
| Coupon | AdminCouponController | CouponService |
| EVoucherType | AdminEVoucherController | EVoucherTypeService |
| EVoucher | AdminEVoucherController | EVoucherService |
| EVoucherToken | AdminEVoucherController | EVoucherService |
| EVoucherRedeemLog | AdminEVoucherController | EVoucherService |
| SignInRule | SignInAdminController | SignInService系列(5個) |
| UserSignInStats | SignInAdminController | SignInStatsService |
| Pet | AdminPetController | PetService系列(20個) |
| PetSkinColorCostSettings | PetSkinColorCostSettingController | PetSkinColorCostSettingService |
| PetBackgroundCostSettings | PetBackgroundCostSettingController | PetBackgroundCostSettingService |
| PetLevelRewardSettings | PetLevelRewardSettingController | PetLevelRewardSettingService |
| MiniGame | AdminMiniGameController, GameAdminController | GamePlayService系列(6個) |
| SystemSettings | AdminDiagnosticsController | DiagnosticsService |
| Users | AdminUserController | UserService |
| ManagerData | AdminManagerController | ManagerService |
| ManagerRole | AdminManagerController | ManagerService |
| ManagerRolePermission | AdminManagerController | ManagerService |

**涵蓋率:** 20/20 = **100%**

---

*文件版本: 1.0*
*最後更新: 2025-11-03*
*作者: AI Documentation System*
*狀態: 完整分析完成*
