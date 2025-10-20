# Openpilot v0.9.1 完整研究環境建置報告

**專案名稱：** Openpilot v0.9.1 自動駕駛系統研究環境建置
**執行期間：** 2025年9月26日 - 2025年10月9日
**執行者：** kevinfan100
**系統環境：** Ubuntu 20.04 LTS (Dual Boot)
**硬體設備：** ROG Zephyrus G14 GA401IU
**最終狀態：** ✅ 兩個 Demo 都可成功運行

---

## 📋 目錄

1. [專案概述](#專案概述)
2. [環境需求](#環境需求)
3. [完整建置時間軸](#完整建置時間軸)
4. [所有遇到的問題與解決方案](#所有遇到的問題與解決方案)
5. [Taiwan Demo 特別除錯記錄](#taiwan-demo-特別除錯記錄)
6. [除錯方法總結](#除錯方法總結)
7. [最終成果](#最終成果)
8. [使用指南](#使用指南)
9. [後續研究建議](#後續研究建議)
10. [附錄](#附錄)

---

## 專案概述

### 目標

建立 Openpilot v0.9.1 的完整研究環境，能夠：
- 編譯 Openpilot UI 程式和 Replay 工具
- 執行 USA Demo（標準測試資料）
- 執行 Taiwan Demo（台灣道路資料）
- 觀察自動駕駛系統的即時運作
- 分析車道線偵測、路徑規劃等算法

### 背景

Openpilot 是 comma.ai 開發的開源自動駕駛系統，可以安裝在支援的車輛上提供：
- 自適應巡航控制 (ACC)
- 車道保持輔助 (LKAS)
- 自動駕駛功能

本專案使用 Replay 工具在電腦上重現真實行駛資料，無需實體車輛即可研究系統運作。

### 參考文件

- 主要參考：InstallOP.docx.md (JLL 2020.8.11 - 2024.11.14)
- Openpilot 官方：https://github.com/commaai/openpilot
- 版本：v0.9.1
- 輔助資料：tools092.pdf, tools092.zip

---

## 環境需求

### 硬體需求

| 項目 | 最低需求 | 建議配置 | 本次使用 |
|------|---------|---------|---------|
| CPU | Intel i5 / AMD Ryzen 5 | Intel i7 / AMD Ryzen 7 | AMD Ryzen 9 4900HS |
| RAM | 8 GB | 16 GB | 40 GB |
| 儲存空間 | 50 GB | 100 GB | 充足 |
| 顯示卡 | 整合顯卡 | 獨立顯卡 | NVIDIA GTX 1660 Ti |
| 網路 | 必須 | 必須 | WiFi |

### 軟體需求

| 項目 | 版本 | 用途 |
|------|------|------|
| 作業系統 | Ubuntu 20.04 LTS | 開發環境 |
| Python | 3.8.2 / 3.8.10 | 主程式語言 |
| Poetry | 1.2.2 - 1.3.2 | Python 套件管理 |
| SCons | 4.4.0 | 建置工具 |
| Git | 最新版 | 版本控制 |
| Git LFS | 2.9.2+ | 大型檔案管理 |

---

## 完整建置時間軸

### Phase 0: 初次安裝 (2025-09-26)

#### 0.1 前置準備
```bash
# 安裝基礎工具
sudo apt update
sudo apt install -y curl git python3.8 python3.8-venv

# 安裝 Poetry
curl -sSL https://install.python-poetry.org | python3.8 -
echo 'export PATH=$PATH:$HOME/.local/bin' >> ~/.bashrc
source ~/.bashrc
```

**狀態：** ✅ Poetry 1.2.2 安裝成功

#### 0.2 克隆 Openpilot
```bash
git clone -b v0.9.1 https://github.com/commaai/openpilot
cd openpilot
sudo git submodule update --init  # ⚠️ 這裡使用 sudo 會造成問題
```

**問題：** 使用 sudo 導致後續權限錯誤

#### 0.3 替換 tools 目錄
- 從 tools092.zip 替換 tools 資料夾
- 包含修改版的 replayJLL 和測試資料

**狀態：** ✅ 完成

#### 0.4 建立虛擬環境
```bash
python3.8 -m venv ~/sconsvenv
source ~/sconsvenv/bin/activate
pip install scons==4.4.0
```

**狀態：** ✅ SCons 4.4.0 安裝成功

#### 0.5 執行環境設定
```bash
cd ~/openpilot
tools/ubuntu_setup.sh
```

**遇到問題：**
- poetry.lock 是 Git LFS 指標檔案
- 網路連線逾時無法重新生成
- 按文件指示忽略錯誤繼續

**狀態：** ⚠️ 部分錯誤但按文件指示忽略

#### 0.6 初次編譯嘗試
```bash
cd ~/openpilot
source ~/sconsvenv/bin/activate
scons -i
```

**遇到問題：**
- 多個權限錯誤
- 無法寫入 obj/gitversion.h
- cereal 相關檔案權限被拒

**狀態：** ❌ 編譯失敗，_ui 未生成

#### 0.7 測試 Replay
```bash
cd ~/openpilot/tools/replay
chmod +x ./replayJLL
./replayJLL --demo
```

**結果：**
- ✅ USA Demo 成功載入
- ❌ Taiwan 資料測試失敗（資料不完整）

**Phase 0 總結：**
- 基本環境配置完成
- Replay 功能可運行
- UI 編譯失敗需要解決

---

### Phase 1: 完成 UI 編譯 (2025-10-08)

#### 1.1 [16:30] 診斷問題
檢查發現 `_ui` 執行檔不存在，需要重新編譯。

#### 1.2 [16:33] 解決問題 #1 - 檔案權限

**症狀：**
```
error: unable to open output file 'cereal/messaging/messaging.os': 'Permission denied'
scons: *** [cereal/messaging/messaging.os] Error 1
```

**診斷：**
```bash
ls -ld ~/openpilot/cereal/messaging/
# drwxr-xr-x 3 root root 4096 ...  ← 擁有者是 root！
```

**原因：** 之前使用 `sudo git submodule update --init`

**解決：**
```bash
sudo chown -R kevinfan100:kevinfan100 ~/openpilot/
```

**狀態：** ✅ 權限修正完成

#### 1.3 [16:45] 解決問題 #2 - Git LFS 檔案

**症狀：**
```
/usr/bin/ld:third_party/mapbox-gl-native-qt/x86_64/libqmapboxgl.so: file format not recognized
```

**診斷：**
```bash
file ~/openpilot/third_party/mapbox-gl-native-qt/x86_64/libqmapboxgl.so
# .../libqmapboxgl.so: ASCII text  ← 應該是 ELF 檔案！
```

**原因：** Git LFS 指標檔案未被替換為實際二進位檔

**解決：**
```bash
cd ~/openpilot
git lfs pull
```

**驗證：**
```bash
file ~/openpilot/third_party/mapbox-gl-native-qt/x86_64/libqmapboxgl.so
# .../libqmapboxgl.so: ELF 64-bit LSB shared object  ← 正確！
```

**狀態：** ✅ LFS 檔案下載完成（9.8MB）

#### 1.4 [16:53] 解決問題 #3 - Python 模組缺失

**症狀：**
```
ModuleNotFoundError: No module named 'smbus2'
```

**解決：**
```bash
source ~/sconsvenv/bin/activate
pip install smbus2
```

**狀態：** ✅ 模組安裝完成

#### 1.5 [16:54] ✅ UI 編譯成功！

**執行：**
```bash
cd ~/openpilot
source ~/sconsvenv/bin/activate
scons -i -j4 selfdrive/ui/
```

**結果：**
- ✅ `_ui` 編譯成功（27MB）
- ✅ `_soundd` 音效處理程式
- ✅ 其他輔助工具

**驗證：**
```bash
ls -lh ~/openpilot/selfdrive/ui/_ui
# -rwxrwxr-x 1 kevinfan100 kevinfan100 27M 10月  8 16:54 _ui
```

---

### Phase 2: USA Demo 測試 (2025-10-08)

#### 2.1 [17:00] 初次測試遇到問題

**執行：**
```bash
cd ~/openpilot/tools/replay
./replayJLL --demo
```

**結果：**
- ✅ Replay 正常運行
- ❌ UI 視窗一閃就關閉

#### 2.2 [17:15] 解決問題 #4 - TERM 環境變數

**症狀：** UI 視窗立即崩潰

**診斷：**
```bash
echo $TERM
# dumb  ← 問題！IDE 設定的終端類型
```

**錯誤訊息：**
```
Error opening terminal: unknown.
_ui: cereal/messaging/msgq.cc:386: Assertion `size > 0' failed.
```

**原因：**
- 在 Claude Code IDE 整合終端機執行
- `TERM=dumb` 不支援 UI 程式

**解決方案 A：** 使用系統終端機
```bash
# 按 Ctrl+Alt+T 開啟系統終端機
```

**解決方案 B：** 設定 TERM 變數
```bash
TERM=xterm ./selfdrive/ui/ui
```

**狀態：** ✅ UI 可以啟動了

#### 2.3 [17:50] 解決問題 #5 - 版本不相容 ⭐ 最關鍵

**症狀：** UI 啟動後立即崩潰

**錯誤訊息：**
```
_ui: cereal/messaging/msgq.cc:385: int msgq_msg_recv(msgq_msg_t *, msgq_queue_t *):
Assertion `(uint64_t)size < q->size' failed.
```

**診斷：**
```bash
ls -l ~/openpilot/tools/replay/replayJLL
# -rwxr-xr-x ... 8月 24  2023 replayJLL  ← 2023年編譯

ls -l ~/openpilot/selfdrive/ui/_ui
# -rwxrwxr-x ... 10月 8  2025 _ui  ← 2025年編譯
```

**根本原因：**
- replayJLL (2023) 與新編譯的 _ui (2025) 訊息協議不相容
- 訊息大小超過 UI 的佇列限制
- cereal 版本不匹配

**解決：重新編譯 Replay**
```bash
cd ~/openpilot
source ~/sconsvenv/bin/activate

# 清理舊的編譯檔
scons -c tools/replay/

# 重新編譯
scons -i -j4 tools/replay/

# 修正執行權限
chmod +x ~/openpilot/tools/replay/replay
```

**狀態：** ✅ Replay 重新編譯完成

#### 2.4 [18:00] 🎉 USA Demo 成功運行！

**執行：**
```bash
# 終端機 1
cd ~/openpilot/tools/replay
./replay --demo

# 終端機 2 (等5-8秒)
cd ~/openpilot
TERM=xterm ./selfdrive/ui/ui
```

**成功標誌：**
- ✅ 全螢幕 UI 視窗顯示
- ✅ 道路實景影像流暢播放
- ✅ 綠色車道線即時更新
- ✅ 藍色/白色路徑規劃點
- ✅ 車輛資訊：TOYOTA RAV4 2017
- ✅ 速度、狀態持續更新

**Phase 2 總結：**
- ✅ 解決 5 個主要問題
- ✅ USA Demo 完全正常運行
- ✅ 建立快速啟動腳本

---

### Phase 3: Taiwan Demo 除錯 (2025-10-09)

#### 3.1 [19:30] 初次測試 Taiwan Demo

**執行：**
```bash
cd ~/openpilot/tools/replay
./replay --data_dir dataC "8bfda98c9c9e4291|2020-05-11--03-00-57--61"
```

**結果：**
- ❌ 錯誤：`failed to load route from "dataC"`
- UI 有出現但沒有影片

#### 3.2 [19:45] 診斷資料結構問題

**檢查資料目錄：**
```bash
ls -la ~/openpilot/tools/replay/dataC/
# 8bfda98c9c9e4291|2020-05-11--03-00-57/
#   └── 61/
#       ├── fcamera.hevc (37MB)
#       └── rlog.bz2 (6MB)
```

**問題分析：**
1. replay 使用 `--61` 格式（雙破折號）
2. 實際目錄是 `/61` 格式（斜線）
3. 資料結構不符合 replay 預期

#### 3.3 [20:00] 研究 replay 源碼

**查看 route.cc：**
```cpp
// tools/replay/route.cc:65-78
bool Route::loadFromLocal() {
  QDir log_dir(data_dir_);
  for (const auto &folder : log_dir.entryList(...)) {
    int pos = folder.lastIndexOf("--");
    if (pos != -1 && folder.left(pos) == route_.timestamp) {
      const int seg_num = folder.mid(pos + 2).toInt();
      // 期望格式：2020-05-11--03-00-57--61
      ...
    }
  }
}
```

**發現：**
- replay 期望目錄名為 `YYYY-MM-DD--HH-MM-SS--NN`
- 但實際資料結構是 `route_id|YYYY-MM-DD--HH-MM-SS/NN`

#### 3.4 [20:10] 重組資料結構

**解決方案：建立符號連結**
```bash
cd ~/openpilot/tools/replay/dataC

# 將 62 目錄移動並重命名
mv "8bfda98c9c9e4291|2020-05-11--03-00-57/61" "2020-05-11--03-00-57--61"

# 清理空目錄
rmdir "8bfda98c9c9e4291|2020-05-11--03-00-57"
```

**驗證：**
```bash
ls -la ~/openpilot/tools/replay/dataC/
# 2020-05-11--03-00-57--61/
#   ├── fcamera.hevc
#   └── rlog.bz2
```

#### 3.5 [20:15] 測試載入成功但仍無畫面

**執行：**
```bash
./replay --data_dir dataC "8bfda98c9c9e4291|2020-05-11--03-00-57--61"
```

**日誌顯示：**
```
loading route  "8bfda98c9c9e4291|2020-05-11--03-00-57--61"
load route 8bfda98c9c9e4291|2020-05-11--03-00-57 with 1 valid segments  ← 成功！
Starting listener for: camerad  ← 開始視訊
```

**但 UI 仍然閃退！**

#### 3.6 [20:25] 發現 replayJLL 版本問題

**問題：**
- 標準 `replay` 已重新編譯（2025）
- 但 Taiwan Demo 腳本使用的是 `replayJLL`（2023）
- 版本不一致導致崩潰

**檢查：**
```bash
ls -l ~/openpilot/tools/replay/
# -rwxr-xr-x ... 10月  8 replay      ← 新版
# -rwxrwxr-x ... 8月 24  2023 replayJLL  ← 舊版
```

**解決：修改腳本使用新版 replay**
```bash
# 編輯 run_taiwan_demo.sh
# 將 ./replayJLL 改為 ./replay
```

#### 3.7 [20:30] 解決 camerad 初始化問題

**新問題：** UI 仍然閃退

**診斷：**
```bash
cat /tmp/ui_taiwan.log
# _ui: cereal/messaging/msgq.cc:386: Assertion `size > 0' failed.
```

**原因：** UI 啟動太快，camerad 還沒準備好

**解決：增加等待時間**
```bash
# 在腳本中等待 camerad 啟動
for i in {1..15}; do
    if grep -q "Starting listener for: camerad" /tmp/replay_taiwan.log; then
        echo "✅ Camerad 已啟動！"
        break
    fi
    sleep 1
done
sleep 2  # 額外緩衝時間
```

#### 3.8 [20:40] 清理共享記憶體

**新增腳本開頭：**
```bash
# 清理舊的共享記憶體，避免舊資料干擾
echo "🧹 清理舊的共享記憶體..."
rm -f /dev/shm/*
```

#### 3.9 [20:50] 🎉 Taiwan Demo 成功運行！

**最終腳本配置：**
1. ✅ 清理共享記憶體
2. ✅ 使用新編譯的 replay（不是 replayJLL）
3. ✅ 正確的資料目錄結構
4. ✅ 等待 camerad 完全啟動
5. ✅ 設定 TERM=xterm

**執行：**
```bash
~/openpilot/run_taiwan_demo.sh
```

**成功標誌：**
- ✅ UI 視窗穩定顯示
- ✅ 台灣道路畫面播放
- ✅ 車道線偵測正常
- ✅ 車輛資訊：TOYOTA PRIUS 2017
- ✅ 無閃退問題

**Phase 3 總結：**
- ✅ 解決資料結構問題
- ✅ 解決版本相容問題
- ✅ 解決初始化時序問題
- ✅ Taiwan Demo 完全正常運行

---

## 所有遇到的問題與解決方案

### 問題總覽

| # | 問題 | 嚴重程度 | 解決時間 | 發生階段 |
|---|------|---------|---------|---------|
| 1 | 檔案權限問題 | 🔴 高 | 5 分鐘 | Phase 1 |
| 2 | Git LFS 檔案問題 | 🔴 高 | 10 分鐘 | Phase 1 |
| 3 | Python 模組缺失 | 🟡 中 | 2 分鐘 | Phase 1 |
| 4 | TERM 環境變數 | 🟡 中 | 5 分鐘 | Phase 2 |
| 5 | 版本不相容 | 🔴 高 | 20 分鐘 | Phase 2 |
| 6 | Taiwan 資料結構 | 🟡 中 | 30 分鐘 | Phase 3 |
| 7 | Camerad 初始化 | 🟡 中 | 15 分鐘 | Phase 3 |

---

### 問題 #1: 檔案權限問題

#### 症狀描述
```
error: unable to open output file 'cereal/messaging/messaging.os': 'Permission denied'
scons: *** [cereal/messaging/messaging.os] Error 1
```

#### 根本原因
使用 `sudo git submodule update --init` 導致部分目錄的擁有者變成 `root`。

#### 診斷方法
```bash
ls -ld ~/openpilot/cereal/messaging/
# drwxr-xr-x 3 root root 4096 ...  ← 問題
# drwxr-xr-x 3 kevinfan100 kevinfan100 4096 ...  ← 正確
```

#### 解決步驟
```bash
# 修正整個專案目錄
sudo chown -R kevinfan100:kevinfan100 ~/openpilot/
```

#### 預防措施
- ❌ 避免使用 `sudo git submodule update --init`
- ✅ 使用 `git submodule update --init`（不加 sudo）

---

### 問題 #2: Git LFS 檔案未下載

#### 症狀描述
```
/usr/bin/ld:third_party/mapbox-gl-native-qt/x86_64/libqmapboxgl.so: file format not recognized
```

#### 根本原因
Git LFS 指標檔案未被替換為實際的二進位檔案。

**檔案內容範例（錯誤）：**
```
version https://git-lfs.github.com/spec/v1
oid sha256:ee37b571a5a50d07f2fd1a3150aa2842f10576e96e01278bbc060815549d57e9
size 10219704
```

#### 診斷方法
```bash
# 檢查檔案類型
file ~/openpilot/third_party/mapbox-gl-native-qt/x86_64/libqmapboxgl.so
# 錯誤：ASCII text
# 正確：ELF 64-bit LSB shared object

# 查看檔案大小
ls -lh ~/openpilot/third_party/mapbox-gl-native-qt/x86_64/libqmapboxgl.so
# 錯誤：幾百 bytes
# 正確：約 10 MB
```

#### 解決步驟
```bash
cd ~/openpilot
git lfs pull

# 驗證
file ~/openpilot/third_party/mapbox-gl-native-qt/x86_64/libqmapboxgl.so
# 應顯示：ELF 64-bit LSB shared object
```

---

### 問題 #3: Python 模組缺失 (smbus2)

#### 症狀描述
```
ModuleNotFoundError: No module named 'smbus2'
```

#### 解決步驟
```bash
source ~/sconsvenv/bin/activate
pip install smbus2
```

---

### 問題 #4: TERM 環境變數導致 UI 崩潰

#### 症狀描述
- UI 視窗一閃就關閉
- Replay 顯示：`Error opening terminal: unknown.`

#### 根本原因
在 IDE (Claude Code) 整合終端機執行，`TERM=dumb` 不支援 UI 程式。

#### 診斷方法
```bash
echo $TERM
# 問題：dumb
# 正確：xterm, xterm-256color, linux
```

#### 解決方案
```bash
# 方案 A：使用系統終端機（推薦）
# 按 Ctrl+Alt+T

# 方案 B：設定 TERM 變數
TERM=xterm ./selfdrive/ui/ui

# 方案 C：使用修正版腳本（自動設定）
```

---

### 問題 #5: Replay 與 UI 版本不相容 ⭐ 最關鍵

#### 症狀描述
```
_ui: cereal/messaging/msgq.cc:385: Assertion `(uint64_t)size < q->size' failed.
```

#### 根本原因
- replayJLL：2023年8月編譯
- _ui：2025年10月編譯
- 訊息佇列協議不相容

#### 診斷方法
```bash
ls -l ~/openpilot/tools/replay/replayJLL
# -rwxr-xr-x ... 8月 24  2023

ls -l ~/openpilot/selfdrive/ui/_ui
# -rwxrwxr-x ... 10月  8  2025

# 日期相差太多 → 可能不相容
```

#### 解決步驟
```bash
source ~/sconsvenv/bin/activate
cd ~/openpilot

# 清理舊的編譯檔
scons -c tools/replay/

# 重新編譯
scons -i -j4 tools/replay/

# 修正執行權限
chmod +x ~/openpilot/tools/replay/replay
```

#### 重要教訓
**版本一致性原則：**
1. ✅ 所有組件應同時編譯
2. ❌ 不要混用新舊編譯的二進位檔
3. ✅ 更新程式碼後重新編譯所有相依組件

---

### 問題 #6: Taiwan 資料結構不符

#### 症狀描述
```
failed to load route "8bfda98c9c9e4291|2020-05-11--03-00-57" from "dataC"
```

#### 根本原因
資料目錄結構不符合 replay 預期格式：
- 實際：`8bfda98c9c9e4291|2020-05-11--03-00-57/61/`
- 預期：`2020-05-11--03-00-57--61/`

#### 解決步驟
```bash
cd ~/openpilot/tools/replay/dataC

# 方案 A：重命名（移動資料）
mv "8bfda98c9c9e4291|2020-05-11--03-00-57/61" "2020-05-11--03-00-57--61"

# 方案 B：建立符號連結（保留原結構）
mkdir -p "8bfda98c9c9e4291|2020-05-11--03-00-57"
ln -sf ../2020-05-11--03-00-57--61 "8bfda98c9c9e4291|2020-05-11--03-00-57/61"
```

---

### 問題 #7: Camerad 初始化時序

#### 症狀描述
UI 啟動但立即崩潰，即使 replay 正常運行。

#### 根本原因
UI 啟動時 camerad 還沒準備好發送視訊資料。

#### 解決步驟
在腳本中加入等待機制：
```bash
# 等待 camerad 啟動
for i in {1..15}; do
    if grep -q "Starting listener for: camerad" /tmp/replay_taiwan.log; then
        echo "✅ Camerad 已啟動！"
        break
    fi
    echo -n "等待中... $i/15 "
    sleep 1
done
sleep 2  # 額外緩衝
```

---

## Taiwan Demo 特別除錯記錄

### 除錯時間軸

#### 第一次嘗試：資料路徑問題
```bash
./replay --data_dir dataC "8bfda98c9c9e4291|2020-05-11--03-00-57--61"
# 錯誤：failed to load route
```

**發現：** 路徑格式錯誤（`--61` vs `/61`）

#### 第二次嘗試：資料結構調整
```bash
# 重組目錄結構
mv .../61 "2020-05-11--03-00-57--61"
# 成功：load route ... with 1 valid segments
```

**但：** UI 仍然閃退

#### 第三次嘗試：版本問題
**發現：** 使用舊版 replayJLL (2023)

**修正：** 改用新編譯的 replay (2025)

**但：** UI 還是閃退

#### 第四次嘗試：初始化時序
**發現：** UI 啟動太快，camerad 未準備好

**修正：** 加入等待 camerad 的邏輯

**結果：** ✅ 成功！

### 最終解決方案

完整的 `run_taiwan_demo.sh` 腳本包含：

1. **清理環境**
```bash
rm -f /dev/shm/*  # 清理共享記憶體
```

2. **使用正確版本**
```bash
./replay  # 不是 ./replayJLL
```

3. **等待初始化**
```bash
# 等待 camerad 啟動
grep -q "Starting listener for: camerad" /tmp/replay_taiwan.log
sleep 2
```

4. **設定環境變數**
```bash
export TERM=xterm
```

---

## 除錯方法總結

### 系統化診斷流程

```
遇到問題
    ↓
1. 記錄完整錯誤訊息
    ↓
2. 檢查檔案權限與類型
    ├─ ls -la
    ├─ file <檔案>
    └─ ldd <執行檔>
    ↓
3. 檢查環境變數
    ├─ echo $DISPLAY
    ├─ echo $TERM
    └─ echo $PATH
    ↓
4. 查看日誌
    ├─ 編譯日誌
    ├─ /tmp/*.log
    └─ stderr 輸出
    ↓
5. 驗證檔案完整性
    ├─ Git LFS 狀態
    ├─ 檔案大小
    └─ 檔案類型
    ↓
6. 檢查版本一致性
    ├─ 編譯日期
    ├─ library 版本
    └─ 依賴關係
    ↓
7. 追蹤源碼邏輯
    ├─ 閱讀相關源碼
    ├─ 理解預期行為
    └─ 對比實際狀況
```

### 常用除錯指令集

#### 檔案檢查
```bash
file <檔案>                  # 檢查檔案類型
ls -la <檔案>                # 檢查權限和擁有者
ldd <執行檔>                 # 檢查依賴
find <目錄> -name "檔案名"   # 查找檔案
grep -r "搜尋字串" <目錄>    # 搜尋內容
```

#### 權限診斷
```bash
ls -ld <目錄>                          # 檢查目錄擁有者
find ~/openpilot -user root            # 查找 root 擁有的檔案
sudo chown -R $USER:$USER <目錄>       # 修正權限
chmod +x <執行檔>                      # 添加執行權限
```

#### Git LFS 診斷
```bash
git lfs status                                    # 檢查 LFS 狀態
find . -name "*.so" -exec file {} \; | grep ASCII # 查找 LFS 指標
git lfs pull                                      # 下載 LFS 檔案
head -3 <檔案>                                   # 檢查是否為指標
```

#### 編譯問題診斷
```bash
scons -c                          # 清理編譯
scons -i -j4 <目標>              # 編譯特定目標
ls -lt <編譯產物>                 # 檢查編譯日期
ldd <執行檔> | grep cereal       # 檢查 library 版本
```

#### 環境變數診斷
```bash
echo $DISPLAY          # 檢查顯示環境
echo $TERM            # 檢查終端類型
export TERM=xterm     # 設定終端類型
env | grep -i term    # 查看所有相關變數
```

### 進階除錯技巧

#### 使用 strace 追蹤系統呼叫
```bash
strace -e openat ./replay --demo 2>&1 | grep dataC
strace -e trace=file ./selfdrive/ui/ui
```

#### 查看共享記憶體
```bash
ipcs -m              # 檢查共享記憶體段
df -h /dev/shm       # 檢查 /dev/shm 空間
ls -la /dev/shm/     # 查看共享記憶體檔案
```

#### 監控程序
```bash
ps aux | grep -E "(replay|_ui)"    # 查看程序
top -p $(pgrep -d',' replay)       # 監控 CPU/記憶體
```

---

## 最終成果

### 成功指標

#### 編譯成果

| 組件 | 狀態 | 檔案大小 | 位置 | 編譯日期 |
|------|------|---------|------|---------|
| _ui | ✅ | 27 MB | `selfdrive/ui/_ui` | 2025-10-08 |
| replay | ✅ | 11 MB | `tools/replay/replay` | 2025-10-08 |
| _soundd | ✅ | - | `selfdrive/ui/soundd/_soundd` | 2025-10-08 |

#### 功能驗證

**USA Demo 測試結果：**

| 功能 | 狀態 | 說明 |
|------|------|------|
| UI 啟動 | ✅ | 全螢幕顯示正常 |
| 影片播放 | ✅ | 道路實景流暢播放 |
| 車道線偵測 | ✅ | 綠色線條即時更新 |
| 路徑規劃 | ✅ | 藍色/白色點顯示路徑 |
| 車輛辨識 | ✅ | 前車偵測框顯示 |
| 速度資訊 | ✅ | 即時更新 |
| 狀態指示 | ✅ | Engaged/Disengaged 正常 |
| 時間軸 | ✅ | 播放進度顯示 |

**測試資料：**
- 路線：4cf7a6ad03080c90|2021-09-29--13-46-36
- Segments：11 個
- 車輛：TOYOTA RAV4 2017
- 地點：美國加州
- 時長：約 11 分鐘

**Taiwan Demo 測試結果：**

| 功能 | 狀態 | 說明 |
|------|------|------|
| UI 啟動 | ✅ | 穩定顯示無閃退 |
| 影片播放 | ✅ | 台灣道路畫面 |
| 車道線偵測 | ✅ | 正常運作 |
| 路徑規劃 | ✅ | 正常顯示 |
| 速度資訊 | ✅ | 即時更新 |

**測試資料：**
- 路線：8bfda98c9c9e4291|2020-05-11--03-00-57--61
- Segments：1 個
- 車輛：TOYOTA PRIUS 2017
- 地點：台灣
- 資料來源：dataC

### UI 畫面元素

```
┌────────────────────────────────────────────┐
│ [OPENPILOT]              時間 | 溫度 | 狀態 │
├────────────────────────────────────────────┤
│                                            │
│              前方道路實景影像                │
│         ══════ 綠色車道線 ══════            │
│            ● ● ● ● ● (路徑點)              │
│          🚗 前車偵測框 (如有)               │
│                                            │
│  速度: 24.13 m/s    |  ENGAGED ■■■■■      │
│  轉向剛性: 101.64%  |  播放進度           │
│  角度偏移: -1.61°   |  [==========>  ]    │
│                                            │
└────────────────────────────────────────────┘
```

---

## 使用指南

### 快速啟動腳本

#### USA Demo
```bash
~/openpilot/run_demo_fixed.sh
```

**腳本功能：**
- 自動設定 TERM=xterm
- 背景啟動 replay
- 等待初始化（5秒）
- 啟動 UI
- 自動清理程序

#### Taiwan Demo
```bash
~/openpilot/run_taiwan_demo.sh
```

**腳本功能：**
- 清理共享記憶體
- 啟動 Taiwan 資料 replay
- 等待 camerad 完全初始化
- 啟動 UI
- 自動清理程序

### 手動執行（兩個終端機）

#### 方式 A：推薦順序

**終端機 1（系統終端 Ctrl+Alt+T）：**
```bash
cd ~/openpilot/tools/replay
./replay --demo  # 或 USA Demo
# 或
./replay --data_dir dataC "8bfda98c9c9e4291|2020-05-11--03-00-57--61"  # Taiwan Demo
```

**終端機 2（等5-8秒後開啟）：**
```bash
cd ~/openpilot
TERM=xterm ./selfdrive/ui/ui
```

#### 方式 B：單一終端執行

```bash
cd ~/openpilot/tools/replay
./replay --demo &
sleep 5
cd ~/openpilot
TERM=xterm ./selfdrive/ui/ui
# UI 關閉後
kill %1  # 關閉 replay
```

### 重要注意事項

1. **必須使用系統終端機**
   - 不能在 IDE 整合終端機執行
   - 使用 Ctrl+Alt+T 開啟獨立終端

2. **啟動順序很重要**
   - 先啟動 replay
   - 等待 5-8 秒
   - 再啟動 UI

3. **環境變數設定**
   - 確保 TERM=xterm
   - 確保 DISPLAY=:0

4. **退出方式**
   - 關閉 UI 視窗或按 ESC
   - Ctrl+C 停止 replay

---

## 後續研究建議

### 階段 1: 熟悉系統運作 (1-2 週)

#### 1.1 觀察不同場景
- 直線道路時的行為
- 彎道時的路徑規劃
- 有前車時的反應
- 車道線不清楚時的處理

#### 1.2 研究 UI 程式碼
```
selfdrive/ui/
├── ui.cc          # 主程式
├── ui.h           # UI 定義
├── qt/
│   ├── onroad.cc  # 行駛中畫面
│   └── sidebar.cc # 側邊欄
```

#### 1.3 分析訊息協議
```
cereal/
├── messaging/     # 訊息佇列實作
├── *.capnp       # Cap'n Proto 定義
└── gen/          # 產生的程式碼
```

### 階段 2: 深入算法研究 (2-4 週)

#### 2.1 車道線偵測
- 深度學習模型架構
- 影像前處理方法
- 車道線拟合算法

#### 2.2 路徑規劃
- MPC (模型預測控制)
- 路徑平滑化
- 障礙物迴避

#### 2.3 車輛控制
- PID 控制原理
- 轉向控制
- 速度控制

### 階段 3: 參數調整實驗 (2-3 週)

#### 3.1 建立實驗環境
```bash
# 備份原始檔案
cp selfdrive/controls/lib/latcontrol_pid.py \
   selfdrive/controls/lib/latcontrol_pid.py.bak

# 修改參數
vim selfdrive/controls/lib/latcontrol_pid.py

# 重新編譯
scons -i -j4
```

#### 3.2 實驗項目
- 調整 PID 參數
- 修改巡航速度設定
- 測試不同跟車距離

---

## 附錄

### A. 完整指令清單

#### A.1 環境建置
```bash
# 安裝 Poetry
curl -sSL https://install.python-poetry.org | python3.8 -
echo 'export PATH=$PATH:$HOME/.local/bin' >> ~/.bashrc
source ~/.bashrc

# 建立虛擬環境
python3.8 -m venv ~/sconsvenv
source ~/sconsvenv/bin/activate
pip install scons==4.4.0

# 克隆 Openpilot
git clone -b v0.9.1 https://github.com/commaai/openpilot
cd openpilot
git submodule update --init  # 不要加 sudo！
```

#### A.2 編譯流程
```bash
# 啟動環境
source ~/sconsvenv/bin/activate
cd ~/openpilot

# 修正權限
sudo chown -R $USER:$USER ~/openpilot/

# 下載 Git LFS 檔案
git lfs pull

# 安裝 Python 模組
pip install smbus2

# 完整編譯
scons -i -j4

# 只編譯 UI
scons -i -j4 selfdrive/ui/

# 只編譯 Replay
scons -i -j4 tools/replay/

# 清理編譯
scons -c
```

#### A.3 執行測試
```bash
# 方法 1: 使用腳本
~/openpilot/run_demo_fixed.sh        # USA Demo
~/openpilot/run_taiwan_demo.sh       # Taiwan Demo

# 方法 2: 手動執行（兩個終端）
# 終端 1
cd ~/openpilot/tools/replay
./replay --demo

# 終端 2 (等 5-8 秒)
cd ~/openpilot
TERM=xterm ./selfdrive/ui/ui
```

### B. 檔案結構說明

```
~/openpilot/
├── cereal/                # 訊息定義與序列化
│   ├── messaging/         # 訊息佇列實作
│   └── *.capnp           # Cap'n Proto 定義
├── common/                # 共用工具
├── opendbc/              # CAN 資料庫
├── selfdrive/            # 核心程式
│   ├── controls/         # 控制邏輯
│   ├── modeld/           # 深度學習模型
│   └── ui/               # 使用者介面
│       ├── ui.cc         # UI 主程式
│       └── _ui           # 編譯產物 (27MB)
├── third_party/          # 第三方函式庫
└── tools/                # 開發工具
    └── replay/           # Replay 工具
        ├── replay        # 編譯產物 (11MB)
        └── dataC/        # Taiwan 測試資料
```

### C. 快速參考表

#### C.1 常用路徑

| 用途 | 路徑 |
|------|------|
| UI 執行檔 | `~/openpilot/selfdrive/ui/_ui` |
| UI 啟動腳本 | `~/openpilot/selfdrive/ui/ui` |
| Replay 執行檔 | `~/openpilot/tools/replay/replay` |
| USA Demo 腳本 | `~/openpilot/run_demo_fixed.sh` |
| Taiwan Demo 腳本 | `~/openpilot/run_taiwan_demo.sh` |
| Taiwan 測試資料 | `~/openpilot/tools/replay/dataC/` |
| 虛擬環境 | `~/sconsvenv/` |

#### C.2 環境變數

| 變數 | 建議值 | 說明 |
|------|--------|------|
| TERM | xterm | 終端類型 |
| DISPLAY | :0 | 顯示環境 |
| PATH | 包含 ~/.local/bin | Poetry 路徑 |

#### C.3 重要指令

| 功能 | 指令 |
|------|------|
| 啟動虛擬環境 | `source ~/sconsvenv/bin/activate` |
| 編譯全部 | `scons -i -j4` |
| 編譯 UI | `scons -i -j4 selfdrive/ui/` |
| 編譯 Replay | `scons -i -j4 tools/replay/` |
| 清理編譯 | `scons -c` |
| 執行 USA Demo | `~/openpilot/run_demo_fixed.sh` |
| 執行 Taiwan Demo | `~/openpilot/run_taiwan_demo.sh` |
| 修正權限 | `sudo chown -R $USER:$USER ~/openpilot/` |
| 下載 LFS | `git lfs pull` |

### D. 問題速查表

| 錯誤訊息關鍵字 | 可能原因 | 快速解決 |
|--------------|---------|---------|
| Permission denied | 權限問題 | `sudo chown -R $USER:$USER ~/openpilot/` |
| file format not recognized | Git LFS 未下載 | `git lfs pull` |
| ModuleNotFoundError | Python 模組缺失 | `pip install <模組名>` |
| Error opening terminal | TERM 變數錯誤 | `TERM=xterm` 或使用系統終端 |
| Assertion failed | 版本不相容 | 重新編譯 replay |
| cannot find -l | 缺少函式庫 | `sudo apt install lib<名稱>-dev` |
| failed to load route | 資料結構錯誤 | 檢查目錄格式 |

### E. 常見問答 (FAQ)

#### Q1: 為什麼一定要 Ubuntu 20.04？
**A:** Openpilot v0.9.1 針對 Ubuntu 20.04 開發，使用其他版本可能遇到相容性問題。

#### Q2: 可以在虛擬機中運行嗎？
**A:** 可以，但效能會較差，建議使用 Dual Boot。

#### Q3: 為什麼要重新編譯 replay？
**A:** tools092.zip 中的 replayJLL 是 2023 年編譯，與新編譯的 UI 不相容。

#### Q4: Taiwan 資料為什麼特別處理？
**A:** 資料目錄結構與標準格式不同，需要重新組織。

#### Q5: 編譯需要多久？
**A:**
- 完整編譯：15-30 分鐘（4 核心）
- 只編譯 UI：5-10 分鐘
- 只編譯 replay：10-20 分鐘

#### Q6: 兩個 Demo 有什麼差別？
**A:**
- USA Demo：標準測試資料，11 segments，加州道路
- Taiwan Demo：台灣道路資料，1 segment，需特別處理

---

## 致謝

- **comma.ai** - 開發 Openpilot
- **JLL** - 提供詳細的安裝文件和工具包
- **Openpilot 社群** - 持續的開發與支援

---

## 版本記錄

| 版本 | 日期 | 說明 |
|------|------|------|
| 1.0 | 2025-09-26 | 初次安裝記錄 |
| 2.0 | 2025-10-08 | USA Demo 成功運行 |
| 3.0 | 2025-10-09 | Taiwan Demo 成功運行 |
| 3.1 | 2025-10-09 | 完整報告整合 |

---

**報告完成日期：** 2025年10月9日
**總建置時間：** 約 14 天（實際工作時間約 4 小時）
**解決問題總數：** 7 個主要問題
**最終狀態：** ✅ 專案完全成功，兩個 Demo 都可正常運行

---

*此報告詳細記錄了 Openpilot v0.9.1 研究環境的完整建置過程，包含從初次安裝到成功運行兩個 Demo 的所有步驟、遇到的問題、除錯方法、解決方案，以及後續研究建議。可作為類似專案的完整參考文件。*
