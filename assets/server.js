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


async function selectVideos(user, duration, focus, goal) {
  const fitnessLevelMap = {
    'Nicht so oft': 1,
    'Mehrmals im Monat': 2,
    'Einmal pro Woche': 3,
    'Mehrmals pro Woche': 4,
    'Täglich': 5,
  };

  let fitnessLevels = [
    fitnessLevelMap[user.fitnessLevel]
  ];
  
  // Adjust fitness levels priority based on user's current fitness level
  const fitnessLevel = fitnessLevelMap[user.fitnessLevel];
  if (fitnessLevel === 1) {
    fitnessLevels.push(2, 3, 4, 5);
  } else if (fitnessLevel === 2) {
    fitnessLevels.push(1, 3, 4, 5);
  } else if (fitnessLevel === 3) {
    fitnessLevels.push(4, 5, 1, 2);
  } else if (fitnessLevel === 4) {
    fitnessLevels.push(5, 1, 2, 3);
  } else if (fitnessLevel === 5) {
    fitnessLevels.push(1, 2, 3, 4);
  }

  const transitionVideos = ['0134', '0135', '0136', '0137', '0138', '0139'];
  const mandatoryParts = ['WU1', 'WU2', 'AB1', 'AB2'];
  const videoCriteria = {
    WU1: [],
    WU2: [],
    MAIN: [],
    AB1: [],
    AB2: [],
    TRANSITION: []
  };

  const videos = await Video.find({});

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

  const selectVideoByCriteria = (logic, remainingDuration) => {
    for (const level of fitnessLevels) {
      const filteredVideos = videoCriteria[logic].filter(video => 
        video.difficulty === 0 || video.difficulty === level &&
        (focus === 'Allgemein' || video.focus.includes(focus)) &&
        (goal === 'Allgemein' || video.goal.includes(goal)) &&
        (!user.painAreas.length || user.painAreas.some(painArea => video.focus.includes(painArea))) &&
        video.duration <= remainingDuration
      );
      
      if (filteredVideos.length > 0) {
        return filteredVideos[Math.floor(Math.random() * filteredVideos.length)];
      }
    }
    return null;
  };

  let selectedVideos = [];
  let totalDuration = 0;

  for (const part of mandatoryParts) {
    const video = selectVideoByCriteria(part, duration - totalDuration);
    if (video) {
      selectedVideos.push(video);
      totalDuration += video.duration;
    }
  }

  while (totalDuration < duration) {
    const video = selectVideoByCriteria('MAIN', duration - totalDuration) ||
                  selectVideoByCriteria('TRANSITION', duration - totalDuration);

    if (video) {
      selectedVideos.push(video);
      totalDuration += video.duration;
    } else {
      break;
    }
  }

  return { selectedVideos, totalDuration };
}

app.post('/concatenate', authenticateToken, async (req, res) => {
  try {
    const { duration, focus = 'Allgemein', goal = 'Allgemein' } = req.body;
    const user = await User.findOne({ username: req.user.username });
    if (!user) return res.status(404).send('User not found');

    const { selectedVideos, totalDuration } = await selectVideos(user, duration, focus, goal);
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

// A protected route
app.get('/protected', authenticateToken, (req, res) => {
  res.json({ message: 'Welcome to the protected route!', user: req.user });
});

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
