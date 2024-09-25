const fs = require("fs");
const path = require("path");

const logging_start_datetime = new Date();
const logs_path = path.join(process.cwd(), "logs");
const file_paths = [
    path.join(logs_path, "latest"),
    path.join(logs_path, (() => {
        const datetime = logging_start_datetime.toISOString().split("T");
        const date = datetime[0];
        const time = datetime[1].substring(0, 8);
        return `${date}.${time.replace(/:/g, "-")}.log`;
    })())
];
if (!fs.existsSync(logs_path))
{
    fs.mkdirSync(logs_path);
}

function printFileWriteError(error) {
    if (error)
    {
        console.error("Logging error:", error);
    }
}

for (const file of file_paths) {
    fs.writeFile(file, "Sketchbook logging started at " + logging_start_datetime.toISOString() + "\n\n", printFileWriteError);
}


module.exports = {
    message: function (category, ...message) {
        console.log(`[${category}]`, ...message);
        for (const file of file_paths)
        {
            fs.appendFile(file, `[${category}] ${message.join(" ")}\n`, printFileWriteError);
        }
    },
    error: function (category, ...message) {
        console.error(`{${category}}`, ...message);
        for (const file of file_paths)
        {
            fs.appendFile(file, `{${category}} ${message.join(" ")}\n`, printFileWriteError);
        }
    }
};
