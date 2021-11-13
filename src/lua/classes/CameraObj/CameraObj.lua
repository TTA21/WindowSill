do --open

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

    CameraObj = {} --[[ = {
        width = windowOptions.width,    ---Size of the screen
        height = windowOptions.height,  ---Size of the screen


        anchor,  --Lua passes tables by refernece, cool right?

        pointA = {
            X=0,Y=0,    --relative to map
        },
        pointB = {
            X=width+pointA.X, Y=height+pointA.Y,
        },

        cameraId = -1,  --similar to BaseObj's globalId idea

        currentCam = false,  ---there can be multiple cameras

        name = "Default Camera Name",   ---For ease of use

    }]]--
    CameraObj.__index = CameraObj

    --[[
        Camera constructor achors itself to an object that posseses a posX or posY
    ]]--
    function CameraObj:anchorTo(
        anchor, cameraName
    )
        local self = setmetatable({}, CameraObj)
        self.__index = self
    
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
    
        return self
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
        Renders whatever the camera sees on a simple map table, only one camera should be rendering at any one time

    ]]--
    function CameraObj:render()

        ---Currently iterating through basic map table, pass real map later

        if self.currentCam == true then
            
            globalFrameCounter = globalFrameCounter + 1

            for index, baseObj in pairs(map.characters) do
                
                screenX = baseObj.posX - self.pointA.X
                screenY = baseObj.posY - self.pointA.Y

                if  (screenX >= (0 - baseObj.texture.width * baseObj.scale)) and (screenX <= self.width) and
                    (screenY >= (0 - baseObj.texture.height * baseObj.scale)) and (screenY <= self.height)
                then
                    
                    baseObj:enableRender()
                    baseObj:updateRenderObjCommon(screenX, screenY)

                else 

                    baseObj:disableRender()
                
                end

            end

        end

    end

    --[[
        Expected to be called every frame.
        Renders whatever the camera sees on a MapObj table, only one camera should be rendering at any one time

    ]]--
    function CameraObj:renderTable(table)

        if self.currentCam == true then
            
            globalFrameCounter = globalFrameCounter + 1

            for index, baseObj in pairs(table) do
                
                screenX = baseObj.posX - self.pointA.X
                screenY = baseObj.posY - self.pointA.Y

                if  (screenX >= (0 - (baseObj.texture.width * baseObj.scale))) and (screenX <= self.width) and
                    (screenY >= (0 - baseObj.texture.height * baseObj.scale)) and (screenY <= self.height)
                then
                    
                    baseObj:enableRender()
                    baseObj:updateRenderObjCommon(screenX, screenY)

                else 

                    baseObj:disableRender()
                
                end

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
    function CameraObj:renderReorder()
        itemsToRender = {}
        for i, rendObj in pairs(renderItems) do
            if rendObj.allowRender == true then
                itemsToRender[#itemsToRender+1] = rendObj
            end
        end

        table.sort(itemsToRender, function(a,b) return a.posY < b.posY end)
        currentCameraRenderItems = itemsToRender

    end

end --close