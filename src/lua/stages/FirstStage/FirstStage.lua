do

    local firstLevelMap = MapObj:new(
        1500, 1500, "First Level"
    )

    function firstStageSetup()

        obj1 = MovableObj:clone()
        obj1:defineBase("Object1", textures.bard_16_31_left, 1, 123, 123)
        obj1:defineMovable(true,1,true, {
            up_still = textures.bard_17_31_up_still,
            down_still = textures.bard_18_31_down_still,
            left_still = textures.bard_16_31_left_still,
            right_still = textures.bard_15_31_right_still,
            up = textures.bard_17_31_up,
            down = textures.bard_18_31_down,
            left = textures.bard_16_31_left,
            right = textures.bard_16_31_right,
        })
        
        firstLevelMap:addCameraAnchoredTo("Main Camera", obj1)

        firstLevelMap:addNamedItemToMiddleGround("Object1", obj1)

        obj2 = MovableObj:clone()
        obj2:defineBase("Object2", textures.bard_16_31_left, 1, 1, 1)
        obj2:defineMovable(false,1,true,{
            up_still = textures.bard_17_31_up_still,
            down_still = textures.bard_18_31_down_still,
            left_still = textures.bard_16_31_left_still,
            right_still = textures.bard_15_31_right_still,
            up = textures.bard_17_31_up,
            down = textures.bard_18_31_down,
            left = textures.bard_16_31_left,
            right = textures.bard_16_31_right,
        })
        
        firstLevelMap:addNamedItemToMiddleGround("Object2", obj2)

        obj3 = BaseObj:clone()
        obj3:defineBase("Object3", textures.blue_square, 1, 321, 312)

        firstLevelMap:addNamedItemToMiddleGround("Object3", obj3)

        reorderRenderItems()

        obj2:setGotoPos(444,444)

        obj4 = BaseObjAttachedObj:clone()
        obj4:defineBase("Object4", textures.red_square, 1, 1,1)
        obj4.hasCollision = false
        obj4:defineBaseObjAttached(obj2, 50,50)
        firstLevelMap:addNamedItemToMiddleGround("Object4", obj4)

        obj5 = MovableObjAttachedObj:clone()
        obj5:defineBase("Object5", textures.red_square, 1, 1,1)
        obj5:defineMovable(false,1,true)
        obj5:defineBaseObjAttached(obj1, 20,20)
        firstLevelMap:addNamedItemToMiddleGround("Object5", obj5)

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