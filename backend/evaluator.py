# -*- coding: utf-8 -*-
"""
Video Understanding and Summary Evaluation Module

This module provides AI-powered evaluation of user video understanding
by comparing user summaries with reference content using semantic similarity.
"""

import logging
import numpy as np
from sentence_transformers import SentenceTransformer, util
from typing import Dict, List, Any, Tuple, Optional
import torch

logger = logging.getLogger(__name__)

class SummaryEvaluator:
    """
    AI-powered summary evaluation using sentence transformers for semantic similarity.
    """

    def __init__(self, model_name: str = 'all-MiniLM-L6-v2'):
        """
        Initialize the summary evaluator with a sentence transformer model.

        Args:
            model_name (str): Name of the sentence transformer model to use
        """
        try:
            self.model = SentenceTransformer(model_name)
            self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
            logger.info(f"SummaryEvaluator initialized with model: {model_name} on device: {self.device}")
        except Exception as e:
            logger.error(f"Error initializing SummaryEvaluator: {str(e)}")
            raise

    def calculate_similarity_score(self, user_summary: str, reference_summary: str) -> float:
        """
        Calculate semantic similarity between user summary and reference summary.

        Args:
            user_summary (str): User's understanding/summary of the video
            reference_summary (str): Reference or ideal summary

        Returns:
            float: Similarity score between 0 and 1
        """
        try:
            # Encode both summaries
            embedding_reference = self.model.encode(reference_summary, convert_to_tensor=True)
            embedding_user = self.model.encode(user_summary, convert_to_tensor=True)

            # Calculate cosine similarity
            similarity_score = util.pytorch_cos_sim(embedding_user, embedding_reference).item()

            return float(similarity_score)

        except Exception as e:
            logger.error(f"Error calculating similarity score: {str(e)}")
            return 0.0

    def get_feedback_message(self, similarity_score: float) -> str:
        """
        Generate feedback message based on similarity score.

        Args:
            similarity_score (float): Similarity score between 0 and 1

        Returns:
            str: Feedback message for the user
        """
        if similarity_score < 0.3:
            return "❌ Your understanding seems quite different from the video content. Consider rewatching and focusing on the main concepts."
        elif similarity_score < 0.5:
            return "⚠️ You've captured some aspects, but there's room for improvement. Try to identify the key themes and main points."
        elif similarity_score < 0.65:
            return "👍 You're getting there! You've understood several important points. Focus on connecting the main ideas."
        elif similarity_score < 0.8:
            return "✅ Good job! You've understood most of the video content well. Minor details could be refined."
        else:
            return "🌟 Excellent! You have a comprehensive understanding of the video content."

    def get_performance_level(self, similarity_score: float) -> str:
        """
        Get performance level based on similarity score.

        Args:
            similarity_score (float): Similarity score between 0 and 1

        Returns:
            str: Performance level (Poor, Fair, Good, Excellent)
        """
        if similarity_score < 0.3:
            return "Poor"
        elif similarity_score < 0.5:
            return "Fair"
        elif similarity_score < 0.8:
            return "Good"
        else:
            return "Excellent"

    def evaluate_summary(self, user_summary: str, reference_summary: str) -> Dict[str, Any]:
        """
        Comprehensive evaluation of user summary against reference.

        Args:
            user_summary (str): User's understanding/summary
            reference_summary (str): Reference or ideal summary

        Returns:
            Dict[str, Any]: Comprehensive evaluation results
        """
        try:
            # Calculate similarity score
            similarity_score = self.calculate_similarity_score(user_summary, reference_summary)

            # Generate feedback and performance level
            feedback_message = self.get_feedback_message(similarity_score)
            performance_level = self.get_performance_level(similarity_score)

            # Calculate additional metrics
            word_count_user = len(user_summary.split())
            word_count_reference = len(reference_summary.split())
            length_ratio = word_count_user / word_count_reference if word_count_reference > 0 else 0

            # Determine if length is appropriate
            length_feedback = self._get_length_feedback(length_ratio)

            return {
                "similarity_score": round(similarity_score, 3),
                "performance_level": performance_level,
                "feedback_message": feedback_message,
                "length_analysis": {
                    "user_word_count": word_count_user,
                    "reference_word_count": word_count_reference,
                    "length_ratio": round(length_ratio, 2),
                    "length_feedback": length_feedback
                },
                "detailed_metrics": {
                    "semantic_similarity": round(similarity_score, 3),
                    "comprehensiveness_score": round(similarity_score * 100, 1),
                    "understanding_quality": performance_level
                },
                "recommendations": self._generate_recommendations(similarity_score, length_ratio)
            }

        except Exception as e:
            logger.error(f"Error in summary evaluation: {str(e)}")
            return {
                "error": str(e),
                "similarity_score": 0.0,
                "performance_level": "Error",
                "feedback_message": "An error occurred during evaluation."
            }

    def _get_length_feedback(self, length_ratio: float) -> str:
        """Generate feedback about summary length."""
        if length_ratio < 0.3:
            return "Your summary is quite brief. Consider adding more key details."
        elif length_ratio > 2.0:
            return "Your summary is quite detailed. Try to focus on the most important points."
        else:
            return "Your summary length is appropriate."

    def _generate_recommendations(self, similarity_score: float, length_ratio: float) -> List[str]:
        """Generate personalized recommendations based on evaluation."""
        recommendations = []

        if similarity_score < 0.5:
            recommendations.append("Focus on identifying the main topic and key concepts")
            recommendations.append("Pay attention to repeated themes or emphasized points")

        if similarity_score < 0.7:
            recommendations.append("Try to connect different parts of the video content")
            recommendations.append("Look for cause-and-effect relationships")

        if length_ratio < 0.3:
            recommendations.append("Include more specific details and examples")
        elif length_ratio > 2.0:
            recommendations.append("Focus on the most essential information")
            recommendations.append("Avoid including minor details")

        if similarity_score >= 0.8:
            recommendations.append("Excellent work! Continue practicing with more complex content")

        return recommendations

    def batch_evaluate(self, user_summaries: List[str], reference_summaries: List[str]) -> List[Dict[str, Any]]:
        """
        Evaluate multiple summaries in batch.

        Args:
            user_summaries (List[str]): List of user summaries
            reference_summaries (List[str]): List of reference summaries

        Returns:
            List[Dict[str, Any]]: List of evaluation results
        """
        if len(user_summaries) != len(reference_summaries):
            raise ValueError("Number of user summaries must match number of reference summaries")

        results = []
        for user_summary, reference_summary in zip(user_summaries, reference_summaries):
            result = self.evaluate_summary(user_summary, reference_summary)
            results.append(result)

        return results
