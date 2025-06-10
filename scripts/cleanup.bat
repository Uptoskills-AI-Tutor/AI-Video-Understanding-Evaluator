@echo off
REM Video Summarizer Evaluation - Windows Cleanup Script

echo 🧹 Video Summarizer Evaluation - Cleanup Script (Windows)
echo ==========================================================

echo.
echo 🛑 Stopping all services...
echo ===========================

REM Kill Node.js processes
taskkill /F /IM node.exe 2>nul
echo ✅ Stopped Node.js processes

REM Kill Python processes
taskkill /F /IM python.exe 2>nul
echo ✅ Stopped Python processes

echo.
echo 🗂️  Cleanup Options:
echo ===================
echo 1. Light cleanup (node_modules, Python cache)
echo 2. Medium cleanup (+ Python virtual environment)
echo 3. Full cleanup (+ logs, uploads, all generated files)
echo 4. Nuclear cleanup (+ .env files, complete reset)
echo.

set /p cleanup_level="Select cleanup level (1-4): "

if "%cleanup_level%"=="1" goto light_cleanup
if "%cleanup_level%"=="2" goto medium_cleanup
if "%cleanup_level%"=="3" goto full_cleanup
if "%cleanup_level%"=="4" goto nuclear_cleanup

echo ❌ Invalid option selected
pause
exit /b 1

:light_cleanup
echo 📦 Performing light cleanup...
set CLEAN_NODE_MODULES=true
set CLEAN_PYTHON_CACHE=true
goto perform_cleanup

:medium_cleanup
echo 📦 Performing medium cleanup...
set CLEAN_NODE_MODULES=true
set CLEAN_PYTHON_CACHE=true
set CLEAN_VENV=true
goto perform_cleanup

:full_cleanup
echo 📦 Performing full cleanup...
set CLEAN_NODE_MODULES=true
set CLEAN_PYTHON_CACHE=true
set CLEAN_VENV=true
set CLEAN_LOGS=true
set CLEAN_UPLOADS=true
set CLEAN_BUILD=true
goto perform_cleanup

:nuclear_cleanup
echo 💥 Performing nuclear cleanup...
set CLEAN_NODE_MODULES=true
set CLEAN_PYTHON_CACHE=true
set CLEAN_VENV=true
set CLEAN_LOGS=true
set CLEAN_UPLOADS=true
set CLEAN_BUILD=true
set CLEAN_ENV=true
goto perform_cleanup

:perform_cleanup

REM Clean node_modules
if "%CLEAN_NODE_MODULES%"=="true" (
    echo.
    echo 📦 Removing node_modules directories...
    
    if exist "node_modules" (
        echo Removing root node_modules...
        rmdir /s /q node_modules
        echo ✅ Removed root node_modules
    )
    
    if exist "frontend\node_modules" (
        echo Removing frontend node_modules...
        rmdir /s /q frontend\node_modules
        echo ✅ Removed frontend\node_modules
    )
    
    if exist "backend\node-api\node_modules" (
        echo Removing backend API node_modules...
        rmdir /s /q backend\node-api\node_modules
        echo ✅ Removed backend\node-api\node_modules
    )
    
    REM Clean npm cache
    call npm cache clean --force 2>nul
    echo ✅ Cleaned npm cache
)

REM Clean Python cache
if "%CLEAN_PYTHON_CACHE%"=="true" (
    echo.
    echo 🐍 Removing Python cache files...
    
    REM Remove __pycache__ directories
    for /d /r . %%d in (__pycache__) do @if exist "%%d" rmdir /s /q "%%d"
    
    REM Remove .pyc files
    for /r . %%f in (*.pyc) do @if exist "%%f" del "%%f"
    
    REM Remove .pyo files
    for /r . %%f in (*.pyo) do @if exist "%%f" del "%%f"
    
    REM Remove .pytest_cache
    for /d /r . %%d in (.pytest_cache) do @if exist "%%d" rmdir /s /q "%%d"
    
    echo ✅ Removed Python cache files
)

