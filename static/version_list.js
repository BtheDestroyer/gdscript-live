async function updateVersionList() {
    try
    {
        const response = await fetch("/api/versions");
        if (!response.ok)
        {
            throw new Error(`Response status: ${response.status}`);
        }
        const json = await response.json();
        const select = $("select#godot-version");
        select.empty();
        for (const version of json["versions"])
        {
            select.append(`<option value="${version}">${version}</option>`);
            if ("godot_version" in query_params && version == decodeURIComponent(query_params["godot_version"]))
            {
                select.val(version);
            }
        }
    }
    catch (error)
    {
        console.error(error);
    }
}
updateVersionList();
