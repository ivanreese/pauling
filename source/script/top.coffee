"use strict"

PI = Math.PI
TAU = PI * 2


clip = (input, inputMin = 0, inputMax = 1)->
  Math.min inputMax, Math.max inputMin, input


scale = (input, inputMin = 0, inputMax = 1, outputMin = 0, outputMax = 1, doClip = false)->
  return outputMin if inputMin is inputMax # Avoids a divide by zero
  input = clip(input, inputMin, inputMax) if doClip
  input -= inputMin
  input /= inputMax - inputMin
  input *= outputMax - outputMin
  input += outputMin
  return input


lerp = (a,b,t)-> (1-t)*a + t*b
