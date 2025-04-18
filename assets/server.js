require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const helmet = require('helmet');
const ffmpeg = require('fluent-ffmpeg');
const fs = require('fs');
const path = require('path');
const cron = require('node-cron');
const { v4: uuidv4 } = require('uuid');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());
app.use(helmet());

mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log('MongoDB connected'))
  .catch(err => console.log('MongoDB connection error:', err));

const UserSchema = new mongoose.Schema({
  username: String,
  password: String,
  birthdate: Date,
  gender: String,
  weight: Number,
  height: Number,
  weeklyGoal: Number,
  weeklyDone: Number,
  weeklyStreak: Number,
  lastUpdateString: String,
  completedLevels: Number,
  completedLevelsTotal: Number,
  painAreas: [String],
  workplaceEnvironment: String,
  fitnessLevel: String,
  personalGoal: [String],
  questionnaireDone: Boolean,
  payedSubscription: Boolean,
  subType: String,
  subStarted: Date,
  receiptData: String,
  lastResetDate: String,
  feedback: [{
    videoId: String,
    difficulty: Number,
    painAreas: [String]
  }]
});

const User = mongoose.model('User', UserSchema);

// Register endpoint
app.post('/register', async (req, res) => {
  try {
    const hashedPassword = await bcrypt.hash(req.body.password, 10);
    const user = new User({ username: req.body.username, password: hashedPassword });
    await user.save();
    res.status(201).send('User registered successfully');
  } catch (error) {
    console.error("Registration error:", error);
    res.status(500).send(error.message || 'Server error');
  }
});

// Login endpoint
app.post('/login', async (req, res) => {
  const user = await User.findOne({ username: req.body.username });
  if (user == null) {
    return res.status(400).send('Cannot find user');
  }
  try {
    if (await bcrypt.compare(req.body.password, user.password)) {
      const accessToken = jwt.sign(
        { username: user.username },
        process.env.ACCESS_TOKEN_SECRET,
        { expiresIn: '14d' }
      );
      res.json({ accessToken: accessToken });
    } else {
      res.send('Not Allowed');
    }
  } catch {
    res.status(500).send();
  }
});

app.post('/guestnode', (req, res) => {
	console.log("guestnode is triggered")
  try {
    const guestToken = jwt.sign(
      {},
      process.env.ACCESS_TOKEN_SECRET,
      { expiresIn: '1d' }
    );

    res.json({ accessToken: guestToken });
  } catch (error) {
    console.error('Error generating guest token:', error);
    res.status(500).send('Failed to generate guest token');
  }
});

app.post('/validateToken', async (req, res) => {
  const { token } = req.body;
  try {
    const decoded = jwt.verify(token, process.env.ACCESS_TOKEN_SECRET);
    const user = await User.findOne({ username: decoded.username });
    if (user) {
      res.json({ isValid: true });
    } else {
      res.json({ isValid: false, reason: "No user found" });
    }
  } catch (error) {
    res.status(400).send({ isValid: false, reason: "Invalid token" });
  }
});

app.post('/updateProfile', authenticateToken, async (req, res) => {
  try {
    const user = await User.findOne({ username: req.user.username });
    if (!user) {
      return res.status(404).send('User not found');
    }

    if (req.body.birthdate) user.birthdate = req.body.birthdate;
    if (req.body.gender) user.gender = req.body.gender;
    if (req.body.weight) user.weight = req.body.weight;
    if (req.body.height) user.height = req.body.height;
	if (req.body.weeklyGoal) user.weeklyGoal = req.body.weeklyGoal;
	if (req.body.weeklyDone) user.weeklyDone = req.body.weeklyDone;
	if (req.body.weeklyStreak) user.weeklyStreak = req.body.weeklyStreak;
	if (req.body.lastUpdateString) user.lastUpdateString = req.body.lastUpdateString;
	if (req.body.completedLevels) user.completedLevels = req.body.completedLevels;
	if (req.body.completedLevelsTotal) user.completedLevelsTotal = req.body.completedLevelsTotal;
    if (req.body.painAreas) user.painAreas = req.body.painAreas;
    if (req.body.workplaceEnvironment) user.workplaceEnvironment = req.body.workplaceEnvironment;
    if (req.body.fitnessLevel) user.fitnessLevel = req.body.fitnessLevel;
    if (req.body.personalGoal) user.personalGoal = req.body.personalGoal;
	if (req.body.questionnaireDone) user.questionnaireDone = req.body.questionnaireDone;
	if (req.body.payedSubscription) user.payedSubscription = req.body.payedSubscription;
	if (req.body.subType) user.subType = req.body.subType;
	if (req.body.subStarted) user.subStarted = req.body.subStarted;
	if (req.body.receiptData) user.receiptData = req.body.receiptData;
	if (req.body.lastResetDate) user.lastResetDate = req.body.lastResetDate;
	if (req.body.feedback) user.feedback = req.body.feedback;

    await user.save();
    res.status(200).send('Profile updated successfully');
  } catch (error) {
    console.error("Profile update error:", error);
    res.status(500).send(error.message || 'Server error');
  }
});

