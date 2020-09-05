# mh-kwann
MedHacks 2020 - Enabling Physicians to improve opioid response plans through aggregated First Responder data.

### Dev Setup
#### Frontend (Flutter)
<i>In client directories (`reporter`)</i><br />

i. [Install](https://flutter.dev/docs/get-started/install) Flutter<br />
ii. Ensure Android SDK is installed (install [Android Studio](https://developer.android.com/studio) if necessary)<br />
iii. Run `flutter doctor` to check if dev environment is good (shouldn't need to worry about Android Studio or vscode checklist)<br />
iv. Connect device / emulator and run `flutter devices` to check if connection is good<br />
v. Execute `flutter run` and let it build - should open on phone / emulator and hot-reload any code changes.<br />

#### Backend (Firebase)
`npm install -g firebase-tools`

<p>At the moment it's unclear how you can set firebase up locally to point to the firebase instance on Neil's Google account... But that hopefully shouldn't be necessary for local testing.</p>
All the API stuff is in `functions/index.js`. In the `functions` folder run `firebase emulators:start` and open localhost:4000 for a sweet dashboard. To test out endpoints I'd suggest using [Postman](https://www.postman.com).<br /><br />
If firebase is being too Google-y and insisting you have to link it locally to an account (ie can't find my mh-kwann project), follow [this](https://firebase.google.com/docs/functions/get-started) tutorial to spin up your own firebase account, but <i>try to keep any code changes that induces out of git please!</i>