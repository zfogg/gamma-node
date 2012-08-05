$gjs = require "gamejs"

exports.SpriteSheet = class
    constructor: (@imagePath, @sheetSpec) ->
        width = @sheetSpec.width
        height = @sheetSpec.height
        image = $gjs.image.load imagePath
        imgSize = new $gjs.Rect([0, 0], [width, height])

        j = 0
        while j < image.rect.height
            i = 0
            row = []
            while i < image.rect.width
                surface = new $gjs.Surface([width, height])
                rect = new $gjs.Rect(i, j, width, height)
                surface.blit image, imgSize, rect
                row.push surface
                i += width
            @surfaceCache.push row
            j += height

    surfaceCache: []

    get: (x, y) ->
        @surfaceCache[x][y]
