# 寵物頁面 Views 快速參考指南

## 文件位置

```
GamiPort/GamiPort/Areas/MiniGame/Views/Pet/
├── Index.cshtml       ← 主頁面 (寵物資訊 + 互動)
└── Customize.cshtml   ← 膚色/背景定制專頁
```

## 核心功能速查表

| 功能 | 位置 | 狀態 | 備註 |
|------|------|------|------|
| 寵物資訊卡片 | Index 第 162-199 行 | ✓ 完成 | 頭像、名字、經驗 |
| 屬性指標 (5個) | Index 第 207-287 行 | ✓ 完成 | 餓/心/體/潔/健 |
| 互動按鈕 | Index 第 408-427 行 | ✓ 完成 | onclick 綁定 |
| 互動結果 | Index 第 303-311 行 | ✓ 完成 | 成功/失敗提示 |
| 冷卻時間 | Index 第 645-664 行 | ✓ 完成 | 倒計時管理 |
| 膚色定制 | Customize 第 178-206 行 | ✓ 完成 | 8 色選擇器 |
| 背景定制 | Customize 第 209-237 行 | ✓ 完成 | 6 色選擇器 |

## 互動配置

### 互動設定 (Index.cshtml 第 541-545 行)

```javascript
feed:   { message: '您給寵物餵食了！', statChanges: { hunger: -20, experience: 10 }, cooldown: 60 }
bath:   { message: '您給寵物洗澡了！', statChanges: { cleanliness: +20, stamina: -10, experience: 15 }, cooldown: 120 }
play:   { message: '您和寵物一起玩耍了！', statChanges: { mood: +20, stamina: -20, hunger: +10, experience: 20 }, cooldown: 90 }
sleep:  { message: '寵物睡覺了，狀態恢復中...', statChanges: { stamina: +30, hunger: -10, health: +10, experience: 5 }, cooldown: 180 }
```

### 膚色配置 (Customize.cshtml 第 351-361 行)

```javascript
{ color: '#ff6b6b', name: '紅色', cost: 100 },
{ color: '#ffa500', name: '橙色', cost: 100 },
{ color: '#ffd93d', name: '黃色', cost: 100 },
{ color: '#6bcf7f', name: '綠色', cost: 100 },
{ color: '#4ecdc4', name: '青色', cost: 150 },
{ color: '#17a2b8', name: '靛色', cost: 150 },
{ color: '#6c5ce7', name: '紫色', cost: 200 },
{ color: '#fd79a8', name: '粉色', cost: 100 }
```

### 背景配置 (Customize.cshtml 第 363-370 行)

```javascript
{ color: '#ffffff', name: '白色', cost: 0 },
{ color: '#f0f4f8', name: '淺藍', cost: 0 },
{ color: '#e8f0f4', name: '冰藍', cost: 50 },
{ color: '#fff8e1', name: '淺黃', cost: 50 },
{ color: '#e8f5e9', name: '淺綠', cost: 50 },
{ color: '#fce4ec', name: '淺粉', cost: 75 }
```

## Teal 色系

```
主色:      #17a2b8 (標準) / #0d9488 (深色)
背景:      #f0f4f8 (淺藍灰)
強調:      #ff9f43 (橙色)
成功:      #28a745 (綠)
失敗:      #dc3545 (紅)
邊框:      #e0f2f1 (淡綠) / #e8f0f4 (淡藍)
```

## JavaScript 主要函數

### Index.cshtml

| 函數 | 用途 | 調用位置 |
|------|------|---------|
| `interactWithPet(action, button)` | 處理互動邏輯 | 按鈕 onclick |
| `showResult(success, message, statChanges)` | 顯示結果 | interactWithPet 內 |
| `setInteractionCooldown(action, cooldown)` | 冷卻管理 | interactWithPet 內 |
| `getStatLabel(stat)` | 屬性標籤翻譯 | showResult 內 |

### Customize.cshtml

| 函數 | 用途 | 調用時機 |
|------|------|---------|
| `initializeSkinColors()` | 初始化膚色選項 | DOMContentLoaded |
| `initializeBackgroundColors()` | 初始化背景選項 | DOMContentLoaded |
| `selectSkinColor(color, cost)` | 選擇膚色 | 顏色點擊事件 |
| `selectBackgroundColor(color, cost)` | 選擇背景 | 背景點擊事件 |
| `resetSkinColorSelection()` | 重置膚色選擇 | 取消按鈕 |
| `resetBackgroundColorSelection()` | 重置背景選擇 | 取消按鈕 |
| `confirmCustomization(type, cost)` | 提交確認 | 確認按鈕 (API 待實現) |
| `showSuccessMessage(message)` | 成功提示 | confirmCustomization 內 |

