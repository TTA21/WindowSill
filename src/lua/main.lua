package.path = 'src/lua/?.lua;' .. package.path

require('globals')  ---dont change the order
require('requires')


function setup()
    --serves to setup enviroment data, and first stage name
    
    math.randomseed(os.time())
    stageSelect("Setup")    --DO NOT CHANGE THIS

end

function stageSelect(currentStage)

    --stage refers to game levels, or screens or whatever you game calls it
    --stages are lead to the 'stages' folder in this directory
    --there their objects will be initialized, etc
    --stages are names of the main functions of the levels you create
    --for example: "levelOneMain", wich will lead to levelOneMain() in 'stages/levelOne.lua'

    if currentStage == "Setup" then
        ---lead to first stage
        currentStage = "First Stage"
        firstStageSetup()
        currentStageFunction = "firstStage"

    elseif currentStage == "First Stage" then
        firstStageSetup()
        currentStageFunction = "firstStage"

    elseif currentStage == "Second Stage" then
        currentStageFunction = "secondStage"
    end

end

--[[
    Used mostly for testing, put it in your loop if you want
]]--
function quitButton()
    for I, V in pairs(keysPressed) do
        if V == "Escape" then
            shouldGameContinue = false
        end

    end
end

--[[
    TODO:
    for alfa1.1
        menus,
        bugchecking with multiple resolutions and stress testing with multiple
        objects
        documentation of the engine so far
]]