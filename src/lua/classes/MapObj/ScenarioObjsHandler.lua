
    --[[
        Used for scenario objects.
        Must be a scenario object.
        
        Returns false if something goes wrong.
    ]]--
    function MapObj:addToScenario(obj, ground)

        groundTypes = {}
        groundTypes["ForeGround"] = {table = self.foreGround , priority = globalDefaultParams.priorities.foreGround}
        groundTypes["MiddleGround"] = {table = self.middleGround, priority = globalDefaultParams.priorities.middleGround}
        groundTypes["BackGround"] = {table = self.backGround, priority = globalDefaultParams.priorities.backGround}

        ---Simplified
        groundTypes["F"] = {table = self.foreGround , priority = globalDefaultParams.priorities.foreGround}
        groundTypes["M"] = {table = self.middleGround, priority = globalDefaultParams.priorities.middleGround}
        groundTypes["B"] = {table = self.backGround, priority = globalDefaultParams.priorities.backGround}

        if not groundTypes[ground] then
            print("Alert! addToScenario called with improper ground name '" .. ground .. "'")
            return false
        end 

        ---Must be scenario object
        if isScenarioObjType(obj) then

            --Must be within bounds of map
            if  obj.posX >= 0 and obj.posX <= self.width and
                obj.posY >= 0 and obj.posY <= self.height then

                    ---Only add to table if there are no duplicates
                    if self:checkForDuplicates(obj.globalId) then
                        obj:changePriority(groundTypes[ground].priority)
                        groundTypes[ground].table[#groundTypes[ground].table + 1] = obj
                    else
                        print("Alert! Attempt to add duplicate entry to " .. ground .. " at frame " .. globalFrameCounter .." | globalId = " .. obj.globalId)
                    end
            else
                print("Obj not added, " .. obj.name .. " out of bounds!")
                return false
            end
        else
            print("Obj not added, " .. obj.name .." not an acceptable scenario object!")
            return false
        end
        
    end

    --[[
        Remove an item from the foreground.
        Returns false if no item was found.
        :removeFromForeGround({
            globalId = ,    ---only one will suffice
            object = ,
        })
    ]]
    function MapObj:removeFromScenario(params)

        if params.globalId then
            foundObj = false
            for index, object in pairs(self.foreGround) do
                if object.globalId == params.globalId then
                    self.foreGround[index] = nil
                    foundObj = true
                end
            end
            return foundObj

        elseif params.object then
            foundObj = false
            for index, object in pairs(self.foreGround) do
                if object.globalId == params.object.globalId then
                    self.foreGround[index] = nil
                    foundObj = true
                end
            end
            return foundObj

        else

            return false
        end

    end

    function isScenarioObjType(obj)

        if obj:isa(AttachableDialogObj) then return false end
        if obj:isa(AttachableMenuObj) then return false end
        if obj:isa(CameraObj) then return false end
        if obj:isa(HitBoxObj) then return false end
        if obj:isa(MapObj) then return false end

        if obj:isa(BaseObj) then return true end

        return false
    end

    --[[
        Checks ground tables for duplicate entries,
        returns false if duplicate is found.
    ]]
    function MapObj:checkForDuplicates(globalId)

        for i, obj in pairs(self.backGround) do
            if obj.globalId == globalId then
                return false
            end
        end

        for i, obj in pairs(self.middleGround) do
            if obj.globalId == globalId then
                return false
            end
        end

        for i, obj in pairs(self.foreGround) do
            if obj.globalId == globalId then
                return false
            end
        end

        return true

    end

