const path = require("path");
const api = require(path.join(process.cwd(), "libs/api.js"));
const config = require(path.join(process.cwd(), "libs/config.js"));

module.exports = {
    register_endpoints: endpoints => {
        endpoints["/api/echo"] = async (req, res) => {
            const params = await api.getParams(req);
            api.sendResponse(res, 200, {error:"", params: params})
            return true;
        }
    }
};
