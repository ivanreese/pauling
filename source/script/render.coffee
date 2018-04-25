requestRender = ()->
  unless renderRequested
    renderRequested = true
    requestAnimationFrame render


render = (ms)->
  renderRequested = false
  requestRender() if running
  return if document.hidden
  return requestRender() if isNaN ms

  lastTime ?= (ms - 16)/1000 * timeScale
  t = ms/1000 * timeScale
  dt = t - lastTime
  lastTime = t

  for name, surface of surfaces when surface.active
    surface.context.clearRect 0, 0, width, height if surface.clear
    if surface.blurTime?
      renderWithMotionBlur surface, t, dt
    else
      surface.render surface.context, t, dt

  null


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
