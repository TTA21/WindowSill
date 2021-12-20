do  ---open

    --BaseObj | Class Declaration

    --[[
        :defineBase({
            texture = ,
            posX = ,
            posY = ,
            scale = ,
            prority = ,
            alpha = ,
            animStage = ,
            numAnimationStages = ,
            name = ,
            hasCollision = ,
            pauseAnimation = ,
            numFramesPerAnimationStage = ,
            localFrameCounter = ,
            allowRender = ,
            hitBoxObj = {
                posX =  ,
                posY =  ,
                width =  ,
                height =  ,
                anchor =  ,
            },
            onBaseObjUpdate = (
                function (this) 

                end
            ),
            onBaseObjCollisionDetection = (
                function (this, directions) 

                end
            ),
            onBaseObjConstructorStart = (
                function (this) 
                
                end
            ),
            onBaseObjConstructorEnd = (
                function (this) 

                end
            ),
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
            onBaseObjUpdate = (function (this) end),                                ---Closure, every time the baseObj's update is called, this function is called, recieves self
            onBaseObjCollisionDetection = (function (this, directions) end),        ---Closure, if the object has collision on, during every update it will be tested,
                                                                                    ---if no closure provided, standard test will be performed with the collision data
            onBaseObjConstructorStart = (function (this) end),  ---Closure, called at the beggining of the 'defineBase' function
            onBaseObjConstructorEnd = (function (this) end),    ---Closure, called at the end of the 'defineBase' function

        })

        --priority_0 --Letters of Dialogs and menus
        --priority_1 --Dialogs and menus
        --priority_2 --ForeGround
        --priority_3 --Middle Ground
        --priority_4 --BackGround
    ]]--

    BaseObj = object:clone()

    ---Function Declaration

    function BaseObj:defineBase(params)

        self.globalId = newGlobalId()

        ---Optional construtor closure
        if params.onBaseObjConstructorStart then
            params.onBaseObjConstructorStart(self)
        end

        self.allowRender = params.allowRender or globalDefaultParams.allowRender
        self.animStage = params.animStage or 0
        self.alpha = params.alpha or globalDefaultParams.alpha
        self.hasCollision = params.hasCollision or globalDefaultParams.hasCollision
        self.isOnCamera = false
        self.localFrameCounter = params.localFrameCounter or 0
        self.name = params.name or globalDefaultParams.baseObjName
        self.numFramesPerAnimationStage = params.numFramesPerAnimationStage
            or globalDefaultParams.numFramesPerAnimationStage
        self.pauseAnimation = params.pauseAnimation or false
        self.posX = params.posX or 1
        self.posY = params.posY or 1
        self.priority = params.priority or 4  
        self.scale = params.scale or globalDefaultParams.scale
        self.texture = params.texture or textures.std_menu_background_white_10_10
        
        ---If hitbox not declared in params, the hitbox will be generated as the whole sprite
        if params.hitBoxObj then
            self.hitBox = params.hitBoxObj
        else
            hitBox = HitBoxObj:clone()
            hitBox:defineHitBox({
                width = self.texture.width,
                height = self.texture.height,
                anchor = self ,
            })
            self.hitBox = hitBox
        end
    
        ---If no number of animation stages not decalred in params, the obj will assume the parameter in global textures array
        if self.texture then
            self.numAnimationStages = params.numAnimationStages or self.texture.numAnimationStages
        else
            self.numAnimationStages = params.numAnimationStages or 0
        end
        
        ---If no closure is provided in params, the obj will assume no function should be called
        if params.onBaseObjUpdate then
            self.onUpdate = params.onBaseObjUpdate
        else
            self.onUpdate = function (this) end
        end

        ---If no closure provided in params, the side that has collided will have its force nullified
        if params.onBaseObjCollisionDetection then
            self.onCollisionDetection = params.onBaseObjCollisionDetection
        else
            self.onCollisionDetection = (
                function (this, directions)   ---default closure
                    if directions.upHit == false then
                        this.forceUp = 0
                    end
                    if directions.downHit == false then
                        this.forceDown = 0
                    end
                    if directions.leftHit == false then
                        this.forceLeft = 0
                    end
                    if directions.rightHit == false then
                        this.forceRight = 0
                    end
                end
            )
        end

        ---Render obj declaration
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

        ---Optional construtor closure
        if params.onBaseObjConstructorEnd then
            params.onBaseObjConstructorEnd(self)
        end

    end

    --[[
        *****Expected to be called every frame.******

        If an object, like a character moves or animates, it will have to be re-rendered with new data,
        call this function when you want to render this new state.
        
        Also automatically does the animation transitions for convenience
    ]]--
    function BaseObj:updateRenderObjCommon(x,y)

        ---Update intrinsics
        self.renderObj:changeSprite(self.texture)
        self.renderObj.posX = x or self.posX
        self.renderObj.posY = y or self.posY
        self.renderObj.scale = self.scale
        self.renderObj.alpha = self.alpha
        self.renderObj.allowRender = self.allowRender

        ---Animation handling
        self.renderObj.animStage = self.animStage
        if self.pauseAnimation == false then
            if self.localFrameCounter < self.numFramesPerAnimationStage then
                self.localFrameCounter = self.localFrameCounter + 1
            else
                self.localFrameCounter = 0
                if self.animStage < self.numAnimationStages then
                    self.animStage = self.animStage + 1
                else
                    self.animStage = 0
                end ---self.animStage < self.numAnimationStages
            end ---self.localFrameCounter < self.numFramesPerAnimationStage
        end ---self.pauseAnimation == false

    end

    --[[
        Changes the sprite and hitbox dimensions
    ]]
    function BaseObj:changeDimensions(width, height)
        self.renderObj.width = (width or self.renderObj.width) * self.scale
        self.renderObj.height = (height or self.renderObj.height) * self.scale
        self.hitBox.hitBoxWidth = (width or self.renderObj.width) * self.scale
        self.hitBox.hitBoxHeight = (height or self.renderObj.height) * self.scale
    end

    --[[
        Used internalyy by the CameraObj
    ]]
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
        Directions are the returning array from checkCollisionDirection, false if collided
    ]]
    function BaseObj:dealWithCollision(directions)
        self.onCollisionDetection(self, directions)
    end 

    --[[
        Directions are the returning array from checkCollisionDirection
    ]]
    function BaseObj:changeSprite(sprite, framesPerAnim)

        self.animStage = 0
        self.texture = sprite or self.texture
        self.renderObj.width = self.texture.width
        self.renderObj.height = self.texture.height
        self.numAnimationStages = sprite.numAnimationStages or self.texture.numAnimationStages
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
        For debugging purposes
    ]]
    function BaseObj:debug_printBaseObj(closure, funcName)
        indent = "\t"
        if not funcName then
            funcName = "debug_printBaseObj"
        end
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        print(indent .. funcName .. " called at frame " .. globalFrameCounter)
        print(indent .."name = " .. self.name .. " : globalId = " .. self.globalId)
        print(indent .."renderObj objId = " .. self.renderObj.objId)
        print(indent .."texture id = " .. self.texture.identifier .. " : path = " .. self.texture.spritePath)
        print(indent .."position : " .. self.posX .. "  " .. self.posY .. " | scale = " .. self.scale)
        print(indent .."priority = " .. self.priority .. " | hasCollision = " .. tostring(self.hasCollision))
        print(indent .."allowRender = " .. tostring(self.allowRender) .. " | numFramesPerAnimStage = " .. self.numFramesPerAnimationStage )
        if closure then
            closure(indent)
        end
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
    end

    --[[
        To be overriden, in principle this should never be called, but hey, just in case
    ]]
    function BaseObj:update() 
        print("BaseObj update called!")
        self.onUpdate(self)
    end


end ---close