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


lerp = (a,b,t)->
  (1-t) * a + t * b


rand = (min, max)->
  if not max?
    max = min
    min = 0
  scale Math.random(), 0, 1, min, max


granularlize = (grainSize, i)->
  grainSize * Math.round i / grainSize


noiseMemory = []
memoizedNoise = (granularity, x, y)->
  t = Math.round(x / granularity)
  s = Math.round(y / granularity)
  gmem = noiseMemory[granularity] ?= []
  tmem = gmem[t] ?= []
  smem = tmem[s] ?= simplex2 x, y


makeNoisePhasor = (name, cycleTime, radius = 1, phase = 0, xOffset = 0, yOffset = 0)->
  # radius is a measure of complexity, with intuitive values in the range 1 to 100
  # phase is measured in TAU-radians and thus should be between 0 and 1
  # offsets can be negative or positive
  phasors[name] =
    name: name
    type: "noise"
    radius: radius * phasorComplexityTuning
    cycleTime: cycleTime
    phase: phase * TAU
    xOffset: xOffset * phasorComplexityTuning
    yOffset: yOffset * phasorComplexityTuning


sampleNoisePhasor = (name, time, fn = simplex2)->
  phasor = phasors[name]
  p = phasor.phase + TAU * time / phasor.cycleTime
  x: x = Math.cos p
  y: y = Math.sin p
  v: fn phasor.xOffset + phasor.radius * x, phasor.yOffset + phasor.radius * y


deletePhasor = (name)->
  delete phasors[name]