REM Clean Python virtual environment
if "%CLEAN_VENV%"=="true" (
    echo.
    echo 🐍 Removing Python virtual environment...
    
    if exist "backend\python-ai\venv" (
        rmdir /s /q backend\python-ai\venv
        echo ✅ Removed Python virtual environment
    )
)

REM Clean logs
if "%CLEAN_LOGS%"=="true" (
    echo.
    echo 📝 Removing log files...
    
    if exist "logs" (
        del /q logs\*.*
        echo ✅ Removed log files
    )
)

REM Clean uploads
if "%CLEAN_UPLOADS%"=="true" (
    echo.
    echo 📁 Removing uploaded files...
    
    if exist "backend\node-api\uploads" (
        for /r backend\node-api\uploads %%f in (*.*) do del "%%f"
        echo ✅ Removed uploaded files
    )
    
    if exist "backend\python-ai\temp" (
        del /q backend\python-ai\temp\*.*
        echo ✅ Removed temporary files
    )
)

REM Clean build directories
if "%CLEAN_BUILD%"=="true" (
    echo.
    echo 🏗️ Removing build directories...
    
    if exist "frontend\build" (
        rmdir /s /q frontend\build
        echo ✅ Removed frontend\build
    )
    
    if exist "frontend\.next" (
        rmdir /s /q frontend\.next
        echo ✅ Removed frontend\.next
    )
    
    REM Remove dist directories
    for /d /r . %%d in (dist) do @if exist "%%d" rmdir /s /q "%%d"
)

REM Clean .env files
if "%CLEAN_ENV%"=="true" (
    echo.
    echo ⚠️ Removing .env files...
    
    set /p confirm="This will remove all .env configuration files. Continue? (y/N): "
    if /i "%confirm%"=="y" (
        for /r . %%f in (.env) do @if exist "%%f" if not "%%~nxf"==".env.example" del "%%f"
        echo ✅ Removed .env files
    ) else (
        echo ⏭️ Skipped .env file removal
    )
)

REM Additional cleanup
echo.
echo 🧹 Performing additional cleanup...

REM Remove package-lock.json files
set /p confirm="Remove package-lock.json files? (They will be regenerated on next install) (y/N): "
if /i "%confirm%"=="y" (
    for /r . %%f in (package-lock.json) do @if exist "%%f" del "%%f"
    echo ✅ Removed package-lock.json files
)

REM Remove Windows system files
for /r . %%f in (Thumbs.db) do @if exist "%%f" del "%%f"
for /r . %%f in (desktop.ini) do @if exist "%%f" del "%%f"
echo ✅ Removed Windows system files

REM Remove IDE files
set /p confirm="Remove IDE configuration files? (.vscode, .idea, etc.) (y/N): "
if /i "%confirm%"=="y" (
    if exist ".vscode" rmdir /s /q .vscode
    if exist ".idea" rmdir /s /q .idea
    for /r . %%f in (*.code-workspace) do @if exist "%%f" del "%%f"
    echo ✅ Removed IDE configuration files
)

echo.
echo 🎉 Cleanup Complete!
echo ===================
echo.
echo 📋 What was cleaned:
if "%CLEAN_NODE_MODULES%"=="true" echo    ✅ Node.js modules and npm cache
if "%CLEAN_PYTHON_CACHE%"=="true" echo    ✅ Python cache files
if "%CLEAN_VENV%"=="true" echo    ✅ Python virtual environment
if "%CLEAN_LOGS%"=="true" echo    ✅ Log files
if "%CLEAN_UPLOADS%"=="true" echo    ✅ Uploaded files and temp files
if "%CLEAN_BUILD%"=="true" echo    ✅ Build directories
if "%CLEAN_ENV%"=="true" echo    ✅ Environment configuration files
echo.
echo 🔄 To reinstall everything:
echo    scripts\install.bat
echo.
echo 🚀 To start fresh development:
echo    1. Run: scripts\install.bat
echo    2. Configure .env files
echo    3. Run: scripts\start.bat
echo.
echo ✅ System cleaned successfully! 🧹
pause
