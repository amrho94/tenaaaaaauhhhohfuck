if not game:IsLoaded() then game.Loaded:Wait() end
local previous=shared.Tenacity
if previous then pcall(function()previous:Uninject()end)end

local core
local rawLoadstring=loadstring
local function compile(source,name)
    local chunk,err=rawLoadstring(source,name)
    if not chunk then
        warn('[Tenacity] Compile failed: '..tostring(err))
        if core then core:CreateNotification('Tenacity','Failed to compile '..tostring(name)..': '..tostring(err),30,'alert')end
        error(err,2)
    end
    return chunk
end

local queue_on_teleport=queue_on_teleport or function()end
local isfile=isfile or function(file)local ok,value=pcall(readfile,file);return ok and value~=nil and value~=''end
local cloneref=cloneref or function(value)return value end
local Players=cloneref(game:GetService('Players'))

local runtime=shared.TenacityRuntime
if not runtime then
    runtime=assert(compile(readfile('tenacity/libraries/runtime.lua'),'@tenacity/libraries/runtime.lua'))()
    shared.TenacityRuntime=runtime
elseif previous and type(runtime.ClearMemoryCache)=='function' then
    pcall(runtime.ClearMemoryCache)
end
local read=runtime.Read

local loading=compile(read('tenacity/guis/loading.lua'),'@tenacity/guis/loading.lua')()
shared.TenacityLoading=loading
loading:SetLoadingProgress(.07,'Initializing runtime')

local preload={'tenacity/guis/tenacity.lua','tenacity/libraries/tenacity-api.lua','tenacity/libraries/krs-render.lua'}
if not shared.TenacityIndependent then preload[#preload+1]='tenacity/games/universal.lua'end
runtime.Prefetch(preload)
loading:SetLoadingProgress(.25,'Constructing Tenacity shell')

core=compile(read('tenacity/guis/tenacity.lua'),'@tenacity/guis/tenacity.lua')()
assert(type(core)=='table'and core.Name=='Tenacity','Tenacity UI did not return a valid core.')
assert(core.Build=='tenacity-ui-r2','Stale Tenacity core detected: '..tostring(core.Build))
shared.Tenacity=core
shared.TenacityBuild=core.Build

local apiFactory=compile(read('tenacity/libraries/tenacity-api.lua'),'@tenacity/libraries/tenacity-api.lua')()
core.API=apiFactory(core)
shared.TenacityAPI=core.API

loading:SetTheme(core.Libraries.uipallet,core.GUIColor)
core.HideLoadingScreen=function(_,immediate)loading:HideLoadingScreen(immediate)end
core:Clean(function()loading:HideLoadingScreen(true)end)

local function finish()
    core.Init=nil
    loading:SetLoadingProgress(.82,'Restoring Tenacity profile')

    if not core.Libraries.additions then
        local ok,err=pcall(function()
            local init=compile(read('tenacity/libraries/additions.lua'),'@tenacity/libraries/additions.lua')()
            init(core)
        end)
        if not ok then core:CreateNotification('Extensions',tostring(err),12,'alert')end
    end

    core:Load()
    loading:SetLoadingProgress(1,'Tenacity ready')
    core:HideLoadingScreen()

    task.spawn(function()
        repeat
            task.wait(30)
            if shared.Tenacity~=core or not core.Loaded then break end
            core:Save()
        until not core.Loaded
    end)

    local queued=false
    core:Clean(Players.LocalPlayer.OnTeleport:Connect(function()
        if queued or shared.TenacityIndependent then return end
        queued=true;core:Save()
        local teleportScript=[[
            shared.TenacityReload=true
            local ok,source=pcall(readfile,'tenacity/loader.lua')
            if ok then
                assert(loadstring(source,'@tenacity/loader.lua'))()
            else
                local repo=shared.TenacityRepository or 'amrho94/tenaaaaaauhhhohfuck'
                local branch=shared.TenacityBranch or 'main'
                assert(loadstring(game:HttpGet(('https://raw.githubusercontent.com/%s/%s/loader.lua'):format(repo,branch),true),'@Tenacity/loader.lua'))()
            end
        ]]
        teleportScript='shared.TenacityRepository='..string.format('%q',runtime.Repo)..'\nshared.TenacityBranch='..string.format('%q',runtime.Branch)..'\n'..teleportScript
        if shared.TenacityDeveloper then teleportScript='shared.TenacityDeveloper=true\n'..teleportScript end
        if shared.TenacityCustomProfile then teleportScript='shared.TenacityCustomProfile='..string.format('%q',shared.TenacityCustomProfile)..'\n'..teleportScript end
        queue_on_teleport(teleportScript)
    end))

    if not shared.TenacityReload and core.Settings.GUI.Options['GUI bind indicator'].Enabled then
        local bind=core.GUIBind and table.concat(core.GUIBind.Keys,' + '):upper() or 'RSHIFT'
        core:CreateNotification('Tenacity','Ready — '..bind..' opens the workspace.',5)
    end
end

loading:SetLoadingProgress(.48,'Registering modules')
if not shared.TenacityIndependent then
    compile(read('tenacity/games/universal.lua'),'@tenacity/games/universal.lua')()
    local gamePath='tenacity/games/'..game.PlaceId..'.lua'
    if not shared.TenacityDeveloper or isfile(gamePath) then
        local ok,source=pcall(read,gamePath,nil,true)
        if ok and source then
            compile(source,'@'..gamePath)(...)
        elseif not ok then
            warn('[Tenacity] No game integration for '..tostring(game.PlaceId)..'; using Universal.')
        end
    end
    finish()
else
    core.Init=finish
    return core
end
