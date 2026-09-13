-- Set TenacityRepository and TenacityBranch before loading to use a fork.
if shared.TenacityBooting then return end
shared.TenacityBooting = true
shared.TenacityRepository = shared.TenacityRepository or 'amrho94/tenaaaaaauhhhohfuck'

local previous = shared.Tenacity
-- Catch the previous in-session build during migration.
if not previous then
    for _, candidate in shared do
        if type(candidate) == 'table' and type(candidate.Uninject) == 'function'
            and tostring(candidate.Build or ''):find('tenacity-ui', 1, true) then
            previous = candidate
            pcall(function() candidate:Uninject() end)
            break
        end
    end
end
local hotReload = shared.TenacitySessionBooted == true or previous ~= nil
shared.TenacitySessionBooted = true

if hotReload then
    shared.TenacityReload = true
    if not shared.TenacityDeveloper then
        shared.TenacityRefresh = true
    end
end
local function boot()
    assert(type(readfile)=='function' and type(writefile)=='function' and type(makefolder)=='function',
        'Tenacity requires executor filesystem support.')

    for _, path in ipairs({
        'tenacity', 'tenacity/assets', 'tenacity/assets/new', 'tenacity/assets/tenacity', 'tenacity/games', 'tenacity/guis',
        'tenacity/libraries', 'tenacity/profiles', 'tenacity/additions', 'tenacity/additions/configs'
    }) do pcall(makefolder, path) end

    local cacheRevision='tenacity-ui-r2'
    local marker='tenacity/profiles/cache-revision.txt'
    local markerOK,current=pcall(readfile,marker)
    local refreshForRevision=not markerOK or current~=cacheRevision
    if refreshForRevision and not shared.TenacityDeveloper then shared.TenacityRefresh=true end

    local runtimePath='tenacity/libraries/runtime.lua'
    local cachedOK,cachedSource=pcall(readfile,runtimePath)
    local cachedChunk=cachedOK and type(cachedSource)=='string' and loadstring(cachedSource,'@'..runtimePath)
    local source,chunk

    if (hotReload or refreshForRevision or shared.TenacityRefresh==true) and not shared.TenacityDeveloper then
        local repo=shared.TenacityRepository or 'amrho94/tenaaaaaauhhhohfuck'
        local branch=shared.TenacityBranch or 'main'
        local fetched,body=pcall(game.HttpGet,game,('https://raw.githubusercontent.com/%s/%s/libraries/runtime.lua'):format(repo,branch),true)
        if fetched and type(body)=='string' and #body>0 then
            local remoteChunk=loadstring(body,'@'..runtimePath)
            if remoteChunk then
                source=body
                chunk=remoteChunk
                pcall(writefile,runtimePath,body)
            end
        end
    end

    if not chunk then
        source=cachedSource
        chunk=cachedChunk
    end

    if not chunk then
        local repo=shared.TenacityRepository or 'amrho94/tenaaaaaauhhhohfuck'
        local branch=shared.TenacityBranch or 'main'
        source=game:HttpGet(('https://raw.githubusercontent.com/%s/%s/libraries/runtime.lua'):format(repo,branch),true)
        chunk=assert(loadstring(source,'@'..runtimePath))
        pcall(writefile,runtimePath,source)
    end

    local runtime=chunk()
    shared.TenacityRuntime=runtime
    pcall(writefile,'tenacity/profiles/commit.txt',runtime.Branch or 'main')

    if not game:IsLoaded() then game.Loaded:Wait() end
    assert(loadstring(runtime.Read('tenacity/main.lua'),'@tenacity/main.lua'))()
    if refreshForRevision then pcall(writefile,marker,cacheRevision) end
end

local ok, err=xpcall(boot,function(message)
    local trace='';pcall(function()trace=debug.traceback(nil,2)end)
    return tostring(message)..(trace~=''and('\n'..trace)or'')
end)

shared.TenacityBooting=nil
shared.TenacityRefresh=nil
if not ok then
    if shared.TenacityLoading then pcall(shared.TenacityLoading.HideLoadingScreen,shared.TenacityLoading,true) end
    local current=shared.Tenacity
    if current and current~=previous then pcall(function()current:Uninject()end)end
    error('[Tenacity] Startup failed: '..tostring(err),0)
end
