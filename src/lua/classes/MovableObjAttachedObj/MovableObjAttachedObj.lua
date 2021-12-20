do --open

    --MovableObjAttachedObj | Class Declaration

    --[[
        :defineMovable({
            baseObj params,
            movableObj params,
            anchor = ,
            offsetX = ,
            offsetY = ,
        })
    ]]

    --[[
        When anchored to a MovableObj or its derivative it will mirror its force.
        Note that it will mimic the force, not the movement, If the anchor collides it will
        stop, and so will the MovableObjAttached, regardless if the anchor is trying to move
        agains the collision and the MovableObjAttached is not colliding with anything.

        defineMovable({
            baseObj params,     ---See file 'lua/classes/BaseObj/BaseObj.lua'
            movableObj params,  ---See file 'lua/classes/MovableObj/MovableObj.lua'
            anchor,             ---Must be a movableObj or its derivatives
            offsetX,            ---Initial cartesian X axis offset from the anchor, uses top left corner as 0
            offsetY             ---Initial cartesian Y axis offset from the anchor, uses top left corner as 0
        })
    ]]

    MovableObjAttachedObj = MovableObj:clone()

    function MovableObjAttachedObj:defineMovableObjAttached(params)

        self:defineMovable(params)

        self.offsetX = params.offsetX or 0
        self.offsetY = params.offsetY or 0

        ---Test if anchor was declared, if not alert the terminal and set noBaseAttached to true
        self.noBaseAttached = false
        if not params.anchor then
            print("ALERT, MovableObjAttachedObj's anchor is nil")
            self.noBaseAttached = true
            return
        end

        ---Test if the anchor is a MovableObj or derivative, if not alert the terminal and set noBaseAttached to true
        if params.anchor:isa(MovableObj) then
            self.anchor = params.anchor
        else
            print("ALERT, MovableObjAttachedObj's anchor does not contain MovableObj")
            self.noBaseAttached = true
            return
        end

        self.posX = self.offsetX + self.anchor.posX ---Initial position
        self.posY = self.offsetY + self.anchor.posY ---Initial position

    end

    --[[
        Mirrors the force of the anchor
    ]]
    function MovableObjAttachedObj:updateForce()
        self.forceUp = self.anchor.forceUp
        self.forceDown = self.anchor.forceDown
        self.forceLeft = self.anchor.forceLeft
        self.forceRight = self.anchor.forceRight
    end

end --close