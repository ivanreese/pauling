start = (c)->
  return if running
  running = true

  container = c

  absolutePos container
  container.style.backgroundColor = "#222"

  resetDefaults()

  setupSurface surface for name, surface of surfaces

  window.addEventListener "mousemove", mousemove
  window.addEventListener "touchmove", touchmove
  window.addEventListener "resize", requestResize

  resize()

  render()
  undefined


stop = ()->
  running = false

  clearContainer()

  window.removeEventListener "mousemove", mousemove
  window.removeEventListener "touchmove", touchmove
  window.removeEventListener "resize", requestResize

  undefined


API =
  start: start
  stop: stop


window.Pauling = ()-> API
