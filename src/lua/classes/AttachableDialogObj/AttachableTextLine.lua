do

    --[[
        This creates a single line of text with no background.
    ]]

    --[[
        :defineAttachableTextLine{
            baseObj params,
            baseObjAttached params,
            text = "",
            font = ,
            size = ,
            spacing = ,
            interval = ,
            writeCondition = (
                function (this) 
                    return
                end
            ),
            onFullyWritten = (
                function (this) 
                
                end
            ),
        }
    ]]

    AttachableTextLine = BaseObjAttachedObj:clone()

    --[[
        :defineAttachableTextLine{
            baseObj params,
            baseObjAttached params,
            text = "",
            font = ,            ---Default if not declared
            size = ,            ---Font's default if not declared
            spacing = ,         ---Separation between the characters in pixels
            interval = ,        ---Every x frames, write one letter, used on queue obj
            writeCondition = ,  ---Closure, begin wrtiting if true
            onFullyWritten = ,  ---When fully writen, closure
        }
    ]]
    function AttachableTextLine:defineAttachableTextLine(params)

        ---Must remove background
        params['texture'] = textures.std_empty_10_10
        self:defineBaseObjAttached(params)

        ---Font definition
        self.font = params.font
        if not self.font then
            stdFont = FontObj:clone()
            stdFont:defineFont()
            self.font = stdFont
        end

        ---Set font size
        ---TODO change this to do different widths and heights later
        self.size = params.size or globalDefaultParams.scale

        ---What will be shown
        self.text = params.text or globalDefaultParams.attachableLineDefaultText
        
        ---Spacing between letters in pixels
        self.spacing = params.spacing or globalDefaultParams.attachableLineDefaultSpacing

        ---Will hold the BaseObjAttached list, which are the characters
        self.letterList = {}
        self:makeLetters()

        self.interval = params.interval or globalDefaultParams.attachableLineDefaultInterval

        ---Begin writing whent this closure returns true, write immediatly if none passed
        self.writeCondition = params.writeCondition

        ---When the queue is done, act on closure.
        self.onFullyWritten = params.onFullyWritten

    end

    ---Makes the letters to display, the letters are BaseObjAttached objects
    function AttachableTextLine:makeLetters()

        letterWidth = self.font.texture.width * self.size
        letterWidthAccumulator = 0  ---For separation of the letters

        for j=1, #self.text do

            ---Every letter is a BaseObjAttached with a Font as a texture
            ---The texture can serve as a font if the texture is a line of characters,
            --- based on the character an origin x can found from a look-up table and the
            --- correct texture can be shown.
            letter = BaseObjAttachedObj:clone()
            letter:defineBaseObjAttached({
                name =  self.name .. "_char_" .. self.text:sub(j,j),
                texture = self.font.texture,    ---The font
                scale = self.size,
                animStage = self.font.charTable[self.text:sub(j,j)],    ---The look-up table
                pauseAnimation = true,
                anchor = self,
                offsetX = letterWidthAccumulator,
                offsetY = 0,
                hasCollision = false
            })
            letter.char = self.text:sub(j,j) ---Added for convinience
            ---The arithmetic for the letter placement
            letterWidthAccumulator = letterWidth + letterWidthAccumulator + self.spacing

            ---Where the letter will be stored
            self.letterList[#self.letterList + 1] = letter
        end

        self.totalLenght = letterWidth + letterWidthAccumulator ---For future convinience
    end

    ---Gets a pre-made queue that adds the letters algorithmically to the map,
    ---since map might change, a closure for the letter insertion needs to be passed
    function AttachableTextLine:getParametrizedQueue(onInsertLetter)
        queue = QueueObj:clone()
        queue:defineQueue({
            intervalFrame = self.interval,
            updateCondition = self.writeCondition,
            onConstructor = (
                function (this)
                    this.accumulator = 1
                end
            ),
            onUpdate = (
                function (this)
                    onInsertLetter(this)    ---The function on the MapObj that adds letters
                    this.accumulator = this.accumulator + 1
                end
            ),
            stopCondition = (
                function (this) 
                    return ( 1 + #self.letterList == this.accumulator)
                end
            ),
            onStopCondition = self.onFullyWritten
        })
        return queue
    end

end