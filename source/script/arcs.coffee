surfaces.arcs.setup = (surface)->
  surface.context.lineCap = "round"
  surface.context.lineJoin = "round"


surfaces.arcs.render = (ctx, t, dt)->
  for a, ai in particles
    for bi in [ai-1..ai-1] when bi > 0
      b = particles[bi]
      dx = a.x-b.x
      dy = a.y-b.y
      dist = Math.sqrt dx*dx + dy*dy
      avgEnergy = (a.energy + b.energy)/10
      # if minParticleArcDist*avgEnergy < dist and dist < maxParticleArcDist*avgEnergy
      renderArc ctx, t, a, b, dist, avgEnergy
  null


renderArc = (ctx, t, a, b, dist, avgEnergy)->
  delay = Math.sqrt dist/50
  steps = Math.ceil dist/10

  x = a.sx + a.r * sampleNoisePhasor(a.xName, t).v
  y = a.sy + a.r * sampleNoisePhasor(a.yName, t).v

  ctx.beginPath()
  ctx.moveTo x, y

  alpha = Math.min a.alpha, b.alpha, scale dist, minParticleArcDist*avgEnergy, maxParticleArcDist*avgEnergy, 1, 0, true
  # alpha = 1
  ctx.lineWidth = 2#avgEnergy * 3 |0

  # h = scale frac, 0, 1, 198, 284
  # s = scale frac, 0, 1, 100, 44
  # l = scale frac, 0, 1, 44, 55
  # ctx.strokeStyle = "hsla(#{h}, #{s}%, #{l}%, #{alpha})"
  ctx.strokeStyle = "rgba(255,255,255,#{alpha})"


  for i in [1..steps]
    frac = i / steps
    # frac2 = scale Math.cos(TAU * frac), -1, 1, 0, 1

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
