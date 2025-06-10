# 🎬 Video Summary Evaluator

A clean and simple Flask + React application for evaluating video summaries with manual CORS handling.

## 🏗️ Architecture

- **Backend**: Flask (Python) with manual CORS headers for reliable cross-origin requests
- **Frontend**: React with embedded YouTube player and detailed results display
- **Evaluation**: Word-based similarity scoring with intelligent filtering
- **Features**: YouTube video integration, AI-powered evaluation, detailed feedback, no authentication required

## 🚀 Quick Start

### 1. Backend Setup (Flask)

```bash
# Navigate to backend directory
cd backend

# Install Flask
pip install Flask

# Start Flask server
python flask_cors_server.py
```

The Flask backend will run on **http://localhost:5000**

### 2. Frontend Setup (React)

```bash
# Navigate to frontend directory
cd frontend

# Install dependencies (if not already installed)
npm install

# Start React development server
npm start
```

The React frontend will run on **http://localhost:3000**

## 📋 How to Use

1. **Open your browser** to http://localhost:3000
2. **Watch the embedded YouTube video** about photosynthesis (ID: Y5dRycQMHk0)
3. **Click "Show Summary"** to reveal the comprehensive reference summary
4. **Write your own summary** covering key concepts like light reactions, Calvin cycle, and chloroplasts
5. **Click "Evaluate My Summary"** to get comprehensive AI-powered feedback
6. **View detailed results** including similarity scores, performance analysis, and personalized recommendations

## 🎯 Advanced Features

### Backend (Flask + AI)
- **Advanced AI Model**: sentence-transformers with all-MiniLM-L6-v2
- **Semantic Similarity**: Deep understanding beyond keyword matching
- **Comprehensive Analysis**: Length analysis, performance levels, detailed metrics
- **Personalized Feedback**: Context-aware recommendations
- **Modular Design**: Clean separation of evaluation logic

### Frontend (React)
- **Fixed Video Player**: Embedded YouTube video about photosynthesis
- **Show/Hide Summary**: Toggle button to reveal reference summary
- **Enhanced Results Display**: Multi-section results with visual indicators
- **Performance Color Coding**: Visual feedback based on performance level
- **Detailed Metrics**: Semantic similarity, comprehensiveness scores
- **Length Analysis**: Feedback on summary length and appropriateness
- **Recommendations**: Personalized suggestions for improvement

### AI Evaluation Engine
- **Sentence Transformers**: State-of-the-art semantic similarity
- **Performance Levels**: Poor, Fair, Good, Excellent with detailed thresholds
- **Length Analysis**: Optimal summary length evaluation
- **Contextual Feedback**: Specific recommendations based on performance
- **Batch Processing**: Support for multiple summary evaluations

## 🔗 API Endpoints

### Backend (Port 5000)
- `GET /health` - Health check
- `GET /api/videos` - Get all videos
- `GET /api/videos/<id>` - Get specific video
- `POST /api/evaluate` - Advanced AI evaluation

### Enhanced Evaluation Response
```json
{
  "similarity_score": 0.847,
  "performance_level": "Excellent",
  "feedback_message": "🌟 Excellent! You have a comprehensive understanding of the video content.",
  "length_analysis": {
    "user_word_count": 45,
    "reference_word_count": 52,
    "length_ratio": 0.87,
    "length_feedback": "Your summary length is appropriate."
  },
  "detailed_metrics": {
    "semantic_similarity": 0.847,
    "comprehensiveness_score": 84.7,
    "understanding_quality": "Excellent"
  },
  "recommendations": [
    "Excellent work! Continue practicing with more complex content"
  ],
  "score_percentage": 84.7,
  "video_title": "Photosynthesis Explained",
  "video_category": "Biology"
}
```

## 🛠️ Technology Stack

### Backend
- **Flask 2.3.2** - Web framework
- **Flask-CORS 4.0.0** - Cross-origin requests
- **sentence-transformers 2.2.2** - Advanced semantic similarity
- **torch** - Deep learning framework
- **NumPy 1.24.3** - Numerical computing

### Frontend
- **React 18.2.0** - UI framework
- **Create React App** - Build tooling
- **Custom CSS** - Enhanced styling with performance indicators

## 📁 Project Structure

```
video-summary-evaluator/
├── backend/
│   ├── flask_cors_server.py  # Flask application with manual CORS
│   ├── evaluator.py          # AI evaluation module 
│   └── requirements.txt      # Python dependencies
├── frontend/
│   ├── src/
│   │   ├── App.js           # React component
│   │   ├── index.js         # React entry point
│   │   └── index.css        # Styling
│   ├── public/
│   │   └── index.html       # HTML template
│   └── package.json         # Node dependencies
├── README.md                # This file
└── start.bat                # Windows startup script
```

## 🎥 Featured Video

**Photosynthesis Explained** (Biology)
- YouTube Video ID: Y5dRycQMHk0
- Comprehensive coverage of photosynthesis process
- Includes light-dependent reactions, Calvin cycle, and chloroplast function
- Explains the chemical equation: 6CO2 + 6H2O + light energy → C6H12O6 + 6O2
- Perfect for testing biological understanding and scientific summary writing
- AI-generated reference summary for accurate evaluation

## 🔧 Development

### Adding New Videos
Edit the `VIDEOS` array in `backend/app.py`:

```python
VIDEOS = [
    {
        "id": 4,
        "title": "Your Video Title",
        "youtube_id": "YouTube_Video_ID",
        "summary": "Detailed educational summary...",
        "category": "Your Category"
    }
]
```

### Customizing AI Evaluation
Modify the `SummaryEvaluator` class in `backend/evaluator.py`:
- Adjust similarity thresholds
- Customize feedback messages
- Add new performance metrics
- Modify recommendation logic

## 🎯 Perfect For

- **Educational Platforms**: Advanced comprehension testing
- **Training Applications**: Professional summary writing skills
- **Research Projects**: Semantic similarity studies
- **AI Development**: Evaluation system prototyping
- **Learning**: Understanding transformer models and semantic analysis

## ✨ What Makes It Advanced

- **Semantic Understanding**: Goes beyond keyword matching
- **Contextual Analysis**: Understands meaning and relationships
- **Comprehensive Feedback**: Multi-dimensional evaluation
- **Personalized Recommendations**: Tailored improvement suggestions
- **Professional UI**: Enhanced visual feedback and results display
- **Modular Architecture**: Clean, maintainable code structure

Start both servers and experience advanced AI-powered video summary evaluation! 🚀
