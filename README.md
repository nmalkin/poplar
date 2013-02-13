Poplar
======
Poplar is a web application that turns any webpage into a [Mozilla App](http://developer.mapquest.com/web/products/open/map).

Turning a webpage into a Mozilla App requires an [app manifest](https://developer.mozilla.org/en-US/docs/Apps/Manifest) and for the page to be served from its own (sub)domain. Poplar provides both, serving the desired page from an iframe on a subdomain unique to the domain on which Poplar is running (specified in `config.json`).

Setup
-----
You'll need [CoffeeScript](http://coffeescript.org/) to compile the source of the server:

    coffee -c poplar.coffee

Execution
---------
Poplar runs on [node.js](http://nodejs.org/):

    node poplar.js

The server will be running on the port number specified by $PORT in the environment or on port 8111 by default.
