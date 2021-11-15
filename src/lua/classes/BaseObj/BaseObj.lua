do  ---open

    --BaseObj | Class Declaration

    --Every object that can be rendered is expected to be derived form this base class

    BaseObj = object:clone()

    ---Data Declaration
    BaseObj.texture = {}
    BaseObj.posX = 0
    BaseObj.posY = 0
    BaseObj.scale = 1

    BaseObj.hitBox = {}
    
    BaseObj.alpha = 100
    BaseObj.animStage = 0

    BaseObj.globalId = -1

    BaseObj.name = "Default Name"
    BaseObj.hasCollision = false

    BaseObj.numAnimationStages = 0
    BaseObj.animStage = 0
    BaseObj.numFramesPerAnimationStage = 100
    BaseObj.localFrameCounter = 0

    BaseObj.allowRender = false

    ---Function Declaration

    function BaseObj:defineBase(
        name,               ---Self explanatory
        texture,            ---Texture object
        scale,              ---Width & Height of the sprite times scale. 1 for normal
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
        --renderObj
    )
        self.texture = texture or {}
        self.posX = posX or 0
        self.posY = posY or 0
        self.scale = scale or 1

        if hitBoxObj then
            self.hitBox = hitBoxObj
        else
            hitBox = HitBoxObj:clone()
            hitBox:defineHitBox(
                0, 0, 
                texture.width * self.scale, 
                texture.height * self.scale, 
                self
            )
            self.hitBox = hitBox
        end

        
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

        self.renderObj = RenderObj:clone()

        self.renderObj:new(
            self.texture,
            self.posX,          
            self.posY,        
            self.texture.width,      
            self.texture.height,     
            self.scale,      
            self.alpha,      
            self.animStage,
            self.allowRender
        )
        renderItems[#renderItems+1] = self.renderObj
    end

    --[[
        *****Expected to be called every frame.******

        If an object, like a character moves or animates, it will have to be re-rendered with new data,
        call this function when you want to render this new state.
        
        Also automatically does the animation transitions for convenience
    ]]--
    function BaseObj:updateRenderObjCommon(x,y)

        --self.renderObj.textureId = self.texture.identifier
        self.renderObj:changeSprite(self.texture)
        self.renderObj.posX = x or self.posX
        self.renderObj.posY = y or self.posY
        self.renderObj.scale = self.scale
        self.renderObj.alpha = self.alpha
        self.renderObj.animStage = self.animStage
        self.renderObj.allowRender = self.allowRender

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
        self.renderObj.allowRender = true
    end

    function BaseObj:disableRender()
        self.allowRender = false
        self.renderObj.allowRender = false
    end


end ---close