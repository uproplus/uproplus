'use strict';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "index.html": "b71b25ade326165fef7a014d7e803e0e",
"/": "b71b25ade326165fef7a014d7e803e0e",
"main.dart.js": "485bcaeb710c76db1ce0adacd8faf418",
"assets/LICENSE": "2975d8bef793c0b2dd38b864f3190d70",
"assets/AssetManifest.json": "fa06965eda196d5c94ec158ecd300b2e",
"assets/FontManifest.json": "01700ba55b08a6141f33e168c4a6c22f",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "9a62a954b81a1ad45a58b9bcea89b50b",
"assets/fonts/MaterialIcons-Regular.ttf": "56d3ffdef7a25659eab6a68a3fbfaf16",
"assets/assets/icons/logout.png": "d7cd2e70bcbf770e8b1f9c1b06778fef",
"assets/assets/icons/logo_upro.png": "ddd25d7a3ad10b985994b16cf5c79993",
"assets/assets/icons/change_plan.png": "4fc19900382788e6d7fb8965a4708188"
};

self.addEventListener('activate', function (event) {
  event.waitUntil(
    caches.keys().then(function (cacheName) {
      return caches.delete(cacheName);
    }).then(function (_) {
      return caches.open(CACHE_NAME);
    }).then(function (cache) {
      return cache.addAll(Object.keys(RESOURCES));
    })
  );
});

self.addEventListener('fetch', function (event) {
  event.respondWith(
    caches.match(event.request)
      .then(function (response) {
        if (response) {
          return response;
        }
        return fetch(event.request);
      })
  );
});
