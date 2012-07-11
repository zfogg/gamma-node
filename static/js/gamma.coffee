$ ->
  path = document.location.pathname[1..].split('/')[0]

  # #nav setup.
  if path
    for e in ($ ".navItem")
      if path == e.textContent.replace(/\s+/g, '').toLowerCase()
        ($ "body").addClass "bg-color-"+e.id.split('-')[1]
        break
  else ($ "body").addClass "bg-color-body"
  body_bg_color = ($ "body")[0].className.match /bg-color-\w+/

  replaceBGColor = (e, color) ->
    Gamma.replaceClass e, /bg-color-.*/, color
  headerH1Color = ($ "#header h1").css "color"
  ($ ".navItem").mouseover ->
    replaceBGColor ($ "body")[0], "bg-color-"+@.id.split('-')[1]
    ($ "#header h1").css "color", ($ @).css "background-color"
  ($ ".navItem").mouseout ->
    replaceBGColor ($ "body")[0], body_bg_color
    ($ "#header h1").css "color", headerH1Color
