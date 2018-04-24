"use strict"

API = null

surfaces =
  phasors:
    active: true
  particles:
    active: false
  main:
    active: true
    blurCurve: .5 # 0 to 1 or higher
    blurOpacity: .7
    blurSamples: 10
    blurTime: .05
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

phasors = {}

hue = 227
sat = 20

# This tweaks phasor radius/shift values to be more intuitive
phasorComplexityTuning = 1/50
