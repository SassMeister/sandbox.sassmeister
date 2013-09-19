document.addEventListener('DOMContentLoaded', function() { 

  parent.postMessage('Bring it.', '*'); 
});

onmessage = function (event) {
  if (event.origin === 'http://<%= APP_DOMAIN %>') {
    var info = JSON.parse(event.data);

    if(info.css) { document.querySelector('style').textContent = info.css; }

    if(info.html) { document.body.innerHTML = info.html; }
  }
};