const path = require("path");
const config = require(path.join(process.cwd(), "libs/config.js"));

module.exports = {
    getParams: async function(req) {
        if ("params" in req) {
            return req.params;
        }
        req.params = {};
        if (req.method === "GET") {
            var url = req.url.split("?");
            const url_page = url.shift();
            const url_params = url.shift();
            if (url_params)
            {
                for (const url_param of url_params.split("&"))
                {
                    var split_param = url_param.split("=");
                    const k = split_param.shift();
                    const v = split_param.join("=");
                    req.params[k] = v !== undefined ? decodeURIComponent(v) : null;
                }
            }
        }
        else if (req.method === "POST") {
            return new Promise((resolve, reject) => {
                var body = "";
                req.on("data", chunk => {
                    body += chunk;
                    if (body.length > 1e6)
                    {
                        req.connection.destroy();
                        body = "";
                        reject();
                    }
                });
                req.on("end", () => {
                    for (const url_param of body.split(/[&\n]/))
                    {
                        var split_param = url_param.split("=");
                        const k = split_param.shift();
                        const v = split_param.join("=");
                        req.params[k] = v !== undefined ? decodeURIComponent(v) : null;
                    }
                    resolve(req.params);
                });
            });
        }
        return req.params;
    },
    sendResponse: function(res, code, data) {
        res.writeHead(code, {"Content-Type": "application/json"});
        res.end(JSON.stringify(data, undefined, 2));
    },
    keyIsValid: function(key) {
        return this.key == key || key in config.api.permitted_keys;
    }
};
