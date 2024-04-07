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
  .outputOptions('-c copy')
  .output(outputFile)
  .on('start', (commandLine) => {
    console.log(`Spawned ffmpeg with command: ${commandLine}`);
    console.log(`ffmpeg working directory: ${process.cwd()}`);
  })
  .on('error', (err) => reject(err))
  .on('end', () => resolve(outputFile))
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


app.get('/concatenate', authenticateToken, async (req, res) => {
  try {
    const user = await User.findOne({ username: req.user.username });
    if (!user) return res.status(404).send('User not found');

    const fitnessLevelMap = {
      'Nicht so oft': 1,
      'Mehrmals im Monat': 2,
      'Einmal pro Woche': 3,
      'Mehrmals pro Woche': 4,
      'Täglich': 5,
    };

    let userFitnessLevel = fitnessLevelMap[user.fitnessLevel];
    let selectedVideoIds = [];
    const videoFiles = [];
    let currentEndPose;

    const wu1Video = await Video.findOne({
      difficulty: userFitnessLevel,
      _id: { $nin: selectedVideoIds },
      logic: { $in: ["WU1"] }
    });
    if (!wu1Video) return res.status(404).send('No WU1 video found');
    videoFiles.push(`/var/www/backquest/videos/${wu1Video.id}.mp4`);
    selectedVideoIds.push(wu1Video._id);
    currentEndPose = wu1Video.endPose;

    const wu2Video = await Video.findOne({
      startPose: { $regex: new RegExp('^' + currentEndPose + '$', 'i') },
      difficulty: userFitnessLevel,
      _id: { $nin: selectedVideoIds },
      logic: { $in: ["WU2"] }
    });
    if (wu2Video) {
      videoFiles.push(`/var/www/backquest/videos/${wu2Video.id}.mp4`);
      selectedVideoIds.push(wu2Video._id);
      currentEndPose = wu2Video.endPose;
    }

    for (let i = 2; i < 6; i++) {
      const nextVideo = await Video.findOne({
        startPose: { $regex: new RegExp('^' + currentEndPose + '$', 'i') },
        difficulty: { $in: [userFitnessLevel, userFitnessLevel + 1] },
        _id: { $nin: selectedVideoIds },
        logic: { $nin: ["WU1", "AB2"] }
      });

      if (!nextVideo) break;

      videoFiles.push(`/var/www/backquest/videos/${nextVideo.id}.mp4`);
      selectedVideoIds.push(nextVideo._id);
      currentEndPose = nextVideo.endPose;
    }

    const ab2Video = await Video.findOne({
      startPose: { $regex: new RegExp('^' + currentEndPose + '$', 'i') },
      difficulty: { $in: [userFitnessLevel, userFitnessLevel + 1] },
      _id: { $nin: selectedVideoIds },
      logic: { $in: ["AB2"] }
    });

    if (!ab2Video) return res.status(404).send('No AB2 video found to conclude the sequence.');
    videoFiles.push(`/var/www/backquest/videos/${ab2Video.id}.mp4`);

    const listPath = '/var/www/backquest/videos/mylist.txt';
    const outputVideo = '/var/www/backquest/output/concatenated_video.mp4';

    await generateConcatListFile(videoFiles, listPath);
    await concatenateVideos(listPath, outputVideo);
	
	res.json({
		message: 'Videos concatenated successfully',
		selectedVideos: videoFiles.map(filePath => {
		  const fileName = path.basename(filePath);
		  return fileName.split('.')[0];
		}),
	});

    console.log('Videos concatenated successfully');
  } catch (error) {
    console.error('Failed to concatenate videos:', error);
    res.status(500).send('Failed to concatenate videos');
  }
});


//Video Streaming


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
