surfaces.particles.move = (x, y, t, dt)->
  return unless particleMoveCount++ % 2 is 0
  lastParticleX ?= x
  lastParticleY ?= y
  dx = lastParticleX - x
  dy = lastParticleY - y
  dist = Math.sqrt dx*dx + dy*dy
  currentParticleEnergy += .01 * Math.pow dist, 1.7
  currentParticleEnergy = clip currentParticleEnergy, particleMinEnergy, particleMaxEnergy
  energy = Math.random() * currentParticleEnergy
  index = particleID++
  xName = "particle#{index}x"
  yName = "particle#{index}y"
  makeNoisePhasor xName, 20, 40, 0, Math.random()*100, 0
  makeNoisePhasor yName, 20, 40, 0, Math.random()*100, 0
  particles.push particle =
    sx: x + 30 * (Math.random() - .5) * Math.sqrt energy
    sy: y + 30 * (Math.random() - .5) * Math.sqrt energy
    r: 0
    birth: t
    maxAge: 1#scale particles.length, 0, maxParticles, 5, 5
    dead: false
    energy: energy
    xName: xName
    yName: yName
    shape: Math.floor(Math.pow(Math.random(), 3) * 10)
    angle: Math.random()
    skew: 1#1 + .5 * Math.pow(Math.random()*2-1, 3)
    arcs: 0
  for i in [particles.length-4...particles.length-1] when i > 0
    pair = particles[i]
    dx = particle.sx - pair.sx
    dy = particle.sy - pair.sy
    dist = Math.sqrt dx*dx + dy*dy
    arcEnergy = 10 * (particle.energy + pair.energy) / dist
    if arcEnergy > 1
      particle.arcs++
      pair.arcs++
      makeArc pair, particle, dist, arcEnergy
  lastParticleX = x
  lastParticleY = y


surfaces.particles.simulate = (t, dt)->
  currentParticleEnergy *= .9

  deadIndex = null

  for particle, i in particles by -1
    frac = i/particles.length

    particle.age = t - particle.birth

    if particles.length > maxParticles
      particle.maxAge -= .1*(particles.length-maxParticles)/maxParticles

    particle.r = Math.pow((particle.age/particle.maxAge)*20, 1.2)#Math.sqrt(particle.age) * 100

    particle.x = particle.sx + particle.r * sampleNoisePhasor(particle.xName, t).v
    particle.y = particle.sy + particle.r * sampleNoisePhasor(particle.yName, t).v

    particle.birthFrac = scale particle.age, 0, particle.maxAge*.2, 0, 1, true
    particle.deathFrac = scale particle.age, particle.maxAge*.6, particle.maxAge, 1, 0, true

    energyFrac = scale particle.energy, particleMinEnergy, particleMaxEnergy, 0.01, 1, true
    ageFrac = scale particle.age, 0, particle.maxAge, 1, 0, true
    ageFactor = Math.min ageFrac, Math.sqrt particle.birthFrac
    particle.radius = scale Math.pow(energyFrac * ageFactor, .5), 0, 1, 0, maxParticleRadius

    if particle.birthFrac < 1
      h = scale particle.birthFrac, 0, 1, 42, 20
      particle.style = "hsl(#{h},100%,50%)"
    else
      h = scale frac, 0, 1, 198, 284
      s = scale frac, 0, 1, 100, 44
      l = Math.min 100, scale frac, 0, 1, 44, 55/particle.deathFrac
      particle.style = "hsl(#{h},#{s}%,#{l}%)"

    if particle.deathFrac < 1 and Math.random() < .3
      spawnSnow particle.x, particle.y, particle.radius

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
  for particle, i in particles
    frac = i/particles.length

    ctx.beginPath()

    ctx.fillStyle = particle.style

    if particle.shape < 3
      ctx.arc particle.x, particle.y, particle.radius, 0, TAU
    else
      ctx.moveTo particle.x + particle.skew * particle.radius * Math.cos(TAU * particle.angle), particle.y + particle.radius * Math.sin(TAU * particle.angle)
      for p in [1..particle.shape]
        ang = TAU * (particle.angle+p/particle.shape)
        ctx.lineTo particle.x + particle.skew * particle.radius * Math.cos(ang), particle.y + particle.radius * Math.sin(ang)
    ctx.fill()

  null
