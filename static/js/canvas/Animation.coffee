exports.Animation = class
    constructor: (@spriteSheet, @spec, @fps=6) ->
        @frameDuration = 1000 / @fps

    currentFrame:         null
    currentFrameDuration: 0
    currentAnimation:     null
    loopFinished:         false
    image:                null

    start: (animation) ->
        @currentAnimation = animation
        @currentFrame = @spec[animation][0]
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

            #loop back to first frame if animation finished or single frame
            aniSpec = @spec[@currentAnimation]
            if aniSpec.length is 1 or @currentFrame > aniSpec[1]
                @loopFinished = true
                # unless third argument is false, which means: do not loop
                if aniSpec.length is 3 and aniSpec[2] is false
                    @currentFrame--
                else
                    @currentFrame = aniSpec[0]

        @image = @spriteSheet.get @currentFrame
