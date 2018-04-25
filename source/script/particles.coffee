surfaces.particles.setup = (surface)->


surfaces.particles.render = (ctx, t)->
  for a, ai in particles
    for b, bi in particles when bi > ai
      dx = a.x-b.x
      dy = a.y-b.y
      dist = Math.sqrt dx*dx + dy*dy
      avgEnergy = (a.energy + b.energy)/10
      if minParticleArcDist*avgEnergy < dist and dist < maxParticleArcDist*avgEnergy
        renderArc ctx, t, a, b, dist, avgEnergy

  i = 0
  while i < particles.length
    particle = particles[i]
    frac = i/particles.length

    particle.birth ?= t
    particle.age = t - particle.birth

    if particles.length > maxParticles
      particle.maxAge -= (particles.length-maxParticles)/maxParticles

    particle.r = Math.sqrt(particle.age) * 100

    particle.x = particle.sx + particle.r * sampleNoisePhasor(particle.xName, t).v
    particle.y = particle.sy + particle.r * sampleNoisePhasor(particle.yName, t).v

    ctx.beginPath()
    ctx.arc particle.x, particle.y, particle.energy, 0, TAU

    birthAlpha = scale particle.age, 0, particle.maxAge*.1, 0, 1, true
    deathAlpha = scale particle.age, particle.maxAge*.9, particle.maxAge, 1, 0, true
    particle.alpha = Math.min birthAlpha, deathAlpha
    if birthAlpha < 1
      ctx.fillStyle = "hsla(19,100%,#{particle.alpha*50+50}%,#{particle.alpha})"
    else
      h = scale frac, 0, 1, 198, 284
      s = scale frac, 0, 1, 100, 44
      l = scale frac, 0, 1, 44, 55
      ctx.fillStyle = "hsla(#{h},#{s}%,#{l}%,#{particle.alpha})"
    ctx.fill()

    deceased = particle.age > particle.maxAge
    offScreen = particle.x < -10 or particle.y < -10 or particle.x > width + 10 or particle.y > height + 10

    if deceased or offScreen
      deleteParticle particle
      particles.splice i, 1
    else
      i++

  null


surfaces.particles.move = (x, y)->
  makeParticle x, y


makeParticle = (x, y)->
  lastParticleX ?= x
  lastParticleY ?= y
  return if Math.abs(lastParticleX - x) < 12 and Math.abs(lastParticleY - y) < 12

  dx = lastParticleX - x
  dy = lastParticleY - y
  dist = Math.sqrt dx*dx + dy*dy
  energy = 0.1 * Math.pow dist, 1.5
  energy = clip energy, 1, 20

  lastParticleX = x
  lastParticleY = y

  index = particleID++
  xName = "particle#{index}x"
  yName = "particle#{index}y"
  makeNoisePhasor xName, 10, 10, Math.random(), 0, 0
  makeNoisePhasor yName, 10, 10, Math.random(), 0, 0
  particles.push
    sx: x
    sy: y
    r: 1
    maxAge: Math.pow rand(.5, 2), 3
    energy: energy
    xName: xName
    yName: yName

deleteParticle = (particle)->
  deletePhasor particle.xName
  deletePhasor particle.yName



renderArc = (ctx, t, a, b, dist, avgEnergy)->

  delay = Math.sqrt dist/50
  steps = Math.ceil dist/10

  x = a.sx + a.r * sampleNoisePhasor(a.xName, t).v
  y = a.sy + a.r * sampleNoisePhasor(a.yName, t).v

  ctx.beginPath()
  ctx.moveTo x, y

  alpha = Math.min a.alpha, b.alpha, scale dist, minParticleArcDist*avgEnergy, maxParticleArcDist*avgEnergy, 1, 0, true
  # alpha = 1
  ctx.lineWidth = alpha * 5 |0

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

    h = scale frac, 0, 1, 198, 284
    s = scale frac, 0, 1, 100, 44
    l = scale frac, 0, 1, 44, 55
    ctx.strokeStyle = "hsla(#{h}, #{s}%, #{l}%, #{alpha})"
    ctx.lineTo x, y
    ctx.stroke()
    ctx.beginPath()
    ctx.moveTo x, y
  null