## CSS 類別速查

### Index.cshtml

| 類別 | 用途 | 特性 |
|------|------|------|
| `.pet-card` | 卡片容器 | 圓角 + 陰影 + 懸停效果 |
| `.pet-card-header` | 卡片頭 | Teal 漸層 + 白文字 |
| `.pet-avatar` | 寵物頭像 | 120px 圓形 + 邊框 |
| `.level-badge` | 等級徽章 | 橙色漸層 + 圓形 |
| `.stat-card` | 屬性卡片 | 淡藍灰背景 + 16px 圓角 |
| `.progress` | 進度條 | 24px 高 + 12px 圓角 |
| `.progress-bar` | 進度條填充 | Teal 漸層 + 文字 |
| `.info-card` | 資訊卡片 | Teal 左邊框 + 淡綠背景 |
| `.interaction-result` | 互動結果 | 滑入動畫 + 邊框變色 |
| `.pet-action-btn` | 互動按鈕 | 位置相對 + 加載支持 |
| `.loading-spinner` | 加載動畫 | 居中 + 隱藏/顯示切換 |
| `.cooldown-badge` | 冷卻徽章 | 黃色背景 |
| `.btn-action` | 按鈕樣式 | 16px 圓角 + 過渡效果 |
| `.btn-teal` | Teal 按鈕 | Teal 漸層 + 白文字 |

### Customize.cshtml

| 類別 | 用途 | 特性 |
|------|------|------|
| `.customize-page-bg` | 頁面背景 | 漸層背景 + 100vh |
| `.customize-card` | 定制卡片 | 24px 圓角 + 陰影 |
| `.customize-card-header` | 卡片頭 | Teal 漸層 |
| `.color-grid` | 顏色網格 | CSS Grid + auto-fill |
| `.color-option` | 顏色選項 | 彈性容器 + 懸停效果 |
| `.color-swatch` | 顏色樣本 | 80px 圓形 + 邊框 |
| `.color-option.selected` | 已選中顏色 | Teal 邊框 + 放大 |
| `.color-label` | 顏色標籤 | 600 字重 + 居中 |
| `.color-cost` | 顏色成本 | 淡綠背景 + Teal 文字 |
| `.preview-card` | 預覽卡片 | 白背景 + 邊框 |
| `.preview-pet-avatar` | 預覽頭像 | 100px 圓形 |
| `.points-display` | 點數顯示 | 橙色漸層 + 居中 |
| `.btn-confirm` | 確認按鈕 | Teal 漸層 + 懸停深化 |
| `.btn-cancel` | 取消按鈕 | 淺藍背景 + 邊框 |

## 頁面導航

### Index.cshtml 路由

```
GET /MiniGame/Pet/Index
  ↓
[未登入] → 重定向到登入頁面
  ↓
[已登入] → 顯示寵物頁面
  ↓
點擊「定制寵物外觀」 → 導航至 /MiniGame/Pet/Customize
```

### Customize.cshtml 路由

```
GET /MiniGame/Pet/Customize
  ↓
[未登入] → 顯示登入提示
  ↓
[已登入] → 顯示定制頁面
  ↓
點擊「返回寵物頁面」 → 導航至 /MiniGame/Pet/Index
```

## 資料流向

### 互動流程

```
使用者點擊互動按鈕
  ↓
interactWithPet(action, button)
  ├─ 檢查冷卻時間
  ├─ 禁用按鈕 + 加載狀態
  ├─ [API 調用] POST /MiniGame/Pet/Interact (待實現)
  ├─ showResult(success, message, statChanges)
  ├─ setInteractionCooldown(action, cooldown)
  └─ 4 秒後自動隱藏結果
```

### 定制流程

```
使用者選擇膚色/背景
  ↓
selectSkinColor() / selectBackgroundColor()
  ├─ 更新選中狀態
  ├─ 更新成本顯示
  ├─ 實時預覽更新
  └─ 啟用確認按鈕
  ↓
點擊確認按鈕
  ├─ [API 調用] POST /MiniGame/Pet/Customize (待實現)
  ├─ showSuccessMessage()
  └─ 3 秒後隱藏訊息
```

