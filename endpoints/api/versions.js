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
                const versions = fs.readFileSync(path.join(process.cwd(), "containers/builds.txt"), {encoding: "utf-8", flag: "r"})
                    .split("\n")
                    .filter(line => line.trim().length > 0);
                api.sendResponse(res, 200, {error:"", versions});
            }
            catch (error)
            {
                api.sendResponse(res, 502, {error:`Failed to get available versions: ${error}`});
            }
            return true;
        };
    }
};
