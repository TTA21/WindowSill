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
        
        firstLevelMap:addNamedItemToBackGround("Object2", obj2)

        obj3 = BaseObj:clone()
        obj3:defineBase("Object3", textures.blue_square, 1, 321, 312)

        firstLevelMap:addNamedItemToMiddleGround("Object3", obj3)

        obj2:setGotoPos(444,444)

        obj4 = BaseObjAttachedObj:clone()
        obj4:defineBase("Object4", textures.red_square, 1)
        obj4.hasCollision = false
        obj4:defineBaseObjAttached(obj2, 50,50)
        firstLevelMap:addNamedItemToMiddleGround("Object4", obj4)

        obj5 = MovableObjAttachedObj:clone()
        obj5:defineBase("Object5", textures.red_square, 1)
        obj5:defineMovable(false,1,true)
        obj5:defineMovableObjAttached(obj1, 20,20)
        firstLevelMap:addNamedItemToMiddleGround("Object5", obj5)

        dialog1 = AttachableDialogObj:clone()
        dialog1:defineBase("Dialog1")
        dialog1:defineBaseObjAttached(obj1, 40, 40)
        dialog1:defineAttachableDialog("Test Message!\n Test Test?", 1, 2, 1, 3000 , 10, "C", true)
        firstLevelMap:addNamedItemToDialogs("Dialog1", dialog1)

        dialog2 = AttachableDialogObj:clone()
        dialog2:defineBase("Dialog2")
        dialog2:defineBaseObjAttached(obj2, 0, -80)
        dialog2:defineAttachableDialog("ASDASD()()\nzxczxc", 1, 2, 1, -1, 10, "F")
        firstLevelMap:addNamedItemToDialogs("Dialog2", dialog2)
        
        --objTest = BaseObj:clone()
        --font = FontObj:clone()
        --font:defineFont()
        --objTest:defineBase("Font", font.texture, 1,30, 30 )
        --objTest.animStage = 3
        --objTest.pauseAnimation = true
        --firstLevelMap:addNamedItemToMiddleGround("Font", objTest)

        --timedRenderer = TimedRendererObj:clone()
        --timedRenderer:defineTimedRenderer(400, dialog1.letters, firstLevelMap.dialogs.letters)
        --timed = timedRenderer

        --[[
        testButton = ButtonMenuObj:clone()
        testButton:defineBase("button1", nil, 1)
        testButton:defineBaseObjAttached(obj1, 150,150)
        testButton:defineButtonMenu("asdasd", nil, true, false)
        firstLevelMap:addNamedItemToMenus("button1", testButton)
        button1 = testButton

        stringInput = StringInputMenuComponentObj:clone()
        stringInput:defineBase("input1", nil, 1)
        stringInput:defineBaseObjAttached(obj1, 100, 100)
        stringInput:defineStringInputMenu("type something", 10, true, "")
        firstLevelMap:addNamedItemToMenus("input1", stringInput)

        sliderInput = SliderMenuComponentObj:clone()
        sliderInput:defineBase("sliderinput1", nil, 1)
        sliderInput:defineBaseObjAttached(obj1, -100, -100)
        sliderInput:defineSliderMenu("slide the slide", nil, true, 50, 10, true)
        firstLevelMap:addNamedItemToMenus("sliderinput1", sliderInput)
        ]]

        menuExamp = AttachableMenuObj:clone()
        menuExamp:defineBase("menu1", nil, 1)
        menuExamp:defineBaseObjAttached(obj1, 100, 100)
        menuExamp:defineAttachableMenu(
            "Menu 1", 
            {
                {"Button", {description = "First Button",}},    ---the rest is default
                {"Button", {description = "Second Button",}}, 
                {"Slider", {description = "First Slide", initialState = 50,}}, 
                {"StringInput", {description = "First String Input",}}
            }, 
            "Tab",
            (function(data)
                for i, d in pairs(data) do
                    print(i, d)
                end
                print("")
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