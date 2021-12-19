do --open

    --[[
        When attached to something, they share the same force, they might desync
        if the attached obj hits something, but thats the idea

        offsetX and offsetY are just initial positions

        Useful for very simple npcs
    ]]

    MovableObjAttachedObj = MovableObj:clone()

    ---Data declaration

    ---Function Declarations

    --anchor, offsetX, offsetY
    --[[
        defineMovable({
            baseObj params,
            movableObj params,
            anchor,
            offsetX,
            offsetY
        })
    ]]

    function MovableObjAttachedObj:defineMovableObjAttached(params)

        self:defineMovable(params)
        
        self.noBaseAttached = false
        if not params.anchor then
            print("ALERT, MovableObjAttachedObj's anchor is nil")
            self.noBaseAttached = true
            return
        end

        if params.anchor:isa(MovableObj) then
            self.anchor = params.anchor
        else
            print("ALERT, MovableObjAttachedObj's anchor does not contain MovableObj")
            self.noBaseAttached = true
            return
        end

        self.offsetX = params.offsetX or 0
        self.offsetY = params.offsetY or 0

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