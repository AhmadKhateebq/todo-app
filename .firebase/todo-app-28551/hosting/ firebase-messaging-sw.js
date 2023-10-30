importScripts("https://www.gstatic.com/firebasejs/7.15.5/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/7.15.5/firebase-messaging.js");

//Using singleton breaks instantiating messaging()
// App firebase = FirebaseWeb.instance.app;


firebase.initializeApp({
  apiKey: 'AIzaSyBTG2QXGepxNeQJAJUQMID1Ez33I83KKwo',
  authDomain: 'todo-app-28551.firebaseapp.com',
  databaseURL: 'https://todo-app-28551-default-rtdb.europe-west1.firebasedatabase.app',
  projectId: 'todo-app-28551',,
  storageBucket: 'todo-app-28551.appspot.com',
  messagingSenderId: '938312015413',
  appId: '1:938312015413:web:a475d2755cb78bb9421b7c',
  measurementId: 'G-BT39H3S4FK',
});








const messaging = firebase.messaging();
messaging.setBackgroundMessageHandler(function (payload) {
    const promiseChain = clients
        .matchAll({
            type: "window",
            includeUncontrolled: true
        })
        .then(windowClients => {
            for (let i = 0; i < windowClients.length; i++) {
                const windowClient = windowClients[i];
                windowClient.postMessage(payload);
            }
        })
        .then(() => {
            return registration.showNotification("New Message");
        });
    return promiseChain;
});
self.addEventListener('notificationclick', function (event) {
    console.log('notification received: ', event)
});