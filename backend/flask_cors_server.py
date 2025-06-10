#!/usr/bin/env python3
"""
Video Summary Evaluator - Flask Backend with Manual CORS Headers
Clean, simple Flask server for video summary evaluation
"""

from flask import Flask, request, jsonify
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(message)s')
logger = logging.getLogger(__name__)

app = Flask(__name__)

# Manual CORS headers - This is the key to solving CORS issues
@app.after_request
def add_cors_headers(response):
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization'
    response.headers['Access-Control-Max-Age'] = '86400'
    return response

# Handle preflight OPTIONS requests
@app.before_request
def handle_preflight():
    if request.method == "OPTIONS":
        response = jsonify({'status': 'ok'})
        response.status_code = 200
        return response

# Video data
VIDEO = {
    "id": 1,
    "title": "Photosynthesis Explained",
    "youtube_id": "Y5dRycQMHk0",
    "summary": "Photosynthesis is a vital biological process where plants, algae, and certain bacteria convert light energy, typically from the sun, into chemical energy stored in glucose molecules. This process occurs primarily in the chloroplasts of plant cells, specifically in structures called thylakoids. The process involves two main stages: the light-dependent reactions (photo reactions) and the light-independent reactions (Calvin cycle). During the light reactions, chlorophyll absorbs sunlight and splits water molecules, releasing oxygen as a byproduct and generating ATP and NADPH. In the Calvin cycle, carbon dioxide from the atmosphere is fixed into organic molecules using the energy from ATP and NADPH. The overall equation for photosynthesis is: 6CO2 + 6H2O + light energy → C6H12O6 + 6O2. This process is crucial for life on Earth as it produces oxygen for respiration and forms the base of most food chains by converting inorganic carbon into organic compounds that serve as food for other organisms.",
    "category": "Biology"
}

def simple_evaluate(user_text, reference_text):
    """Simple word-based similarity evaluation"""
    # Filter out short words and common words
    stop_words = {'the', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for', 'of', 'with', 'by', 'is', 'are', 'was', 'were', 'be', 'been', 'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would', 'could', 'should', 'may', 'might', 'can', 'this', 'that', 'these', 'those', 'a', 'an'}
    
    user_words = set(word.lower() for word in user_text.split() if len(word) > 2 and word.lower() not in stop_words)
    ref_words = set(word.lower() for word in reference_text.split() if len(word) > 2 and word.lower() not in stop_words)
    
    if not user_words or not ref_words:
        return 0.0
    
    intersection = user_words.intersection(ref_words)
    union = user_words.union(ref_words)
    
    similarity = len(intersection) / len(union) if union else 0.0
    return similarity

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    logger.info("Health check requested")
    return jsonify({
        "status": "healthy",
        "service": "Video Summary Evaluator",
        "cors": "manual_headers_enabled",
        "flask": "working"
    })

@app.route('/api/videos', methods=['GET'])
def get_videos():
    """Get all videos"""
    logger.info("Videos requested")
    return jsonify([VIDEO])

@app.route('/api/videos/<int:video_id>', methods=['GET'])
def get_video(video_id):
    """Get specific video"""
    logger.info(f"Video {video_id} requested")
    
    if video_id == 1:
        return jsonify(VIDEO)
    else:
        return jsonify({"error": "Video not found"}), 404

@app.route('/api/evaluate', methods=['POST'])
def evaluate_summary():
    """Evaluate user summary against video summary"""
    logger.info("Evaluation requested")
    
    try:
        # Get JSON data
        data = request.get_json()
        if not data:
            logger.error("No JSON data provided")
            return jsonify({"error": "No JSON data provided"}), 400
        
        user_text = data.get('user_text', '').strip()
        video_id = data.get('video_id')
        reference_summary = data.get('reference_summary', '').strip()

        logger.info(f"Evaluating text: '{user_text[:50]}...' for video {video_id}")

        # Validation
        if not user_text:
            return jsonify({"error": "User text is required"}), 400

        if not video_id:
            return jsonify({"error": "Video ID is required"}), 400

        # Use custom reference summary if provided, otherwise use default
        if reference_summary:
            reference_text = reference_summary
            logger.info("Using custom reference summary")
        else:
            if video_id != 1:
                return jsonify({"error": "Video not found"}), 404
            reference_text = VIDEO['summary']
            logger.info("Using default reference summary")

        # Evaluate similarity
        similarity_score = simple_evaluate(user_text, reference_text)
        
        # Determine performance level and feedback
        if similarity_score >= 0.6:
            performance_level = "Excellent"
            feedback = "🌟 Excellent! Your summary captures the key concepts very well."
        elif similarity_score >= 0.4:
            performance_level = "Good"
            feedback = "👍 Good work! Your summary covers most important points."
        elif similarity_score >= 0.2:
            performance_level = "Fair"
            feedback = "📝 Fair attempt. Try to include more key concepts."
        else:
            performance_level = "Poor"
            feedback = "📚 Your summary needs improvement. Focus on main ideas."
        
        # Calculate metrics
        user_word_count = len(user_text.split())
        ref_word_count = len(reference_text.split())
        length_ratio = user_word_count / ref_word_count if ref_word_count > 0 else 0
        
        # Build response
        evaluation_result = {
            "similarity_score": round(similarity_score, 3),
            "performance_level": performance_level,
            "feedback_message": feedback,
            "score_percentage": round(similarity_score * 100, 1),
            "video_title": VIDEO['title'],
            "video_category": VIDEO['category'],
            "length_analysis": {
                "user_word_count": user_word_count,
                "reference_word_count": ref_word_count,
                "length_ratio": round(length_ratio, 2),
                "length_feedback": (
                    "Your summary length is appropriate." if 0.3 <= length_ratio <= 2.0 else 
                    "Your summary is quite brief. Consider adding more details." if length_ratio < 0.3 else
                    "Your summary is quite detailed. Try to focus on key points."
                )
            },
            "detailed_metrics": {
                "semantic_similarity": round(similarity_score, 3),
                "comprehensiveness_score": round(similarity_score * 100, 1),
                "understanding_quality": performance_level
            },
            "recommendations": (
                [
                    "Focus on key photosynthesis concepts like light reactions and Calvin cycle",
                    "Include important terms like chloroplasts, ATP, and NADPH",
                    "Explain the overall importance of photosynthesis for life on Earth"
                ] if similarity_score < 0.6 else [
                    "Excellent work! You have a strong understanding of photosynthesis"
                ]
            )
        }
        
        logger.info(f"Evaluation complete: {similarity_score:.3f} ({performance_level})")
        return jsonify(evaluation_result)
        
    except Exception as e:
        logger.error(f"Error in evaluation: {str(e)}")
        return jsonify({"error": f"Internal server error: {str(e)}"}), 500

@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors"""
    return jsonify({"error": "Endpoint not found"}), 404

@app.errorhandler(500)
def internal_error(error):
    """Handle 500 errors"""
    return jsonify({"error": "Internal server error"}), 500

if __name__ == '__main__':
    print("🎬 Video Summary Evaluator - Flask with Manual CORS")
    print("=" * 60)
    print("🚀 Starting Flask server on http://localhost:5000")
    print("🌐 Manual CORS headers enabled for all origins")
    print("📝 API endpoint: http://localhost:5000/api/evaluate")
    print("💚 Health check: http://localhost:5000/health")
    print("=" * 60)
    print("Server ready! No CORS issues expected.")
    
    # Run Flask development server
    app.run(
        host='0.0.0.0',
        port=5000,
        debug=True,
        threaded=True
    )
