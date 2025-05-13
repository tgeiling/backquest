require('dotenv').config();
const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const helmet = require('helmet');
const rateLimit = require("express-rate-limit");
const ffmpeg = require('fluent-ffmpeg');
const fs = require('fs');
const path = require('path');
const cron = require('node-cron');
const { v4: uuidv4 } = require('uuid');
const { google } = require('googleapis');
const { GoogleAuth } = require('google-auth-library');
const axios = require('axios');

// Create express app
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());
app.use(helmet());
app.use(cors());

// MongoDB connection
mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log('MongoDB connected'))
  .catch(err => console.log('MongoDB connection error:', err));

// JWT Secret
const JWT_SECRET = process.env.JWT_SECRET || 'backquest_secret';

// User Schema
const UserSchema = new mongoose.Schema({
  username: { type: String, unique: true, required: true },
  password: { type: String, required: true },
  
  // User Profile Data
  age: { type: Number, default: 0 },
  fitnessLevel: { type: Number, default: 0 },
  height: { type: Number, default: 0 }, // in cm
  weight: { type: Number, default: 0 }, // in kg
  gender: { type: String, default: "" },
  acceptedGdpr: { type: Boolean, default: false },
  isExplained: { type: Boolean, default: false },
  
  // Back Pain Management Data
  painAreas: { type: Map, of: Number, default: {} }, // Maps body area to pain level (1-10)
  lastExerciseDate: { type: Map, of: Date, default: {} }, // Last time exercise was performed
  exerciseCount: { type: Map, of: Number, default: {} }, // Number of times exercise performed
  consecutiveDays: { type: Number, default: 0 }, // Streak of days using the app
  weeklyGoalProgress: { type: Number, default: 0 },
  weeklyGoalTarget: { type: Number, default: 3 },
  
  // Video Preferences
  duration: { type: Number, default: null },
  focus: { type: Number, default: null },
  goal: { type: Number, default: null },
  intensity: { type: Number, default: null },
  
  createdAt: { type: Date, default: Date.now },

  subscription: {
    active: { type: Boolean, default: false },
    type: { type: String, enum: ['monthly', 'yearly', null], default: null },
    validUntil: { type: Date, default: null },
    receipt: { type: String, default: null },
    platform: { type: String, enum: ['ios', 'android', null], default: null },
    startedAt: { type: Date, default: null },
    lastValidated: { type: Date, default: null }
  },
  
  // Feedback data
  feedback: [{
    videoId: String,
    difficulty: Number,
    painAreas: [String]
  }]
});

// Create an index on validUntil for efficient queries
UserSchema.index({ 'subscription.validUntil': 1 });

// Add a method to check if subscription is active
UserSchema.methods.hasActiveSubscription = function() {
  if (!this.subscription || !this.subscription.active) {
    return false;
  }
  
  return this.subscription.validUntil > new Date();
};

// Add a static method to find users with expiring subscriptions
UserSchema.statics.findExpiringSubscriptions = function(daysToExpire = 3) {
  const now = new Date();
  const expiryDate = new Date(now);
  expiryDate.setDate(expiryDate.getDate() + daysToExpire);
  
  return this.find({
    'subscription.active': true,
    'subscription.validUntil': {
      $gt: now,
      $lt: expiryDate
    }
  });
};

// Create a task to check for expired subscriptions daily
cron.schedule('0 0 * * *', async () => {
  console.log('Running expired subscription check...');
  try {
    const now = new Date();
    
    // Find users with expired subscriptions
    const expiredUsers = await User.find({
      'subscription.active': true,
      'subscription.validUntil': { $lt: now }
    });
    
    console.log(`Found ${expiredUsers.length} users with expired subscriptions`);
    
    // Update them as inactive
    for (const user of expiredUsers) {
      user.subscription.active = false;
      await user.save();
      console.log(`Deactivated subscription for user: ${user.username}`);
      
      // Here you could also send notification emails about expiration
    }
  } catch (error) {
    console.error('Error checking expired subscriptions:', error);
  }
});

const User = mongoose.model('User', UserSchema);

// Video Model Schema
const VideoSchema = new mongoose.Schema({
  id: String,
  name: String,
  background: String,
  duration: Number,
  startPose: String,
  endPose: String,
  direction: String,
  focus: [String],
  goal: [String],
  difficulty: Number,
  caution: [String],
  workplaceRelevance: String,
  logic: [String],
});

const Video = mongoose.model('Video', VideoSchema);

// Storage for active video sessions
const videoSessions = {};





//
// payment area
//






const APPLE_SECRET = process.env.APPLE_SECRET;
// Constants for validation URLs
const APPLE_PRODUCTION_URL = 'https://buy.itunes.apple.com/verifyReceipt';
const APPLE_SANDBOX_URL = 'https://sandbox.itunes.apple.com/verifyReceipt';
const GOOGLE_API_URL = 'https://androidpublisher.googleapis.com/androidpublisher/v3/applications';

