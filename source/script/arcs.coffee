surfaces.arcs.render = (ctx, t, dt)->
  ctx.lineJoin = "round"

  for a, ai in particles when ai > 0
    b = particles[ai-1]
    dx = a.x-b.x
    dy = a.y-b.y
    dist = Math.sqrt dx*dx + dy*dy
    if dist < 100
      arcEnergy = (a.energy + b.energy)/10
      renderArc ctx, t, a, b, dist, arcEnergy
  null


renderArc = (ctx, t, a, b, dist, arcEnergy)->
  delay = Math.pow dist/20, .5
  steps = Math.ceil dist/10

  x = a.sx + a.r * sampleNoisePhasor(a.xName, t).v
  y = a.sy + a.r * sampleNoisePhasor(a.yName, t).v

  ctx.beginPath()
  ctx.moveTo x, y

  alpha = Math.min(a.alpha, b.alpha)/2
  ctx.strokeStyle = "rgba(255,255,255,#{alpha})"
  ctx.lineWidth = scale a.radius + b.radius, 2, maxParticleRadius*2, 1, 8, true

  for i in [1..steps]
    frac = i / steps

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
  null
