do

    ButtonMenuObj = BaseObjAttachedObj:clone()

    function ButtonMenuObj:defineButtonMenu(
            description,        ---The sentence on the right of the button, affected by scale
            selectKey,          ---The key that presses the button, Enter key if left alone
            isSelected,         ---If the component is selected then it can be pressed
            initialState,       ---Pressed(true) or not pressed(false)
            texturePressed,     ---Sprite of the pressed button, std if left alone
            textureNotPressed,  ---Sprite of the unpressed button, std if left alone
            font                ---Font for the sentence, std font if left alone
        )   
        ---Should have text on the right and two textures to display state

        self.hasCollision = false
        self.description = description or "Description Here"
        self.selectKey = selectKey or "Return"  ---Enter Key
        self.texturePressed = texturePressed or textures.std_button_green_10_10
        self.textureNotPressed = textureNotPressed or textures.std_button_blue_10_10

        self.state = initialState or false
        self.isSelected = isSelected or false

        if self.state then
            self:changeSprite(self.texturePressed)
        else
            self:changeSprite(self.textureNotPressed)
        end


        ---Write the sentence besides the button
        self.attachedDialog = AttachableDialogObj:clone()
        self.attachedDialog:defineBaseObjAttached({
            name = self.description,
            anchor = self
        })

        self.attachedDialog:defineAttachableDialog(self.description, 1, 2, self.scale, -1 , 1)
        self.attachedDialog.offsetY = -((self.attachedDialog.height/2) - self.attachedDialog.font.texture.height/2)
        self.attachedDialog:changeSprite(textures.std_empty_10_10)


        ---Dialog not going away
        ---Maybe make a simpler dialog obj without background
    end


    function ButtonMenuObj:update()
        if self.isSelected then
            if risingEdgeKey(self.selectKey) then
                self.state = not self.state
                if self.state then
                    self:changeSprite(self.texturePressed)
                else
                    self:changeSprite(self.textureNotPressed)
                end
            end
        end

    end

    function ButtonMenuObj:hide()
        self:disableRender()
        self.attachedDialog:hide()
    end
    function ButtonMenuObj:show()
        self:enableRender()
        self.attachedDialog:show()
    end

end