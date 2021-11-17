do

    --[[
        Timed insertions insert to the end (append) a table to another in an interval
        Useful for dialogs, where you want one letter ater another in a sequence
        but not all at the same time

        If self.isDone is true, make sure to nullify the reference to this object to not
        waste performance
    ]]

    TimedInsertionObj = object:clone()

    function TimedInsertionObj:defineTimedRenderer(
        interval,       ---The interval in frames
        itemTable,      ---The items to add
        tableToinsert   ---Where the items are put
    )

        self.itemTable = itemTable or {}
        self.tableToinsert = tableToinsert or nil
        self.interval = interval or 1

        self.currentTime = globalFrameCounter
        self.index = 1
        self.isDone = false

    end

    function TimedInsertionObj:update()
        if (self.index ~= #self.itemTable)
            and (globalFrameCounter > (self.currentTime + self.interval))
        then
            --self.tableToinsert[#self.tableToinsert] = item
            self.tableToinsert[#self.tableToinsert+1] = self.itemTable[self.index]
            self.index = self.index + 1
            self.currentTime = globalFrameCounter
        end

        if self.index == #self.itemTable then
            self.isDone = true
        end
    end
end