app.get('/profile', authenticateToken, async (req, res) => {
  try {
    const user = await User.findOne({ username: req.user.username });
    if (!user) {
      return res.status(404).send('User not found');
    }

    // Respond with the user's profile information
    const userProfile = {
	  birthdate: user.birthdate,
	  gender: user.gender,
	  weight: user.weight,
	  height: user.height,
	  weeklyGoal: user.weeklyGoal,
	  weeklyDone: user.weeklyDone,
	  weeklyStreak: user.weeklyStreak,
	  lastUpdateString: user.lastUpdateString,
	  completedLevels: user.completedLevels,
	  completedLevelsTotal: user.completedLevelsTotal,
	  painAreas: user.painAreas,
	  workplaceEnvironment: user.workplaceEnvironment,
	  fitnessLevel: user.fitnessLevel,
	  personalGoal: user.personalGoal,
	  questionnaireDone: user.questionnaireDone,
	  payedSubscription: user.payedSubscription,
	subType: user.subType,
    subStarted: user.subStarted,
    receiptData: user.receiptData,
	lastResetDate: user.lastResetDate,
	  feedback: user.feedback,
    };

    res.status(200).json(userProfile);
  } catch (error) {
    console.error("Fetching profile error:", error);
    res.status(500).send(error.message || 'Server error');
  }
});

app.post('/requestDeletion', authenticateToken, async (req, res) => {
  try {
    const { password } = req.body;
    
    // Find the user by username from the JWT token
    const user = await User.findOne({ username: req.user.username });
    
    if (!user) {
      return res.status(404).send({ 
        success: false, 
        message: 'User not found' 
      });
    }
    
    // Quick password verification
    const validPassword = await bcrypt.compare(password, user.password);
    if (!validPassword) {
      return res.status(401).send({ 
        success: false, 
        message: 'Incorrect password' 
      });
    }
    
    // Just delete it immediately
    await User.deleteOne({ _id: user._id });
    
    // Return success
    res.status(200).send({ 
      success: true, 
      message: 'Account deleted successfully' 
    });
    
  } catch (error) {
    console.error("Account deletion error:", error);
    res.status(500).send({ 
      success: false, 
      message: 'Server error' 
    });
  }
});

app.get('/userFeedback', async (req, res) => {
  try {
    const users = await User.find({});

    const userFeedback = users.map((user) => ({
      userData: {
        username: user.username,
        birthdate: user.birthdate,
        gender: user.gender,
        weight: user.weight,
        height: user.height,
        weeklyGoal: user.weeklyGoal,
        weeklyDone: user.weeklyDone,
		weeklyStreak: user.weeklyStreak,
		lastUpdateString: user.lastUpdateString,
        completedLevels: user.completedLevels,
		completedLevelsTotal: user.completedLevelsTotal,
        painAreas: user.painAreas,
        workplaceEnvironment: user.workplaceEnvironment,
        fitnessLevel: user.fitnessLevel,
        personalGoal: user.personalGoal,
        questionnaireDone: user.questionnaireDone,
		payedSubscription: user.payedSubscription,
    subType: user.subType,
    subStarted: user.subStarted,
    receiptData: user.receiptData,
	lastResetDate: user.lastResetDate,
        feedback: user.feedback
      }
    }));

    res.json(userFeedback);
  } catch (error) {
    console.error('Failed to fetch user feedback:', error);
    res.status(500).send('Failed to fetch user feedback');
  }
});


//Video Concat

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

function generateConcatListFile(videoFiles, listPath) {
    const listContent = videoFiles.map(file => `file '${file}'`).join('\n');
    fs.writeFileSync(listPath, listContent);
}

