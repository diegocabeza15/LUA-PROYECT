window.addEventListener('message', function (event) {
    if (event.data.type === "showCommands") {
        document.getElementById("comandos").innerHTML = event.data.commands;
        document.getElementById("modal").classList.remove('hidden')
        setTimeout(function () {
            window.dispatchEvent(new MessageEvent('message', { data: { type: 'close' } }));
        }, 1000);
    } else if (event.data.type === "close") { // Añadir manejo para el cierre
        document.getElementById("modal").classList.add('hidden'); // Ocultar el modal
    }
});

// Crear un botón para cerrar el panel
const closeButton = document.querySelector('#closeButton')
closeButton.onclick = function () {
    window.dispatchEvent(new MessageEvent('message', { data: { type: 'close' } }));
};
