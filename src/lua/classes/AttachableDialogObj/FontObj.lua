do -- open

    ---Serves to define the font and its table

    FontObj = object:clone()

    function FontObj:defineFont(characters, texture)
        self.texture = texture or textures.std_font_10_10
        self.characters = characters or 
            "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890!?%()' " --standard

        self.charTable = {}

        for i=1, #self.characters do
            --print(self.characters:sub(i,i), i-1)
            self.charTable[self.characters:sub(i,i)] = i-1
        end
    end

end -- close