--- Menu module
--- @param settings Settings settings
--- @param awful awful module
--- @param hotkeys_popup hotkeys_popup popup module
--- @return table menu menu functions
local function myawesomemenu(settings, awful, hotkeys_popup)
    return {
        { "Hotkeys",     function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
        { "Manual",      settings.terminal .. " -e man awesome" },
        { "Edit Config", settings.editor_cmd .. " " .. awesome.conffile },
        { "Restart",     awesome.restart },
        { "Quit",        function() awesome.quit() end },
    }
end

--- Main menu
--- @param settings Settings settings
--- @param awful awful module
--- @param beautiful beautiful module
--- @param myawesomemenu table myawesomemenu menu functions
--- @return table menu menu functions
local function mymainmenu(settings, awful, beautiful, myawesomemenu)
    return awful.menu({
        items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
            { "Open Terminal", settings.terminal }
        }
    })
end

local function mylauncher(awful, beautiful, mymainmenu)
    return awful.widget.launcher({
        image = beautiful.awesome_icon,
        menu = mymainmenu
    })
end

return {
    myawesomemenu = myawesomemenu,
    mymainmenu = mymainmenu,
    mylauncher = mylauncher,
}
