#=require gammalib
#=require "libs/mousetrap.min"

$ ->
    path = document.location.pathname[1..].split('/')[0]

    # #nav setup.
    if path
        for e in ($ ".navItem")
            if path == e.textContent.replace(/\s+/g, '').toLowerCase()
                ($ "body").addClass "bg-color-"+e.id.split('-')[1]
                break
    else ($ "body").addClass "bg-color-body"

    bodyBGColor = ($ "body")[0].className.match /bg-color-\w+/
    headerH1Color = ($ "#header h1").css "color"

    replaceBGColor = (e, color) ->
        Gamma.replaceClass e, /bg-color-\w+/, color

    ($ ".navItem").hover (->
            replaceBGColor ($ "body")[0], "bg-color-"+@.id.split('-')[1]
            ($ "#header h1").css "color", ($ @).css "background-color"
        ), (->
            replaceBGColor ($ "body")[0], bodyBGColor
            ($ "#header h1").css "color", headerH1Color
        )

    #if /ie(6|7|8)/.test ($ "html")[0].className
        #document.location = "/ie_reject"

    #User Input - Keyboard, Mouse, Touch
    Mousetrap.bind 'f9', ->
        Gamma.toggleFullscreen()
