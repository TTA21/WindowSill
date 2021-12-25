
    --[[
        Used for scenario objects.
        Must be a scenario object.

        Can also auto attach an active camera for convinience.
        
        Returns false if something goes wrong.
    ]]--
    function MapObj:addToScenario(obj, ground, withCamera, cameraName)

        groundTypes = self:groundTypes()

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

                        ---If withCamera is true, automatically add a camera, if no camera name provided
                        ---camera name will be the object name + "_auto_camera"
                        if withCamera then
                            cameraName = cameraName or (obj.name .. "_auto_camera")
                            cameraObj = CameraObj:clone()
                            cameraObj:anchorTo(obj, cameraName)
                            self:addCamera(cameraName, cameraObj)
                            self:switchToCamera(cameraName)
                        end
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
            ground = ,
        })
    ]]
    function MapObj:removeFromScenario(params)
        
        groundTypes = self:groundTypes()

        if type(params.ground) ~= "string" then
            print("ALERT! removeFromScenario called with non-string 'ground' at frame " .. globalFrameCounter)
            return false
        end

        if not groundTypes[params.ground] then
            print("Alert! removeFromScenario called with improper ground name '" .. ground .. "'")
            return false
        end 
        
        foundObj = false
        if params.globalId then
            for index, object in pairs(groundTypes[params.ground].table) do
                if object.globalId == params.globalId then
                    self.dialogs[index] = nil
                    foundObj = true
                end
            end
        elseif params.object then
            for index, object in pairs(groundTypes[params.ground].table) do
                if object.globalId == params.object.globalId then
                    self.dialogs[index] = nil
                    foundObj = true
                end
            end
        else

            return false
        end

        return foundObj
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

    function MapObj:groundTypes()
        groundTypes = {}
        groundTypes["ForeGround"] = {table = self.foreGround , priority = globalDefaultParams.priorities.foreGround}
        groundTypes["MiddleGround"] = {table = self.middleGround, priority = globalDefaultParams.priorities.middleGround}
        groundTypes["BackGround"] = {table = self.backGround, priority = globalDefaultParams.priorities.backGround}

        ---Simplified
        groundTypes["F"] = {table = self.foreGround , priority = globalDefaultParams.priorities.foreGround}
        groundTypes["M"] = {table = self.middleGround, priority = globalDefaultParams.priorities.middleGround}
        groundTypes["B"] = {table = self.backGround, priority = globalDefaultParams.priorities.backGround}

        return groundTypes
    end 

-----------------------------------LOOP

    --[[
        :scenarioObjLoop({
            iterateTable = ,    ---Table to iterate through
            collisionTables = {
                
            },
            onMovableObjUpdate = (function (this, obj) end),
            onLoopIteration = (function (this, obj) end),
            onEndOfLoop = (function (this) end),
        })
    ]]
    function MapObj:scenarioObjLoop(params)

        for i, obj in pairs(params.iterateTable) do

            --Move movable objs
            if obj:isa(MovableObj) then

                ---Helper Closure
                if params.onMovableObjUpdate then
                    params.onMovableObjUpdate(self, obj)
                end

                ---Update postition of attached objs
                if obj:isa(MovableObjAttachedObj) and not obj.noBaseAttached then
                    obj:updateForce()
                end

                obj:moveToPos()     ---Movement script of MovableObj

                ---Test Collisions in selected tables if initialized
                if params.collisionTables and obj.hasCollision then
                    for _, collTable in pairs(params.collisionTables) do
                        self:testTableForCollisions(obj, collTable)
                    end
                end

                ---Force arithmetic and sprite updates based on force
                obj:exertForce()
                obj:updateSprite()
                obj:exertResistance()

            end --if obj:isa(MovableObj)

            ---Update postition of attached objs
            if obj:isa(BaseObjAttachedObj) and not obj.noBaseAttached then
                obj:updatePos()
            end

            ---End of iteration closure
            if params.onLoopIteration then
                params.onLoopIteration(self, obj)
            end

        end --for pairs(params.iterateTable)

        ---End of loop closure
        if params.onEndOfLoop then
            params.onEndOfLoop(self)
        end

    end