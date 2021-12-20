do --open

    --BaseObjAttached | Class Declaration

    --[[
        :defineBaseObjAttached({
            --BaseObj params,
            anchor =  ,
            offsetX =  ,
            offsetY =  ,
        })
    ]]

    --[[
        This object is meant to keep a constant distance from an 'anchor' object, wich can be
        another BaseObj object or derivative.
        Very useful for keeping things on screen like menus and dialogs, simply attach this object
        to whatever the camera is attached to and it will stay on the screen.
        Note that this object never deals with force, simply osition, as such collisions are irrelevant.

        :defineBaseObjAttached({
            --BaseObj params,   ---See file 'lua/classes/BaseObj/BaseObj.lua'
            anchor =  ,         ---BaseObj or its derivatives, object must have posX or posY
            offsetX =  ,        ---Cartesian X axis offset from the anchor, uses top left corner as 0
            offsetY =  ,        ---Cartesian Y axis offset from the anchor, uses top left corner as 0
        })
    ]]

    BaseObjAttachedObj = BaseObj:clone()

    ---Function Declarations

    function BaseObjAttachedObj:defineBaseObjAttached(params)
        
        ---BaseObj instanciation
        self:defineBase(params)

        ---Test if anchor was declared, if not alert the terminal and set noBaseAttached to true
        self.noBaseAttached = false
        if not params.anchor then
            print("ALERT, BaseObjAttached's anchor is nil", self.name)
            self.noBaseAttached = true
            return
        end

        ---Test if the anchor is a BaseObj or derivative, if not alert the terminal and set noBaseAttached to true
        if params.anchor:isa(BaseObj) then
            self.anchor = params.anchor
        else
            print("ALERT, BaseObjAttached's anchor does not contain BaseObj")
            self.noBaseAttached = true
            return
        end

        ---If the anchor has problems the offsets will remain undefined
        self.offsetX = params.offsetX or 0
        self.offsetY = params.offsetY or 0

    end

    --[[
        Moves the object along with the object its anchored to
    ]]
    function BaseObjAttachedObj:updatePos()
        self.posX = (self.anchor.posX + self.offsetX)
        self.posY = (self.anchor.posY + self.offsetY)
    end

end --close