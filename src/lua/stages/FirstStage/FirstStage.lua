do

    local firstLevelMap = MapObj:new(
        1500, 1500, "First Level"
    )

    function firstStageSetup()

        obj1 = MovableObj:new( "Object1", textures.red_square, 1, 123, 123)
        obj1.allowMovementByKeyboard = true
        obj1.movementMultiplier = 1
        obj1.hasCollision = true
        --obj1.hitBox = HitBoxObj:new(
        --    0, 0, obj1.texture.width*obj1.scale, obj1.texture.height*obj1.scale, obj1
        --)
        obj1:keyboardMove()

        firstLevelMap:addCameraAnchoredTo("Main Camera", obj1)

        firstLevelMap:addNamedItemToMiddleGround("Object1", obj1)

        obj2 = BaseObj:new( "Object2", textures.blue_square, 1, 80, 150 )
        obj2.hasCollision = true
        obj2.hitBox = HitBoxObj:new(
            0, (obj2.texture.height - obj2.texture.height/3)*obj2.scale, obj2.texture.width*obj2.scale, (obj2.texture.height/3)*obj2.scale, obj2
        )
        
        firstLevelMap:addNamedItemToMiddleGround("Object2", obj2)

        reorderRenderItems()

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