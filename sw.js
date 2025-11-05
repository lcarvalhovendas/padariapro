self.addEventListener('install',e=>{self.skipWaiting()});
self.addEventListener('activate',e=>{self.clients.claim()});
self.addEventListener('fetch',e=>{e.respondWith((async()=>{try{return await fetch(e.request)}catch{return new Response('offline',{status:200,headers:{'Content-Type':'text/plain'}})} })())});
