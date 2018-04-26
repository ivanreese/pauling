surfaces.snow.setup = (surface)->
  makeNoisePhasor "snowLightness", 30, 30, 0
  makeNoisePhasor "snowSaturation", 20, 20, 100
  makeNoisePhasor "snowHue", 15, 15, 200
  makeNoisePhasor "snowAlpha", 10, 10, 300


spawnSnow = (x, y, radius)->
  while snow.length > 2000
    snow.splice 0, 1

  snow.push
    x: x + scale Math.random(), 0, 1, 10-radius, radius/2-10
    y: y + scale Math.random(), 0, 1, 10-radius, radius/2-10
    age: 0
    light: Math.random() * 3
    minRadius: Math.random()*2

surfaces.snow.simulate = (t, dt)->
  for s, i in snow by -1
    a = vectors[Math.floor s.x/vectorSpacing]?[Math.floor s.y/vectorSpacing]
    b = vectors[Math.floor s.x/vectorSpacing]?[Math.ceil  s.y/vectorSpacing]
    c = vectors[Math.ceil  s.x/vectorSpacing]?[Math.floor s.y/vectorSpacing]
    d = vectors[Math.ceil  s.x/vectorSpacing]?[Math.ceil  s.y/vectorSpacing]

    if a? and b? and c? and d?
      s.ox = s.x
      s.oy = s.y
      vecSnowDist i, dt, s, a
      vecSnowDist i, dt, s, b
      vecSnowDist i, dt, s, c
      vecSnowDist i, dt, s, d

      s.age += dt

    else
      snow.splice i, 1

  null


surfaces.snow.render = (ctx, t, dt)->
  snowLight = scale sampleNoisePhasor("snowLightness", t).v, -1, 1, 50, 80
  snowSat = scale sampleNoisePhasor("snowSaturation", t).v, -1, 1, 40, 80
  snowAlpha = scale sampleNoisePhasor("snowAlpha", t).v, -1, 1, .5, .05
  snowHue = scale sampleNoisePhasor("snowHue", t).v, -1, 1, 290, 190

  # ctx.lineCap = "round"
  # ctx.lineJoin = "round"

  for s, i in snow
    ctx.beginPath()
    radius = s.minRadius + scale s.age, 0, 1, 3, .5, true
    alpha = scale s.age, 0, 1, 1, .3, true
    ctx.fillStyle = "hsla(#{snowHue},#{snowSat}%,#{snowLight+s.light}%,#{snowAlpha*alpha})"
    # ctx.lineWidth = 2*radius*2 + s.minRadius
    # ctx.moveTo 2*s.ox, 2*s.oy
    # ctx.lineTo 2*s.x, 2*s.y
    # ctx.stroke()
    ctx.arc 2*s.x, 2*s.y, 2*radius, 0, TAU
    ctx.fill()

  # ctx.globalCompositeOperation = "destination-out"
  # ctx.globalAlpha = .01
  # ctx.fillStyle = "#000"
  # ctx.fillRect 0, 0, width, height
  # ctx.globalAlpha = 1
  # ctx.globalCompositeOperation = "source-over"


vecSnowDist = (i, dt, s, vec)->
  dx = vec.x - s.x
  dy = vec.y - s.y
  dist = Math.sqrt dx*dx+dy*dy
  vecStrength = Math.max .1, vec.strength
  strength = Math.max 0, vecStrength * (1 - dist/vectorSpacing)
  s.x += strength * 100 * dt * Math.cos vec.angle * TAU
  s.y += strength * 100 * dt * Math.sin vec.angle * TAU
