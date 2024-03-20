require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const helmet = require('helmet');
const ffmpeg = require('fluent-ffmpeg');
const fs = require('fs');

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
  completedLevels: Number,
  painAreas: [String],
  workplaceEnvironment: String,
  fitnessLevel: String,
  expectation: String,
  personalGoal: String,
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
	if (req.body.completedLevels) user.completedLevels = req.body.completedLevels;
    if (req.body.painAreas) user.painAreas = req.body.painAreas;
    if (req.body.workplaceEnvironment) user.workplaceEnvironment = req.body.workplaceEnvironment;
    if (req.body.fitnessLevel) user.fitnessLevel = req.body.fitnessLevel;
    if (req.body.expectation) user.expectation = req.body.expectation;
    if (req.body.personalGoal) user.personalGoal = req.body.personalGoal;

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
	  completedLevels: user.completedLevels,
      painAreas: user.painAreas,
      workplaceEnvironment: user.workplaceEnvironment,
      fitnessLevel: user.fitnessLevel,
      expectation: user.expectation,
      personalGoal: user.personalGoal,
    };

    res.status(200).json(userProfile);
  } catch (error) {
    console.error("Fetching profile error:", error);
    res.status(500).send(error.message || 'Server error');
  }
});


//Video Concat

const videosToConcatenate = [
    '/var/www/backquest/videos/abschluss1_cp_fesi.mp4',
    '/var/www/backquest/videos/birddog_hiswi_auf_4fl_auf.mp4',
    '/var/www/backquest/videos/birddog_wippen_links_4fl_auf_4fl_auf.mp4',
    '/var/www/backquest/videos/birddog_wippen_rechts_4fl_auf_4fl_auf.mp4',
    '/var/www/backquest/videos/childpose_4fl_cp.mp4',
    '/var/www/backquest/videos/childpose_cp_cp.mp4',
    '/var/www/backquest/videos/einseitigchildpose_rechts_cp_cp.mp4',
    '/var/www/backquest/videos/katzekuh_4fl_auf_4fl_auf_.mp4',
    '/var/www/backquest/videos/schneidersitz_meditation.mp4'
];

function generateConcatListFile(videoFiles, listPath) {
    const listContent = videoFiles.map(file => `file '${file}'`).join('\n');
    fs.writeFileSync(listPath, listContent);
}

function concatenateVideos(listPath, outputFile) {
    return new Promise((resolve, reject) => {
        ffmpeg()
            .input(listPath)
            .inputOptions(['-f concat', '-safe 0'])
            .outputOptions('-c copy')
            .output(outputFile)
            .on('error', (err) => reject(err))
            .on('end', () => resolve(outputFile))
            .run();
    });
}

app.get('/concatenate', (req, res) => {
    const listPath = '/var/www/backquest/videos/mylist.txt'; // Path to your list file
    const outputVideo = '/var/www/backquest/output/concatenated_video.mp4'; // Output file path

    // Generate list file and concatenate videos
    generateConcatListFile(videosToConcatenate, listPath);
    concatenateVideos(listPath, outputVideo)
        .then(() => {
            console.log('Videos concatenated successfully');
            res.send('Videos concatenated successfully');
        })
        .catch((error) => {
            console.error('Failed to concatenate videos:', error);
            res.status(500).send('Failed to concatenate videos');
        });
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
