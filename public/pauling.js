(function() {
  var API, F2, G2, Grad, PI, TAU, absolutePos, arcs, bail, bestSnow, bufferTime, clearContainer, clip, container, currentParticleEnergy, deletePhasor, fadeTime, grad3, gradP, granularlize, hasMoved, height, lastMouseX, lastMouseY, lastParticleX, lastParticleY, lastTime, lerp, makeArc, makeNoisePhasor, maxParticleArcDist, maxParticleRadius, maxParticles, maxSnow, minParticleArcDist, mouseDist, mouseDx, mouseDy, mouseX, mouseY, mousemove, p, particleID, particleMaxEnergy, particleMinEnergy, particles, perm, phasorComplexityTuning, phasors, rand, render, renderRequested, requestRender, requestResize, resetDefaults, resize, running, sampleNoisePhasor, scale, setSeed, setupSurface, simplex2, snow, snowId, spawnSnow, start, stop, surfaces, timeScale, touchmove, vecSnowDist, vectorSpacing, vectors, width, worldTime, worstSnow;

  API = null;

  surfaces = {
    snow: {
      doSimulate: true,
      doRender: true
    },
    snowbuffer: {
      doRender: true,
      doSimulate: true
    },
    particles: {
      doSimulate: true,
      doRender: true,
      clear: true
    },
    arcs: {
      doSimulate: true,
      doRender: true,
      clear: true
    }
  };

  container = null;

  width = 0;

  height = 0;

  running = false;

  renderRequested = false;

  worldTime = 0;

  lastTime = null;

  timeScale = 1;

  hasMoved = false;

  mouseX = 0;

  mouseY = 0;

  lastMouseX = null;

  lastMouseY = null;

  mouseDx = null;

  mouseDy = null;

  mouseDist = null;

  phasorComplexityTuning = 1 / 50;

  phasors = {};

  particles = [];

  maxParticles = 400;

  minParticleArcDist = 5;

  maxParticleArcDist = 100;

  particleID = 0;

  lastParticleX = null;

  lastParticleY = null;

  particleMinEnergy = 1;

  particleMaxEnergy = 30;

  maxParticleRadius = 70;

  currentParticleEnergy = 0;

  arcs = [];

  vectorSpacing = 100;

  vectors = [];

  snow = [];

  maxSnow = 600;

  worstSnow = 400;

  bestSnow = 900;

  snowId = 0;

  fadeTime = 25;

  bufferTime = 0;

  resetDefaults = function() {
    phasors = {};
    particles = [];
    particleID = 0;
    lastParticleX = null;
    lastParticleY = null;
    currentParticleEnergy = 0;
    arcs = [];
    vectors = [];
    snow = [];
    maxSnow = 600;
    snowId = 0;
    return bufferTime = 0;
  };

  makeArc = function(a, b, dist, energy) {
    return arcs.push({
      a: a,
      b: b,
      dist: dist,
      energy: energy
    });
  };

  surfaces.arcs.render = function(ctx, t, dt) {
    var a, arc, b, d1, d2, delay, frac, i, k, l, light, ref, s, steps, x, x1, x2, y, y1, y2;
    if (!(arcs.length > 0)) {
      return false;
    }
    for (i = k = arcs.length - 1; k >= 0; i = k += -1) {
      arc = arcs[i];
      a = arc.a;
      b = arc.b;
      if (a.dead || b.dead) {
        delete arcs.splice(i, 1);
        continue;
      }
      delay = .5 + 2 * a.ageFrac;
      steps = Math.ceil(delay * arc.dist / 13);
      x = a.sx + a.r * sampleNoisePhasor(a.xName, t).v;
      y = a.sy + a.r * sampleNoisePhasor(a.yName, t).v;
      ctx.beginPath();
      ctx.moveTo(x, y);
      ctx.globalAlpha = Math.pow(Math.min(a.deathFrac, b.deathFrac), .8);
      light = scale(a.light, 0, 100, 40, 100, true);
      ctx.strokeStyle = "hsl(" + a.hue + ", 100%, " + light + "%)";
      ctx.lineWidth = scale(a.radius + b.radius, 2, maxParticleRadius * 2, 1, 5, true);
      for (s = l = 1, ref = steps; 1 <= ref ? l <= ref : l >= ref; s = 1 <= ref ? ++l : --l) {
        frac = s / steps;
        d1 = t - delay * frac;
        d2 = t - delay * (1 - frac);
        x1 = a.sx + a.r * sampleNoisePhasor(a.xName, d1).v;
        y1 = a.sy + a.r * sampleNoisePhasor(a.yName, d1).v;
        x2 = b.sx + b.r * sampleNoisePhasor(b.xName, d2).v;
        y2 = b.sy + b.r * sampleNoisePhasor(b.yName, d2).v;
        x = lerp(x1, x2, frac);
        y = lerp(y1, y2, frac);
        ctx.lineTo(x, y);
      }
      ctx.stroke();
    }
    return true;
  };

  absolutePos = function(elm) {
    elm.style.position = "absolute";
    elm.style.top = elm.style.left = "0";
    return elm.style.width = elm.style.height = "100%";
  };

  setupSurface = function(surface) {
    surface.canvas = document.createElement("canvas");
    container.appendChild(surface.canvas);
    absolutePos(surface.canvas);
    surface.context = surface.canvas.getContext("2d");
    return typeof surface.setup === "function" ? surface.setup(surface) : void 0;
  };

  clearContainer = function() {
    return container.innerHTML = "";
  };

  resize = function() {
    var name, surface;
    width = container.offsetWidth;
    height = container.offsetHeight;
    for (name in surfaces) {
      surface = surfaces[name];
      surface.canvas.width = width;
      surface.canvas.height = height;
      if (typeof surface.resize === "function") {
        surface.resize(surface);
      }
    }
    return null;
  };

  requestResize = function() {
    var heightChanged, widthChanged;
    widthChanged = 2 < Math.abs(width - container.offsetWidth);
    heightChanged = 50 < Math.abs(height - container.offsetHeight);
    if (widthChanged || heightChanged) {
      return requestAnimationFrame(function(time) {
        var first;
        first = true;
        resize();
        if (!renderRequested) {
          return render();
        }
      });
    }
  };

  mousemove = function(e) {
    hasMoved = true;
    mouseX = e.clientX;
    return mouseY = e.clientY;
  };

  touchmove = function(e) {
    hasMoved = true;
    mouseX = e.touches[0].clientX;
    return mouseY = e.touches[0].clientY;
  };

  PI = Math.PI;

  TAU = PI * 2;

  clip = function(input, inputMin, inputMax) {
    if (inputMin == null) {
      inputMin = 0;
    }
    if (inputMax == null) {
      inputMax = 1;
    }
    return Math.min(inputMax, Math.max(inputMin, input));
  };

  scale = function(input, inputMin, inputMax, outputMin, outputMax, doClip) {
    if (inputMin == null) {
      inputMin = 0;
    }
    if (inputMax == null) {
      inputMax = 1;
    }
    if (outputMin == null) {
      outputMin = 0;
    }
    if (outputMax == null) {
      outputMax = 1;
    }
    if (doClip == null) {
      doClip = false;
    }
    if (inputMin === inputMax) {
      return outputMin;
    }
    if (doClip) {
      input = clip(input, inputMin, inputMax);
    }
    input -= inputMin;
    input /= inputMax - inputMin;
    input *= outputMax - outputMin;
    input += outputMin;
    return input;
  };

  lerp = function(a, b, t) {
    return (1 - t) * a + t * b;
  };

  rand = function(min, max) {
    if (max == null) {
      max = min;
      min = 0;
    }
    return scale(Math.random(), 0, 1, min, max);
  };

  granularlize = function(grainSize, i) {
    return grainSize * Math.round(i / grainSize);
  };

  makeNoisePhasor = function(name, cycleTime, radius, phase, xOffset, yOffset) {
    if (radius == null) {
      radius = 1;
    }
    if (phase == null) {
      phase = 0;
    }
    if (xOffset == null) {
      xOffset = 0;
    }
    if (yOffset == null) {
      yOffset = 0;
    }
    return phasors[name] = {
      name: name,
      type: "noise",
      radius: radius * phasorComplexityTuning,
      cycleTime: cycleTime,
      phase: phase * TAU,
      xOffset: xOffset * phasorComplexityTuning,
      yOffset: yOffset * phasorComplexityTuning
    };
  };

  sampleNoisePhasor = function(name, time, fn) {
    var p, phasor, x, y;
    if (fn == null) {
      fn = simplex2;
    }
    phasor = phasors[name];
    p = phasor.phase + TAU * time / phasor.cycleTime;
    return {
      x: x = Math.cos(p),
      y: y = Math.sin(p),
      v: fn(phasor.xOffset + phasor.radius * x, phasor.yOffset + phasor.radius * y)
    };
  };

  deletePhasor = function(name) {
    return delete phasors[name];
  };

  F2 = 0.5 * (Math.sqrt(3) - 1);

  G2 = (3 - Math.sqrt(3)) / 6;

  Grad = function(x, y, z) {
    this.x = x;
    this.y = y;
    this.z = z;
  };

  Grad.prototype.dot2 = function(x, y) {
    return this.x * x + this.y * y;
  };

  Grad.prototype.dot3 = function(x, y, z) {
    return this.x * x + this.y * y + this.z * z;
  };

  grad3 = [new Grad(1, 1, 0), new Grad(-1, 1, 0), new Grad(1, -1, 0), new Grad(-1, -1, 0), new Grad(1, 0, 1), new Grad(-1, 0, 1), new Grad(1, 0, -1), new Grad(-1, 0, -1), new Grad(0, 1, 1), new Grad(0, -1, 1), new Grad(0, 1, -1), new Grad(0, -1, -1)];

  p = [151, 160, 137, 91, 90, 15, 131, 13, 201, 95, 96, 53, 194, 233, 7, 225, 140, 36, 103, 30, 69, 142, 8, 99, 37, 240, 21, 10, 23, 190, 6, 148, 247, 120, 234, 75, 0, 26, 197, 62, 94, 252, 219, 203, 117, 35, 11, 32, 57, 177, 33, 88, 237, 149, 56, 87, 174, 20, 125, 136, 171, 168, 68, 175, 74, 165, 71, 134, 139, 48, 27, 166, 77, 146, 158, 231, 83, 111, 229, 122, 60, 211, 133, 230, 220, 105, 92, 41, 55, 46, 245, 40, 244, 102, 143, 54, 65, 25, 63, 161, 1, 216, 80, 73, 209, 76, 132, 187, 208, 89, 18, 169, 200, 196, 135, 130, 116, 188, 159, 86, 164, 100, 109, 198, 173, 186, 3, 64, 52, 217, 226, 250, 124, 123, 5, 202, 38, 147, 118, 126, 255, 82, 85, 212, 207, 206, 59, 227, 47, 16, 58, 17, 182, 189, 28, 42, 223, 183, 170, 213, 119, 248, 152, 2, 44, 154, 163, 70, 221, 153, 101, 155, 167, 43, 172, 9, 129, 22, 39, 253, 19, 98, 108, 110, 79, 113, 224, 232, 178, 185, 112, 104, 218, 246, 97, 228, 251, 34, 242, 193, 238, 210, 144, 12, 191, 179, 162, 241, 81, 51, 145, 235, 249, 14, 239, 107, 49, 192, 214, 31, 181, 199, 106, 157, 184, 84, 204, 176, 115, 121, 50, 45, 127, 4, 150, 254, 138, 236, 205, 93, 222, 114, 67, 29, 24, 72, 243, 141, 128, 195, 78, 66, 215, 61, 156, 180];

  perm = new Array(512);

  gradP = new Array(512);

  setSeed = function(seed) {
    var i, v;
    if (seed > 0 && seed < 1) {
      seed *= 65536;
    }
    seed = Math.floor(seed);
    if (seed < 256) {
      seed |= seed << 8;
    }
    i = 0;
    while (i < 256) {
      v = void 0;
      if (i & 1) {
        v = p[i] ^ seed & 255;
      } else {
        v = p[i] ^ seed >> 8 & 255;
      }
      perm[i] = perm[i + 256] = v;
      gradP[i] = gradP[i + 256] = grad3[v % 12];
      i++;
    }
  };

  setSeed(0);

  simplex2 = function(xin, yin) {
    var gi0, gi1, gi2, i, i1, j, j1, n0, n1, n2, s, t, t0, t1, t2, x0, x1, x2, y0, y1, y2;
    n0 = void 0;
    n1 = void 0;
    n2 = void 0;
    s = (xin + yin) * F2;
    i = Math.floor(xin + s);
    j = Math.floor(yin + s);
    t = (i + j) * G2;
    x0 = xin - i + t;
    y0 = yin - j + t;
    i1 = void 0;
    j1 = void 0;
    if (x0 > y0) {
      i1 = 1;
      j1 = 0;
    } else {
      i1 = 0;
      j1 = 1;
    }
    x1 = x0 - i1 + G2;
    y1 = y0 - j1 + G2;
    x2 = x0 - 1 + 2 * G2;
    y2 = y0 - 1 + 2 * G2;
    i &= 255;
    j &= 255;
    gi0 = gradP[i + perm[j]];
    gi1 = gradP[i + i1 + perm[j + j1]];
    gi2 = gradP[i + 1 + perm[j + 1]];
    t0 = 0.5 - (x0 * x0) - (y0 * y0);
    if (t0 < 0) {
      n0 = 0;
    } else {
      t0 *= t0;
      n0 = t0 * t0 * gi0.dot2(x0, y0);
    }
    t1 = 0.5 - (x1 * x1) - (y1 * y1);
    if (t1 < 0) {
      n1 = 0;
    } else {
      t1 *= t1;
      n1 = t1 * t1 * gi1.dot2(x1, y1);
    }
    t2 = 0.5 - (x2 * x2) - (y2 * y2);
    if (t2 < 0) {
      n2 = 0;
    } else {
      t2 *= t2;
      n2 = t2 * t2 * gi2.dot2(x2, y2);
    }
    return 70 * (n0 + n1 + n2);
  };

  surfaces.particles.move = function(x, y, t, dt) {
    var arcEnergy, dist, dx, dy, energy, energyFrac, i, index, k, pair, particle, ref, ref1, xName, yName;
    currentParticleEnergy += .01 * Math.pow(mouseDist, 1.7);
    currentParticleEnergy = clip(currentParticleEnergy, particleMinEnergy, particleMaxEnergy);
    energy = Math.random() * currentParticleEnergy;
    energyFrac = scale(energy, particleMinEnergy, particleMaxEnergy, 0.01, 1, true);
    index = particleID++;
    xName = "particle" + index + "x";
    yName = "particle" + index + "y";
    makeNoisePhasor(xName, 10, 20, 0, Math.random() * 1000, 0);
    makeNoisePhasor(yName, 10, 20, 0, Math.random() * 1000, 0);
    particles.push(particle = {
      sx: x + (Math.random() - .5) * scale(energyFrac, 0, 1, 10, 220),
      sy: y + (Math.random() - .5) * scale(energyFrac, 0, 1, 10, 220),
      birth: t,
      maxAge: 1.1,
      dead: false,
      energy: energy,
      energyFrac: energyFrac,
      xName: xName,
      yName: yName,
      shape: Math.floor(Math.pow(Math.random(), 2.5) * 9),
      angle: Math.random(),
      arcs: 0,
      id: index,
      spawnCount: 0
    });
    for (i = k = ref = particles.length - 3, ref1 = particles.length - 1; ref <= ref1 ? k < ref1 : k > ref1; i = ref <= ref1 ? ++k : --k) {
      if (!(i > 0)) {
        continue;
      }
      pair = particles[i];
      dx = particle.sx - pair.sx;
      dy = particle.sy - pair.sy;
      dist = Math.sqrt(dx * dx + dy * dy);
      arcEnergy = 10 * (particle.energy + pair.energy) / dist;
      if (arcEnergy > 1) {
        makeArc(pair, particle, dist, arcEnergy);
      }
    }
    return null;
  };

  surfaces.particles.simulate = function(t, dt) {
    var ageFactor, ageFrac, ageFracInv, deadIndex, frac, i, k, l, particle, radiusFrac, ref;
    if (!(particles.length > 0)) {
      return;
    }
    currentParticleEnergy *= .9;
    deadIndex = null;
    for (i = k = particles.length - 1; k >= 0; i = k += -1) {
      particle = particles[i];
      frac = i / particles.length;
      particle.age = t - particle.birth;
      ageFrac = particle.age / particle.maxAge;
      particle.ageFrac = ageFrac;
      ageFracInv = 1 - ageFrac;
      if (particles.length > maxParticles) {
        particle.maxAge -= .1 * (particles.length - maxParticles) / maxParticles;
      }
      particle.r = scale(Math.pow(ageFrac, 2), 0, 1, 10, 80 + 40 * particle.energyFrac);
      particle.x = particle.sx + particle.r * sampleNoisePhasor(particle.xName, t).v;
      particle.y = particle.sy + particle.r * sampleNoisePhasor(particle.yName, t).v;
      particle.birthFrac = Math.min(1, ageFrac * 5);
      particle.deathFrac = Math.min(1, ageFracInv / .7);
      ageFactor = Math.min(ageFracInv, Math.sqrt(particle.birthFrac));
      radiusFrac = Math.pow(particle.energyFrac * ageFactor, .5);
      particle.radius = radiusFrac * maxParticleRadius;
      if (particle.birthFrac < 1) {
        particle.hue = scale(particle.birthFrac, 0, 1, 42, 20);
        particle.sat = "100";
        particle.light = "50";
      } else {
        particle.hue = scale(frac, 0, 1, 198, 284);
        particle.sat = scale(frac, 0, 1, 100, 44);
        particle.light = Math.min(100, scale(frac, 0, 1, 44, 55 / particle.deathFrac));
      }
      particle.style = "hsl(" + particle.hue + "," + particle.sat + "%," + particle.light + "%)";
      if (particle.deathFrac < 1 && particle.spawnCount++ % 4 === 0) {
        spawnSnow(particle.id, particle.x, particle.y, particle.radius / 10, particle.deathFrac);
      }
      if (particle.age > particle.maxAge) {
        deadIndex = i;
        break;
      }
    }
    if (deadIndex != null) {
      for (i = l = 0, ref = deadIndex; 0 <= ref ? l <= ref : l >= ref; i = 0 <= ref ? ++l : --l) {
        particle = particles[i];
        particle.dead = true;
        deletePhasor(particle.xName);
        deletePhasor(particle.yName);
      }
      particles.splice(0, deadIndex + 1);
    }
    return null;
  };

  surfaces.particles.render = function(ctx, t) {
    var ang, frac, i, k, l, len, particle, ref;
    if (!(particles.length > 0)) {
      return false;
    }
    for (i = k = 0, len = particles.length; k < len; i = ++k) {
      particle = particles[i];
      frac = i / particles.length;
      ctx.beginPath();
      ctx.fillStyle = particle.style;
      if (particle.shape < 3) {
        ctx.arc(particle.x, particle.y, particle.radius, 0, TAU);
      } else {
        ctx.moveTo(particle.x + particle.radius * Math.cos(TAU * particle.angle), particle.y + particle.radius * Math.sin(TAU * particle.angle));
        for (p = l = 1, ref = particle.shape; 1 <= ref ? l <= ref : l >= ref; p = 1 <= ref ? ++l : --l) {
          ang = TAU * (particle.angle + p / particle.shape);
          ctx.lineTo(particle.x + particle.radius * Math.cos(ang), particle.y + particle.radius * Math.sin(ang));
        }
      }
      ctx.fill();
    }
    return true;
  };

  requestRender = function() {
    if (!renderRequested) {
      renderRequested = true;
      return requestAnimationFrame(render);
    }
  };

  bail = function(fn) {
    lastMouseX = null;
    lastMouseY = null;
    return typeof fn === "function" ? fn() : void 0;
  };

  render = function(currentTime) {
    var deltaMs, dt, name, surface;
    renderRequested = false;
    if (running) {
      requestRender();
    }
    if (document.hidden) {
      return bail(null);
    }
    if (isNaN(currentTime)) {
      return bail(requestRender);
    }
    if (lastTime == null) {
      lastTime = currentTime - 16;
    }
    deltaMs = Math.min(50, currentTime - lastTime);
    dt = timeScale / 1000 * deltaMs;
    lastTime = currentTime;
    worldTime += dt;
    if (hasMoved & (lastMouseX != null)) {
      mouseDx = lastMouseX - mouseX;
      mouseDy = lastMouseY - mouseY;
      mouseDist = Math.sqrt(mouseDx * mouseDx + mouseDy * mouseDy);
    } else {
      lastMouseX = mouseX;
      lastMouseY = mouseY;
      mouseDx = 0;
      mouseDy = 0;
      mouseDist = 0;
    }
    for (name in surfaces) {
      surface = surfaces[name];
      if (!surface.doSimulate) {
        continue;
      }
      if (hasMoved) {
        if (typeof surface.move === "function") {
          surface.move(mouseX, mouseY, worldTime, dt);
        }
      }
      if (typeof surface.simulate === "function") {
        surface.simulate(worldTime, dt);
      }
    }
    for (name in surfaces) {
      surface = surfaces[name];
      if (!(surface.doSimulate && surface.doRender)) {
        continue;
      }
      if (surface.clear && surface.needsClear) {
        surface.context.clearRect(0, 0, width, height);
      }
      surface.needsClear = typeof surface.render === "function" ? surface.render(surface.context, worldTime, dt) : void 0;
    }
    hasMoved = false;
    lastMouseX = mouseX;
    return lastMouseY = mouseY;
  };

  surfaces.snow.setup = function(surface) {
    makeNoisePhasor("snowLight", 100, 40, 1000 * Math.random());
    return makeNoisePhasor("snowHue", 30, 40, 1000 * Math.random());
  };

  surfaces.snow.resize = function(surface) {
    var aName, i, j, k, l, len, len1, m, n, ref, ref1, sName, size, vec, vecList, x, xVecs, y, yVecs;
    for (k = 0, len = vectors.length; k < len; k++) {
      vecList = vectors[k];
      for (l = 0, len1 = vecList.length; l < len1; l++) {
        vec = vecList[l];
        deletePhasor(vec.aName);
        deletePhasor(vec.sName);
      }
    }
    vectors = [];
    size = Math.min(width, height);
    vectorSpacing = Math.floor(size / 10);
    xVecs = Math.ceil(width / vectorSpacing);
    yVecs = Math.ceil(height / vectorSpacing);
    for (i = m = 0, ref = xVecs; 0 <= ref ? m <= ref : m >= ref; i = 0 <= ref ? ++m : --m) {
      x = i * vectorSpacing;
      vectors[i] = [];
      for (j = n = 0, ref1 = yVecs; 0 <= ref1 ? n <= ref1 : n >= ref1; j = 0 <= ref1 ? ++n : --n) {
        y = j * vectorSpacing;
        aName = "vectors-" + x + "-" + y + "a";
        sName = "vectors-" + x + "-" + y + "s";
        makeNoisePhasor(aName, 120, 25, 0, i * 8, j);
        makeNoisePhasor(sName, 70, 30, 0, -i * 8, -j);
        vectors[i].push({
          aName: aName,
          sName: sName,
          x: x,
          y: y,
          initAngle: simplex2(i / 15, j / 15)
        });
      }
    }
    return null;
  };

  spawnSnow = function(particleId, x, y, radius, particleAgeFrac) {
    var id, satFrac;
    if (snow.length > maxSnow) {
      snow.splice(0, snow.length - maxSnow);
    }
    id = snowId++;
    satFrac = (particleId / 200) % 1;
    return snow.push({
      x: x + scale(Math.random(), 0, 1, -radius, +radius),
      y: y + scale(Math.random(), 0, 1, -radius, +radius),
      age: 0,
      id: id,
      sat: scale(Math.pow(0.5 * (Math.pow(2 * satFrac - 1, 3) + 1), 2), 0, 1, 10, 90),
      maxAge: 3 + Math.pow(particleAgeFrac, 2) * 10,
      radius: radius / 2
    });
  };

  surfaces.snow.simulate = function(t, dt) {
    var a, b, c, d, i, k, l, len, len1, lower, m, s, scaledX, scaledY, targetSnow, upper, vec, vecList;
    if (!(snow.length > 0)) {
      return;
    }
    targetSnow = scale(dt, .015, .024, bestSnow, worstSnow, true);
    maxSnow = Math.round(maxSnow * .9 + targetSnow * .1);
    for (k = 0, len = vectors.length; k < len; k++) {
      vecList = vectors[k];
      for (l = 0, len1 = vecList.length; l < len1; l++) {
        vec = vecList[l];
        vec.angle = vec.initAngle + sampleNoisePhasor(vec.aName, t).v;
        vec.strength = sampleNoisePhasor(vec.sName, t).v * .5 + .5;
      }
    }
    for (i = m = snow.length - 1; m >= 0; i = m += -1) {
      s = snow[i];
      s.age += dt * scale(Math.pow(snow.length / maxSnow, 4), 0, 1, 1, 100);
      s.ageFrac = s.age / s.maxAge;
      s.ageFracInv = 1 - s.ageFrac;
      s.alpha = Math.min(s.ageFracInv, .6);
      if (s.age > s.maxAge || s.x < 0 || s.y < 0 || s.x > width || s.y > height) {
        snow.splice(i, 1);
        continue;
      }
      scaledX = s.x / vectorSpacing;
      scaledY = s.y / vectorSpacing;
      if (lower = vectors[Math.floor(scaledX)]) {
        a = lower[Math.floor(scaledY)];
        b = lower[Math.ceil(scaledY)];
      }
      if (upper = vectors[Math.ceil(scaledX)]) {
        c = upper[Math.floor(scaledY)];
        d = upper[Math.ceil(scaledY)];
      }
      if ((a != null) && (b != null) && (c != null) && (d != null)) {
        s.ox = s.x;
        s.oy = s.y;
        vecSnowDist(i, dt, s, a);
        vecSnowDist(i, dt, s, b);
        vecSnowDist(i, dt, s, c);
        vecSnowDist(i, dt, s, d);
      } else {
        snow.splice(i, 1);
      }
    }
    return null;
  };

  vecSnowDist = function(i, dt, s, vec) {
    var dist, dx, dy, strength;
    dx = vec.x - s.x;
    dy = vec.y - s.y;
    dist = Math.sqrt(dx * dx + dy * dy);
    strength = vec.strength * (1 - dist / vectorSpacing);
    if (strength > 0) {
      s.x += strength * 300 * dt * Math.cos(vec.angle * TAU);
      return s.y += strength * 300 * dt * Math.sin(vec.angle * TAU);
    }
  };

  surfaces.snow.render = function(ctx, t, dt) {
    var i, k, len, s, snowHue, snowLight;
    if (!(snow.length > 0)) {
      return;
    }
    snowHue = scale(sampleNoisePhasor("snowHue", t).v, -1, 1, 270, 210);
    snowLight = scale(sampleNoisePhasor("snowLight", t).v, -1, 1, 65, 100);
    ctx.lineWidth = .5;
    for (i = k = 0, len = snow.length; k < len; i = ++k) {
      s = snow[i];
      ctx.beginPath();
      ctx.strokeStyle = "hsla(" + snowHue + "," + s.sat + "%," + snowLight + "%," + s.alpha + ")";
      ctx.moveTo(s.ox, s.oy);
      ctx.lineTo(s.x, s.y);
      ctx.stroke();
    }
    return null;
  };

  surfaces.snowbuffer.render = function(ctx, t, dt) {
    bufferTime += mouseDist / 160 + dt;
    if (bufferTime > fadeTime) {
      bufferTime = 0;
      ctx.clearRect(0, 0, width, height);
      ctx.drawImage(surfaces.snow.canvas, 0, 0, width, height);
      surfaces.snow.context.clearRect(0, 0, width, height);
    }
    return surfaces.snowbuffer.canvas.style.opacity = Math.pow(scale(bufferTime, 0, fadeTime, 1, 0, true), .8);
  };

  start = function(c) {
    var name, surface;
    if (running) {
      return;
    }
    running = true;
    container = c;
    absolutePos(container);
    container.style.backgroundColor = "#222";
    resetDefaults();
    for (name in surfaces) {
      surface = surfaces[name];
      setupSurface(surface);
    }
    window.addEventListener("mousemove", mousemove);
    window.addEventListener("touchmove", touchmove);
    window.addEventListener("resize", requestResize);
    resize();
    render();
    return void 0;
  };

  stop = function() {
    running = false;
    clearContainer();
    window.removeEventListener("mousemove", mousemove);
    window.removeEventListener("touchmove", touchmove);
    window.removeEventListener("resize", requestResize);
    return void 0;
  };

  API = {
    start: start,
    stop: stop
  };

  window.Pauling = function() {
    return API;
  };

}).call(this);
