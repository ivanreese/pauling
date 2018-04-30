surfaces.snow.setup = (surface)->
  makeNoisePhasor "snowLight", 100, 40, 1000 * Math.random()
  makeNoisePhasor "snowHue", 30, 40, 1000 * Math.random()


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
    light: scale Math.random(), 0, 1, 30, 50
    sat: scale Math.pow(0.5*(Math.pow(2*satFrac - 1, 3)+1), 2), 0, 1, 0, 90
    maxAge: 3 + Math.pow(particleAgeFrac, 3) * 20
    radius: radius/2


surfaces.snow.simulate = (t, dt)->
  targetSnow = scale dt, .015, .032, bestSnow, worstSnow, true
  maxSnow = Math.round maxSnow * .95 + targetSnow * .05

  for s, i in snow by -1
    s.age += dt * scale Math.pow(snow.length/maxSnow, 4), 0, 1, 1, 100
    s.ageFrac = s.age / s.maxAge
    s.ageFracInv = 1 - s.ageFrac

    s.alpha = Math.min s.ageFracInv, 1

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
  ctx.globalCompositeOperation = "screen"
  snowHue = scale sampleNoisePhasor("snowHue", t).v, -1, 1, 270, 210
  snowLight = scale sampleNoisePhasor("snowLight", t).v, -1, 1, 50, 70
  ctx.lineCap = "round" # This prevents speckling in Chrome
  for s, i in snow
    ctx.beginPath()
    ctx.lineWidth = .2 + s.ageFracInv + s.radius
    ctx.strokeStyle = "hsla(#{snowHue},#{s.sat}%,#{snowLight}%,#{s.alpha})"
    ctx.moveTo s.ox, s.oy
    ctx.lineTo s.x, s.y
    ctx.stroke()
  null
