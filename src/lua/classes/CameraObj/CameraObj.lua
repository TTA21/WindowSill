do  --open

    --CameraObj | Class Declaration

    --[[
        :anchorTo(
            --anchor,
            --cameraName
        )
    ]]

    --[[
        Cameras serve to display the map, it is anchored to a BaseObj or a derivative.
        It also convinently does render reorders to keep visual aberrations to a minimum.

        There can be multiple cameras, aswell as multiple active cameras if one wants some special effects.

        Undefined behaviour of the camera is unanchored.

        Note that camera's do not have define's, it is created and immediatly anchored to something
        :anchorTo(
            --anchor,       --BaseObj or its derivatives
            --cameraName    --For debugging purposes
        )

        Render priority follows the following sequence:
        --priority_0 --Letters of Dialogs and menus
        --priority_1 --Dialogs and menus
        --priority_2 --ForeGround
        --priority_3 --Middle Ground
        --priority_4 --BackGround
    ]]

    CameraObj = object:clone()

    ---Function Declarations

    function CameraObj:anchorTo(
        anchor, cameraName
    )

        self.cameraId = newGlobalId()

        ---Undefined behaviour of the camera is unanchored.
        self.anchor = anchor or nil

        ---Immediately set to false, if none changed the game will never have an active camera
        self.currentCam = false

        ---Name for debugging purposes
        self.name = cameraName or "Give This Camera A Name Please"

        ---This can be changed after the class definition if wanted
        self.width = windowOptions.width
        self.height = windowOptions.height

        ---Points used to calculate relative positions on the map
        self.pointA = {
            X = self.anchor.posX - (self.width/2),
            Y = self.anchor.posY - (self.height/2),
        }
        self.pointB = {
            X = self.anchor.posX + (self.width/2),
            Y = self.anchor.posY + (self.height/2),
        }
        
    end

    --[[
        ************************Expected to be called every frame************************
        Update the camera position based on the anchor object, cant have the camera sitting still
        while the character moves.

        For the sake of not having to calculate the new positions of inactive cameras,
        the arithmetic is only done on the active ones. Might change later
    ]]--
    function CameraObj:updateCameraPos()
 
        if self.currentCam == true then

            --[[
                To get the caera to the center of the sprite,

                -   Start by getting the 0,0 if the anchor, the subtract by half the camera width,
                        that will put you in the center of the sprite's 0,0.

                -   However the texture does not have a 0 size width, as such simply add half the sprites
                        width to the position, that will put you in the very middle of the sprite's position
            ]]

            self.pointA.X = self.anchor.posX - (self.width/2) + ((self.anchor.texture.width/2) * self.anchor.scale)
            self.pointA.Y = self.anchor.posY - (self.height/2) + (self.anchor.texture.height/2 * self.anchor.scale)

            --[[
                Point A is the top left corner, Point B is the bottom right corner
            ]]
            self.pointB.X = self.pointA.X + self.width
            self.pointB.Y = self.pointA.Y + self.height

        end

    end


    --[[
        ************************Expected to be called every frame************************
        
        Renders whatever the camera sees on a MapObj table, only one camera should be rendering at any one time unless
        you know what youre doing.

        MapObj table is expected to be a table of BaseObj's or its derivatives.

        The camera simply dictates what sprites should be rendered by Rust's SDL, if the referenced
        RenderObj has isOnCamera=true, then rust will render it at the position the camera calculated.
    ]]--
    function CameraObj:renderTable(table)

        if self.currentCam == true then
            
            for index, baseObj in pairs(table) do
                
                --Calculate the position on the screen based on the position on the map
                screenX = baseObj.posX - self.pointA.X
                screenY = baseObj.posY - self.pointA.Y

                --Check if it would appear on the screen and set isOnCamera accordingly
                if  (screenX >= (-1 - (baseObj.texture.width * baseObj.scale))) and (screenX <= self.width+1) and
                    (screenY >= (-1 - baseObj.texture.height * baseObj.scale)) and (screenY <= self.height+1)
                then
                    baseObj:updateIsOnCamera(true)
                else 
                    baseObj:updateIsOnCamera(false)
                end

                --Update the renderObj properties if they changed between frames (animations)
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
        Orders based on PosY for items with the same priority, but places items with
        higher priority first.
        Mind that priority 0 is the highest priority

        TODO: make this presentable, genius.
    ]]
    function CameraObj:renderReorderPriority()

        --Get the items that are allowed to render
        itemsToRender = {}
        for i, rendObj in pairs(renderItems) do
            if rendObj.allowRender == true then
                itemsToRender[#itemsToRender+1] = rendObj
            end
        end

        --Sort them based on the Y position. In simple terms, items that are 'closer' to the camera
        --  have a higher Y value, as such they should be rendered last to be on top of everything.
        table.sort(itemsToRender, 
            function(a,b) 
                return (a.posY + a.referencingObj.texture.height*a.referencingObj.scale) < 
                (b.posY + b.referencingObj.texture.height*b.referencingObj.scale)
            end
        )

        --However some items are on top of other even if their Y positions are bigger, as such they
        --  should be ordered. Rust recieves an array of items to render, and it will render them in
        --  the order it recieves, it is this functions job to order them correctly.
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