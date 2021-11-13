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
}

