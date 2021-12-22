--[[
        The developer should know the name of the object, for direct referencing
        EX:
            map:addNamedItemToBackGround("example", obj)
            map.backGround["example"].name
    ]]--
    function MapObj:addNamedItemToBackGround(name, obj)
        if  obj.posX > 0 and obj.posX < self.width and
            obj.posY > 0 and obj.posY < self.height then

                obj:changePriority(4)
                self.backGround[name] = obj
        else
            print("Obj not added,  ", obj.name, " out of bounds!")
        end
        
    end

    --[[
        Used for scenario objects
    ]]--
    function MapObj:addToBackGround(obj)
        if  obj.posX > 0 and obj.posX < self.width and
            obj.posY > 0 and obj.posY < self.height then

                obj:changePriority(4)
                self.backGround[#self.backGround + 1] = obj
        else
            print("Obj not added,  ", obj.name, " out of bounds!")
        end
        
    end

    function MapObj:removeNamedFromBackGround(name)
        self.backGround[name] = nil
    end

    function MapObj:removeFromBackGround(globalId)
        for index, object in pairs(self.backGround) do
            if object.globalId == globalId then
                object = nil
            end
        end
    end
