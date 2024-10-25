window.addEventListener('message', function (event) {
    let closeTimeout;
    if (event.data.type === "showCommands") {
        document.getElementById("comandos").innerHTML = event.data.commands;
        document.getElementById("modal").classList.remove('hidden');
    }

    if (event.data.type === "close") {
        clearTimeout(closeTimeout); // Limpiar el timeout al cerrar
        document.getElementById("modal").classList.add('hidden');
        return window.dispatchEvent(new MessageEvent('message', { data: { type: 'focusLost' } }));
    }
    if (event.data.type === "focusLost") {
        document.body.style.backgroundColor = 'rgba(0, 0, 0, 0)';
    }
});

// Añadir un evento para el botón de cerrar
const modal = document.querySelector("section")
const closeButton = document.querySelector('#closeButton');
closeButton.addEventListener('click', (e) => {
    window.dispatchEvent(new MessageEvent('message', { data: { type: 'close' } })); // Llamar al evento de cierre
    modal.classList.add("hidden")
});
