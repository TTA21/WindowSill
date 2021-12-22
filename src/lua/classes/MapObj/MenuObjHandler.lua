    
    function MapObj:addNamedItemToMenus(name, obj)

        if type(name) ~= "string" then
            print("ALERT! addNamedItemToMenus called with non-string name at frame " .. globalFrameCounter)
            return false
        end

        if not obj:isa(AttachableMenuObj) then
            print("ALERT! addNamedItemToMenus called with non-AttachableMenuObj obj at frame " .. globalFrameCounter)
            return false
        end

        ---add menu obj to menus table by name
        obj:changePriority(globalDefaultParams.priorities.menu)
        self.menus[name] = obj

        ---Menu has a background, add it to the menu sprites list
        obj.selectedBackground:changePriority(globalDefaultParams.priorities.dialog)
        self.menuSprites[name .. "_selected_background"] = obj.selectedBackground

        ---Add every component in the menu, since the components are composed of dialogs and their letters,
        ---aswell as possible attached BaeObj's, all of them are placed in their tables accordingly here
        accumulator = 1
        for i, component in pairs(obj.menuComponentList) do
            component:changePriority(globalDefaultParams.priorities.dialog)
            self:addToDialogs(component.attachedDialog)

            if component:isa(StringInputMenuComponentObj) then
                self:addToDialogs(component.attachedInputDialog)
            end

            if component:isa(SliderMenuComponentObj) then
                component.slideHandler:changePriority(globalDefaultParams.priorities.dialog)
                self.menuSprites[name .. "_handler_" .. accumulator] = component.slideHandler

                if component.displayState then
                    self:addToDialogs(component.attachedStateDialog)
                end
            end
            accumulator = accumulator + 1
        end

    end