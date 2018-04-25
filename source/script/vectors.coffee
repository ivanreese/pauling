surfaces.vectors.setup = (surface)->


surfaces.vectors.resize = (surface)->
  for vecList in vectors
    for vec in vecList
      deletePhasor vec.name

  vectors = []

  xVecs = Math.ceil width/vectorSpacing
  yVecs = Math.ceil height/vectorSpacing

  for i in [0..xVecs]
    x = i * vectorSpacing
    vectors[i] = []
    for j in [0..yVecs]
      y = j * vectorSpacing
      name = "vectors-#{x}-#{y}"
      makeNoisePhasor name, 60, 30, 0, i, j
      vectors[i].push
        name: name
        x: x
        y: y
        initAngle: simplex2 i/15, j/15


surfaces.vectors.render = (ctx, t)->
  ctx.lineWidth = 2

  lightness = scale t, 0, 15, 25, bgLightness, true

  ctx.strokeStyle = "hsl(#{hue}, #{sat}%, #{lightness}%)"
  ctx.fillStyle = "hsl(#{hue}, #{sat}%, #{lightness}%)"

  for vecList in vectors
    for vec in vecList
      vec.angle = vec.initAngle + sampleNoisePhasor(vec.name, t).v

      if lightness > bgLightness
        ctx.beginPath()
        x = vec.x + vectorSpacing/4 * Math.cos vec.angle * TAU
        y = vec.y + vectorSpacing/4 * Math.sin vec.angle * TAU

        ctx.arc x, y, 2, 0, TAU
        ctx.fill()

        ctx.beginPath()
        ctx.moveTo x, y

        x = vec.x + vectorSpacing/2 * Math.cos vec.angle * TAU
        y = vec.y + vectorSpacing/2 * Math.sin vec.angle * TAU
        ctx.lineTo x, y
        ctx.stroke()
