exports.Animation = class
    constructor: (@spriteSheet, @spec, @fps=6) ->
        @frameDuration = 1000 / @fps

    currentFrame:         null
    currentRow:           0
    currentFrameDuration: 0
    currentAnimation:     null
    loopFinished:         false
    image:                null

    start: (animation) ->
        @currentAnimation = animation
        @currentFrame = @spec[animation][0]
        @currentRow   = @spec[animation][1]
        @currentFrameDuration = 0
        @update 0
        null

    update: (msDuration) ->
        unless @currentAnimation
            throw new Error("No animation started. call start(\"fooCycle\") before updating")

        @currentFrameDuration += msDuration
        if @currentFrameDuration >= @frameDuration
            @currentFrame++
            @currentFrameDuration = 0

            aniSpec = @spec[@currentAnimation]
            if aniSpec.length is 2 or @currentFrame > aniSpec[2]
                @loopFinished = true
                # unless fourth argument is false, which means: do not loop
                if aniSpec.length is 4 and aniSpec[3] is false
                    @currentFrame--
                else
                    @currentFrame = aniSpec[0]

        @image = @spriteSheet.get @currentRow, @currentFrame
