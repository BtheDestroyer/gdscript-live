const { exec } = require("child_process");
const fs = require("fs");
const path = require("path");
const util = require("util");
const api = require(path.join(process.cwd(), "libs/api.js"));
const config = require(path.join(process.cwd(), "libs/config.js"));

const execAsync = util.promisify(exec);

module.exports = {
    register_endpoints: async endpoints => {
        endpoints["/api/versions"] = async (req, res) => {
            try {
                const {stdout, stderr} = await execAsync(`docker images | grep -e "^gdscript-live/godot\\s" | grep -ve "\\sbase\\s"`);
                api.sendResponse(res, 200, {error:"", versions:`${stdout}`
    .split("\n")
    .map(line => line.substr("gdscript-live/godot".length).trim())
    .map(line => line.substr(0, line.indexOf(' ')))
    .filter(line => line.trim().length > 0)});
            }
            catch (error)
            {
                api.sendResponse(res, 502, {error:"Failed to get available versions"});
            }
            return true;
        };
    }
};
