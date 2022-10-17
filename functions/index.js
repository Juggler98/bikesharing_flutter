const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });


exports.reportNotify = functions.https.onRequest((req, res) => {
  console.log(req);
  const userId = req.userId;
  db.doc("users/" + userId).get().then((userDoc) => {
    if (userDoc.data() == null || userDoc.data().tokens == null) {
      return res.send("done");
    }
    const messageBody = userId + " reported bike " + req.bikeId;
    admin.messaging().sendToDevice(userDoc.data().tokens, {
      notification: {
        title: "Bikesharing - ADMIN",
        body: messageBody,
      },
      data: {
        "bikeId": req.bikeId,
        "body": messageBody,
      },
    }).then(() => {
      res.send("done");
    });
  });
});

exports.reportNotify2 = functions.https.onCall((data, context) => {
  console.log(data);
  const userId = data[0];
  const bikeId = data[1];
  console.log(userId);
  return db.doc("users/" + userId).get().then((userDoc) => {
    if (userDoc.data() == null || userDoc.data().tokens == null) {
      return;
    }
    const messageBody = userId + " reported bike " + bikeId;
    console.log(messageBody);
    return admin.messaging().sendToDevice(userDoc.data().tokens, {
      notification: {
        title: "Bikesharing - ADMIN",
        body: messageBody,
      },
      data: {
        "bikeId": bikeId,
        "body": messageBody,
      },
    });
  });
});
