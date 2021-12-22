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

    require('classes/MapObj/CameraObjHandler')
    require('classes/MapObj/ScenarioObjsHandler')
    require('classes/MapObj/DialogObjHandler')
    require('classes/MapObj/MenuObjHandler')

    --[[
        Expected to be called Once per map creation, but not  mandatory
    ]]--
    function MapObj:clearRenderer()
        
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