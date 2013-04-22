Scry Dispatcher
===============

Node app that dispatches the geolocation of requests to your website to listening clients in realtime.

Install
=======

1. npm install
2. geoip-lite requires two files to be manually copied into ./node_modules/geoip-lite/data. They are ```geoip-city.dat``` and ```geoip-city-names.dat```. They can be found at https://github.com/bluesmoon/node-geoip/tree/master/data.

Usage
=====
When your server receives a request, send an HTTP request in turn to the ```/in``` endpoint with the following parameters:
- ```ip```: The IP Adress your server received the request from.
- ```labels```: The list of labels you would like to associate the request with.
- ```data```: Any auxillary data you would like to pass through to the clients.
 
Create a client that connects to the dispatcher via websockets. The dispatcher responds to the following events:
- ```register```: Provide a list of labels that you would like to receive events for.
- ```deregister```: Provide a list of labels that you would like to stop receiving events for.

Best Practice
=============
- It's important not to block responding to the request to your server with your own request to scry. One simple approach is to just add some JavaScript to your page so that whenever it's loaded, you asynchronously make a request to Scry. Alternatively, you could queue sending the request to Scry or have a worker thread handle it on the server side.
