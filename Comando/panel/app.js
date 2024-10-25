window.addEventListener('message', function (event) {
    if (event.data.type === "showCommands") {
        document.getElementById("comandos").innerHTML = event.data.commands; // Cambiado a innerHTML para permitir etiquetas HTML

        // Cerrar el panel automáticamente después de 5 segundos
        setTimeout(function () {
            // Enviar un mensaje para cerrar el panel
            window.dispatchEvent(new MessageEvent('message', { data: { type: 'close' } }));
        }, 5000); // 5000 milisegundos = 5 segundos
    }
});

// Crear un botón para cerrar el panel
const closeButton = document.querySelector('#closeButton')
closeButton.onclick = function () {
    window.dispatchEvent(new MessageEvent('message', { data: { type: 'close' } }));
};
