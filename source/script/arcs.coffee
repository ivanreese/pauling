makeArc = (a, b, dist, energy)->
  arcs.push
    a:a
    b:b
    dist:dist
    energy:energy


surfaces.arcs.render = (ctx, t, dt)->
  return false unless arcs.length > 0
  # ctx.lineCap = "round"
  # ctx.lineJoin = "round"

  for arc, i in arcs by -1
    a = arc.a
    b = arc.b

    if a.dead or b.dead
      delete arcs.splice i, 1
      continue

    delay = .5 + 2 * a.ageFrac
    steps = Math.ceil delay * arc.dist/13

    x = a.sx + a.r * sampleNoisePhasor(a.xName, t).v
    y = a.sy + a.r * sampleNoisePhasor(a.yName, t).v

    ctx.beginPath()
    ctx.moveTo x, y

    ctx.globalAlpha = Math.pow Math.min(a.deathFrac, b.deathFrac), .8
    light = scale a.light, 0, 100, 40, 100, true
    ctx.strokeStyle = "hsl(#{a.hue}, 100%, #{light}%)"
    ctx.lineWidth = scale a.radius + b.radius, 2, maxParticleRadius*2, 1, 5, true

    for s in [1..steps]
      frac = s / steps

      d1 = t-delay*frac
      d2 = t-delay*(1-frac)

      x1 = a.sx + a.r * sampleNoisePhasor(a.xName, d1).v
      y1 = a.sy + a.r * sampleNoisePhasor(a.yName, d1).v
      x2 = b.sx + b.r * sampleNoisePhasor(b.xName, d2).v
      y2 = b.sy + b.r * sampleNoisePhasor(b.yName, d2).v

      x = lerp x1, x2, frac
      y = lerp y1, y2, frac

      ctx.lineTo x, y

    ctx.stroke()
  true
