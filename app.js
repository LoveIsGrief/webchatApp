require("coffee-script/register");

var express = require("express"),
  fs = require("fs"),
  config = require("./config/config");

var app = express();

require("./config/express")(app, config);

var http = require("http").Server(app);
var io = require("socket.io")(http)

// configure socket.io
require("./config/socket")(app, io);

http.listen(config.port, function () {
	console.log("Listening on port:" + config.port)
});

// Save the db before being killed
function handleShutdown () {
	console.log("Saving db in face of imminent death");

	fs.writeFileSync(config.db,
		JSON.stringify(app.get("chatrooms"), null, '\t')
		)
	console.log("We may die now")
	process.exit();
}

process.on("SIGINT", handleShutdown)
process.on("SIGTERM", handleShutdown)
