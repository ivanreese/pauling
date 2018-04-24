surfaces.particles.setup = (surface)->


surfaces.particles.render = (ctx, t)->
  for particle in particles
    ""
  null



makeParticle = (x, y)->
  index = particles.length
  particles.push
    name: name = "particle #{index}"
    phasor: makeNoisePhasor "aX", 10, 10, 0, index * 10 % 100, 10 * Math.floor index / 100
    x: x
    y: y
    r: 1
