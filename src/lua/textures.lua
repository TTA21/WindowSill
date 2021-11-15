---IMPORTANT
---'identifier' HAS TO BE UNIQUE, 
---otherwise the first texture in the list with the same identifier will be loaded
---NOTE 'identifier' has to be a number but it doesnt have to be ordered, it is simply an index
---All the games sprites are loaded here
---the width and height are of a single sprite, but many character animations might be in it
---for animation purposes, DO NOT MAKE THE 'width' AND 'height' THE SIZE OF THE IMAGE UNLESS
---THE SPRITE IS THE WHOLE IMAGE

---Also important, numAnimationStages is the number of sprites in series -1, since it counts from 0

--Example
--[[

textures = {
    bardo_asset = {
        identifier = 1,
        spritePath = "assets/bardo.png",
        width = 26,
        height = 36,
        numAnimationStages = 2
    },
    bardo_2_asset = {
        identifier = 2,
        spritePath = "assets/bardo2.png",
        width = 26,
        height = 36,
        numAnimationStages = 2
    }
}

]]--


---If the name isnt here, it wont be loaded at all
texturesToBeLoaded = {
    'bardo_asset',
    'bardo_2_asset',
    'red_square',
    'blue_square',
    'bard_16_31_left',
    'bard_17_31_up',
    'bard_16_31_right',
    'bard_18_31_down',
    'bard_15_31_right_still',
    'bard_16_31_left_still',
    'bard_17_31_up_still',
    'bard_18_31_down_still',
}
textures = {
    bardo_asset = {
        identifier = 1,
        spritePath = "assets/bardo.png",
        width = 26,
        height = 36,
        numAnimationStages = 2,
    },
    bardo_2_asset = {
        identifier = 2,
        spritePath = "assets/bardo2.png",
        width = 26,
        height = 36,
        numAnimationStages = 2,
    },
    red_square = {
        identifier = 3,
        spritePath = "assets/red.png",
        width = 20,
        height = 20,
        numAnimationStages = 0,
    },
    blue_square = {
        identifier = 4,
        spritePath = "assets/blue.png",
        width = 20,
        height = 20,
        numAnimationStages = 0,
    },
    bard_16_31_left = {
        identifier = 5,
        spritePath = "assets/bard_16_31_left.png",
        width = 16,
        height = 31,
        numAnimationStages = 3,
    },
    bard_16_31_right = {
        identifier = 6,
        spritePath = "assets/bard_16_31_right.png",
        width = 16,
        height = 31,
        numAnimationStages = 3,
    },
    bard_17_31_up = {
        identifier = 7,
        spritePath = "assets/bard_17_31_up.png",
        width = 17,
        height = 31,
        numAnimationStages = 3,
    },
    bard_18_31_down = {
        identifier = 8,
        spritePath = "assets/bard_18_31_down.png",
        width = 18,
        height = 31,
        numAnimationStages = 3,
    },

    bard_15_31_right_still = {
        identifier = 9,
        spritePath = "assets/bard_15_31_right_still.png",
        width = 15,
        height = 31,
        numAnimationStages = 2,
    },
    bard_16_31_left_still = {
        identifier = 10,
        spritePath = "assets/bard_16_31_left_still.png",
        width = 16,
        height = 31,
        numAnimationStages = 2,
    },
    bard_17_31_up_still = {
        identifier = 11,
        spritePath = "assets/bard_17_31_up_still.png",
        width = 17,
        height = 31,
        numAnimationStages = 0,
    },
    bard_18_31_down_still = {
        identifier = 12,
        spritePath = "assets/bard_18_31_down_still.png",
        width = 18,
        height = 31,
        numAnimationStages = 2,
    },
}

