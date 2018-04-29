setupInput = ()->
  window.addEventListener "mousemove", (e)->
    hasMoved = true
    clientX = e.clientX
    clientY = e.clientY

  window.addEventListener "touchmove", (e)->
    hasMoved = true
    clientX = e.touches[0].clientX
    clientY = e.touches[0].clientY
