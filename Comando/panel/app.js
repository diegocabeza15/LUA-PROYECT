window.addEventListener('message', function (event) {
    if (event.data.type === "showCommands") {
        document.getElementById("comandos").innerText = event.data.commands;

        // Cerrar el panel automáticamente después de 5 segundos
        setTimeout(function () {
            // Enviar un mensaje para cerrar el panel
            window.dispatchEvent(new MessageEvent('message', { data: { type: 'close' } }));
        }, 5000); // 5000 milisegundos = 5 segundos
    }
});
