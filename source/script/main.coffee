window.Pauling = (container)->
  TAU = Math.PI * 2
  surfaceNames = ["noise", "main", "blur"]

  dpr = 1#Math.max 1, Math.round(window.devicePixelRatio)
  surfaces = {}
  width = 0
  height = 0
  running = false
  renderRequested = false
  count = 0
  phase = 0
  noiseRendered = false


  lerp = (a,b,t)-> (1-t)*a + t*b


  absolutePos = (elm)->
    elm.style.position = "absolute"
    elm.style.top = elm.style.left = "0"
    elm.style.width = elm.style.height = "100%"


  makeSurface = (name)->
    canvas = document.createElement "canvas"
    container.appendChild canvas
    absolutePos canvas
    surfaces[name] =
      canvas: canvas
      context: canvas.getContext "2d"


  resize = ()->
    noiseRendered = false

    width = container.offsetWidth * dpr
    height = container.offsetHeight * dpr
    for name, surface of surfaces
      surface.canvas.width = width
      surface.canvas.height = height
    null


  requestResize = ()->
    widthChanged = 2 < Math.abs width - container.offsetWidth * dpr
    heightChanged = 50 < Math.abs height - container.offsetHeight * dpr
    if widthChanged or heightChanged
      requestAnimationFrame (time)->
        first = true
        resize()
        render() unless renderRequested


  requestRender = ()->
    unless renderRequested
      renderRequested = true
      requestAnimationFrame render


  render = (ms)->
    t = ms/1000
    renderRequested = false
    return requestRender() if isNaN ms
    requestRender() if running
    return if document.hidden
    # return unless count++ % 2 is 0

    renderMain t
    # renderNoise t


  step = 2
  scale = 100


  renderMain = (t)->
    ctx = surfaces.main.context
    ctx.clearRect 0, 0, width, height

    nCircles = 3000
    for i in [0..nCircles]
      ctx.beginPath()
      frac = i/nCircles
      x = width/2 + i/4 * Math.cos(89 * frac + .01 * t * TAU)
      y = height/2 + i/4 * Math.sin(89 * frac + .01 * t * TAU)
      v = simplex2 x/scale, y/scale
      l = Math.round lerp 128, 255, v
      ctx.fillStyle = "rgb(#{l},#{l},#{l})"
      ctx.arc x, y, Math.sqrt(800 * frac), 0, TAU
      ctx.fill()


  renderNoise = (t)->
    return if noiseRendered
    noiseRendered = true
    ctx = surfaces.noise.context
    ctx.clearRect 0, 0, width, height

    for x in [0..width/step]
      for y in [0..height/step]
        v = simplex2 x*step/scale, y*step/scale
        l = Math.round lerp 128, 255, v
        ctx.fillStyle = "rgb(#{l},#{l},#{l})"
        ctx.fillRect x*step, y*step, step, step


    # context.arc x1(t), y1(t), 10, 0, TAU
    # context.arc x2(t), y2(t), 10, 0, TAU
    # context.fill()
    #
    # context.beginPath()
    # context.strokeWidth = 2
    # context.strokeStyle = "white"
    #
    # context.moveTo x1(t), y1(t)
    #
    # steps = 100
    # delay = 3
    #
    # for i in [1...steps]
    #   frac = i / steps
    #   x = lerp x1(t - delay*frac), x2(t - delay*(1-frac)), frac
    #   y = lerp y1(t - delay*frac), y2(t - delay*(1-frac)), frac
    #   context.lineTo x, y
    #
    # context.stroke()

    # blurContext.drawImage canvas, 0, 0, width, height


  # INIT ##########################################################################################

  absolutePos container
  container.style.backgroundColor = "#BBB"#"hsl(230, 25%, 13%)"

  makeSurface name for name in surfaceNames
  surfaces.blur?.canvas.style["-webkit-filter"] = "blur(20px)"


  window.addEventListener "resize", requestResize
  resize()

  return API =
    start: ()->
      return if running
      running = true
      render()

    stop: ()->
      running = false
