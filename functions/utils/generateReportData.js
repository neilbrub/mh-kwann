let axios = require('axios');

/**
 * Data format:
 * {
 *    timestamp: ,
 *    location: {
 *      lat: ,
 *      lng: ,
 *    },
 *    naloxoneAdministered: ,
 *    comments: ,
 * }
 * 
 * Data should reflect Waterloo region from 2019 to present;
 *    - There should be about 2000 total OD reports in that period
 * 
 * Location bounding:
 *    - Lat: 43.41 to 43.51
 *    - Long: -80.57 to -80.42
 */


let records = [];

// First generate uniformly-spaced events

let ms_start = 1546340400*1000;
let ms_curr = 1599355990*1000;
let step = Math.floor((ms_curr - ms_start) / 3000);

let [lat_min, lat_max] = [43.41, 43.51];
let [lng_min, lng_max] = [-80.57, -80.42];

let lat_diff = lat_max - lat_min;
let lng_diff = lng_max - lng_min;

let timestamp = ms_start;

for (let i = 0; i < 3500; i++) {
  let rand_lat = Math.random()*lat_diff + lat_min;
  let rand_lng = Math.random()*lng_diff + lng_min;
  let rand_naloxone = Math.random() < 0.9 ? 1 : 0;
  let timestampDate = new Date(timestamp);

  records.push({
    time: timestampDate.toUTCString(),
    location: {
      lat: rand_lat,
      lng: rand_lng
    },
    naloxone: rand_naloxone,
    comments: ""
  });

  timestamp = timestamp + step;
}

// Now pass over repeatedly, deleting at random intervals

for (let i = 0; i < 60; i++){
  let length = records.length;
  let j = 0;
  while (j < length) {
    j = j + Math.floor(Math.random() * 100)
    if (i * j < 30000) {
      records = [...records.slice(0, j), ...records.slice(j+1)];
    }
  }
}

let sleep = ms => {
  return new Promise(resolve => setTimeout(resolve, ms));
}


// Every elegant solution failed, so just spam the individual report endpoint :(

records.forEach(async record => {
  await axios({
    method: 'post',
    url: 'https://us-central1-mh-kwann.cloudfunctions.net/report',
    data: record,
    headers: {'Content-Type': 'application/json'}
  }).then(resp => {
    sleep(200);
  }).catch(err => {
    console.warn(err);
  });
})

