surfaces.particles.setup = (surface)->


surfaces.particles.render = (ctx, t)->
  ctx.strokeWidth = 2
  maxParticles = 300

  i = 0
  while i < particles.length
    particle = particles[i]

    particle.birth ?= t
    particle.age = t - particle.birth

    if particles.length > maxParticles
      particle.maxAge -= (particles.length-maxParticles)/maxParticles

    particle.r = Math.sqrt(particle.age) * 100

    particle.x = particle.sx + particle.r * sampleNoisePhasor(particle.phasor.name, t).v
    particle.y = particle.sy + particle.r * sampleNoisePhasor(particle.phasor.name, t + PI).v

    ctx.beginPath()
    ctx.arc particle.x, particle.y, 2, 0, TAU
    particle.alpha = scale particle.age, particle.maxAge*.9, particle.maxAge, 1, 0, true
    ctx.fillStyle = "rgba(255,255,255,#{particle.alpha})"
    ctx.fill()

    deceased = particle.age > particle.maxAge
    offScreen = particle.x < -10 or particle.y < -10 or particle.x > width + 10 or particle.y > height + 10

    if deceased or offScreen
      deleteParticle particle
      particles.splice i, 1
    else
      i++

  for a, ai in particles
    for b, bi in particles when bi > ai
      dx = a.x-b.x
      dy = a.y-b.y
      dist = Math.sqrt dx*dx + dy*dy
      if 20 < dist and dist < 50
        renderLine ctx, t, a, b, dist

  null


surfaces.particles.move = (x, y)->
  makeParticle x, y

particleID = 0


lastParticleX = 0
lastParticleY = 0


makeParticle = (x, y)->
  return if Math.abs(lastParticleX - x) < 1 and Math.abs(lastParticleY - y) < 1

  dx = lastParticleX - x
  dy = lastParticleY - y
  energy = Math.sqrt dx*dx + dy*dy

  lastParticleX = x
  lastParticleY = y

  index = particleID++
  phasorX = rand 200
  phasorY = rand 200
  particles.push
    name: name = "particle #{index}"
    phasor: makeNoisePhasor name, 10, 10, Math.random(), phasorX, phasorY
    sx: x
    sy: y
    r: 1
    maxAge: rand 1, 10

deleteParticle = (particle)->
  deletePhasor particle.phasor.name



renderLine = (ctx, t, a, b, dist)->

  delay = dist / 100
  steps = Math.ceil Math.sqrt dist

  x = a.sx + a.r * sampleNoisePhasor(a.phasor.name, t).v
  y = a.sy + a.r * sampleNoisePhasor(a.phasor.name, t + PI).v

  ctx.moveTo x, y


  for i in [1..steps]
    frac = i / steps
    frac2 = frac * scale Math.cos(TAU * i/steps), -1, 1, 0, 1

    d1 = t-delay*frac
    d2 = t-delay*(1-frac)

    x1 = a.sx + a.r * sampleNoisePhasor(a.phasor.name, d1).v
    y1 = a.sy + a.r * sampleNoisePhasor(a.phasor.name, d1 + PI).v
    x2 = b.sx + b.r * sampleNoisePhasor(b.phasor.name, d2).v
    y2 = b.sy + b.r * sampleNoisePhasor(b.phasor.name, d2 + PI).v

    x = lerp x1, x2, frac2
    y = lerp y1, y2, frac2

    h = frac * 360 |0
    alpha = Math.min a.alpha, b.alpha, scale dist, 20, 50, 1, 0, true
    ctx.strokeStyle = "hsla(#{h}, #{sat}%, 50%, #{alpha})"
    ctx.lineTo x, y
    ctx.stroke()
    ctx.beginPath()
    ctx.moveTo x, y
  null
