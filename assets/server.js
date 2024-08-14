require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const helmet = require('helmet');
const ffmpeg = require('fluent-ffmpeg');
const fs = require('fs');
const path = require('path');

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
  painAreas: [String],
  workplaceEnvironment: String,
  fitnessLevel: String,
  personalGoal: [String],
  questionnaireDone: Boolean,
  payedSubscription: Boolean,
  subType: String,
  subStarted: Date,
  feedback: [{
    videoId: String,
    difficulty: String,
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
    if (req.body.painAreas) user.painAreas = req.body.painAreas;
    if (req.body.workplaceEnvironment) user.workplaceEnvironment = req.body.workplaceEnvironment;
    if (req.body.fitnessLevel) user.fitnessLevel = req.body.fitnessLevel;
    if (req.body.personalGoal) user.personalGoal = req.body.personalGoal;
	if (req.body.questionnaireDone) user.questionnaireDone = req.body.questionnaireDone;
	if (req.body.payedSubscription) user.payedSubscription = req.body.payedSubscription;
  if (req.body.subType) user.subType = req.body.subType;
  if (req.body.subStarted) user.subStarted = req.body.subStarted;
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
      painAreas: user.painAreas,
      workplaceEnvironment: user.workplaceEnvironment,
      fitnessLevel: user.fitnessLevel,
      personalGoal: user.personalGoal,
	  questionnaireDone: user.questionnaireDone,
	  payedSubscription: user.payedSubscription,
    subType: user.subType,
    subStarted: user.subStarted,
	  feedback: user.feedback,
    };

    res.status(200).json(userProfile);
  } catch (error) {
    console.error("Fetching profile error:", error);
    res.status(500).send(error.message || 'Server error');
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
        painAreas: user.painAreas,
        workplaceEnvironment: user.workplaceEnvironment,
        fitnessLevel: user.fitnessLevel,
        personalGoal: user.personalGoal,
        questionnaireDone: user.questionnaireDone,
		payedSubscription: user.payedSubscription,
    subType: user.subType,
    subStarted: user.subStarted,
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
      .inputOptions(['-f concat', '-safe 0'])
      .outputOptions([
        '-c copy',
        '-bsf:a aac_adtstoasc',
        '-fflags +genpts'
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
  const transitionVideos = ['0134', '0135', '0136', '0137', '0138', '0139'];
  const warmUpParts = ['WU1', 'WU2'];
  const endParts = ['AB1', 'AB2'];
  const pairsToPlayConsecutively = [
    ['0002', '0003'], ['0018', '0019'], ['0029', '0030'], ['0061', '0062'], ['0011', '0012'], ['0045', '0046'],
    ['0039', '0040'], ['0077', '0078'], ['0042', '0041']
  ];
  const fitnessLevelMap = {
    'Nicht so oft': 1,
    'Mehrmals im Monat': 2,
    'Einmal pro Woche': 3,
    'Mehrmals pro Woche': 4,
    'Täglich': 5,
  };
  const fitnessLevel = fitnessLevelMap[userFitnessLevel];
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







app.post('/concatenate', authenticateToken, async (req, res) => {
  try {
    console.log(req.body);
    console.log('#######################################');
    const { duration, focus = 'Allgemein', goal = 'Allgemein', userFitnessLevel } = req.body;

    const { selectedVideos, totalDuration } = await selectVideos(userFitnessLevel, duration, focus, goal);
    const listPath = '/var/www/backquest/videos/mylist.txt';
    const outputVideo = '/var/www/backquest/output/concatenated_video.mp4';

    await generateConcatListFile(selectedVideos.map(video => `/var/www/backquest/videos/${video.id}.mp4`), listPath);
    await concatenateVideos(listPath, outputVideo);

    res.json({
      message: 'Videos concatenated successfully',
      totalDuration,
      selectedVideos: selectedVideos.map(video => video.id),
    });
  } catch (error) {
    console.error('Failed to concatenate videos:', error);
    res.status(500).send('Failed to concatenate videos');
  }
});




const videoPath = '/var/www/backquest/output/concatenated_video.mp4';

app.get('/video', (req, res) => {
  const stat = fs.statSync(videoPath);
  const fileSize = stat.size;
  const range = req.headers.range;

  if (range) {
    const parts = range.replace(/bytes=/, "").split("-");
    const start = parseInt(parts[0], 10);
    const end = parts[1] ? parseInt(parts[1], 10) : fileSize-1;

    const chunksize = (end-start)+1;
    const file = fs.createReadStream(videoPath, {start, end});
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

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