// Load Google service account credentials
let googleCredentials;
try {
  // Try to load credentials from file first
  const credentialsPath = path.join(__dirname, 'credentials', 'google-service-account.json');
  if (fs.existsSync(credentialsPath)) {
    googleCredentials = require(credentialsPath);
  } else {
    // Fall back to environment variable if file doesn't exist
    googleCredentials = JSON.parse(process.env.GOOGLE_SERVICE_ACCOUNT_CREDENTIALS || '{}');
  }
} catch (error) {
  console.error('Failed to load Google credentials:', error);
  googleCredentials = {};
}

// Validate receipt from app
app.post('/validate_receipt', authenticateToken, async (req, res) => {
  try {
    const { receipt, subscription_type, platform } = req.body;
    
    if (!receipt || !subscription_type || !platform) {
      return res.status(400).json({ message: 'Missing required data' });
    }
    
    let isValid = false;
    let validUntil = null;
    
    // Validate with the appropriate app store
    if (platform === 'ios') {
      const validationResult = await validateAppleReceipt(receipt);
      isValid = validationResult.isValid;
      validUntil = validationResult.validUntil;
    } else if (platform === 'android') {
      const validationResult = await validateGoogleReceipt(receipt, subscription_type);
      isValid = validationResult.isValid;
      validUntil = validationResult.validUntil;
    } else {
      return res.status(400).json({ message: 'Invalid platform' });
    }
    
    // If valid, update user subscription in database
    if (isValid && validUntil) {
      // Find the user
      const user = await User.findOne({ username: req.user.username });
      if (!user) {
        return res.status(404).json({ message: 'User not found' });
      }
      
      // Update user subscription status in database
      user.subscription = {
        active: true,
        type: subscription_type,
        validUntil: validUntil,
        receipt: receipt,
        platform: platform,
        lastValidated: new Date()
      };
      
      await user.save();
    }
    
    res.json({
      is_valid: isValid,
      valid_until: validUntil ? validUntil.toISOString() : null
    });
  } catch (error) {
    console.error('Receipt validation error:', error);
    res.status(500).json({ message: 'Server error during validation' });
  }
});

