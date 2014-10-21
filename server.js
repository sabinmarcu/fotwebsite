require("coffee-script/register"); // Fix for Coffee-Script 1.7
require("LiveScript"); // Fix for LiveScript
var debug = require("debug")("app:Bootstrap");
	debug.error = require("debug")("app:Bootstrap:Error");
	debug.error.log = console.error.bind(console);
var args   = new (require("cliparser"))(process.argv).link({
		"-v": "--version",
		"-h": "--help",
		"-c": "--compile",
		"-p": "--port",
		"-a": "--address",
		"-s": "--static",
		"-l": "--location",
		"-b": "--bundle",
		"-V": "--verbose",
		"-w": "--watch"
	}).booleanify()["doubleDashArgs"];
debug("Got startup arguments", args);
require("nodetime").profile({
	accountKey: "295cb94fab52d4b9e41559d455804bee11a3f24f",
	appName: "ISRotterdam"
});

process.comp_args = args;

if (args.version) {
	var info = require("./package.json")
	console.log(info.version);
} else if (args.help) {
	var info = require("./package.json");
	require("./server/help")(info)
} else {
	var Compiler = null, Static = null, json = require("./package.json");
	if (args.compile) {
		var location = args.location || __dirname + "/public"
		if (location[location.length - 1] !== "/") location += "/"
		var jsLocation = location + "js/" + json.name + ".js",
			cssLocation = location + "css/styles.css"
		Compiler = require("./server/compiler");
		Compiler.setAttribute("bundle", args.bundle);
		Compiler.setAttribute("verbose", args.verbose);
		try {
			Compiler.compile(jsLocation, function(error, source) {
				if (error) debug.error(error);
				else debug("Compiled");
				process.exit(0);
			});
		} catch (e) {
			debug.error(e);
			process.exit(1);
		}
		if (args.location) return;
	}
	if (args.static) {
		var data = {};
		data.address = args.address || process.env.IP || "0.0.0.0"
		data.port    = args.port || process.env.PORT || "8080"

		var Static = require("./server/static"),
			server = new Static(data, args.watch, args.bundle);
		if (Compiler !== null) server.connect(Compiler);
		server.start()
	}
}
