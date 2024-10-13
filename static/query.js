const query_params = location.search.substr(1).split("&").reduce((a, c) => {
        const kvp_split = c.indexOf("=");
        const [key, value] = (kvp_split != -1 ? [c.substr(0, kvp_split), c.substr(kvp_split + 1)] : [c, undefined]);
        a[key] = decodeURIComponent(value);
        return a;
    }, {});
