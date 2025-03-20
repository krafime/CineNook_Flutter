// Bootstrap script for Flutter web app

// Make sure DOM is loaded before initializing Flutter
window.addEventListener("load", function () {
  // This is to ensure Flutter engine has a valid target
  if (!document.getElementById("flutter_target")) {
    console.warn("Flutter target element not found, creating one");
    const target = document.createElement("div");
    target.id = "flutter_target";
    document.body.appendChild(target);
  }

  // Function to load the main.dart.js file
  const loadMainDartJs = function () {
    const scriptTag = document.createElement("script");
    scriptTag.src = "main.dart.js";
    scriptTag.type = "application/javascript";
    document.body.appendChild(scriptTag);
  };

  // Load main.dart.js
  loadMainDartJs();
});
