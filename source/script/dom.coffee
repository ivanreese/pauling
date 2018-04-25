absolutePos = (elm)->
  elm.style.position = "absolute"
  elm.style.top = elm.style.left = "0"
  elm.style.width = elm.style.height = "100%"


setupSurface = (surface)->
  surface.canvas = document.createElement "canvas"
  container.appendChild surface.canvas
  absolutePos surface.canvas
  surface.context = surface.canvas.getContext "2d"
  surface.setup? surface


resize = ()->
  width = container.offsetWidth * dpr
  height = container.offsetHeight * dpr
  for name, surface of surfaces when surface.active
    scale = surface.scale or 1
    surface.canvas.width = width * scale
    surface.canvas.height = height * scale
    surface.resize?(surface)
  null


requestResize = ()->
  widthChanged = 2 < Math.abs width - container.offsetWidth * dpr
  heightChanged = 50 < Math.abs height - container.offsetHeight * dpr
  if widthChanged or heightChanged
    requestAnimationFrame (time)->
      first = true
      resize()
      render() unless renderRequested