## API 端點 (待實現)

### 1. 互動端點

```http
POST /MiniGame/Pet/Interact

Request Body:
{
    "action": "feed|bath|play|sleep",
    "petId": 123
}

Response (200):
{
    "success": true,
    "message": "互動成功",
    "statChanges": {
        "hunger": -20,
        "experience": 10,
        ...
    },
    "currentStats": {
        "hunger": 45,
        "mood": 60,
        ...
    }
}
```

### 2. 冷卻狀態端點

```http
GET /MiniGame/Pet/GetCooldownStatus

Response (200):
{
    "feed": 0,
    "bath": 45,
    "play": 0,
    "sleep": 180
}
```

### 3. 定制端點

```http
POST /MiniGame/Pet/Customize

Request Body:
{
    "type": "skinColor|backgroundColor",
    "value": "#ff6b6b",
    "cost": 100
}

Response (200):
{
    "success": true,
    "message": "定制成功",
    "remainingPoints": 900
}

Response (400):
{
    "success": false,
    "message": "點數不足"
}
```

## 修改快速指南

### 變更互動冷卻時間

**位置**: Index.cshtml 第 541-545 行

```javascript
feed: { ..., cooldown: 60 }  // 改為秒數
```

### 變更互動屬性變化

**位置**: Index.cshtml 第 541-545 行

```javascript
feed: { ..., statChanges: { hunger: -20, experience: 10 } }  // 修改變化值
```

### 變更膚色選項

**位置**: Customize.cshtml 第 351-361 行

```javascript
{ color: '#ff6b6b', name: '紅色', cost: 100 }  // 新增或修改
```

### 變更背景選項

**位置**: Customize.cshtml 第 363-370 行

```javascript
{ color: '#ffffff', name: '白色', cost: 0 }  // 新增或修改
```

### 變更色系主色

**查找 & 取代**:
- `#17a2b8` → 新主色
- `#0d9488` → 新深色
- `#f0f4f8` → 新背景色

## 常見問題

### Q: 為什麼互動後沒有API呼叫?
A: API 端點待後端實現。目前前端使用模擬延遲 (0.8 秒) 演示。搜尋 `TODO: Call actual API endpoint` 以找到整合點。

### Q: 如何讓定制立即生效?
A: 在 `confirmCustomization()` 中實現 API 呼叫，完成後刷新寵物資訊。

### Q: 冷卻時間如何同步?
A: 在頁面載入時呼叫 `GetCooldownStatus` API，恢復之前的冷卻狀態。見 `DOMContentLoaded` 事件。

### Q: 如何支持動態顏色選項?
A: 將 `skinColorOptions` 和 `backgroundColorOptions` 從 ViewBag 動態載入，而非硬編碼。

## 編碼建議

### 添加新互動類型

1. 在 `interactionConfig` 中新增配置
2. 在按鈕 HTML 中新增按鈕元素
3. 更新 `getStatLabel()` 函數 (如有新屬性)
4. 後端實現邏輯

### 添加新膚色選項

1. 在 `skinColorOptions` 陣列中新增物件
2. 確保 HEX 顏色有效
3. 設定合理的點數成本
4. 測試色值是否易於辨認

## 文件編碼檢查

```bash
# Windows PowerShell
file -i GamiPort/GamiPort/Areas/MiniGame/Views/Pet/*.cshtml

# 應為: UTF-8 without BOM
```

## 性能優化提示

1. **減少重排**: 使用 CSS 類別切換而非 inline styles
2. **動畫優化**: 使用 CSS 過渡而非 JavaScript 動畫
3. **事件委託**: 考慮為多個按鈕使用事件委託
4. **圖片優化**: 寵物頭像使用 SVG 或 emoji
5. **快取選項**: 在 localStorage 快取膚色/背景選項

## 相關文件

| 文件 | 用途 |
|------|------|
| `PET_VIEW_ENHANCEMENT_REPORT.md` | 詳細評估報告 |
| `PET_VIEW_IMPLEMENTATION_SUMMARY.md` | 實施摘要 |
| `PET_VIEW_COMPLETENESS_SCORECARD.txt` | 完整性評分卡 |
| `CLAUDE.md` | 專案指南 |

---

**最後更新**: 2025-11-04
**版本**: 1.0
**完整性**: 96/100
