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
            cam:updateCameraPos()                       ---Move the camera

            cam:renderTable(self.backGround)            ---Render Grounds
            cam:renderTable(self.middleGround)          ---Render Grounds
            cam:renderTable(self.foreGround)            ---Render Grounds

            cam:renderTable(self.dialogs.backGrounds)   ---Render the dialog back plate
            cam:renderTable(self.dialogs.letters)       ---Render the letters

            cam:renderTable(self.menus)                 ---Render the menu's back plate
            for i, component in pairs(self.menus) do
                cam:renderTable(component.menuComponentList)    ---Render the menu's dialogs
            end
            cam:renderTable(self.menuSprites)           ---Render the menus buttons and handles

            --cam:renderReorderPosY() --old
            cam:renderReorderPriority()                 ---Make everything stay coherent
            
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
            
            ---Foreground has no collisions
            self:scenarioObjLoop({
                iterateTable = self.foreGround,    ---Table to iterate through
                onMovableObjUpdate = (
                    function (this, obj) 
                        obj:keyboardMove()  ---To be removed later
                    end
                ),
            })

            self:scenarioObjLoop({
                iterateTable = self.middleGround,   ---Table to iterate through
                collisionTables = {
                    self.middleGround, self.backGround,
                },
                onMovableObjUpdate = (
                    function (this, obj) 
                        obj:keyboardMove()  ---To be removed later
                    end
                ),
            })

            ---BackGround does have collisions on, might change later
            self:scenarioObjLoop({
                iterateTable = self.backGround,   ---Table to iterate through
                collisionTables = {
                    self.middleGround, self.backGround,
                },
                onMovableObjUpdate = (
                    function (this, obj) 
                        obj:keyboardMove()  ---To be removed later
                    end
                ),
            })

        end --pausegame

        ---Update Queues
        for i, obj in pairs(self.queues) do
            obj:update()
        end

        ---Update Dialogs
        self:dialogObjLoop()

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