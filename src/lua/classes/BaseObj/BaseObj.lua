do--open

    --BaseObj | Class Declaration

    --Every object that can be rendered is expected to be derived form this base class

    --[[
        obj1 = BaseObj:new(
            textures.bardo_asset,
            111,222
        )
        obj1.numAnimationStages = 3
    ]]--

    BaseObj = {}
    BaseObj.__index = BaseObj

    function BaseObj:new(
        name,               ---Self explanatory
        texture,            ---Texture object
        scale,              ---Width & Height of the sprite times scale. 1 for normal
        --renderObjId,        ---RederObj.ObjId
        --renderItemIndex,    ---renderItems[RenderItemIndex]
        posX,               ---Based on the map, not the screen
        posY,               ---Based on the map, not the screen
        hitBox,             ---Contains offset for proper hitboxing
        
        alpha,              ---Opacity, 0 for see through, 100 for fully opaque
        animStage,          ---Frame of the animation sprite
    
        --globalId,           ---Every Object has an unique id
        
        hasCollision,       ---Self explanatory, uses hitbox values
    
        numAnimationStages,             ---How many frames sprite has
        animStage,                      ---Current sprite animation
        numFramesPerAnimationStage,     ---Every 10 frames, move animStage forward, used for delay
        localFrameCounter,              ---Used for the animations

        allowRender
    )
        local self = setmetatable({}, BaseObj)
        self.__index = self
    
        self.texture = texture or {}
        self.RenderItemIndex = RenderItemIndex or -1
        self.posX = posX or 0
        self.posY = posY or 0
        self.scale = scale or 1

        self.hitBox = hitBoxObj or 
            HitBoxObj:new(
                0, 0, texture.width * self.scale, texture.height * self.scale, self
            )
        
        self.alpha = alpha or 100
        self.animStage = animStage or 0
    
        self.globalId = globalIdCounter
        globalIdCounter = globalIdCounter + 1
    
        self.name = name or "Bob"
        self.hasCollision = hasCollision or true
    
        self.numAnimationStages = numAnimationStages or 0
        self.animStage = animStage or 0
        self.numFramesPerAnimationStage = numFramesPerAnimationStage or 100
        self.localFrameCounter = localFrameCounter or 0

        self.allowRender = allowRender or true

        self:createRenderObj()
        
        return self
    end

    function BaseObj:createRenderObj()
        renderObj = RenderObj:new(
            self.texture.identifier,
            self.posX,       ---for now    
            self.posY,       ---for now  
            self.texture.width,      
            self.texture.height,     
            self.scale,      
            self.alpha,      
            self.animStage,
            self.allowRender
        )
        self.renderObjId = renderObj.objId
        renderItems[#renderItems+1] = renderObj
        self.renderItemIndex = findRenderObjById(self.renderObjId)
    end

    --[[
        *****Expected to be called every frame.******

        If an object, like a character moves or animates, it will have to be re-rendered with new data,
        call this function when you want to render this new state.
        
        Also automatically does the animation transitions for convenience
    ]]--
    function BaseObj:updateRenderObjCommon(x,y)

        renderItems[self.renderItemIndex].textureId = self.texture.identifier
        renderItems[self.renderItemIndex].posX = x or self.posX
        renderItems[self.renderItemIndex].posY = y or self.posY
        renderItems[self.renderItemIndex].scale = self.scale
        renderItems[self.renderItemIndex].alpha = self.alpha
        renderItems[self.renderItemIndex].animStage = self.animStage
        renderItems[self.renderItemIndex].allowRender = self.allowRender

        if self.localFrameCounter < self.numFramesPerAnimationStage then
            self.localFrameCounter = self.localFrameCounter + 1
        else
            self.localFrameCounter = 0
            
            if self.animStage < self.numAnimationStages then
                self.animStage = self.animStage + 1
            else
                self.animStage = 0
            end

        end

    end

    function BaseObj:enableRender()
        self.allowRender = true
        renderItems[self.renderItemIndex].allowRender = true
    end

    function BaseObj:disableRender()
        self.allowRender = false
        renderItems[self.renderItemIndex].allowRender = false
    end


end--close

--[[
---test stuff
            obj1 = BaseObj:new(
                textures.bardo_asset,
                111,222
            )
            obj1.numAnimationStages = 3

            for index, obj in pairs(renderItems) do
                print(index, ",", obj.posX, ",", obj.posY, obj.allowRender);
            end

            for i = 0, 50, 1 do
                obj1:updateRenderObjCommon()
                print(obj1.posX, obj1.posY, obj1.allowRender, obj1.localFrameCounter, obj1.animStage)
                
            end

            for index, obj in pairs(renderItems) do
                print(index, ",", obj.posX, ",", obj.posY, obj.allowRender, ",", obj.animStage);
            end

]]