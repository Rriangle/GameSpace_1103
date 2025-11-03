# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a dual ASP.NET Core MVC application for a gaming portal called "GameSpace" (管理後台) and "GamiPort" (前台). The project implements a comprehensive mini-game area with wallet, pet, sign-in, and gaming systems.

**Key Projects:**
- **GameSpace** (`GameSpace/GameSpace/`): Admin backend portal (後台)
- **GamiPort** (`GamiPort/GamiPort/`): Public frontend portal (前台)

## Build and Run Commands

### Prerequisites
- .NET 8.0 SDK
- SQL Server (LocalDB or Express)
- Visual Studio 2022 or VS Code with C# extension

**Key NuGet Packages (both projects):**
- `Microsoft.EntityFrameworkCore.SqlServer` (8.0.19-8.0.20)
- `Microsoft.AspNetCore.SignalR.Client` (8.0.19-8.0.20)
- `Microsoft.AspNetCore.Identity.*` (8.0.19-8.0.20)

**GameSpace-specific:**
- `ClosedXML` (0.105.0) - Excel export functionality

### Build
```powershell
# Build GameSpace (Admin)
dotnet build GameSpace/GameSpace/GameSpace.csproj

# Build GamiPort (Frontend)
dotnet build GamiPort/GamiPort/GamiPort.csproj

# Build both projects
dotnet build
```

### Run
```powershell
# Run GameSpace (Admin) - Default ports: https://localhost:7042, http://localhost:5211
dotnet run --project GameSpace/GameSpace/GameSpace.csproj

# Run GamiPort (Frontend) - Default ports: https://localhost:7160, http://localhost:5042
dotnet run --project GamiPort/GamiPort/GamiPort.csproj
```

### Database
The project uses SQL Server with the database name **GameSpacedatabase**. Connection strings are configured in `appsettings.json`:
- GameSpace uses: `(local)\SQLEXPRESS01` or `DESKTOP-8HQIS1S\SQLEXPRESS`
- Database initialization is manual via SQL scripts in `schema/` directory
- **CRITICAL**: Do NOT use EF Migrations to modify the schema. The SQL Server database is the single source of truth.
- Schema extraction: Use `extract_schema.sql` to export current database structure
- Complete schema reference: `COMPLETE_SCHEMA_EXPORT.md` contains the full database structure

### Test Commands
No automated test suite is currently implemented. Manual testing is performed through the web interfaces.

## Architecture

### Area-Based Structure
Both projects use ASP.NET Core Areas for modular organization:

**GameSpace Areas (Admin):**
- `Areas/MiniGame/` - Mini-game admin controls (primary focus)
- `Areas/Forum/` - Forum management
- `Areas/MemberManagement/` - User management
- `Areas/OnlineStore/` - Store admin
- `Areas/social_hub/` - Social features & customer support
- `Areas/Identity/` - Admin identity

**GamiPort Areas (Frontend):**
- `Areas/MiniGame/` - Client-facing mini-game features
- `Areas/Forum/` - Forum views
- `Areas/Login/` - User authentication
- `Areas/OnlineStore/` - Store frontend
- `Areas/social_hub/` - Chat and support

### MiniGame Area Architecture (Primary Feature)

The MiniGame Area is the core focus of this repository. It implements a comprehensive gaming system with four major subsystems:

**GameSpace/GameSpace/Areas/MiniGame/ (Admin Backend):**
```
Controllers/
  - Admin*Controller.cs (各功能管理器)
  - Settings/ (系統設定控制器)
Services/
  - I*Service.cs (服務介面)
  - *Service.cs (服務實作)
Constants/
  - *Constants.cs (常數定義)
config/
  - ServiceExtensions.cs (DI註冊)
```

**Four Core Subsystems:**

1. **Wallet System** (會員錢包)
   - Point balance management (`User_Wallet`)
   - Transaction history (`WalletHistory`)
   - Coupon management (`CouponType`, `Coupon`)
   - E-voucher system (`EVoucherType`, `EVoucher`, `EVoucherToken`, `EVoucherRedeemLog`)
   - Services: `IWalletService`, `ICouponService`, `IEVoucherService`

