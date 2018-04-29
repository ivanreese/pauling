"use strict"

API = null

surfaces =
  vectors:
    doSimulate: true
  snow:
    doSimulate: false
    doRender: false
    scale: 1
  snowbuffer:
    doRender: true
    doSimulate: true
  particles:
    doSimulate: true
    doRender: true
    # blurCurve: .2 # 0 to 1 or higher
    # blurOpacity: .9
    # blurSamples: 3
    # blurTime: .5
    clear: true
  arcs:
    doSimulate: true
    doRender: true
    # blurCurve: 0 # 0 to 1 or higher
    # blurOpacity: .5
    # blurSamples: 3
    # blurTime: 1.2
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
lastTime = null

timeScale = 1

hasMoved = false
clientX = 0
clientY = 0

# This tweaks phasor radius/shift values to be more intuitive
phasorComplexityTuning = 1/50

phasors = {}

noiseRadius = .1
circleSpeed = .1

noiseMemory = []

hue = 227
sat = 15
bgLightness = 15

particles = []
maxParticles = 400
minParticleArcDist = 5
maxParticleArcDist = 100
particleID = 0
lastParticleX = null
lastParticleY = null
particleMinEnergy = 1
particleMaxEnergy = 35
maxParticleRadius = 90
lastParticleSpawnTime = -10000
currentParticleEnergy = 0
maxArcsPerParticle = 5
particleMoveCount = 0

arcs = []

vectorSpacing = 100
vectors = []
vectorFading = 0

snow = []
maxSnow = 1000
worstSnow = 0
bestSnow = 3000
snowId = 0

fadeTime = 10
bufferTime = 0
