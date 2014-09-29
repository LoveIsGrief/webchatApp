require("coffee-script/register");

var express = require("express"),
  config = require("./config/config");

var app = express();

require("./config/express")(app, config);

var http = require("http").Server(app);
var io = require("socket.io")(http)

// configure socket.io
require("./config/socket")(app, io);

http.listen(config.port);