2. **Sign-In System** (簽到系統)
   - Daily check-in with calendar view
   - Configurable rewards per day (`SignInRule`)
   - Check-in history tracking (`UserSignInStats`)
   - Services: `ISignInService`, `ISignInStatsService`

3. **Pet System** (寵物系統)
   - Virtual pet with 5 stats: Hunger, Mood, Stamina, Cleanliness, Health (0-100)
   - Pet interactions (feed, bathe, play, sleep)
   - Customization: skin colors and backgrounds (point-based)
   - Level/experience progression with rewards
   - Tables: `Pet`, `PetSkinColorCostSettings`, `PetBackgroundCostSettings`, `PetLevelRewardSettings`
   - Services: `IPetService`, `IPetRulesService`, `IPetLevelingService`

4. **Mini-Game System** (小遊戲系統)
   - Game session management with daily limits (default: 3 plays/day)
   - Game records with win/lose/abort states
   - Reward distribution (points, pet exp, coupons)
   - Tables: `MiniGame`, integrated with `Pet` and wallet tables
   - Services: `IGamePlayService`, `IGameQueryService`, `IGameMutationService`, `IGameRulesService`, `IDailyGameLimitService`

### Authentication & Authorization

**GameSpace (Admin):**
- Uses `AdminCookie` scheme with Cookie authentication
- Claims-based authorization with `IsManager=true` claim
- Manager permission system via `ManagerData`, `ManagerRole`, `ManagerRolePermission` tables
- Login redirects to shared login system at root level

**GamiPort (Frontend):**
- Custom Cookie authentication (`GamiPort.User`)
- Does NOT use ASP.NET Identity
- User authentication against `Users` table in GameSpacedatabase
- Uses `IAppCurrentUser` interface for centralized user context

### Database Schema

**Database:** GameSpacedatabase
**Tables:** 20 core tables (see `schema/QUICK_REFERENCE.md` for complete reference)

**Key Tables:**
- **User & Wallet:** `Users`, `User_Wallet`, `WalletHistory`
- **Coupons:** `CouponType`, `Coupon`
- **E-Vouchers:** `EVoucherType`, `EVoucher`, `EVoucherToken`, `EVoucherRedeemLog`
- **Pet:** `Pet`, `Pet*Settings` (3 tables)
- **Sign-In:** `SignInRule`, `UserSignInStats`
- **Mini-Games:** `MiniGame`
- **Admin:** `ManagerData`, `ManagerRolePermission` (Note: `ManagerRole` removed in recent update)
- **Config:** `SystemSettings`
- **Store & Payment:** `SoOrderInfo`, `SoPaymentAudit`, `SoPaymentTransaction`, `VwPaymentOrderInconsistency`
- **Rankings & Stats:** `SVRankingFavorite`, `SVRankingSale`, `SVRankingClick`, `SVRankingRating`

**Design Patterns:**
- All tables implement soft delete: `IsDeleted`, `DeletedAt`, `DeletedBy`, `DeleteReason`
- Audit trail: `CreatedAt`, `UpdatedAt`, `UpdatedBy`
- UTC timestamps via `sysutcdatetime()`

**Reference Files:**
- `schema/MINIGAME_AREA_SCHEMA_AI_OPTIMIZED.md` - Complete schema with all columns, constraints, indexes
- `schema/SAMPLE_DATA_REFERENCE.md` - Sample data patterns and examples
- `schema/QUICK_REFERENCE.md` - One-page cheat sheet for quick lookups
- `schema/README_合併版.md` - Full specification in Traditional Chinese

### Service Registration

**GameSpace (`Program.cs`):**
```csharp
// MiniGame Area services registered via extension method
builder.Services.AddMiniGameServices(builder.Configuration);

// Located in: Areas/MiniGame/config/ServiceExtensions.cs
```

**GamiPort (`Program.cs`):**
```csharp
// Services registered individually:
// - INotificationStore, IRelationService
// - Chat/Support services (IChatService, IProfanityFilter)
// - Shopping cart services
// - Email sender services
```

