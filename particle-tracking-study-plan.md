# 視覺影像追蹤技術學習計畫
## 從離焦影像到高速3D粒子追蹤的系統性學習路徑

---

## 📚 核心論文清單

1. **[Zhang2008]** Zhang, Z., & Menq, C. H. (2008). "Three-dimensional particle tracking with subnanometer resolution using off-focus images." *Applied Optics*, 47(13), 2361-2370.

2. **[Cheng2013]** Cheng, P., et al. (2013). "Real-time visual sensing system achieving high-speed 3D particle tracking with nanometer resolution." *Applied Optics*, 52(31), 7530-7539.

3. **[Cheng2013-CIRM]** Cheng, P., & Menq, C. H. (2013). "Real-time continuous image registration enabling ultraprecise 2-D motion tracking." *IEEE Transactions on Image Processing*, 22(5), 2081-2090.

4. **[Cheng2018]** Cheng, P., & Menq, C. H. (2018). "Visual tracking of six-axis motion rendering ultraprecise visual servoing of microscopic objects." *IEEE/ASME Transactions on Mechatronics*, 23(4), 1564-1572.

---

## 第一階段：理解基礎原理（2-3週）

### Week 1: 離焦成像基礎與橫向定位

#### Day 1-2: 離焦成像原理
**閱讀材料：**
- **[Zhang2008]** Section 1 (Introduction) - 了解技術背景與動機
- **[Zhang2008]** Section 2 (Experimental Setup) - 理解實驗架構

**學習重點：**
- 為什麼離焦影像能提供深度資訊
- 顯微鏡系統的基本配置
- CMOS vs CCD相機的差異

#### Day 3-4: 橫向位置估計（質心法）
**閱讀材料：**
- **[Zhang2008]** Section 3.A (頁面2363，方程式1)
- **[Zhang2008]** Section 4.A (Errors in Lateral Motion Estimation，頁面2365)
- **[Cheng2013]** Section 3.A (方程式1，頁面7533)

**學習重點：**
- 質心法的數學推導：
  ```
  (xc, yc) = (ΣI_i*x_i/ΣI_i, ΣI_i*y_i/ΣI_i)
  ```
- 閾值處理對精度的影響
- 偏差誤差的週期性特徵

#### Day 5: 實作練習
**實作內容：**
- 用Python/MATLAB實作質心法
- 測試不同閾值策略
- 分析雜訊對結果的影響

### Week 2: 軸向定位核心技術

#### Day 1-2: 徑向投影（Radial Projection）
**閱讀材料：**
- **[Zhang2008]** Section 3.B.1 (Radial Projection，頁面2363-2364)
- **[Zhang2008]** Figure 2 & Figure 4 - 視覺化理解

**學習重點：**
- 2D到1D的資訊保留轉換
- 線性內插的實作細節
- 上採樣（upsampling）的必要性

#### Day 3-4: Object-Specific Model
**閱讀材料：**
- **[Zhang2008]** Section 3.B.2 (Object-Specific Model，頁面2364)
- **[Zhang2008]** Figure 5 & Figure 6 - 校正模型視覺化
- **[Cheng2013]** Figure 5 - 正規化半徑向量模型

**學習重點：**
- 自動校正流程設計
- Spline fitting的應用
- 為什麼需要連續模型

#### Day 5-6: 匹配演算法
**閱讀材料：**
- **[Zhang2008]** Section 3.B.3 (Matching Algorithm，頁面2365)
- **[Zhang2008]** 方程式(3)-(6) - 最佳化目標函數

**學習重點：**
- 最小平方法的應用
- 梯度計算與收斂性
- 計算效率優化

### Week 3: 誤差分析與效能評估

#### Day 1-3: 理論誤差分析
**閱讀材料：**
- **[Zhang2008]** Section 4 (Performance Analysis，頁面2365-2367)
- **[Zhang2008]** 方程式(7)-(14) - 變異數推導
- **[Zhang2008]** 方程式(15)-(21) - 橫向誤差耦合

**學習重點：**
- S(z)曲線的物理意義
- 雜訊傳播分析
- 最佳量測範圍選擇

#### Day 4-5: 實驗驗證
**閱讀材料：**
- **[Zhang2008]** Section 5 (Experimental Results，頁面2367-2369)
- **[Zhang2008]** Figure 9-11 - 實驗數據分析

**學習重點：**
- 奈米級步進量測
- 長程追蹤能力
- 不同粒子大小的影響

---

## 第二階段：高速系統實現（2-3週）

### Week 4: FPGA系統架構

#### Day 1-2: 系統整合設計
**閱讀材料：**
- **[Cheng2013]** Section 2 (System Configuration，頁面7531-7533)
- **[Cheng2013]** Figure 1 & Figure 2 - 系統架構圖

**學習重點：**
- 三FPGA協同架構
- Camera Link介面
- 即時資料流處理

#### Day 3-4: FPGA演算法實現
**閱讀材料：**
- **[Cheng2013]** Section 3 (Implementation，頁面7533-7535)
- **[Cheng2013]** 平行運算設計

**學習重點：**
- 78μs處理時間達成
- 記憶體管理策略
- 時序同步控制

### Week 5: 偏差補償技術

