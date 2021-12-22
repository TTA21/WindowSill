
    --[[
        Used for scenario objects.
        Must be a BaseObj or its derivatives.
    ]]--
    function MapObj:addToForeGround(obj)

        ---Must be Base Obj
        if obj.isa(BaseObj) then

            --Must be within bounds of map
            if  obj.posX >= 0 and obj.posX <= self.width and
                obj.posY >= 0 and obj.posY <= self.height then

                    obj:changePriority(globalDefaultParams.priorities.foreGround)
                    self.foreGround[#self.foreGround + 1] = obj
            else
                print("Obj not added, " .. obj.name .. " out of bounds!")
                return false
            end
        else
            print("Obj not added, " .. obj.name .." not a BaseObj or derivative!")
            return false
        end
        
    end

    --[[
        Remove an item from the foreground.
        Returns false if no item was found.
        :removeFromForeGround({
            globalId = ,    ---only one will suffice
            object = ,
        })
    ]]
    function MapObj:removeFromForeGround(params)

        if params.globalId then
            foundObj = false
            for index, object in pairs(self.foreGround) do
                if object.globalId == params.globalId then
                    self.foreGround[index] = nil
                    foundObj = true
                end
            end
            return foundObj

        elseif params.object then
            foundObj = false
            for index, object in pairs(self.foreGround) do
                if object.globalId == params.object.globalId then
                    self.foreGround[index] = nil
                    foundObj = true
                end
            end
            return foundObj

        else

            return false
        end

        
    end

