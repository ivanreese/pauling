mainMemoizedNoise = (x, y)-> memoizedNoise 0.03, x, y

surfaces.main.setup = ()->
  makeNoisePhasor "aX", 10, 5, 0, -30, -30
  makeNoisePhasor "aY", 10, 5, 0,  30, -30
  makeNoisePhasor "bX", 10, 5, 0, -30,  30
  makeNoisePhasor "bY", 10, 5, 0,  30,  30


surfaces.main.render = (ctx, t)->

  # renderCircle width/4, ctx, "a", t-frac, 0.00001, 0
  # renderCircle width*3/4, ctx, "b", t-frac, 0.00001, 360
  # renderLine ctx, t-frac, 100, 0.00001
  # renderLine ctx, t, 100, 0.001
  renderLine ctx, t, 100, 0.001
  null


# renderCircle = (cx, ctx, name, t, grainSize, hue)->
#   ctx.beginPath()
#   ctx.fillStyle = "hsl(#{hue-180}, #{sat}%, #{50}%)"
#   sampleX = sampleNoisePhasor "#{name}X", t, mainMemoizedNoise
#   sampleY = sampleNoisePhasor "#{name}Y", t, mainMemoizedNoise
#   x = cx + width/4 * sampleX.v
#   y = height/2 + height/2 * sampleY.v
#   ctx.fillStyle = "hsl(#{hue}, #{sat}%, 50%)"
#   ctx.arc x, y, 10, 0, TAU
#   ctx.fill()


renderLine = (ctx, t, steps, grainSize)->
  ctx.lineWidth = 2

  x = width/4 + width/2  * sampleNoisePhasor("aX", t, mainMemoizedNoise).v
  y = height/2 + height * sampleNoisePhasor("aY", t, mainMemoizedNoise).v

  ctx.moveTo x, y

  delay = 5

  for i in [1..steps]
    frac = i / steps
    # frac2 = scale Math.cos(TAU * frac), -1, 1, 0, 1

    d1 = t - delay * frac
    d2 = t - delay * (1-frac)

    x1 = width/4 + width/2  * sampleNoisePhasor("aX", d1, mainMemoizedNoise).v
    y1 = height/2 + height * sampleNoisePhasor("aY", d1, mainMemoizedNoise).v
    x2 = width*3/4 + width/2 * sampleNoisePhasor("bX", d2, mainMemoizedNoise).v
    y2 = height/2 + height * sampleNoisePhasor("bY", d2, mainMemoizedNoise).v

    x = lerp x1, x2, frac
    y = lerp y1, y2, frac

    h = frac * 360 |0
    ctx.strokeStyle = "hsla(198, 10%, 44%, .05)"
    ctx.lineTo x, y
    ctx.stroke()
    ctx.beginPath()
    ctx.moveTo x, y
  null
