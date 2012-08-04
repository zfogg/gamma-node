$gjs = require "gamejs"

exports.SpriteSheet = class
    constructor: (@imagePath, @sheetSpec) ->
        width = @sheetSpec.width
        height = @sheetSpec.height
        image = $gjs.image.load imagePath
        imgSize = new $gjs.Rect([0, 0], [width, height])

        i = 0
        while i < image.rect.width
            j = 0
            while j < image.rect.height
                surface = new $gjs.Surface([width, height])
                rect = new $gjs.Rect(i, j, width, height)
                surface.blit image, imgSize, rect
                @surfaceCache.push surface
                j += height
                i += width

    surfaceCache: []

    get: (id) ->
        @surfaceCache[id]

