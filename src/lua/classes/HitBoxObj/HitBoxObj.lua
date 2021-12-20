
do --open

    --[[
        :defineHitBox({
            posX =  ,
            posY =  ,
            width =  ,
            height =  ,
            anchor =  ,
        })
    ]]

    --[[
        HitBoxObj holds the more 'sophisticated' hitbox data, hitboxes serve to make the characters less flat
        by making the bottom part, or the 'shadow' of the sprite the actual hitbox.
        The posX, posY, hitBoxWidth, hitBoxHeight are the 'shadow'. posX and posY are relative
        to the sprite, not the map.

        sss
        sss     s = sprite
        sss     S = shadow, S is the hitbox, s can clip through things, S cannot
        SSS

        :defineHitBox({
            posX =  ,   ---Cartesian X axis position relative to the srite, works very much like BaseObjAttached
            posY =  ,   ---Cartesian Y axis position relative to the srite, works very much like BaseObjAttached
            width =  ,    ---The hitbox width, usually the sprite's width
            height =  ,   ---The hitbox height, usually the sprite's height or height/3
            anchor =  ,         ---BaseObj or its derivatives
        })
    ]]--

    HitBoxObj = object:clone()

    ---Function Declaration

    function HitBoxObj:defineHitBox(params)

        self.globalId = newGlobalId()

        if params.anchor then
            self.anchor = params.anchor
            self.scale = params.anchor.scale
        else
            print("ALERT! defineHitBox called with no anchor at frame " .. globalFrameCounter)
            self.anchor = nil
            self.scale = 0
        end

        self.posX = params.posX or 0
        self.posY = params.posY or 0
        self.hitBoxWidth = (params.width or 0) * self.scale
        self.hitBoxHeight = (params.height or 0) * self.scale

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