do

    --[[
        Timed insertions insert to the end (append) a table to another in an interval
        Useful for dialogs, where you want one letter ater another in a sequence
        but not all at the same time
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

    end

    function TimedInsertionObj:update()
        if (#self.itemTable > 0) 
            and (self.index < #self.itemTable)
            and globalFrameCounter > (self.currentTime + self.interval)
        then
            --self.tableToinsert[#self.tableToinsert] = item
            self.tableToinsert[#self.tableToinsert+1] = self.itemTable[self.index]
            self.index = self.index + 1
            self.currentTime = globalFrameCounter
        end
    end
end