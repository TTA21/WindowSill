do

    ---QueueObj |  Class Definition

    --[[
        :defineQueue({
            intervalFrame = ,
            updateCondition = (         ---Begin updating if closure returns true
                function (this) 
                    return
                end
            ),
            onUpdate = (
                function (this) 
                
                end
            ),
            onConstructor = (
                function (this)

                end
            ),
            stopCondition = (
                function (this) 
                    return 
                end
            ),
            onStopCondition = (     ---Upon completion, do this
                function (this) 
                    return 
                end
            ),
        })
    ]]

    --[[
        QueueObj perform an action (onUpdate) every interval (intervalFrame) until a 
        condition is true (stopCondition), the condition might be complex, thus
        a closure is used to store parameters in the object (onConstructor).

        This is useful for making dynamic scenes where characters or scenarios will appear in
        sequence. Aswell as making better looking dialogs.

        :defineQueue({
            intervalFrame = ,       ---How many frames between every update
            onUpdate = (            ---What will happen if the stop condition is false
                function (this) 
                
                end
            ),
            onConstructor = (       ---If necessary to add more data or perform more actions
                function (this)

                end
            ),
            stopCondition = (       ---If true, object stops
                function (this) 
                    return 
                end
            ),
            onStopCondition = (     ---Upon completion, do this
                function (this) 
                    return 
                end
            ),
        })

        ---------------------
        example:
        testQueue = QueueObj:clone()
        testQueue:defineQueue({
            intervalFrame = 10,
            onConstructor = (
                function (this)
                    this.accumulator = 0
                end
            ),
            onUpdate = (
                function (this) 
                    print(globalFrameCounter .. " INSERT")
                    this.accumulator = this.accumulator + 1
                end
            ),
            stopCondition = (
                function (this) 
                    return (this.accumulator > 10)
                end
            ),
        })

        testQueue:update()

        Output:
        0 INSERT
        10 INSERT
        20 INSERT
        30 INSERT
        40 INSERT
        50 INSERT
        60 INSERT
        70 INSERT
        80 INSERT
        90 INSERT
        100 INSERT
    ]]

    QueueObj = object:clone()

    function QueueObj:defineQueue(params)
        self.globalId = newGlobalId()

        if params.intervalFrame > 0 then
            self.intervalFrame = params.intervalFrame or 1
        else
            print("ALERT! defineQueue called with intervalFrame less than 1")
            self.intervalFrame = 1
        end

        self.updateCondition = params.updateCondition or (function (this) return true end)
        self.onUpdate = params.onUpdate or (function (this) end)
        self.stopCondition = params.stopCondition or (function (this) return false end)
        self.onStopCondition = params.onStopCondition or (function (this) end)

        self.finished = false

        params.onConstructor(self)
    end

    --[[
        ***************MEANT TO BE CALLED EVERY FRAME***************
    ]]
    function QueueObj:update()

        if self.updateCondition(self) then
            stopCondition = self.stopCondition(self) 
            if not self.finished and not stopCondition 
                and ((globalFrameCounter % self.intervalFrame) == 0) then
                    self.onUpdate(self)
            end

            if stopCondition and not self.finished then
                self.onStopCondition(self)
                self.finished = true
            end
        end

    end

end