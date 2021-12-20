globalFrameCounter = 0  ---Number increases every CameraObj render
globalIdCounter = 0     ---Used to create unique id's
function newGlobalId()
    --print("ALERT, new item at added at frame " .. globalFrameCounter .." : " .. globalIdCounter)
    globalIdCounter = globalIdCounter + 1
    return (globalIdCounter - 1)
end

globalDefaultParams = {
    baseObjName = "Bob",
    numFramesPerAnimationStage = 1000,
    alpha = 100,
    scale = 1,
    hasCollision = true,
    allowRender = true,
}

renderItems = {}        ---used by the engine, do not mess with it directly
currentCameraRenderItems = {}

currentStageFunction = "stageSelect"    ---Leads to the function in another file in '/stages'
                                        ---ONLY FUNCTION 'stageSelect' CAN CHANGE THIS VARIABLE

shouldGameContinue = true   ---Self explanatory

windowOptions = {
    width = 800,
    height = 600,
    name = "WindowSill 1.0alpha"    ---The name of your game
}

keysPressedOld = {} --last iteration of keysPressed, used to check for key press differences
keysPressed = {}    --Comes as strings; 'A', 'B', 'Left Shift', 'Left Tab', etc
mouse = {}          --X, Y, RMB, LMB, MMB

------------------------------------
--Helper Functions

function istable(t) return type(t) == 'table' end

function bool_to_number(value)
return value and 1 or 0
end
  

--[[
    Checks collision of two hitboxes
    Expects two BaseObj derivatives.
    Objects must contain posX, posY, scale, hitBoxWidth, hitBoxHeight

    A XXXX C    A XXXX C
      XT X        XJ X
    D XXXX B    D XXXX B

]]--
function checkCollision(obj1, obj2)

    left_Tx = obj1.posX ---Tax, Tdx
    left_Jx = obj2.posX ---Jax, Jdx
    right_Tx = (obj1.posX + obj1.hitBoxWidth)   --Tcx, Tbx
    right_Jx = (obj2.posX + obj2.hitBoxWidth)   --Jcx, Jbx

    top_Ty = obj1.posY  ---Tay, Tcy
    top_Jy = obj2.posY  ---Jay, Jcy
    bottom_Ty = (obj1.posY + obj1.hitBoxHeight)     --Tdy, Tby
    bottom_Jy = (obj2.posY + obj2.hitBoxHeight)     --Jdy, Jby

    --print("BoxA", (left_Tx - right_Tx), "x", (top_Ty - bottom_Ty))

    if  not (bottom_Ty <= top_Jy) and 
        not (top_Ty >= bottom_Jy) and 
        not (right_Tx <= left_Jx) and 
        not (left_Tx >= right_Jx) then

        return true
    end
    
    return false
end

--[[
    Checks collision of two hitboxes and returns an array of booleans indicating wich side of the box was hit

    return: {upHit, downHit, leftHit, rightHit}
    0 == hit, 1 == nohit

    A XXXX C    A XXXX C
      XT X        XJ X
    D XXXX B    D XXXX B

]]--
function checkCollisionDirection(obj1, obj2)

    left_Tx = obj1.posX ---Tax, Tdx
    left_Jx = obj2.posX ---Jax, Jdx
    right_Tx = (obj1.posX + obj1.hitBoxWidth)+1   --Tcx, Tbx
    right_Jx = (obj2.posX + obj2.hitBoxWidth)+1   --Jcx, Jbx

    top_Ty = obj1.posY  ---Tay, Tcy
    top_Jy = obj2.posY  ---Jay, Jcy
    bottom_Ty = (obj1.posY + obj1.hitBoxHeight)+1     --Tdy, Tby
    bottom_Jy = (obj2.posY + obj2.hitBoxHeight)+1     --Jdy, Jby

    --print("BoxA", (left_Tx - right_Tx), "x", (top_Ty - bottom_Ty))

    if  not (bottom_Ty <= top_Jy) and 
        not (top_Ty >= bottom_Jy) and 
        not (right_Tx <= left_Jx) and 
        not (left_Tx >= right_Jx) then

            testInt2 = testInt2 + 1

            --test left
            leftHitx = math.abs(math.floor(right_Jx - left_Tx))

            --test right
            rightHitx = math.abs(math.floor(right_Tx - left_Jx))

            --test up
            upHity = math.abs(math.floor(top_Ty - bottom_Jy))

            --test down
            bottomHity = math.abs(math.floor(top_Jy - bottom_Ty))


            return {
                upHit = not (upHity == 1), 
                downHit = not (bottomHity == 1), 
                leftHit = not (leftHitx == 1), 
                rightHit = not (rightHitx == 1)
            }
    end
    
    return {
        upHit = true, 
        downHit = true, 
        leftHit = true, 
        rightHit = true
    }
