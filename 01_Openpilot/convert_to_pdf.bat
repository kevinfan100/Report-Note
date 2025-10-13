@echo off
chcp 65001 >nul
echo ========================================
echo   Openpilot 報告 PDF 轉換工具
echo ========================================
echo.

REM 檢查 pandoc 是否安裝
where pandoc >nul 2>nul
if %errorlevel% neq 0 (
    echo [錯誤] 未安裝 Pandoc
    echo.
    echo 請先安裝 Pandoc：
    echo 1. 前往 https://pandoc.org/installing.html
    echo 2. 下載 Windows 安裝程式
    echo 3. 安裝後重新執行此腳本
    echo.
    pause
    exit /b 1
)

echo [✓] 已找到 Pandoc
pandoc --version | findstr /C:"pandoc"
echo.

REM 設定檔案路徑
set INPUT_FILE=AI_Project_One_Report.md
set OUTPUT_FILE=AI_Project_One_Report.pdf

REM 檢查輸入檔案是否存在
if not exist "%INPUT_FILE%" (
    echo [錯誤] 找不到輸入檔案: %INPUT_FILE%
    pause
    exit /b 1
)

echo [→] 開始轉換...
echo     輸入: %INPUT_FILE%
echo     輸出: %OUTPUT_FILE%
echo.

REM 執行轉換（使用 xelatex 引擎支援中文）
pandoc "%INPUT_FILE%" -o "%OUTPUT_FILE%" ^
    --pdf-engine=xelatex ^
    -V CJKmainfont="Microsoft YaHei" ^
    -V geometry:margin=2.5cm ^
    -V fontsize=12pt ^
    --toc ^
    --toc-depth=3 ^
    --number-sections ^
    -V linkcolor=blue ^
    -V urlcolor=blue

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo [✓] 轉換成功！
    echo ========================================
    echo.
    echo PDF 檔案已生成: %OUTPUT_FILE%
    echo.

    REM 詢問是否開啟檔案
    set /p OPEN="是否開啟 PDF 檔案？(Y/N): "
    if /i "%OPEN%"=="Y" (
        start "" "%OUTPUT_FILE%"
    )
) else (
    echo.
    echo ========================================
    echo [✗] 轉換失敗
    echo ========================================
    echo.
    echo 可能的原因：
    echo 1. 未安裝 TeX Live / MiKTeX
    echo 2. 缺少中文字型
    echo.
    echo 解決方案：
    echo 1. 安裝 MiKTeX: https://miktex.org/download
    echo 2. 或使用線上轉換工具（詳見下方說明）
    echo.
)

echo.
pause
