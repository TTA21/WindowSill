do

    

    --[[
        MovableObj uses the more 'sophisticated' Hitbox to do collisions, it also accepts
        keyboard movement, it is meant as a base class for NPC's and the player character

        Also if no hitbox is given, the hitbox will be the lower third of the sprite
    ]]--
    
    MovableObj = {}
    MovableObj.__index = MovableObj

    function MovableObj:new(
        name,               ---Self explanatory
        texture,            ---Texture object
        scale,              ---Width & Height of the sprite times scale. 1 for normal
        --renderObjId,        ---RederObj.ObjId
        --renderItemIndex,    ---renderItems[RenderItemIndex]
        posX,               ---Based on the map, not the screen
        posY,               ---Based on the map, not the screen
        hitBoxObj,          ---Contains offset for proper hitboxing
        allowMovementByKeyboard,     ---WASD
        allowMovementByMouse,        ---Point and click to move in a direction
        movementMultiplier          ---1 = normal speed, 2 = double speed
    )

        --local self = setmetatable(BaseObj:new(name, texture, scale, posX, posY, 0, 0), MovableObj)
        local self = setmetatable({}, {__index = BaseObj:new(name, texture, scale, posX, posY, 0, 0)})
        self.__index = self

        self.hitBoxWidth = nil  ---wont need the basic suff
        self.hitBoxHeight = nil ---wont need the basic suff

        self.hitBox = hitBoxObj or 
            HitBoxObj:new(
                0, (texture.height - texture.height/3)*self.scale, texture.width*self.scale, (texture.height/3)*scale, self
            )
            

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
        self.isMovableObj = true

        return self

    end

    --[[
        Extremely Basic movement, it is expected of the game dev to create a hero class to
        implement more complex design for their game
    ]]--
    function BaseObj:keyboardMove()
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
    function BaseObj:exertForce()

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
    function BaseObj:exertResistance()


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
        Called by the dev, the object tries to go to the position on the map +- 1 pixel
    ]]
    function BaseObj:setGotoPos(posX, posY)
        self.gotoX = posX
        self.gotoY = posY
        self.currentlyMovingByScript = true
    end

    --[[
        Meant to be called by the map loop, moves in the direction of the desired coordinates
        set by 'setGotoPos' +- 1 pixel
    ]]
    function BaseObj:moveToPos()
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


end