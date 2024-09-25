const fs = require("fs");
const mime = require("mime-types");
const path = require("path");

module.exports = {
    register_endpoints: endpoints => {
        endpoints[/^\/static\/.+$/] = async (req, res) => {
            const url = req.url.split("?").shift();
            const requested_path = path.resolve(path.join(process.cwd(), url));
            const relative_path = path.relative(process.cwd(), url);
            if (relative_path && relative_path.startsWith("..") && !path.isAbsolute(relative_path) && fs.existsSync(requested_path))
            {
                const file_stat = fs.statSync(requested_path);
                const read_stream = fs.createReadStream(requested_path);
                res.writeHead(200, {
                        "Content-Type": mime.lookup(path.extname(requested_path)),
                        "Content-Length": file_stat.size
                    });
                read_stream.pipe(res);
                return true;
            }
            return false;
        };
        endpoints["/"] = async (req, res) => {
            const requested_path = path.resolve(path.join(process.cwd(), "static/index.html"));
            if (fs.existsSync(requested_path))
            {
                const file = fs.readFileSync(requested_path);
                res.writeHead(200);
                res.end(file);
                return true;
            }
            res.writeHead(404);
            res.end("File not found /");
            return true;
        }
        endpoints["/favicon.ico"] = async (req, res) => {
            const requested_path = path.resolve(path.join(process.cwd(), "static/favicon.ico"));
            if (fs.existsSync(requested_path))
            {
                const file = fs.readFileSync(requested_path);
                res.writeHead(200);
                res.end(file);
                return true;
            }
            res.writeHead(404);
            res.end("File not found /favicon.ico");
            return true;
        }
    }
};
