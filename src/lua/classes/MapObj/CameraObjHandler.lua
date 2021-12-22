
    --[[
        Added cameras are not immediatly active, they must be activated later.
    ]]
    function MapObj:addCamera(name, camera)
        if type(name) == "string" then
            if camera:isa(CameraObj) then
                --camera.currentCam = false
                self.cameras[name] = camera
                return true
            else
                print("Alert! Attempt to add non-camera object to cameras at frame" .. globalFrameCounter)
            end
        else
            print("Alert! Attempt to add camera with a non-string name at frame " .. globalFrameCounter)
        end
        return false
    end

    --[[
        In principle only one camera should be active at a time, so all others are disabled.
    ]]
    function MapObj:switchToCamera(name)
        if type(name) == "string" then

            if not self.cameras[name] then
                print("Alert! Camera " .. name .. "not found, cannot switch")
                return false
            end

            for i, cam in pairs(self.cameras) do
                    cam:disableCamera()
            end

            self.cameras[name]:enableCamera()
            return true

        else
            print("Alert! Attempt to camera switch to non-string name")
            return true
        end

    end