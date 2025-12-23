// server.js
// Simple Express proxy for a Hugging Face Space predict endpoint
// Run: node server.js

const express = require('express');
const multer = require('multer');
const fs = require('fs');
const fetch = require('node-fetch');
const path = require('path');
require('dotenv').config();
const cors = require('cors');

const app = express();
app.use(cors());
const upload = multer({ dest: 'uploads/' });

const HF_OWNER = process.env.HF_SPACE_OWNER;
const HF_SPACE = process.env.HF_SPACE_NAME;
const HF_TOKEN = process.env.HF_TOKEN || '';
const PORT = process.env.PORT || 5000;

function fileToBase64(path) {
  const b = fs.readFileSync(path);
  return b.toString('base64');
}

app.post('/tryon', upload.fields([{ name: 'person' }, { name: 'garment' }]), async (req, res) => {
  try {
    if (!req.files || !req.files.person || !req.files.garment) {
      return res.status(400).json({ error: 'person and garment required' });
    }
    const personPath = req.files.person[0].path;
    const garmentPath = req.files.garment[0].path;

    const personB64 = fileToBase64(personPath);
    const garmentB64 = fileToBase64(garmentPath);

    // Build payload (this MUST match the target Space's expected input)
    const payload = {
      data: [
        `data:image/jpeg;base64,${personB64}`,
        `data:image/png;base64,${garmentB64}`
      ]
    };

    const url = `https://huggingface.co/spaces/${HF_OWNER}/${HF_SPACE}/+/api/predict/`;
    const headers = { 'Content-Type': 'application/json' };
    if (HF_TOKEN) headers['Authorization'] = `Bearer ${HF_TOKEN}`;

    const hfResp = await fetch(url, { method: 'POST', headers, body: JSON.stringify(payload) });

    const text = await hfResp.text();
    let json;
    try {
      json = JSON.parse(text);
    } catch (e) {
      // sometimes spaces return HTML or text on error
      return res.status(500).json({ error: 'HF space returned non-JSON', details: text });
    }

    // Example: json = { data: [ "data:image/png;base64,..." ] }
    const result = json?.data?.[0];
    // Cleanup uploaded files
    fs.unlinkSync(personPath);
    fs.unlinkSync(garmentPath);

    if (!result) return res.status(500).json({ error: 'Unexpected response from HF', raw: json });

    return res.json({ result });
  } catch (err) {
    console.error('server error', err);
    return res.status(500).json({ error: 'server error', details: err.toString() });
  }
});

app.listen(PORT, () => console.log(`Server running on http://localhost:${PORT}`));
