do ---open
    --GameObj | Class Declaration

    --[[
        obj1 = RenderObj:new(
            textures.bardo.identifier, 
            400, 
            300, 
            width = textures.bardo.width, 
            height = textures.bardo.height,
            allowRender = true
        );
        renderItems[#renderItems+1] = obj1
    ]]--

    --To be placed in gameObjs for rendering ONLY
    RenderObj = {}
    RenderObj.__index = RenderObj

    function RenderObj:new(
        textureId,  ---Textures 'identifier' number, EX textures.bardo_asset.identifier
        posX,       ---Position in the screen to be rendered
        posY,       ---Position in the screen to be rendered
        width,      ---Can be found in the texture object, EX textures.bardo_asset.width
        height,     ---Can be found in the texture object, EX textures.bardo_asset.height
        scale,      ---Self evident
        alpha,      ---Opacity, 100 for fully opaque
        animStage,  ---Frame of the sprite
        allowRender ---Allows render to show this sprite
    )
        local self = setmetatable({}, RenderObj)
        self.__index = self

        self.objId = globalIdCounter
        globalIdCounter = globalIdCounter + 1
        self.textureId = textureId or -1
        self.posX = posX or 0
        self.posY = posY or 0
        self.width = width or 0
        self.height = height or 0
        self.scale = scale or 1
        self.alpha = alpha or 100
        self.animStage = animStage or 0
        self.allowRender = allowRender or false

        return self
    end

    --[[
        findRenderObjById(id)

        Returns the index of the object in renderItems,
            Params:
                objId : RenderObj's objId
            Return:
                index of object in renderItems or nil if it doenst exist
    ]]--
    function findRenderObjById(objId)

        for index, renderObj in pairs(renderItems) do
            if renderObj.objId == objId then
                return index
            end
        end
        return nil

    end

    --[[
        findRenderObjByIdInCamera(id)

        Returns the index of the object in currentCameraRenderItems,
            Params:
                objId : RenderObj's objId
            Return:
                index of object in renderItems or nil if it doenst exist
    ]]--
    function findRenderObjByIdInCamera(objId)

        for index, renderObj in pairs(currentCameraRenderItems) do
            if renderObj.objId == objId then
                return renderObj
            end
        end
        return nil

    end

    --[[
        Every time you finish generating a map, it is good to call this function,
        it will reorder sprites based on the Y axis, so that sprites closer to the camera are
        rendered first, instead of by creation order
    ]]
    function reorderRenderItems()
        table.sort(renderItems, function(a,b) return a.posY < b.posY end)
    end


end ---close