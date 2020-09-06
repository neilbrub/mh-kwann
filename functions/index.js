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

// Get all reports
FetchApp.get('/', async (req, res) => {
  const recordsRef = admin.firestore().collection('reports');
  const snapshot = await recordsRef.get();

  let reportData = []
  snapshot.forEach(async doc => {
    let data = doc.data();
    reportData.push(data.original)
  });

  res.json({reports: reportData});
});

// FetchApp.post('/', (req, res) => {
//   let timeStart = null;
//   let timeEnd = null;
//   if (req.body.hasOwnProperty('time_start')) timeStart = req.body['time_start'];
//   if (req.body.hasOwnProperty('time_end')) timeEnd = req.body['time_end'];
// })


// Export function
exports.report = functions.https.onRequest(ReportApp);
exports.fetch = functions.https.onRequest(FetchApp);
