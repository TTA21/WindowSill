do  ---open

    --BaseObj | Class Declaration

    --[[
        Every object that can be rendered is expected to be derived from this base class

        Has a simple hitbox for collisions, does simple 1 sprite animations.

        obj:defineBase({
            texture = textures.std_menu_background_white_10_10,
            posX = 1,
            posY = 1,
            scale = 1,
            prority = 4,
            hitBoxObj = null,
            alpha = 100,
            animStage = 0,
            numAnimationStages = 0,
            name = "ASD",
            hasCollision = true,
            pauseAnimation = false,
            numFramesPerAnimationStage = 100,
            localFrameCounter = 0,
            allowRender = true

        })
    ]]--
    BaseObj = object:clone()

    ---Function Declaration

    function BaseObj:defineBase(
        params  ---The parameters object
    )
        self.texture = params.texture or textures.std_menu_background_white_10_10
        self.posX = params.posX or 1
        self.posY = params.posY or 1
        self.scale = params.scale or 1

        --priority_0 --Letters of Dialogs and menus
        --priority_1 --Dialogs and menus
        --priority_2 --ForeGround
        --priority_3 --Middle Ground
        --priority_4 --BackGround
        self.priority = params.priority or 4   

        if params.hitBoxObj then
            self.hitBox = params.hitBoxObj
        else
            hitBox = HitBoxObj:clone()
            hitBox:defineHitBox(
                0, 0, 
                self.texture.width * self.scale, 
                self.texture.height * self.scale, 
                self
            )
            self.hitBox = hitBox
        end

        
        self.alpha = params.alpha or 100
    
        self.globalId = globalIdCounter
        globalIdCounter = globalIdCounter + 1
    
        self.name = params.name or "Bob"
        self.hasCollision = params.hasCollision or true
    
        if self.texture then
            self.numAnimationStages = params.numAnimationStages or self.texture.numAnimationStages
        else
            self.numAnimationStages = params.numAnimationStages or 0
        end
        
        self.animStage = params.animStage or 0
        self.pauseAnimation = params.pauseAnimation or false
        self.numFramesPerAnimationStage = params.numFramesPerAnimationStage or 100
        self.localFrameCounter = params.localFrameCounter or 0

        self.allowRender = params.allowRender or true
        self.isOnCamera = false   ---For cameraObj

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
            self.allowRender,
            self,
            self.priority,
            self.isOnCamera
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
        self.renderObj.allowRender = self.allowRender
        if self.pauseAnimation == false then
            self.renderObj.animStage = self.animStage
        
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
        else
            self.renderObj.animStage = self.animStage
        end

    end

    function BaseObj:changeDimensions(width, height)
        self.renderObj.width = width
        self.renderObj.height = height
    end

    function BaseObj:updateIsOnCamera(state)
        self.isOnCamera = state
        self.renderObj.isOnCamera = state
    end

    function BaseObj:enableRender()
        self.allowRender = true
        self.renderObj.allowRender = true
    end

    function BaseObj:disableRender()
        self.allowRender = false
        self.renderObj.allowRender = false
    end

    --[[
        Directions are the returning array from checkCollisionDirection
    ]]
    function BaseObj:dealWithCollision(directions)

        if directions.upHit == false then
            self.forceUp = 0
        end
        if directions.downHit == false then
            self.forceDown = 0
        end
        if directions.leftHit == false then
            self.forceLeft = 0
        end
        if directions.rightHit == false then
            self.forceRight = 0
        end

    end 

    --[[
        Directions are the returning array from checkCollisionDirection
    ]]
    function BaseObj:changeSprite(sprite, framesPerAnim)

        self.animStage = 0
        self.texture = sprite
        self.renderObj.width = self.texture.width
        self.renderObj.height = self.texture.height
        self.numAnimationStages = sprite.numAnimationStages
        self.numFramesPerAnimationStage = framesPerAnim or self.numFramesPerAnimationStage

    end 

    --[[
        Change this renderObj's render priority
    ]]
    function BaseObj:changePriority(priority)

        self.priority = priority
        self.renderObj.priority = self.priority

    end 

    --[[
        To be overriden
    ]]
    function BaseObj:update() end


end ---close