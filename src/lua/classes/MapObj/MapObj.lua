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

        self.cameras[name] = CameraObj:anchorTo(obj)
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
        end

        if hasCameras == false then
            print("No camera attached to Map ", self.name)
        end

    end

    --[[
        Checks if anything in the table is colliding with the current object of interest
        if so, act accordingly
    ]]
    function MapObj:testTableForCollisions(obj, table)
        for i, obj2 in pairs(table) do
            if obj2.hasCollision == true then
                if obj.globalId ~= obj2.globalId then
                    directions = obj.hitBox:checkForDirectionalCollision(obj2.hitBox)
                    obj:dealWithCollision(directions)
                    obj2:dealWithCollision(directions)
                end
            end
        end
    end

    --[[
        Make Movable Objects Move, check collisions, make scripts work, etc

        ---NOTE:
        Directional collisions only checked on the middle and background,
        if something is on the foreground it is not checked, foreground serves for
        sprites whose collisions dont matter
    ]]--
    function MapObj:act()
        --if obj.isMovableObj ~= nil

        for i, obj in pairs(self.foreGround) do
            if obj.isMovableObj == true then
                obj:keyboardMove()
                obj:mouseMove()

                ---Test for any possible collisions
                self:testTableForCollisions(obj, self.middleGround)
                self:testTableForCollisions(obj, self.backGround)

                obj:exertForce()
                obj:exertResistance()
            end

            ---DO other scripts here too

        end

        for i, obj in pairs(self.middleGround) do
            if obj.isMovableObj == true then
                obj:keyboardMove()
                obj:mouseMove()

                ---Test for any possible collisions
                self:testTableForCollisions(obj, self.middleGround)
                self:testTableForCollisions(obj, self.backGround)

                obj:exertForce()
                obj:exertResistance()
            end
            ---DO other scripts here too

        end

        for i, obj in pairs(self.backGround) do
            if obj.isMovableObj == true then
                obj:keyboardMove()
                obj:mouseMove()

                ---Test for any possible collisions
                self:testTableForCollisions(obj, self.middleGround)
                self:testTableForCollisions(obj, self.backGround)

                obj:exertForce()
                obj:exertResistance()
            end
            ---DO other scripts here too

        end
    end



end --close