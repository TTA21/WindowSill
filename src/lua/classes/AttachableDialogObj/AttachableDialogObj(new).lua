do --open

    --[[
        This object is a dialog box attached to some object, usually an NPC

        If one wants to have it as a simpler dialog box on the screen and not move like
        an rpg, simply attach it to whatever the camera is anchored to
    ]]

    AttachableDialogObj = BaseObjAttachedObj:clone()

    ---Data declaration

    AttachableDialogObj.texture = textures.std_menu_background_white_10_10 ---Standard

    ---Function Declaration

    --[[
        defineAttachableDialog({
            baseObj params,
            baseObjAttached params,
            lines = {
                {
                    text = ,    ---The text of a single line
                    font = ,    ---Default if not declared
                    size = ,    ---Font's default if not declared
                },
            },
            image = {   ---The image at the side of the dialog
                texture = ,
                width = ,   ---The texture's width and height if not declared
                height = ,
            },
        })
    ]]

    --[[
        lines = {
            {
                text = ,    ---The text of a single line
                font = ,    ---Default if not declared
            },
        },

        or

        lines = {
            {text = "asdasd"},
            {text = "dsasdasd"},
            {text = "qweqweqeqwewe"},
        }
    ]]

    ----TODO:
    ----Scale the dialogs correctly, they are mismatched
    ----Add side images
    ----Add simple menu to dialog

    function AttachableDialogObj:defineAttachableDialog(
        params
    )

        self:defineBaseObjAttached(params)
    end


end --close