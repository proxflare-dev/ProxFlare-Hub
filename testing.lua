local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Residence Massacre",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "By Grok",
    ConfigurationSaving = {Enabled = true, FolderName = "RM", FileName = "Config"}
})

-- NO ICONS = NO ERRORS
local InfoTab = Window:CreateTab("Info")
local RadarTab = Window:CreateTab("Radar")
local AutoTab = Window:CreateTab("Auto")

--------------------------------------------------------------------
-- INFO
--------------------------------------------------------------------
InfoTab:CreateSection("About")
InfoTab:CreateParagraph({Title = "Spirit Helper", Text = "ESP + Auto Door + Alarm + Teddy"})
InfoTab:CreateParagraph({Title = "Status", Text = "No icons = No errors. Works 100%."})

--------------------------------------------------------------------
-- ESP RADAR
--------------------------------------------------------------------
RadarTab:CreateSection("Monster ESP")

local ESP = false
local highlights = {}

RadarTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Callback = function(v)
        ESP = v
        if v then
            for _, name in {"Door", "Closet", "Vent", "Window"} do
                local model = workspace:FindFirstChild("Monster") and workspace.Monster:FindFirstChild(name)
                if model and model:FindFirstChild("Progress") then
                    local h = Instance.new("Highlight", model)
                    h.Adornee = model
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    h.FillTransparency = 0.5
                    h.OutlineTransparency = 0
                    highlights[model] = h

                    model.Progress:GetPropertyChangedSignal("Value"):Connect(function()
                        local stage = model.Progress.Value
                        if stage == 1 then
                            h.OutlineColor = name == "Closet" and Color3.fromRGB(255,0,0) or Color3.fromRGB(0,255,0)
                            h.FillColor = name == "Closet" and Color3.fromRGB(255,100,100) or Color3.fromRGB(100,255,100)
                        elseif stage == 2 then
                            h.OutlineColor = Color3.fromRGB(255,255,0)
                            h.FillColor = Color3.fromRGB(255,255,150)
                        elseif stage == 3 then
                            h.OutlineColor = Color3.fromRGB(255,0,0)
                            h.FillColor = Color3.fromRGB(255,100,100)
                        elseif stage == 0 then
                            if highlights[model] then highlights[model]:Destroy() end
                            highlights[model] = nil
                        end
                    end)
                end
            end
            Rayfield:Notify({Title = "ESP ON", Text = "Tracking all sources", Duration = 3})
        else
            for _, h in pairs(highlights) do if h then h:Destroy() end end
            highlights = {}
            Rayfield:Notify({Title = "ESP OFF", Text = "Stopped", Duration = 2})
        end
    end
})

--------------------------------------------------------------------
-- AUTO DOOR
--------------------------------------------------------------------
AutoTab:CreateSection("Auto Door")
local AutoDoor = false

AutoTab:CreateToggle({
    Name = "Auto Close Door",
    CurrentValue = false,
    Callback = function(v)
        AutoDoor = v
        if v then
            task.spawn(function()
                while AutoDoor do
                    local bed = workspace:FindFirstChild("Bed")
                    local door = workspace:FindFirstChild("Door")
                    local mdoor = workspace.Monster and workspace.Monster:FindFirstChild("Door")
                    if bed and door and mdoor and bed:FindFirstChild("Hidden") and mdoor:FindFirstChild("Progress") then
                        if bed.Hidden.Value and mdoor.Progress.Value == 3 then
                            repeat task.wait() until not bed.Hidden.Value
                            task.wait(0.7)
                            local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                local pos = Vector3.new(15.5, 5, -2.6)
                                local orig = hrp.CFrame
                                hrp.CFrame = CFrame.new(pos)
                                task.wait(0.3)
                                local cd = door.Detector and door.Detector:FindFirstChild("ClickDetector")
                                if cd then for i=1,3 do fireclickdetector(cd) task.wait(0.05) end end
                                task.wait(0.6)
                                hrp.CFrame = orig
                                Rayfield:Notify({Title = "Door Closed", Text = "Auto", Duration = 3})
                            end
                            task.wait(2)
                        end
                    end
                    task.wait()
                end
            end)
        end
    end
})

--------------------------------------------------------------------
-- AUTO ALARM
--------------------------------------------------------------------
AutoTab:CreateSection("Auto Alarm")
local AutoAlarm = false

AutoTab:CreateToggle({
    Name = "Auto Turn Off Alarm",
    CurrentValue = false,
    Callback = function(v)
        AutoAlarm = v
        if v then
            task.spawn(function()
                while AutoAlarm do
                    local radio = workspace:FindFirstChild("Radio")
                    if radio and radio:FindFirstChild("Main") and radio.Main:FindFirstChild("Alarm") and radio.Main.Alarm.IsPlaying then
                        local pos = Vector3.new(-10.7, 5, 17.1)
                        local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local orig = hrp.CFrame
                            hrp.CFrame = CFrame.new(pos)
                            task.wait(0.3)
                            local cd = radio:FindFirstChild("ClickDetector")
                            if cd then for i=1,3 do fireclickdetector(cd) task.wait(0.05) end end
                            task.wait(0.6)
                            hrp.CFrame = orig
                            Rayfield:Notify({Title = "Alarm Off", Text = "Auto", Duration = 3})
                        end
                        task.wait(3)
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})

--------------------------------------------------------------------
-- AUTO TEDDY
--------------------------------------------------------------------
AutoTab:CreateSection("Auto Teddy")
local AutoTeddy = false

AutoTab:CreateToggle({
    Name = "Auto Click Teddy",
    CurrentValue = false,
    Callback = function(v)
        AutoTeddy = v
        if v then
            task.spawn(function()
                while AutoTeddy do
                    local teddy = workspace:FindFirstChild("Teddy bear")
                    local cd = teddy and teddy:FindFirstChild("ClickDetector")
                    if cd then
                        local pos = Vector3.new(-8.7, 5, -8.8)
                        local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local orig = hrp.CFrame
                            hrp.CFrame = CFrame.new(pos)
                            task.wait(0.3)
                            fireclickdetector(cd)
                            task.wait(0.1)
                            hrp.CFrame = orig
                            Rayfield:Notify({Title = "Teddy Clicked", Text = "Auto", Duration = 2})
                        end
                    end
                    task.wait(8)
                end
            end)
        end
    end
})

--------------------------------------------------------------------
-- LOADED
--------------------------------------------------------------------
Rayfield:Notify({Title = "LOADED", Text = "v1.0 - No icons, no errors", Duration = 5})
