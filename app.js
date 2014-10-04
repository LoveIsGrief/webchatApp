require("coffee-script/register");
require("sugar")

var fs = require("fs"),
	server = require("./config/server"),
	http = server.http,
	app = server.app
	config = server.config;

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
