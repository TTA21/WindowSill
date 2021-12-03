do

    local firstLevelMap = {}
    --new(
    --    1500, 1500, "First Level"
    --)

    button1 = {}

    function firstStageSetup()

        firstLevelMap = MapObj:clone()
        firstLevelMap:defineMap(1500, 1500, "First Level")

        obj1 = MovableObj:clone()
        obj1:defineBase({
            name = "Object1", 
            texture = textures.bard_16_31_left,
            posX = 123, 
            posY = 123
        })
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
        obj2:defineBase({
            name = "Object2", 
            texture = textures.bard_16_31_left, 
        })
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
        
        firstLevelMap:addNamedItemToBackGround("Object2", obj2)

        obj3 = BaseObj:clone()
        obj3:defineBase({
            name = "Object3", 
            texture = textures.blue_square, 
            posX = 321, 
            posY = 312
        })

        firstLevelMap:addNamedItemToMiddleGround("Object3", obj3)

        --print("obj3 ", obj3.globalId)

        obj2:setGotoPos(444,444)

        obj4 = BaseObjAttachedObj:clone()
        obj4:defineBase({name = "Object4", texture = textures.red_square, hasCollision = false})
        obj4:defineBaseObjAttached(obj2, 50,50)
        firstLevelMap:addNamedItemToMiddleGround("Object4", obj4)

        obj5 = MovableObjAttachedObj:clone()
        obj5:defineBase({name = "Object5", texture = textures.red_square})
        obj5:defineMovable(false,1,true)
        obj5:defineMovableObjAttached(obj1, 20,20)
        firstLevelMap:addNamedItemToMiddleGround("Object5", obj5)

        dialog1 = AttachableDialogObj:clone()
        dialog1:defineBase({name = "Dialog1"})
        dialog1:defineBaseObjAttached(obj1, 40, 40)
        dialog1:defineAttachableDialog("Test Message!\n Test Test?", 1, 2, 1, 3000 , 10, "C", true)
        firstLevelMap:addNamedItemToDialogs("Dialog1", dialog1)

        dialog2 = AttachableDialogObj:clone()
        dialog2:defineBase({name = "Dialog2"})
        dialog2:defineBaseObjAttached(obj2, 0, -80)
        dialog2:defineAttachableDialog("ASDASD()()\nzxczxc", 1, 2, 1, -1, 10, "F")
        firstLevelMap:addNamedItemToDialogs("Dialog2", dialog2)
        
        menuExamp = AttachableMenuObj:clone()
        menuExamp:defineBase({name = "menu1"})
        menuExamp:defineBaseObjAttached(obj1, 100, 100)
        menuExamp:defineAttachableMenu(
            "Menu 1", 
            {
                {"Button", {description = "First Button",}},    ---the rest is default
                {"Button", {description = "Second Button",}}, 
                {"Slider", {description = "First Slide", initialState = 50,}}, 
                {"StringInput", {description = "First String Input", stringLength = 20, initialState = "init"}},
                {"Button", {description = "Third Button",}},
            }, 
            "Tab",
            (function(data)
                --for i, d in pairs(data) do
                    --print(i, d)
                --end
                --print("")
            end)
        )
        firstLevelMap:addNamedItemToMenus("menu1", menuExamp)

        reorderRenderItems()
    end

    function firstStage()

        firstLevelMap:act()     ---MANDATORY
        firstLevelMap:render()  ---MANDATORY

        quitButton()
        if shouldGameContinue == false then
            print("Level: ", firstLevelMap.name, " Deconstructed")
            firstLevelMap = nil
        end

        globalFrameCounter = globalFrameCounter + 1 ---MANDATORY

    end

end


--[[
    TODO:
    Dialog trees, and dialog choices (simple menu)
    action scripts
    add constructors, loop conditions and other useful closures to objects  --WIP
]]