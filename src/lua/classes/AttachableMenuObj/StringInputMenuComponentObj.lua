do

    --[[
        Used to add string inputs to a menu, will be used later for 
        complex dialogs
    ]]

    StringInputMenuComponentObj = BaseObjAttachedObj:clone()

    function StringInputMenuComponentObj:defineStringInputMenu(
        description,    ---The sentence on the top of the input, affected by scale
        stringLength,   ---The number of characters the input accepts. -1 for infinite
        isSelected,     ---If the component is selected then it can be writen
        initialState,   ---What the input will have by default
        font            ---Font for the sentence, std font if left alone
    )

        self.hasCollision = false
        self.description = description or "Description Here"

        --self.state = initialState or ""
        self.isSelected = isSelected or false
        self:changeSprite(textures.std_empty_10_10)

        self.font = font
        if not self.font then
            stdFont = FontObj:clone()
            stdFont:defineFont()
            self.font = stdFont
        end

        ---Write the sentence above the
        self.attachedDialog = AttachableDialogObj:clone()
        self.attachedDialog:defineAttachableDialog({
            name = self.description,
            anchor = self,
            offsetX = 0,
            offsetY = -15,
            text = self.description,
            spacingX = 1,
            spacingY = 2,
            fontScale = self.scale,
            timeOnScreen = -1,
            framesPerLetter = 1,
            pauseGame = false,
            font = self.font,
        })
        self.attachedDialog:changeSprite(textures.std_empty_10_10)

        if stringLength > 1 then
            self.stringLength = stringLength
        else
            self.stringLength = 20
        end

        self.state = ""
        for i=1, self.stringLength do
            self.state = self.state .. " "
        end
        self.stateWriteIndex = 1

        self.attachedInputDialog = AttachableDialogObj:clone()
        self.attachedInputDialog:defineAttachableDialog({
            name = self.description,
            anchor = self,
            offsetX = 10,
            offsetY = 0,
            text = self.state,
            spacingX = 1,
            spacingY = 2,
            fontScale = self.scale,
            timeOnScreen = -1,
            framesPerLetter = 1,
            backgroundTexture = textures.std_empty_10_10
        })

    end

    ---TODO: ADD lower case and upper case, everything is upper case for now
    function StringInputMenuComponentObj:update()
        if self.isSelected then
            pressedKeys = risingEdgeKeys()
            
            stateBuffer = self.state
            for i, key in pairs(pressedKeys) do

                if key == 'Space' then
                    key = ' '
                end

                if key ~= 'Backspace' then
                    if string.match(self.font.characters, key) then
                        if self.stateWriteIndex <= self.stringLength then
                            if self.stateWriteIndex <= self.stringLength then
                                stateBuffer = replace_char(self.stateWriteIndex, stateBuffer, key)
                                self.stateWriteIndex = self.stateWriteIndex + 1
                            end
                        end
                    end
                else
                    ---Dealing with deleting words
                    if self.stateWriteIndex > 1 then
                        stateBuffer = replace_char(self.stateWriteIndex-1, stateBuffer, ' ')
                        self.stateWriteIndex = self.stateWriteIndex - 1
                    end
                end
                self.state = stateBuffer

                for j=1, #stateBuffer do
                    self.attachedInputDialog:changeLetter(
                        1, 
                        j, 
                        self.state:sub(j,j)
                    )
                end
            end
            
        end

    end

    function StringInputMenuComponentObj:hide()
        self:disableRender()
        self.attachedDialog:hide()
        self.attachedInputDialog:hide()
    end
    function StringInputMenuComponentObj:show()
        self:enableRender()
        self.attachedDialog:show()
        self.attachedInputDialog:show()
    end
        
end