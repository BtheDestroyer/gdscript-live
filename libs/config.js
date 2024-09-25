const fs = require("fs");
const path = require("path");
const yaml = require("yaml");

const PATH = path.join(process.cwd(), "config.yaml");
const DEFAULT = {
    webserver: {
        ip: "0.0.0.0",
        port: 8090
    }
};

function isObject(x) {
    return (x && typeof x === "object" && !Array.isArray(x));
}

function merge(target, ...sources) {
    if (!sources.length)
    {
        return target;
    }
    const source = sources.shift();

    if (isObject(target) && isObject(source))
    {
        for (const key in source)
        {
            if (isObject(source[key]))
            {
                if (!target[key])
                {
                    Object.assign(target, { [key]: {} });
                }
                merge(target[key], source[key]);
            }
            else
            {
                Object.assign(target, { [key]: source[key] })
            }
        }
    }

    return merge(target, ...sources);
}

function clone() {
    var config = {};
    for (const k of Object.keys(module.exports))
    {
        if (typeof this[k] !== "function")
        {
            config[k] = structuredClone(module.exports[k]);
        }
    }
    return config;
}

function save() {
    fs.writeFileSync(PATH, yaml.stringify(module.exports.clone()), "utf-8");
}

function reload() {
    if (fs.existsSync(PATH))
    {
        var config_file = yaml.parse(fs.readFileSync(PATH, "utf-8"));
        config_file = merge(DEFAULT, config_file);
        config_file.save = save;
        config_file.clone = clone;
        module.exports = config_file;
    }
    else
    {
        module.exports = {...DEFAULT, save, clone};
        console.log("program", "Creating default config...");
    }
    save();
}
reload();

