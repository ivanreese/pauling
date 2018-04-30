surfaces.snowbuffer.render = (ctx, t, dt)->
  bufferTime += mouseDist/180 + dt

  if bufferTime > fadeTime
    bufferTime = 0
    ctx.clearRect 0, 0, width, height
    ctx.drawImage surfaces.snow.canvas, 0, 0, width, height
    surfaces.snow.context.clearRect 0, 0, width, height

  surfaces.snowbuffer.canvas.style.opacity = Math.pow scale(bufferTime, 0, fadeTime, 1, 0, true), .7
