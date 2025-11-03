# GamiPort 前台開發完整藍圖 - MiniGame Area

**生成日期:** 2025-11-03
**專案:** GamiPort (客戶端前台)
**當前狀態:** 其他Areas完成，MiniGame Area僅5%完成
**設計系統:** 淡藍色(Teal/Turquoise)現代主題，卡片式佈局

---

## 執行摘要

### 專案概況
- **名稱:** GamiPort (前台/Client Portal)
- **對應後台:** GameSpace (管理後台)
- **核心架構:** ASP.NET Core 8.0 MVC + SignalR
- **認證:** Cookie-based (非Identity)，使用IAppCurrentUser介面
- **資料庫:** SQL Server GameSpacedatabase (共用)
- **連線埠:** HTTPS:7160, HTTP:5042

### MiniGame Area開發需求摘要

| 類別 | 當前狀態 | 需開發 | 預估工作量 |
|------|----------|--------|------------|
| Controllers | 4個stub | 完整實作 + 1個新增(GameController) | 2週 |
| Services | 0個 | 40+個服務(介面+實作) | 3週 |
| ViewModels | 0個 | 30+個 | 1週 |
| Views | 5個placeholder | 完整實作 + 10+個新增 | 2週 |
| Client-side JS | 0個 | 5個功能模組 | 1.5週 |
| CSS (Teal主題) | 0個 | 完整設計系統 | 1週 |
| **總計** | **5%完成** | **95%需開發** | **9-10週** |

---

## 目錄