#### Day 1-3: 偏差分析與補償
**閱讀材料：**
- **[Cheng2013]** Section 3.B (Measurement Bias，頁面7535)
- **[Cheng2013]** Figure 6 - 偏差函數視覺化
- **[Cheng2013-CIRM]** Section II.B - 子像素配準偏差

**學習重點：**
- Z位置相關的偏差特性
- Cubic spline fitting補償
- 即時補償實作

#### Day 4-5: 效能驗證
**閱讀材料：**
- **[Cheng2013]** Section 4 (Experimental Results，頁面7536-7538)
- **[Cheng2013]** Figure 8-10 - 追蹤精度驗證

---

## 第三階段：進階影像配準技術（2週）

### Week 6: 連續影像配準（CIRM）

#### Day 1-3: CIRM核心原理
**閱讀材料：**
- **[Cheng2013-CIRM]** Section II.C (CIRM方法，頁面2084-2086)
- **[Cheng2013-CIRM]** 方程式(10)-(21) - 數學推導

**學習重點：**
- 連續空間變數的優勢
- 頻域vs空域實作
- 零偏差達成原理

#### Day 4-5: 雜訊分析
**閱讀材料：**
- **[Cheng2013-CIRM]** Section II.D (Effect of Image Noise)
- **[Cheng2013-CIRM]** 方程式(22)-(27) - 誤差傳播

### Week 7: 實作與比較

#### Day 1-3: 演算法實作
**閱讀材料：**
- **[Cheng2013-CIRM]** Section III (Computer Simulation)
- **[Cheng2013-CIRM]** Figure 1-3 - 模擬結果

#### Day 4-5: 實驗驗證
**閱讀材料：**
- **[Cheng2013-CIRM]** Section IV (Experimental Results)
- **[Cheng2013-CIRM]** 0.1nm解析度達成

---

## 第四階段：系統整合與應用（2週）

### Week 8: 六軸視覺伺服控制

#### Day 1-3: 白光干涉測量整合
**閱讀材料：**
- **[Cheng2018]** Section II.A (3-DOF LSWLI，頁面1565-1566)
- **[Cheng2018]** 方程式(3)-(4) - NLLS參數估計

#### Day 4-5: 六軸追蹤實現
**閱讀材料：**
- **[Cheng2018]** Section II.B (In-plane motion tracking)
- **[Cheng2018]** Figure 7-9 - 實驗結果

---

## 💻 程式實作專案

### 初級專案（第1-2週）
```python
# Project 1: 基礎質心法實作
- centroid_tracker.py
- threshold_analysis.py
- noise_simulation.py
```

### 中級專案（第3-4週）
```python
# Project 2: 3D粒子追蹤系統
- radial_projection.py
- calibration_module.py
- matching_algorithm.py
- bias_compensation.py
```

### 進階專案（第5-8週）
```python
# Project 3: 即時追蹤系統
- realtime_tracker.py
- continuous_registration.py
- six_axis_tracking.py
```

---

## 📊 評估檢查點

### 第一階段檢查（第3週末）
- [ ] 能解釋離焦影像包含深度資訊的原理
- [ ] 完成質心法與徑向投影的程式實作
- [ ] 理解S(z)曲線的意義

### 第二階段檢查（第5週末）
- [ ] 理解FPGA加速的必要性
- [ ] 完成偏差補償的實作
- [ ] 達到模擬環境中的奈米級追蹤

### 第三階段檢查（第7週末）
- [ ] 理解CIRM零偏差原理
- [ ] 完成頻域配準實作
- [ ] 比較不同方法的優劣

### 最終評估（第8週末）
- [ ] 整合多種技術完成完整系統
- [ ] 撰寫技術報告
- [ ] 提出改進方向

---

## 📖 補充閱讀材料

1. **影像處理基礎**
   - Gonzalez & Woods, "Digital Image Processing"
   - 特別關注：Chapter 4 (Fourier Transform), Chapter 12 (Registration)

2. **光學顯微鏡原理**
   - Born & Wolf, "Principles of Optics"
   - 重點：Airy disk, PSF, 數值孔徑

3. **最佳化理論**
   - Boyd & Vandenberghe, "Convex Optimization"
   - 應用：非線性最小平方法

---

## 🎯 學習成果目標

完成本學習計畫後，您將能夠：

1. **理論層面**
   - 深入理解離焦影像3D追蹤原理
   - 掌握影像配準的數學基礎
   - 進行完整的誤差分析

2. **實作能力**
   - 實現完整的3D粒子追蹤系統
   - 優化演算法達到即時處理
   - 整合多種感測技術

3. **研究能力**
   - 評估不同技術方案
   - 提出創新改進方向
   - 撰寫技術文獻

---

## 📅 時間管理建議

- **每日學習時間**：3-4小時
- **理論/實作比例**：40% / 60%
- **每週回顧**：週五下午總結本週學習
- **專案時間**：集中在週末進行

---

## 💡 學習技巧

1. **做筆記**：為每篇論文建立詳細筆記
2. **畫圖表**：視覺化關鍵概念
3. **寫代碼**：邊學邊實作
4. **討論交流**：加入相關研究社群
5. **定期複習**：鞏固核心概念