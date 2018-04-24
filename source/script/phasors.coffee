surfaces.phasors.render = (ctx, t)->
  pad = 60
  rad = 40

  for name, phasor of phasors
    ctx.beginPath()
    sample = sampleNoisePhasor name, t

    x = pad + rad * (phasor.xOffset + sample.x * phasor.radius)
    y = pad + rad * (phasor.yOffset + sample.y * phasor.radius)
    ctx.arc x, y, 1, 0, TAU

    lightness = scale sample.v, -1, 1, 0, 100
    stroke = Math.floor lightness
    fill = Math.floor lightness * .8
    ctx.strokeStyle = "hsl(#{hue}, #{sat}%, #{stroke}%)"
    ctx.fillStyle = "hsl(#{hue}, #{sat}%, #{fill}%)"

    ctx.lineWidth = 5 + 5 * phasor.radius

    ctx.stroke()
    ctx.fill()
  null
