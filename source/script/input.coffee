mousemove = (e)->
  hasMoved = true
  mouseX = e.clientX
  mouseY = e.clientY

touchmove = (e)->
  e.preventDefault()
  hasMoved = true
  mouseX = e.touches[0].clientX
  mouseY = e.touches[0].clientY
