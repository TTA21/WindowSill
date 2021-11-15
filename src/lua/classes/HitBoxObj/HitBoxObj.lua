
do --open

    ---Note Movable obj will have access to keyboard and mouse, and will have attached hitbox
    ---will also have collision

    --[[
            HitBoxObj holds the more 'sophisticated' hitbox data, hitboxes serve to make the characters less flat
            by making the bottom part, or the 'shadow' of the sprite the actual hitbox.
            The posX, posY, hitBoxWidth, hitBoxHeight are the 'shadow'. posX and posY are relative
            to the sprite, not the map.

            sss
            sss     s = sprite
            sss     S = shadow, S is the hitbox, s can clip through things, S cannot
            SSS
    ]]--

    HitBoxObj = object:clone()

    ---Data Declaration

    HitBoxObj.posX = 0
    HitBoxObj.posY = 0
    HitBoxObj.hitBoxWidth =  0
    HitBoxObj.hitBoxHeight = 0
    HitBoxObj.anchor = {}
    HitBoxObj.scale = 1

    ---Function Declaration

    function HitBoxObj:defineHitBox(
        posX,           ---Relative to Sprite
        posY,           ---Relative to Sprite
        hitBoxWidth,    ---Relative to Sprite
        hitBoxHeight,   ---Relative to Sprite
        anchor,          ---BaseObj or MovableObj, used to get posX and posY of this anchor
        scale           ---Relative to Sprite
    )

        self.posX = posX or 0
        self.posY = posY or 0
        self.hitBoxWidth = hitBoxWidth or 0
        self.hitBoxHeight = hitBoxHeight or 0
        self.anchor = anchor or {}
        self.scale = scale or 1

    end

    --[[
        Returns the equivalent rectangle in relation to the actual map.
        It is as if a new BaseObj was created with collision on wherever you placed the hitbox

        Recieves BaseObj's posX and posY
    ]]
    function HitBoxObj:getNormalized()
        return {
            posX = self.anchor.posX + self.posX,
            posY = self.anchor.posY + self.posY,
            scale = self.anchor.scale,
            hitBoxWidth = self.hitBoxWidth,
            hitBoxHeight = self.hitBoxHeight
        }
    end

    --[[
        Checks for collision agains testObj
    ]]--
    function HitBoxObj:checkForCollision(testBox)

        normalizedBox1 = self:getNormalized()
        normalizedBox2 = testBox:getNormalized()

        return checkCollision(normalizedBox1, normalizedBox2)
    end

    --[[
        Checks for collision agains testObj and returns wich sides are hitting in an array
    ]]--
    function HitBoxObj:checkForDirectionalCollision(testBox)

        normalizedBox1 = self:getNormalized()
        normalizedBox2 = testBox:getNormalized()

        return checkCollisionDirection(normalizedBox1, normalizedBox2)
    end

end --close