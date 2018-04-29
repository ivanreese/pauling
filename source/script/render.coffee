requestRender = ()->
  unless renderRequested
    renderRequested = true
    requestAnimationFrame render


render = (currentTime)->
  renderRequested = false
  requestRender() if running
  return if document.hidden
  return requestRender() if isNaN currentTime

  lastTime ?= currentTime - 16
  deltaMs = Math.min 32, currentTime - lastTime
  dt = timeScale/1000 * deltaMs
  lastTime = currentTime
  worldTime += dt

  for name, surface of surfaces when surface.doSimulate
    surface.move? clientX, clientY, worldTime, dt if hasMoved
    surface.simulate? worldTime, dt

  for name, surface of surfaces when surface.doSimulate and surface.doRender
    surface.context.clearRect 0, 0, width, height if surface.clear
    if surface.blurTime?
      renderWithMotionBlur surface, worldTime, dt
    else
      surface.render? surface.context, worldTime, dt

  hasMoved = false


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
