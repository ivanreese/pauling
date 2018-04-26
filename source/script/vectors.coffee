surfaces.vectors.move = ()->
  vectorFading++


surfaces.vectors.simulate = (t, dt)->
  for vecList in vectors
    for vec in vecList
      vec.angle = vec.initAngle + sampleNoisePhasor(vec.aName, t).v
      vec.strength = scale sampleNoisePhasor(vec.sName, t).v, 0, 1, .5, 2
  null


surfaces.vectors.render = (ctx, t)->
  lightness = if vectorFading > 100
    scale t, 0, 15, 25, bgLightness, true
  else
    25

  return unless lightness > bgLightness

  ctx.lineWidth = 2
  ctx.strokeStyle = "hsl(#{hue}, #{sat}%, #{lightness}%)"
  ctx.fillStyle = "hsl(#{hue}, #{sat}%, #{lightness}%)"

  for vecList in vectors
    for vec in vecList
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
  null


surfaces.vectors.resize = (surface)->
  for vecList in vectors
    for vec in vecList
      deletePhasor vec.aName
      deletePhasor vec.sName

  vectors = []

  xVecs = Math.ceil width/vectorSpacing
  yVecs = Math.ceil height/vectorSpacing

  for i in [0..xVecs]
    x = i * vectorSpacing
    vectors[i] = []
    for j in [0..yVecs]
      y = j * vectorSpacing
      aName = "vectors-#{x}-#{y}a"
      sName = "vectors-#{x}-#{y}s"
      makeNoisePhasor aName, 60, 30, 0, i*10, j
      makeNoisePhasor sName, 70, 30, 0, -i*10, -j
      vectors[i].push
        aName: aName
        sName: sName
        x: x
        y: y
        initAngle: simplex2 i/15, j/15
  null
