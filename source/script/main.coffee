"use strict"

window.Pauling = (container)->

  blurCanvas = document.createElement "canvas"
  container.appendChild blurCanvas
  blurContext = blurCanvas.getContext "2d"
  # blurCanvas.style["-webkit-filter"] = "blur(20px)"


  canvas = document.createElement "canvas"
  container.appendChild canvas
  context = canvas.getContext "2d"


  for elm in [container, canvas, blurCanvas]
    elm.style.position = "absolute"
    elm.style.top = elm.style.left = "0"
    elm.style.width = elm.style.height = "100%"

  container.style.backgroundColor = "hsl(230, 25%, 13%)"


  dpr = Math.max 1, Math.round(window.devicePixelRatio)
  width = 0
  height = 0
  running = false
  renderRequested = false
  count = 0
  lines = null


  resize = ()->
    width = canvas.width = blurCanvas.width = container.offsetWidth * dpr
    height = canvas.height = blurCanvas.height = container.offsetHeight * dpr


  requestResize = ()->
    widthChanged = 2 < Math.abs width - container.offsetWidth * dpr
    heightChanged = 50 < Math.abs height - container.offsetHeight * dpr
    if widthChanged or heightChanged
      requestAnimationFrame (time)->
        first = true
        resize()
        requestRender()


  requestRender = ()->
    unless renderRequested
      renderRequested = true
      requestAnimationFrame render

  rand = (max)-> Math.floor Math.random() * max

  makeP = ()->
    x:rand width
    y:rand height
    xDir: 2 * rand(2) - 1
    yDir: 2 * rand(2) - 1

  makeL = ()->
    p1: makeP()
    p2: makeP()

  moveP = (p)->
    p.x += p.xDir * 5
    p.y += p.yDir * 5
    p.xDir *= -1 if p.x <= 0 or p.x >= width
    p.yDir *= -1 if p.y <= 0 or p.y >= height

  moveL = (l)->
    moveP l.p1
    moveP l.p2

  render = (time)->
    renderRequested = false
    requestRender() if running
    return if document.hidden

    # return unless count++ % 2 is 0

    for line in lines

      moveL line

      context.beginPath()
      context.strokeStyle = "hsl(#{Math.random() * 360}, 100%, 50%)"
      context.lineWidth = 5
      context.moveTo line.p1.x, line.p1.y
      context.lineTo line.p2.x, line.p2.y
      context.stroke()

    # d = context.getImageData 0, 0, width, height
    # byte = 3
    # while byte < d.data.length
    #   d.data[byte] = d.data[byte] * .95 |0
    #   byte += 4
    # context.putImageData d, 0, 0

    context.save()
    context.globalCompositeOperation = "destination-out"
    context.globalAlpha = .997
    context.fillStyle = "#000"
    context.fillRect 0, 0, width, height
    context.restore()

    blurContext.drawImage canvas, 0, 0, width, height


    null


  # INIT ##########################################################################################


  window.addEventListener "resize", requestResize
  resize()

  lines = (makeL() for i in [0...50])

  return API =
    start: ()->

      running = true
      requestRender()

    stop: ()->
      running = false
