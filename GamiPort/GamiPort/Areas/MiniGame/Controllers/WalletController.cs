using GamiPort.Areas.MiniGame.Services;
using GamiPort.Infrastructure.Security;
using GamiPort.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace GamiPort.Areas.MiniGame.Controllers
{
	[Area("MiniGame")]
	public class WalletController : Controller
	{
		private readonly GameSpacedatabaseContext _context;
		private readonly IWalletService _walletService;
		private readonly IAppCurrentUser _currentUser;
		private readonly IFuzzySearchService _fuzzySearchService;
		private readonly ILogger<WalletController> _logger;

		public WalletController(
			GameSpacedatabaseContext context,
			IWalletService walletService,
			IAppCurrentUser currentUser,
			IFuzzySearchService fuzzySearchService,
			ILogger<WalletController> logger)
		{
			_context = context ?? throw new ArgumentNullException(nameof(context));
			_walletService = walletService ?? throw new ArgumentNullException(nameof(walletService));
			_currentUser = currentUser ?? throw new ArgumentNullException(nameof(currentUser));
			_fuzzySearchService = fuzzySearchService ?? throw new ArgumentNullException(nameof(fuzzySearchService));
			_logger = logger ?? throw new ArgumentNullException(nameof(logger));
		}

		/// <summary>
		/// 錢包主頁 - 顯示點數、優惠券、電子禮券概況
		/// </summary>
		public async Task<IActionResult> Index()
		{
			// 檢查登入狀態，未登入跳轉到正確的登入頁面
			if (User.Identity?.IsAuthenticated != true)
			{
				var returnUrl = "/MiniGame/Wallet/Index";
				return Redirect($"/Login/Login/Login/Login?ReturnUrl={Uri.EscapeDataString(returnUrl)}");
			}

			try
			{
				var userId = _currentUser.UserId;
				if (userId <= 0)
				{
					_logger.LogWarning("無法取得用戶ID");
					return RedirectToAction("Index", "Home");
				}

				// 獲取錢包信息
				var wallet = await _walletService.GetUserWalletAsync(userId);
				if (wallet == null)
				{
					_logger.LogWarning("用戶錢包不存在: UserId={UserId}", userId);
					return RedirectToAction("Index", "Home");
				}

				// 獲取統計信息
				var summary = await _walletService.GetPointsSummaryAsync(userId);
				var unusedCouponCount = await _walletService.GetUnusedCouponCountAsync(userId);
				var unusedEVoucherCount = await _walletService.GetUnusedEVoucherCountAsync(userId);

				// 構建視圖模型
				var viewModel = new Dictionary<string, object>
				{
					{ "CurrentPoints", wallet.UserPoint },
					{ "TotalEarned", summary.ContainsKey("TotalEarned") ? summary["TotalEarned"] : 0 },
					{ "TotalSpent", summary.ContainsKey("TotalSpent") ? summary["TotalSpent"] : 0 },
					{ "TransactionCount", summary.ContainsKey("TransactionCount") ? summary["TransactionCount"] : 0 },
					{ "UnusedCouponCount", unusedCouponCount },
					{ "UnusedEVoucherCount", unusedEVoucherCount }
				};

				return View(viewModel);
			}
			catch (Exception ex)
			{
				_logger.LogError(ex, "錢包主頁加載失敗");
				return RedirectToAction("Index", "Home");
			}
		}

		/// <summary>
		/// 優惠券列表 - 顯示用戶所有優惠券，支持模糊搜尋
		/// </summary>
		[HttpGet]
		public async Task<IActionResult> Coupons(string search = "")
		{
			// 檢查登入狀態
			if (User.Identity?.IsAuthenticated != true)
			{
				var returnUrl = "/MiniGame/Wallet/Coupons";
				return Redirect($"/Login/Login/Login/Login?ReturnUrl={Uri.EscapeDataString(returnUrl)}");
			}

			try
			{
				var userId = _currentUser.UserId;
				if (userId <= 0)
				{
					_logger.LogWarning("無法取得用戶ID");
					return RedirectToAction("Index");
				}

				// 獲取優惠券列表（支持模糊搜尋）
				var coupons = await _walletService.GetUserCouponsAsync(userId, search);

				// 構建視圖數據
				var viewData = new
				{
					Coupons = coupons,
					SearchTerm = search,
					TotalCount = coupons.Count(),
					UnusedCount = coupons.Count(c => !c.IsUsed),
					UsedCount = coupons.Count(c => c.IsUsed)
				};

				return View(viewData);
			}
			catch (Exception ex)
			{
				_logger.LogError(ex, "優惠券列表加載失敗: UserId={UserId}", _currentUser.UserId);
				return RedirectToAction("Index");
			}
		}

		/// <summary>
		/// 電子禮券列表 - 顯示用戶所有電子禮券，支持模糊搜尋
		/// </summary>
		[HttpGet]
		public async Task<IActionResult> EVouchers(string search = "")
		{
			// 檢查登入狀態
			if (User.Identity?.IsAuthenticated != true)
			{
				var returnUrl = "/MiniGame/Wallet/EVouchers";
				return Redirect($"/Login/Login/Login/Login?ReturnUrl={Uri.EscapeDataString(returnUrl)}");
			}

			try
			{
				var userId = _currentUser.UserId;
				if (userId <= 0)
				{
					_logger.LogWarning("無法取得用戶ID");
					return RedirectToAction("Index");
				}

				// 獲取電子禮券列表（支持模糊搜尋）
				var eVouchers = await _walletService.GetUserEVouchersAsync(userId, search);

				// 構建視圖數據
				var viewData = new
				{
					EVouchers = eVouchers,
					SearchTerm = search,
					TotalCount = eVouchers.Count(),
					UnusedCount = eVouchers.Count(e => !e.IsUsed),
					UsedCount = eVouchers.Count(e => e.IsUsed)
				};

				return View(viewData);
			}
			catch (Exception ex)
			{
				_logger.LogError(ex, "電子禮券列表加載失敗: UserId={UserId}", _currentUser.UserId);
				return RedirectToAction("Index");
			}
		}

		/// <summary>
		/// 交易明細頁面 - 支持日期和類型篩選、分頁顯示
		/// </summary>
		[HttpGet]
		public async Task<IActionResult> History(DateTime? startDate = null, DateTime? endDate = null, string? changeType = null, int page = 1, int pageSize = 20)
		{
			// 檢查登入狀態
			if (User.Identity?.IsAuthenticated != true)
			{
				var returnUrl = "/MiniGame/Wallet/History";
				return Redirect($"/Login/Login/Login/Login?ReturnUrl={Uri.EscapeDataString(returnUrl)}");
			}

			try
			{
				var userId = _currentUser.UserId;
				if (userId <= 0)
				{
					_logger.LogWarning("無法取得用戶ID");
					return RedirectToAction("Index");
				}

				// 確保頁碼有效
				if (page < 1) page = 1;
				if (pageSize < 1) pageSize = 20;
				if (pageSize > 100) pageSize = 100; // 限制最大分頁大小

				// 獲取交易記錄
				var (transactions, totalCount) = await _walletService.GetWalletHistoryPagedAsync(
					userId,
					startDate,
					endDate,
					changeType,
					page,
					pageSize);

				// 計算餘額（需要從錢包獲取當前餘額，然後反推每筆交易後的餘額）
				var wallet = await _walletService.GetUserWalletAsync(userId);
				var currentBalance = wallet?.UserPoint ?? 0;

				// 為每筆交易添加餘額資訊
				var transactionsWithBalance = new List<WalletHistoryWithBalance>();

				// 獲取所有交易記錄以計算餘額
				var allTransactions = await _context.WalletHistories
					.AsNoTracking()
					.Where(h => h.UserId == userId && !h.IsDeleted)
					.OrderByDescending(h => h.ChangeTime)
					.ToListAsync();

				// 計算每筆交易後的餘額
				var balance = currentBalance;
				foreach (var txn in allTransactions)
				{
					var txnWithBalance = new WalletHistoryWithBalance
					{
						LogId = txn.LogId,
						UserId = txn.UserId,
						ChangeType = txn.ChangeType,
						PointsChanged = txn.PointsChanged,
						ItemCode = txn.ItemCode,
						Description = txn.Description,
						ChangeTime = txn.ChangeTime,
						AfterBalance = balance
					};

					if (transactions.Any(t => t.LogId == txn.LogId))
					{
						transactionsWithBalance.Add(txnWithBalance);
					}

					// 反推上一筆的餘額
					balance -= txn.PointsChanged;
				}

				// 構建視圖模型
				var viewModel = new WalletHistoryViewModel
				{
					Transactions = transactionsWithBalance,
					CurrentPage = page,
					PageSize = pageSize,
					TotalCount = totalCount,
					TotalPages = (int)Math.Ceiling(totalCount / (double)pageSize),
					StartDate = startDate,
					EndDate = endDate,
					ChangeType = changeType
				};

				return View(viewModel);
			}
			catch (Exception ex)
			{
				_logger.LogError(ex, "交易明細頁面加載失敗: UserId={UserId}", _currentUser.UserId);
				return RedirectToAction("Index");
			}
		}
	}

	/// <summary>
	/// 交易明細視圖模型
	/// </summary>
	public class WalletHistoryViewModel
	{
		public List<WalletHistoryWithBalance> Transactions { get; set; } = new();
		public int CurrentPage { get; set; }
		public int PageSize { get; set; }
		public int TotalCount { get; set; }
		public int TotalPages { get; set; }
		public DateTime? StartDate { get; set; }
		public DateTime? EndDate { get; set; }
		public string? ChangeType { get; set; }
	}

	/// <summary>
	/// 帶餘額資訊的交易記錄
	/// </summary>
	public class WalletHistoryWithBalance
	{
		public int LogId { get; set; }
		public int UserId { get; set; }
		public string ChangeType { get; set; } = null!;
		public int PointsChanged { get; set; }
		public string? ItemCode { get; set; }
		public string? Description { get; set; }
		public DateTime ChangeTime { get; set; }
		public int AfterBalance { get; set; }
	}
}
