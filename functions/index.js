const functions = require('firebase-functions');
const admin = require('firebase-admin');

const express = require('express');

admin.initializeApp();
const db = admin.firestore();

const ReportApp = express();
const FetchApp = express();

// Routes
ReportApp.post('/', (req, res) => {
  let msg = req.body['message'];

  admin.firestore().collection('messages').add({original: msg});
  res.json({result: `Message ${msg} added to Firestore.`});
});


FetchApp.get('/', (req, res) => {
  res.send("Empty get request success");
});


// Export function
exports.report = functions.https.onRequest(ReportApp);
exports.fetch = functions.https.onRequest(FetchApp);
