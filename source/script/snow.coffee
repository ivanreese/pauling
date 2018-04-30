surfaces.snow.setup = (surface)->
  makeNoisePhasor "snowLight", 120, 30, 0, 1000 * Math.random()
  makeNoisePhasor "snowHue", 30, 40, 190, 1000 * Math.random()


spawnSnow = (particleId, x, y, radius)->
  if snow.length > maxSnow
    snow.splice 0, snow.length-maxSnow

  id = snowId++
  satFrac = (particleId/200) % 1
  snow.push
    x: x + scale Math.random(), 0, 1, -radius, +radius
    y: y + scale Math.random(), 0, 1, -radius, +radius
    age: 0
    id: id
    light: scale Math.random(), 0, 1, 30, 50
    sat: scale Math.pow(0.5*(Math.pow(2*satFrac - 1, 3)+1), 2), 0, 1, 15, 85
    maxAge: 2 + Math.pow(Math.random(), 3) * 15


surfaces.snow.simulate = (t, dt)->
  targetSnow = scale dt, .015, .032, bestSnow, worstSnow, true
  maxSnow = Math.round maxSnow * .95 + targetSnow * .05

  for s, i in snow by -1
    s.age += dt * scale Math.pow(snow.length/maxSnow, 4), 0, 1, 1, 100
    s.ageFrac = s.age / s.maxAge
    s.ageFracInv = 1 - s.ageFrac

    s.alpha = Math.min s.ageFracInv, 1

    if s.age > s.maxAge
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
    s.x += strength * 150 * dt * Math.cos vec.angle * TAU
    s.y += strength * 150 * dt * Math.sin vec.angle * TAU


surfaces.snow.render = (ctx, t, dt)->
  ctx.globalCompositeOperation = "screen"
  snowHue = scale sampleNoisePhasor("snowHue", t).v, -1, 1, 280, 200
  snowLight = scale sampleNoisePhasor("snowLight", t).v, -1, 1, 50, 90
  ctx.lineWidth = 1
  ctx.lineCap = "round" # This prevents speckling in Chrome
  for s, i in snow
    ctx.beginPath()
    ctx.strokeStyle = "hsla(#{snowHue},#{s.sat}%,#{snowLight}%,#{s.alpha})"
    ctx.moveTo s.ox, s.oy
    ctx.lineTo s.x, s.y
    ctx.stroke()
  null
