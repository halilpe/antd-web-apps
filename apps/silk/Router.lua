
--define the class
Router = BaseObject:extends{class="Router",registry = {}}
function Router:setPath(path)
    self.path = path
end

function Router:initialize()
    self.routes = {}
end

--function Router:setArgs(args)
--    self.args = args
--end

--function Router:arg(name)
--    return self.args[name]
--end

function Router:infer(url)
    -- a controller is like this /a/b/c/d/e
    -- a is controller name
    -- b is action
    -- c,d,e is parameters
    -- if user dont provice the url, try to infer it
    -- from the REQUEST
    url = url or REQUEST.query.r
    url = std.trim(url,"/")
    local args = explode(url,"/")
    local data = {
        name = 'index',
        action = 'index',
        args = {}
    }
    if args and #args > 0 and args[1] ~= "" then
        data.name = args[1]
        if args[2] then data.action = args[2] end
        for i = 3, #args do table.insert( data.args, args[i] ) end
    end

    self:log('Controller: '..JSON.encode(data))
    -- find the controller class and init it
    local controller_name = firstToUpper(data.name).."Controller"
    local controller_path = self.path.."."..controller_name
    -- require the controller module
    -- ignore the error
    pcall(require, controller_path)
    --require(controller_path)
    if not _G[controller_name] then
        data.controller = NotfoundController:new{ registry = self.registry }
        data.args = {controller_name}
        data.action = "index"
        data.name = "notfound"
    else
        data.controller = _G[controller_name]:new{ registry = self.registry }
        if  not data.controller[data.action] then
            data.args = {data.action}
            data.action = "actionnotfound"
        end
    end
    return data
end


function Router:delegate()
    local views = {}
    local data = self:infer()
    views.__main__ = self:call(data)
    if not views.__main__ then return end
    -- get all visible routes
    local routes = self:visibleRoutes(data.name.."/"..data.action)
    for k, v in pairs(routes) do
        data = self:infer(v)
        views[k] = self:call(data)
    end
    -- now require the main page to put the view

    local fn, e = loadscript(VIEW_ROOT..DIR_SEP..self.registry.layout..DIR_SEP.."index.ls")
    html()
    if fn then
        local r,o = pcall(fn, views)
        if not r then
            self:error(o)
        end
    else
        self:error("The index page is not found for layout: "..self.registry.layout)
    end
end

function Router:visibleRoutes(url)
    local list = {}
    --self:log("comparing "..url)
    for k,v in pairs(self.routes) do
        if v.visibility == "ALL" then
            list[k] = v.url
        elseif v.visibility.routes then
            if v.visibility.shown == true or v.visibility.shown == nil then
                if v.visibility.routes[url] then
                    list[k] = v.url
                end
            else
                if not v.visibility.routes[url] then
                    list[k] = v.url
                end
            end
        end
    end
    return list
end

function Router:call(data)
    local obj = data.controller[data.action](data.controller,table.unpack(data.args))
    if obj then
        data.controller.template:setView(data.action, data.name)
        return data.controller.template
    else
        return false
    end
end

function Router:route(name, url, visibility)
    self.routes[name] = {
        url = std.trim(url,"/"),
        visibility = visibility
    }
end