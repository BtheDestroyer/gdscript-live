const { exec } = require("child_process");
const crypto = require("crypto");
const fs = require("fs");
const path = require("path");
const util = require("util");
const api = require(path.join(process.cwd(), "libs/api.js"));
const config = require(path.join(process.cwd(), "libs/config.js"));

function make_id(length) {
    var id = "";
    const characters = "0123456789abcdef";
    while (id.length < length)
    {
        id += characters.charAt(Math.floor(Math.random() * characters.length));
    }
    return id;
}

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

const execAsync = util.promisify(exec);

module.exports = {
    register_endpoints: async endpoints => {
        endpoints["/api/run"] = async (req, res) => {
            const params = await api.getParams(req);
            if (!("script" in params))
            {
                api.sendResponse(res, 400, {error:"Missing 'script' parameter"});
                return true;
            }
            if (!("godot_version" in params))
            {
                api.sendResponse(res, 400, {error:"Missing 'godot_version' parameter"});
                return true;
            }
            if (params["godot_version"] == "base" || /\s/g.test(params["godot_version"]))
            {
                api.sendResponse(res, 400, {error:"Invalid 'godot_version' parameter", godot_version: params["godot_version"]});
                return true;
            }
            try {
                const {stdout, stderr} = await execAsync(`docker images | grep -e "^gdscript-live/godot\\s" | grep -e "\\s${params["godot_version"]}\\s"`);
            }
            catch (error)
            {
                api.sendResponse(res, 400, {error:"Invalid 'godot_version' parameter", godot_version: params["godot_version"]});
                return true;
            }
            const script_hash = crypto.createHash("sha256").update(params["script"] + params["godot_version"]).digest("hex");
            var dir = `/tmp/gdscript.live/finished-${script_hash}`;
            if (fs.existsSync(dir))
            {
                try
                {
                    api.sendResponse(res, 200, {error:"", script_hash, stdout: fs.readFileSync(path.join(dir, "stdout"), "utf8").toString(), stderr: fs.readFileSync(path.join(dir, "stderr"), "utf8").toString() });
                    return true;
                }
                catch (error)
                {
                    // rerun
                }
            }
            var id = make_id(16);
            dir = path.join("/tmp/gdscript.live", id);
            while (fs.existsSync(dir))
            {
                id = make_id(16);
                dir = path.join("/tmp/gdscript.live", id);
            }
            fs.mkdirSync(dir, {recursive: true});
            const script_contents = Buffer.from(params["script"], "base64").toString("utf8")
            fs.writeFileSync(path.join(dir, "script.gd"), script_contents);
            var container_id = "";
            try
            {
                const command = `docker run -d --cpus="0.5" --memory=256m --network=none -v "${dir}:/mnt/user/" "gdscript-live/godot:${params["godot_version"]}"`;
                const {stdout, stderr} = await execAsync(command);
                container_id = `${stdout}`.trim();
            }
            catch (error)
            {
                api.sendResponse(res, 502, {error:`Error running script: ${error}`});
                return true;
            }
            const timeout_s = 30
            const stop_time = Date.now() + timeout_s * 1000;
            var finished = false;
            while (Date.now() < stop_time)
            {
                try
                {
                    const command = `docker inspect -f "{{.State.Running}}" "${container_id}"`;
                    const {stdout, stderr} = await execAsync(command);
                    const running_status = `${stdout}`.trim();
                    if (running_status == "false")
                    {
                        const {stdout, stderr} = await execAsync(`docker logs ${container_id}`);
                        api.sendResponse(res, 200, {error:"", script: script_contents, godot_version: process["godot_version"], stdout, stderr });
                        finished = true;
                        var cache_dir = `/tmp/gdscript.live/finished-${script_hash}`;
                        if (!fs.existsSync(cache_dir))
                        {
                            fs.mkdirSync(cache_dir, {recursive: true});
                        }
                        fs.writeFileSync(path.join(cache_dir, "stdout"), stdout, "utf8");
                        fs.writeFileSync(path.join(cache_dir, "stderr"), stderr, "utf8");
                        break;
                    }
                    await sleep(1000);
                }
                catch (error)
                {
                    api.sendResponse(res, 502, {error:`Error running script: ${error}`});
                    finished = true;
                }
            }
            if (!finished)
            {
                api.sendResponse(res, 502, {error:`Script timed out. Max time of ${timeout_s} seconds.`});
            }
            try
            {
                await execAsync(`docker rm -f ${container_id}`);
            }
            catch(error)
            {
                
            }
            fs.rmSync(dir, {recursive: true, force: true});
            return true;
        }
    }
};
