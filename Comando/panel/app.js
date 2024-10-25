window.addEventListener("message", function (event) {
  if (event.data.type === "showCommands") {
    document.getElementById("comandos").innerHTML = event.data.commands;
    document.getElementById("modal").classList.remove("hidden");
  }
  if (event.data.type === 'close') {
    // Añadir manejo para el cierre
    document.getElementById("modal").classList.add("hidden");
    setNuiFocus(false, false) // Ocultar el modal
    return window.dispatchEvent(
      new MessageEvent("message", { data: { type: "focusLost" } })
    ); // Enviar evento de enfoque perdido
  }
  if (event.data.type === "focusLost") {
    document.body.style.backgroundColor = "rgba(0, 0, 0, 0)";
  }
});
// Añadir un evento para el botón de cerrar
const closeButton = document.querySelector("#closeButton");
closeButton.onclick = function () {
  window.dispatchEvent(
    new MessageEvent("message", { data: { type: 'close' } })
  ); // Llamar al evento de cierre
};
