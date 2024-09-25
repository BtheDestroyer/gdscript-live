const log = require("./libs/log.js");
log.message("program", "Starting program...");

const webserver = require("./libs/webserver.js");

function exitHandler(reason) {
    log.message("program", "Progam exit:", reason);
    process.exit();
}
process.on("exit", exitHandler.bind("exit"));
process.on("SIGINT", exitHandler.bind("SIGINT"));
process.on("SIGUSR1", exitHandler.bind("SIGUSR1"));
process.on("SIGUSR2", exitHandler.bind("SIGUSR2"));
process.on("uncaughtException", exitHandler.bind("uncaughtException"));
webserver.start();
log.message("program", "Setup complete!")
