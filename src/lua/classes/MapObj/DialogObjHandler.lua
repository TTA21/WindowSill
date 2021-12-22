    
    function MapObj:addToDialogs(obj)
        if obj:isa(AttachableDialogObj) then
            obj:changePriority(globalDefaultParams.priorities.dialog)
            self.dialogs.backGrounds[#self.dialogs.backGrounds + 1] = obj
            self:insertLetterQueue(obj)
            return true
        else
            print("ALERT! Attempt to add non-dialog object to dialogs at frame " .. globalFrameCounter)
        end
        return false
    end

    --[[
        :removeFromDialogs({
            globalId = ,    ---only one will suffice
            object = ,
        })
    ]]
    function MapObj:removeFromDialogs(params)
        foundObj = false
        if params.globalId then
            for index, object in pairs(self.dialogs) do
                if object.globalId == params.globalId then
                    self.dialogs[index] = nil
                    foundObj = true
                end
            end
        elseif params.object then
            for index, object in pairs(self.dialogs) do
                if object.globalId == params.object.globalId then
                    self.dialogs[index] = nil
                    foundObj = true
                end
            end
        else

            return false
        end

        return foundObj
    end

    function MapObj:insertLetter(obj)
        if obj:isa(BaseObjAttachedObj) then
            obj:changePriority(globalDefaultParams.priorities.letter)
            self.dialogs.letters[#self.dialogs.letters + 1] = obj
            return true
        else
            print("ALERT! insertLetter called with improper object at frame " .. globalFrameCounter)
        end
        return false
    end

    --[[
        obj refers to the dialog object, where it gathers all letters to put on a queue
    ]]--
    function MapObj:insertLetterQueue(obj)
        if obj:isa(AttachableDialogObj) then
            queue = QueueObj:clone()
            queue:defineQueue({
                intervalFrame = obj.framesPerLetter,
                onConstructor = (
                    function (this)
                        this.accumulator = 1
                    end
                ),
                onUpdate = (
                    function (this)
                        self:insertLetter(obj.letters[this.accumulator]) 
                        this.accumulator = this.accumulator + 1
                    end
                ),
                stopCondition = (
                    function (this) 
                        return ( 1 + #obj.letters == this.accumulator)
                    end
                ),
            })
            self.queues[#self.queues + 1] = queue
            return true
        else
            print("ALERT! insertLetterQueue called with non-AttachableDialogObj at frame " .. globalFrameCounter)
        end
        return false
    end

    function MapObj:dialogObjLoop()

        for i, obj in pairs(self.dialogs.backGrounds) do

            ---If dialog is renderable, update it, otherwise leave it alone
            if obj.allowRender then
                obj:update()
            end

            ---If 'pauseGame' is set, pause the game, this conditional is dealt with internally
            ---in the dialog obj
            if obj.pauseGame then
                self:pauseGameDueToDialog()
            end
            
            ---If the dialog paused the game, and is now closed, unpause and delete the dialog
            if obj.isClosed and obj.pauseGame then
                self:unPauseGameDueToDialog()
                self.dialogs[i] = nil
            end
        end

        ---Update Dialogs letters
        for i, obj in pairs(self.dialogs.letters) do
            if obj.allowRender then
                obj:updatePos()
            end
        end

    end