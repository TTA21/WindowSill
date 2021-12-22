    --[[
        The developer should know the name of the object, for direct referencing
        EX:
            map:addNamedItemToMiddleGround("example", obj)
            map.middleGround["example"].name
    ]]--
    function MapObj:addNamedItemToMiddleGround(name, obj)
        if  obj.posX > 0 and obj.posX < self.width and
            obj.posY > 0 and obj.posY < self.height then

                obj:changePriority(3)
                self.middleGround[name] = obj
        else
            print("Obj not added,  ", obj.name, " out of bounds!")
        end
        
    end

    --[[
        Used for scenario objects
    ]]--
    function MapObj:addToMiddleGround(obj)
        if  obj.posX > 0 and obj.posX < self.width and
            obj.posY > 0 and obj.posY < self.height then

                obj:changePriority(3)
                self.middleGround[#self.middleGround + 1] = obj
        else
            print("Obj not added,  ", obj.name, " out of bounds!")
        end
        
    end

    function MapObj:removeNamedFromMiddleGround(name)
        self.middleGround[name] = nil
    end

    function MapObj:removeFromMiddleGround(globalId)
        for index, object in pairs(self.middleGround) do
            if object.globalId == globalId then
                object = nil
            end
        end
    end
