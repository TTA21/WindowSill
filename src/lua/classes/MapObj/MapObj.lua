do --open

    MapObj = object:clone()

    function MapObj:defineMap(
        width, height, name
    )

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
        self.dialogs = {
            backGrounds = {},
            letters = {}
        }
        self.menus = {  ---Menus use the dialogs to show letters
            backGrounds = {},
            sprites = {}
        }
        self.cameras = {}
        self.areas = {}
        self.timedInsertions = {}  ---for TimedInsertions ONLY

        self:clearRenderer()

        self.gamePaused = false
        self.gamePausedDueToDialog = false

    end

    --[[
        Expected to be called Once per map creation, but not  mandatory
    ]]--
    function MapObj:clearRenderer()
        
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

                obj:changePriority(2)
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

                obj:changePriority(2)
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

                obj:changePriority(3)
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

                obj:changePriority(3)
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

                obj:changePriority(4)
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

                obj:changePriority(4)
                self.backGround[#self.backGround + 1] = obj
        else
            print("Obj not added,  ", obj.name, " out of bounds!")
        end
        
    end

    function MapObj:removeNamedFromBackGround(name)
        self.backGround[name] = nil
    end

    function MapObj:removeFromBackGround(globalId)
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
        obj:changePriority(1)
        self.dialogs.backGrounds[name] = obj
        timedInsertion = TimedInsertionObj:clone()
        timedInsertion:defineTimedRenderer(
            obj.framesPerLetter, 
            obj.letters, 
            self.dialogs.letters
        )
        self.timedInsertions[#self.timedInsertions+1] = timedInsertion
    end
    function MapObj:addToDialogs(obj)
        obj:changePriority(1)
        self.dialogs.backGrounds[#self.dialogs.backGrounds + 1] = obj
        timedInsertion = TimedInsertionObj:clone()
        timedInsertion:defineTimedRenderer(
            obj.framesPerLetter, 
            obj.letters, 
            self.dialogs.letters
        )
        self.timedInsertions[#self.timedInsertions+1] = timedInsertion
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
        Used for dialogs
    ]]--
    function MapObj:insertLetter(obj)
        obj:changePriority(0)
        self.dialogs.letters[#self.dialogs.letters + 1] = obj
    end

    --[[
        Used for menus
    ]]
    --[[
        Used for dialogs
    ]]--
    function MapObj:addNamedItemToMenus(name, obj)
        --For now just the components
        obj:changePriority(1)
        self.menus.sprites[name] = obj
        self:addToDialogs(obj.attachedDialog)

        if obj:isa(StringInputMenuComponentObj) then
            self:addToDialogs(obj.attachedInputDialog)
        end

        if obj:isa(SliderMenuComponentObj) then
            obj.slideHandler:changePriority(0)  ---To go on top of the bar
            self.menus.sprites[name .. "_handler"] = obj.slideHandler

            if obj.displayState then
                self:addToDialogs(obj.attachedStateDialog)
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

            cam:renderTable(self.dialogs.backGrounds)
            cam:renderTable(self.dialogs.letters)
            cam:renderTable(self.menus.backGrounds)
            cam:renderTable(self.menus.sprites)

            --cam:renderReorderPosY() --old
            cam:renderReorderPriority()
            
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
        Standard Pause
    ]]
    function MapObj:pauseGame()
        self.gamePaused = true
    end

    function MapObj:unPauseGame()
        self.gamePaused = false
    end

    --[[
        Pause due to dialog
    ]]
    function MapObj:pauseGameDueToDialog()
        self.gamePausedDueToDialog = true
    end

    function MapObj:unPauseGameDueToDialog()
        self.gamePausedDueToDialog = false
    end

    --[[
        Make Movable Objects Move, check collisions, make scripts work, reorder renderItems, etc

        ---NOTE:
        Directional collisions only checked on the middle and background,
        if something is on the foreground it is not checked, foreground serves for
        sprites whose collisions dont matter
    ]]--
    function MapObj:act()

        if not self.gamePausedDueToDialog and not self.gamePaused then
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

        end --pausegame

        ---Update Timed Renderers
        for i, obj in pairs(self.timedInsertions) do
            --obj:update()
            ret = obj:returnObj()
            if ret then
                self:insertLetter(ret)
            end

            if obj.isDone then
                self.timedInsertions[i] = nil
            end
        end

        ---Update Dialogs
        for i, obj in pairs(self.dialogs.backGrounds) do
            if obj.allowRender then
                obj:update()
            end
            if obj.pauseGame then
                self:pauseGameDueToDialog()
            end
            if obj.isClosed and obj.pauseGame then
                self:unPauseGameDueToDialog()
                self.dialogs[i] = nil
            end
        end
        ---Update Dialogs
        for i, obj in pairs(self.dialogs.letters) do
            if obj.allowRender then
                obj:updatePos()
            end
        end

        --Update Menus, just components for now
        for i, obj in pairs(self.menus.sprites) do
            --allow rendering is checked by the component, FOR NOW
            obj:update()
            obj:updatePos()
        end

        --occasionally reorder the scenario for better performance
        if (globalFrameCounter % 10000) == 1 then
            reorderRenderItems()
        end

        keysPressedOld = keysPressed    ---update key buffer

    end

    

end --close