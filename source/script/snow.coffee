surfaces.snow.setup = (surface)->
  makeNoisePhasor "snowLightness", 120, 30, 0, 1000 * Math.random()
  makeNoisePhasor "snowSaturation", 80, 20, 100, 1000 * Math.random()
  makeNoisePhasor "snowHue", 60, 20, 200, 1000 * Math.random()
  makeNoisePhasor "snowAlpha", 40, 20, 300, 1000 * Math.random()


spawnSnow = (x, y, radius)->
  if snow.length > maxSnow
    snow.splice maxSnow, snow.length-maxSnow-1

  snow.push
    x: x
    y: y
    age: 0
    id: snowId++
    light: Math.random() * 3
    minRadius: Math.random()*2

surfaces.snow.simulate = (t, dt)->
  targetSnow = scale dt, .015, .032, bestSnow, worstSnow, true
  maxSnow = Math.round maxSnow * .95 + targetSnow * .05


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


vecSnowDist = (i, dt, s, vec)->
  dx = vec.x - s.x
  dy = vec.y - s.y
  dist = Math.sqrt dx*dx+dy*dy
  vecStrength = Math.max .05, vec.strength
  strength = Math.max 0, vecStrength * (1 - dist/vectorSpacing)
  s.x += strength * 80 * dt * Math.cos vec.angle * TAU
  s.y += strength * 80 * dt * Math.sin vec.angle * TAU


surfaces.snow.render = (ctx, t, dt)->
  # This could help perf
  # return if t % .06 < .03

  for s, i in snow
    snowHue = scale sampleNoisePhasor("snowHue", t+s.id/300).v, -1, 1, 280, 200
    snowSat = scale sampleNoisePhasor("snowSaturation", t+s.id/300).v, -1, 1, 45, 70
    snowLight = scale sampleNoisePhasor("snowLightness", t+s.id/300).v, -1, 1, 30, 100
    snowAlpha = scale Math.pow(sampleNoisePhasor("snowAlpha", t+s.id/300).v, 2), 0, 1, .2, .6
    ctx.beginPath()
    radius = s.minRadius + scale s.age, 0, 1, 3, .3, true
    alpha = scale s.age, 0, 10, 1, .1, true
    ctx.fillStyle = "hsla(#{snowHue},#{snowSat}%,#{snowLight+s.light}%,#{snowAlpha*alpha})"
    ctx.arc s.x, s.y, radius, 0, TAU
    ctx.fill()
  null
