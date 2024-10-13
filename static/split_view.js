var handle_ratio = 0.5;
var horizontal_layout = true;
function onResize() {
    const aspect = window.innerWidth / window.innerHeight;
    if (aspect > 1.15)
    {
        $("#main-split>.handle").css("width", "");
        $("#main-split #code-editor").css("height", "");
        horizontal_layout = true
        $("#main-split").addClass("flex-h").removeClass("flex-v");
    }
    else if (aspect < 0.85)
    {
        $("#main-split>.handle").css("height", "");
        $("#main-split #code-editor").css("width", "");
        horizontal_layout = false;
        $("#main-split").addClass("flex-v").removeClass("flex-h");
    }
    const split_height = $("#main-split").height();
    const split_width = window.innerWidth;
    if (horizontal_layout)
    {
        $(".flex-h>#code-editor").width((window.innerWidth - 12) * handle_ratio);
    }
    else
    {
        $(".flex-v>#code-editor").height((split_height - 12) * handle_ratio);
    }
}
$(window).resize(onResize);
onResize();

var dragging_handle = false;
const handle = $(".handle");
handle.on("mousedown", mouse_event => {
    if (dragging_handle || mouse_event.button != 0)
    {
        return;
    }
    dragging_handle = true;
    $("body").addClass("no-select");
});
document.onmouseup = mouse_event => {
    if (!dragging_handle || mouse_event.button != 0)
    {
        return;
    }
    dragging_handle = false;
    $("body").removeClass("no-select");
};
document.onmousemove = mouse_event => {
    if (!dragging_handle)
    {
        return;
    }
    mouse_event = mouse_event || window.event;
    const min_size = 300;
    if (horizontal_layout)
    {
        const mouse_position = Math.max(min_size, Math.min(window.innerWidth - min_size, mouse_event.clientX));
        handle_ratio = (mouse_position - handle.width() * 0.5) / (window.innerWidth - handle.width());
    }
    else
    {
        const mouse_position = Math.max(min_size, Math.min($("#main-split").height() - min_size, mouse_event.clientY - $("#main-split").position().top));
        handle_ratio = (mouse_position - handle.height() * 0.5) / ($("#main-split").height() - handle.height());
    }
    onResize();
};