end

--[[
    Check if obj1 is 'range' number of pixels near obj2
]]--

function checkNearby(obj1, obj2, range)

    obj1 = obj1.hitBox:getNormalized()
    obj2 = obj2.hitBox:getNormalized()

    left_Tx = obj1.posX ---Tax, Tdx
    left_Jx = obj2.posX - range ---Jax, Jdx
    right_Tx = (obj1.posX + obj1.hitBoxWidth)   --Tcx, Tbx
    right_Jx = (obj2.posX + obj2.hitBoxWidth) + range   --Jcx, Jbx

    top_Ty = obj1.posY  ---Tay, Tcy
    top_Jy = obj2.posY - range  ---Jay, Jcy
    bottom_Ty = (obj1.posY + obj1.hitBoxHeight)     --Tdy, Tby
    bottom_Jy = (obj2.posY + obj2.hitBoxHeight) + range     --Jdy, Jby

    --print("BoxA", (left_Tx - right_Tx), "x", (top_Ty - bottom_Ty))

    if  not (bottom_Ty <= top_Jy) and 
        not (top_Ty >= bottom_Jy) and 
        not (right_Tx <= left_Jx) and 
        not (left_Tx >= right_Jx) then

        return true
    end
    
    return false
end

--[[
    Gets the position of the center of the hitbox
]]
function getCenterOfHitbox(obj)
    return {
        posX = obj.posX + (obj.hitBox.hitBoxWidth)/2,
        posY = obj.posY + (obj.hitBox.hitBoxHeight)/2
    }
end

--[[
    Returns true if key has just been pressed, but not if the key is being pressed
]]
function risingEdgeKey(keyCode)
    isInOldBuffer = false
    for i,key in pairs(keysPressedOld) do
        if key == keyCode then isInOldBuffer = true end
    end
    isInCurrentBuffer = false
    for i,key in pairs(keysPressed) do
        if key == keyCode then isInCurrentBuffer = true end
    end

    return (isInCurrentBuffer and not isInOldBuffer)
end

--[[
    Returns the keys that have just been pressed
]]
function risingEdgeKeys(keyCode)
    ret = {}
    for i,key in pairs(keysPressed) do
        if risingEdgeKey(key) then
            ret[#ret+1] = key
        end
    end
    return ret
end

--[[
    Checks if key is pressed
]]
function keyIsPressed(keyCode)
    for i,key in pairs(keysPressed) do
        if key == keyCode then return true end
    end
    return false
end

--[[
    https://stackoverflow.com/questions/5249629/modifying-a-character-in-a-string-in-lua
    replaces a character in a string
]]
function replace_char(pos, str, r)
    return str:sub(1, pos-1) .. r .. str:sub(pos+1)
end


--[[
    Merges two tables together, tableBase recieves data from tableDonator
    If there are any similar keys in tableDonator, they will override the tableBase.
    References work just the same as any other table, no deep copies are made.
]]
function merge(tableBase, tableDonator)
    for k,v in pairs(tableDonator) do
        tableBase[k] = v
    end
end