function delay(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
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



async function selectVideos(userFitnessLevel, duration, focus, goal) {
  const transitionVideos = ['0134', '0135', '0136', '0137', '0139'];
  
  console.log(transitionVideos)
  
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
  let usedVideos = new Set();

  // Determine how many focus and goal videos to include based on duration
  let focusVideosToInclude = Math.max(1, Math.floor((duration - 240) / 200) + 1);
  let goalVideosToInclude = Math.max(1, Math.floor((duration - 240) / 200) + 1);

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

    // Ensure that we select enough focus videos based on the duration
    if (focusMatchedCount < focusVideosToInclude && focus !== 'Allgemein') {
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


const videoSessions = {};  // Store session-based paths for active videos

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
      locale = req.body.locale,
    } = req.body;

    console.log(req.body);

    // Convert string inputs to integers if necessary
    const focusIndex = typeof rawFocus === 'string' ? focusMapping[rawFocus] : rawFocus;
    const goalIndex = typeof rawGoal === 'string' ? goalMapping[rawGoal] : rawGoal;
    const fitnessLevel = typeof rawFitnessLevel === 'string' ? fitnessLevelMapping[rawFitnessLevel] : rawFitnessLevel;

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
    console.log("Locale: " + locale);

    const { selectedVideos, totalDuration } = await selectVideos(fitnessLevel, duration, focus, goal);
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







// Middleware to authenticate token
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (token == null) return res.sendStatus(401);

  jwt.verify(token, process.env.ACCESS_TOKEN_SECRET, (err, user) => {
    if (err) return res.sendStatus(403);
    req.user = user;
    next();
  });
}

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

/**
 * Validates an Apple receipt
 * @param {string} receiptData - The base64 encoded receipt data
 * @returns {Promise<{valid: boolean, details: object|null, error: string|null}>}
 */
async function validateAppleReceipt(receiptData) {
  const appleSharedSecret = process.env.APPLE_SHARED_SECRET;
  
  if (!appleSharedSecret) {
    console.error('Apple shared secret is not configured');
    return { valid: false, details: null, error: 'Configuration error' };
  }
  
  try {
    // First try production environment
    let response = await axios.post(APPLE_PRODUCTION_URL, {
      'receipt-data': receiptData,
      'password': appleSharedSecret,
    });
    
    // If status is 21007, the receipt is from the sandbox environment
    if (response.data.status === 21007) {
      console.log('Receipt is from sandbox, retrying with sandbox URL');
      response = await axios.post(APPLE_SANDBOX_URL, {
        'receipt-data': receiptData,
        'password': appleSharedSecret,
      });
    }
    
    // Status 0 indicates successful validation
    const isValid = response.data.status === 0;
    
    // Return validation result
    return {
      valid: isValid,
      details: isValid ? response.data : null,
      error: isValid ? null : `Apple validation failed with status: ${response.data.status}`
    };
  } catch (error) {
    console.error('Error validating Apple receipt:', error.message);
    return { 
      valid: false, 
      details: null, 
      error: `Validation request failed: ${error.message}`
    };
  }
}

/**
 * Validates a Google Play receipt
 * @param {string} packageName - The package name of the app
 * @param {string} productId - The product ID of the purchase
 * @param {string} purchaseToken - The purchase token to validate
 * @param {boolean} isSubscription - Whether this is a subscription (true) or one-time product (false)
 * @returns {Promise<{valid: boolean, details: object|null, error: string|null}>}
 */
async function validateGoogleReceipt(packageName, productId, purchaseToken, isSubscription = false) {
  if (!Object.keys(googleCredentials).length) {
    console.error('Google API credentials are not configured');
    return { valid: false, details: null, error: 'Configuration error' };
  }

  try {
    // Set up authentication
    const auth = new GoogleAuth({
      credentials: googleCredentials,
      scopes: ['https://www.googleapis.com/auth/androidpublisher']
    });
    
    const client = await auth.getClient();
    
    // Determine the endpoint based on whether this is a subscription or one-time purchase
    const endpoint = isSubscription 
      ? `${GOOGLE_API_URL}/${packageName}/purchases/subscriptions/${productId}/tokens/${purchaseToken}`
      : `${GOOGLE_API_URL}/${packageName}/purchases/products/${productId}/tokens/${purchaseToken}`;
    
    // Make the validation request
    const response = await client.request({ url: endpoint });
    
    // Check if the purchase is valid
    // For subscriptions, check the subscription state
    // For one-time purchases, check the purchaseState
    let isValid = false;
    
    if (isSubscription) {
      // For subscriptions, check if it's active (not expired, cancelled, etc.)
      isValid = response.data.expiryTimeMillis > Date.now() && 
                response.data.paymentState === 1; // 1 = Payment received
    } else {
      // For one-time purchases, check if purchase state is 0 (purchased)
      isValid = response.data.purchaseState === 0;
    }
    
    return {
      valid: isValid,
      details: response.data,
      error: null
    };
  } catch (error) {
    console.error('Error validating Google receipt:', error.message);
    return { 
      valid: false, 
      details: null, 
      error: `Validation request failed: ${error.message}`
    };
  }
}

module.exports = {
  validateAppleReceipt,
  validateGoogleReceipt
};

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
            }
          });
        }
      });
    });
  });
});


app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
