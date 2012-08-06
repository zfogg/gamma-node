Gravity = (require "./gravity").Gravity

$ ->
  canvas        = ($ "#canvas")[0]
  canvas.height = 564
  canvas.width  = 940

  if canvas.getContext
    Gravity canvas
