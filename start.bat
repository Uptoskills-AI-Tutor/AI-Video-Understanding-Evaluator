@echo off
echo 🎬 Video Summary Evaluator - Starting Services
echo ================================================

echo.
echo 📋 Starting Flask Backend (Port 5000)...
echo ----------------------------------------
start "Flask Backend" cmd /k "cd backend && python flask_cors_server.py"

echo.
echo ⏳ Waiting 3 seconds for backend to start...
timeout /t 3 /nobreak >nul

echo.
echo 📋 Starting React Frontend (Port 3000)...
echo -----------------------------------------
start "React Frontend" cmd /k "cd frontend && npm start"

echo.
echo ✅ Both services are starting!
echo.
echo 🌐 Access Points:
echo    Frontend: http://localhost:3000
echo    Backend:  http://localhost:5000
echo.
echo 📝 Instructions:
echo 1. Wait for both services to fully start
echo 2. Open http://localhost:3000 in your browser
echo 3. Select a video and start evaluating summaries!
echo.
echo Press any key to exit this window...
pause >nul
