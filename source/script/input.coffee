update = (e)->
  for name, surface of surfaces when surface.move?
    surface.move e.clientX, e.clientY
  null

setupInput = ()->
  window.addEventListener "mousemove", update
  window.addEventListener "touchmove", (e)->
    update touch for touch in e.touches
    null
