surfaces.glow.render = (ctx, t)->
  scale = surfaces.glow.scale

  ctx.globalAlpha = 0.015
  dist = 10
  samples = 7
  for i in [0...samples]
    dx = dist * Math.cos TAU * i/samples
    dy = dist * Math.sin TAU * i/samples
    ctx.drawImage surfaces.snowbuffer.canvas, dx*scale, dy*scale, width*scale, height*scale
    ctx.drawImage surfaces.snow.canvas, dx*scale, dy*scale, width*scale, height*scale


  null
