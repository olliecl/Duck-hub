print("Duck Hub: Fetching active window memory states...")

-- 1. Grab shared core framework objects from the master script session
local Hub = _G.DuckHubModules

if not Hub then
    warn("Duck Hub: Framework memory core registry unavailable.")
    return
end

local Fluent = Hub.Fluent
local GameTab = Hub.GameTab

-- 2. Add structural components natively
local Section = GameTab:AddSection("Egg Automation")

local AutoSafezoneEnabled = false
local LocalPlayer = game:GetService("Players").LocalPlayer

GameTab:AddToggle("AutoSafezoneToggle", {
    Title = "TP to Safezone When Holding Egg",
    Description = "Bypasses required velocity restrictions across all map zones.",
    Default = false,
    Callback = function(Value)
        AutoSafezoneEnabled = Value
        print("Auto Safezone Flag:", AutoSafezoneEnabled)
    end
})

-------------------------------------------------------------------------------
-- CORE LOGIC ENVIRONMENT LOOPS
-------------------------------------------------------------------------------
game:GetService("ProximityPromptService").PromptTriggered:Connect(function(prompt, player)
    -- Security clearance filter: verify target identity matches client trigger context
    if player ~= LocalPlayer then return end
    
    if AutoSafezoneEnabled then 
        local character = LocalPlayer.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        
        -- Locate user workspace plot container
        local Plot = workspace:FindFirstChild("Plot_" .. LocalPlayer.Name)
        if Plot then 
            local TPSpot = Plot:FindFirstChild("Spawn")
            if TPSpot then
                -- Perform secure layout displacement positioning updates
                character.HumanoidRootPart.CFrame = TPSpot.CFrame
                print("Duck Hub: Relocated safely back to base layout structure!")
            else
                warn("Duck Hub Logic Error: 'Spawn' part missing inside plot hierarchy.")
            end
        else
            warn("Duck Hub Logic Error: Workspace missing component matching: Plot_" .. LocalPlayer.Name)
        end
    end
end)
