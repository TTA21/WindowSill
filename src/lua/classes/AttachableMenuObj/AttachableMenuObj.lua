do
    --[[
        TODO:
        string input
        button
        draggable lever

        separate them into components that can be added in a list,
        all of them should have some text besides them aswell
    ]]
    AttachableMenuObj = BaseObjAttachedObj:clone()

    function AttachableMenuObj:defineAttachableMenu(
        menuTitle,          ---Self explanatory
        optionsList,        ---What the menu contains
        toggleKey,          ---The key that opens and closes the menu
        onUpdate,           ---Function handler provided by the dev, it is called after and update
                            ---to do something with the menu's data
        selectKeys,         ---The keys that select wich menu component is being modified, only goes up or down
        backGroundTexture   ---The background for the overall menu,not its components
    )

        self.title = menuTitle or "Menu Title"
        self.optionsList = optionsList or {}
        ---OptionsList example:
        --[[{ 
            {"Button", {description: "Something", initialState: true}},
            {"Button", {The parameters for the component}},     ---equivalent 'define' functions
            {"Slider", {The parameters for the component}}, 
            {"StringInput", {The parameters for the component}}
            }
        ]]

        self.menuComponentList = {} ---Read optionsList and build it
        self.data = {}
        ---Data will be as such with the example OptionsList
        --[[
            {
                1: true         --reference to the first component, a button
                2: true         --reference to the second component, a button
                3: 75           --reference to the third component, a slider
                4: "HelloWorld" --reference to the third component, a StringInput
            }
        ]]

        self.selectKeys = selectKeys or {{"Up"}, {"Down"}}

        self.isClosed = false
        self.toggleKey = toggleKey or "Tab"
        self.onUpdate = onUpdate or 
            function(states)
                ---states recieves self.data on call
                print(states[1])
            end

        self:changeSprite(backGroundTexture or textures.std_menu_background_blue_10_10)
        ---Proper dimensions needed
        self:changeDimensions(300,300)

        for i, component in pairs(self.optionsList) do
            if component[1] == "Button" then
                button = ButtonMenuObj:clone()
                button:defineBase(
                    component[2].description .. "_" .. i, 
                    component[2].texture, 
                    component[2].scale, 
                    component[2].posX, 
                    component[2].posY, 
                    component[2].hitBox, 
                    component[2].alpha, 
                    component[2].animStage, 
                    component[2].hasCollision, 
                    component[2].numAnimationStages, 
                    component[2].animStage, 
                    component[2].numFramesPerAnimationStage, 
                    component[2].localFrameCounter, 
                    component[2].allowRender, 
                    component[2].priority
                )
                button:defineBaseObjAttached(
                    self, 
                    10,     --X
                    20*i    --Y
                )
                button:defineButtonMenu(
                    component[2].description, 
                    component[2].selectKey, 
                    false,  --initial selection is done automatically 
                    component[2].initialState, 
                    component[2].texturePressed, 
                    component[2].textureNotPressed,
                    component[2].font
                )
                if i == 1 then
                    button.isSelected = true
                end

                self.menuComponentList[#self.menuComponentList +1 ] = button
                self.data[i] = button.state

            elseif component[1] == "Slider" then

            elseif component[1] == "StringInput" then

            end
        end

        self.selectedId = 1 ---Wich component is selected

        self.selectedBackground = BaseObjAttachedObj:clone()
        self.selectedBackground:defineBase(self.title .. "_selectedBackground", nil, 1)
        self.selectedBackground:defineBaseObjAttached(self.menuComponentList[self.selectedId], -5, -2)
        self.selectedBackground:changeDimensions(
            self.menuComponentList[self.selectedId].attachedDialog.width,
            self.menuComponentList[self.selectedId].attachedDialog.height/3
        );


    end

    function AttachableMenuObj:changeSelectedBackGroundAnchor()
        self.selectedBackground.anchor = self.menuComponentList[self.selectedId]
        self.selectedBackground:changeDimensions(
            self.menuComponentList[self.selectedId].attachedDialog.width,
            self.menuComponentList[self.selectedId].attachedDialog.height/3
        );
    end

    function AttachableMenuObj:update()

        if risingEdgeKey(self.toggleKey) then
            self.isClosed = not self.isClosed
            if self.isClosed then
                self:closeMenu()
            else
                self:openMenu()
            end
        end 

        if not self.isClosed then
            for i, key in pairs(self.selectKeys[2]) do
                if keyIsPressed(key) then
                    if self.selectedId < #self.menuComponentList then
                        self.menuComponentList[self.selectedId].isSelected = false
                        self.selectedId = self.selectedId + 1
                        self.menuComponentList[self.selectedId].isSelected = true

                        self:changeSelectedBackGroundAnchor()
                    end
                end
            end
            for i, key in pairs(self.selectKeys[1]) do
                if keyIsPressed(key) then
                    if self.selectedId > 1 then
                        self.menuComponentList[self.selectedId].isSelected = false
                        self.selectedId = self.selectedId - 1
                        self.menuComponentList[self.selectedId].isSelected = true

                        self:changeSelectedBackGroundAnchor()
                    end
                end
            end

            self.selectedBackground:updatePos()
            self:updatePos()
            for i, component in pairs(self.menuComponentList) do
                component:update()
                component:updatePos()
                self.data[i] = component.state
            end
            self.onUpdate(self.data)
        end
    end

    --[[
        Menu's might not need to be deleted if the dev needs them again,
        so open and close are implemented and checked on the mapObj
    ]]
    function AttachableMenuObj:closeMenu()
        self:disableRender()
        self.selectedBackground:disableRender()
        for i, component in pairs(self.menuComponentList) do
            component:hide()
        end
    end

    function AttachableMenuObj:openMenu()
        self:enableRender()
        self.selectedBackground:enableRender()
        for i, component in pairs(self.menuComponentList) do
            component:show()
        end
    end

end