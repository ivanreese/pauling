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


clearContainer = ()->
  container.innerHTML = ""


resize = ()->
  width = container.offsetWidth
  height = container.offsetHeight
  for name, surface of surfaces
    surface.canvas.width = width
    surface.canvas.height = height
    surface.resize?(surface)
  null


requestResize = ()->
  widthChanged = 2 < Math.abs width - container.offsetWidth
  heightChanged = 50 < Math.abs height - container.offsetHeight
  if widthChanged or heightChanged
    requestAnimationFrame (time)->
      first = true
      resize()
      render() unless renderRequested
