do

    --[[
        Sliders are those dragging things that common ui's have.

        |-----X----| = 6

        |--------X-| = 8

        You know, those things.

        Only goes from 0 to 100 in integers.
    ]]

    SliderMenuComponentObj = BaseObjAttachedObj:clone()

    function SliderMenuComponentObj:defineSliderMenu(
        description,            ---The sentence on the right of the button, affected by scale
        sliderKeys,             ---An array with two strings that contain the keys that slide the slider,
                                ---if left alone, [["Left", "A"],["Right", "D"]]
        isSelected,             ---If the component is selected then it can be pressed
        initialState,           ---An integer from 0 to 100
        valueChangeDelay,       ---1 = normal speed, 2 = twice the time to change value
        displayValueOnSide,     ---Show the state on the side
        sliderTexture,          ---The texture of the slider, std if not initialized
        sliderHandlerTexture,   ---The texture for the handler that slides on the slider
        font                    ---Font for the sentence, std font if left alone
    )

        self.hasCollision = false
        self.description = description or "Description Here"
        self.isSelected = isSelected or false

        self.sliderKeys = sliderKeys or {{"Left", "A"},{"Right", "D"}}
        self.valueChangeDelay = valueChangeDelay or 10

        if sliderTexture then
            self:changeSprite(sliderTexture)
        else
            self:changeSprite(textures.std_roller_bar_100_10_blue)
        end

        self.font = font
        if not self.font then
            stdFont = FontObj:clone()
            stdFont:defineFont()
            self.font = stdFont
        end

        ---Write the sentence above the input
        self.attachedDialog = AttachableDialogObj:clone()
        self.attachedDialog:defineAttachableDialog({
            name = self.description,
            anchor = self,
            offsetX = -10,
            offsetY = -40,
            text = self.description,
            spacingX = 1,
            spacingY = 2,
            fontScale = self.scale,
            timeOnScreen = -1,
            framesPerLetter = 1,
            pauseGame = false,
            font = self.font,
            backgroundTexture = textures.std_empty_10_10
        })

        self.state = initialState or 0

        self.slideHandler = BaseObjAttachedObj:clone()
        if sliderHandlerTexture then
            self.slideHandler:defineBaseObjAttached({
                name = self.description,
                texture = sliderHandlerTexture,
                anchor = self,
                offsetX = self.state,
                offsetY = 1
            })
        else
            self.slideHandler:defineBaseObjAttached({
                name = self.description,
                texture = textures.std_roller_handle_blue_10_10,
                anchor = self,
                offsetX = self.state,
                offsetY = 1
            })
        end

        self.displayState = displayValueOnSide or false
        if self.displayState then
            ---Write the state value on the side
            
            stateString = tostring(self.state)
            if self.state < 10 then
                stateString = "00" .. stateString
            end

            if self.state < 100 and self.state > 9 then
                stateString = "0" .. stateString
            end

            self.attachedStateDialog = AttachableDialogObj:clone()
            self.attachedStateDialog:defineAttachableDialog({
                name = self.description .. "_state",
                anchor = self,
                offsetX = 110,
                offsetY = -17,
                text = stateString,
                spacingX = 1,
                spacingY = 2,
                fontScale = self.scale,
                timeOnScreen = -1,
                framesPerLetter = 1,
                pauseGame = false,
                font = self.font,
                backgroundTexture = textures.std_empty_10_10
            })
        end

    end


    function SliderMenuComponentObj:update()
        if self.isSelected then
            if (globalFrameCounter % self.valueChangeDelay) == 0 then
                for i, key in pairs(self.sliderKeys[1]) do
                    if keyIsPressed(key) then
                        if self.state > 0 then
                            self.state = self.state - 1
                        end
                        
                    end
                end
                for i, key in pairs(self.sliderKeys[2]) do
                    if keyIsPressed(key) then
                        if self.state < 100 then
                            self.state = self.state + 1
                        end
                    end
                end
                self.slideHandler.offsetX = self.state - (self.slideHandler.texture.width/2)

                if self.displayState then
                    stateString = tostring(self.state)

                    if self.state < 10 then
                        stateString = "00" .. stateString
                    end

                    if self.state < 100 and self.state > 9 then
                        stateString = "0" .. stateString
                    end

                    for j=1, #stateString do
                        self.attachedStateDialog:changeLetter(
                            1, 
                            j, 
                            stateString:sub(j,j)
                        )
                    end
                end
            end
        end
    end

    function SliderMenuComponentObj:show()
        self:enableRender()
        self.attachedDialog:show()
        self.slideHandler:enableRender()
        if self.displayState then
            self.attachedStateDialog:show()
        end
    end

    function SliderMenuComponentObj:hide()
        self:disableRender()
        self.attachedDialog:hide()
        self.slideHandler:disableRender()
        if self.displayState then
            self.attachedStateDialog:hide()
        end
    end

end