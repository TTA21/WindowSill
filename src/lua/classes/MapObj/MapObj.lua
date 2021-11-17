do --open

    ---TODO: create Area Scripts
    MapObj = {
        width,
        height,

        name,
        globalId,

        foreGround = {},
        middleGround = {},
        backGround = {},

        cameras = {},

        areas = {} ---used for placing scripts, such as, if withing x,y,x2,y2, run something

    }
    MapObj.__index = MapObj

    function MapObj:new(
        width, height, name
    )

        local self = setmetatable({}, MapObj)
        self.__index = self

        self.width = width or windowOptions.width
        if self.width < windowOptions.width then
            self.width = windowOptions.width
        end

        self.height = height or windowOptions.height
        if self.height < windowOptions.height then
            self.height = windowOptions.height
        end

        self.name = name or "Default Map Name"

        self.globalId = globalIdCounter
        globalIdCounter = globalIdCounter + 1

        self.foreGround = {}
        self.middleGround = {}
        self.backGround = {}
        self.dialogs = {}
        self.cameras = {}
        self.areas = {}

        self:clearRenderer()
        return self

    end

    --[[
        Expected to be called Once per map creation, but not  mandatory
    ]]--
    function MapObj:clearRenderer()
        renderItems = {}
    end

    --[[
        The developer should know the name of the object, for direct referencing
        EX:
            map:addNamedItemToForeGround("example", obj)
            map.foreground["example"].name
    ]]--
    function MapObj:addNamedItemToForeGround(name, obj)
        if  obj.posX > 0 and obj.posX < self.width and
            obj.posY > 0 and obj.posY < self.height then

                self.foreGround[name] = obj
        else
            print("Obj not added,  ", obj.name, " out of bounds!")
        end

        
    end


    --[[
        Used for scenario objects
    ]]--
    function MapObj:addToForeGround(obj)
        if  obj.posX >= 0 and obj.posX <= self.width and
            obj.posY >= 0 and obj.posY <= self.height then

            self.foreGround[#self.foreGround + 1] = obj
        else
            print("Obj not added,  ", obj.name, " out of bounds!")
        end
        
    end

    function MapObj:removeNamedFromForeGround(name)
        self.foreGround[name] = nil
    end

    function MapObj:removeFromForeGround(globalId)
        for index, object in pairs(self.foreGround) do
            if object.globalId == globalId then
                object = nil
            end
        end
    end

    --[[
        The developer should know the name of the object, for direct referencing
        EX:
            map:addNamedItemToMiddleGround("example", obj)
            map.middleGround["example"].name
    ]]--
    function MapObj:addNamedItemToMiddleGround(name, obj)
        if  obj.posX > 0 and obj.posX < self.width and
            obj.posY > 0 and obj.posY < self.height then

            self.middleGround[name] = obj
        else
            print("Obj not added,  ", obj.name, " out of bounds!")
        end
        
    end

    --[[
        Used for scenario objects
    ]]--
    function MapObj:addToMiddleGround(obj)
        if  obj.posX > 0 and obj.posX < self.width and
            obj.posY > 0 and obj.posY < self.height then

            self.middleGround[#self.middleGround + 1] = obj
        else
            print("Obj not added,  ", obj.name, " out of bounds!")
        end
        
    end

    function MapObj:removeNamedFromMiddleGround(name)
        self.middleGround[name] = nil
    end

    function MapObj:removeFromMiddleGround(globalId)
        for index, object in pairs(self.middleGround) do
            if object.globalId == globalId then
                object = nil
            end
        end
    end

    --[[
        The developer should know the name of the object, for direct referencing
        EX:
            map:addNamedItemToBackGround("example", obj)
            map.backGround["example"].name
    ]]--
    function MapObj:addNamedItemToBackGround(name, obj)
        if  obj.posX > 0 and obj.posX < self.width and
            obj.posY > 0 and obj.posY < self.height then

                self.backGround[name] = obj
        else
            print("Obj not added,  ", obj.name, " out of bounds!")
        end
        
    end

    --[[
        Used for scenario objects
    ]]--
    function MapObj:addToBackGround(obj)
        if  obj.posX > 0 and obj.posX < self.width and
            obj.posY > 0 and obj.posY < self.height then

                self.backGround[#self.backGround + 1] = obj
        else
            print("Obj not added,  ", obj.name, " out of bounds!")
        end
        
    end

    function MapObj:removeNamedFromBackGround(name)
        self.backGround[name] = nil
    end

    function MapObj:removeFromMiddleGround(globalId)
        for index, object in pairs(self.backGround) do
            if object.globalId == globalId then
                object = nil
            end
        end
    end

    --[[
        There can be multiple cameras at any one time, but only one active.
        As soon as the camera is added, it is disabled. Enable it after adding it.

        addCameraAnchoredTo activates it immediately however.
    ]]--
    function MapObj:addCameraAnchoredTo(name, obj)

        cameraObj = CameraObj:clone()
        cameraObj:anchorTo(obj, name)
        self.cameras[name] = cameraObj
        self:switchToCamera(name)

    end

    function MapObj:addCamera(name, camera)
        camera.currentCam = false
        self.cameras[name] = camera
    end

    function MapObj:switchToCamera(name)
        for i, cam in pairs(self.cameras) do
                cam:disableCamera()
        end

        self.cameras[name]:enableCamera()

    end

    --[[
        Used for dialogs
    ]]--
    function MapObj:addNamedItemToDialogs(name, obj)
        self.dialogs[name] = obj
    end
    function MapObj:addToDialogs(obj)
        self.dialogs[#self.dialogs + 1] = obj
    end

    function MapObj:removeNamedFromDialogs(name)
        self.dialogs[name] = nil
    end

    function MapObj:removeFromDialogs(globalId)
        for index, object in pairs(self.dialogs) do
            if object.globalId == globalId then
                object = nil
            end
        end
    end


    --[[
        Main render function, called every frame
    ]]--
    function MapObj:render()
        
        hasCameras = false
        for i, cam in pairs(self.cameras) do
            hasCameras = true
            cam:updateCameraPos()
            cam:renderTable(self.backGround)
            cam:renderTable(self.middleGround)
            cam:renderTable(self.foreGround)
            cam:renderTable(self.dialogs)
            cam:renderReorder()
        end

        if hasCameras == false then
            print("No camera attached to Map ", self.name)
        end

    end

    --[[
        Checks if anything in the table is colliding with the current object of interest
        if so, act accordingly
    ]]
    testInt = 0
    function MapObj:testTableForCollisions(obj, table)
        if obj.hasCollision == true then
            for i, obj2 in pairs(table) do
                if obj2.hasCollision == true then
                    if (obj.globalId ~= obj2.globalId) and checkNearby(obj2, obj, 2) then
                        directions = obj.hitBox:checkForDirectionalCollision(obj2.hitBox)
                        obj:dealWithCollision(directions)
                        obj2:dealWithCollision(directions)
                    end
                end
            end
        end
    end

    --[[
        Make Movable Objects Move, check collisions, make scripts work, reorder renderItems, etc

        ---NOTE:
        Directional collisions only checked on the middle and background,
        if something is on the foreground it is not checked, foreground serves for
        sprites whose collisions dont matter
    ]]--
    function MapObj:act()

        for i, obj in pairs(self.foreGround) do

            --test movement
            if obj:isa(MovableObj) or obj:isa(MovableObjAttachedObj)  then
                obj:keyboardMove()

                obj:moveToPos()

                ---Test for any possible collisions
                self:testTableForCollisions(obj, self.middleGround)
                self:testTableForCollisions(obj, self.backGround)

                obj:exertForce()obj:updateSprite()
                obj:exertResistance()
            end

            ---DO other scripts here too

            ---Update postition of attached objs
            if obj:isa(BaseObjAttachedObj) then
                if not obj.noBaseAttached then
                    obj:updatePos()
                end
            end

            ---Update postition of attached objs
            if obj:isa(MovableObjAttachedObj) then
                if not obj.noBaseAttached then
                    obj:updateForce()
                end
            end

        end

        for i, obj in pairs(self.middleGround) do

            ----test movement
            if obj:isa(MovableObj) or obj:isa(MovableObjAttachedObj) then
                obj:keyboardMove()

                obj:moveToPos()

                ---Test for any possible collisions
                self:testTableForCollisions(obj, self.middleGround)
                self:testTableForCollisions(obj, self.backGround)

                obj:exertForce()
                obj:updateSprite()
                obj:exertResistance()
            end
            ---DO other scripts here too

            ---Update postition of attached objs
            if obj:isa(BaseObjAttachedObj) then
                if not obj.noBaseAttached then
                    obj:updatePos()
                end
            end
            ---Update postition of attached objs
            if obj:isa(MovableObjAttachedObj) then
                if not obj.noBaseAttached then
                    obj:updateForce()
                end
            end

        end

        for i, obj in pairs(self.backGround) do

            --test movement
            if obj:isa(MovableObj) then
                obj:keyboardMove()

                obj:moveToPos()

                ---Test for any possible collisions
                self:testTableForCollisions(obj, self.middleGround)
                self:testTableForCollisions(obj, self.backGround)

                obj:exertForce()
                obj:updateSprite()
                obj:exertResistance()
            end
            ---DO other scripts here too

            ---Update postition of attached objs
            if obj:isa(BaseObjAttachedObj) then
                if not obj.noBaseAttached then
                    obj:updatePos()
                end
            end

            ---Update postition of attached objs
            if obj:isa(MovableObjAttachedObj) then
                if not obj.noBaseAttached then
                    obj:updateForce()
                end
            end

        end

        for i, obj in pairs(self.dialogs) do
            obj:update()
        end

        --occasionally reorder the scenario for better performance
        if (globalFrameCounter % 10000) == 1 then
            reorderRenderItems()
        end

    end

    

end --close