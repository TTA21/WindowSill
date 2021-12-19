do --open

    --[[
        When attached to something, the difference of position of the object it
        is attached to is added to this objects position
        NOTE: The forçe is aways 0, the postion changes, not the force, wich means that
        collisions DO NOT apply

        Useful for dialog boxes and menus
    ]]

    BaseObjAttachedObj = BaseObj:clone()

    ---Data declaration

    BaseObjAttachedObj.anchor = {}

    ---Function Declarations

    function BaseObjAttachedObj:defineBaseObjAttached(anchor, offsetX, offsetY)
        
        self.noBaseAttached = false
        if not anchor then
            print("ALERT, BaseObjAttached's anchor is nil")
            self.noBaseAttached = true
            return
        end

        if anchor:isa(BaseObj) then
            self.anchor = anchor
        else
            print("ALERT, BaseObjAttached's anchor does not contain BaseObj")
            self.noBaseAttached = true
            return
        end

        self.offsetX = offsetX or 0
        self.offsetY = offsetY or 0

    end

    --[[
        Moves the object along with the object its anchored to
    ]]
    function BaseObjAttachedObj:updatePos()
        self.posX = (self.anchor.posX + self.offsetX)
        self.posY = (self.anchor.posY + self.offsetY)
    end

end --close