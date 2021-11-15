do

    local firstLevelMap = MapObj:new(
        1500, 1500, "First Level"
    )

    function firstStageSetup()

        obj1 = MovableObj:clone()
        obj1:defineBase("Object1", textures.red_square, 1, 123, 123)
        obj1:defineMovable(true,1,true)
        --obj1.hitBox = HitBoxObj:new(
        --    0, 0, obj1.texture.width*obj1.scale, obj1.texture.height*obj1.scale, obj1
        --)


        firstLevelMap:addCameraAnchoredTo("Main Camera", obj1)

        firstLevelMap:addNamedItemToMiddleGround("Object1", obj1)

        obj2 = MovableObj:clone()
        obj2:defineBase("Object2", textures.blue_square, 1, 1, 1)
        obj2:defineMovable(false,1,true)
        --obj2.hitBox = HitBoxObj:new(
        --    0, (obj2.texture.height - obj2.texture.height/3)*obj2.scale, obj2.texture.width*obj2.scale, (obj2.texture.height/3)*obj2.scale, obj2
        --)
        
        firstLevelMap:addNamedItemToMiddleGround("Object2", obj2)

        reorderRenderItems()

        obj2:setGotoPos(123,123)

    end

    function firstStage()

        firstLevelMap:act()
        firstLevelMap:render()

        quitButton()
        if shouldGameContinue == false then
            print("Level: ", firstLevelMap.name, " Deconstructed")
            firstLevelMap = nil
        end

    end

end