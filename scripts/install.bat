@echo off
REM Video Summarizer Evaluation - Windows Installation Script

echo 🚀 Video Summarizer Evaluation - Installation Script (Windows)
echo ==============================================================

REM Check if Node.js is installed
node --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Node.js is not installed. Please install Node.js 18+ from https://nodejs.org/
    pause
    exit /b 1
)

echo ✅ Node.js found: 
node --version

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python is not installed. Please install Python 3.11+ from https://python.org/
    pause
    exit /b 1
)

echo ✅ Python found:
python --version

REM Check if pip is installed
pip --version >nul 2>&1
if errorlevel 1 (
    echo ❌ pip is not installed. Please install pip.
    pause
    exit /b 1
)

echo ✅ pip found:
pip --version

echo.
echo 📦 Installing dependencies...
echo ============================

REM Create directories
echo 📁 Creating project directories...
if not exist "logs" mkdir logs
if not exist "backend\python-ai\temp" mkdir backend\python-ai\temp
if not exist "backend\node-api\uploads\videos" mkdir backend\node-api\uploads\videos
if not exist "backend\node-api\uploads\thumbnails" mkdir backend\node-api\uploads\thumbnails

REM Install Python AI Service dependencies
echo.
echo 🐍 Setting up Python AI Service...
cd backend\python-ai

REM Create virtual environment
echo Creating Python virtual environment...
python -m venv venv

REM Activate virtual environment
echo Activating virtual environment...
call venv\Scripts\activate.bat

REM Upgrade pip
echo Upgrading pip...
python -m pip install --upgrade pip

REM Install PyTorch (CPU version for compatibility)
echo Installing PyTorch...
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

REM Install other dependencies
echo Installing Python dependencies...
pip install -r requirements.txt

REM Create .env file if it doesn't exist
if not exist ".env" (
    echo Creating Python AI .env file...
    copy .env.example .env
    echo ✅ Created .env file. Please review and update as needed.
)

echo ✅ Python AI Service setup complete!

REM Go back to root directory
cd ..\..

REM Install Node.js API dependencies
echo.
echo 🔧 Setting up Node.js API...
cd backend\node-api

call npm install

REM Create .env file if it doesn't exist
if not exist ".env" (
    echo Creating Node.js API .env file...
    copy .env.example .env
    echo ✅ Created .env file. Please review and update as needed.
)

echo ✅ Node.js API setup complete!

REM Go back to root directory
cd ..\..

REM Install Frontend dependencies
echo.
echo 🌐 Setting up Frontend...
cd frontend

call npm install

REM Create .env file if it doesn't exist
if not exist ".env" (
    echo Creating Frontend .env file...
    echo REACT_APP_API_URL=http://localhost:5001/api > .env
    echo ✅ Created .env file for frontend.
)

echo ✅ Frontend setup complete!

REM Go back to root directory
cd ..

REM Install root dependencies
echo.
echo 📦 Installing root development dependencies...
call npm install

echo ✅ Root dependencies installed!

REM Create Windows batch scripts
echo.
echo 📝 Creating Windows batch scripts...

REM Create start.bat
echo @echo off > scripts\start.bat
echo echo 🚀 Starting Video Summarizer Evaluation System >> scripts\start.bat
echo echo ============================================== >> scripts\start.bat
echo echo. >> scripts\start.bat
echo echo Starting services... >> scripts\start.bat
echo echo Frontend: http://localhost:3000 >> scripts\start.bat
echo echo API: http://localhost:5001 >> scripts\start.bat
echo echo AI Service: http://localhost:5000 >> scripts\start.bat
echo echo. >> scripts\start.bat
echo echo Press Ctrl+C to stop all services >> scripts\start.bat
echo echo. >> scripts\start.bat
echo start "AI Service" cmd /k "cd backend\python-ai && venv\Scripts\activate && python app.py" >> scripts\start.bat
echo timeout /t 3 /nobreak ^>nul >> scripts\start.bat
echo start "API Service" cmd /k "cd backend\node-api && npm run dev" >> scripts\start.bat
echo timeout /t 3 /nobreak ^>nul >> scripts\start.bat
echo start "Frontend" cmd /k "cd frontend && npm start" >> scripts\start.bat
echo echo All services started! >> scripts\start.bat
echo pause >> scripts\start.bat

REM Create test.bat
echo @echo off > scripts\test.bat
echo echo 🧪 Running Tests >> scripts\test.bat
echo echo =============== >> scripts\test.bat
echo echo. >> scripts\test.bat
echo echo Testing Python AI Service... >> scripts\test.bat
echo cd backend\python-ai >> scripts\test.bat
echo call venv\Scripts\activate.bat >> scripts\test.bat
echo python test_api.py >> scripts\test.bat
echo cd ..\.. >> scripts\test.bat
echo echo. >> scripts\test.bat
echo echo Testing Node.js API... >> scripts\test.bat
echo cd backend\node-api >> scripts\test.bat
echo call npm test >> scripts\test.bat
echo cd ..\.. >> scripts\test.bat
echo echo. >> scripts\test.bat
echo echo Testing Frontend... >> scripts\test.bat
echo cd frontend >> scripts\test.bat
echo call npm test -- --watchAll=false >> scripts\test.bat
echo cd .. >> scripts\test.bat
echo echo. >> scripts\test.bat
echo echo ✅ All tests completed! >> scripts\test.bat
echo pause >> scripts\test.bat

echo ✅ Windows batch scripts created!

echo.
echo 🎉 Installation Complete!
echo ========================
echo.
echo 📋 Next Steps:
echo 1. Review and update .env files in:
echo    - backend\python-ai\.env
echo    - backend\node-api\.env
echo    - frontend\.env
echo.
echo 2. Start MongoDB (if using local installation):
echo    mongod --dbpath .\data\db
echo.
echo 3. Start all services:
echo    scripts\start.bat
echo.
echo 4. Run tests:
echo    scripts\test.bat
echo.
echo 🌐 Access Points:
echo    Frontend: http://localhost:3000
echo    API: http://localhost:5001
echo    AI Service: http://localhost:5000
echo.
echo ✅ Happy coding! 🚀
pause
