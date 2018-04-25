"use strict"

API = null

surfaces =
  vectors:
    active: true
    clear: true
  snow:
    active: true
  phasors:
    active: false
  particles:
    active: true
    clear: true
  main:
    active: false
    blurCurve: 0 # 0 to 1 or higher
    blurOpacity: .7
    blurSamples: 10
    blurTime: 3
    clear: true
  glow:
    active: false
    clear: true
    scale: .5

container = null

dpr = 1#Math.max 1, Math.round(window.devicePixelRatio)
width = 0
height = 0

running = false
renderRequested = false

timeScale = 1

noiseRadius = .1
circleSpeed = .1

noiseMemory = []

particles = []
maxParticles = 300
minParticleArcDist = 5
maxParticleArcDist = 50
particleID = 0
lastParticleX = null
lastParticleY = null

phasors = {}

hue = 227
sat = 15
bgLightness = 15

# This tweaks phasor radius/shift values to be more intuitive
phasorComplexityTuning = 1/50

vectorSpacing = 100
vectors = []

lastTime = null

snow = []
