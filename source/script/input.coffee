setupInput = ()->
  window.addEventListener "mousemove", (e)->
    hasMoved = true
    mouseX = e.clientX
    mouseY = e.clientY

  window.addEventListener "touchmove", (e)->
    hasMoved = true
    mouseX = e.touches[0].clientX
    mouseY = e.touches[0].clientY
