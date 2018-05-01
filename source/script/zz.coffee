window.Pauling = (c)->
  return API if container?

  container = c

  absolutePos container
  container.style.backgroundColor = "#222"

  setupSurface surface for name, surface of surfaces

  setupInput()

  window.addEventListener "resize", requestResize
  resize()

  return API =
    start: ()->
      return if running
      running = true
      render()
      undefined

    stop: ()->
      running = false
      undefined
