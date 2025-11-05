-- ====================================================================
-- Sample Data Extraction - Top 20 Rows Per Table
-- ====================================================================

SET NOCOUNT ON;

-- 1. User_Wallet
PRINT '=== User_Wallet ===';
SELECT TOP 20 * FROM dbo.User_Wallet ORDER BY User_Id;

-- 2. WalletHistory
PRINT '';
PRINT '=== WalletHistory ===';
SELECT TOP 20 * FROM dbo.WalletHistory ORDER BY LogID DESC;

-- 3. CouponType
PRINT '';
PRINT '=== CouponType ===';
SELECT TOP 20 * FROM dbo.CouponType ORDER BY CouponTypeID;

-- 4. Coupon
PRINT '';
PRINT '=== Coupon ===';
SELECT TOP 20 * FROM dbo.Coupon ORDER BY CouponID DESC;

-- 5. EVoucherType
PRINT '';
PRINT '=== EVoucherType ===';
SELECT TOP 20 * FROM dbo.EVoucherType ORDER BY EVoucherTypeID;

-- 6. EVoucher
PRINT '';
PRINT '=== EVoucher ===';
SELECT TOP 20 * FROM dbo.EVoucher ORDER BY EVoucherID DESC;

-- 7. EVoucherToken
PRINT '';
PRINT '=== EVoucherToken ===';
SELECT TOP 20 * FROM dbo.EVoucherToken ORDER BY TokenID DESC;

-- 8. EVoucherRedeemLog
PRINT '';
PRINT '=== EVoucherRedeemLog ===';
SELECT TOP 20 * FROM dbo.EVoucherRedeemLog ORDER BY RedeemID DESC;

-- 9. Pet
PRINT '';
PRINT '=== Pet ===';
SELECT TOP 20 * FROM dbo.Pet ORDER BY PetID DESC;

-- 10. PetSkinColorCostSettings
PRINT '';
PRINT '=== PetSkinColorCostSettings ===';
SELECT TOP 20 * FROM dbo.PetSkinColorCostSettings ORDER BY SettingId;

-- 11. PetBackgroundCostSettings
PRINT '';
PRINT '=== PetBackgroundCostSettings ===';
SELECT TOP 20 * FROM dbo.PetBackgroundCostSettings ORDER BY SettingId;

-- 12. PetLevelRewardSettings
PRINT '';
PRINT '=== PetLevelRewardSettings ===';
SELECT TOP 20 * FROM dbo.PetLevelRewardSettings ORDER BY SettingId;

-- 13. SignInRule
PRINT '';
PRINT '=== SignInRule ===';
SELECT TOP 20 * FROM dbo.SignInRule ORDER BY Id;

-- 14. UserSignInStats
PRINT '';
PRINT '=== UserSignInStats ===';
SELECT TOP 20 * FROM dbo.UserSignInStats ORDER BY LogID DESC;

-- 15. MiniGame
PRINT '';
PRINT '=== MiniGame ===';
SELECT TOP 20 * FROM dbo.MiniGame ORDER BY PlayID DESC;

-- 16. SystemSettings
PRINT '';
PRINT '=== SystemSettings ===';
SELECT TOP 20 * FROM dbo.SystemSettings ORDER BY SettingId;

-- 17. Users
PRINT '';
PRINT '=== Users ===';
SELECT TOP 20 * FROM dbo.Users ORDER BY User_ID DESC;

-- 18. ManagerData
PRINT '';
PRINT '=== ManagerData ===';
SELECT TOP 20 * FROM dbo.ManagerData ORDER BY Manager_Id;

-- 19. ManagerRole
PRINT '';
PRINT '=== ManagerRole ===';
SELECT TOP 20 * FROM dbo.ManagerRole ORDER BY Manager_Id;

-- 20. ManagerRolePermission
PRINT '';
PRINT '=== ManagerRolePermission ===';
SELECT TOP 20 * FROM dbo.ManagerRolePermission ORDER BY ManagerRole_Id;
