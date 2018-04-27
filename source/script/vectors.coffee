surfaces.vectors.resize = (surface)->
  for vecList in vectors
    for vec in vecList
      deletePhasor vec.aName
      deletePhasor vec.sName

  vectors = []

  xVecs = Math.ceil width/vectorSpacing
  yVecs = Math.ceil height/vectorSpacing

  for i in [0..xVecs]
    x = i * vectorSpacing
    vectors[i] = []
    for j in [0..yVecs]
      y = j * vectorSpacing
      aName = "vectors-#{x}-#{y}a"
      sName = "vectors-#{x}-#{y}s"
      makeNoisePhasor aName, 60, 30, 0, i*10, j
      makeNoisePhasor sName, 70, 30, 0, -i*10, -j
      vectors[i].push
        aName: aName
        sName: sName
        x: x
        y: y
        initAngle: simplex2 i/15, j/15
  null


surfaces.vectors.simulate = (t, dt)->
  for vecList in vectors
    for vec in vecList
      vec.angle = vec.initAngle + sampleNoisePhasor(vec.aName, t).v
      vec.strength = scale sampleNoisePhasor(vec.sName, t).v, 0, 1, .3, 4
  null
