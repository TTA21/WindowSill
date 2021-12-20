
do  --open

    ---A RenderObj serves as the data packet to the SDL renderer to render something,
    ---Every RenderObj is a sprite with position and dimension
    RenderObj = object:clone()

    ---Data Declaration
    RenderObj.objId = -1
    RenderObj.texture = {}
    RenderObj.posX = 0
    RenderObj.posY = 0
    RenderObj.width = 0
    RenderObj.height = 0
    RenderObj.scale = 1
    RenderObj.alpha = 100
    RenderObj.animStage = 0
    RenderObj.allowRender = false

    ---Function Declarations

    function RenderObj:new(
        texture,    ---The texture is the sprite, its named texture because SDL calls it so
        posX,       ---Position in the screen to be rendered
        posY,       ---Position in the screen to be rendered
        width,      ---Can be found in the texture object, EX textures.bardo_asset.width
        height,     ---Can be found in the texture object, EX textures.bardo_asset.height
        scale,      ---Self evident
        alpha,      ---Opacity, 100 for fully opaque
        animStage,  ---Frame of the sprite
        allowRender,---Allows render to show this sprite
        referencingObj,
        priority,
        isOnCamera
    )

        self.objId = newGlobalId()
        self.texture = texture or {}
        self.textureId = texture.identifier or nil
        self.posX = posX or 0
        self.posY = posY or 0
        self.width = width or 0
        self.height = height or 0
        self.scale = scale or 1
        self.alpha = alpha or 100
        self.animStage = animStage or 0
        self.allowRender = allowRender or false
        self.referencingObj = referencingObj or {}
        self.priority = priority or 5
    end

    ---Serves to change the texture Id aswell
    function RenderObj:changeSprite(texture)
        self.texture = texture or {}
        self.textureId = texture.identifier or 1
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
        table.sort(renderItems, 
            function(a,b) 
                return (a.posY + a.referencingObj.texture.height*a.referencingObj.scale) < 
                (b.posY + b.referencingObj.texture.height*b.referencingObj.scale)
            end
        )
    end

end --close