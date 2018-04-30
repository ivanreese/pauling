"use strict"

API = null

surfaces =
  vectors:
    doSimulate: true
  snow:
    doSimulate: true
    doRender: true
    scale: 1
  snowbuffer:
    doRender: true
    doSimulate: true
  particles:
    doSimulate: true
    doRender: true
    clear: true
  arcs:
    doSimulate: true
    doRender: true
    clear: true

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
mouseX = 0
mouseY = 0
lastMouseX = null
lastMouseY = null
mouseDx = null
mouseDy = null
mouseDist = null

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
particleMaxEnergy = 30
maxParticleRadius = 70
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
worstSnow = 500
bestSnow = 1000
snowId = 0

fadeTime = 30
bufferTime = 0
