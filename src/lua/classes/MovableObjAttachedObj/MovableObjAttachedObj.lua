do --open

    --[[
        When attached to something, they share the same force, they might desync
        if the attached obj hits something, but thats the idea

        offsetX and offsetY are just initial positions

        Useful for very simple npcs
    ]]

    MovableObjAttachedObj = MovableObj:clone()

    ---Data declaration

    MovableObjAttachedObj.anchor = {}

    ---Function Declarations

    function MovableObjAttachedObj:defineBaseObjAttached(anchor, offsetX, offsetY)
        
        self.noBaseAttached = false
        if not anchor then
            print("ALERT, MovableObjAttachedObj's anchor is nil")
            self.noBaseAttached = true
            return
        end

        if anchor:isa(MovableObj) then
            self.anchor = anchor
        else
            print("ALERT, MovableObjAttachedObj's anchor does not contain MovableObj")
            self.noBaseAttached = true
            return
        end

        self.offsetX = offsetX or 0
        self.offsetY = offsetY or 0

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