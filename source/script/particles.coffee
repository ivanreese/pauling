surfaces.particles.move = (x, y)->
  if worldTime - lastParticleSpawnTime > .1
    lastParticleX = x
    lastParticleY = y

  lastParticleSpawnTime = worldTime

  return if Math.abs(lastParticleX - x) < 1 and Math.abs(lastParticleY - y) < 1

  dx = lastParticleX - x
  dy = lastParticleY - y
  dist = Math.sqrt dx*dx + dy*dy

  steps = Math.max 1, dist/12|0
  for i in [0..steps]
    frac = i/steps
    currentParticleEnergy += .1# * Math.pow dist, 1.5
    currentParticleEnergy = clip currentParticleEnergy, particleMinEnergy, particleMaxEnergy
    index = particleID++
    xName = "particle#{index}x"
    yName = "particle#{index}y"
    makeNoisePhasor xName, 30, 30, 0, Math.random()*100, 0
    makeNoisePhasor yName, 30, 30, 0, Math.random()*100, 0
    particles.push
      sx: lerp lastParticleX, x, frac
      sy: lerp lastParticleY, y, frac
      r: 1
      maxAge: 5#scale particles.length, 0, maxParticles, 5, 5
      energy: currentParticleEnergy
      xName: xName
      yName: yName
      shape: Math.random()
  lastParticleX = x
  lastParticleY = y


surfaces.particles.simulate = (t, dt)->
  currentParticleEnergy *= 0.90

  deadIndex = null

  for particle, i in particles by -1
    frac = i/particles.length

    particle.birth ?= t
    particle.age = t - particle.birth

    if particles.length > maxParticles
      particle.maxAge -= .1*(particles.length-maxParticles)/maxParticles

    energyFrac = scale particle.energy, particleMinEnergy, particleMaxEnergy, 0.3, 1, true
    ageFrac = scale particle.age, 0, particle.maxAge, 1, 0, true
    particle.radius = scale energyFrac * ageFrac, 0, 1, 0, maxParticleRadius

    particle.r = Math.pow((particle.age/particle.maxAge)*6, 3)#Math.sqrt(particle.age) * 100

    particle.birthAlpha = scale particle.age, 0, particle.maxAge*.1, 0, 1, true
    particle.deathAlpha = scale particle.age, particle.maxAge*.6, particle.maxAge, 1, 0, true
    particle.alpha = Math.min particle.birthAlpha, particle.deathAlpha

    if particle.deathAlpha < 1 and Math.random() < .3
      spawnSnow particle.x, particle.y, particle.radius

    if particle.age > particle.maxAge
      deadIndex = i
      break

  if deadIndex?
    for i in [0..deadIndex]
      deletePhasor particles[i].xName
      deletePhasor particles[i].yName
    particles.splice 0, deadIndex+1

  null


surfaces.particles.render = (ctx, t)->
  # ctx.globalCompositeOperation = "lighter-color"

  for particle, i in particles
    frac = i/particles.length

    particle.x = particle.sx + particle.r * sampleNoisePhasor(particle.xName, t).v
    particle.y = particle.sy + particle.r * sampleNoisePhasor(particle.yName, t).v

    ctx.beginPath()
    # ctx.globalAlpha = .7

    if particle.birthAlpha < 1
      h = scale particle.birthAlpha, 0, 1, 42, 20
      ctx.fillStyle = "hsl(#{h},100%,50%)"
    else
      h = scale frac, 0, 1, 198, 284
      s = scale frac, 0, 1, 100, 44
      l = Math.min 100, scale frac, 0, 1, 44, 55/particle.deathAlpha
      ctx.fillStyle = "hsl(#{h},#{s}%,#{l}%)"


    # if particle.shape < 0.5
    ctx.arc particle.x, particle.y, particle.radius, 0, TAU
    # else
    # ctx.rect particle.x-particle.radius, particle.y-particle.radius, particle.radius*2, particle.radius*2

    ctx.fill()

  null
