window.Pauling = (container)->
  surfaceNames = ["main", "blur"]

  dpr = 1#Math.max 1, Math.round(window.devicePixelRatio)
  surfaces = {}
  width = 0
  height = 0
  running = false
  renderRequested = false
  count = 0
  phase = 0


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

    # t /= 100

    renderMain t


  noiseRadius = 0.5

  x1 = (t)->
    seed = 317
    0.25 * width + 150 * memoizedNoise seed + noiseRadius * Math.cos(TAU * t * .3), noiseRadius * Math.sin(TAU * t * .3)
  y1 = (t)->
    seed = 1697
    0.5 * height + 150 * memoizedNoise seed + noiseRadius * Math.cos(TAU * t * .3), noiseRadius * Math.sin(TAU * t * .3)

  x2 = (t)->
    seed = 1317
    0.75 * width + 100 * memoizedNoise seed + noiseRadius * Math.cos(TAU * t * .2), noiseRadius * Math.sin(TAU * t * .2)
  y2 = (t)->
    seed = 697
    0.5 * height + 100 * memoizedNoise seed + noiseRadius * Math.cos(TAU * t * .2), noiseRadius * Math.sin(TAU * t * .2)


  blurTime = 1
  blurSamples = 1


  noiseMemory = []
  granularity = 0.1
  memoizedNoise = (x, y)->
    t = Math.round(x / granularity)
    s = Math.round(y / granularity)
    tmem = noiseMemory[t] ?= []
    smem = tmem[s] ?= simplex2 x, y


  renderMain = (time, blur)->
    ctx = surfaces.main.context
    ctx.clearRect 0, 0, width, height

    for i in [0...blurSamples]

      tFrac = i / blurSamples
      t = time - tFrac * blurTime

      # alphaCurve = Math.cos scale i, 0, blurSamples, -PI, PI
      # ctx.globalAlpha = scale alphaCurve, -1, 1, 0.1, 1
      # ctx.globalAlpha = 1 - tFrac

      ctx.fillStyle = "white"
      ctx.beginPath()
      ctx.arc x1(t), y1(t), 10, 0, TAU
      ctx.fill()
      ctx.beginPath()
      ctx.arc x2(t), y2(t), 10, 0, TAU
      ctx.fill()

      ctx.beginPath()
      ctx.strokeWidth = 2
      ctx.strokeStyle = "white"

      ctx.moveTo x1(t), y1(t)

      steps = 100
      delay = 3

      for i in [1...steps]
        frac = i / steps
        x = lerp x1(t - delay*frac), x2(t - delay*(1-frac)), frac
        y = lerp y1(t - delay*frac), y2(t - delay*(1-frac)), frac
        ctx.lineTo x, y

      ctx.stroke()

    # blurContext.drawImage canvas, 0, 0, width, height


  # INIT ##########################################################################################

  absolutePos container
  container.style.backgroundColor = "hsl(230, 25%, 13%)"

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
