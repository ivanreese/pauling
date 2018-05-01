surfaces.particles.move = (x, y, t, dt)->
  currentParticleEnergy += .01 * Math.pow mouseDist, 1.7
  currentParticleEnergy = clip currentParticleEnergy, particleMinEnergy, particleMaxEnergy
  energy = Math.random() * currentParticleEnergy
  energyFrac = scale energy, particleMinEnergy, particleMaxEnergy, 0.01, 1, true
  index = particleID++
  xName = "particle#{index}x"
  yName = "particle#{index}y"
  makeNoisePhasor xName, 10, 20, 0, Math.random()*1000, 0
  makeNoisePhasor yName, 10, 20, 0, Math.random()*1000, 0
  particles.push particle =
    sx: x + (Math.random() - .5) * scale energyFrac, 0, 1, 10, 220
    sy: y + (Math.random() - .5) * scale energyFrac, 0, 1, 10, 220
    birth: t
    maxAge: 1.1
    dead: false
    energy: energy
    energyFrac: energyFrac
    xName: xName
    yName: yName
    shape: Math.floor(Math.pow(Math.random(), 2.5) * 9)
    angle: Math.random()
    arcs: 0
    id: index
    spawnCount: 0
  for i in [particles.length-3...particles.length-1] when i > 0
    pair = particles[i]
    dx = particle.sx - pair.sx
    dy = particle.sy - pair.sy
    dist = Math.sqrt dx*dx + dy*dy
    arcEnergy = 10 * (particle.energy + pair.energy) / dist
    makeArc pair, particle, dist, arcEnergy if arcEnergy > 1
  null

surfaces.particles.simulate = (t, dt)->
  return unless particles.length > 0

  currentParticleEnergy *= .9

  deadIndex = null

  for particle, i in particles by -1
    frac = i/particles.length

    particle.age = t - particle.birth
    ageFrac = particle.age/particle.maxAge
    particle.ageFrac = ageFrac
    ageFracInv = 1-ageFrac

    if particles.length > maxParticles
      particle.maxAge -= .1*(particles.length-maxParticles)/maxParticles

    particle.r = scale Math.pow(ageFrac, 2), 0, 1, 10, 80 + 40 * particle.energyFrac

    particle.x = particle.sx + particle.r * sampleNoisePhasor(particle.xName, t).v
    particle.y = particle.sy + particle.r * sampleNoisePhasor(particle.yName, t).v

    particle.birthFrac = Math.min 1, ageFrac * 5
    particle.deathFrac = Math.min 1, ageFracInv / .7

    ageFactor = Math.min ageFracInv, Math.sqrt particle.birthFrac
    radiusFrac = Math.pow particle.energyFrac * ageFactor, .5
    particle.radius = radiusFrac * maxParticleRadius

    if particle.birthFrac < 1
      particle.hue = scale particle.birthFrac, 0, 1, 42, 20
      particle.sat = "100"
      particle.light = "50"
    else
      particle.hue = scale frac, 0, 1, 198, 284
      particle.sat = scale frac, 0, 1, 100, 44
      particle.light = Math.min 100, scale frac, 0, 1, 44, 55/particle.deathFrac
    particle.style = "hsl(#{particle.hue},#{particle.sat}%,#{particle.light}%)"

    if particle.deathFrac < 1 and particle.spawnCount++ % 4 is 0
      spawnSnow particle.id, particle.x, particle.y, particle.radius/10, particle.deathFrac

    if particle.age > particle.maxAge
      deadIndex = i
      break

  if deadIndex?
    for i in [0..deadIndex]
      particle = particles[i]
      particle.dead = true
      deletePhasor particle.xName
      deletePhasor particle.yName
    particles.splice 0, deadIndex+1

  null


surfaces.particles.render = (ctx, t)->
  return false unless particles.length > 0
  for particle, i in particles
    frac = i/particles.length

    ctx.beginPath()

    ctx.fillStyle = particle.style

    if particle.shape < 3
      ctx.arc particle.x, particle.y, particle.radius, 0, TAU
    else
      ctx.moveTo particle.x + particle.radius * Math.cos(TAU * particle.angle), particle.y + particle.radius * Math.sin(TAU * particle.angle)
      for p in [1..particle.shape]
        ang = TAU * (particle.angle+p/particle.shape)
        ctx.lineTo particle.x + particle.radius * Math.cos(ang), particle.y + particle.radius * Math.sin(ang)
    ctx.fill()

  true
