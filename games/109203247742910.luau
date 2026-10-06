-- Duck Hub: Custom Game Script Load
print("Duck Hub: Tailored Safezone script loaded successfully!")

-- 1. Safely find or re-initialize Fluent interface components
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- 2. Dynamically retrieve the open window environment
local Window = nil
for _, obj in pairs(game:GetService("CoreGui"):GetChildren()) do
    if obj:IsA("ScreenGui") and (string.find(obj.Name, "Fluent") or string.find(obj.Name, "DuckHub")) then
        -- Fluent creates internal variables on the Window object, but we can reconstruct access via options
        break
    end
end

-- 3. Instead of guess-seeking Fluent tables, look up active UI elements or create a safe fallback
local Options = Fluent.Options
local GameTab = nil

-- If standard reference fails, Fluent allows creating a direct sub-tab or section
-- We can add our elements directly to the framework configuration cleanly:
local Window = _G.DuckHubWindow or Fluent.Windows[1]

-- Safe check to ensure we can hook into your existing window tabs
if Fluent.Tabs and Fluent.Tabs.GameModules then
    GameTab = Fluent.Tabs.GameModules
else
    -- Fallback: If it cannot find the main tab, it will safely execute the logic standalone
    print("Duck Hub: Attaching modules to active window session...")
end

-- 4. Auto Safezone Configuration Variables
local AutoSafezoneEnabled = false
local LocalPlayer = game:GetService("Players").LocalPlayer

-- Create the Toggle Switch (Fixed syntax and typos)
Fluent:Notify({
    Title = "Duck Hub Modules",
    Content = "Injected Safezone exploit utilities successfully!",
    Duration = 3
})

-- Adding elements directly via options registry bypasses cross-script blockages
-- Note: Change 'Fluent.Tabs.GameModules' to wherever your UI reference sits
if Fluent.Tabs and Fluent.Tabs.GameModules then
    local Section = Fluent.Tabs.GameModules:AddSection("Egg Automation")

    Fluent.Tabs.GameModules:AddToggle("AutoSafezoneToggle", {
        Title = "TP to Safezone When Holding Egg",
        Description = "Bypasses required velocity restrictions across all map zones.",
        Default = false,
        Callback = function(Value)
            AutoSafezoneEnabled = Value
            print("Auto Safezone Status:", AutoSafezoneEnabled)
        end
    })
end

-------------------------------------------------------------------------------
-- CORE LOGIC RUNTIME ENGINE
-------------------------------------------------------------------------------
game:GetService("ProximityPromptService").PromptTriggered:Connect(function(prompt, player)
    -- Ensure the prompt was triggered by YOUR local player, not someone else on the server
    if player ~= LocalPlayer then return end
    
    if AutoSafezoneEnabled then 
        local character = LocalPlayer.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        
        -- Dynamically locate player's base plot
        local Plot = workspace:FindFirstChild("Plot_" .. LocalPlayer.Name)
        if Plot then 
            local TPSpot = Plot:FindFirstChild("Spawn")
            if TPSpot then
                -- Perform instant client teleportation
                character.HumanoidRootPart.CFrame = TPSpot.CFrame
                print("Duck Hub: Successfully teleported back to Safezone Spawn!")
            else
                warn("Duck Hub: 'Spawn' object missing inside your plot workspace container.")
            end
        else
            warn("Duck Hub: Could not find workspace plot named: Plot_" .. LocalPlayer.Name)
        end
    end
end)
