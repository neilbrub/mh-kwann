const functions = require('firebase-functions');
const admin = require('firebase-admin');

const express = require('express');

admin.initializeApp();
const db = admin.firestore();

const ReportApp = express();
const FetchApp = express();

// Routes
ReportApp.post('/', (req, res) => {
  let report = {
    location: req.body['location'],
    timestamp: req.body['time'],
    naloxoneAdministered: req.body['naloxone'],
    comments: req.body['comments']
  }

  admin.firestore().collection('reports').add({original: report});
  res.json({result: `report for ${report.timestamp} added to Firestore.`});
});


FetchApp.get('/', (req, res) => {
  res.send("Empty get request success");
});


// Export function
exports.report = functions.https.onRequest(ReportApp);
exports.fetch = functions.https.onRequest(FetchApp);
