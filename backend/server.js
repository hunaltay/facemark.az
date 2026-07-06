import express from 'express';
import cors from 'cors';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const app = express();
const uploadDir = path.resolve(__dirname, 'uploads');
const publicDir = path.resolve(__dirname, '..');
const dataFile = path.resolve(__dirname, 'data.json');

if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

if (!fs.existsSync(dataFile)) {
  fs.writeFileSync(dataFile, JSON.stringify({ applications: [] }, null, 2));
}

function readData() {
  try {
    return JSON.parse(fs.readFileSync(dataFile, 'utf-8'));
  } catch (err) {
    return { applications: [] };
  }
}

function writeData(data) {
  fs.writeFileSync(dataFile, JSON.stringify(data, null, 2));
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, uploadDir),
  filename: (req, file, cb) => {
    const safeName = `${Date.now()}-${file.originalname.replace(/[^a-zA-Z0-9._-]/g, '_')}`;
    cb(null, safeName);
  }
});

const upload = multer({
  storage,
  limits: { fileSize: 10 * 1024 * 1024 }
});

app.use(cors({ origin: true }));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use('/uploads', express.static(uploadDir));
app.use((req, res, next) => {
  if (req.path.startsWith('/backend')) {
    return res.status(404).end();
  }
  next();
});
app.use(express.static(publicDir));

app.get('/api/health', (req, res) => {
  res.json({ ok: true, uptime: process.uptime() });
});

app.post('/api/applications', upload.single('cv'), (req, res) => {
  const {
    form_type,
    first_name,
    last_name,
    email,
    phone,
    direction,
    message,
    linkedin
  } = req.body;

  if (!form_type || !first_name || !last_name || !email) {
    return res.status(400).json({ error: 'form_type, first_name, last_name and email are required' });
  }

  const cv_path = req.file ? `/uploads/${req.file.filename}` : null;
  const data = readData();
  const application = {
    id: typeof crypto !== 'undefined' && crypto.randomUUID ? crypto.randomUUID() : Date.now().toString(),
    form_type,
    first_name,
    last_name,
    email,
    phone: phone || null,
    direction: direction || null,
    message: message || null,
    linkedin: linkedin || null,
    cv_path,
    created_at: new Date().toISOString()
  };

  data.applications.push(application);
  writeData(data);

  res.status(201).json({ id: application.id, cv_path });
});

app.use((req, res) => {
  res.status(404).json({ error: 'Not found' });
});

const port = process.env.PORT || 4000;
app.listen(port, () => {
  console.log(`Backend running at http://localhost:${port}`);
});
