# AI Video Summary Evaluation Service

This Python service provides AI-powered evaluation of video understanding using semantic similarity analysis. It uses the `SummaryEvaluator` class with sentence transformers to compare user summaries with reference content.

## 🚀 Features

- **Semantic Similarity Analysis**: Uses sentence transformers for accurate text comparison
- **Performance Level Assessment**: Categorizes understanding as Poor, Fair, Good, or Excellent
- **Detailed Feedback**: Provides personalized feedback messages and recommendations
- **Length Analysis**: Evaluates summary length appropriateness
- **Batch Processing**: Support for evaluating multiple summaries at once
- **RESTful API**: Flask-based API with multiple endpoints

## 📋 Requirements

- Python 3.11+
- PyTorch
- sentence-transformers
- Flask
- See `requirements.txt` for complete list

## 🛠️ Installation

1. **Create virtual environment**:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

2. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

3. **Set up environment variables**:
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

## 🚀 Usage

### Start the Service

```bash
python app.py
```

The service will start on `http://localhost:5000` by default.

### API Endpoints

#### 1. Health Check
```http
GET /health
```

**Response**:
```json
{
  "status": "healthy",
  "service": "AI Video Evaluator"
}
```

#### 2. Evaluate Summary
```http
POST /evaluate-summary
Content-Type: application/json

{
  "user_text": "Plants use sunlight to make food",
  "video_summary": "This video explains photosynthesis process"
}
```

**Response**:
```json
{
  "similarity_score": 0.756,
  "performance_level": "Good",
  "feedback_message": "✅ Good job! You've understood most of the video content well.",
  "length_analysis": {
    "user_word_count": 7,
    "reference_word_count": 8,
    "length_ratio": 0.88,
    "length_feedback": "Your summary length is appropriate."
  },
  "detailed_metrics": {
    "semantic_similarity": 0.756,
    "comprehensiveness_score": 75.6,
    "understanding_quality": "Good"
  },
  "recommendations": [
    "Try to connect different parts of the video content"
  ]
}
```

#### 3. Compare Texts
```http
POST /compare-texts
Content-Type: application/json

{
  "user_text": "Plants make food using sunlight",
  "reference_text": "Photosynthesis converts light energy to chemical energy"
}
```

#### 4. Get Similarity Score Only
```http
POST /similarity-score
Content-Type: application/json

{
  "user_text": "Water boils at 100 degrees",
  "reference_text": "Water reaches boiling point at 100°C"
}
```

**Response**:
```json
{
  "similarity_score": 0.892,
  "performance_level": "Excellent",
  "feedback_message": "🌟 Excellent! You have a comprehensive understanding."
}
```

#### 5. Batch Evaluation
```http
POST /batch-evaluate
Content-Type: application/json

{
  "user_summaries": [
    "Plants use sunlight for food",
    "Water boils at 100 degrees"
  ],
  "reference_summaries": [
    "Photosynthesis converts sunlight to energy",
    "Water boiling point is 100°C"
  ]
}
```

**Response**:
```json
{
  "batch_results": [
    {
      "similarity_score": 0.823,
      "performance_level": "Excellent",
      "feedback_message": "🌟 Excellent! You have a comprehensive understanding."
    },
    {
      "similarity_score": 0.945,
      "performance_level": "Excellent",
      "feedback_message": "🌟 Excellent! You have a comprehensive understanding."
    }
  ],
  "total_evaluations": 2,
  "average_score": 0.884
}
```

## 🧪 Testing

Run the test script to verify all endpoints:

```bash
python test_api.py
```

This will test all API endpoints and provide a summary of results.

## 📊 Performance Levels

The system categorizes understanding into four levels:

- **Poor** (< 0.3): Significant gaps in comprehension
- **Fair** (0.3 - 0.5): Some understanding but needs improvement
- **Good** (0.5 - 0.8): Good grasp of main concepts
- **Excellent** (≥ 0.8): Comprehensive understanding

## 🔧 Configuration

Environment variables in `.env`:

```env
DEBUG=False
PORT=5000
DEVICE=auto  # auto, cpu, cuda
LOG_LEVEL=INFO
```

## 🏗️ Architecture

### SummaryEvaluator Class

The core evaluation logic is in `summary_evaluation.py`:

- **Model**: Uses `all-MiniLM-L6-v2` sentence transformer
- **Similarity**: Cosine similarity between embeddings
- **Feedback**: Rule-based feedback generation
- **Recommendations**: Personalized improvement suggestions

### Flask Application

The `app.py` file provides:

- RESTful API endpoints
- Error handling and logging
- CORS support for web integration
- Input validation

## 🔗 Integration

This service integrates with the Node.js API through HTTP requests. The Node.js service:

1. Receives evaluation requests from the frontend
2. Calls this Python service via HTTP
3. Transforms responses to match database schema
4. Stores results in MongoDB

## 🚀 Deployment

### Docker

```bash
docker build -t ai-evaluator .
docker run -p 5000:5000 ai-evaluator
```

### Production

For production deployment:

1. Set `DEBUG=False` in environment
2. Use a production WSGI server like Gunicorn
3. Configure proper logging
4. Set up health monitoring

```bash
gunicorn --bind 0.0.0.0:5000 --workers 4 app:app
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📝 License

This project is licensed under the MIT License.
