do
    --[[
        Simple menus, can do buttons (true or false), String Inputs (to write stuff),
        and Sliders (integer 0 to 100)
    ]]
    AttachableMenuObj = BaseObjAttachedObj:clone()
    --[[
        defineAttachableMenu({
            baseObjParams
            baseObjAttached params,
            menuTitle,          ---Self explanatory
            optionsList,        ---What the menu contains
            toggleKey,          ---The key that opens and closes the menu
            onUpdate,           ---Function handler provided by the dev, it is called after and update
                                ---to do something with the menu's data
            selectKeys,         ---The keys that select wich menu component is being modified, only goes up or down
            backGroundTexture   ---The background for the overall menu,not its components
        })
        
    ]]

    function AttachableMenuObj:defineAttachableMenu(
        params
    )

        self:defineBaseObjAttached(params)

        self.title = params.menuTitle or "Menu Title"
        self.optionsList = params.optionsList or {}
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

        self.selectKeys = params.selectKeys or {{"Up"}, {"Down"}}

        self.isClosed = false
        self.toggleKey = params.toggleKey or "Tab"
        self.pauseGame = true
        self.onUpdate = params.onUpdate or 
            function(states)
                ---states recieves self.data on call
                print(states[1])
            end

        self:changeSprite(params.backGroundTexture or textures.std_menu_background_blue_10_10)

        yAccumulator = 0
        componentTypeCount = {0,0,0} ---For calculating size of background
        for i, component in pairs(self.optionsList) do
            --component[2].description = component[2].description .. "_" .. i

            if component[1] == "Button" then
                componentTypeCount[1] = componentTypeCount[1]+1

                button = ButtonMenuObj:clone()
                
                yAccumulator = 20 + yAccumulator

                ---component[2] has baseObj data, but not defineBaseObjAttached, must merge early
                merge(component[2], {
                    anchor = self, 
                    offsetX = 10,     --X
                    offsetY = yAccumulator    --Y
                })
                button:defineBaseObjAttached(component[2])

                button:defineButtonMenu(
                    component[2].description, 
                    component[2].selectKey, 
                    false,  --initial selection is done automatically 
                    component[2].initialState, 
                    component[2].texturePressed, 
                    component[2].textureNotPressed,
                    component[2].font
                )
                self.menuComponentList[#self.menuComponentList +1 ] = button
                self.data[i] = button.state

            elseif component[1] == "Slider" then
                componentTypeCount[2] = componentTypeCount[2]+1

                sliderInput = SliderMenuComponentObj:clone()

                yAccumulator = 50 + yAccumulator    ---Needs bigger spacing for title

                ---component[2] has baseObj data, but not defineBaseObjAttached, must merge early
                merge(component[2], {
                    anchor = self, 
                    offsetX = 20,     --X
                    offsetY = yAccumulator    --Y
                })
                sliderInput:defineBaseObjAttached(component[2])

                sliderInput:defineSliderMenu(
                    component[2].description,
                    component[2].sliderKeys,
                    false,
                    component[2].initialState,
                    component[2].valueChangeDelay,
                    component[2].displayValueOnSide,
                    component[2].sliderTexture,
                    component[2].sliderHandlerTexture,
                    component[2].font
                )
                self.menuComponentList[#self.menuComponentList +1 ] = sliderInput
                self.data[i] = sliderInput.state
                
            elseif component[1] == "StringInput" then
                componentTypeCount[3] = componentTypeCount[3]+1

                stringInput = StringInputMenuComponentObj:clone()

                yAccumulator = 20 + yAccumulator

                ---component[2] has baseObj data, but not defineBaseObjAttached, must merge early
                merge(component[2], {
                    anchor = self, 
                    offsetX = 10,     --X
                    offsetY = yAccumulator    --Y
                })
                stringInput:defineBaseObjAttached(component[2])

                yAccumulator = 20 + yAccumulator    ---More spacing for anything below this component

                stringInput:defineStringInputMenu(
                    component[2].description,
                    component[2].stringLength,
                    false,
                    component[2].initialState,
                    component[2].font
                )

                self.menuComponentList[#self.menuComponentList +1 ] = stringInput
                self.data[i] = stringInput.state
            end
        end

        self.menuComponentList[1].isSelected = true

        self.selectedId = 1 ---Wich component is selected

        self.selectedBackground = BaseObjAttachedObj:clone()
        self.selectedBackground:defineBaseObjAttached({
            name = self.title .. "_selectedBackground",
            scale = 1,
            anchor = self.menuComponentList[self.selectedId],
            offsetX = -5,
            offsetY = -2
        })
        
        self:changeSelectedBackGroundAnchor()

         self:changeDimensions(300, yAccumulator + (20 * componentTypeCount[2]) )

    end

    function AttachableMenuObj:changeSelectedBackGroundAnchor()
        self.selectedBackground.anchor = self.menuComponentList[self.selectedId]

        if self.selectedBackground.anchor:isa(StringInputMenuComponentObj) then
            self.selectedBackground:changeDimensions(
                self.menuComponentList[self.selectedId].attachedInputDialog.width,
                self.menuComponentList[self.selectedId].attachedInputDialog.height
            );
        else
            self.selectedBackground:changeDimensions(
                self.menuComponentList[self.selectedId].attachedDialog.width,
                self.menuComponentList[self.selectedId].attachedDialog.height/3
            );
        end
    end

    function AttachableMenuObj:update()

        if risingEdgeKey(self.toggleKey) then
            self.isClosed = not self.isClosed
            if self.isClosed then
                self:closeMenu()
                self.pauseGame = false
            else
                self:openMenu()
                self.pauseGame = true
            end
        end 

        if not self.isClosed then
            for i, key in pairs(self.selectKeys[2]) do
                if risingEdgeKey(key) then
                    if self.selectedId < #self.menuComponentList then
                        self.menuComponentList[self.selectedId].isSelected = false
                        self.selectedId = self.selectedId + 1
                        self.menuComponentList[self.selectedId].isSelected = true

                        self:changeSelectedBackGroundAnchor()
                    end
                end
            end
            for i, key in pairs(self.selectKeys[1]) do
                if risingEdgeKey(key) then
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

                if component:isa(SliderMenuComponentObj) then
                    component.slideHandler:updatePos()
                end
                self.data[i] = component.state
            end
            self.onUpdate(self.data)
        end
    end

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