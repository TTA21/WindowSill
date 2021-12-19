do  ---open

    --BaseObj | Class Declaration

    --[[
        :defineBase({
            texture = ,
            posX = ,
            posY = ,
            scale = ,
            prority = ,
            hitBoxObj = ,
            alpha = ,
            animStage = ,
            numAnimationStages = ,
            name = ,
            hasCollision = ,
            pauseAnimation = ,
            numFramesPerAnimationStage = ,
            localFrameCounter = ,
            allowRender = ,
        })
    ]]

    --[[
        Every object that can be rendered is expected to be derived from this class.

        Has a simple hitbox for collisions, does simple 1 sprite animations.

        obj:defineBase({
            texture = ,                         ---The sprite to be displayed, should be declared in 'textures.lua'
            posX = ,                            ---Cartesian X axis position on the map
            posY = ,                            ---Cartesian Y axis position on the map
            scale = ,                           ---Width and Height multiplied by this number
            prority = ,                         ---Rendering priority, see below
            hitBoxObj = ,                       ---The hitbox used for collisions and scripts
            alpha = ,                           ---The transparency, 100 for none
            animStage = ,                       ---If a sprite is animated, it has n stages, begins at 0
            numAnimationStages = ,              ---The number of sprites for the animation
            name = ,                            ---Name for debugging purposes, Bob for automatically generated ones
            hasCollision = ,                    ---True if the object has collision, does not affect scripts
            pauseAnimation = ,                  ---True if you want the animation to be paused, will not pause the movement
            numFramesPerAnimationStage = ,      ---Every n frames, change animation frame
            localFrameCounter = ,               ---Used for the parameter above, leave it alone if ou dont know what it does
            allowRender = ,                     ---True if you want it to render,equivalento to having an alfa of 0, does not affect scripts
            onUpdate = (function (this) end),   ---Closure, every time the baseObj's update is called, this function is called

        })

        --priority_0 --Letters of Dialogs and menus
        --priority_1 --Dialogs and menus
        --priority_2 --ForeGround
        --priority_3 --Middle Ground
        --priority_4 --BackGround
    ]]--

    BaseObj = object:clone()

    ---Function Declaration

    function BaseObj:defineBase(
        params  ---The parameters object
    )
        self.texture = params.texture or textures.std_menu_background_white_10_10
        self.posX = params.posX or 1
        self.posY = params.posY or 1
        self.scale = params.scale or globalDefaultParams.scale
        
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

        
        self.alpha = params.alpha or globalDefaultParams.alpha
    
        self.globalId = newGlobalId()
    
        self.name = params.name or globalDefaultParams.baseObjName
        self.hasCollision = params.hasCollision or globalDefaultParams.hasCollision
    
        if self.texture then
            self.numAnimationStages = params.numAnimationStages or self.texture.numAnimationStages
        else
            self.numAnimationStages = params.numAnimationStages or 0
        end
        
        self.animStage = params.animStage or 0
        self.pauseAnimation = params.pauseAnimation or false
        self.numFramesPerAnimationStage = params.numFramesPerAnimationStage or globalDefaultParams.numFramesPerAnimationStage
        self.localFrameCounter = params.localFrameCounter or 0

        self.allowRender = params.allowRender or globalDefaultParams.allowRender
        self.isOnCamera = false   ---For cameraObj

        if params.onUpdate then
            self.onUpdate = params.onUpdate
        else
            self.onUpdate = function (this) end
        end

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
        self.renderObj.width = width or self.renderObj.width
        self.renderObj.height = height or self.renderObj.height
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
        self.texture = sprite or self.texture
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
        To be overriden, in principle this should never be called, but hey, just in case
    ]]
    function BaseObj:update() 
        self.onUpdate(self)
    end


end ---close