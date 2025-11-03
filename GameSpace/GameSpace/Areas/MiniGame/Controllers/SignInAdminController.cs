using GameSpace.Areas.MiniGame.Models.ViewModels;
using GameSpace.Areas.MiniGame.Services;
using GameSpace.Areas.social_hub.Auth;
using GameSpace.Areas.MiniGame.Models;
using GameSpace.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace GameSpace.Areas.MiniGame.Controllers
{
    [Area("MiniGame")]
    [Authorize(AuthenticationSchemes = AuthConstants.AdminCookieScheme, Policy = "AdminOnly")]
    public class SignInAdminController : MiniGameBaseController
    {
        private readonly IInMemorySignInRuleService _ruleService;

        public SignInAdminController(
            GameSpacedatabaseContext context,
            IInMemorySignInRuleService ruleService)
            : base(context)
        {
            _ruleService = ruleService;
        }

        [HttpGet]
        public async Task<IActionResult> RuleSettings()
        {
            var rules = await _ruleService.GetAllRulesAsync();

            // 動態查詢 CouponTypes（不可硬編碼）
            var couponTypes = await _context.CouponTypes
                .AsNoTracking()
                .Where(ct => !ct.IsDeleted)
                .OrderBy(ct => ct.CouponTypeId)
                .Select(ct => new { ct.CouponTypeId, ct.Name })
                .ToListAsync();

            ViewBag.CouponTypes = couponTypes;

            // 建立 Name → CouponTypeId 的映射（用於 JavaScript）
            var couponTypeMapping = couponTypes.ToDictionary(ct => ct.Name, ct => ct.CouponTypeId);
            ViewBag.CouponTypeMapping = System.Text.Json.JsonSerializer.Serialize(couponTypeMapping);

            var model = new SignInRuleSettingsViewModel
            {
                Rules = rules.OrderBy(r => r.DayNumber).ToList()
            };

            return View(model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> UpdateRule(int ruleId, int points, int experience, bool hasCoupon, int? couponTypeId, bool isActive, string? description)
        {
            if (points < 0 || experience < 0)
            {
                TempData["Error"] = "點數和經驗值不能為負數";
                return RedirectToAction(nameof(RuleSettings));
            }

            // 將 CouponTypeId 映射為 CouponType.Name（因為資料庫 FK 使用 Name）
            string? couponTypeCode = null;
            if (hasCoupon && couponTypeId.HasValue)
            {
                var couponType = await _context.CouponTypes
                    .AsNoTracking()
                    .Where(ct => ct.CouponTypeId == couponTypeId.Value && !ct.IsDeleted)
                    .Select(ct => ct.Name)
                    .FirstOrDefaultAsync();

                if (couponType == null)
                {
                    TempData["Error"] = "找不到指定的優惠券類型";
                    return RedirectToAction(nameof(RuleSettings));
                }

                couponTypeCode = couponType;
            }

            // 使用記憶體服務更新規則
            var success = await _ruleService.UpdateRuleAsync(ruleId, points, experience, hasCoupon, couponTypeCode, isActive, description);

            if (!success)
            {
                TempData["Error"] = "找不到該簽到規則";
                return RedirectToAction(nameof(RuleSettings));
            }

            var rule = await _ruleService.GetRuleByIdAsync(ruleId);
            TempData["Success"] = $"成功更新第 {rule?.DayNumber} 天的簽到規則";
            return RedirectToAction(nameof(RuleSettings));
        }

        /// <summary>
        /// 快速切換規則啟用/停用狀態
        /// </summary>
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> ToggleActive(int ruleId)
        {
            var rule = await _ruleService.GetRuleByIdAsync(ruleId);
            if (rule == null)
            {
                TempData["Error"] = "找不到該簽到規則";
                return RedirectToAction(nameof(RuleSettings));
            }

            // 切換狀態
            var newStatus = !rule.IsActive;
            var success = await _ruleService.UpdateRuleAsync(
                rule.Id,
                rule.Points,
                rule.Experience,
                rule.HasCoupon,
                rule.CouponTypeCode,
                newStatus,
                rule.Description
            );

            if (success)
            {
                var statusText = newStatus ? "啟用" : "停用";
                TempData["Success"] = $"成功{statusText}第 {rule.DayNumber} 天的簽到規則";
            }
            else
            {
                TempData["Error"] = "更新規則狀態失敗";
            }

            return RedirectToAction(nameof(RuleSettings));
        }

        [HttpGet]
        public async Task<IActionResult> Records(int page = 1, int pageSize = 20)
        {
            page = Math.Max(1, page);
            pageSize = Math.Clamp(pageSize, 10, 100);

            // ⚠️ 修復 UserId1 錯誤：不使用 .Include(s => s.User)，改用手動分開查詢
            var source = _context.UserSignInStats
                .AsNoTracking()
                .OrderByDescending(s => s.SignTime);

            var totalCount = await source.CountAsync();
            var items = await source.Skip((page - 1) * pageSize).Take(pageSize).ToListAsync();

            // 手動載入用戶資料
            var userIds = items.Select(s => s.UserId).Distinct().ToList();
            var users = await _context.Users
                .AsNoTracking()
                .Where(u => userIds.Contains(u.UserId))
                .ToDictionaryAsync(u => u.UserId);

            var records = items.Select(s =>
            {
                users.TryGetValue(s.UserId, out var userData);
                
                return new SignInRecordViewModel
                {
                    LogId = s.LogId,
                    UserId = s.UserId,
                    UserAccount = userData?.UserAccount ?? string.Empty,
                    UserName = userData?.UserName ?? string.Empty,
                    SignTime = s.SignTime,
                    PointsGained = s.PointsGained,
                    ExpGained = s.ExpGained,
                    CouponCode = string.IsNullOrWhiteSpace(s.CouponGained) ? null : s.CouponGained
                };
            }).ToList();

            var model = new SignInRecordsViewModel
            {
                Records = new PagedResult<SignInRecordViewModel>
                {
                    Items = records,
                    TotalCount = totalCount,
                    CurrentPage = page,
                    PageSize = pageSize
                }
            };

            return View(model);
        }
    }
}
