Gravity = (require "./gravity").Gravity

$ ->
  canvas        = ($ "#canvas")[0]
  canvas.height = 960
  canvas.width  = 960

  if canvas.getContext
    Gravity canvas