### SignalR Integration

Both projects use SignalR for real-time features:

**GameSpace:**
- `SupportHub` at `/hubs/support` (backend support console)

**GamiPort:**
- `SupportHub` at `/hubs/support` (customer support)
- `ChatHub` for direct messaging
- CORS enabled for cross-origin Hub connections from GameSpace

## Development Constraints

### Area Isolation Rule
When working on MiniGame Area features:
- **ONLY modify files under:** `Areas/MiniGame/**`
- **EXCEPTION:** `Program.cs` may be modified ONLY to add necessary service registrations for MiniGame Area
- **DO NOT** modify other Areas or global files
- **DO NOT** modify shared layouts, vendor files, or other team members' code

### Database Rules
- **NO EF Migrations**: Database schema is manually managed via SQL scripts
- **SQL Server is source of truth**: Always read from existing SQL Server database via SSMS
- **Model Sync Process**: When database changes occur:
  1. Run `extract_schema.sql` in SSMS to export schema
  2. Use EF Core Power Tools or scaffold command to regenerate Models from database
  3. Compare generated models with existing `GameSpace/Models/` and `GamiPort/Models/`
  4. Update `GameSpacedatabaseContext.cs` with new table configurations
  5. Update `COMPLETE_SCHEMA_EXPORT.md` with new schema information
- All MiniGame-related tables must be 100% covered by the application
- Use transactions for all point/coupon/pet mutation operations
- Use `AsNoTracking()` for read-only queries
- Batch operations limited to ≤ 1000 records

### UI/Styling Rules

**Admin (GameSpace):**
- Uses SB Admin template (`wwwroot/lib/sb-admin/`)
- Two-level sidebar navigation for MiniGame Area (module → function buttons)

**Frontend (GamiPort) - MiniGame Area Design System:**

The MiniGame Area frontend should follow a modern, light blue (teal/turquoise) color scheme with card-based layouts. Reference designs are located in `MiniGame_Area想要採用的風格(淡藍現代系配色)/`.

**Color Palette:**
- Primary: Deep teal/turquoise `#17a2b8` or `#0d9488`
- Background: Very light blue-gray `#f0f4f8` or `#e8f0f4`
- Cards: White `#ffffff` with soft shadows
- Accent: Orange `#ff9f43` or `#ffa500` for CTAs and highlights
- Light teal highlights: `#e0f2f1` for hover states and selected items
- Text: Dark gray `#2c3e50` for primary text, lighter gray for secondary

**Design Principles:**
- Card-based layout with generous border-radius (16-24px)
- Soft shadows for depth: `box-shadow: 0 4px 12px rgba(0,0,0,0.08)`
- Left sidebar navigation with teal background and white icons
- Ample white space and clean layouts
- Rounded icons and buttons (circular for main actions)
- Data visualization uses teal curves/charts
- Subtle gradient backgrounds where appropriate
- Mobile-responsive with focus on tablet/desktop experience

**Component Patterns:**
- Profile cards with circular avatars
- Metric cards with large numbers and icons
- Category pills/chips with light teal backgrounds
- List items with hover states
- Calendar views with highlight dates
- Progress circles and bars in teal
- Icon + label button combinations
- Toast notifications with teal accents

**General Rules:**
- **DO NOT** modify vendor files in `wwwroot/lib/`
- Keep consistent spacing (multiples of 8px: 8, 16, 24, 32)
- Use transitions for interactive elements (0.2s ease)
- Ensure WCAG AA contrast ratios for text
- Test responsiveness at breakpoints: 768px, 1024px, 1440px

### Coding Standards
- **Encoding:** UTF-8 with BOM for all files (especially for Chinese content)
- **Transaction Safety:** All wallet deductions, coupon issuance, game settlements must be within database transactions
- **Logging:** Use Serilog with CorrelationId for audit trails
- **Error Handling:** Return `ProblemDetails` or unified Result type
- **Commit Size:** ≤ 3 files / ≤ 400 lines per commit

## Common Patterns