// Record subscription (when a user makes a new purchase)
app.post('/record_subscription', authenticateToken, async (req, res) => {
  try {
    const { subscription_id, receipt, subscription_type, started_at, platform } = req.body;
    
    // Find the user
    const user = await User.findOne({ username: req.user.username });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    // Calculate expiry date based on subscription type
    const startDate = new Date(started_at);
    let validUntil;
    
    if (subscription_type === 'yearly') {
      validUntil = new Date(startDate);
      validUntil.setFullYear(validUntil.getFullYear() + 1);
    } else {
      validUntil = new Date(startDate);
      validUntil.setMonth(validUntil.getMonth() + 1);
    }
    
    // Update user subscription in database
    user.subscription = {
      active: true,
      type: subscription_type,
      validUntil: validUntil,
      receipt: receipt,
      platform: platform,
      startedAt: startDate
    };
    
    await user.save();
    
    res.json({ 
      success: true, 
      valid_until: validUntil.toISOString() 
    });
  } catch (error) {
    console.error('Recording subscription error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get subscription status
app.get('/subscription_status', authenticateToken, async (req, res) => {
  try {
    // Find the user
    const user = await User.findOne({ username: req.user.username });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    // If user has no subscription data
    if (!user.subscription) {
      return res.json({
        is_paid: false
      });
    }
    
    // Check if subscription is still valid
    const now = new Date();
    const isValid = user.subscription.active && user.subscription.validUntil > now;
    
    res.json({
      is_paid: isValid,
      subscription_type: isValid ? user.subscription.type : null,
      started_at: isValid ? user.subscription.startedAt.toISOString() : null,
      valid_until: isValid ? user.subscription.validUntil.toISOString() : null,
      receipt: isValid ? user.subscription.receipt : null
    });
  } catch (error) {
    console.error('Checking subscription status error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Cancel subscription notification
app.post('/cancel_subscription', authenticateToken, async (req, res) => {
  try {
    // Find the user
    const user = await User.findOne({ username: req.user.username });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    // Update subscription status to cancelled
    if (user.subscription) {
      user.subscription.active = false;
    }
    
    await user.save();
    
    res.json({ success: true });
  } catch (error) {
    console.error('Cancel subscription error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Apple receipt validation function
async function validateAppleReceipt(receipt) {
  try {
    // Sandbox environment for testing, use 'buy.itunes.apple.com' for production
    const endpoint = 'sandbox.itunes.apple.com';
    const validationUrl = `https://${endpoint}/verifyReceipt`;
    
    const response = await axios.post(validationUrl, {
      'receipt-data': receipt,
      'password': APPLE_SECRET, // Your App-Specific Shared Secret
      'exclude-old-transactions': true
    });
    
    const data = response.data;
    
    // Status 0 means successful validation
    if (data.status === 0) {
      // Find the latest subscription receipt
      let latestExpiry = null;
      let productId = null;
      
      if (data.latest_receipt_info && data.latest_receipt_info.length > 0) {
        // Sort receipts by expiration date (descending)
        const sortedReceipts = data.latest_receipt_info.sort((a, b) => {
          return parseInt(b.expires_date_ms) - parseInt(a.expires_date_ms);
        });
        
        // Get the latest receipt
        const latestReceipt = sortedReceipts[0];
        
        // Convert expiration date from milliseconds to Date
        latestExpiry = new Date(parseInt(latestReceipt.expires_date_ms));
        productId = latestReceipt.product_id;
        
        // Check if subscription matches our products
        if (productId !== '0001' && productId !== '0002') {
          console.warn(`Unrecognized product ID: ${productId}`);
        }
      }
      
      // Check if subscription is still valid
      const isValid = latestExpiry && latestExpiry > new Date();
      
      return {
        isValid,
        validUntil: latestExpiry,
        productId
      };
    }
    
    console.warn(`Apple receipt validation failed with status: ${data.status}`);
    return {
      isValid: false,
      validUntil: null
    };
  } catch (error) {
    console.error('Apple receipt validation error:', error);
    return {
      isValid: false,
      validUntil: null
    };
  }
}

// Google receipt validation function
async function validateGoogleReceipt(receipt, subscription_type) {
  if (!Object.keys(googleCredentials).length) {
    console.error('Google API credentials are not configured');
    return { isValid: false, validUntil: null, error: 'Configuration error' };
  }

  try {
    // Parse receipt data to extract necessary information
    let receiptData;
    try {
      receiptData = JSON.parse(receipt);
    } catch (e) {
      console.error('Failed to parse receipt data:', e);
      return { isValid: false, validUntil: null, error: 'Invalid receipt format' };
    }

    const { packageName, productId, purchaseToken } = receiptData;
    
    if (!packageName || !productId || !purchaseToken) {
      console.error('Missing required fields in receipt data');
      return { isValid: false, validUntil: null, error: 'Incomplete receipt data' };
    }

    // Set up authentication
    const auth = new GoogleAuth({
      credentials: googleCredentials,
      scopes: ['https://www.googleapis.com/auth/androidpublisher']
    });
    
    const client = await auth.getClient();
    
    // This is a subscription validation
    const endpoint = `${GOOGLE_API_URL}/${packageName}/purchases/subscriptions/${productId}/tokens/${purchaseToken}`;
    
    // Make the validation request
    const response = await client.request({ url: endpoint });
    
    // Check if the subscription is valid
    const expiryTimeMillis = parseInt(response.data.expiryTimeMillis);
    const currentTimeMillis = Date.now();
    
    const isValid = expiryTimeMillis > currentTimeMillis && 
                   response.data.paymentState === 1; // 1 = Payment received
    
    // Calculate valid until date
    const validUntil = new Date(expiryTimeMillis);
    
    return {
      isValid,
      validUntil: isValid ? validUntil : null,
      productId: productId
    };
  } catch (error) {
    console.error('Error validating Google receipt:', error.message);
    return { 
      isValid: false, 
      validUntil: null, 
      error: `Validation request failed: ${error.message}`
    };
  }
}

//
// payment area
//






// Test route
app.get('/test', (req, res) => {
  res.status(200).json({ message: 'Test endpoint is working!' });
});

// Helper function to validate username
const badWords = ["admin", "moderator", "fuck", "shit", "bitch", "asshole"]; // Add more as needed

function validateUsername(username) {
  const regex = /^[a-zA-Z0-9_]+$/;
  let errors = [];

  if (!regex.test(username)) errors.push("Username can only contain letters, numbers, and underscores.");
  if (username.length < 3 || username.length > 16) errors.push("Username must be between 3 and 16 characters.");
  if (badWords.some(word => username.toLowerCase().includes(word))) errors.push("Username contains forbidden words.");

  return errors;
}

// Register route
app.post('/register', async (req, res) => {
  try {
    const { username, password } = req.body;

    // Validate username
    const errors = validateUsername(username);
    if (errors.length > 0) {
      return res.status(400).json({ message: "Invalid username", errors });
    }

    // Validate password length
    if (!password || password.length < 6) {
      return res.status(400).json({ 
        message: "Invalid password", 
        errors: ["Password must be at least 6 characters long."] 
      });
    }

    // Check if username already exists
    const existingUser = await User.findOne({ username });
    if (existingUser) {
      return res.status(400).json({ 
        message: "Username already exists", 
        errors: ["This username is already taken."] 
      });
    }

    // Hash the password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create new user with initialized values
    const user = new User({ 
      username, 
      password: hashedPassword,
      // Initialize with default values
      age: 0,
      fitnessLevel: 0,
      height: 0,
      weight: 0,
      gender: "",
      acceptedGdpr: false,
      isExplained: false,
      painAreas: {},
      lastExerciseDate: {},
      exerciseCount: {},
      consecutiveDays: 0,
      weeklyGoalProgress: 0,
      weeklyGoalTarget: 3,
    });
    
    await user.save();

    res.status(201).json({ message: "User registered successfully" });
  } catch (error) {
    console.error("Registration error:", error);
    res.status(500).json({ message: "Server error" });
  }
});

// Rate limiting for login attempts
const loginLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 5, // Max 5 login attempts per minute
  message: { message: "Too many login attempts. Please try again later." },
  standardHeaders: true,
  legacyHeaders: false,
});

// Login route
app.post('/login', loginLimiter, async (req, res) => {
  const { username, password } = req.body;
  console.log(`Login attempt for username: ${username}`);

  const user = await User.findOne({ username });

  if (!user) {
    console.log('User not found');
    return res.status(400).json({ message: 'User not found' });
  }

  const isMatch = await bcrypt.compare(password, user.password);
  console.log(`Password match: ${isMatch}`);

  if (!isMatch) {
    console.log('Invalid credentials');
    return res.status(400).json({ message: 'Invalid credentials' });
  }

  const token = jwt.sign({ id: user._id, username: user.username }, JWT_SECRET, { expiresIn: '12h' });
  console.log('Authentication successful, sending token');
  res.json({ token });
});

// Middleware to authenticate token
function authenticateToken(req, res, next) {
  const token = req.header('Authorization')?.split(' ')[1];
  if (!token) return res.status(401).json({ message: 'Access denied' });

  try {
    const verified = jwt.verify(token, JWT_SECRET);
    req.user = verified;
    next();
  } catch (err) {
    res.status(400).json({ message: 'Invalid token' });
  }
}

// Update profile route
app.post('/updateProfile', authenticateToken, async (req, res) => {
  try {
    // Use findOneAndUpdate which doesn't rely on document versioning
    const result = await User.findOneAndUpdate(
      { username: req.user.username },
      { $set: req.body },
      { new: true }  // Return the updated document
    );
    
    if (!result) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    res.status(200).json({ message: 'Profile updated successfully' });
  } catch (error) {
    console.error("Profile update error:", error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get profile route
app.get('/profile', authenticateToken, async (req, res) => {
  try {
    const user = await User.findOne({ username: req.user.username });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Convert Map types to plain objects for JSON response
    const transformMapToObject = (map) => {
      if (!map) return {};
      const obj = {};
      map.forEach((value, key) => {
        obj[key] = value;
      });
      return obj;
    };

    // Format dates in ISO string format
    const formatDates = (dateMap) => {
      if (!dateMap) return {};
      const obj = {};
      dateMap.forEach((value, key) => {
        obj[key] = value instanceof Date ? value.toISOString() : value;
      });
      return obj;
    };

    // Return the user's profile data
    res.status(200).json({
      username: user.username,
      age: user.age,
      fitnessLevel: user.fitnessLevel,
      height: user.height,
      weight: user.weight,
      gender: user.gender,
      acceptedGdpr: user.acceptedGdpr,
      isExplained: user.isExplained,
      painAreas: transformMapToObject(user.painAreas),
      lastExerciseDate: formatDates(user.lastExerciseDate),
      exerciseCount: transformMapToObject(user.exerciseCount),
      consecutiveDays: user.consecutiveDays,
      weeklyGoalProgress: user.weeklyGoalProgress,
      weeklyGoalTarget: user.weeklyGoalTarget,
      duration: user.duration,
      focus: user.focus,
      goal: user.goal,
      intensity: user.intensity,
      feedback: user.feedback || []
    });
  } catch (error) {
    console.error("Fetching profile error:", error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Guest token generation endpoint
app.post('/guest', (req, res) => {
  try {
    const guestToken = jwt.sign({ guest: true }, JWT_SECRET, { expiresIn: '7d' });
    res.json({ token: guestToken });
  } catch (error) {
    console.error('Error generating guest token:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Token validation endpoint
app.post('/validateToken', async (req, res) => {
  const { token } = req.body;
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    // Check if guest token
    if (decoded.guest) {
      return res.json({ isValid: true, isGuest: true });
    }
    
    const user = await User.findOne({ username: decoded.username });
    if (user) {
      res.json({ isValid: true, isGuest: false });
    } else {
      res.json({ isValid: false, reason: "No user found" });
    }
  } catch (error) {
    res.status(400).send({ isValid: false, reason: "Invalid token" });
  }
});

// Feedback submission endpoint
app.post('/feedback', authenticateToken, async (req, res) => {
  try {
    const user = await User.findOne({ username: req.user.username });
    if (!user) return res.status(404).send('User not found');

    const feedbackData = req.body.feedback;
    if (!feedbackData) {
      return res.status(400).send('Feedback data is missing.');
    }

    feedbackData.forEach(feedback => {
      const existingFeedbackIndex = user.feedback.findIndex(f => f.videoId === feedback.videoId);

      if (existingFeedbackIndex !== -1) {
        user.feedback[existingFeedbackIndex].difficulty = feedback.difficulty;
        user.feedback[existingFeedbackIndex].painAreas = feedback.painAreas;
      } else {
        user.feedback.push({
          videoId: feedback.videoId,
          difficulty: feedback.difficulty,
          painAreas: feedback.painAreas
        });
      }
    });

    await user.save();

    res.status(200).send({ message: 'Feedback updated successfully.' });
  } catch (error) {
    console.error('Failed to update feedback:', error);
    res.status(500).send({ error: 'Failed to update feedback.' });
  }
});

//------------------------------------------------
// Video Concatenation and Streaming Functionality
//------------------------------------------------

function generateConcatListFile(videoFiles, listPath) {
  const listContent = videoFiles.map(file => `file '${file}'`).join('\n');
  fs.writeFileSync(listPath, listContent);
}

async function concatenateVideos(listPath, outputFile) {
  return new Promise((resolve, reject) => {
    ffmpeg()
      .input(listPath)
      .inputOptions([
        '-f concat', 
        '-safe 0'
      ])
      .outputOptions([
        '-c copy',                 // Copy video and audio streams
        '-avoid_negative_ts make_zero', 
        '-map_metadata -1'
      ])
      .output(outputFile)
      .on('start', (commandLine) => {
        console.log(`Spawned ffmpeg with command: ${commandLine}`);
      })
      .on('error', (err) => {
        console.error(`Error during concatenation: ${err.message}`);
        reject(err);
      })
      .on('end', () => {
        console.log('Concatenation succeeded');
        resolve(outputFile);
      })
      .run();
  });
}

async function selectVideos(userFitnessLevel, duration, focus, goal, intensity) {
  const transitionVideos = ['0134', '0135', '0136', '0137', '0139'];
  
  const warmUpParts = ['WU1', 'WU2'];
  const endParts = ['AB1', 'AB2'];
  const pairsToPlayConsecutively = [
    ['0002', '0003'], ['0018', '0019'], ['0061', '0062'], ['0011', '0012'], ['0045', '0046'],
    ['0039', '0040'], ['0042', '0041']
  ];
  const videoCriteria = {
    WU1: [],
    WU2: [],
    MAIN: [],
    AB1: [],
    AB2: [],
    TRANSITION: [],
  };

  const videos = await Video.find({});
  console.log(`Found ${videos.length} videos in database`);

  // Categorize the videos
  for (const video of videos) {
    if (transitionVideos.includes(video.id)) {
      videoCriteria.TRANSITION.push(video);
    } else {
      for (const logic of video.logic) {
        if (videoCriteria[logic]) {
          videoCriteria[logic].push(video);
        }
      }
    }
  }

  const selectVideoByPose = (category, startPose = null, usedVideos = new Set()) => {
    let candidates = videoCriteria[category].filter(video =>
      (!startPose || video.startPose === startPose) && !usedVideos.has(video.id)
    );
    if (candidates.length > 0) {
      const selected = candidates[Math.floor(Math.random() * candidates.length)];
      usedVideos.add(selected.id);
      return selected;
    }
    return null;
  };

  const selectRandomTransitionVideo = (usedVideos = new Set()) => {
    let candidates = videoCriteria.TRANSITION.filter(video => !usedVideos.has(video.id));
    if (candidates.length > 0) {
      const selected = candidates[Math.floor(Math.random() * candidates.length)];
      usedVideos.add(selected.id);
      return selected;
    }
    return null;
  };

  const selectVideoByFocus = (category, focus, usedVideos = new Set()) => {
    let candidates = videoCriteria[category].filter(video =>
      video.focus.some(f => f.trim() === focus.trim()) && !usedVideos.has(video.id)
    );
    if (candidates.length > 0) {
      const selected = candidates[Math.floor(Math.random() * candidates.length)];
      usedVideos.add(selected.id);
      return selected;
    }
    return null;
  };

  const selectVideoByGoal = (category, goal, usedVideos = new Set()) => {
    let candidates = videoCriteria[category].filter(video =>
      video.goal.some(g => g.trim() === goal.trim()) && !usedVideos.has(video.id)
    );
    if (candidates.length > 0) {
      const selected = candidates[Math.floor(Math.random() * candidates.length)];
      usedVideos.add(selected.id);
      return selected;
    }
    return null;
  };

  // Select videos based on intensity (new function)
  const selectVideoByIntensity = (category, intensityLevel, usedVideos = new Set()) => {
    // Map UI intensity level (0, 1, 2) to difficulty ranges
    let minDifficulty, maxDifficulty;
    
    switch(intensityLevel) {
      case 0: // Low intensity
        minDifficulty = 1;
        maxDifficulty = 3;
        break;
      case 1: // Medium intensity
        minDifficulty = 3;
        maxDifficulty = 7;
        break;
      case 2: // High intensity
        minDifficulty = 7;
        maxDifficulty = 10;
        break;
      default: // Default to medium if unknown
        minDifficulty = 3;
        maxDifficulty = 7;
    }
    
    let candidates = videoCriteria[category].filter(video =>
      video.difficulty >= minDifficulty && 
      video.difficulty <= maxDifficulty && 
      !usedVideos.has(video.id)
    );
    
    if (candidates.length > 0) {
      const selected = candidates[Math.floor(Math.random() * candidates.length)];
      usedVideos.add(selected.id);
      return selected;
    }
    return null;
  };

  const checkConsecutivePair = (videoId) => {
    for (let pair of pairsToPlayConsecutively) {
      if (pair[0] === videoId) {
        return pair[1];
      }
      else if(pair[1] === videoId){
        return pair[0];  
      }
    }
    return null;
  };

  let selectedVideos = [];
  let totalDuration = 0;
  let lastEndPose = null;
  let focusMatchedCount = 0;
  let goalMatchedCount = 0;
  let intensityMatchedCount = 0;
  let usedVideos = new Set();

  // Determine how many focus and goal videos to include based on duration
  let focusVideosToInclude = Math.max(1, Math.floor((duration - 240) / 200) + 1);
  let goalVideosToInclude = Math.max(1, Math.floor((duration - 240) / 200) + 1);
  let intensityVideosToInclude = Math.max(1, Math.floor((duration - 240) / 200) + 1);

  // Select one video from each warm-up category
  for (const part of warmUpParts) {
    let video = selectVideoByPose(part, lastEndPose, usedVideos);
    if (video) {
      selectedVideos.push(video);
      totalDuration += video.duration;
      lastEndPose = video.endPose;
      console.log(`Selected ${part} video: ${video.id}`);

      let consecutiveVideoId = checkConsecutivePair(video.id);
      if (consecutiveVideoId && !usedVideos.has(consecutiveVideoId)) {
        let consecutiveVideo = videos.find(v => v.id === consecutiveVideoId);
        if (consecutiveVideo) {
          selectedVideos.push(consecutiveVideo);
          totalDuration += consecutiveVideo.duration;
          lastEndPose = consecutiveVideo.endPose;
          usedVideos.add(consecutiveVideo.id);
          console.log(`Selected consecutive video: ${consecutiveVideo.id}`);
        }
      }
    } else {
      // If no matching video found, select any video
      video = selectVideoByPose(part, null, usedVideos);
      if (video) {
        selectedVideos.push(video);
        totalDuration += video.duration;
        lastEndPose = video.endPose;
        console.log(`Selected ${part} video without pose match: ${video.id}`);
      } else {
        console.warn(`No ${part} video found`);
      }
    }
  }

  // Calculate the duration for AB1 and AB2
  const endPartDurations = endParts.reduce((sum, part) => {
    const video = selectVideoByPose(part, lastEndPose, usedVideos) || selectVideoByPose(part, null, usedVideos);
    return sum + (video ? video.duration : 0);
  }, 0);

  // Select MAIN and TRANSITION videos to fill the middle part
  let mainVideoCount = 0;

  while (totalDuration < duration - endPartDurations) {
    const remainingDuration = duration - totalDuration - endPartDurations;
    if (remainingDuration <= 0) break;

    let video = null;

    // Ensure that we select enough videos matching the intensity
    if (intensityMatchedCount < intensityVideosToInclude) {
      video = selectVideoByIntensity('MAIN', intensity, usedVideos);
      if (video) {
        intensityMatchedCount++;
        console.log(`Selected Main video by intensity level ${intensity}: ${video.id}`);
      }
    }

    // Ensure that we select enough focus videos based on the duration
    if (!video && focusMatchedCount < focusVideosToInclude && focus !== 'Allgemein') {
      video = selectVideoByFocus('MAIN', focus, usedVideos);
      if (video) {
        focusMatchedCount++;
        console.log(`Selected Main video by focus: ${video.id}`);
      }
    }

    // Ensure that we select enough goal videos based on the duration
    if (!video && goalMatchedCount < goalVideosToInclude && goal !== 'Allgemein') {
      video = selectVideoByGoal('MAIN', goal, usedVideos);
      if (video) {
        goalMatchedCount++;
        console.log(`Selected Main video by goal: ${video.id}`);
      }
    }

    if (!video) {
      video = selectVideoByPose('MAIN', lastEndPose, usedVideos);
    }

    if (video) {
      selectedVideos.push(video);
      totalDuration += video.duration;
      lastEndPose = video.endPose;
      mainVideoCount++;
      console.log(`Selected Main video: ${video.id}`);

      let consecutiveVideoId = checkConsecutivePair(video.id);
      if (consecutiveVideoId && !usedVideos.has(consecutiveVideoId)) {
        let consecutiveVideo = videos.find(v => v.id === consecutiveVideoId);
        if (consecutiveVideo) {
          selectedVideos.push(consecutiveVideo);
          totalDuration += consecutiveVideo.duration;
          lastEndPose = consecutiveVideo.endPose;
          usedVideos.add(consecutiveVideo.id);
          console.log(`Selected consecutive video: ${consecutiveVideo.id}`);
        }
      }
    } else {
      let transitionVideo = selectRandomTransitionVideo(usedVideos);
      if (transitionVideo) {
        selectedVideos.push(transitionVideo);
        totalDuration += transitionVideo.duration;
        lastEndPose = null; // Ignore matching poses for the next video
        console.log(`Selected transition video: ${transitionVideo.id}`);
      } else {
        console.warn('No TRANSITION video found to fill remaining duration');
        break;
      }
    }
  }

  // Select one video from each end category
  for (const part of endParts) {
    let video = selectVideoByPose(part, lastEndPose, usedVideos) || selectVideoByPose(part, null, usedVideos);
    if (video) {
      selectedVideos.push(video);
      totalDuration += video.duration;
      lastEndPose = video.endPose;
      console.log(`Selected ${part} video: ${video.id}`);

      let consecutiveVideoId = checkConsecutivePair(video.id);
      if (consecutiveVideoId && !usedVideos.has(consecutiveVideoId)) {
        let consecutiveVideo = videos.find(v => v.id === consecutiveVideoId);
        if (consecutiveVideo) {
          selectedVideos.push(consecutiveVideo);
          totalDuration += consecutiveVideo.duration;
          lastEndPose = consecutiveVideo.endPose;
          usedVideos.add(consecutiveVideo.id);
          console.log(`Selected consecutive video: ${consecutiveVideo.id}`);
        }
      }
    } else {
      console.warn(`No ${part} video found`);
    }
  }

  console.log(`Selected ${mainVideoCount} MAIN videos`);
  return { selectedVideos, totalDuration };
}

app.post('/concatenate', async (req, res) => {
  try {
    const focusMapping = {
      0: 'Allgemein',
      1: 'unterer Ruecken',
      2: 'oberer Ruecken',
      3: 'Nacken',
      4: 'Schulter',
      5: 'Knie',
      'Allgemein': 0,
      'unterer Ruecken': 1,
      'oberer Ruecken': 2,
      'Nacken': 3,
      'Schulter': 4,
      'Knie': 5,
    };

    const goalMapping = {
      0: 'Allgemein',
      1: 'Kraft',
      2: 'Beweglichkeit',
      3: 'Haltung',
      'Allgemein': 0,
      'Kraft': 1,
      'Beweglichkeit': 2,
      'Haltung': 3,
    };

    const fitnessLevelMapping = {
      0: 'Nicht so oft',
      1: 'Mehrmals im Monat',
      2: 'Einmal pro Woche',
      3: 'Mehrmals pro Woche',
      4: 'Täglich',
      'Nicht so oft': 0,
      'Mehrmals im Monat': 1,
      'Einmal pro Woche': 2,
      'Mehrmals pro Woche': 3,
      'Täglich': 4,
    };

    const {
      duration,
      focus: rawFocus = 0,
      goal: rawGoal = 0,
      userFitnessLevel: rawFitnessLevel,
      intensity: rawIntensity = 1,
      locale = 'de_DE',
    } = req.body;

    console.log(req.body);

    // Convert string inputs to integers if necessary
    const focusIndex = typeof rawFocus === 'string' ? focusMapping[rawFocus] : rawFocus;
    const goalIndex = typeof rawGoal === 'string' ? goalMapping[rawGoal] : rawGoal;
    const fitnessLevel = typeof rawFitnessLevel === 'string' ? fitnessLevelMapping[rawFitnessLevel] : rawFitnessLevel;
    const intensity = typeof rawIntensity === 'number' ? rawIntensity : 1; // Default to medium intensity

    // Validate the converted values
    if (
      focusIndex === undefined ||
      goalIndex === undefined ||
      fitnessLevel === undefined
    ) {
      return res.status(400).json({
        message: 'Invalid focus, goal, or userFitnessLevel value. Please update your app.',
      });
    }

    console.log(locale);
    const videoDirectory = locale === 'de_DE' ? '/home/backquest/videos/de' : '/home/backquest/videos/en';
    //const videoDirectory = '/home/backquest/videos/de';

    // Map integers to their respective string values for further processing
    const focus = focusMapping[focusIndex] || 'Allgemein';
    const goal = goalMapping[goalIndex] || 'Allgemein';
    const listPath = '/home/backquest/videos/mylist.txt';

    console.log("Duration: " + duration);
    console.log("Goal: " + goal);
    console.log("Focus: " + focus);
    console.log("FitnessLevel: " + fitnessLevel);
    console.log("Intensity: " + intensity);
    console.log("Locale: " + locale);

    const { selectedVideos, totalDuration } = await selectVideos(
      fitnessLevel, 
      duration, 
      focus, 
      goal, 
      intensity
    );
    
    const sessionId = Date.now() + "_" + Math.random().toString(36).substr(2, 9); // Unique session identifier
    const outputVideo = `/home/backquest/output/concatenated_video_${sessionId}.mp4`;

    await generateConcatListFile(selectedVideos.map(video => `${videoDirectory}/${video.id}.mp4`), listPath);
    await concatenateVideos(listPath, outputVideo);

    videoSessions[sessionId] = outputVideo; // Store video path with session ID

    res.json({
      message: 'Videos concatenated successfully',
      sessionId,
      totalDuration,
      selectedVideos: selectedVideos.map(video => video.id),
    });
  } catch (error) {
    console.error('Failed to concatenate videos:', error);
    res.status(500).send('Failed to concatenate videos');
  }
});

app.get('/video', (req, res) => {
  const sessionId = req.query.sessionId;  // Get sessionId from query parameters

  if (!sessionId) {
    return res.status(400).send('No session ID provided');
  }

  const videoPath = videoSessions[sessionId];  // Retrieve the correct video path for this sessionId
  if (!videoPath || !fs.existsSync(videoPath)) {
    console.log('Video not found for sessionId:', sessionId);
    return res.status(404).send('Video not found');
  }

  const stat = fs.statSync(videoPath);
  const fileSize = stat.size;
  const range = req.headers.range;

  if (range) {
    const parts = range.replace(/bytes=/, "").split("-");
    const start = parseInt(parts[0], 10);
    const end = parts[1] ? parseInt(parts[1], 10) : fileSize - 1;

    if (start >= fileSize) {
      return res.status(416).send('Requested range not satisfiable\n' + start + ' >= ' + fileSize);
    }

    const chunksize = (end - start) + 1;
    const file = fs.createReadStream(videoPath, { start, end });
    const head = {
      'Content-Range': `bytes ${start}-${end}/${fileSize}`,
      'Accept-Ranges': 'bytes',
      'Content-Length': chunksize,
      'Content-Type': 'video/mp4',
    };

    res.writeHead(206, head);
    file.pipe(res);
  } else {
    const head = {
      'Content-Length': fileSize,
      'Content-Type': 'video/mp4',
    };
    res.writeHead(200, head);
    fs.createReadStream(videoPath).pipe(res);
  }
});

// Cleanup old video files periodically
const outputPath = '/home/backquest/output'; // Define outputPath

cron.schedule('0 */2 * * *', () => {  // Runs every 2 hours at the top of the hour
  console.log("Running periodic cleanup...");
  fs.readdir(outputPath, (err, files) => {
    if (err) {
      console.error('Unable to scan directory:', err);
      return;
    }

    const currentTime = new Date().getTime();

    files.forEach((file) => {
      const filePath = path.join(outputPath, file);  // Use path.join for better handling
      fs.stat(filePath, (err, stats) => {
        if (err) {
          console.error('Unable to get file stats:', err);
          return;
        }

        const fileAge = (currentTime - new Date(stats.mtime).getTime()) / (1000 * 60 * 60); // Age in hours
        if (fileAge > 24) {
          // Delete the file
          fs.unlink(filePath, (err) => {
            if (err) {
              console.error('Failed to delete file:', err);
            } else {
              console.log('Deleted:', filePath);
              
              // Also clean up the videoSessions object
              for (let sessionId in videoSessions) {
                if (videoSessions[sessionId] === filePath) {
                  delete videoSessions[sessionId];
                  console.log(`Removed session ${sessionId} from memory`);
                }
              }
            }
          });
        }
      });
    });
  });
});

// Ensure required directories exist
function initializeDirectories() {
  const requiredDirs = [
    '/home/backquest/videos/de',
    '/home/backquest/videos/en',
    '/home/backquest/output'
  ];

  requiredDirs.forEach(dir => {
    if (!fs.existsSync(dir)) {
      console.log(`Creating directory: ${dir}`);
      fs.mkdirSync(dir, { recursive: true });
    } else {
      console.log(`Directory already exists: ${dir}`);
    }
  });
}

// Initialize directories when server starts
initializeDirectories();

// Start the server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

module.exports = { app, User };