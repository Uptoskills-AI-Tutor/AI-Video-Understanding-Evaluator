import axios from 'axios';

// Base API configuration
const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:5001/api';

// Create axios instances
export const authAPI = axios.create({
  baseURL: API_BASE_URL,
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
  },
});

export const videoAPI = axios.create({
  baseURL: API_BASE_URL,
  timeout: 300000, // 5 minutes for video uploads
});

export const evaluationAPI = axios.create({
  baseURL: API_BASE_URL,
  timeout: 60000, // 1 minute for evaluations
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptors to add auth token
const addAuthToken = (config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
};

authAPI.interceptors.request.use(addAuthToken);
videoAPI.interceptors.request.use(addAuthToken);
evaluationAPI.interceptors.request.use(addAuthToken);

// Response interceptors for error handling
const handleResponseError = (error) => {
  if (error.response?.status === 401) {
    // Token expired or invalid
    localStorage.removeItem('token');
    window.location.href = '/login';
  }
  return Promise.reject(error);
};

authAPI.interceptors.response.use(
  (response) => response,
  handleResponseError
);

videoAPI.interceptors.response.use(
  (response) => response,
  handleResponseError
);

evaluationAPI.interceptors.response.use(
  (response) => response,
  handleResponseError
);

// Video API functions
export const videoService = {
  // Get all videos with pagination and filters
  getVideos: async (params = {}) => {
    const response = await videoAPI.get('/videos', { params });
    return response.data;
  },

  // Get single video by ID
  getVideo: async (id) => {
    const response = await videoAPI.get(`/videos/${id}`);
    return response.data;
  },

  // Upload new video
  uploadVideo: async (formData, onUploadProgress) => {
    const response = await videoAPI.post('/videos', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
      onUploadProgress,
    });
    return response.data;
  },

  // Update video
  updateVideo: async (id, data) => {
    const response = await videoAPI.put(`/videos/${id}`, data);
    return response.data;
  },

  // Delete video
  deleteVideo: async (id) => {
    const response = await videoAPI.delete(`/videos/${id}`);
    return response.data;
  },

  // Get AI processing status
  getAIStatus: async (id) => {
    const response = await videoAPI.get(`/videos/${id}/ai-status`);
    return response.data;
  },

  // Trigger AI reprocessing
  reprocessVideo: async (id) => {
    const response = await videoAPI.post(`/videos/${id}/reprocess`);
    return response.data;
  },
};

// Evaluation API functions
export const evaluationService = {
  // Get user's evaluations
  getEvaluations: async (params = {}) => {
    const response = await evaluationAPI.get('/evaluations', { params });
    return response.data;
  },

  // Get single evaluation
  getEvaluation: async (id) => {
    const response = await evaluationAPI.get(`/evaluations/${id}`);
    return response.data;
  },

  // Create new evaluation
  createEvaluation: async (data) => {
    const response = await evaluationAPI.post('/evaluations', data);
    return response.data;
  },

  // Update evaluation feedback
  updateFeedback: async (id, feedback) => {
    const response = await evaluationAPI.put(`/evaluations/${id}/feedback`, feedback);
    return response.data;
  },

  // Delete evaluation
  deleteEvaluation: async (id) => {
    const response = await evaluationAPI.delete(`/evaluations/${id}`);
    return response.data;
  },

  // Get evaluations for a specific video
  getVideoEvaluations: async (videoId, params = {}) => {
    const response = await evaluationAPI.get(`/evaluations/video/${videoId}`, { params });
    return response.data;
  },

  // Quick evaluation without saving to database
  quickEvaluate: async (userText, referenceText) => {
    const response = await evaluationAPI.post('/evaluations/quick-evaluate', {
      userText,
      referenceText
    });
    return response.data;
  },

  // Batch evaluate multiple summaries
  batchEvaluate: async (userSummaries, referenceSummaries) => {
    const response = await evaluationAPI.post('/evaluations/batch-evaluate', {
      userSummaries,
      referenceSummaries
    });
    return response.data;
  },

  // Get evaluation statistics for user
  getEvaluationStats: async () => {
    const response = await evaluationAPI.get('/evaluations/stats');
    return response.data;
  },
};

// User API functions
export const userService = {
  // Get user profile
  getProfile: async () => {
    const response = await authAPI.get('/users/profile');
    return response.data;
  },

  // Update user profile
  updateProfile: async (data) => {
    const response = await authAPI.put('/users/profile', data);
    return response.data;
  },

  // Change password
  changePassword: async (data) => {
    const response = await authAPI.put('/users/change-password', data);
    return response.data;
  },

  // Get user statistics
  getStats: async () => {
    const response = await authAPI.get('/users/stats');
    return response.data;
  },

  // Delete account
  deleteAccount: async (password) => {
    const response = await authAPI.delete('/users/account', {
      data: { password }
    });
    return response.data;
  },
};

// Utility functions
export const apiUtils = {
  // Build query string from params
  buildQueryString: (params) => {
    const searchParams = new URLSearchParams();
    Object.entries(params).forEach(([key, value]) => {
      if (value !== undefined && value !== null && value !== '') {
        searchParams.append(key, value);
      }
    });
    return searchParams.toString();
  },

  // Format file size
  formatFileSize: (bytes) => {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  },

  // Format duration
  formatDuration: (seconds) => {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const remainingSeconds = Math.floor(seconds % 60);

    if (hours > 0) {
      return `${hours}:${minutes.toString().padStart(2, '0')}:${remainingSeconds.toString().padStart(2, '0')}`;
    }
    return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`;
  },

  // Get video thumbnail URL
  getVideoThumbnail: (video) => {
    if (video.thumbnailUrl) {
      return `${process.env.REACT_APP_API_URL || 'http://localhost:5001'}${video.thumbnailUrl}`;
    }
    return '/placeholder-video.jpg';
  },

  // Get video URL
  getVideoUrl: (video) => {
    return `${process.env.REACT_APP_API_URL || 'http://localhost:5001'}${video.videoUrl}`;
  },
};

export default {
  authAPI,
  videoAPI,
  evaluationAPI,
  videoService,
  evaluationService,
  userService,
  apiUtils,
};
