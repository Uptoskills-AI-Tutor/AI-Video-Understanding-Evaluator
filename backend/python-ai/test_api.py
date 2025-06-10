#!/usr/bin/env python3
"""
Test script for the updated AI evaluation API
"""

import requests
import json
import sys

# API base URL
BASE_URL = "http://localhost:5000"

def test_health():
    """Test health endpoint"""
    print("Testing health endpoint...")
    try:
        response = requests.get(f"{BASE_URL}/health")
        print(f"Status: {response.status_code}")
        print(f"Response: {response.json()}")
        return response.status_code == 200
    except Exception as e:
        print(f"Error: {e}")
        return False

def test_evaluate_summary():
    """Test summary evaluation endpoint"""
    print("\nTesting evaluate-summary endpoint...")
    
    test_data = {
        "user_text": "The video explains how plants make their food using sunlight through photosynthesis.",
        "video_summary": "This educational video demonstrates the process of photosynthesis, showing how plants convert sunlight, water, and carbon dioxide into glucose and oxygen."
    }
    
    try:
        response = requests.post(
            f"{BASE_URL}/evaluate-summary",
            json=test_data,
            headers={"Content-Type": "application/json"}
        )
        print(f"Status: {response.status_code}")
        result = response.json()
        print(f"Response: {json.dumps(result, indent=2)}")
        return response.status_code == 200
    except Exception as e:
        print(f"Error: {e}")
        return False

def test_compare_texts():
    """Test text comparison endpoint"""
    print("\nTesting compare-texts endpoint...")
    
    test_data = {
        "user_text": "Plants use sunlight to make food",
        "reference_text": "Photosynthesis is the process by which plants convert light energy into chemical energy"
    }
    
    try:
        response = requests.post(
            f"{BASE_URL}/compare-texts",
            json=test_data,
            headers={"Content-Type": "application/json"}
        )
        print(f"Status: {response.status_code}")
        result = response.json()
        print(f"Response: {json.dumps(result, indent=2)}")
        return response.status_code == 200
    except Exception as e:
        print(f"Error: {e}")
        return False

def test_similarity_score():
    """Test similarity score endpoint"""
    print("\nTesting similarity-score endpoint...")
    
    test_data = {
        "user_text": "The video shows how to cook pasta",
        "reference_text": "This tutorial demonstrates pasta cooking techniques"
    }
    
    try:
        response = requests.post(
            f"{BASE_URL}/similarity-score",
            json=test_data,
            headers={"Content-Type": "application/json"}
        )
        print(f"Status: {response.status_code}")
        result = response.json()
        print(f"Response: {json.dumps(result, indent=2)}")
        return response.status_code == 200
    except Exception as e:
        print(f"Error: {e}")
        return False

def test_batch_evaluate():
    """Test batch evaluation endpoint"""
    print("\nTesting batch-evaluate endpoint...")
    
    test_data = {
        "user_summaries": [
            "Plants make food using sunlight",
            "Water boils at 100 degrees",
            "The Earth orbits the Sun"
        ],
        "reference_summaries": [
            "Photosynthesis allows plants to convert sunlight into energy",
            "Water reaches its boiling point at 100 degrees Celsius",
            "Earth completes one orbit around the Sun in 365 days"
        ]
    }
    
    try:
        response = requests.post(
            f"{BASE_URL}/batch-evaluate",
            json=test_data,
            headers={"Content-Type": "application/json"}
        )
        print(f"Status: {response.status_code}")
        result = response.json()
        print(f"Response: {json.dumps(result, indent=2)}")
        return response.status_code == 200
    except Exception as e:
        print(f"Error: {e}")
        return False

def main():
    """Run all tests"""
    print("🧪 Testing AI Evaluation API")
    print("=" * 50)
    
    tests = [
        ("Health Check", test_health),
        ("Evaluate Summary", test_evaluate_summary),
        ("Compare Texts", test_compare_texts),
        ("Similarity Score", test_similarity_score),
        ("Batch Evaluate", test_batch_evaluate)
    ]
    
    results = []
    for test_name, test_func in tests:
        print(f"\n🔍 {test_name}")
        print("-" * 30)
        success = test_func()
        results.append((test_name, success))
        print(f"✅ PASSED" if success else "❌ FAILED")
    
    print("\n" + "=" * 50)
    print("📊 Test Results Summary:")
    print("-" * 30)
    
    passed = 0
    for test_name, success in results:
        status = "✅ PASSED" if success else "❌ FAILED"
        print(f"{test_name}: {status}")
        if success:
            passed += 1
    
    print(f"\nTotal: {passed}/{len(results)} tests passed")
    
    if passed == len(results):
        print("🎉 All tests passed! API is working correctly.")
        sys.exit(0)
    else:
        print("⚠️  Some tests failed. Check the API service.")
        sys.exit(1)

if __name__ == "__main__":
    main()
