# mh-kwann
MedHacks 2020 - Enabling Physicians to improve opioid response plans through aggregated First Responder data.

### What's goin on here?
```
   {Firestore}
      ^    |
      |    v
 {Cloud functions}
      ^    |
   report fetch
      |    v
 {Client (Flutter)}
```

### Dev Setup
#### Dashboard Web App (Plotly Dash)
<i>In client directories (`reporter`)</i><br />

i. The following commands can be done more easily if in a virtual environment (like conda) so it highly recommended to install [Anaconda](https://www.anaconda.com/distribution/) beforehand.<br />
i (cont). With Anaconda installed, open up the command line and enter: `conda create --name py3 python=3.6` to create a new virtual env and enter `conda activate py3` to start using it.<br />
ii. Navigate to the correct folder and install the dependencies with the following command: `pip install -r requirements.txt`<br />
iii. Use the following command to start the app on a local server: `python app.py`<br />


#### Frontend (Flutter)
<i>In client directories (`reporter`)</i><br />

i. [Install](https://flutter.dev/docs/get-started/install) Flutter<br />
ii. Ensure Android SDK is installed (install [Android Studio](https://developer.android.com/studio) if necessary)<br />
iii. Run `flutter doctor` to check if dev environment is good (shouldn't need to worry about Android Studio or vscode checklist)<br />
iv. Connect device / emulator and run `flutter devices` to check if connection is good<br />
v. Execute `flutter run` and let it build - should open on phone / emulator and hot-reload any code changes.<br />

#### Backend (Firebase)
`npm install -g firebase-tools`

At the moment it's unclear how you can set firebase up locally to point to the firebase instance on Neil's Google account... But that hopefully shouldn't be necessary for local testing.

All the API stuff is in `functions/index.js`. In the `functions` folder run `firebase emulators:start` and open localhost:4000 for a sweet dashboard. To test out endpoints I'd suggest using [Postman](https://www.postman.com).<br /><br />
If firebase is being too Google-y and insisting you have to link it locally to an account (ie can't find my mh-kwann project), follow [this](https://firebase.google.com/docs/functions/get-started) tutorial to spin up your own firebase account, but -- try to keep any code changes that induces out of git please!!
