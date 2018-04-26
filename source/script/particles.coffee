surfaces.particles.simulate = (t, dt)->
  i = particles.length
  while i > 0
    i--
    particle = particles[i]

    particle.birth ?= t
    particle.age = t - particle.birth

    if particles.length > maxParticles
      particle.maxAge -= (particles.length-maxParticles)/maxParticles

    particle.r = Math.sqrt(particle.age) * 100

    particle.x = particle.sx + particle.r * sampleNoisePhasor(particle.xName, t).v
    particle.y = particle.sy + particle.r * sampleNoisePhasor(particle.yName, t).v

    particle.birthAlpha = scale particle.age, 0, particle.maxAge*.1, 0, 1, true
    particle.deathAlpha = scale particle.age, particle.maxAge*.9, particle.maxAge, 1, 0, true
    particle.alpha = Math.min particle.birthAlpha, particle.deathAlpha

    deceased = particle.age > particle.maxAge
    offScreen = particle.x < -10 or particle.y < -10 or particle.x > width + 10 or particle.y > height + 10

    if deceased or offScreen
      deleteParticle particle
      particles.splice i, 1

  null


surfaces.particles.render = (ctx, t)->
  for particle, i in particles
    frac = i/particles.length

    ctx.beginPath()
    ctx.arc particle.x, particle.y, particle.energy, 0, TAU

    if particle.birthAlpha < 1
      ctx.fillStyle = "hsla(19,100%,#{particle.alpha*50+50}%,#{particle.alpha})"
    else
      h = scale frac, 0, 1, 198, 284
      s = scale frac, 0, 1, 100, 44
      l = scale frac, 0, 1, 44, 55
      ctx.fillStyle = "hsla(#{h},#{s}%,#{l}%,#{particle.alpha})"
    ctx.fill()

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
