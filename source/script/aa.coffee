"use strict"

API = null

surfaces =
  vectors:
    doSimulate: true
    doRender: false
    clear: true
  snow:
    doSimulate: true
    doRender: true
    scale: 2
  particles:
    doSimulate: true
    doRender: true
    blurCurve: 0 # 0 to 1 or higher
    blurOpacity: .7
    blurSamples: 10
    blurTime: .2
    clear: true
  snowbuffer:
    doRender: true
  arcs:
    doSimulate: true
    doRender: true
    blurCurve: 1 # 0 to 1 or higher
    blurOpacity: .4
    blurSamples: 4
    blurTime: 1
    clear: true
  phasors:
    doSimulate: false
    doRender: false
  main:
    doSimulate: false
    doRender: false
    blurCurve: 0 # 0 to 1 or higher
    blurOpacity: .7
    blurSamples: 10
    blurTime: 3
    clear: true
  glow:
    doSimulate: false
    doRender: false
    clear: true
    scale: .5

container = null

dpr = 1#Math.max 1, Math.round(window.devicePixelRatio)
width = 0
height = 0

running = false
renderRequested = false

worldTime = 0

timeScale = 1

noiseRadius = .1
circleSpeed = .1

noiseMemory = []

particles = []
maxParticles = 300
minParticleArcDist = 5
maxParticleArcDist = 100
particleID = 0
lastParticleX = null
lastParticleY = null
particleMinEnergy = 1
particleMaxEnergy = 30

phasors = {}

hue = 227
sat = 15
bgLightness = 15

# This tweaks phasor radius/shift values to be more intuitive
phasorComplexityTuning = 1/50

vectorSpacing = 100
vectors = []
vectorFading = 0

lastTime = null

snow = []
