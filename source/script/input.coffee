update = (e)->
  for name, surface of surfaces when surface.move?
    surface.move e.clientX, e.clientY
  null

setupInput = ()->
  container.addEventListener "mousemove", update
  container.addEventListener "touchmove", (e)->
    update touch for touch in e.touches
    null
