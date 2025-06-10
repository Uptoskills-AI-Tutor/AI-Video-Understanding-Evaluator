import React from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { 
  Play, 
  BarChart3, 
  Upload, 
  Brain, 
  CheckCircle, 
  ArrowRight,
  Star,
  Users,
  Video
} from 'lucide-react';

const Home = () => {
  const { isAuthenticated } = useAuth();

  const features = [
    {
      icon: Brain,
      title: 'AI-Powered Analysis',
      description: 'Advanced AI models analyze video content and compare it with your understanding.',
    },
    {
      icon: BarChart3,
      title: 'Detailed Evaluation',
      description: 'Get comprehensive metrics including ROUGE scores, semantic similarity, and more.',
    },
    {
      icon: Video,
      title: 'Multi-Modal Processing',
      description: 'Analyze both visual content and audio transcription for complete understanding.',
    },
    {
      icon: CheckCircle,
      title: 'Instant Feedback',
      description: 'Receive immediate feedback and recommendations to improve your comprehension.',
    },
  ];

  const stats = [
    { label: 'Videos Analyzed', value: '10,000+' },
    { label: 'Evaluations Completed', value: '50,000+' },
    { label: 'Active Users', value: '2,500+' },
    { label: 'Accuracy Rate', value: '95%' },
  ];

  const testimonials = [
    {
      name: 'Sarah Johnson',
      role: 'Student',
      content: 'This platform has revolutionized how I study video content. The AI feedback is incredibly accurate.',
      rating: 5,
    },
    {
      name: 'Dr. Michael Chen',
      role: 'Educator',
      content: 'Perfect tool for assessing student comprehension of video materials. Saves me hours of manual evaluation.',
      rating: 5,
    },
    {
      name: 'Emily Rodriguez',
      role: 'Researcher',
      content: 'The detailed metrics help me understand exactly where my video understanding can be improved.',
      rating: 5,
    },
  ];

  return (
    <div className="min-h-screen">
      {/* Hero Section */}
      <section className="relative bg-gradient-to-br from-primary-600 via-primary-700 to-primary-800 text-white">
        <div className="absolute inset-0 bg-black opacity-10"></div>
        <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-24">
          <div className="text-center">
            <h1 className="text-4xl md:text-6xl font-bold mb-6 leading-tight">
              Evaluate Your Video
              <span className="block text-primary-200">Understanding with AI</span>
            </h1>
            <p className="text-xl md:text-2xl mb-8 text-primary-100 max-w-3xl mx-auto">
              Upload videos, share your understanding, and get detailed AI-powered evaluations 
              to improve your comprehension skills.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              {isAuthenticated ? (
                <>
                  <Link
                    to="/upload"
                    className="btn-lg bg-white text-primary-600 hover:bg-gray-50 font-semibold"
                  >
                    <Upload className="w-5 h-5 mr-2" />
                    Upload Video
                  </Link>
                  <Link
                    to="/dashboard"
                    className="btn-lg border-2 border-white text-white hover:bg-white hover:text-primary-600 font-semibold"
                  >
                    <BarChart3 className="w-5 h-5 mr-2" />
                    View Dashboard
                  </Link>
                </>
              ) : (
                <>
                  <Link
                    to="/register"
                    className="btn-lg bg-white text-primary-600 hover:bg-gray-50 font-semibold"
                  >
                    Get Started Free
                    <ArrowRight className="w-5 h-5 ml-2" />
                  </Link>
                  <Link
                    to="/videos"
                    className="btn-lg border-2 border-white text-white hover:bg-white hover:text-primary-600 font-semibold"
                  >
                    <Play className="w-5 h-5 mr-2" />
                    Explore Videos
                  </Link>
                </>
              )}
            </div>
          </div>
        </div>
      </section>

      {/* Stats Section */}
      <section className="py-16 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-8">
            {stats.map((stat, index) => (
              <div key={index} className="text-center">
                <div className="text-3xl md:text-4xl font-bold text-primary-600 mb-2">
                  {stat.value}
                </div>
                <div className="text-gray-600 font-medium">
                  {stat.label}
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-20 bg-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-3xl md:text-4xl font-bold text-gray-900 mb-4">
              Powerful Features for Video Understanding
            </h2>
            <p className="text-xl text-gray-600 max-w-3xl mx-auto">
              Our AI-powered platform provides comprehensive tools to evaluate and improve 
              your video comprehension skills.
            </p>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
            {features.map((feature, index) => {
              const Icon = feature.icon;
              return (
                <div
                  key={index}
                  className="bg-white p-6 rounded-xl shadow-sm border border-gray-200 hover:shadow-md transition-shadow duration-200"
                >
                  <div className="w-12 h-12 bg-primary-100 rounded-lg flex items-center justify-center mb-4">
                    <Icon className="w-6 h-6 text-primary-600" />
                  </div>
                  <h3 className="text-lg font-semibold text-gray-900 mb-2">
                    {feature.title}
                  </h3>
                  <p className="text-gray-600">
                    {feature.description}
                  </p>
                </div>
              );
            })}
          </div>
        </div>
      </section>

      {/* How It Works Section */}
      <section className="py-20 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-3xl md:text-4xl font-bold text-gray-900 mb-4">
              How It Works
            </h2>
            <p className="text-xl text-gray-600 max-w-3xl mx-auto">
              Simple steps to evaluate your video understanding
            </p>
          </div>

          <div className="grid md:grid-cols-3 gap-8">
            <div className="text-center">
              <div className="w-16 h-16 bg-primary-600 rounded-full flex items-center justify-center mx-auto mb-4">
                <Upload className="w-8 h-8 text-white" />
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-2">
                1. Upload Video
              </h3>
              <p className="text-gray-600">
                Upload your video content and provide a summary of what you understood.
              </p>
            </div>

            <div className="text-center">
              <div className="w-16 h-16 bg-primary-600 rounded-full flex items-center justify-center mx-auto mb-4">
                <Brain className="w-8 h-8 text-white" />
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-2">
                2. AI Analysis
              </h3>
              <p className="text-gray-600">
                Our AI analyzes the video content and compares it with your understanding.
              </p>
            </div>

            <div className="text-center">
              <div className="w-16 h-16 bg-primary-600 rounded-full flex items-center justify-center mx-auto mb-4">
                <BarChart3 className="w-8 h-8 text-white" />
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-2">
                3. Get Results
              </h3>
              <p className="text-gray-600">
                Receive detailed evaluation metrics and personalized recommendations.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Testimonials Section */}
      <section className="py-20 bg-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-3xl md:text-4xl font-bold text-gray-900 mb-4">
              What Our Users Say
            </h2>
            <p className="text-xl text-gray-600">
              Trusted by students, educators, and researchers worldwide
            </p>
          </div>

          <div className="grid md:grid-cols-3 gap-8">
            {testimonials.map((testimonial, index) => (
              <div
                key={index}
                className="bg-white p-6 rounded-xl shadow-sm border border-gray-200"
              >
                <div className="flex items-center mb-4">
                  {[...Array(testimonial.rating)].map((_, i) => (
                    <Star key={i} className="w-5 h-5 text-yellow-400 fill-current" />
                  ))}
                </div>
                <p className="text-gray-600 mb-4 italic">
                  "{testimonial.content}"
                </p>
                <div>
                  <div className="font-semibold text-gray-900">
                    {testimonial.name}
                  </div>
                  <div className="text-sm text-gray-500">
                    {testimonial.role}
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 bg-primary-600">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h2 className="text-3xl md:text-4xl font-bold text-white mb-4">
            Ready to Improve Your Video Understanding?
          </h2>
          <p className="text-xl text-primary-100 mb-8 max-w-2xl mx-auto">
            Join thousands of users who are already using AI to enhance their learning experience.
          </p>
          {!isAuthenticated && (
            <Link
              to="/register"
              className="btn-lg bg-white text-primary-600 hover:bg-gray-50 font-semibold"
            >
              Start Free Today
              <ArrowRight className="w-5 h-5 ml-2" />
            </Link>
          )}
        </div>
      </section>
    </div>
  );
};

export default Home;
