window.Pauling = (c)->
  return API if container?

  container = c

  absolutePos container
  container.style.backgroundColor = "hsl(#{hue}, #{sat}%, 15%)"

  setupSurface surface for name, surface of surfaces when surface.active

  setupInput()

  window.addEventListener "resize", requestResize
  resize()

  return API =
    start: ()->
      return if running
      running = true
      render()

    stop: ()->
      running = false
