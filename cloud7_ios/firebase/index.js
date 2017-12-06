
// The Cloud Functions for Firebase SDK to create Cloud Functions and setup triggers.
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const speech = require('@google-cloud/speech')
admin.initializeApp(functions.config().firebase);

const projectId = 'Cloud7'

const client = new speech.SpeechClient({
  projectId: projectId
})

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

      const config = {
        encoding: 'LINEAR16',
        sampleRateHertz: 8000,
        languageCode: 'en-US'
      }

      const audio = {
        content: data
      }

      var request = {
        config: config,
        audio: audio,
      }

      client.recognize(request)
        .then(data => {
          console.log("BASE 64 START")
          const response = data[0];
          const transcription = response.results
            .map(result => result.alternatives[0].transcript)
            .join('\n');
          console.log(`Transcription: ${transcription}`);
          console.log('Got something from cloud ^^')
          console.log("BASE 64 END")
        })
        .catch(err => {
          console.error(err);
        });
      const retVal = "Translation: "
      return event.data.ref.parent.child('return_value').set(retVal).then(snapshot => {
            res.redirect(303,snapshot.ref);
      });

});

    // This will get called when we upload our wav file to the cloud storage.
    exports.handleWaveFile = functions.storage.object().onChange(event => {
        console.log("item uploaded to cloud storage")
        const object = event.data; // The Storage object.
        const fileBucket = object.bucket; // The Storage bucket that contains the file.
        const filePath = object.name; // File path in the bucket.
        const contentType = object.contentType; // File content type.
        const resourceState = object.resourceState; // The resourceState is 'exists' or 'not_exists' (for file/folder deletions).
        const metageneration = object.metageneration; // Number of times metadata has been generated. New objects have a value of 1.
        
        console.log(object)

        const config = {
          encoding: 'LINEAR16',
          sampleRateHertz: 8000,
          languageCode: 'en-US'
        }
  
        const audio = {
          uri: "gs://microp-audio.appspot.com/audio/recording.wav"
        }
  
        var request = {
          config: config,
          audio: audio,
        }

        var transcript = client.recognize(request)
        .then(data => {
          console.log("CLOUD BUCKET START")
          const response = data[0];
          const transcription = response.results
            .map(result => result.alternatives[0].transcript)
            .join('\n');
          console.log(`Transcription: ${transcription}`);
          console.log("CLOUD BUCKET END")
        })
        
       
        //Then write to the database
        var db = admin.database()
        var ref = db.ref('/audio/USER123/cloudData')
        ref.child.set({
          audio: transcript
        });

        

        
    });