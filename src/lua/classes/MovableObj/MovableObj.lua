do  --open

    MovableObj = BaseObj:clone()

    ---Function Declaration

    --[[
        defineMovable({
            baseObj params,
            allowMovementByKeyboard,     ---WASD
            movementMultiplier,          ---1 = normal speed, 2 = double speed
            hasCollision,
            diretionalTextures,         ---One sprite aniation for left, right, up and down
            hitBox
        })
    ]]

    function MovableObj:defineMovable(
        params
    )
        self:defineBase(params)
        self.hasCollision = params.hasCollision or false

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

        if params.hitBoxObj then
            self.hitBox = params.hitBoxObj
        else
            hitBox = HitBoxObj:clone()
            hitBox:defineHitBox(
                0, 
                (self.texture.height - self.texture.height/3)*self.scale, 
                self.texture.width*self.scale, 
                (self.texture.height/3)*self.scale, 
                self
            )
            self.hitBox = hitBox
        end
            
        self.allowMovementByKeyboard = params.allowMovementByKeyboard or false
        self.allowMovementByMouse = params.allowMovementByMouse or false
        self.movementMultiplier = params.movementMultiplier or 1

        self.forceLeft = 0
        self.forceRight = 0
        self.forceUp = 0
        self.forceDown = 0

        self.gotoX = self.posX  ---Goto this position
        self.gotoY = self.posY
        self.currentlyMovingByScript = false

        self.lastMoveDirection = 1  --0 up, 1 down, 2 left, 3 right

        self.forceCap = 10  ---Number of pixels the object will move after letting go
        
    end

    --[[
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
        Takes force values and translates them to movement
    ]]--
    function MovableObj:exertForce()

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

        --self:updateSprite()
    end

    --[[
        Force must run out eventually, call it after force has been exerted
    ]]--
    function MovableObj:exertResistance()


        if math.floor(self.forceUp) > 0 then
            self.forceUp = self.forceUp - 0.5
        end

        if math.floor(self.forceDown) > 0 then
            self.forceDown = self.forceDown - 0.5
        end

        if math.floor(self.forceLeft) > 0 then
            self.forceLeft = self.forceLeft - 0.5
        end

        if math.floor(self.forceRight) > 0 then
            self.forceRight = self.forceRight - 0.5
        end
    end

    --[[
        Changes sprite based on the force the object is exerting
    ]]
    function MovableObj:updateSprite()
        if  (self.forceUp > 0.5) or 
            (self.forceDown > 0.5) or  
            (self.forceLeft > 0.5) or 
            (self.forceRight > 0.5)
            then
                
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
        Called by the dev, the object tries to go to the position on the map +- 1 pixel
    ]]
    function MovableObj:setGotoPos(posX, posY)
        self.gotoX = posX
        self.gotoY = posY
        self.currentlyMovingByScript = true
    end

    --[[
        Meant to be called by the map loop, moves in the direction of the desired coordinates
        set by 'setGotoPos' +- 1 pixel
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