surfaces.particles.move = (x, y)->
  lastParticleX ?= x
  lastParticleY ?= y
  return if Math.abs(lastParticleX - x) < 12 and Math.abs(lastParticleY - y) < 12

  dx = lastParticleX - x
  dy = lastParticleY - y
  dist = Math.sqrt dx*dx + dy*dy
  energy = 0.1 * Math.pow dist, 1.5
  energy = clip energy, particleMinEnergy, particleMaxEnergy

  lastParticleX = x
  lastParticleY = y

  index = particleID++
  xName = "particle#{index}x"
  yName = "particle#{index}y"
  makeNoisePhasor xName, 30, 30, 0, Math.random()*100, 0
  makeNoisePhasor yName, 30, 30, 0, Math.random()*100, 0
  particles.push
    sx: x
    sy: y
    r: 1
    maxAge: 2 + particles.length/100#Math.pow rand(.5, 2), 3
    energy: energy
    xName: xName
    yName: yName


surfaces.particles.simulate = (t, dt)->
  i = particles.length
  while i > 0
    i--
    frac = i/particles.length
    particle = particles[i]

    particle.birth ?= t
    particle.age = t - particle.birth

    if particles.length > maxParticles
      particle.maxAge -= (particles.length-maxParticles)/maxParticles

    energyFrac = scale particle.energy, particleMinEnergy, particleMaxEnergy, 0, 1, true
    ageFrac = scale particle.age, 0, particle.maxAge, 1, 0, true
    particle.radius = scale energyFrac * ageFrac, 0, 1, 3, 100

    particle.r = Math.pow((particle.age/particle.maxAge)*6, 3)#Math.sqrt(particle.age) * 100

    particle.birthAlpha = scale particle.age, 0, particle.maxAge*.1, 0, 1, true
    particle.deathAlpha = scale particle.age, particle.maxAge*.5, particle.maxAge, 1, 0, true
    particle.alpha = Math.min 1, particle.birthAlpha, particle.deathAlpha+.1

    if particle.deathAlpha < 1
      spawnSnow particle.x, particle.y, particle.radius


    deceased = particle.age > particle.maxAge
    offScreen = particle.x < -10 or particle.y < -10 or particle.x > width + 10 or particle.y > height + 10

    if deceased or offScreen
      deleteParticle particle, frac
      particles.splice i, 1

  null


surfaces.particles.render = (ctx, t)->
  for particle, i in particles by -1
    frac = i/particles.length

    particle.x = particle.sx + particle.r * sampleNoisePhasor(particle.xName, t).v
    particle.y = particle.sy + particle.r * sampleNoisePhasor(particle.yName, t).v

    ctx.beginPath()
    # ctx.globalAlpha = .7

    ctx.arc particle.x, particle.y, particle.radius, 0, TAU

    if particle.birthAlpha < 1
      h = scale particle.birthAlpha, 0, 1, 42, 20
      ctx.fillStyle = "hsla(#{h},100%,50%,.7)"
    else
      h = scale frac, 0, 1, 198, 284
      s = scale frac, 0, 1, 100, 44
      l = scale frac, 0, 1, 44, 55
      ctx.fillStyle = "hsla(#{h},#{s}%,#{l}%,#{particle.alpha})"
    ctx.fill()

  null


deleteParticle = (particle, frac)->
  deletePhasor particle.xName
  deletePhasor particle.yName
