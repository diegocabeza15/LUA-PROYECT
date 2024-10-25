window.addEventListener('message', function (event) {
    if (event.data.type === "showCommands") {
        document.getElementById("comandos").innerText = event.data.commands;
    }
});