do  --open

    MovableObj = BaseObj:clone()

    ---Function Declaration
    --[[
        :defineMovable({
            baseObj params,
            allowMovementByKeyboard = ,
            movementMultiplier = ,
            diretionalTextures = {
                up_still = textures. ,
                down_still = textures. ,
                left_still = textures. ,
                right_still = textures. ,
                up = textures. ,
                down = textures. ,
                left = textures. ,
                right = textures. 
            },
        })
    ]]

    --[[
        Movable Objects are a derivative of BaseObj, it is very similar to the standard BaseObj but
        it allows itself to move, applying force in the directions demanded by the desired position.

        It contains a rudimentary collision algorithm, if it detects a collision the force in the 
        direction of the collision is nullified.

        It also contains a better animation handler, enabling direction animations to be implemented
        for characters and such.

        :defineMovable({
            baseObj params,             ---See file 'lua/classes/BaseObj/BaseObj.lua'
            allowMovementByKeyboard,    ---WASD, temporary
            movementMultiplier,         ---1 = normal speed, 2 = double speed
            diretionalTextures,         ---One sprite animation for left, right, up and down; when moving and when still
        })
    ]]

    function MovableObj:defineMovable(
        params
    )
        self:defineBase(params)

        self.allowMovementByKeyboard = params.allowMovementByKeyboard or false  ---TO BE REMOVED
        
        self.forceLeft = 0
        self.forceRight = 0
        self.forceUp = 0
        self.forceDown = 0

        self.gotoX = self.posX  ---Goto this position
        self.gotoY = self.posY  ---Goto this position
        self.currentlyMovingByScript = false    ---See function 'setGotoPos()'

        self.lastMoveDirection = 1  --0 up, 1 down, 2 left, 3 right

        self.forceCap = globalDefaultParams.forceCap  ---Number of pixels the object will move after letting go

        ---If no directionalTexture provided, the BaseObj's texture will be used on all cases.
        if params.diretionalTextures then
            self.diretionalTextures = params.diretionalTextures
            self.diretionalTextures = {
                up_still = params.diretionalTextures.up_still or self.texture,
                down_still = params.diretionalTextures.down_still or self.texture,
                left_still = params.diretionalTextures.left_still or self.texture,
                right_still = params.diretionalTextures.right_still or self.texture,
                up = params.diretionalTextures.up or self.texture,
                down = params.diretionalTextures.down or self.texture,
                left = params.diretionalTextures.left or self.texture,
                right = params.diretionalTextures.right or self.texture
            }
        else
            self.diretionalTextures = {
                up_still = self.texture,
                down_still = self.texture,
                left_still = self.texture,
                right_still = self.texture,
                up = self.texture,
                down = self.texture,
                left = self.texture,
                right = self.texture
            }
        end

        ---If no hitBox provided, create one with a third the height and at the bottom of the sprite.
        if params.hitBoxObj then
            self.hitBox = params.hitBoxObj
        else
            hitBox = HitBoxObj:clone()
            hitBox:defineHitBox({
                posY = (self.texture.height - self.texture.height/3)*self.scale ,
                width = self.texture.width ,
                height = (self.texture.height/3) ,
                anchor = self ,
            })
            self.hitBox = hitBox
        end

        ---The limit of the movement multiplier is 0 <= x <= 5
        self.movementMultiplier = params.movementMultiplier or globalDefaultParams.movementMultiplier
        if self.movementMultiplier < 0 then
            self.movementMultiplier = 0
        elseif self.movementMultiplier > 5 then
            self.movementMultiplier = 5
        end
            
    end

    --[[
        *********WILL BE REMOVED LATER**************
        Extremely Basic movement, it is expected of the game dev to create a hero class to
        implement more complex design for their game
    ]]--
    function MovableObj:keyboardMove()
        if self.allowMovementByKeyboard == true and self.currentlyMovingByScript == false then
            for I, V in pairs(keysPressed) do
                if V == "Left" or V == "A" then
                    self.lastMoveDirection = 2
                    if self.forceLeft < self.forceCap then
                        self.forceLeft = self.forceLeft + self.movementMultiplier
                    end
                end
        
                if V == "Right" or V == "D" then
                    self.lastMoveDirection = 3
                    if self.forceRight < self.forceCap then
                        self.forceRight = self.forceRight + self.movementMultiplier
                    end
                end

                if V == "Up" or V == "W" then
                    self.lastMoveDirection = 0
                    if self.forceUp < self.forceCap then
                        self.forceUp = self.forceUp + self.movementMultiplier
                    end
                end
        
                if V == "Down" or V == "S" then
                    self.lastMoveDirection = 1
                    if self.forceDown < self.forceCap then
                        self.forceDown = self.forceDown + self.movementMultiplier
                    end
                end
                
            end
        end
    end

    --[[
        **********************MEANT TO BE CALLED EVERY FRAME**********************
        Takes force values and translates them to movement
    ]]--
    function MovableObj:exertForce()

        --[[
            The movement occurs by determining if in this frame the position will change,
            if the force is above 0 the movement can occur.
            If the movement multiplier is high, the chance that move will happen will be higher.
        ]]
        if math.floor(self.forceUp) > 0 then
            if (globalFrameCounter % math.abs(math.floor(5-self.movementMultiplier)) ) == 0 then
                self.posY = self.posY - 1
            end
        end

        if math.floor(self.forceDown) > 0 then
            if (globalFrameCounter % math.abs(math.floor(5-self.movementMultiplier)) ) == 0 then
                self.posY = self.posY + 1
            end
        end

        if math.floor(self.forceLeft) > 0 then
            if (globalFrameCounter % math.abs(math.floor(5-self.movementMultiplier)) ) == 0 then
                self.posX = self.posX - 1
            end
        end

        if math.floor(self.forceRight) > 0 then
            if (globalFrameCounter % math.abs(math.floor(5-self.movementMultiplier)) ) == 0 then
                self.posX = self.posX + 1
            end
        end

    end

    --[[
        **********************MEANT TO BE CALLED EVERY FRAME**********************
        Force must run out eventually, call it after force has been exerted
    ]]--
    function MovableObj:exertResistance()


        if math.floor(self.forceUp) > 0 then
            self.forceUp = self.forceUp - globalDefaultParams.forceResistance
        end

        if math.floor(self.forceDown) > 0 then
            self.forceDown = self.forceDown - globalDefaultParams.forceResistance
        end

        if math.floor(self.forceLeft) > 0 then
            self.forceLeft = self.forceLeft - globalDefaultParams.forceResistance
        end

        if math.floor(self.forceRight) > 0 then
            self.forceRight = self.forceRight - globalDefaultParams.forceResistance
        end
    end

    --[[
        **********************MEANT TO BE CALLED EVERY FRAME**********************
        Changes sprite based on the force the object is exerting
    ]]
    function MovableObj:updateSprite()
        if  (self.forceUp > globalDefaultParams.forceResistance) or 
            (self.forceDown > globalDefaultParams.forceResistance) or  
            (self.forceLeft > globalDefaultParams.forceResistance) or 
            (self.forceRight > globalDefaultParams.forceResistance)
            then
                
                --- 0.5 here is a token value, this conditional serves to not let the 
                --- sprite spazz out when horizontal and vertical forces are being applied at the same
                --- time.
                --- The conditional favors vertical animations
                if not (self.forceLeft > 0.5 or self.forceRight > 0.5) then
                    ---Moving Up
                    if self.lastMoveDirection == 0 then
                        if self.texture.identifier ~= self.diretionalTextures.up.identifier then
                            self:changeSprite(self.diretionalTextures.up, 100)
                        end
                    end
                    ---Moving Down
                    if self.lastMoveDirection == 1 then
                        if self.texture.identifier ~= self.diretionalTextures.down.identifier then
                            self:changeSprite(self.diretionalTextures.down, 100)
                        end
                    end
                end
                ---Moving Left
                if self.lastMoveDirection == 2 then
                    if self.texture.identifier ~= self.diretionalTextures.left.identifier then
                        self:changeSprite(self.diretionalTextures.left, 100)
                    end
                end
                ---Moving Right
                if self.lastMoveDirection == 3 then
                    if self.texture.identifier ~= self.diretionalTextures.right.identifier then
                        self:changeSprite(self.diretionalTextures.right, 100)
                    end
                end
            else
                ---Standing Up
                if self.lastMoveDirection == 0 then
                    if self.texture.identifier ~= self.diretionalTextures.up_still.identifier then
                        self:changeSprite(self.diretionalTextures.up_still, 1000)
                    end
                end
                ---Standing Down
                if self.lastMoveDirection == 1 then
                    if self.texture.identifier ~= self.diretionalTextures.down_still.identifier then
                        self:changeSprite(self.diretionalTextures.down_still, 1000)
                    end
                end
                ---Standing Left
                if self.lastMoveDirection == 2 then
                    if self.texture.identifier ~= self.diretionalTextures.left_still.identifier then
                        self:changeSprite(self.diretionalTextures.left_still, 1000)
                    end
                end
                ---Standing Right
                if self.lastMoveDirection == 3 then
                    if self.texture.identifier ~= self.diretionalTextures.right_still.identifier then
                        self:changeSprite(self.diretionalTextures.right_still, 1000)
                    end
                end
        end
    end

    --[[
        Called by the dev, the object tries to go to the position on the map +- 1 pixel.
        Very useful for NPC's and more animated game worlds
    ]]
    function MovableObj:setGotoPos(posX, posY)
        self.gotoX = posX
        self.gotoY = posY
        self.currentlyMovingByScript = true
    end

    --[[
        **********************MEANT TO BE CALLED EVERY FRAME**********************
        Meant to be called by the map loop, moves in the direction of the desired coordinates
        set by 'setGotoPos' +- 1 pixel.
        Mind that if it has collision on, it will not go around obstacles, derivatives of this
        object will implement path finding algorithms, this is a basic movement script.
    ]]
    function MovableObj:moveToPos()
        if self.currentlyMovingByScript then
            currentPos = getCenterOfHitbox(self)
            desiredPos = getCenterOfHitbox({
                posX = self.gotoX,
                posY = self.gotoY,
                hitBox = {
                    hitBoxWidth = self.hitBox.hitBoxWidth,
                    hitBoxHeight = self.hitBox.hitBoxHeight
                }
            })

            if currentPos.posX > (desiredPos.posX) then
                self.lastMoveDirection = 2
                if self.forceLeft < self.forceCap then
                    self.forceLeft = self.forceLeft + self.movementMultiplier
                end
            end

            if currentPos.posX < (desiredPos.posX) then
                self.lastMoveDirection = 3
                if self.forceRight < self.forceCap then
                    self.forceRight = self.forceRight + self.movementMultiplier
                end
            end

            if currentPos.posY > (desiredPos.posY) then
                self.lastMoveDirection = 0
                if self.forceUp < self.forceCap then
                    self.forceUp = self.forceUp + self.movementMultiplier
                end
            end

            if currentPos.posY < (desiredPos.posY) then
                self.lastMoveDirection = 1
                if self.forceDown < self.forceCap then
                    self.forceDown = self.forceDown + self.movementMultiplier
                end
            end

            if  (self.posX == self.gotoX+1 or self.posX == self.gotoX-1) and
                (self.posY == self.gotoY+1 or self.posY == self.gotoY-1)
            then
                self.currentlyMovingByScript = false
            end
        end
    end

end --close