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

// MongoDB connection
mongoose.connect(process.env.MONGO_URI, {
  serverSelectionTimeoutMS: 45000,
  connectTimeoutMS: 45000,
})
.then(() => console.log('MongoDB connected'))
.catch(err => console.log(err));

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

async function selectVideoForCategory(category, currentEndPose, focus, goal, selectedVideoIds) {
    // Constants for video pairing
    let videoPairs = {
        "0034": "0033",
        "0036": "0035"
    };

    // Attempt sequence to relax search criteria
    let attempts = [
        { focus: focus, goal: goal },  // First attempt with both focus and goal
        { focus: null, goal: goal },  // Second attempt without focus
        { focus: focus, goal: null }  // Third attempt without goal
    ];

    // Fitness level trials
    let fitnessLevelsToTry = [1,2,3,4,5];
    let videoFound = null;

    // Fetch user and their feedback

    // Categories to try
    let categoriesToTry = category === 'MAIN' ? [category] : [category];

    for (const attempt of attempts) {
        for (const currentCategory of categoriesToTry) {
            if (videoFound) break;

            for (const level of fitnessLevelsToTry) {
                let matchCriteria = {
                    difficulty: level,
                    logic: { $in: [currentCategory] },
                    _id: { $nin: selectedVideoIds }
                };
                if (currentEndPose) matchCriteria.startPose = new RegExp('^' + currentEndPose + '$', 'i');
                if (attempt.focus !== null) matchCriteria.focus = attempt.focus;
                if (attempt.goal !== null) matchCriteria.goal = attempt.goal;

                const videos = await Video.find(matchCriteria).sort({ duration: -1 });
				

                if (videos.length > 0) {
                    const randomIndex = Math.floor(Math.random() * videos.length);
                    videoFound = videos[randomIndex];

                    // Handle video pairs
                    if (videoPairs[videoFound._id] && !selectedVideoIds.includes(videoPairs[videoFound._id])) {
                        const pairVideoId = videoPairs[videoFound._id];
                        const pairVideo = await Video.findById(pairVideoId);
                        if (pairVideo) {
                            selectedVideoIds.push(pairVideo._id);
                            return { pairVideo, videoFound };
                        }
                    }
                }
            }
        }
        if (videoFound) break;
    }

    // Final fallback: try additional categories if MAIN was initially chosen and no video found
    if (!videoFound && category === 'MAIN') {
        categoriesToTry = ['WU1', 'WU2', 'AB1', 'AB2'];
        for (const fallbackCategory of categoriesToTry) {
            const result = await selectVideoForCategory(fallbackCategory, currentEndPose, null, null, selectedVideoIds);
            if (result) return result;
        }
    }
	
	if(!videoFound && category === 'AB1'){
		const result = await selectVideoForCategory('AB1', null, null, null, selectedVideoIds);
	}
	
	if(!videoFound && category === 'AB2'){
		const result = await selectVideoForCategory('AB2', null, null, null, selectedVideoIds);
	}

    return videoFound;
}




app.get('/concatenate', authenticateToken, async (req, res) => {
	console.log("auth fine")
  try {
    // Initialization
    const fitnessLevelMap = {
      'Nicht so oft': 1,
      'Mehrmals im Monat': 2,
      'Einmal pro Woche': 3,
      'Mehrmals pro Woche': 4,
      'Täglich': 5,
    };
    const desiredDuration = parseInt(req.query.duration) || 600;
    const focus = req.query.focus !== 'Allgemein' ? req.query.focus : null;
    const goal = req.query.goal !== 'Allgemein' ? req.query.goal : null;
    let totalDuration = 0;
    let currentEndPose = null;
    const selectedVideos = [];
    const selectedVideoIds = [];
	
	console.log(Video);

    // Warmup
    for (const category of ['WU1', 'WU2']) {
      let video = await selectVideoForCategory(category, currentEndPose, focus, goal, selectedVideoIds);
      if (video) {
        selectedVideos.push(video);
		console.log(selectedVideos);
        selectedVideoIds.push(video._id);
        currentEndPose = video.endPose;
        totalDuration += video.duration;
      }
    }

    // Main Exercise Loop
    while (totalDuration < desiredDuration) {
	let mainVideo = await selectVideoForCategory('MAIN', currentEndPose, focus, goal, selectedVideoIds);
      if (!mainVideo) break;
	  selectedVideos.push(mainVideo);
	  console.log(selectedVideos);
	  selectedVideoIds.push(mainVideo._id);
	  currentEndPose = mainVideo.endPose;
	  totalDuration += mainVideo.duration;
    }

    // Cooldown
    for (const category of ['AB1', 'AB2']) {
      let video = await selectVideoForCategory(category, currentEndPose, focus, goal, selectedVideoIds);
      if (video) {
        selectedVideos.push(video);
		console.log(selectedVideos);
        selectedVideoIds.push(video._id);
        currentEndPose = video.endPose;
        totalDuration += video.duration;
      }
    }

    // Concatenate the videos
    const listPath = '/var/www/backquest/videos/mylist.txt';
    const outputVideo = '/var/www/backquest/output/concatenated_video.mp4';
    await generateConcatListFile(selectedVideos.map(video => `/var/www/backquest/videos/${video.id}.mp4`), listPath);
    await concatenateVideos(listPath, outputVideo);

    // Response
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

// A protected route
app.get('/protected', authenticateToken, (req, res) => {
  res.json({ message: 'Welcome to the protected route!', user: req.user });
});

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
