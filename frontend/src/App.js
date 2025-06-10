import { useState } from 'react';

function App() {
  // Initial video data - using the specified video with photosynthesis content
  const initialVideoData = {
    id: 1,
    title: "Photosynthesis Explained",
    youtube_id: "Y5dRycQMHk0",
    summary: "Photosynthesis is a vital biological process where plants, algae, and certain bacteria convert light energy, typically from the sun, into chemical energy stored in glucose molecules. This process occurs primarily in the chloroplasts of plant cells, specifically in structures called thylakoids. The process involves two main stages: the light-dependent reactions (photo reactions) and the light-independent reactions (Calvin cycle). During the light reactions, chlorophyll absorbs sunlight and splits water molecules, releasing oxygen as a byproduct and generating ATP and NADPH. In the Calvin cycle, carbon dioxide from the atmosphere is fixed into organic molecules using the energy from ATP and NADPH. The overall equation for photosynthesis is: 6CO2 + 6H2O + light energy → C6H12O6 + 6O2. This process is crucial for life on Earth as it produces oxygen for respiration and forms the base of most food chains by converting inorganic carbon into organic compounds that serve as food for other organisms.",
    category: "Biology"
  };

  const [videoData, setVideoData] = useState(initialVideoData);
  const [showSummary, setShowSummary] = useState(false);
  const [userSummary, setUserSummary] = useState('');
  const [result, setResult] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [isEditingSummary, setIsEditingSummary] = useState(false);

  // Function to reset summary to original
  const resetSummary = () => {
    setVideoData({...videoData, summary: initialVideoData.summary});
    setIsEditingSummary(false);
  };

  const evaluateSummary = async () => {
    if (!userSummary.trim()) {
      setError('Please write your summary first');
      return;
    }

    setLoading(true);
    setError(null);
    setResult(null);

    try {
      const response = await fetch('http://localhost:5000/api/evaluate', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          user_text: userSummary,
          video_id: videoData.id,
          reference_summary: videoData.summary
        })
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      setResult(data);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-100 py-8">
      <div className="max-w-6xl mx-auto px-4">
        <div className="bg-white rounded-lg shadow-lg p-8">
          <h1 className="text-3xl font-bold text-center mb-8 text-blue-600">
            🎬 Video Summary Evaluator
          </h1>
          <p className="text-center text-gray-600 mb-8">
            Watch the video about photosynthesis and test your understanding with AI-powered evaluation
          </p>

          <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
            {/* Video Section */}
            <div className="bg-gray-50 rounded-lg p-6">
              <h2 className="text-xl font-semibold mb-4">📺 {videoData.title}</h2>
              <p className="text-sm text-gray-600 mb-4">Category: {videoData.category}</p>

              <div className="mb-4">
                <iframe
                  width="100%"
                  height="315"
                  src={`https://www.youtube.com/embed/${videoData.youtube_id}`}
                  title={videoData.title}
                  style={{border: 0}}
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                  allowFullScreen
                  className="rounded-lg"
                ></iframe>
              </div>

              <div className="text-center mb-4">
                <button
                  onClick={() => setShowSummary(!showSummary)}
                  className="bg-green-600 text-white px-6 py-2 rounded-lg hover:bg-green-700 font-semibold"
                >
                  {showSummary ? 'Hide Summary' : 'Show Summary'}
                </button>
              </div>

              {showSummary && (
                <div className="bg-blue-50 p-4 rounded-lg">
                  <div className="flex justify-between items-center mb-2">
                    <h3 className="font-semibold text-blue-800">Reference Summary:</h3>
                    <div className="space-x-2">
                      <button
                        onClick={() => setIsEditingSummary(!isEditingSummary)}
                        className="text-sm bg-blue-600 text-white px-3 py-1 rounded hover:bg-blue-700"
                      >
                        {isEditingSummary ? 'Save' : 'Edit'}
                      </button>
                      {videoData.summary !== initialVideoData.summary && (
                        <button
                          onClick={resetSummary}
                          className="text-sm bg-gray-600 text-white px-3 py-1 rounded hover:bg-gray-700"
                        >
                          Reset
                        </button>
                      )}
                    </div>
                  </div>

                  {isEditingSummary ? (
                    <div>
                      <textarea
                        value={videoData.summary}
                        onChange={(e) => setVideoData({...videoData, summary: e.target.value})}
                        className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-700"
                        rows="8"
                        placeholder="Edit the reference summary..."
                      />
                      <p className="text-sm text-gray-600 mt-2">
                        💡 Tip: Modify the reference summary to test different evaluation criteria
                      </p>
                    </div>
                  ) : (
                    <p className="text-gray-700">{videoData.summary}</p>
                  )}
                </div>
              )}
            </div>

            {/* Evaluation Section */}
            <div className="bg-gray-50 rounded-lg p-6">
              <h2 className="text-xl font-semibold mb-4">📝 Write Your Summary</h2>
              <p className="text-sm text-gray-600 mb-4">
                Watch the photosynthesis video, click "Show Summary" to see the reference, then write your own understanding below.
              </p>

              <div className="mb-4">
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Your Summary:
                </label>
                <textarea
                  value={userSummary}
                  onChange={(e) => setUserSummary(e.target.value)}
                  placeholder="After watching the photosynthesis video, write your summary here. Try to capture key concepts like light-dependent reactions, Calvin cycle, chloroplasts, the role of chlorophyll, and why photosynthesis is important for life on Earth..."
                  className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  rows="8"
                />
              </div>

              <button
                onClick={evaluateSummary}
                disabled={loading || !userSummary.trim()}
                className="w-full bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700 disabled:opacity-50 font-semibold"
              >
                {loading ? 'Evaluating...' : 'Evaluate My Summary'}
              </button>
            </div>
          </div>

          {/* Results Section */}
          {result && (
            <div className="mt-8 bg-white border-2 border-blue-200 rounded-lg p-6">
              <h3 className="text-xl font-semibold mb-4 text-center">📊 AI Evaluation Results</h3>

              {/* Main Score Display */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
                <div className="text-center">
                  <div className="text-4xl font-bold text-blue-600 mb-2">
                    {result.score_percentage}%
                  </div>
                  <div className="text-sm text-gray-600">Similarity Score</div>
                </div>

                <div className="text-center">
                  <div className={`text-2xl font-semibold mb-2 ${
                    result.performance_level === 'Excellent' ? 'text-green-600' :
                    result.performance_level === 'Good' ? 'text-blue-600' :
                    result.performance_level === 'Fair' ? 'text-yellow-600' :
                    'text-red-600'
                  }`}>
                    {result.performance_level}
                  </div>
                  <div className="text-sm text-gray-600">Performance Level</div>
                </div>

                <div className="text-center">
                  <div className="text-lg font-medium text-gray-800 mb-2">
                    {result.length_analysis?.user_word_count || result.user_word_count} words
                  </div>
                  <div className="text-sm text-gray-600">Your Summary Length</div>
                </div>
              </div>

              {/* Feedback Message */}
              <div className="bg-blue-50 p-4 rounded-lg text-center mb-6">
                <p className="text-gray-800 font-medium">{result.feedback_message}</p>
              </div>

              {/* Length Analysis */}
              {result.length_analysis && (
                <div className="bg-yellow-50 p-4 rounded-lg mb-6">
                  <h4 className="font-semibold text-yellow-800 mb-2">📏 Length Analysis</h4>
                  <p className="text-yellow-700">{result.length_analysis.length_feedback}</p>
                  <div className="mt-2 text-sm text-yellow-600">
                    <span>Your words: {result.length_analysis.user_word_count} | </span>
                    <span>Reference words: {result.length_analysis.reference_word_count} | </span>
                    <span>Ratio: {result.length_analysis.length_ratio}</span>
                  </div>
                </div>
              )}

              {/* Detailed Metrics */}
              {result.detailed_metrics && (
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
                  <div className="bg-gray-50 p-3 rounded-lg text-center">
                    <div className="text-lg font-semibold text-gray-800">
                      {result.detailed_metrics.semantic_similarity}
                    </div>
                    <div className="text-sm text-gray-600">Semantic Similarity</div>
                  </div>
                  <div className="bg-gray-50 p-3 rounded-lg text-center">
                    <div className="text-lg font-semibold text-gray-800">
                      {result.detailed_metrics.comprehensiveness_score}%
                    </div>
                    <div className="text-sm text-gray-600">Comprehensiveness</div>
                  </div>
                  <div className="bg-gray-50 p-3 rounded-lg text-center">
                    <div className="text-lg font-semibold text-gray-800">
                      {result.detailed_metrics.understanding_quality}
                    </div>
                    <div className="text-sm text-gray-600">Understanding Quality</div>
                  </div>
                </div>
              )}

              {/* Recommendations */}
              {result.recommendations && result.recommendations.length > 0 && (
                <div className="bg-green-50 p-4 rounded-lg">
                  <h4 className="font-semibold text-green-800 mb-2">💡 Recommendations</h4>
                  <ul className="list-disc list-inside text-green-700 space-y-1">
                    {result.recommendations.map((rec, index) => (
                      <li key={index}>{rec}</li>
                    ))}
                  </ul>
                </div>
              )}
            </div>
          )}

          {/* Loading State */}
          {loading && (
            <div className="mt-8 text-center py-8">
              <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
              <p className="mt-2 text-gray-600">Evaluating your summary...</p>
            </div>
          )}

          {/* Error Display */}
          {error && (
            <div className="mt-8 p-4 bg-red-50 border border-red-200 rounded-lg">
              <p className="text-red-700">{error}</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default App;
