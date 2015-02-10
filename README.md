<a href="http://zenhub.io" target="_blank"><img src="https://raw.githubusercontent.com/ZenHubIO/support/master/zenhub-badge.png" height="18px" alt="Powered by ZenHub"/></a>

# Usage

The app is built using a node.js server, so the first step would be to install all npm modules

    $ npm install .

The server bit of the application will compile everything into one JS file (similar to [brunch](http://brunch.io/)).
After that, you can start the server by using the following  :

    $ DEBUG=app* node server -sVwcp 8000

for example, which will start a web server (s) in verbose mode (V – both the server and clientside will spew debug messages) with livereload started (w) and instant compiling (c – at each request, the source is again compiled) and port 8000 (p).

# Irelevant anyway