1. [當前狀態評估](#1-當前狀態評估)
2. [架構分析 - 既有模式](#2-架構分析---既有模式)
3. [設計系統規範](#3-設計系統規範)
4. [Service層開發計劃](#4-service層開發計劃)
5. [Controller層開發計劃](#5-controller層開發計劃)
6. [ViewModel開發計劃](#6-viewmodel開發計劃)
7. [View層開發計劃](#7-view層開發計劃)
8. [Client-Side JavaScript](#8-client-side-javascript)
9. [API端點設計(可選)](#9-api端點設計可選)
10. [Service註冊](#10-service註冊)
11. [開發路線圖](#11-開發路線圖)
12. [測試策略](#12-測試策略)
13. [部署檢查清單](#13-部署檢查清單)

---

## 1. 當前狀態評估

### 1.1 已完成Areas (100%)

**Forum Area** ✅
- Controllers: HomeController, ThreadsController
- API: ForumsApiController, ThreadsApiController, MeApiController
- Services: IForumsService, IThreadsService, IMeContentService (含實作)
- Views: Index, Detail, 共用佈局
- 模式: 服務層 + API + Views完整

**Login Area** ✅
- Controllers: LoginController, RegisterController, PasswordController, EmailController, IntroduceController, HomeController
- Services: IEmailSender (SmtpEmailSender / NullEmailSender), TokenUtility
- Auth: 自訂Cookie (非ASP.NET Identity)
- 模式: 多步驟註冊，郵箱驗證

**OnlineStore Area** ✅
- Controllers: HomeController, StoreController, CartController, CheckoutController, OrdersController, PaymentController
- Services: ICartService (SqlCartService), ILookupService, EcpayPaymentService
- 模式: 購物車狀態管理，ECPay金流整合

**social_hub Area** ✅
- Controllers: ChatController, SupportController, NotificationController, RelationsController, ProfanityController, CombosController
- Hubs: ChatHub (/social_hub/chathub), SupportHub (/hubs/support)
- Services: IChatService, ISupportService, IRelationService, INotificationStore, IProfanityFilter (Singleton)
- 模式: SignalR即時通訊

**MemberManagement Area** ✅
- Controllers: HomeController, HomeSettingController, MemberController, MyHomeController
- Models: HomePageVM, HomeSettingEditVM, UserHomeVM
- Views: 個人資料頁、設定頁

### 1.2 MiniGame Area 當前狀態 (5%)

**目錄結構:**
```
Areas/MiniGame/
├── Controllers/                [4個STUB檔案]
│   ├── HomeController.cs       - 基本View()回傳
│   ├── PetController.cs        - 手動auth檢查，無服務，有TODO
│   ├── WalletController.cs     - 手動auth檢查，無服務，有TODO
│   └── SignInController.cs     - 手動auth檢查，無服務，有TODO
│
├── Views/                      [5個PLACEHOLDER檔案]
│   ├── _ViewImports.cshtml     - 標準Razor imports
│   ├── _ViewStart.cshtml       - Layout設定
│   ├── Home/Index.cshtml       - "小遊戲"純文字
│   ├── Pet/Index.cshtml        - Bootstrap卡片，禁用按鈕，TODO清單
│   ├── Wallet/Index.cshtml     - 度量卡片（0值），禁用按鈕
│   ├── SignIn/Index.cshtml     - 狀態卡片，空日曆/歷史
│   └── Shared/_Layout.cshtml   - Bootstrap 5.3.3佈局
│
├── Services/                   [不存在]
├── Models/                     [不存在]
└── API/                        [不存在]
```

**現有View功能 (UI Scaffold):**
- **Pet/Index:** 寵物屬性顯示（Hunger/Mood/Stamina/Cleanliness 0-100），禁用互動按鈕
- **Wallet/Index:** Points/Coupons/E-Vouchers度量卡片，禁用兌換按鈕
- **SignIn/Index:** 日曆placeholder，空歷史表格
- 所有Views使用Bootstrap 5.3.3卡片與元件

**遺漏內容 (95%):**
- ❌ Service層 (IWalletService, IPetService, ISignInService, IGamePlayService)
- ❌ Service實作（含資料庫存取）
- ❌ API controllers（AJAX互動）
- ❌ ViewModels（資料綁定）
- ❌ Client-side JavaScript（互動邏輯）
- ❌ Service註冊（Program.cs）
- ❌ 功能性Controllers（服務注入）
- ❌ Views實際資料綁定
- ❌ 認證屬性（目前手動檢查）
- ❌ Teal設計系統CSS

---

## 2. 架構分析 - 既有模式

### 2.1 認證模式 (from Login Area)

**IAppCurrentUser Pattern:**
```csharp
// 位置: Infrastructure/Security/IAppCurrentUser.cs
public interface IAppCurrentUser
{
    int UserId { get; }
    string Email { get; }
    string NickName { get; }
    Task<int> GetUserIdAsync(CancellationToken ct = default);
}

// 位置: Infrastructure/Security/AppCurrentUser.cs
public class AppCurrentUser : IAppCurrentUser
{
    private readonly IHttpContextAccessor _httpContextAccessor;
    private readonly GameSpacedatabaseContext _context;

    public int UserId
    {
        get
        {
            // Claims優先：AppUserId > NameIdentifier > 資料庫查詢
            var appUserIdClaim = _httpContextAccessor.HttpContext?.User?.FindFirst("AppUserId");
            if (appUserIdClaim != null && int.TryParse(appUserIdClaim.Value, out var appUserId))
                return appUserId;

            var nameIdentifierClaim = _httpContextAccessor.HttpContext?.User?.FindFirst(ClaimTypes.NameIdentifier);
            if (nameIdentifierClaim != null && int.TryParse(nameIdentifierClaim.Value, out var nameId))
                return nameId;

            // Fallback: 查資料庫
            var username = _httpContextAccessor.HttpContext?.User?.Identity?.Name;
            if (!string.IsNullOrEmpty(username))
            {
                var user = _context.Users.FirstOrDefault(u => u.User_Account == username || u.User_name == username);
                return user?.User_ID ?? 0;
            }

            return 0;
        }
    }

    public async Task<int> GetUserIdAsync(CancellationToken ct = default)
    {
        // 非同步版本，含資料庫fallback
    }
}
```

**Cookie Authentication (Program.cs, Line 73-87):**
```csharp
builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
    .AddCookie(options =>
    {
        options.Cookie.Name = "GamiPort.User"; // ≠ AdminCookie
        options.LoginPath = "/Login/Login/Login";
        options.LogoutPath = "/Login/Login/Logout";
        options.AccessDeniedPath = "/Login/Login/Denied";
        options.ExpireTimeSpan = TimeSpan.FromDays(7);
        options.SlidingExpiration = true;
        options.Cookie.SameSite = SameSiteMode.Lax;
        options.Cookie.HttpOnly = true;
    });
```

### 2.2 Service層模式 (from Forum Area)

**Service Interface:**
```csharp
// Areas/Forum/Services/IForumsService.cs
public interface IForumsService
{
    Task<ForumViewModel> GetForumAsync(int forumId, CancellationToken ct);
    Task<IEnumerable<ThreadViewModel>> GetThreadsAsync(int forumId, int page, int pageSize, CancellationToken ct);
}
```

**Service Implementation:**
```csharp
// Areas/Forum/Services/ForumsService.cs
public class ForumsService : IForumsService
{
    private readonly GameSpacedatabaseContext _context;
    private readonly ILogger<ForumsService> _logger;

    public ForumsService(GameSpacedatabaseContext context, ILogger<ForumsService> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task<ForumViewModel> GetForumAsync(int forumId, CancellationToken ct)
    {
        return await _context.Forums
            .AsNoTracking() // ★ 唯讀查詢使用AsNoTracking
            .Where(f => !f.IsDeleted)
            .Select(f => new ForumViewModel
            {
                ForumId = f.forum_id,
                GameId = f.game_id,
                // ... 其他欄位
            })
            .FirstOrDefaultAsync(ct);
    }
}
```

### 2.3 Controller模式 (from OnlineStore Area)

**Controller Pattern:**
```csharp
[Area("OnlineStore")]
[Authorize] // ★ 使用[Authorize]屬性，不手動檢查
public class CartController : Controller
{
    private readonly ICartService _cartService;
    private readonly IAppCurrentUser _currentUser;
    private readonly ILogger<CartController> _logger;

    public CartController(
        ICartService cartService,
        IAppCurrentUser currentUser,
        ILogger<CartController> logger)
    {
        _cartService = cartService;
        _currentUser = currentUser;
        _logger = logger;
    }

    // GET: /OnlineStore/Cart
    public async Task<IActionResult> Index(CancellationToken ct)
    {
        var userId = await _currentUser.GetUserIdAsync(ct);
        var cart = await _cartService.GetCartAsync(userId, ct);
        return View(cart);
    }

    // POST: /OnlineStore/Cart/AddItem
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> AddItem(int productId, int quantity, CancellationToken ct)
    {
        var userId = await _currentUser.GetUserIdAsync(ct);
        var success = await _cartService.AddItemAsync(userId, productId, quantity, ct);

        if (success)
            TempData["Success"] = "商品已加入購物車";
        else
            TempData["Error"] = "加入失敗，請稍後再試";

        return RedirectToAction(nameof(Index));
    }
}
```

### 2.4 API Controller模式 (from Forum Area)

**API Controller:**
```csharp
[Area("Forum")]
[Route("api/[area]/[controller]")]
[ApiController]
[Authorize]
public class ForumsApiController : ControllerBase
{
    private readonly IForumsService _service;

    public ForumsApiController(IForumsService service)
    {
        _service = service;
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<ForumDto>> GetForum(int id, CancellationToken ct)
    {
        var forum = await _service.GetForumAsync(id, ct);
        return forum == null ? NotFound() : Ok(forum);
    }

    [HttpPost]
    [ValidateAntiForgeryToken] // ★ 同源POST需要CSRF token
    public async Task<ActionResult<ForumDto>> CreateForum([FromBody] CreateForumRequest req, CancellationToken ct)
    {
        var result = await _service.CreateForumAsync(req, ct);
        return CreatedAtAction(nameof(GetForum), new { id = result.ForumId }, result);
    }
}
```

### 2.5 SignalR模式 (from social_hub Area)

**Hub Implementation:**
```csharp
[Authorize]
public class ChatHub : Hub
{
    private readonly IChatService _chatService;
    private readonly IAppCurrentUser _currentUser;

    public ChatHub(IChatService chatService, IAppCurrentUser currentUser)
    {
        _chatService = chatService;
        _currentUser = currentUser;
    }

    public async Task SendMessage(int recipientId, string message)
    {
        var senderId = _currentUser.UserId;
        var result = await _chatService.SendMessageAsync(senderId, recipientId, message);

        // 發送給接收者
        await Clients.User(recipientId.ToString()).SendAsync("ReceiveMessage", result);

        // 發送給自己（確認）
        await Clients.Caller.SendAsync("MessageSent", result);
    }

    public override async Task OnConnectedAsync()
    {
        var userId = _currentUser.UserId;
        await Groups.AddToGroupAsync(Context.ConnectionId, $"user_{userId}");
        await base.OnConnectedAsync();
    }
}
```

**SignalR Registration (Program.cs):**
```csharp
// Line 122-127
builder.Services.AddSignalR(options =>
{
    options.EnableDetailedErrors = true;
    options.KeepAliveInterval = TimeSpan.FromSeconds(15);
    options.ClientTimeoutInterval = TimeSpan.FromSeconds(60);
});

// Middleware中映射
app.MapHub<ChatHub>("/social_hub/chathub");
app.MapHub<SupportHub>("/hubs/support");
```

### 2.6 Service註冊模式 (from Program.cs)

**Scoped Services (每請求一個實例):**
```csharp
builder.Services.AddScoped<IForumsService, ForumsService>();
builder.Services.AddScoped<ICartService, SqlCartService>();
builder.Services.AddScoped<IChatService, ChatService>();
```

**Singleton Services (應用程式單例):**
```csharp
builder.Services.AddSingleton<IProfanityFilter>(sp =>
{
    // 使用IServiceScopeFactory手動建立scope存取DbContext
    var scopeFactory = sp.GetRequiredService<IServiceScopeFactory>();
    return new ProfanityFilter(scopeFactory, sp.GetRequiredService<ILogger<ProfanityFilter>>());
});

builder.Services.AddSingleton<IChatNotifier, SignalRChatNotifier>();
```

**User Context:**
```csharp
// Line 156
builder.Services.AddScoped<IAppCurrentUser, AppCurrentUser>();
```

### 2.7 靜態資源組織 (from wwwroot/)

**目錄結構:**
```
wwwroot/
├── css/
│   ├── layout-shell.css        - 雙欄彈性佈局 (topbar + sidebar + main)
│   ├── sidebar.css             - 側邊欄摺疊行為（icon-only）
│   ├── topbar1.css             - 頂部導航列
│   ├── topbar2.css             - 次要topbar
│   ├── right-rail.css          - 右側欄廣告
│   ├── site.css                - 全域樣式
│   ├── Forum/forum.css         - Area特定CSS
│   ├── OnlineStore/site.store.css
│   └── social_hub/chat-line.css
├── js/
│   ├── sidebar.js              - 側邊欄摺疊邏輯
│   └── [area-specific]/
└── lib/                        - Bootstrap 5.3.3, Bootstrap Icons 1.11.3
```

**CSS Variables (layout-shell.css):**
```css
:root {
    --topbar-h: 56px;
    --topbar-gap: 8px;
    --sidebar-w-open: 260px;
    --sidebar-w-collapsed: 72px;
    --sidebar-w: var(--sidebar-w-open);
    --banner-aspect: 1440/300;
    --banner-max-h: 260px;
}
```

---

## 3. 設計系統規範

### 3.1 Teal/Turquoise現代主題

**參考來源:** `MiniGame_Area想要採用的風格(淡藍現代系配色)/` (4張參考圖)

**色彩調色盤:**
```css
:root {
    /* 主色 */
    --minigame-primary: #17a2b8;           /* 深青藍色 */
    --minigame-primary-dark: #0d9488;      /* 較深的青藍 */
    --minigame-primary-light: #e0f2f1;     /* 淺青藍（highlight） */

    /* 背景 */
    --minigame-bg: #f0f4f8;                /* 極淺藍灰 */
    --minigame-bg-alt: #e8f0f4;            /* 替代背景 */
    --minigame-card-bg: #ffffff;           /* 卡片背景 */

    /* 強調色 */
    --minigame-accent: #ff9f43;            /* 橙色 CTA */
    --minigame-accent-alt: #ffa500;        /* 替代強調色 */

    /* 文字 */
    --minigame-text-primary: #2c3e50;      /* 深灰主文字 */
    --minigame-text-secondary: #718096;    /* 淺灰次要文字 */

    /* 陰影 */
    --minigame-shadow: 0 4px 12px rgba(0,0,0,0.08);
    --minigame-shadow-hover: 0 6px 16px rgba(0,0,0,0.12);

    /* 邊框圓角 */
    --minigame-border-radius: 16px;        /* 卡片 */
    --minigame-border-radius-lg: 24px;     /* 大元素 */
    --minigame-border-radius-sm: 8px;      /* 小元素 */

    /* 間距系統 (8px倍數) */
    --spacing-1: 8px;
    --spacing-2: 16px;
    --spacing-3: 24px;
    --spacing-4: 32px;
    --spacing-5: 48px;
    --spacing-6: 64px;
}
```

### 3.2 元件樣式模式

**卡片:**
```css
.minigame-card {
    background: var(--minigame-card-bg);
    border-radius: var(--minigame-border-radius);
    box-shadow: var(--minigame-shadow);
    padding: var(--spacing-3);
    transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.minigame-card:hover {
    transform: translateY(-4px);
    box-shadow: var(--minigame-shadow-hover);
}
```

**度量卡片 (Metric Cards):**
```css
.metric-card {
    text-align: center;
}

.metric-icon {
    font-size: 48px;
    color: var(--minigame-primary);
    margin-bottom: var(--spacing-2);
}

.metric-value {
    font-size: 2.5rem;
    font-weight: bold;
    color: var(--minigame-primary);
}
```

**圓形動作按鈕 (寵物互動):**
```css
.btn-action-circle {
    width: 100px;
    height: 100px;
    border-radius: 50%;
    border: 3px solid var(--minigame-primary);
    background: white;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: all 0.3s ease;
}

.btn-action-circle:hover:not(:disabled) {
    background: var(--minigame-primary);
    color: white;
    transform: scale(1.1);
}

.btn-action-circle:disabled {
    opacity: 0.4;
    cursor: not-allowed;
}
```

**進度條 (寵物屬性):**
```css
.stat-progress {
    height: 12px;
    background: var(--minigame-bg);
    border-radius: 8px;
    overflow: hidden;
}

.stat-progress-bar {
    height: 100%;
    background: linear-gradient(90deg, var(--minigame-primary-dark), var(--minigame-primary));
    transition: width 0.5s ease;
}
```

**日曆格子:**
```css
.calendar-grid {
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    gap: 8px;
}

.calendar-day {
    aspect-ratio: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 50%;
    cursor: pointer;
    transition: all 0.2s ease;
}

.calendar-day.signed-in {
    background: var(--minigame-primary);
    color: white;
    font-weight: bold;
}

.calendar-day.today {
    border: 2px solid var(--minigame-accent);
}
```

### 3.3 響應式斷點

```css
/* Mobile First */
@media (min-width: 768px) {
    /* Tablet */
}

@media (min-width: 1024px) {
    /* Desktop */
}

@media (min-width: 1440px) {
    /* Large Desktop */
}
```

### 3.4 Typography

```css
body {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
    line-height: 1.6;
    color: var(--minigame-text-primary);
}

h1, h2, h3, h4, h5, h6 {
    font-weight: 600;
    color: var(--minigame-text-primary);
}

.text-muted {
    color: var(--minigame-text-secondary);
}
```

---

## 4. Service層開發計劃

### 4.1 Wallet Services (7個)

**檔案結構:**
```
Areas/MiniGame/Services/Wallet/
├── IWalletService.cs
├── WalletService.cs
├── ICouponService.cs
├── CouponService.cs
├── IEVoucherService.cs
└── EVoucherService.cs
```

**IWalletService.cs:**
```csharp
namespace GamiPort.Areas.MiniGame.Services.Wallet;

public interface IWalletService
{
    // 查詢
    Task<WalletViewModel> GetWalletAsync(int userId, CancellationToken ct = default);
    Task<IEnumerable<WalletHistoryViewModel>> GetHistoryAsync(
        int userId, int page, int pageSize, CancellationToken ct = default);
    Task<int> GetPointBalanceAsync(int userId, CancellationToken ct = default);
}
```

**ICouponService.cs:**
```csharp
public interface ICouponService
{
    Task<IEnumerable<CouponViewModel>> GetUserCouponsAsync(int userId, bool includeUsed, CancellationToken ct);
    Task<IEnumerable<CouponTypeViewModel>> GetAvailableCouponTypesAsync(CancellationToken ct);
    Task<bool> ExchangeCouponAsync(int userId, int couponTypeId, int pointsCost, CancellationToken ct);
    Task<bool> CanExchangeAsync(int userId, int couponTypeId, CancellationToken ct);
}
```

**IEVoucherService.cs:**
```csharp
public interface IEVoucherService
{
    Task<IEnumerable<EVoucherViewModel>> GetUserEVouchersAsync(int userId, bool includeUsed, CancellationToken ct);
    Task<EVoucherQRViewModel> GenerateQRCodeAsync(int evoucherId, CancellationToken ct);
    Task<bool> ExchangeEVoucherAsync(int userId, int evoucherTypeId, int pointsCost, CancellationToken ct);
}
```

**實作重點:**
- 使用GameSpacedatabaseContext存取資料
- 所有查詢使用AsNoTracking()
- 點數扣除操作使用Transaction
- 記錄到WalletHistory表
- 錯誤處理與日誌記錄

### 4.2 Pet Services (10個)

**檔案結構:**
```
Areas/MiniGame/Services/Pet/
├── IPetService.cs
├── PetService.cs
├── IPetInteractionService.cs
└── PetInteractionService.cs
```

**IPetService.cs:**
```csharp
public interface IPetService
{
    // 查詢
    Task<PetViewModel> GetUserPetAsync(int userId, CancellationToken ct);
    Task<PetCustomizationOptionsViewModel> GetCustomizationOptionsAsync(CancellationToken ct);

    // 變更
    Task<bool> UpdatePetNameAsync(int petId, string newName, CancellationToken ct);
    Task<bool> ChangeSkinColorAsync(int petId, string colorCode, int pointsCost, int userId, CancellationToken ct);
    Task<bool> ChangeBackgroundAsync(int petId, string backgroundCode, int pointsCost, int userId, CancellationToken ct);
    Task<bool> AddExperienceAsync(int petId, int exp, CancellationToken ct);
}
```

**IPetInteractionService.cs:**
```csharp
public interface IPetInteractionService
{
    Task<PetInteractionResult> FeedAsync(int petId, CancellationToken ct);
    Task<PetInteractionResult> PlayAsync(int petId, CancellationToken ct);
    Task<PetInteractionResult> CleanAsync(int petId, CancellationToken ct);
    Task<PetInteractionResult> SleepAsync(int petId, CancellationToken ct);
}

public class PetInteractionResult
{
    public bool Success { get; set; }
    public string Message { get; set; }
    public int HungerDelta { get; set; }
    public int MoodDelta { get; set; }
    public int StaminaDelta { get; set; }
    public int CleanlinessDelta { get; set; }
    public int HealthDelta { get; set; }
    public bool LeveledUp { get; set; }
    public int? PointsRewarded { get; set; }
    public int NewHunger { get; set; }
    public int NewMood { get; set; }
    public int NewStamina { get; set; }
    public int NewCleanliness { get; set; }
    public int NewHealth { get; set; }
    public int NewLevel { get; set; }
    public int NewExperience { get; set; }
}
```

**業務規則實作:**
- 屬性範圍: 0-100 (資料庫CHECK constraint強制)
- 互動效果:
  - Feed: +30 Hunger
  - Play: +40 Mood
  - Clean: +35 Cleanliness
  - Sleep: +50 Stamina
- Health恢復: 當所有4項屬性達100時恢復Health
- 升級檢查: 經驗值達門檻時自動升級並發放點數獎勵
- 膚色變更: 固定扣除2000點數

### 4.3 SignIn Services (5個)

**檔案結構:**
```
Areas/MiniGame/Services/SignIn/
├── ISignInService.cs
├── SignInService.cs
├── ISignInStatsService.cs
└── SignInStatsService.cs
```

**ISignInService.cs:**
```csharp
public interface ISignInService
{
    Task<SignInStatusViewModel> GetStatusAsync(int userId, CancellationToken ct);
    Task<SignInResult> SignInAsync(int userId, CancellationToken ct);
    Task<bool> CanSignInTodayAsync(int userId, CancellationToken ct);
    Task<IEnumerable<SignInCalendarDayViewModel>> GetMonthCalendarAsync(
        int userId, int year, int month, CancellationToken ct);
}

public class SignInResult
{
    public bool Success { get; set; }
    public string Message { get; set; }
    public int PointsGained { get; set; }
    public int ExpGained { get; set; }
    public string CouponGained { get; set; }
    public DateTime SignTime { get; set; }
}
```

**ISignInStatsService.cs:**
```csharp
public interface ISignInStatsService
{
    Task<IEnumerable<SignInHistoryViewModel>> GetHistoryAsync(
        int userId, int page, int pageSize, CancellationToken ct);
    Task<int> GetConsecutiveDaysAsync(int userId, CancellationToken ct);
    Task<int> GetTotalSignInsAsync(int userId, CancellationToken ct);
}
```

**業務規則實作:**
- 時區: Asia/Taipei (Taipei Standard Time)
- 每日限制: 每天只能簽到一次（00:00重置）
- 獎勵查詢: 從SignInRule表取得當天（第幾天）的獎勵
- 連續天數計算: 檢查UserSignInStats連續記錄
- Transaction: 發放獎勵時更新錢包、寵物經驗、優惠券

### 4.4 Game Services (6個)

**檔案結構:**
```
Areas/MiniGame/Services/Game/
├── IGamePlayService.cs
├── GamePlayService.cs
├── IDailyGameLimitService.cs
└── DailyGameLimitService.cs
```

**IGamePlayService.cs:**
```csharp
public interface IGamePlayService
{
    Task<GameSessionViewModel> StartGameAsync(int userId, int level, CancellationToken ct);
    Task<GameEndResult> EndGameAsync(string sessionId, GameEndRequest request, CancellationToken ct);
    Task<IEnumerable<GameRecordViewModel>> GetHistoryAsync(
        int userId, int page, int pageSize, CancellationToken ct);
}

public class GameSessionViewModel
{
    public string SessionId { get; set; } // GUID
    public DateTime StartTime { get; set; }
    public int Level { get; set; }
    public int MonsterCount { get; set; }
    public decimal SpeedMultiplier { get; set; }
    public int RemainingPlaysToday { get; set; }
}

public class GameEndRequest
{
    public string SessionId { get; set; }
    public string Result { get; set; } // "Win" | "Lose" | "Abort"
    public DateTime EndTime { get; set; }
}

public class GameEndResult
{
    public bool Success { get; set; }
    public int PointsGained { get; set; }
    public int ExpGained { get; set; }
    public string CouponGained { get; set; }
    public int HungerDelta { get; set; }
    public int MoodDelta { get; set; }
    public int StaminaDelta { get; set; }
    public int CleanlinessDelta { get; set; }
}
```

**IDailyGameLimitService.cs:**
```csharp
public interface IDailyGameLimitService
{
    Task<int> GetRemainingPlaysAsync(int userId, CancellationToken ct);
    Task<bool> CanPlayTodayAsync(int userId, CancellationToken ct);
    Task<int> GetMaxDailyPlaysAsync(CancellationToken ct);
}
```

**業務規則實作:**
- 每日限制: 預設3次（從SystemSettings.SettingKey = "MiniGame.MaxDailyPlays"讀取）
- 時區: Asia/Taipei，00:00重置
- 難度配置:
  - Level 1: 6怪物, 1x速度 → Win: +10點, +100 exp
  - Level 2: 8怪物, 1.5x速度 → Win: +20點, +200 exp
  - Level 3: 10怪物, 2x速度 → Win: +30點, +300 exp, +1優惠券
- 只有Win才發放獎勵
- Lose/Abort會降低寵物屬性
- Transaction: 發放獎勵時更新錢包、寵物、遊戲記錄

---

## 5. Controller層開發計劃

### 5.1 更新現有Controllers (4個)

#### WalletController.cs (完整實作)

**目標:** 移除手動auth檢查，注入服務，實作所有action

```csharp
using GamiPort.Areas.MiniGame.Services.Wallet;
using GamiPort.Areas.MiniGame.ViewModels.Wallet;
using GamiPort.Infrastructure.Security;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace GamiPort.Areas.MiniGame.Controllers;

[Area("MiniGame")]
[Authorize] // ★ 使用屬性取代手動檢查
public class WalletController : Controller
{
    private readonly IWalletService _walletService;
    private readonly ICouponService _couponService;
    private readonly IEVoucherService _evoucherService;
    private readonly IAppCurrentUser _currentUser;
    private readonly ILogger<WalletController> _logger;

    public WalletController(
        IWalletService walletService,
        ICouponService couponService,
        IEVoucherService evoucherService,
        IAppCurrentUser currentUser,
        ILogger<WalletController> logger)
    {
        _walletService = walletService;
        _couponService = couponService;
        _evoucherService = evoucherService;
        _currentUser = currentUser;
        _logger = logger;
    }

    // GET: /MiniGame/Wallet
    public async Task<IActionResult> Index(CancellationToken ct)
    {
        var userId = await _currentUser.GetUserIdAsync(ct);
        var wallet = await _walletService.GetWalletAsync(userId, ct);
        return View(wallet);
    }

    // GET: /MiniGame/Wallet/History?page=1
    public async Task<IActionResult> History(int page = 1, int pageSize = 20, CancellationToken ct)
    {
        var userId = await _currentUser.GetUserIdAsync(ct);
        var history = await _walletService.GetHistoryAsync(userId, page, pageSize, ct);
        return View(history);
    }

    // GET: /MiniGame/Wallet/Coupons
    public async Task<IActionResult> Coupons(CancellationToken ct)
    {
        var userId = await _currentUser.GetUserIdAsync(ct);
        var coupons = await _couponService.GetUserCouponsAsync(userId, includeUsed: false, ct);
        var availableTypes = await _couponService.GetAvailableCouponTypesAsync(ct);

        var viewModel = new CouponsPageViewModel
        {
            UserCoupons = coupons,
            AvailableTypes = availableTypes
        };

        return View(viewModel);
    }

    // POST: /MiniGame/Wallet/ExchangeCoupon
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> ExchangeCoupon(int couponTypeId, int pointsCost, CancellationToken ct)
    {
        var userId = await _currentUser.GetUserIdAsync(ct);
        var canExchange = await _couponService.CanExchangeAsync(userId, couponTypeId, ct);

        if (!canExchange)
        {
            TempData["Error"] = "點數不足或優惠券類型無效";
            return RedirectToAction(nameof(Coupons));
        }

        var success = await _couponService.ExchangeCouponAsync(userId, couponTypeId, pointsCost, ct);

        if (success)
            TempData["Success"] = "優惠券兌換成功！";
        else
            TempData["Error"] = "兌換失敗，請稍後再試";

        return RedirectToAction(nameof(Coupons));
    }

    // GET: /MiniGame/Wallet/EVouchers
    public async Task<IActionResult> EVouchers(CancellationToken ct)
    {
        var userId = await _currentUser.GetUserIdAsync(ct);
        var evouchers = await _evoucherService.GetUserEVouchersAsync(userId, includeUsed: false, ct);
        return View(evouchers);
    }

    // GET: /MiniGame/Wallet/EVoucherQR/{id}
    public async Task<IActionResult> EVoucherQR(int id, CancellationToken ct)
    {
        var qr = await _evoucherService.GenerateQRCodeAsync(id, ct);
        return View(qr);
    }
}
```

#### PetController.cs (完整實作)

```csharp
[Area("MiniGame")]
[Authorize]
public class PetController : Controller
{
    private readonly IPetService _petService;
    private readonly IPetInteractionService _petInteractionService;
    private readonly IAppCurrentUser _currentUser;
    private readonly ILogger<PetController> _logger;

    public PetController(
        IPetService petService,
        IPetInteractionService petInteractionService,
        IAppCurrentUser currentUser,
        ILogger<PetController> logger)
    {
        _petService = petService;
        _petInteractionService = petInteractionService;
        _currentUser = currentUser;
        _logger = logger;
    }

    // GET: /MiniGame/Pet
    public async Task<IActionResult> Index(CancellationToken ct)
    {
        var userId = await _currentUser.GetUserIdAsync(ct);
        var pet = await _petService.GetUserPetAsync(userId, ct);
        return View(pet);
    }

    // POST: /MiniGame/Pet/Feed
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Feed(int petId, CancellationToken ct)
    {
        var result = await _petInteractionService.FeedAsync(petId, ct);
        return Json(result);
    }

    // POST: /MiniGame/Pet/Play
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Play(int petId, CancellationToken ct)
    {
        var result = await _petInteractionService.PlayAsync(petId, ct);
        return Json(result);
    }

    // POST: /MiniGame/Pet/Clean
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Clean(int petId, CancellationToken ct)
    {
        var result = await _petInteractionService.CleanAsync(petId, ct);
        return Json(result);
    }

    // POST: /MiniGame/Pet/Sleep
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Sleep(int petId, CancellationToken ct)
    {
        var result = await _petInteractionService.SleepAsync(petId, ct);
        return Json(result);
    }

    // GET: /MiniGame/Pet/Customize
    public async Task<IActionResult> Customize(CancellationToken ct)
    {
        var userId = await _currentUser.GetUserIdAsync(ct);
        var pet = await _petService.GetUserPetAsync(userId, ct);
        var options = await _petService.GetCustomizationOptionsAsync(ct);

        var viewModel = new PetCustomizationViewModel
        {
            Pet = pet,
            Options = options
        };

        return View(viewModel);
    }

    // POST: /MiniGame/Pet/ChangeSkinColor
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> ChangeSkinColor(int petId, string colorCode, int pointsCost, CancellationToken ct)
    {
        var userId = await _currentUser.GetUserIdAsync(ct);
        var success = await _petService.ChangeSkinColorAsync(petId, colorCode, pointsCost, userId, ct);
        return Json(new { success });
    }

    // POST: /MiniGame/Pet/ChangeBackground
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> ChangeBackground(int petId, string backgroundCode, int pointsCost, CancellationToken ct)
    {
        var userId = await _currentUser.GetUserIdAsync(ct);
        var success = await _petService.ChangeBackgroundAsync(petId, backgroundCode, pointsCost, userId, ct);
        return Json(new { success });
    }

    // POST: /MiniGame/Pet/UpdateName
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> UpdateName(int petId, string newName, CancellationToken ct)
    {
        var success = await _petService.UpdatePetNameAsync(petId, newName, ct);
        return Json(new { success });
    }
}
```

#### SignInController.cs (完整實作)

```csharp
[Area("MiniGame")]
[Authorize]
public class SignInController : Controller
{
    private readonly ISignInService _signInService;
    private readonly ISignInStatsService _signInStatsService;
    private readonly IAppCurrentUser _currentUser;
    private readonly ILogger<SignInController> _logger;

    public SignInController(
        ISignInService signInService,
        ISignInStatsService signInStatsService,
        IAppCurrentUser currentUser,
        ILogger<SignInController> logger)
    {
        _signInService = signInService;
        _signInStatsService = signInStatsService;
        _currentUser = currentUser;
        _logger = logger;
    }

    // GET: /MiniGame/SignIn
    public async Task<IActionResult> Index(CancellationToken ct)
    {
        var userId = await _currentUser.GetUserIdAsync(ct);
        var status = await _signInService.GetStatusAsync(userId, ct);
        return View(status);
    }

    // POST: /MiniGame/SignIn/CheckIn
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> CheckIn(CancellationToken ct)
    {
        var userId = await _currentUser.GetUserIdAsync(ct);

        var canSignIn = await _signInService.CanSignInTodayAsync(userId, ct);
        if (!canSignIn)
        {
            return Json(new { success = false, message = "今日已簽到或簽到功能暫時無法使用" });
        }

        var result = await _signInService.SignInAsync(userId, ct);
        return Json(result);
    }

    // GET: /MiniGame/SignIn/Calendar?year=2025&month=11
    public async Task<IActionResult> Calendar(int year, int month, CancellationToken ct)
    {
        var userId = await _currentUser.GetUserIdAsync(ct);
        var calendar = await _signInService.GetMonthCalendarAsync(userId, year, month, ct);
        return Json(calendar);
    }

    // GET: /MiniGame/SignIn/History?page=1
    public async Task<IActionResult> History(int page = 1, int pageSize = 20, CancellationToken ct)
    {
        var userId = await _currentUser.GetUserIdAsync(ct);
        var history = await _signInStatsService.GetHistoryAsync(userId, page, pageSize, ct);
        return View(history);
    }
}
```

### 5.2 新增GameController.cs

```csharp
[Area("MiniGame")]
[Authorize]
public class GameController : Controller
{
    private readonly IGamePlayService _gamePlayService;
    private readonly IDailyGameLimitService _dailyGameLimitService;
    private readonly IAppCurrentUser _currentUser;
    private readonly ILogger<GameController> _logger;

    public GameController(
        IGamePlayService gamePlayService,
        IDailyGameLimitService dailyGameLimitService,
        IAppCurrentUser currentUser,
        ILogger<GameController> logger)
    {
        _gamePlayService = gamePlayService;
        _dailyGameLimitService = dailyGameLimitService;
        _currentUser = currentUser;
        _logger = logger;
    }

    // GET: /MiniGame/Game
    public async Task<IActionResult> Index(CancellationToken ct)
    {
        var userId = await _currentUser.GetUserIdAsync(ct);
        var remainingPlays = await _dailyGameLimitService.GetRemainingPlaysAsync(userId, ct);

        ViewBag.RemainingPlays = remainingPlays;
        return View();
    }

    // POST: /MiniGame/Game/Start
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Start(int level, CancellationToken ct)
    {
        var userId = await _currentUser.GetUserIdAsync(ct);

        var canPlay = await _dailyGameLimitService.CanPlayTodayAsync(userId, ct);
        if (!canPlay)
        {
            return Json(new { success = false, message = "今日遊戲次數已達上限" });
        }

        var session = await _gamePlayService.StartGameAsync(userId, level, ct);
        return Json(new { success = true, session });
    }

    // POST: /MiniGame/Game/End
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> End([FromBody] GameEndRequest request, CancellationToken ct)
    {
        var result = await _gamePlayService.EndGameAsync(request.SessionId, request, ct);
        return Json(result);
    }

    // GET: /MiniGame/Game/History?page=1
    public async Task<IActionResult> History(int page = 1, int pageSize = 20, CancellationToken ct)
    {
        var userId = await _currentUser.GetUserIdAsync(ct);
        var history = await _gamePlayService.GetHistoryAsync(userId, page, pageSize, ct);
        return View(history);
    }

    // GET: /MiniGame/Game/RemainingPlays
    public async Task<IActionResult> RemainingPlays(CancellationToken ct)
    {
        var userId = await _currentUser.GetUserIdAsync(ct);
        var remaining = await _dailyGameLimitService.GetRemainingPlaysAsync(userId, ct);
        return Json(new { remaining });
    }
}
```

---

## 6. ViewModel開發計劃

### 6.1 Wallet ViewModels (10個)

**檔案結構:**
```
Areas/MiniGame/ViewModels/Wallet/
├── WalletViewModel.cs
├── WalletHistoryViewModel.cs
├── CouponViewModel.cs
├── CouponTypeViewModel.cs
├── CouponsPageViewModel.cs
├── EVoucherViewModel.cs
├── EVoucherTypeViewModel.cs
├── EVoucherQRViewModel.cs
└── EVouchersPageViewModel.cs
```

**範例 - WalletViewModel.cs:**
```csharp
namespace GamiPort.Areas.MiniGame.ViewModels.Wallet;

public class WalletViewModel
{
    public int UserId { get; set; }
    public int PointBalance { get; set; }
    public int TotalCoupons { get; set; }
    public int UnusedCoupons { get; set; }
    public int TotalEVouchers { get; set; }
    public int UnusedEVouchers { get; set; }
    public IEnumerable<CouponSummaryViewModel> RecentCoupons { get; set; }
    public IEnumerable<EVoucherSummaryViewModel> RecentEVouchers { get; set; }
}

public class CouponSummaryViewModel
{
    public int CouponID { get; set; }
    public string CouponCode { get; set; }
    public string TypeName { get; set; }
    public string DiscountType { get; set; }
    public decimal DiscountValue { get; set; }
    public DateTime ValidFrom { get; set; }
    public DateTime ValidTo { get; set; }
}
```

### 6.2 Pet ViewModels (8個)

**檔案結構:**
```
Areas/MiniGame/ViewModels/Pet/
├── PetViewModel.cs
├── PetCustomizationViewModel.cs
├── PetCustomizationOptionsViewModel.cs
├── SkinColorOptionViewModel.cs
└── BackgroundOptionViewModel.cs
```

**範例 - PetViewModel.cs:**
```csharp
namespace GamiPort.Areas.MiniGame.ViewModels.Pet;

public class PetViewModel
{
    public int PetID { get; set; }
    public int UserID { get; set; }
    public string PetName { get; set; }
    public int Level { get; set; }
    public int CurrentExperience { get; set; }
    public int ExperienceToNextLevel { get; set; }
    public int ExperiencePercentage => ExperienceToNextLevel > 0
        ? (int)((double)CurrentExperience / ExperienceToNextLevel * 100)
        : 0;

    // 屬性 (0-100)
    public int Hunger { get; set; }
    public int Mood { get; set; }
    public int Stamina { get; set; }
    public int Cleanliness { get; set; }
    public int Health { get; set; }

    // 外觀
    public string SkinColor { get; set; } // #RRGGBB
    public string BackgroundColor { get; set; }

    // 狀態
    public bool CanInteract => Stamina > 0;
    public DateTime? LastInteractionTime { get; set; }
}
```

### 6.3 SignIn ViewModels (5個)

**檔案結構:**
```
Areas/MiniGame/ViewModels/SignIn/
├── SignInStatusViewModel.cs
├── SignInRewardPreviewViewModel.cs
├── SignInCalendarDayViewModel.cs
└── SignInHistoryViewModel.cs
```

**範例 - SignInStatusViewModel.cs:**
```csharp
namespace GamiPort.Areas.MiniGame.ViewModels.SignIn;

public class SignInStatusViewModel
{
    public bool CanSignInToday { get; set; }
    public bool HasSignedInToday { get; set; }
    public DateTime? LastSignInTime { get; set; }
    public int ConsecutiveDays { get; set; }
    public int TotalSignIns { get; set; }
    public SignInRewardPreviewViewModel TodayReward { get; set; }
}

public class SignInRewardPreviewViewModel
{
    public int Points { get; set; }
    public int Experience { get; set; }
    public bool HasCoupon { get; set; }
    public string CouponTypeCode { get; set; }
    public string CouponTypeName { get; set; }
}
```

### 6.4 Game ViewModels (5個)

**檔案結構:**
```
Areas/MiniGame/ViewModels/Game/
├── GameSessionViewModel.cs
├── GameEndRequest.cs
├── GameEndResult.cs
└── GameRecordViewModel.cs
```

**範例 - GameRecordViewModel.cs:**
```csharp
namespace GamiPort.Areas.MiniGame.ViewModels.Game;

public class GameRecordViewModel
{
    public int PlayID { get; set; }
    public DateTime StartTime { get; set; }
    public DateTime? EndTime { get; set; }
    public int Level { get; set; }
    public string Result { get; set; } // "Win" | "Lose" | "Abort"
    public int ExpGained { get; set; }
    public int PointsGained { get; set; }
    public string CouponGained { get; set; }
    public TimeSpan? Duration => EndTime.HasValue ? EndTime.Value - StartTime : null;

    public string ResultBadgeClass => Result switch
    {
        "Win" => "badge bg-success",
        "Lose" => "badge bg-danger",
        "Abort" => "badge bg-secondary",
        _ => "badge bg-secondary"
    };
}
```

---

## 7. View層開發計劃

### 7.1 Wallet/Index.cshtml (完整實作)

**目標:** 顯示點數餘額、優惠券、電子券摘要，recent transactions

```html
@model WalletViewModel
@{
    ViewData["Title"] = "我的錢包";
}

@section Styles {
    <link rel="stylesheet" href="~/css/MiniGame/wallet.css" />
}

<div class="minigame-wallet-container">
    <!-- Header -->
    <div class="wallet-header mb-4">
        <h2><i class="bi bi-wallet2"></i> 我的錢包</h2>
    </div>

    <!-- Metric Cards Row -->
    <div class="row g-4 mb-4">
        <!-- Points Card -->
        <div class="col-md-4">
            <div class="minigame-card metric-card">
                <div class="metric-icon">
                    <i class="bi bi-coin"></i>
                </div>
                <h5 class="metric-label">點數餘額</h5>
                <p class="metric-value">@Model.PointBalance</p>
                <small class="text-muted">可用於兌換優惠券、電子券</small>
            </div>
        </div>

        <!-- Coupons Card -->
        <div class="col-md-4">
            <div class="minigame-card metric-card">
                <div class="metric-icon">
                    <i class="bi bi-ticket-perforated"></i>
                </div>
                <h5 class="metric-label">優惠券</h5>
                <p class="metric-value">@Model.UnusedCoupons / @Model.TotalCoupons</p>
                <a href="@Url.Action("Coupons")" class="btn btn-sm btn-outline-primary mt-2">查看全部</a>
            </div>
        </div>

        <!-- E-Vouchers Card -->
        <div class="col-md-4">
            <div class="minigame-card metric-card">
                <div class="metric-icon">
                    <i class="bi bi-qr-code"></i>
                </div>
                <h5 class="metric-label">電子券</h5>
                <p class="metric-value">@Model.UnusedEVouchers / @Model.TotalEVouchers</p>
                <a href="@Url.Action("EVouchers")" class="btn btn-sm btn-outline-primary mt-2">查看全部</a>
            </div>
        </div>
    </div>

    <!-- Quick Actions -->
    <div class="minigame-card mb-4">
        <h5 class="mb-3"><i class="bi bi-lightning"></i> 快速操作</h5>
        <div class="row g-3">
            <div class="col-md-4">
                <a href="@Url.Action("Coupons")" class="btn btn-primary w-100">
                    <i class="bi bi-ticket"></i> 兌換優惠券
                </a>
            </div>
            <div class="col-md-4">
                <a href="@Url.Action("EVouchers")" class="btn btn-primary w-100">
                    <i class="bi bi-qr-code-scan"></i> 兌換電子券
                </a>
            </div>
            <div class="col-md-4">
                <a href="@Url.Action("History")" class="btn btn-outline-secondary w-100">
                    <i class="bi bi-clock-history"></i> 交易記錄
                </a>
            </div>
        </div>
    </div>

    <!-- Recent Coupons -->
    @if (Model.RecentCoupons?.Any() == true)
    {
        <div class="minigame-card mb-4">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h5 class="mb-0"><i class="bi bi-ticket-detailed"></i> 最近獲得的優惠券</h5>
                <a href="@Url.Action("Coupons")" class="btn btn-sm btn-link">查看全部</a>
            </div>
            <div class="row g-3">
                @foreach (var coupon in Model.RecentCoupons.Take(3))
                {
                    <div class="col-md-4">
                        <div class="coupon-item">
                            <h6>@coupon.TypeName</h6>
                            <p class="coupon-discount">
                                @if (coupon.DiscountType == "PERCENT")
                                {
                                    <text>@coupon.DiscountValue% 折扣</text>
                                }
                                else
                                {
                                    <text>NT$ @coupon.DiscountValue 折抵</text>
                                }
                            </p>
                            <small class="text-muted">
                                有效期限: @coupon.ValidFrom.ToString("yyyy/MM/dd") ~ @coupon.ValidTo.ToString("yyyy/MM/dd")
                            </small>
                        </div>
                    </div>
                }
            </div>
        </div>
    }
</div>

@section Scripts {
    <script src="~/js/MiniGame/wallet.js"></script>
}
```

### 7.2 Pet/Index.cshtml (完整實作 - 已在先前提供)

**重點內容:**
- 寵物展示區 (背景色、膚色)
- 寵物名稱 (可編輯)
- 等級與經驗進度條
- 5項屬性進度條 (Hunger, Mood, Stamina, Cleanliness, Health)
- 4個互動按鈕 (餵食、洗澡、玩耍、哄睡) - 圓形設計
- 開始遊戲按鈕
- 外觀設定連結
- 冒險記錄區域

### 7.3 SignIn/Index.cshtml (完整實作 - 已在先前提供)

**重點內容:**
- 簽到狀態卡片 (今日是否可簽到)
- 獎勵預覽 (點數、經驗、優惠券)
- 立即簽到按鈕
- 連續簽到天數、累計簽到次數統計
- 月曆檢視 (標記已簽到日期)
- 簽到歷史列表

### 7.4 Game/Index.cshtml (新增)

```html
@{
    ViewData["Title"] = "小遊戲";
}

@section Styles {
    <link rel="stylesheet" href="~/css/MiniGame/game.css" />
}

<div class="minigame-game-container">
    <!-- Header -->
    <div class="game-header mb-4">
        <h2><i class="bi bi-joystick"></i> 冒險遊戲</h2>
        <p class="text-muted">今日剩餘遊戲次數: <span id="remainingPlays" class="badge bg-primary">@ViewBag.RemainingPlays</span></p>
    </div>

    <!-- Level Selection -->
    <div class="minigame-card mb-4">
        <h5 class="mb-3">選擇難度</h5>
        <div class="row g-3">
            <!-- Level 1 -->
            <div class="col-md-4">
                <div class="level-card" data-level="1">
                    <div class="level-icon">
                        <i class="bi bi-shield"></i>
                    </div>
                    <h4>簡單</h4>
                    <p class="level-desc">6隻怪物，1x速度</p>
                    <p class="level-reward">
                        <i class="bi bi-coin"></i> +10點數<br />
                        <i class="bi bi-star"></i> +100經驗
                    </p>
                    <button class="btn btn-primary w-100" onclick="selectLevel(1)">開始冒險</button>
                </div>
            </div>

            <!-- Level 2 -->
            <div class="col-md-4">
                <div class="level-card" data-level="2">
                    <div class="level-icon">
                        <i class="bi bi-shield-plus"></i>
                    </div>
                    <h4>普通</h4>
                    <p class="level-desc">8隻怪物，1.5x速度</p>
                    <p class="level-reward">
                        <i class="bi bi-coin"></i> +20點數<br />
                        <i class="bi bi-star"></i> +200經驗
                    </p>
                    <button class="btn btn-primary w-100" onclick="selectLevel(2)">開始冒險</button>
                </div>
            </div>

            <!-- Level 3 -->
            <div class="col-md-4">
                <div class="level-card level-card-hard" data-level="3">
                    <div class="level-icon">
                        <i class="bi bi-shield-fill-exclamation"></i>
                    </div>
                    <h4>困難</h4>
                    <p class="level-desc">10隻怪物，2x速度</p>
                    <p class="level-reward">
                        <i class="bi bi-coin"></i> +30點數<br />
                        <i class="bi bi-star"></i> +300經驗<br />
                        <i class="bi bi-gift"></i> +1優惠券
                    </p>
                    <button class="btn btn-primary w-100" onclick="selectLevel(3)">開始冒險</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Game Canvas (Hidden initially) -->
    <div id="gameCanvas" class="minigame-card mb-4" style="display: none;">
        <canvas id="canvas" width="800" height="600"></canvas>
        <div class="game-controls mt-3">
            <button class="btn btn-danger" onclick="abortGame()">放棄遊戲</button>
        </div>
    </div>

    <!-- Game History -->
    <div class="minigame-card">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h5 class="mb-0"><i class="bi bi-clock-history"></i> 冒險記錄</h5>
            <a href="@Url.Action("History")" class="btn btn-sm btn-link">查看全部</a>
        </div>
        <div id="recentHistory">
            <p class="text-muted">載入中...</p>
        </div>
    </div>
</div>

@section Scripts {
    <script src="~/js/MiniGame/game.js"></script>
    <script>
        $(document).ready(function() {
            loadRecentHistory();
            loadRemainingPlays();
        });
    </script>
}
```

---

## 8. Client-Side JavaScript

### 8.1 共用工具 (common.js)

```javascript
// Areas/MiniGame/wwwroot/js/MiniGame/common.js

// 取得Anti-forgery token
function getAntiForgeryToken() {
    return document.querySelector('input[name="__RequestVerificationToken"]')?.value;
}

// 安全的Fetch (自動加CSRF token)
async function secureFetch(url, options = {}) {
    const token = getAntiForgeryToken();

    options.headers = {
        ...options.headers,
        'RequestVerificationToken': token,
        'Content-Type': 'application/json'
    };

    const response = await fetch(url, options);

    if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
    }

    return response.json();
}

// Toast通知 (使用Bootstrap Toast)
function showToast(type, message, duration = 3000) {
    const toastHtml = `
        <div class="toast align-items-center text-white bg-${type === 'success' ? 'success' : 'danger'} border-0" role="alert" aria-live="assertive" aria-atomic="true">
            <div class="d-flex">
                <div class="toast-body">
                    <i class="bi bi-${type === 'success' ? 'check-circle' : 'x-circle'}"></i> ${message}
                </div>
                <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
            </div>
        </div>
    `;

    const toastContainer = document.getElementById('toastContainer');
    if (!toastContainer) {
        document.body.insertAdjacentHTML('beforeend', '<div id="toastContainer" class="toast-container position-fixed bottom-0 end-0 p-3"></div>');
    }

    document.getElementById('toastContainer').insertAdjacentHTML('beforeend', toastHtml);

    const toastElement = document.querySelector('.toast:last-child');
    const toast = new bootstrap.Toast(toastElement, { autohide: true, delay: duration });
    toast.show();

    toastElement.addEventListener('hidden.bs.toast', () => {
        toastElement.remove();
    });
}

// 格式化日期
function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString('zh-TW', { year: 'numeric', month: '2-digit', day: '2-digit' });
}

// 格式化日期時間
function formatDateTime(dateString) {
    const date = new Date(dateString);
    return date.toLocaleString('zh-TW', { year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit' });
}
```

### 8.2 寵物互動 (pet.js)

```javascript
// wwwroot/js/MiniGame/pet.js

// 寵物互動
async function petAction(action, petId) {
    const actionNames = {
        'feed': '餵食',
        'play': '玩耍',
        'clean': '洗澡',
        'sleep': '哄睡'
    };

    try {
        const result = await secureFetch(`/MiniGame/Pet/${action.charAt(0).toUpperCase() + action.slice(1)}`, {
            method: 'POST',
            body: JSON.stringify({ petId })
        });

        if (result.success) {
            showToast('success', result.message);
            updatePetStats(result);

            if (result.leveledUp) {
                showLevelUpModal(result.newLevel, result.pointsRewarded);
            }
        } else {
            showToast('error', result.message);
        }
    } catch (error) {
        console.error('Pet action error:', error);
        showToast('error', `${actionNames[action]}失敗，請稍後再試`);
    }
}

// 更新寵物屬性 (UI)
function updatePetStats(result) {
    // 更新Hunger
    updateStatBar('hunger', result.newHunger);
    // 更新Mood
    updateStatBar('mood', result.newMood);
    // 更新Stamina
    updateStatBar('stamina', result.newStamina);
    // 更新Cleanliness
    updateStatBar('cleanliness', result.newCleanliness);
    // 更新Health
    updateStatBar('health', result.newHealth);

    // 更新等級與經驗
    if (result.newLevel) {
        document.querySelector('[data-pet-level]').textContent = `Lv. ${result.newLevel}`;
    }
    if (result.newExperience !== undefined) {
        updateExpBar(result.newExperience, result.experienceToNextLevel);
    }
}

// 更新單一屬性進度條
function updateStatBar(statName, newValue) {
    const progressBar = document.querySelector(`[data-stat="${statName}"] .stat-progress-bar`);
    const valueText = document.querySelector(`[data-stat="${statName}"] .stat-value`);

    if (progressBar) {
        progressBar.style.width = `${newValue}%`;
        // 動畫效果
        progressBar.classList.add('stat-updating');
        setTimeout(() => progressBar.classList.remove('stat-updating'), 500);
    }

    if (valueText) {
        valueText.textContent = `${newValue} / 100`;
    }
}

// 更新經驗值進度條
function updateExpBar(currentExp, toNextLevel) {
    const percentage = toNextLevel > 0 ? (currentExp / toNextLevel * 100) : 0;
    const expBar = document.querySelector('[data-exp-bar]');
    const expText = document.querySelector('[data-exp-text]');

    if (expBar) {
        expBar.style.width = `${percentage}%`;
    }

    if (expText) {
        expText.textContent = `${currentExp} / ${toNextLevel} EXP`;
    }
}

// 顯示升級Modal
function showLevelUpModal(newLevel, pointsRewarded) {
    const modalHtml = `
        <div class="modal fade" id="levelUpModal" tabindex="-1">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header bg-primary text-white">
                        <h5 class="modal-title"><i class="bi bi-star-fill"></i> 恭喜升級！</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body text-center">
                        <div class="level-up-animation mb-3">
                            <i class="bi bi-trophy-fill" style="font-size: 64px; color: gold;"></i>
                        </div>
                        <h3>Lv. ${newLevel}</h3>
                        <p class="lead">寵物升級了！</p>
                        ${pointsRewarded ? `<p>獲得 <strong>${pointsRewarded}</strong> 點數獎勵</p>` : ''}
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-primary" data-bs-dismiss="modal">太棒了！</button>
                    </div>
                </div>
            </div>
        </div>
    `;

    document.body.insertAdjacentHTML('beforeend', modalHtml);
    const modal = new bootstrap.Modal(document.getElementById('levelUpModal'));
    modal.show();

    document.getElementById('levelUpModal').addEventListener('hidden.bs.modal', function () {
        this.remove();
    });
}

// 編輯寵物名稱
async function editPetName() {
    const currentName = document.getElementById('petNameDisplay').textContent;

    const newName = prompt('請輸入新的寵物名稱:', currentName);
    if (!newName || newName === currentName) return;

    try {
        const petId = document.querySelector('[data-pet-id]').dataset.petId;
        const result = await secureFetch('/MiniGame/Pet/UpdateName', {
            method: 'POST',
            body: JSON.stringify({ petId: parseInt(petId), newName })
        });

        if (result.success) {
            document.getElementById('petNameDisplay').textContent = newName;
            showToast('success', '寵物名稱已更新');
        } else {
            showToast('error', '更新失敗');
        }
    } catch (error) {
        console.error('Update name error:', error);
        showToast('error', '更新失敗，請稍後再試');
    }
}

// 載入剩餘遊戲次數
async function loadRemainingPlays() {
    try {
        const response = await fetch('/MiniGame/Game/RemainingPlays');
        const data = await response.json();
        document.getElementById('remainingPlays').textContent = data.remaining;
    } catch (error) {
        console.error('Failed to load remaining plays:', error);
    }
}

// 開始遊戲
function startGame() {
    window.location.href = '/MiniGame/Game';
}
```

### 8.3 簽到功能 (signin.js)

```javascript
// wwwroot/js/MiniGame/signin.js

let currentYear = new Date().getFullYear();
let currentMonth = new Date().getMonth() + 1;

// 簽到
async function checkIn() {
    try {
        const result = await secureFetch('/MiniGame/SignIn/CheckIn', {
            method: 'POST'
        });

        if (result.success) {
            showToast('success', `簽到成功！獲得 ${result.pointsGained} 點數、${result.expGained} EXP`);

            // 延遲重新載入頁面以顯示更新狀態
            setTimeout(() => location.reload(), 2000);
        } else {
            showToast('error', result.message);
        }
    } catch (error) {
        console.error('Check-in error:', error);
        showToast('error', '簽到失敗，請稍後再試');
    }
}

// 載入日曆
async function loadCalendar(year, month) {
    try {
        const response = await fetch(`/MiniGame/SignIn/Calendar?year=${year}&month=${month}`);
        const days = await response.json();

        renderCalendar(days, year, month);
    } catch (error) {
        console.error('Failed to load calendar:', error);
    }
}

// 渲染日曆
function renderCalendar(days, year, month) {
    const grid = document.getElementById('calendarGrid');
    grid.innerHTML = '';

    // 計算該月第一天是星期幾
    const firstDay = new Date(year, month - 1, 1).getDay();
    const daysInMonth = new Date(year, month, 0).getDate();

    // 補空白格子 (星期日=0)
    for (let i = 0; i < firstDay; i++) {
        grid.insertAdjacentHTML('beforeend', '<div class="calendar-day calendar-day-empty"></div>');
    }

    // 渲染每一天
    for (let day = 1; day <= daysInMonth; day++) {
        const dayData = days.find(d => d.day === day);
        const isSignedIn = dayData?.isSignedIn ?? false;
        const isToday = (year === new Date().getFullYear() && month === new Date().getMonth() + 1 && day === new Date().getDate());

        const dayHtml = `
            <div class="calendar-day ${isSignedIn ? 'signed-in' : ''} ${isToday ? 'today' : ''}"
                 data-day="${day}"
                 title="${isSignedIn ? `已簽到 (+${dayData.pointsGained}點)` : ''}">
                ${day}
            </div>
        `;
        grid.insertAdjacentHTML('beforeend', dayHtml);
    }
}

// 切換月份
function changeMonth(delta) {
    currentMonth += delta;
    if (currentMonth > 12) {
        currentMonth = 1;
        currentYear++;
    } else if (currentMonth < 1) {
        currentMonth = 12;
        currentYear--;
    }

    loadCalendar(currentYear, currentMonth);
    document.getElementById('calendarMonthLabel').textContent = `${currentYear} 年 ${currentMonth.toString().padStart(2, '0')} 月`;
}

// 載入最近簽到歷史
async function loadRecentHistory() {
    try {
        const response = await fetch('/MiniGame/SignIn/History?page=1&pageSize=5');
        const history = await response.json();

        // 渲染歷史列表
        // ... (省略實作細節)
    } catch (error) {
        console.error('Failed to load history:', error);
    }
}

// 初始化
$(document).ready(function() {
    loadCalendar(currentYear, currentMonth);
    loadRecentHistory();
});
```

### 8.4 遊戲邏輯 (game.js)

```javascript
// wwwroot/js/MiniGame/game.js

let gameSessionId = null;
let gameLevel = 0;
let gameRunning = false;

// 選擇難度
async function selectLevel(level) {
    if (gameRunning) return;

    gameLevel = level;

    try {
        const result = await secureFetch('/MiniGame/Game/Start', {
            method: 'POST',
            body: JSON.stringify({ level })
        });

        if (result.success) {
            gameSessionId = result.session.sessionId;
            startGameUI(result.session);
        } else {
            showToast('error', result.message);
        }
    } catch (error) {
        console.error('Start game error:', error);
        showToast('error', '遊戲啟動失敗');
    }
}

// 啟動遊戲UI
function startGameUI(session) {
    // 隱藏選關畫面
    document.querySelector('.level-selection').style.display = 'none';
    // 顯示遊戲畫布
    document.getElementById('gameCanvas').style.display = 'block';

    gameRunning = true;

    // 初始化遊戲 (Canvas繪圖邏輯)
    initGame(session);
}

// 遊戲初始化 (簡化範例)
function initGame(session) {
    const canvas = document.getElementById('canvas');
    const ctx = canvas.getContext('2d');

    // 遊戲邏輯 (怪物、玩家、碰撞檢測等)
    // ... (省略複雜遊戲邏輯)

    // 遊戲結束時呼叫
    // endGameSession('Win'); // or 'Lose' or 'Abort'
}

// 結束遊戲
async function endGameSession(result) {
    if (!gameRunning) return;

    gameRunning = false;

    try {
        const response = await secureFetch('/MiniGame/Game/End', {
            method: 'POST',
            body: JSON.stringify({
                sessionId: gameSessionId,
                result: result,
                endTime: new Date().toISOString()
            })
        });

        if (response.success) {
            showGameRewards(response);
        }
    } catch (error) {
        console.error('End game error:', error);
        showToast('error', '遊戲結算失敗');
    }
}

// 顯示獎勵
function showGameRewards(result) {
    const modalHtml = `
        <div class="modal fade" id="gameRewardModal" tabindex="-1">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header bg-${result.result === 'Win' ? 'success' : 'danger'} text-white">
                        <h5 class="modal-title">
                            ${result.result === 'Win' ? '<i class="bi bi-trophy"></i> 勝利！' : '<i class="bi bi-x-circle"></i> 失敗'}
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body text-center">
                        ${result.result === 'Win' ? `
                            <h4 class="mb-3">獲得獎勵</h4>
                            <p><i class="bi bi-coin"></i> +${result.pointsGained} 點數</p>
                            <p><i class="bi bi-star"></i> +${result.expGained} 經驗</p>
                            ${result.couponGained ? `<p><i class="bi bi-gift"></i> +1 ${result.couponGained}</p>` : ''}
                        ` : `
                            <p>下次再接再厲！</p>
                        `}
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-primary" onclick="location.reload()">繼續冒險</button>
                    </div>
                </div>
            </div>
        </div>
    `;

    document.body.insertAdjacentHTML('beforeend', modalHtml);
    const modal = new bootstrap.Modal(document.getElementById('gameRewardModal'));
    modal.show();
}

// 放棄遊戲
async function abortGame() {
    if (!confirm('確定要放棄遊戲嗎？')) return;

    await endGameSession('Abort');
}

// 載入剩餘遊戲次數
async function loadRemainingPlays() {
    try {
        const response = await fetch('/MiniGame/Game/RemainingPlays');
        const data = await response.json();
        document.getElementById('remainingPlays').textContent = data.remaining;
    } catch (error) {
        console.error('Failed to load remaining plays:', error);
    }
}
```

---

## 9. API端點設計(可選)

若需要更純粹的RESTful API，可建立API Controllers:

**位置:** `Areas/MiniGame/API/`

### 9.1 WalletApiController.cs

```csharp
[Area("MiniGame")]
[Route("api/[area]/[controller]")]
[ApiController]
[Authorize]
public class WalletApiController : ControllerBase
{
    private readonly IWalletService _walletService;
    private readonly IAppCurrentUser _currentUser;

    // GET: /api/MiniGame/Wallet
    [HttpGet]
    public async Task<ActionResult<WalletViewModel>> GetWallet(CancellationToken ct)
    {
        var userId = await _currentUser.GetUserIdAsync(ct);
        var wallet = await _walletService.GetWalletAsync(userId, ct);
        return Ok(wallet);
    }

    // GET: /api/MiniGame/Wallet/History?page=1&pageSize=20
    [HttpGet("History")]
    public async Task<ActionResult<IEnumerable<WalletHistoryViewModel>>> GetHistory(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20,
        CancellationToken ct = default)
    {
        var userId = await _currentUser.GetUserIdAsync(ct);
        var history = await _walletService.GetHistoryAsync(userId, page, pageSize, ct);
        return Ok(history);
    }
}
```

**優點:**
- 前後端完全分離
- 更適合未來開發Mobile App
- 統一JSON回應格式

**缺點:**
- 增加開發複雜度
- 需額外處理CORS (若跨域)

**建議:** Phase 1先使用Controller + JSON回傳，Phase 2再考慮獨立API Controllers

---

## 10. Service註冊

### 10.1 建立Extension Method

**位置:** `Extensions/ServiceCollectionExtensions.cs`

```csharp
namespace GamiPort.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddMiniGameServices(this IServiceCollection services)
    {
        // Wallet Services
        services.AddScoped<IWalletService, WalletService>();
        services.AddScoped<ICouponService, CouponService>();
        services.AddScoped<IEVoucherService, EVoucherService>();

        // Pet Services
        services.AddScoped<IPetService, PetService>();
        services.AddScoped<IPetInteractionService, PetInteractionService>();

        // SignIn Services
        services.AddScoped<ISignInService, SignInService>();
        services.AddScoped<ISignInStatsService, SignInStatsService>();

        // Game Services
        services.AddScoped<IGamePlayService, GamePlayService>();
        services.AddScoped<IDailyGameLimitService, DailyGameLimitService>();

        return services;
    }
}
```

### 10.2 Program.cs註冊

**位置:** `Program.cs` (約Line 180，在其他服務註冊之後)

```csharp
// MiniGame Area Services
builder.Services.AddMiniGameServices();
```

---

## 11. 開發路線圖

### Phase 1: Foundation (第1-2週)

**目標:** 建立Wallet系統完整功能

| 任務 | 工作量 | 優先級 |
|------|--------|--------|
| 建立IWalletService等介面 | 1天 | P0 |
| 實作WalletService, CouponService, EVoucherService | 3天 | P0 |
| 建立Wallet ViewModels | 0.5天 | P0 |
| 更新WalletController (注入服務，實作actions) | 1天 | P0 |
| 更新Wallet Views (Index, Coupons, EVouchers) | 2天 | P0 |
| 實作wallet.js (client-side) | 1天 | P1 |
| 註冊服務至Program.cs | 0.5天 | P0 |
| 測試錢包功能 | 1天 | P0 |

**交付物:**
- ✅ 點數餘額顯示
- ✅ 優惠券兌換功能
- ✅ 電子券兌換功能
- ✅ 交易歷史查詢

### Phase 2: Pet System (第3-4週)

**目標:** 實作寵物系統（互動、屬性、外觀）

| 任務 | 工作量 | 優先級 |
|------|--------|--------|
| 建立IPetService, IPetInteractionService介面 | 1天 | P0 |
| 實作Pet Services (10個) | 4天 | P0 |
| 建立Pet ViewModels | 1天 | P0 |
| 更新PetController | 2天 | P0 |
| 更新Pet/Index.cshtml (完整UI) | 2天 | P0 |
| 建立Customize.cshtml | 1天 | P1 |
| 實作pet.js (AJAX互動) | 2天 | P0 |
| 套用Teal設計系統CSS | 1天 | P0 |
| 測試寵物互動與升級 | 1天 | P0 |

**交付物:**
- ✅ 寵物屬性即時顯示
- ✅ 4種互動功能 (餵食/洗澡/玩耍/哄睡)
- ✅ 寵物升級系統
- ✅ 膚色/背景客製化

### Phase 3: SignIn System (第5週)

**目標:** 每日簽到功能

| 任務 | 工作量 | 優先級 |
|------|--------|--------|
| 建立ISignInService介面 | 0.5天 | P0 |
| 實作SignIn Services | 2天 | P0 |
| 建立SignIn ViewModels | 0.5天 | P0 |
| 更新SignInController | 1天 | P0 |
| 更新SignIn/Index.cshtml | 1天 | P0 |
| 實作簽到日曆widget (JavaScript) | 2天 | P0 |
| 測試簽到功能與時區 | 0.5天 | P0 |

**交付物:**
- ✅ 每日簽到功能
- ✅ 月曆檢視（標記已簽到日期）
- ✅ 簽到歷史記錄
- ✅ 連續簽到天數追蹤

### Phase 4: Game System (第6-7週)

**目標:** 遊戲對局系統

| 任務 | 工作量 | 優先級 |
|------|--------|--------|
| 建立IGamePlayService介面 | 0.5天 | P0 |
| 實作Game Services | 3天 | P0 |
| 建立Game ViewModels | 1天 | P0 |
| 建立GameController | 2天 | P0 |
| 建立Game/Index.cshtml | 1天 | P0 |
| 實作遊戲Canvas邏輯 (game.js) | 4天 | P0 |
| 整合遊戲獎勵至錢包/寵物 | 1天 | P0 |
| 測試每日限制與獎勵發放 | 1天 | P0 |

**交付物:**
- ✅ 遊戲對局管理
- ✅ 3個難度等級
- ✅ 每日遊戲次數限制
- ✅ 獎勵發放（點數、經驗、優惠券）

### Phase 5: UI Polish & CSS (第8週)

**目標:** Teal設計系統完整套用與響應式優化

| 任務 | 工作量 | 優先級 |
|------|--------|--------|
| 建立minigame.css (Teal主題變數) | 1天 | P0 |
| 套用Teal色彩至所有Views | 2天 | P0 |
| 建立可重用UI元件 (metric-card, stat-bar等) | 1天 | P1 |
| 響應式設計測試 (768px, 1024px, 1440px) | 1天 | P0 |
| 動畫效果調整 (transition, hover) | 0.5天 | P1 |
| 跨瀏覽器測試 (Chrome, Firefox, Safari, Edge) | 0.5天 | P1 |

**交付物:**
- ✅ 一致的Teal/Turquoise主題
- ✅ 響應式佈局
- ✅ 流暢的動畫效果

### Phase 6: Integration & Testing (第9週)

**目標:** 整合測試與Bug修復

| 任務 | 工作量 | 優先級 |
|------|--------|--------|
| 端對端測試 (4個子系統) | 2天 | P0 |
| Bug修復 | 2天 | P0 |
| 使用者驗收測試 (UAT) | 1天 | P0 |
| 效能優化 (lazy loading, caching) | 1天 | P1 |
| 部署至Staging環境 | 0.5天 | P0 |
| 生產部署 | 0.5天 | P0 |

**交付物:**
- ✅ 所有功能整合測試通過
- ✅ Zero critical bugs
- ✅ 生產環境就緒

**總開發時程:** 9週 (45個工作天)

---

## 12. 測試策略

### 12.1 單元測試

**框架:** xUnit, Moq, FluentAssertions

**測試範圍:**
- Service層所有CRUD方法
- 業務規則驗證 (點數餘額、屬性範圍、每日限制)
- Transaction rollback情境

**範例測試:**
```csharp
[Fact]
public async Task SignInAsync_ShouldGrantRewards_WhenFirstTimeToday()
{
    // Arrange
    var userId = 1;
    var today = DateTime.UtcNow.Date;

    // Mock SignInRule: 第1天獎勵
    _mockSignInRules.Setup(r => r.GetRuleForDayAsync(1, It.IsAny<CancellationToken>()))
        .ReturnsAsync(new SignInRule { Points = 20, Experience = 0, HasCoupon = false });

    // Act
    var result = await _signInService.SignInAsync(userId, CancellationToken.None);

    // Assert
    result.Success.Should().BeTrue();
    result.PointsGained.Should().Be(20);
    result.ExpGained.Should().Be(0);
}
```

### 12.2 整合測試

**測試資料庫:** In-memory SQLite 或獨立測試DB

**測試情境:**
- 完整簽到流程 (檢查→簽到→發放獎勵→更新歷史)
- 遊戲對局流程 (開始→結束→發放獎勵→更新寵物)
- 優惠券兌換流程 (扣點→建立優惠券→記錄交易)

### 12.3 E2E測試

**框架:** Selenium WebDriver 或 Playwright

**測試案例:**
- 寵物互動按鈕觸發AJAX並更新屬性
- 簽到日曆顯示正確日期
- 遊戲開始與結束流程
- 響應式佈局 (mobile/tablet/desktop)

### 12.4 手動測試檢查清單

**功能測試:**
- [ ] 錢包餘額正確顯示
- [ ] 交易歷史分頁正常
- [ ] 優惠券兌換扣除正確點數
- [ ] 寵物互動後屬性即時更新
- [ ] 寵物升級發放獎勵
- [ ] 簽到限制每日一次 (時區Asia/Taipei)
- [ ] 日曆標記已簽到日期
- [ ] 遊戲每日限制3次
- [ ] 遊戲獎勵正確發放
- [ ] Win才發放獎勵，Lose/Abort不發放

**UI測試:**
- [ ] Teal主題一致套用
- [ ] 所有按鈕與連結正常運作
- [ ] Mobile (< 768px) 佈局正常
- [ ] Tablet (768-1024px) 佈局正常
- [ ] Desktop (> 1024px) 佈局正常
- [ ] 動畫效果流暢
- [ ] Toast通知正常顯示

---

## 13. 部署檢查清單

### 13.1 部署前檢查

**程式碼:**
- [ ] 所有Services已註冊至Program.cs
- [ ] appsettings.json連線字串正確
- [ ] 所有TODO註解已移除
- [ ] Debug.WriteLine()已移除
- [ ] Console.WriteLine()已移除或改為ILogger

**資料庫:**
- [ ] SQL Server schema最新版本
- [ ] 種子資料已載入 (SignInRule, PetSkinColorCostSettings等)
- [ ] 無pending migrations (本專案不使用migrations)

**靜態資源:**
- [ ] CSS已minify (production)
- [ ] JavaScript已minify (production)
- [ ] 圖片已壓縮

**環境配置:**
- [ ] Development vs Production設定正確
- [ ] HTTPS憑證有效
- [ ] CORS設定正確 (若需要)

### 13.2 部署步驟

**Build:**
```powershell
dotnet build GamiPort/GamiPort/GamiPort.csproj --configuration Release
```

**Test:**
```powershell
dotnet test # (若有測試專案)
```

**Publish:**
```powershell
dotnet publish GamiPort/GamiPort/GamiPort.csproj -c Release -o ./publish
```

**部署至IIS/Azure/Docker:**
- 複製publish資料夾至伺服器
- 設定IIS Application Pool (.NET 8)
- 綁定HTTPS憑證
- 設定環境變數 (ConnectionStrings等)

### 13.3 部署後驗證

**Smoke Tests:**
- [ ] 可訪問 https://yourdomain.com/MiniGame/Wallet
- [ ] 登入功能正常
- [ ] 所有MiniGame Area頁面可訪問
- [ ] 資料庫連線成功
- [ ] SignalR Hubs連線正常 (若使用)

**監控:**
- [ ] 設定Application Insights (可選)
- [ ] 設定Serilog日誌輸出至檔案/資料庫
- [ ] 監控回應時間
- [ ] 監控資料庫查詢效能

---

## 附錄A: 檔案結構完整清單

```
GamiPort/GamiPort/Areas/MiniGame/
├── Controllers/
│   ├── HomeController.cs                [更新 - 保持簡單]
│   ├── WalletController.cs              [更新 - 完整實作]
│   ├── PetController.cs                 [更新 - 完整實作]
│   ├── SignInController.cs              [更新 - 完整實作]
│   └── GameController.cs                [新增]
│
├── Services/
│   ├── Wallet/
│   │   ├── IWalletService.cs            [新增]
│   │   ├── WalletService.cs             [新增]
│   │   ├── ICouponService.cs            [新增]
│   │   ├── CouponService.cs             [新增]
│   │   ├── IEVoucherService.cs          [新增]
│   │   └── EVoucherService.cs           [新增]
│   │
│   ├── Pet/
│   │   ├── IPetService.cs               [新增]
│   │   ├── PetService.cs                [新增]
│   │   ├── IPetInteractionService.cs    [新增]
│   │   └── PetInteractionService.cs     [新增]
│   │
│   ├── SignIn/
│   │   ├── ISignInService.cs            [新增]
│   │   ├── SignInService.cs             [新增]
│   │   ├── ISignInStatsService.cs       [新增]
│   │   └── SignInStatsService.cs        [新增]
│   │
│   └── Game/
│       ├── IGamePlayService.cs          [新增]
│       ├── GamePlayService.cs           [新增]
│       ├── IDailyGameLimitService.cs    [新增]
│       └── DailyGameLimitService.cs     [新增]
│
├── ViewModels/
│   ├── Wallet/                          [新增 - 10個檔案]
│   ├── Pet/                             [新增 - 8個檔案]
│   ├── SignIn/                          [新增 - 5個檔案]
│   └── Game/                            [新增 - 5個檔案]
│
├── Views/
│   ├── Home/
│   │   └── Index.cshtml                 [更新]
│   ├── Wallet/
│   │   ├── Index.cshtml                 [更新 - 完整實作]
│   │   ├── History.cshtml               [新增]
│   │   ├── Coupons.cshtml               [新增]
│   │   └── EVouchers.cshtml             [新增]
│   ├── Pet/
│   │   ├── Index.cshtml                 [更新 - 完整實作]
│   │   └── Customize.cshtml             [新增]
│   ├── SignIn/
│   │   ├── Index.cshtml                 [更新 - 完整實作]
│   │   └── History.cshtml               [新增]
│   ├── Game/
│   │   ├── Index.cshtml                 [新增]
│   │   └── History.cshtml               [新增]
│   └── Shared/
│       ├── _Layout.cshtml               [更新 - 加入MiniGame CSS]
│       └── Components/                  [新增 - 可重用元件]
│
└── API/ (可選)
    ├── WalletApiController.cs
    ├── PetApiController.cs
    └── GameApiController.cs

wwwroot/
├── css/
│   └── MiniGame/
│       ├── minigame.css                 [新增 - Teal主題]
│       ├── wallet.css                   [新增]
│       ├── pet.css                      [新增]
│       ├── signin.css                   [新增]
│       └── game.css                     [新增]
│
└── js/
    └── MiniGame/
        ├── common.js                    [新增 - 共用工具]
        ├── wallet.js                    [新增]
        ├── pet.js                       [新增]
        ├── signin.js                    [新增]
        └── game.js                      [新增]

Extensions/
└── ServiceCollectionExtensions.cs      [新增 - DI註冊]
```

---

## 附錄B: 必要NuGet套件

```xml
<!-- 已安裝 (驗證版本) -->
<PackageReference Include="Microsoft.EntityFrameworkCore" Version="8.0.0" />
<PackageReference Include="Microsoft.EntityFrameworkCore.SqlServer" Version="8.0.0" />
<PackageReference Include="Microsoft.AspNetCore.SignalR" Version="8.0.0" />

<!-- 可能需要新增 -->
<PackageReference Include="QRCoder" Version="1.4.3" />  <!-- E-Voucher QR碼生成 -->
<PackageReference Include="System.Drawing.Common" Version="8.0.0" />  <!-- 圖片處理 -->
```

---

## 附錄C: 參考資源連結

**設計參考:**
- `MiniGame_Area想要採用的風格(淡藍現代系配色)/` - 4張Teal主題參考圖
- `前台風格_brainstorming/` - 50張一般設計靈感

**文件參考:**
- `schema/MINIGAME_AREA_DB_SCHEMA_COMPLETE.md` - 20張表格完整schema
- `schema/BACKEND_GAMESPACE_ARCHITECTURE.md` - 後台架構分析
- `CLAUDE.md` - 專案總覽與開發規範

**ASP.NET Core文件:**
- Cookie Authentication: https://learn.microsoft.com/en-us/aspnet/core/security/authentication/cookie
- SignalR: https://learn.microsoft.com/en-us/aspnet/core/signalr/introduction

---

*文件版本: 1.0*
*最後更新: 2025-11-03*
*作者: AI Documentation System*
*狀態: 完整藍圖 - 待開發*
