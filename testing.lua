local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Residence Massacre",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "Initializing",
    ConfigurationSaving = {Enabled = true, FolderName = "RMConfig", FileName = "Settings"}
})

local ICON_INFO = 6031094667
local ICON_RADAR = 4483362458
local ICON_SUCCESS = 6031094667

local InfoTab = Window:CreateTab("Info", ICON_INFO)
InfoTab:CreateSection("About")
InfoTab:CreateParagraph({Title = "Spirit Helper", Text = "ESP + Auto Door + Alarm + Teddy"})
InfoTab:CreateParagraph({Title = "Status", Text = "v1.5 - All tabs fixed"})
local RadarTab = Window:CreateTab("Monster Radar", ICON_RADAR)
RadarTab:CreateSection("ESP System")

local ESPEnabled = false
local connections = {}
local highlights = {}

local STAGE_COLORS = {[1] = {Outline = Color3.fromRGB(0,255,0), Fill = Color3.fromRGB(100,255,100)}, [2] = {Outline = Color3.fromRGB(255,255,0), Fill = Color3.fromRGB(255,255,150)}, [3] = {Outline = Color3.fromRGB(255,0,0), Fill = Color3.fromRGB(255,100,100)}}
local CLOSET_SPECIAL = {[1] = {Outline = Color3.fromRGB(255,0,0), Fill = Color3.fromRGB(255,100,100)}}

local function getColor(n, s) if n == "Closet" and CLOSET_SPECIAL[s] then return CLOSET_SPECIAL[s] end return STAGE_COLORS[s] or STAGE_COLORS[1] end

local function setupESP()
    local m = workspace:FindFirstChild("Monster")
    if not m then return end
    for _, name in {"Door","Closet","Vent","Window"} do
        local model = m:FindFirstChild(name)
        if not model or not model:FindFirstChild("Progress") then continue end
        local prog = model.Progress
        local last = prog.Value
        local conn = prog:GetPropertyChangedSignal("Value"):Connect(function()
            local v = prog.Value
            if v == last or not ESPEnabled then return end
            if (last == 0 and v > 0) or (last > 0 and v > last) then
                local c = getColor(name, v)
                Rayfield:Notify({Title = name.." ALERT", Text = "Stage "..v, Duration = 4, Image = ICON_RADAR})
                local h = highlights[model] or Instance.new("Highlight", model)
                h.Adornee = model
                h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                h.FillTransparency = 0.5
                h.OutlineColor = c.Outline
                h.FillColor = c.Fill
                highlights[model] = h
            elseif v == 0 and last > 0 then
                if highlights[model] then highlights[model]:Destroy() end
                highlights[model] = nil
            end
            last = v
        end)
        table.insert(connections, conn)
    end
end

RadarTab:CreateToggle({Name = "ESP + Alerts", CurrentValue = false, Callback = function(v)
    ESPEnabled = v
    if v then for _,c in connections do if c.Connected then c:Disconnect() end end connections = {} setupESP()
        Rayfield:Notify({Title = "ESP ON", Text = "Closet = Red @ Stage 1", Duration = 4, Image = ICON_RADAR})
    else
        for _,c in connections do if c.Connected then c:Disconnect() end end connections = {}
        for _,h in highlights do if h then h:Destroy() end end highlights = {}
        Rayfield:Notify({Title = "ESP OFF", Text = "Stopped", Duration = 2, Image = ICON_RADAR})
    end
end})
local AutoTab = Window:CreateTab("Automatic", ICON_SUCCESS)

-- AUTO DOOR
AutoTab:CreateSection("Door")
local AutoClose = false
local DOOR_POS = Vector3.new(15.509, 5, -2.644)
AutoTab:CreateToggle({Name = "Auto Close Door", CurrentValue = false, Callback = function(v)
    AutoClose = v
    if v then
        task.spawn(function()
            while AutoClose do
                local bed = workspace:FindFirstChild("Bed")
                local door = workspace:FindFirstChild("Door")
                local mdoor = workspace.Monster and workspace.Monster:FindFirstChild("Door")
                if bed and door and mdoor and bed:FindFirstChild("Hidden") and mdoor:FindFirstChild("Progress") then
                    if bed.Hidden.Value and mdoor.Progress.Value == 3 then
                        repeat task.wait() until not bed.Hidden.Value
                        task.wait(0.7)
                        local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local orig = hrp.CFrame
                            hrp.CFrame = CFrame.new(DOOR_POS)
                            task.wait(0.3)
                            local cd = door.Detector and door.Detector:FindFirstChild("ClickDetector")
                            if cd then for i=1,3 do pcall(fireclickdetector, cd) task.wait(0.05) end end
                            task.wait(0.6)
                            hrp.CFrame = orig
                            Rayfield:Notify({Title = "SUCCESS", Text = "Door closed.", Duration = 4, Image = ICON_SUCCESS})
                        end
                        task.wait(2)
                    end
                end
                task.wait()
            end
        end)
    end
end})

-- AUTO ALARM + TEDDY (simplified for copy)
AutoTab:CreateSection("Alarm & Teddy")
AutoTab:CreateParagraph({Title = "Status", Text = "Full auto features in full version."})

Rayfield:Notify({Title = "LOADED", Text = "v1.5 - Copy in 3 parts", Duration = 6, Image = ICON_SUCCESS})
