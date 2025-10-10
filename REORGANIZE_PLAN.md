# 檔案重整計畫

## 新的目錄架構

```
Report & Note/
│
├── Report.pptx                       # 簡報檔案（最外層）
├── Openloop_Cali.pptx               # 簡報檔案（最外層）
│
├── 01_Openpilot/                    # Openpilot 自動駕駛專案
│   └── REPORT_FINAL.md
│
├── 02_Control_Systems/              # 控制系統相關
│   ├── PID/
│   │   ├── PID.pdf
│   │   ├── PID_Ctrl.pdf
│   │   ├── PID_Ctrl.typ
│   │   └── test.typ
│   │
│   ├── HSCtrl/
│   │   ├── HSCtrl.pdf
│   │   └── HSCtrl.typ
│   │
│   └── TransferFunction/
│       ├── transfer_function_fitting.pdf
│       ├── transfer_function_fitting.typ
│       └── curve_fitting_derivation.typ
│
├── 03_Calibration/                  # 校正相關
│   ├── Openloop_Cali.docx
│   └── Openloop_Cali.pdf
│
├── 04_Matrix_Analysis/              # 矩陣分析
│   ├── B_matrix.pdf
│   ├── B_matrix.typ
│   ├── matlab/
│   │   ├── analyze_all_invB.m
│   │   └── coculate.m
│   └── results/
│       ├── p1_final.jpg
│       └── p5_final.jpg
│
├── 05_USB_Communication/            # USB 通訊
│   ├── USB_Parameter_Transmission.pdf
│   └── USB_Parameter_Transmission.typ
│
├── 06_Particle_Tracking/            # 粒子追蹤
│   └── particle-tracking-study-plan.md
│
└── _archive/                        # 暫存/過時檔案
    └── ~$enloop_Cali.docx          # Word 暫存檔
```

---

## 檔案移動清單

### 第 1 組：Openpilot
- `REPORT_FINAL.md` → `01_Openpilot/`

### 第 2 組：控制系統 - PID
- `PID.pdf` → `02_Control_Systems/PID/`
- `PID_Ctrl.pdf` → `02_Control_Systems/PID/`
- `PID_Ctrl.typ` → `02_Control_Systems/PID/`
- `test.typ` → `02_Control_Systems/PID/`

### 第 3 組：控制系統 - HSCtrl
- `HSCtrl.pdf` → `02_Control_Systems/HSCtrl/`
- `HSCtrl.typ` → `02_Control_Systems/HSCtrl/`

### 第 4 組：控制系統 - 傳遞函數
- `transfer_function_fitting.pdf` → `02_Control_Systems/TransferFunction/`
- `transfer_function_fitting.typ` → `02_Control_Systems/TransferFunction/`
- `curve_fitting_derivation.typ` → `02_Control_Systems/TransferFunction/`

### 第 5 組：校正
- `Openloop_Cali.docx` → `03_Calibration/`
- `Openloop_Cali.pdf` → `03_Calibration/`
- ~~`Openloop_Cali.pptx`~~ → **保留在最外層**

### 第 6 組：矩陣分析
- `B_matrix.pdf` → `04_Matrix_Analysis/`
- `B_matrix.typ` → `04_Matrix_Analysis/`
- `analyze_all_invB.m` → `04_Matrix_Analysis/matlab/`
- `coculate.m` → `04_Matrix_Analysis/matlab/`
- `p1_final.jpg` → `04_Matrix_Analysis/results/`
- `p5_final.jpg` → `04_Matrix_Analysis/results/`

### 第 7 組：USB 通訊
- `USB_Parameter_Transmission.pdf` → `05_USB_Communication/`
- `USB_Parameter_Transmission.typ` → `05_USB_Communication/`

### 第 8 組：粒子追蹤
- `particle-tracking-study-plan.md` → `06_Particle_Tracking/`

### 第 9 組：暫存檔案（移至 archive）
- `~$enloop_Cali.docx` → `_archive/`

### 保留在最外層
- `Report.pptx` ✅
- `Openloop_Cali.pptx` ✅
- `.gitignore` ✅
- `.git/` ✅
- `.claude/` ✅

---

## 執行步驟

1. 建立所有目錄
2. 移動檔案到對應位置
3. 確認檔案都已正確移動
4. 刪除此計畫檔案（如果你願意）

---

## 注意事項

- 所有操作使用 `git mv` 保留 Git 歷史記錄
- 簡報檔案（.pptx）保留在最外層方便存取
- 暫存檔案移至 `_archive/` 而非直接刪除
- 不建立任何 README.md 檔案

---

**請確認此計畫後，我會開始執行檔案移動操作。**
