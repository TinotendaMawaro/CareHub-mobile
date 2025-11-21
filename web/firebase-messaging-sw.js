importScripts("https://www.gstatic.com/firebasejs/10.0.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/10.0.0/firebase-messaging.js");

firebase.initializeApp({
    apiKey: "AIzaSyD8YUuyWE_WSksdpbbggMhIMWuU1KlEvNI",
    authDomain: "carehub-a5e11.firebaseapp.com",
    projectId: "carehub-a5e11",
    storageBucket: "carehub-a5e11.appspot.com",
    messagingSenderId: "8810329409",
    appId: "YOUR_WEB_APP_ID",
});

const messaging = firebase.messaging();
