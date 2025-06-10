from flask import Flask, request, jsonify
from flask_cors import CORS
import os
from dotenv import load_dotenv
from summary_evaluation import SummaryEvaluator
import logging

# Load environment variables
load_dotenv()

# Initialize Flask app
app = Flask(__name__)
CORS(app)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize the summary evaluator
summary_evaluator = SummaryEvaluator()

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({"status": "healthy", "service": "AI Video Evaluator"})

@app.route('/process-video', methods=['POST'])
def process_video():
    """Process video and extract understanding - Simplified for summary evaluation"""
    try:
        if 'video' not in request.files:
            return jsonify({"error": "No video file provided"}), 400

        video_file = request.files['video']
        user_text = request.form.get('user_text', '')

        if not user_text:
            return jsonify({"error": "No user text provided"}), 400

        # For now, return basic video info since we're focusing on summary evaluation
        # In a full implementation, you would add video processing here
        video_understanding = {
            "filename": video_file.filename,
            "user_text": user_text,
            "status": "processed",
            "message": "Video received successfully. Use /evaluate-summary for evaluation."
        }

        return jsonify({
            "video_understanding": video_understanding,
            "user_text": user_text
        })

    except Exception as e:
        logger.error(f"Error processing video: {str(e)}")
        return jsonify({"error": str(e)}), 500

@app.route('/evaluate-summary', methods=['POST'])
def evaluate_summary():
    """Evaluate user text against video summary using SummaryEvaluator"""
    try:
        data = request.get_json()

        user_text = data.get('user_text')
        #video_summary = data.get('video_summary')
        video_summary = data.get('video_summary')
 
        video_understanding = data.get('video_understanding', {})

        if not user_text:
            return jsonify({"error": "Missing user_text"}), 400

        if not video_summary:
            return jsonify({"error": "Missing video_summary"}), 400

        # Use the new SummaryEvaluator to evaluate the user's summary
        evaluation_results = summary_evaluator.evaluate_summary(user_text, video_summary)

        # Add additional context from video understanding if available
        if video_understanding:
            evaluation_results['video_context'] = {
                'filename': video_understanding.get('filename', 'Unknown'),
                'processing_status': video_understanding.get('status', 'Unknown')
            }

        return jsonify(evaluation_results)

    except Exception as e:
        logger.error(f"Error evaluating summary: {str(e)}")
        return jsonify({"error": str(e)}), 500

@app.route('/compare-texts', methods=['POST'])
def compare_texts():
    """Compare user text with reference text using SummaryEvaluator"""
    try:
        data = request.get_json()

        user_text = data.get('user_text')
        reference_text = data.get('reference_text')
        video_understanding = data.get('video_understanding', {})

        if not user_text:
            return jsonify({"error": "Missing user_text"}), 400

        if not reference_text:
            return jsonify({"error": "Missing reference_text"}), 400

        # Use SummaryEvaluator to compare texts
        comparison_results = summary_evaluator.evaluate_summary(user_text, reference_text)

        # Add context information
        comparison_results['comparison_type'] = 'text_comparison'
        if video_understanding:
            comparison_results['video_context'] = video_understanding

        return jsonify(comparison_results)

    except Exception as e:
        logger.error(f"Error comparing texts: {str(e)}")
        return jsonify({"error": str(e)}), 500

@app.route('/batch-evaluate', methods=['POST'])
def batch_evaluate():
    """Evaluate multiple user summaries against reference summaries"""
    try:
        data = request.get_json()

        user_summaries = data.get('user_summaries', [])
        reference_summaries = data.get('reference_summaries', [])

        if not user_summaries or not reference_summaries:
            return jsonify({"error": "Missing user_summaries or reference_summaries"}), 400

        if len(user_summaries) != len(reference_summaries):
            return jsonify({"error": "Number of user summaries must match reference summaries"}), 400

        # Use batch evaluation
        batch_results = summary_evaluator.batch_evaluate(user_summaries, reference_summaries)

        return jsonify({
            "batch_results": batch_results,
            "total_evaluations": len(batch_results),
            "average_score": sum(result.get('similarity_score', 0) for result in batch_results) / len(batch_results) if batch_results else 0
        })

    except Exception as e:
        logger.error(f"Error in batch evaluation: {str(e)}")
        return jsonify({"error": str(e)}), 500

@app.route('/similarity-score', methods=['POST'])
def get_similarity_score():
    """Get just the similarity score between two texts"""
    try:
        data = request.get_json()

        user_text = data.get('user_text')
        reference_text = data.get('reference_text')

        if not user_text or not reference_text:
            return jsonify({"error": "Missing user_text or reference_text"}), 400

        # Calculate similarity score only
        similarity_score = summary_evaluator.calculate_similarity_score(user_text, reference_text)
        feedback_message = summary_evaluator.get_feedback_message(similarity_score)
        performance_level = summary_evaluator.get_performance_level(similarity_score)

        return jsonify({
            "similarity_score": round(similarity_score, 3),
            "performance_level": performance_level,
            "feedback_message": feedback_message
        })

    except Exception as e:
        logger.error(f"Error calculating similarity score: {str(e)}")
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    debug = os.getenv('DEBUG', 'False').lower() == 'true'
    app.run(host='0.0.0.0', port=port, debug=debug)
