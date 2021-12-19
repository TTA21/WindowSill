do  --open

    --[[
        xxxxxxxxx
        x       x   A = anchor, the obj the player is interested in
        x       x   x = borders
        x   A   x   distance borders to anchor = [width/2][height/2]
        x       x   anything outside borders has 'allowRender = false'
        x       x   converts positions on the map to positions on the screen, 
        xxxxxxxxx       thats the purpose of the camera
    ]]--

    --A camera can anchor to anything that has a posX and posY

    CameraObj = object:clone()

    ---Data Declaration

    CameraObj.width = windowOptions.width
    CameraObj.height = windowOptions.height

    CameraObj.anchor = nil

    CameraObj.pointA = {}

    CameraObj.pointB = {}

    CameraObj.cameraId = -1

    CameraObj.currentCam = false
    CameraObj.name = "Give This Camera A Name Please"

    ---Function Declarations

    function CameraObj:anchorTo(
        anchor, cameraName
    )
        self.width = windowOptions.width
        self.height = windowOptions.height

        self.anchor = anchor or nil

        self.pointA = {
            X = self.anchor.posX - (self.width/2),
            Y = self.anchor.posY - (self.height/2),
        }

        self.pointB = {
            X = self.anchor.posX + (self.width/2),
            Y = self.anchor.posY + (self.height/2),
        }

        self.cameraId = globalIdCounter
        globalIdCounter = globalIdCounter+1

        self.currentCam = false
        self.name = cameraName or "Give This Camera A Name Please"
    end

    --[[
        Expected to be called every frame, serves to update what the camera sees based
        on the anchor's new postion, leave it uncalled and the screen never updates

        You can have multiple cameras
    ]]--
    function CameraObj:updateCameraPos()
 
        if self.currentCam == true then

            self.pointA.X = self.anchor.posX - (self.width/2) + (self.anchor.texture.width/2)
            self.pointA.Y = self.anchor.posY - (self.height/2) + (self.anchor.texture.height/2)

            self.pointB.X = self.pointA.X + self.width
            self.pointB.Y = self.pointA.Y + self.height

        end
        

    end


    --[[
        Expected to be called every frame.
        Renders whatever the camera sees on a MapObj table, only one camera should be rendering at any one time

    ]]--
    function CameraObj:renderTable(table)

        if self.currentCam == true then
            
            for index, baseObj in pairs(table) do
                
                screenX = baseObj.posX - self.pointA.X
                screenY = baseObj.posY - self.pointA.Y

                if  (screenX >= (-1 - (baseObj.texture.width * baseObj.scale))) and (screenX <= self.width+1) and
                    (screenY >= (-1 - baseObj.texture.height * baseObj.scale)) and (screenY <= self.height+1)
                then
                    baseObj:updateIsOnCamera(true)
                else 
                    baseObj:updateIsOnCamera(false)
                end

                baseObj:updateRenderObjCommon(screenX, screenY)

            end

        end

    end

    function CameraObj:enableCamera()
        self.currentCam = true
    end
    function CameraObj:disableCamera()
        self.currentCam = false
    end

    --[[
        Generate render objects the camera can see in order of posY in the currentCameraRenderItems.
        Usually called after renderTable
    ]]
    function CameraObj:renderReorderPosY()
        itemsToRender = {}
        for i, rendObj in pairs(renderItems) do
            if rendObj.allowRender and renderObj.isOnCamera then
                itemsToRender[#itemsToRender+1] = rendObj
            end
        end

        table.sort(itemsToRender, 
            function(a,b) 
                return (a.posY + a.referencingObj.texture.height*a.referencingObj.scale) < 
                (b.posY + b.referencingObj.texture.height*b.referencingObj.scale)
            end
        )
        currentCameraRenderItems = itemsToRender

    end

    --[[
        Orders based on PosY for items with the same priority, but places items with
        higher priority first.
        Mind that priority 0 is the highest priority
    ]]
    function CameraObj:renderReorderPriority()
        itemsToRender = {}
        for i, rendObj in pairs(renderItems) do
            if rendObj.allowRender == true then
                itemsToRender[#itemsToRender+1] = rendObj
            end
        end

        table.sort(itemsToRender, 
            function(a,b) 
                return (a.posY + a.referencingObj.texture.height*a.referencingObj.scale) < 
                (b.posY + b.referencingObj.texture.height*b.referencingObj.scale)
            end
        )

        priority_0 = {} --Letters of said Dialogs and menus
        priority_1 = {} --Dialogs and menus
        priority_2 = {} --ForeGround
        priority_3 = {} --Middle Ground
        priority_4 = {} --BackGround

        for index, obj in pairs(itemsToRender) do
            if obj.priority == 0 then
                priority_0[#priority_0 + 1] = obj
            end

            if obj.priority == 1 then
                priority_1[#priority_1 + 1] = obj
            end

            if obj.priority == 2 then
                priority_2[#priority_2 + 1] = obj
            end

            if obj.priority == 3 then
                priority_3[#priority_3 + 1] = obj
            end

            if obj.priority == 4 then
                priority_4[#priority_4 + 1] = obj
            end
        end 

        orderedItemsToRender = {}

        for i, obj in pairs(priority_4) do
            orderedItemsToRender[#orderedItemsToRender + 1] = obj
        end

        for i, obj in pairs(priority_3) do
            orderedItemsToRender[#orderedItemsToRender + 1] = obj
        end

        for i, obj in pairs(priority_2) do
            orderedItemsToRender[#orderedItemsToRender + 1] = obj
        end

        for i, obj in pairs(priority_1) do
            orderedItemsToRender[#orderedItemsToRender + 1] = obj
        end

        for i, obj in pairs(priority_0) do
            orderedItemsToRender[#orderedItemsToRender + 1] = obj
        end

        currentCameraRenderItems = orderedItemsToRender

    end


end --close