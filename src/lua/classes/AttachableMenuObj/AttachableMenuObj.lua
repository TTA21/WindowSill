do
    --[[
        TODO:
        string input
        button
        draggable lever

        separate them into components that can be added in a list,
        all of them should have some text besides them aswell
    ]]
    AttachableMenuObj = BaseObjAttachedObj:clone()

    function AttachableMenuObj:defineAttachableMenu(optionsList, openKey, closeKey, selectKey)
        ---closekey might be supplanted by a quit button if wanted

        self.optionsList = optionsList or {}

        --optionsList example:
        --[[
            {"Button", "Description1"}, --Description will be used to index list
            {"Button", "Description2"},
            {"TextInput", "Description3"},
            {"Dragger", "Description4"}
        ]]

        self.menuComponentList = {} ---Read optionsList and build it
        self.data = {}

        --data Example:
        --[[
            "Description1" = true
            "Description2" = false
            "Description3" = "asdasdasd"
            "Description4" = 78.2
        ]]

        self.isClosed = false
        self.selectKey = selectKey or "Enter"

        ---TODO: Make the background, the menu title, and render the components
        --- and do the updates of said components

    end

    function AttachableMenuObj:update()
        ---update every component, get their data, collect it to this obj
    end

    function AttachableMenuObj:getData()
        return self.data
    end

    --[[
        Menu's might not need to be deleted if the dev needs them again,
        so open and close are implemented and checked on the mapObj
    ]]
    function AttachableMenuObj:closeMenu()
        self.isClosed = true
    end

    function AttachableMenuObj:openMenu()
        self.isClosed = false
    end

end