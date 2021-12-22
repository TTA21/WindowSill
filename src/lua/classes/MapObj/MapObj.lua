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
        self.menus = {}  ---Menus use the dialogs to show letters
        self.menuSprites = {}
        self.cameras = {}
        self.areas = {}
        self.queues = {}

        self:clearRenderer()

        self.gamePaused = false
        self.gamePausedDueToDialog = false

    end

    require('classes/MapObj/ForeGroundHandler')
    require('classes/MapObj/MiddleGroundHandler')
    require('classes/MapObj/BackGroundHandler')
    require('classes/MapObj/ScenarioObjsHandler')

    --[[
        Expected to be called Once per map creation, but not  mandatory
    ]]--
    function MapObj:clearRenderer()
        
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
        self:insertLetterQueue(obj)
        
    end

    function MapObj:addToDialogs(obj)
        obj:changePriority(1)
        self.dialogs.backGrounds[#self.dialogs.backGrounds + 1] = obj
        self:insertLetterQueue(obj)
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
        Used for dialogs
    ]]--
    function MapObj:insertLetterQueue(obj)
        queue = QueueObj:clone()
        queue:defineQueue({
            intervalFrame = obj.framesPerLetter,
            onConstructor = (
                function (this)
                    this.accumulator = 1
                end
            ),
            onUpdate = (
                function (this)
                    self:insertLetter(obj.letters[this.accumulator]) 
                    this.accumulator = this.accumulator + 1
                end
            ),
            stopCondition = (
                function (this) 
                    return ( 1 + #obj.letters == this.accumulator)
                end
            ),
        })
        self.queues[#self.queues + 1] = queue
    end

    --[[
        Used for menus
    ]]
    --[[
    function MapObj:addNamedItemToMenus(name, obj)
        --For now just the components
        obj:changePriority(1)
        self.menus.sprites[name] = obj
        self:addToDialogs(obj.attachedDialog)

        if obj:isa(StringInputMenuComponentObj) then
            self:addToDialogs(obj.attachedInputDialog)
        end

        if obj:isa(SliderMenuComponentObj) then
            obj.slideHandler:changePriority(1)
            self.menus.sprites[name .. "_handler"] = obj.slideHandler

            if obj.displayState then
                self:addToDialogs(obj.attachedStateDialog)
            end
        end

    end
    ]]

    function MapObj:addNamedItemToMenus(name, obj)
        obj:changePriority(1)
        self.menus[name] = obj
        obj.selectedBackground:changePriority(1)
        self.menuSprites[name .. "_selectedBackground"] = obj.selectedBackground

        accumulator = 1
        for i, component in pairs(obj.menuComponentList) do
            component:changePriority(1)
            self:addToDialogs(component.attachedDialog)

            if component:isa(StringInputMenuComponentObj) then
                self:addToDialogs(component.attachedInputDialog)
            end
    
            if component:isa(SliderMenuComponentObj) then
                component.slideHandler:changePriority(1)
                self.menuSprites[name .. "_handler_" .. accumulator] = component.slideHandler
    
                if component.displayState then
                    self:addToDialogs(component.attachedStateDialog)
                end
            end
            accumulator = accumulator + 1
        end

    end

    function MapObj:addQueue(obj)
        if obj:isa(QueueObj) then
            self.queues[#self.queues+1] = obj
        else
            print("ALERT! Attempt to append non-queue obj to queues in map " .. self.name)
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

            cam:renderTable(self.menus)
            for i, component in pairs(self.menus) do
                cam:renderTable(component.menuComponentList)
            end
            cam:renderTable(self.menuSprites)

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

        ---Update Queues
        for i, obj in pairs(self.queues) do
            obj:update()
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

        ---Update Menus
        for i, menu in pairs(self.menus) do
            menu:update()
            self.gamePaused = menu.pauseGame
        end

        --occasionally reorder the scenario for better performance
        if (globalFrameCounter % 10000) == 1 then
            reorderRenderItems()
        end

        keysPressedOld = keysPressed    ---update key buffer

    end

    

end --close