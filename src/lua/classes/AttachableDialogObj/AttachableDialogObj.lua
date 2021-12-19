do --open

    --[[
        This object is a dialog box attached to some object, usually an NPC

        If one wants to have it as a simpler dialog box on the screen and not move like
        an rpg, simply attach it to whatever the camera is anchored to
    ]]

    AttachableDialogObj = BaseObjAttachedObj:clone()

    ---Data declaration

    AttachableDialogObj.texture = textures.std_menu_background_white_10_10 ---Standard

    ---Function Declaration

    function AttachableDialogObj:defineAttachableDialog(
        text,           ---What you want to write
        spacingX,       ---How many pixels between letters
        spacingY,       ---How many pixels between lines
        fontScale,      ---Width and height of the font, 1 for normal, 2 for double size
        timeOnScreen,   ---How long it should stay on screen by frames, -1 if no time is decided
        framesPerLetter,---Every x frames, write one letter
        closeKey,       ---Wich key to press to close the dialog
        pauseGame,      ---Should the game pause when dialog is on screen
        font,           ---FontObj
        forceWidth,     ---If wished, a size of the dialog can be defined, NOT RECOMENDED
        forceHeight,    ---If wished, a size of the dialog can be defined, NOT RECOMENDED
        backgroundTexture
    )

        self.text = text or "Default Message"
        self.fontScale = fontScale or 1

        --2000 = 5s
        --1000 = 2.5s
        self.timeOnScreen = timeOnScreen or -1
        if self.timeOnScreen > -1 then
            self.startFrame = globalFrameCounter
            self.endFrame = globalFrameCounter + self.timeOnScreen
        end
        self.framesPerLetter = framesPerLetter or 100

        self.closeKey = closeKey or "NONE"
        self.isClosed = false
        self.texture = backgroundTexture or 
            textures.std_menu_background_white_10_10 ---Standard

        self.font = font

        if not self.font then
            stdFont = FontObj:clone()
            stdFont:defineFont()
            self.font = stdFont
        end

        self.pauseGame = pauseGame or false

        self.lines = {}
        self.biggestLine = {    
            line = 1,
            size = 1
        }
        self:parseLines()

        self.width = forceWidth
        self.height = forceHeight
        self.spacingX = spacingX or 5
        self.spacingY = spacingY or 5

        self.spacingX = self.spacingX * self.fontScale
        self.spacingY = self.spacingY * self.fontScale

        if not self.width then
            self.width = (#self.biggestLine * self.font.texture.width) + (self.font.texture.width*3) + (#self.biggestLine * spacingX)
            self.width = self.width * self.fontScale
        end

        if not self.height then
            self.height = (#self.lines * self.font.texture.height) + (self.font.texture.height*3) + (#self.lines * spacingY)
            self.height = self.height * self.fontScale
        end

        self:changeDimensions(self.width, self.height)

        self.letters = {}

        self:makeLetters()

    end

    function AttachableDialogObj:makeLetters()
        spacingAdderX = self.spacingX
        spacingAdderY = self.spacingY
        for i, line in pairs(self.lines) do
            for j=1, #line do
                letter = BaseObjAttachedObj:clone()
                letter:defineBaseObjAttached({
                    name =  "",
                    texture = self.font.texture,
                    scale = self.fontScale,
                    hasCollision = false,
                    animStage = self.font.charTable[line:sub(j,j)],
                    pauseAnimation = true,
                    anchor = self,
                    offsetX = (self.font.texture.width/2)+ ((self.font.texture.width * self.fontScale)*j) + spacingAdderX,
                    offsetY = (self.font.texture.height/2)+ ((self.font.texture.height * self.fontScale)*i) + spacingAdderY
                })
                spacingAdderX = spacingAdderX + self.spacingX
                self.letters[#self.letters+1] = letter
            end
            spacingAdderX = self.spacingX
            spacingAdderY = spacingAdderY + self.spacingY
        end
    end

    function AttachableDialogObj:changeLetter(line, pos, letter)
        workingIndex = 0
        if line > 1 then
            for i=2, line do
                workingIndex = workingIndex + #self.lines[i-1]
            end
        end

        workingIndex = workingIndex + pos
        self.letters[workingIndex].animStage = self.font.charTable[letter]
        self.letters[workingIndex].renderObj.animStage = self.font.charTable[letter]
    end

    function AttachableDialogObj:parseLines()
        line = ""
        for i = 1, #self.text do
            char = self.text:sub(i,i)
            if char ~= "\n" then
                line = line .. char
            else
                self.lines[#self.lines+1] = line
                if #self.biggestLine < #line then
                    self.biggestLine = line
                end
                line = ""
            end
        end
        self.lines[#self.lines+1] = line
        if #self.biggestLine < #line then
            self.biggestLine = line
        end
    end

    ---Check Key and timeOnScreen
    function AttachableDialogObj:update()
        self:updatePos()
        if self.timeOnScreen > -1 then
            if self.endFrame < globalFrameCounter then
                self:close()
            end
        end

        if risingEdgeKey(self.closeKey) then
            self:close()
        end

    end

    function AttachableDialogObj:close()
        for i, letter in pairs(self.letters) do
            letter:disableRender()
            letter.isClosed = true
        end
        self:disableRender()
        self.isClosed = true
    end

    function AttachableDialogObj:hide()
        for i, letter in pairs(self.letters) do
            letter:disableRender()
        end
        self:disableRender()
    end

    function AttachableDialogObj:show()
        for i, letter in pairs(self.letters) do
            letter:enableRender()
        end
        self:enableRender()
    end

end --close