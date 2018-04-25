surfaces.snow.setup = (surface)->
  makeNoisePhasor "snowLightness", 30, 30
  makeNoisePhasor "snowSaturation", 20, 20, 50


surfaces.snow.resize = (surface)->


surfaces.snow.move = (x, y)->
  while snow.length > 300
    snow.splice(0, 1)

  spawnSnow x, y


surfaces.snow.render = (ctx, t, dt)->
  snowLight = scale sampleNoisePhasor("snowLightness", t).v, -1, 1, 0, 100
  snowSat = scale sampleNoisePhasor("snowSaturation", t).v, -1, 1, 10, 50
  snowAlpha = scale snowLight, 0, 100, .5, .05

  ctx.strokeStyle = "hsla(#{hue},#{snowSat}%,#{snowLight}%,#{snowAlpha})"

  # if snow.length < 10
  #   spawnSnow Math.random() * width, Math.random() * height

  i = snow.length
  while i > 0
    i--
    s = snow[i]

    ctx.beginPath()
    ctx.moveTo s.x, s.y

    a = vectors[Math.floor s.x/vectorSpacing]?[Math.floor s.y/vectorSpacing]
    b = vectors[Math.floor s.x/vectorSpacing]?[Math.ceil  s.y/vectorSpacing]
    c = vectors[Math.ceil  s.x/vectorSpacing]?[Math.floor s.y/vectorSpacing]
    d = vectors[Math.ceil  s.x/vectorSpacing]?[Math.ceil  s.y/vectorSpacing]

    vecSnowDist i, dt, s, a
    vecSnowDist i, dt, s, b
    vecSnowDist i, dt, s, c
    vecSnowDist i, dt, s, d

    ctx.lineTo s.x, s.y
    ctx.stroke()


vecSnowDist = (i, dt, s, vec)->
  if vec?
    dx = vec.x - s.x
    dy = vec.y - s.y
    dist = Math.sqrt dx*dx+dy*dy
    strength = 1 - dist/vectorSpacing
    s.x += strength * 100 * dt * Math.cos vec.angle * TAU
    s.y += strength * 100 * dt * Math.sin vec.angle * TAU
  else
    snow.splice i, 1


spawnSnow = (x, y)->
  snow.push
    x: x
    y: y
    age: 0
