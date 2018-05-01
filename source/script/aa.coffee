"use strict"

API = null

surfaces =
  snow:
    doSimulate: true
    doRender: true
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
currentParticleEnergy = 0

arcs = []

vectorSpacing = 100
vectors = []

snow = []
maxSnow = 600
worstSnow = 400
bestSnow = 900
snowId = 0

fadeTime = 25
bufferTime = 0
