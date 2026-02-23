import express from 'express';
import cors from 'cors';
import multer from 'multer';
import { Storage } from 'megajs';
import { Readable } from 'stream';

const app = express();
const upload = multer({ storage: multer.memoryStorage() });
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.static('public'));

function openStorage(email, password) {
  return new Promise((resolve, reject) => {
    const storage = new Storage({ email, password }, (err) => {
      if (err) return reject(err);
      resolve(storage);
    });
  });
}

function waitForFileLoad(file) {
  return new Promise((resolve, reject) => {
    file.loadAttributes((err) => {
      if (err) return reject(err);
      resolve(file);
    });
  });
}

app.post('/api/list-pdf', async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: 'Chybí email nebo heslo.' });
    }

    const storage = await openStorage(email, password);
    const files = storage.root.children
      .filter((item) => item.name && item.name.toLowerCase().endsWith('.pdf'))
      .map((item) => ({ id: item.nodeId, name: item.name, size: item.size || 0 }));

    storage.close();
    res.json({ files });
  } catch (error) {
    res.status(500).json({ error: `MEGA list error: ${error.message}` });
  }
});

app.post('/api/download-pdf', async (req, res) => {
  try {
    const { email, password, nodeId } = req.body;
    if (!email || !password || !nodeId) {
      return res.status(400).json({ error: 'Chybí přihlášení nebo nodeId.' });
    }

    const storage = await openStorage(email, password);
    const file = storage.files[nodeId];
    if (!file) {
      storage.close();
      return res.status(404).json({ error: 'Soubor nebyl nalezen.' });
    }

    await waitForFileLoad(file);
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename="${encodeURIComponent(file.name)}"`);

    const stream = file.download();
    stream.on('end', () => storage.close());
    stream.on('error', () => storage.close());
    stream.pipe(res);
  } catch (error) {
    res.status(500).json({ error: `MEGA download error: ${error.message}` });
  }
});

app.post('/api/upload-pdf', upload.single('pdfFile'), async (req, res) => {
  try {
    const { email, password, fileName } = req.body;
    if (!email || !password || !req.file || !fileName) {
      return res.status(400).json({ error: 'Chybí data pro upload.' });
    }

    const storage = await openStorage(email, password);
    const rs = Readable.from(req.file.buffer);

    await new Promise((resolve, reject) => {
      storage.upload({ name: fileName, size: req.file.size }, rs, (err) => {
        if (err) return reject(err);
        resolve();
      });
    });

    storage.close();
    res.json({ ok: true, message: 'PDF nahráno do MEGA.' });
  } catch (error) {
    res.status(500).json({ error: `MEGA upload error: ${error.message}` });
  }
});

app.listen(PORT, () => {
  console.log(`Server běží na http://localhost:${PORT}`);
});
