surfaces.snow.setup = (surface)->
  makeNoisePhasor "snowLight", 100, 40, 1000 * Math.random()
  makeNoisePhasor "snowHue", 30, 40, 1000 * Math.random()


surfaces.snow.resize = (surface)->
  for vecList in vectors
    for vec in vecList
      deletePhasor vec.aName
      deletePhasor vec.sName

  vectors = []

  size = Math.min width, height
  vectorSpacing = Math.floor size/10

  xVecs = Math.ceil width/vectorSpacing
  yVecs = Math.ceil height/vectorSpacing

  for i in [0..xVecs]
    x = i * vectorSpacing
    vectors[i] = []
    for j in [0..yVecs]
      y = j * vectorSpacing
      aName = "vectors-#{x}-#{y}a"
      sName = "vectors-#{x}-#{y}s"
      makeNoisePhasor aName, 120, 25, 0, i*8, j
      makeNoisePhasor sName, 70, 30, 0, -i*8, -j
      vectors[i].push
        aName: aName
        sName: sName
        x: x
        y: y
        initAngle: simplex2 i/15, j/15
  null


spawnSnow = (particleId, x, y, radius, particleAgeFrac)->
  if snow.length > maxSnow
    snow.splice 0, snow.length-maxSnow

  id = snowId++
  satFrac = (particleId/200) % 1
  snow.push
    x: x + scale Math.random(), 0, 1, -radius, +radius
    y: y + scale Math.random(), 0, 1, -radius, +radius
    age: 0
    id: id
    sat: scale Math.pow(0.5*(Math.pow(2*satFrac - 1, 3)+1), 2), 0, 1, 10, 90
    maxAge: 3 + Math.pow(particleAgeFrac, 3) * 20
    radius: radius/2


surfaces.snow.simulate = (t, dt)->
  return unless snow.length > 0

  targetSnow = scale dt, .015, .024, bestSnow, worstSnow, true
  maxSnow = Math.round maxSnow * .9 + targetSnow * .1

  for vecList in vectors
    for vec in vecList
      vec.angle = vec.initAngle + sampleNoisePhasor(vec.aName, t).v
      vec.strength = sampleNoisePhasor(vec.sName, t).v * .5 + .5

  for s, i in snow by -1
    s.age += dt * scale Math.pow(snow.length/maxSnow, 4), 0, 1, 1, 100
    s.ageFrac = s.age / s.maxAge
    s.ageFracInv = 1 - s.ageFrac

    s.alpha = Math.min s.ageFracInv, .6

    if s.age > s.maxAge or s.x < 0 or s.y < 0 or s.x > width or s.y > height
      snow.splice i, 1
      continue

    scaledX = s.x/vectorSpacing
    scaledY = s.y/vectorSpacing

    if lower = vectors[Math.floor scaledX]
      a = lower[Math.floor scaledY]
      b = lower[Math.ceil scaledY]
    if upper = vectors[Math.ceil scaledX]
      c = upper[Math.floor scaledY]
      d = upper[Math.ceil scaledY]

    if a? and b? and c? and d?
      s.ox = s.x
      s.oy = s.y
      vecSnowDist i, dt, s, a
      vecSnowDist i, dt, s, b
      vecSnowDist i, dt, s, c
      vecSnowDist i, dt, s, d
    else
      snow.splice i, 1
  null


vecSnowDist = (i, dt, s, vec)->
  dx = vec.x - s.x
  dy = vec.y - s.y
  dist = Math.sqrt dx*dx+dy*dy
  strength = vec.strength * (1 - dist/vectorSpacing)
  if strength > 0
    s.x += strength * 300 * dt * Math.cos vec.angle * TAU
    s.y += strength * 300 * dt * Math.sin vec.angle * TAU


surfaces.snow.render = (ctx, t, dt)->
  return unless snow.length > 0

  snowHue = scale sampleNoisePhasor("snowHue", t).v, -1, 1, 270, 210
  snowLight = scale sampleNoisePhasor("snowLight", t).v, -1, 1, 65, 100
  for s, i in snow
    ctx.beginPath()
    ctx.lineWidth = (.5 + s.ageFracInv) * s.radius
    ctx.strokeStyle = "hsla(#{snowHue},#{s.sat}%,#{snowLight}%,#{s.alpha})"
    ctx.moveTo s.ox, s.oy
    ctx.lineTo s.x, s.y
    ctx.stroke()
  null
