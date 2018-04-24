surfaces.main.setup = ()->
  makeNoisePhasor "aX", 10, 20, 0, -30, -30
  makeNoisePhasor "aY", 10, 20, 0,  30, -30
  makeNoisePhasor "bX", 10, 20, 0, -30,  30
  makeNoisePhasor "bY", 10, 20, 0,  30,  30

surfaces.main.render = (ctx, t)->
  renderCircle ctx, "a", t, 0.00001, 0
  renderCircle ctx, "b", t, 0.00001, 360

  renderLine ctx, t, 40, 0.00001
  renderLine ctx, t, 20, 0.03
  renderLine ctx, t, 15, 0.06
  null

renderCircle = (ctx, name, t, grainSize, hue)->
  ctx.beginPath()
  ctx.fillStyle = "hsl(#{hue-180}, #{sat}%, #{50}%)"
  sampleX = sampleNoisePhasor "#{name}X", t
  sampleY = sampleNoisePhasor "#{name}Y", t
  x = width/2  + width/2  * granularlize grainSize, sampleX.v
  y = height/2 + height/2 * granularlize grainSize, sampleY.v
  ctx.fillStyle = "hsl(#{hue}, #{sat}%, 50%)"
  ctx.arc x, y, 10, 0, TAU
  ctx.fill()


renderLine = (ctx, t, steps, grainSize)->
  ctx.strokeWidth = 2

  x = width/2  + width/2  * granularlize grainSize, sampleNoisePhasor("aX", t).v
  y = height/2 + height/2 * granularlize grainSize, sampleNoisePhasor("aY", t).v

  ctx.moveTo x, y

  delay = 5

  for i in [1..steps]
    frac = i / steps
    frac2 = frac * scale Math.cos(TAU * i/steps), -1, 1, 0, 1

    d1 = t-delay*frac
    d2 = t-delay*(1-frac)

    x1 = width/2  + width/2  * granularlize grainSize, sampleNoisePhasor("aX", d1).v
    y1 = height/2 + height/2 * granularlize grainSize, sampleNoisePhasor("aY", d1).v
    x2 = width/2  + width/2  * granularlize grainSize, sampleNoisePhasor("bX", d2).v
    y2 = height/2 + height/2 * granularlize grainSize, sampleNoisePhasor("bY", d2).v

    x = lerp x1, x2, frac2
    y = lerp y1, y2, frac2

    h = frac * 360 |0
    ctx.strokeStyle = "hsl(#{h}, #{sat}%, 50%)"
    ctx.lineTo x, y
    ctx.stroke()
    ctx.beginPath()
    ctx.moveTo x, y
  null
