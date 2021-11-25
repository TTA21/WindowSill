do

    --[[
        Used to add string inputs to a menu, will be used later for 
        complex dialogs
    ]]

    StringInputMenuComponentObj = BaseObjAttachedObj:clone()

    function StringInputMenuComponentObj:defineStringInputComponent(
        description,    ---The sentence on the top of the input, affected by scale
        stringLength,   ---The number of characters the input accepts. -1 for infinite
        isSelected,     ---If the component is selected then it can be writen
        initialState,   ---What the input will have by default
        font            ---Font for the sentence, std font if left alone
    )

        --keys = risingEdgeKeys()
        --if #keys > 0 then
        --    print( table.concat(keys,", "))
        --end

        self.hasCollision = false
        self.description = description or "Description Here"

        self.state = initialState or ""
        self.isSelected = isSelected or false
        self:changeSprite(textures.std_empty_10_10)

        ---Write the sentence besides the button
        self.attachedDialog = AttachableDialogObj:clone()
        self.attachedDialog:defineBase(self.description)
        self.attachedDialog:defineBaseObjAttached(self, 0, -20)
        self.attachedDialog:defineAttachableDialog(self.description, 1, 2, self.scale, -1 , 1)
        
        --self.attachedDialog:changeSprite(textures.std_empty_10_10)

    end

    function StringInputMenuComponentObj:update()
        if self.isSelected then
           
        end

        
    end

    function StringInputMenuComponentObj:hide()
        self:disableRender()
    end
    function StringInputMenuComponentObj:show()
        self:enableRender()
    end
        
end