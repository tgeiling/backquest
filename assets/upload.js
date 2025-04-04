require('dotenv').config();
const mongoose = require('mongoose');
const fs = require('fs');

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
  combine: String,
});

const Video = mongoose.model('Video', VideoSchema);

mongoose.connect(process.env.MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
  serverSelectionTimeoutMS: 45000,
  connectTimeoutMS: 45000,
}).then(async () => {
  console.log('MongoDB connected');

  try {
    await mongoose.connection.dropCollection('videos');
    console.log('Collection dropped successfully.');
  } catch (err) {
    if (err.code === 26) {
      console.log('Collection not found. Proceeding with import.');
    } else {
      console.error('Error dropping collection:', err);
      process.exit(); 
    }
  }

  importVideos();

}).catch(err => {
  console.error('MongoDB connection error:', err);
});

const importVideos = async () => {
  try {
    const data = fs.readFileSync('/home/backquest/videos.json', 'utf8');
    const videos = JSON.parse(data);

    await Video.insertMany(videos);
    console.log('Videos have been successfully imported');
  } catch (error) {
    console.error('Error importing videos:', error);
  } finally {
    mongoose.connection.close();
  }
};