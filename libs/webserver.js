const fs = require("fs");
const http = require("http");
const path = require("path");
const config = require(path.join(process.cwd(), "libs/config.js"));
const log = require(path.join(process.cwd(), "libs/log.js"));

var endpoints = {};

log.message("webserver", "Loading endpoints...");

for (const item of fs.readdirSync(path.join(process.cwd(), "endpoints"), {withFileTypes: true, recursive: true}))
{
    if (item.isFile()) {
        const module = require(path.join(item.parentPath, item.name));
        if ("register_endpoints" in module) {
            module.register_endpoints(endpoints);
        }
    }
}

const requestListener = async function (req, res) {
    try {
        log.message("webserver", "[Request] ", req.method, req.url);
        var url_split = req.url.split("?")
        const url_page = url_split.shift();
        const url_query = url_split.shift();
        if (url_page !== "/" && url_page.endsWith("/"))
        {
            res.writeHead(302, {
                "Location": url_page.replace(/\/+$/, "") + (url_query ? "?" + url_query : "")
            });
            res.end();
        }
        else
        {
            if (url_page in endpoints)
            {
                await endpoints[url_page](req, res);
            }
            else
            {
                var handled = false;
                for (const key of Object.keys(endpoints))
                {
                    if (key.length < 3 || !key.startsWith("/") || !key.endsWith("/")) {
                        continue;
                    }
                    const re = key.substring(1, key.length - 1);
                    if (url_page.match(RegExp(re)))
                    {
                        handled = await endpoints[key](req, res);
                        if (handled)
                        {
                            break;
                        }
                    }
                }
                if (!handled)
                {
                    res.writeHead(404);
                    res.end("<body><h1>Page not found</h1><h2><a href=\"/\">Return Home</a></h2></body>");
                }
            }
        }
        log.message("webserver", "[Response]", req.method, req.url, "->", res.statusCode);
    } catch (e) {
        try {
            res.writeHead(502);
            res.end("Internal server error... Contact server host or try again later.");
        } catch {
            log.error("webserver", "Failed to send 502 for request:", req.url);
        }
        log.error("webserver", "[Response]", req.method, ":", req.url, "->", res.statusCode, "\n\n", e);
    }
};

log.message("webserver", "Endpoint count: ", Object.keys(endpoints).length);

module.exports = {
    endpoints: endpoints,
    start: () => {
        const server = http.createServer(requestListener);
        server.on("error", e => {
            log.error("webserver", "Server error:", e.code);
            if (e.code == "EACCES")
            {
                log.error("webserver", "Failed to start webserver... Perhaps the port", config.webserver.port, "is already in use?");
            }
        });
        server.listen(config.webserver.port, config.webserver.ip, () => {
                log.message("webserver", `Server is running on http://${config.webserver.ip}:${config.webserver.port}`);
            });
    }
};