### Reading MiniGame Data
```csharp
// Use AsNoTracking() for read-only queries
var wallet = await _context.User_Wallet
    .AsNoTracking()
    .FirstOrDefaultAsync(w => w.User_Id == userId && !w.IsDeleted);
```

### Mutation with Transaction
```csharp
using var transaction = await _context.Database.BeginTransactionAsync();
try {
    // Update wallet, create history, etc.
    await _context.SaveChangesAsync();
    await transaction.CommitAsync();
}
catch {
    await transaction.RollbackAsync();
    throw;
}
```

### Authorization Check
```csharp
[Authorize(AuthenticationSchemes = "AdminCookie", Policy = "AdminOnly")]
public class AdminWalletController : Controller { ... }
```

### Service Layer Pattern
All business logic is encapsulated in services (not in controllers):
- Controllers handle HTTP concerns only
- Services contain business logic and data access
- Services are registered in DI container
- Use interfaces for testability

## File Locations

### Configuration
- Connection strings: `appsettings.json` in each project
- Launch settings: `Properties/launchSettings.json`

### Static Assets
- GameSpace: `GameSpace/GameSpace/wwwroot/`
- GamiPort: `GamiPort/GamiPort/wwwroot/`

### Database Scripts
- Schema documentation: `schema/*.md`
- SQL extraction scripts: `schema/*.sql`

### Design References
- MiniGame Area frontend design mockups: `MiniGame_Area想要採用的風格(淡藍現代系配色)/`
  - Contains 4 reference images showcasing the desired teal/turquoise modern design system
  - Used as visual guide for GamiPort MiniGame Area frontend implementation

### Shared Views
- GameSpace: `Views/Shared/` for global layouts
- Area-specific: `Areas/[AreaName]/Views/Shared/`

## Health Check

Both projects should implement:
```
GET /healthz/db
Response: {"status":"ok"} or error details
```

This endpoint verifies database connectivity and basic query functionality.

## Important Notes

1. **Dual-Server Setup:** GameSpace and GamiPort run as separate applications on different ports
2. **Chinese Language:** Project uses Traditional Chinese (zh-TW) in UI and documentation
3. **No Auto-Migration:** Database changes must be manually scripted and applied via SSMS
4. **Specification Hierarchy:**
   - SQL Server database = 100% authority
   - `COMPLETE_SCHEMA_EXPORT.md` = Complete database structure export
   - `schema/README_合併版.md` = Comprehensive specification
   - Schema docs in `schema/` = Reference implementation
5. **Current Status:** GameSpace (Admin) is complete. GamiPort (Frontend) MiniGame Area features are in development.
6. **Frontend Design:** GamiPort MiniGame Area must follow the teal/turquoise modern design system shown in reference images. This is non-negotiable for visual consistency.
7. **Recent Updates:**
   - Added `SVRankingFavorite` table for favorite rankings tracking
   - Added `SoPaymentAudit` for payment audit logging
   - Added `VwPaymentOrderInconsistency` view for payment validation
   - Removed deprecated `ManagerRole` model (functionality moved to `ManagerRolePermission`)
   - Implemented SystemSettings configuration center for business rule adjustments

## Verification Checklist

When implementing MiniGame Area features, verify:
- [ ] All MiniGame tables are covered (20 tables)
- [ ] Soft delete is respected in all queries (`!IsDeleted`)
- [ ] Audit trail fields are properly populated
- [ ] Transactions wrap all multi-step operations
- [ ] AdminCookie authentication is enforced (GameSpace) or Cookie auth (GamiPort)
- [ ] No files modified outside `Areas/MiniGame/` (except Program.cs)
- [ ] UTF-8 with BOM encoding for all .cs and .cshtml files
- [ ] Sidebar buttons match specification exactly
- [ ] **Frontend UI:** Teal color scheme applied (`#17a2b8` primary, `#f0f4f8` background)
- [ ] **Frontend UI:** Card-based layouts with 16-24px border-radius
- [ ] **Frontend UI:** Proper spacing (8px multiples) and shadows
- [ ] **Frontend UI:** Responsive design tested at key breakpoints
