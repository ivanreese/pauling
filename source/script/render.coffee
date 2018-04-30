requestRender = ()->
  unless renderRequested
    renderRequested = true
    requestAnimationFrame render


bail = (fn)->
  lastMouseX = null
  lastMouseY = null
  fn?()


render = (currentTime)->
  renderRequested = false
  requestRender() if running
  return bail null if document.hidden
  return bail requestRender if isNaN currentTime

  lastTime ?= currentTime - 16
  deltaMs = Math.min 32, currentTime - lastTime
  dt = timeScale/1000 * deltaMs
  lastTime = currentTime
  worldTime += dt

  if hasMoved & lastMouseX?
    mouseDx = lastMouseX - mouseX
    mouseDy = lastMouseY - mouseY
    mouseDist = Math.sqrt mouseDx*mouseDx + mouseDy*mouseDy
  else
    lastMouseX = mouseX
    lastMouseY = mouseY
    mouseDx = 0
    mouseDy = 0
    mouseDist = 0

  for name, surface of surfaces when surface.doSimulate
    surface.move? mouseX, mouseY, worldTime, dt if hasMoved
    surface.simulate? worldTime, dt

  for name, surface of surfaces when surface.doSimulate and surface.doRender
    surface.context.clearRect 0, 0, width, height if surface.clear
    if surface.blurTime?
      renderWithMotionBlur surface, worldTime, dt
    else
      surface.render? surface.context, worldTime, dt

  hasMoved = false
  lastMouseX = mouseX
  lastMouseY = mouseY

renderWithMotionBlur = (surface, t, dt)->
  for i in [0...surface.blurSamples]
    frac = scale i, 0, surface.blurSamples-1, -1, 1

    timeCurve = Math.pow Math.abs(frac), 1 + surface.blurCurve
    sign = if frac > 0 then 1 else -1
    signedTimeCurve = timeCurve * sign
    timeOffset = signedTimeCurve * surface.blurTime

    alphaCurve = Math.cos frac * PI/2
    scaledAlphaCurve = scale alphaCurve, 0, 1, .1, surface.blurOpacity
    surface.context.globalAlpha = scaledAlphaCurve

    surface.render surface.context, t + timeOffset, dt
  null
