do --open

    --[[
        This object is a dialog box attached to some object, usually an NPC

        If one wants to have it as a simpler dialog box on the screen and not move like
        an rpg, simply attach it to whatever the camera is anchored to
    ]]

    AttachableDialogObj = BaseObjAttachedObj:clone()

    ---Data declaration

    AttachableDialogObj.texture = textures.std_menu_background_blue_10_10 ---Standard

    ---Function Declaration

    function AttachableDialogObj:defineAttachableDialog(
        text,           ---What you want to write
        spacingX,       ---How many pixels between letters
        spacingY,       ---How many pixels between lines
        timeOnScreen,   ---How long it should stay on screen by frames, -1 if no time is decided
        closeKey,       ---Wich key to press to close the dialog
        pauseGame,      ---Should the game pause when dialog is on screen
        forceWidth,     ---If wished, a size of the dialog can be defined, NOT RECOMENDED
        forceHeight,    ---If wished, a size of the dialog can be defined, NOT RECOMENDED
        backgroundTexture,
        font            ---FontObj
    )

        self.text = text or "Default Message"

        --2000 = 5s
        --1000 = 2.5s
        self.timeOnScreen = timeOnScreen or -1
        if self.timeOnScreen > -1 then
            self.startFrame = globalFrameCounter
            self.endFrame = globalFrameCounter + self.timeOnScreen
        end

        self.closeKey = closeKey or "NONE"
        self.isClosed = false
        self.texture = backgroundTexture or 
            textures.std_menu_background_blue_10_10 ---Standard

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

        for i, line in pairs(self.lines) do
            print(line)
        end
        print(self.biggestLine, #self.biggestLine)

        self.width = forceWidth
        self.height = forceHeight
        self.spacingX = spacingX or 5
        self.spacingY = spacingY or 5

        if not self.width then
            ---width should be the number of chars in a line * sizze of char
            --- + 2 chars width for border
            self.width = (#self.biggestLine * self.font.texture.width) + (self.font.texture.width*3) + (#self.biggestLine * spacingX)
        end

        if not self.height then
            ---height should be the same as width but with num of lines
            self.height = (#self.lines * self.font.texture.height) + (self.font.texture.height*3) + (#self.lines * spacingY)
        end

        print(self.width, self.height)
        self:changeDimensions(self.width, self.height)

        self.letters = {}

        --self:write()

    end

    function AttachableDialogObj:write(mapObj)
        spacingAdderX = self.spacingX
        spacingAdderY = self.spacingY
        for i, line in pairs(self.lines) do
            for j=1, #line do
                letter = BaseObjAttachedObj:clone()
                letter:defineBase("", self.font.texture, 1)
                letter.hasCollision = false
                letter.animStage = self.font.charTable[line:sub(j,j)]
                letter.pauseAnimation = true
                letter:defineBaseObjAttached(
                    self,
                    (self.font.texture.width/2)+ (self.font.texture.width*j) + spacingAdderX,
                    (self.font.texture.height/2)+ (self.font.texture.height*i) + spacingAdderY
                )
                spacingAdderX = spacingAdderX + self.spacingX
                self.letters[#self.letters+1] = letter
                mapObj:addToForeGround(letter)
            end
            spacingAdderX = self.spacingX
            spacingAdderY = spacingAdderY + self.spacingY
        end
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

        for i, key in pairs(keysPressed) do
            if key == self.closeKey then
                self:close()
            end
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

end --close