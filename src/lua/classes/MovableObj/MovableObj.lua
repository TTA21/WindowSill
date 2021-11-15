do  --open

    MovableObj = BaseObj:clone()

    ---Data Declaration

    MovableObj.hitBox = {}
        
    MovableObj.allowMovementByKeyboard = false
    MovableObj.movementMultiplier = 1

    MovableObj.forceLeft = 0
    MovableObj.forceRight = 0
    MovableObj.forceUp = 0
    MovableObj.forceDown = 0

    MovableObj.gotoX = 0                        ---Goto this position
    MovableObj.gotoY = 0
    MovableObj.currentlyMovingByScript = false

    MovableObj.forceCap = 10  ---Number of pixels the object will move after letting go

    ---Function Declaration

    function MovableObj:defineMovable(
        allowMovementByKeyboard,     ---WASD
        movementMultiplier,          ---1 = normal speed, 2 = double speed
        hasCollision,
        hitBox             ---Contains offset for proper hitboxing
    )
        self.hasCollision = hasCollision or false

        if hitBoxObj then
            self.hitBox = hitBoxObj
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
            
        self.allowMovementByKeyboard = allowMovementByKeyboard or false
        self.allowMovementByMouse = allowMovementByMouse or false
        self.movementMultiplier = movementMultiplier or 1

        self.forceLeft = 0
        self.forceRight = 0
        self.forceUp = 0
        self.forceDown = 0

        self.gotoX = self.posX  ---Goto this position
        self.gotoY = self.posY
        self.currentlyMovingByScript = false

        self.forceCap = 10  ---Number of pixels the object will move after letting go
        
    end

    --[[
        Extremely Basic movement, it is expected of the game dev to create a hero class to
        implement more complex design for their game
    ]]--
    function MovableObj:keyboardMove()
        if self.allowMovementByKeyboard == true and self.currentlyMovingByScript == false then
            for I, V in pairs(keysPressed) do
                if V == "Up" or V == "W" then
                    if self.forceUp < self.forceCap then
                        self.forceUp = self.forceUp + self.movementMultiplier
                    end
                end
        
                if V == "Down" or V == "S" then
                    if self.forceDown < self.forceCap then
                        self.forceDown = self.forceDown + self.movementMultiplier
                    end
                end
                
                if V == "Left" or V == "A" then
                    if self.forceLeft < self.forceCap then
                        self.forceLeft = self.forceLeft + self.movementMultiplier
                    end
                end
        
                if V == "Right" or V == "D" then
                    if self.forceRight < self.forceCap then
                        self.forceRight = self.forceRight + self.movementMultiplier
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
    end

    --[[
        Force must run out eventually, call it after force has been exerted
    ]]--
    function MovableObj:exertResistance()


        if math.floor(self.forceUp) > 0 then
            self.forceUp = self.forceUp - 0.4
        end

        if math.floor(self.forceDown) > 0 then
            self.forceDown = self.forceDown - 0.4
        end

        if math.floor(self.forceLeft) > 0 then
            self.forceLeft = self.forceLeft - 0.4
        end

        if math.floor(self.forceRight) > 0 then
            self.forceRight = self.forceRight - 0.4
        end
    end

    --[[
        Directions are the returning array from checkCollisionDirection
    ]]
    function MovableObj:dealWithCollision(directions)

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
                if self.forceLeft < self.forceCap then
                    self.forceLeft = self.forceLeft + self.movementMultiplier
                end
            end

            if currentPos.posX < (desiredPos.posX) then
                if self.forceRight < self.forceCap then
                    self.forceRight = self.forceRight + self.movementMultiplier
                end
            end

            if currentPos.posY > (desiredPos.posY) then
                if self.forceUp < self.forceCap then
                    self.forceUp = self.forceUp + self.movementMultiplier
                end
            end

            if currentPos.posY < (desiredPos.posY) then
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