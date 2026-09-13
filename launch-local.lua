-- Put the project files in tenacity/ before running this.
shared.TenacityDeveloper=true
shared.TenacityRefresh=false
local source=assert(readfile('tenacity/loader.lua'),'Missing tenacity/loader.lua')
return assert(loadstring(source,'@tenacity/loader.lua'))()
