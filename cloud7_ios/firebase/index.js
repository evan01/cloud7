// The Cloud Functions for Firebase SDK to create Cloud Functions and setup triggers.
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);


//Takes our bluetooth data and adds it to the realtime firebase database
exports.uploadAudio = functions.https.onRequest((req, res) => {
  const original = req.query.text;// Grab the text parameter. APIENDPOINT?text=whateveryouwant
  // Push the new message into the Realtime Database using the Firebase Admin SDK.
});

// exports.writeAudio = functions.database.onWrite(('/audio/{pushId}/write'))

// When new data is uploaded to the realtime database... then we process/return it.
exports.processAudio = functions.database.ref('/audio/USER123/data2')
    .onUpdate(event => {
      const data = event.data.val();// Grab the current value of what was written to the Realtime Database.
      console.log('Audio: '+ data);
      const retVal = "The data was: " + data;
      return event.data.ref.parent.child('return_value').set(retVal).then(snapshot => {
          res.redirect(303,snapshot.ref);
      });
    });
