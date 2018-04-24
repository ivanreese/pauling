surfaces.glow.render = (ctx, t)->
  scale = surfaces.glow.scale

  ctx.globalAlpha = 0.025
  dist = 5
  samples = 3
  for i in [0...samples]
    dx = dist * Math.cos TAU * i/samples
    dy = dist * Math.sin TAU * i/samples
    ctx.drawImage surfaces.main.canvas, dx*scale, dy*scale, width*scale, height*scale

  ctx.globalAlpha = 0.015
  dist = 10
  samples = 7
  for i in [0...samples]
    dx = dist * Math.cos TAU * i/samples
    dy = dist * Math.sin TAU * i/samples
    ctx.drawImage surfaces.main.canvas, dx*scale, dy*scale, width*scale, height*scale

  ctx.globalAlpha = 0.01
  dist = 15
  samples = 11
  for i in [0...samples]
    dx = dist * Math.cos TAU * i/samples
    dy = dist * Math.sin TAU * i/samples
    ctx.drawImage surfaces.main.canvas, dx*scale, dy*scale, width*scale, height*scale

  null
