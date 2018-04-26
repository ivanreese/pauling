surfaces.snow.setup = (surface)->
  makeNoisePhasor "snowLightness", 30, 30, 40
  makeNoisePhasor "snowSaturation", 20, 20, 50


surfaces.snow.move = (x, y)->
  while snow.length > 1000
    snow.splice(0, 1)
  spawnSnow x, y


surfaces.snow.render = (ctx, t, dt)->
  snowLight = scale sampleNoisePhasor("snowLightness", t).v, -1, 1, 50, 100
  snowSat = scale sampleNoisePhasor("snowSaturation", t).v, -1, 1, 50, 100

  ctx.strokeStyle = "hsl(#{hue},#{snowSat}%,#{snowLight}%)"
  ctx.beginPath()

  for s, i in snow by -1
    ctx.moveTo s.x, s.y

    a = vectors[Math.floor s.x/vectorSpacing]?[Math.floor s.y/vectorSpacing]
    b = vectors[Math.floor s.x/vectorSpacing]?[Math.ceil  s.y/vectorSpacing]
    c = vectors[Math.ceil  s.x/vectorSpacing]?[Math.floor s.y/vectorSpacing]
    d = vectors[Math.ceil  s.x/vectorSpacing]?[Math.ceil  s.y/vectorSpacing]

    if a? and b? and c? and d?
      vecSnowDist i, dt, s, a
      vecSnowDist i, dt, s, b
      vecSnowDist i, dt, s, c
      vecSnowDist i, dt, s, d
      ctx.lineTo s.x, s.y
    else
      snow.splice i, 1

  ctx.stroke()

  ctx.save()
  ctx.globalCompositeOperation = "destination-out"
  ctx.globalAlpha = .05
  ctx.fillStyle = "#000"
  ctx.fillRect 0, 0, width, height
  ctx.restore()


vecSnowDist = (i, dt, s, vec)->
  dx = vec.x - s.x
  dy = vec.y - s.y
  dist = Math.sqrt dx*dx+dy*dy
  strength = Math.max 0, vec.strength * (1 - dist/vectorSpacing)
  s.x += strength * 100 * dt * Math.cos vec.angle * TAU
  s.y += strength * 100 * dt * Math.sin vec.angle * TAU


spawnSnow = (x, y)->
  snow.push
    x: x
    y: y
    age: 0
