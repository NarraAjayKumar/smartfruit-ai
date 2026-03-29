const express = require('express');
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(express.json());
app.use(cors()); // Enable All CORS Requests for mobile device access

// Logging middleware for production debugging
app.use((req, res, next) => {
    console.log(`📡 ${new Date().toISOString()} - ${req.method} ${req.url}`);
    next();
});

const connectDB = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URI);
        console.log('✅ MongoDB Connected');
    } catch (err) {
        console.error('❌ MongoDB Connection Error:', err.message);
        setTimeout(connectDB, 5000); // Retry after 5 seconds
    }
};
connectDB();

// User Model
const UserSchema = new mongoose.Schema({
    name: { type: String, required: true },
    email: { type: String, unique: true, sparse: true },
    phone: { type: String, unique: true, sparse: true },
    password: { type: String },
    isVerified: { type: Boolean, default: false }
});

const User = mongoose.model('User', UserSchema);

// --- HEALTH CHECK ---
app.get('/api/health', (req, res) => {
    res.json({ success: true, message: '🚀 SmartFruit AI Server is REACHABLE!' });
});

// --- AUTH ROUTES ---

// 1. Email Register
app.post('/api/register', async (req, res) => {
    try {
        const { name, email, password } = req.body;
        
        let user = await User.findOne({ email });
        if (user) return res.status(400).json({ success: false, message: 'User already exists' });

        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        user = new User({ name, email, password: hashedPassword, isVerified: true });
        await user.save();

        const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, { expiresIn: '7d' });
        res.status(201).json({ success: true, token, user: { name: user.name, email: user.email } });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Server Error' });
    }
});

// 2. Email Login
app.post('/api/login', async (req, res) => {
    try {
        const { email, password } = req.body;
        
        const user = await User.findOne({ email });
        if (!user) return res.status(400).json({ success: false, message: 'Invalid credentials' });

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) return res.status(400).json({ success: false, message: 'Invalid credentials' });

        const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, { expiresIn: '7d' });
        res.json({ success: true, token, user: { name: user.name, email: user.email } });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Server Error' });
    }
});

// 3. Send OTP (Mock)
app.post('/api/otp/send', async (req, res) => {
    try {
        const { phone } = req.body;
        console.log(`📡 Sending Mock OTP 123456 to ${phone}`);
        // In a real app, you'd integrate Twilio/MessageBird here
        res.json({ success: true, message: 'OTP sent successfully (Mock: 123456)' });
    } catch (err) {
        res.status(500).json({ success: false, message: 'Failed to send OTP' });
    }
});

// 4. Verify OTP (Mock)
app.post('/api/otp/verify', async (req, res) => {
    try {
        const { phone, otp } = req.body;

        if (otp !== '123456') {
            return res.status(400).json({ success: false, message: 'Invalid OTP' });
        }

        let user = await User.findOne({ phone });
        if (!user) {
            user = new User({ name: `User ${phone.slice(-4)}`, phone, isVerified: true });
            await user.save();
        }

        const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, { expiresIn: '7d' });
        res.json({ success: true, token, user: { name: user.name, phone: user.phone } });
    } catch (err) {
        res.status(500).json({ success: false, message: 'Verification failed' });
    }
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Professional Auth Server running on port ${PORT}`);
});
