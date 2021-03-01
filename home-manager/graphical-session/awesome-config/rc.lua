local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local lain = require("lain")
local hotkeys_popup = require("awful.hotkeys_popup").widget
require("awful.hotkeys_popup.keys")
local dpi = require("beautiful.xresources").apply_dpi

if awesome.startup_errors then
  naughty.notify({
    preset = naughty.config.presets.critical,
    title = "Oops, there were errors during startup!",
    text = awesome.startup_errors,
  })
end

do
  local in_error = false
  awesome.connect_signal("debug::error", function(err)
    if in_error then
      return
    end
    in_error = true

    naughty.notify({
      preset = naughty.config.presets.critical,
      title = "Oops, an error happened!",
      text = tostring(err),
    })
    in_error = false
  end)
end

local modkey = "Mod4"
local altkey = "Mod1"
local terminal = "konsole"
local cycle_prev = true

-- cycle trough all previous client or just the first -- https://github.com/lcpz/awesome-copycats/issues/274
local editor = os.getenv("EDITOR") or "vim"
local gui_editor = os.getenv("GUI_EDITOR") or "gvim"
local browser = os.getenv("BROWSER") or "chromium"
local scrlocker = "dm-tool lock"

awful.util.terminal = terminal
awful.util.tagnames = {}
for i = 1, 9 do
  awful.util.tagnames[#awful.util.tagnames + 1] = i
end

awful.layout.layouts = {
  awful.layout.suit.floating,
  awful.layout.suit.tile,
  awful.layout.suit.tile.left,
  awful.layout.suit.tile.bottom,
  awful.layout.suit.tile.top,

  -- awful.layout.suit.fair,
  -- awful.layout.suit.fair.horizontal,
  -- awful.layout.suit.spiral,
  -- awful.layout.suit.spiral.dwindle,
  -- awful.layout.suit.max,
  -- awful.layout.suit.max.fullscreen,
  -- awful.layout.suit.magnifier,
  -- awful.layout.suit.corner.nw,
  -- awful.layout.suit.corner.ne,
  -- awful.layout.suit.corner.sw,
  -- awful.layout.suit.corner.se,
  -- lain.layout.cascade,
  -- lain.layout.cascade.tile,
  -- lain.layout.centerwork,
  -- lain.layout.centerwork.horizontal,
  -- lain.layout.termfair,
  -- lain.layout.termfair.center,
}

awful.util.taglist_buttons = gears.table.join(
  awful.button({}, 1, function(t)
    t:view_only()
  end),
  awful.button({modkey}, 1, function(t)
    if client.focus then
      client.focus:move_to_tag(t)
    end
  end),
  awful.button({}, 3, awful.tag.viewtoggle),
  awful.button({modkey}, 3, function(t)
    if client.focus then
      client.focus:toggle_tag(t)
    end
  end),
  awful.button({}, 4, function(t)
    awful.tag.viewnext(t.screen)
  end),
  awful.button({}, 5, function(t)
    awful.tag.viewprev(t.screen)
  end)
)

awful.util.tasklist_buttons = gears.table.join(
  awful.button({}, 1, function(c)
    if c == client.focus then
      c.minimized = true
    else
      c.minimized = false
      if not c:isvisible() and c.first_tag then
        c.first_tag:view_only()
      end
      client.focus = c
      c:raise()
    end
  end),
  awful.button({}, 2, function(c)
    c:kill()
  end),
  awful.button({}, 3, function()
    local instance = nil

    return function()
      if instance and instance.wibox.visible then
        instance:hide()
        instance = nil
      else
        instance = awful.menu.clients({theme = {width = dpi(250)}})
      end
    end
  end),
  awful.button({}, 4, function()
    awful.client.focus.byidx(1)
  end),
  awful.button({}, 5, function()
    awful.client.focus.byidx(-1)
  end)
)

lain.layout.termfair.nmaster = 3
lain.layout.termfair.ncol = 1
lain.layout.termfair.center.nmaster = 3
lain.layout.termfair.center.ncol = 1
lain.layout.cascade.tile.offset_x = dpi(2)
lain.layout.cascade.tile.offset_y = dpi(32)
lain.layout.cascade.tile.extra_padding = dpi(5)
lain.layout.cascade.tile.nmaster = 5
lain.layout.cascade.tile.ncol = 2

beautiful.init(string.format("%s/.config/awesome/theme.lua", os.getenv("HOME")))

local myawesomemenu = {
  {
    "hotkeys",
    function()
      return false, hotkeys_popup.show_help
    end
  },
  {"manual", terminal .. " -e man awesome"},
  {
    "edit config",
    string.format("%s -e %s %s", terminal, editor, awesome.conffile)
  },
  {"restart", awesome.restart},
  {
    "quit",
    function()
      awesome.quit()
    end
  },
}

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", function(s)
  if beautiful.wallpaper then
    local wallpaper = beautiful.wallpaper

    -- If wallpaper is a function, call it with the screen
    if type(wallpaper) == "function" then
      wallpaper = wallpaper(s)
    end
    gears.wallpaper.maximized(wallpaper, s, true)
  end
end)

-- No borders when rearranging only 1 non-floating or maximized client
screen.connect_signal("arrange", function(s)
  local only_one = #s.tiled_clients == 1
  for _, c in pairs(s.clients) do
    if only_one and not c.floating or c.maximized then
      c.border_width = 0
    else
      c.border_width = beautiful.border_width
    end
  end
end)

-- Create a wibox for each screen and add it
awful.screen.connect_for_each_screen(function(s)
  beautiful.at_screen_connect(s)
end)

-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(awful.button({}, 4, awful.tag.viewnext), awful.button(
  {},
  5,
  awful.tag.viewprev
)))

-- }}}

local focus_direction_f = function(dir)
  return function()
    awful.client.focus.global_bydirection(dir)
    if client.focus then
      client.focus:raise()
    end
  end
end

local mpc_command = function(cmd)
  return function()
    os.execute("mpc " .. cmd)
    beautiful.mpd.update()
  end
end

globalkeys = gears.table.join(
  awful.key(
    {altkey, "Control"},
    "l",
    function()
      os.execute(scrlocker)
    end,
    {description = "lock screen", group = "hotkeys"}
  ),
  awful.key({modkey}, "s", hotkeys_popup.show_help, {
    description = "show help",
    group = "awesome"
  }),
  awful.key({modkey}, "Left", awful.tag.viewprev, {
    description = "view previous",
    group = "tag"
  }),
  awful.key({modkey}, "Right", awful.tag.viewnext, {
    description = "view next",
    group = "tag"
  }),
  awful.key({modkey}, "Escape", awful.tag.history.restore, {
    description = "go back",
    group = "tag"
  }),
  awful.key(
    {altkey},
    "Left",
    function()
      lain.util.tag_view_nonempty(-1)
    end,
    {description = "view  previous nonempty", group = "tag"}
  ),
  awful.key(
    {altkey},
    "Right",
    function()
      lain.util.tag_view_nonempty(1)
    end,
    {description = "view  previous nonempty", group = "tag"}
  ),
  awful.key(
    {altkey},
    "j",
    function()
      awful.client.focus.byidx(1)
    end,
    {description = "focus next by index", group = "client"}
  ),
  awful.key(
    {altkey},
    "k",
    function()
      awful.client.focus.byidx(-1)
    end,
    {description = "focus previous by index", group = "client"}
  ),
  awful.key({modkey}, "j", focus_direction_f("down"), {
    description = "focus down",
    group = "client"
  }),
  awful.key({modkey}, "k", focus_direction_f("up"), {
    description = "focus up",
    group = "client"
  }),
  awful.key({modkey}, "h", focus_direction_f("left"), {
    description = "focus left",
    group = "client"
  }),
  awful.key({modkey}, "l", focus_direction_f("right"), {
    description = "focus right",
    group = "client"
  }),
  awful.key(
    {modkey, "Shift"},
    "j",
    function()
      awful.client.swap.byidx(1)
    end,
    {description = "swap with next client by index", group = "client"}
  ),
  awful.key(
    {modkey, "Shift"},
    "k",
    function()
      awful.client.swap.byidx(-1)
    end,
    {description = "swap with previous client by index", group = "client"}
  ),
  awful.key(
    {modkey, "Control"},
    "j",
    function()
      awful.screen.focus_relative(1)
    end,
    {description = "focus the next screen", group = "screen"}
  ),
  awful.key(
    {modkey, "Control"},
    "k",
    function()
      awful.screen.focus_relative(-1)
    end,
    {description = "focus the previous screen", group = "screen"}
  ),
  awful.key({modkey}, "u", awful.client.urgent.jumpto, {
    description = "jump to urgent client",
    group = "client"
  }),
  awful.key(
    {modkey},
    "Tab",
    function()
      awful.client.focus.history.previous()
      if client.focus then
        client.focus:raise()
      end
    end,
    {description = "cycle with previous/go back", group = "client"}
  ),
  awful.key(
    {modkey, "Shift"},
    "Tab",
    function()
      awful.client.focus.byidx(1)
      if client.focus then
        client.focus:raise()
      end
    end,
    {description = "go forth", group = "client"}
  ),
  awful.key(
    {modkey},
    "b",
    function()
      local s = awful.screen.focused()
      s.mywibox.visible = not s.mywibox.visible
    end,
    {description = "toggle wibox", group = "awesome"}
  ),
  awful.key(
    {modkey, "Shift"},
    "n",
    function()
      lain.util.add_tag()
    end,
    {description = "add new tag", group = "tag"}
  ),
  awful.key(
    {modkey, "Shift"},
    "r",
    function()
      lain.util.rename_tag()
    end,
    {description = "rename tag", group = "tag"}
  ),
  awful.key(
    {modkey, "Shift"},
    "Left",
    function()
      lain.util.move_tag(-1)
    end,
    {description = "move tag to the left", group = "tag"}
  ),
  awful.key(
    {modkey, "Shift"},
    "Right",
    function()
      lain.util.move_tag(1)
    end,
    {description = "move tag to the right", group = "tag"}
  ),
  awful.key(
    {modkey, "Shift"},
    "d",
    function()
      lain.util.delete_tag()
    end,
    {description = "delete tag", group = "tag"}
  ),
  awful.key(
    {modkey},
    "Return",
    function()
      awful.spawn(terminal)
    end,
    {description = "open a terminal", group = "launcher"}
  ),
  awful.key({modkey, "Control"}, "r", awesome.restart, {
    description = "reload awesome",
    group = "awesome"
  }),
  awful.key({modkey, "Shift"}, "q", awesome.quit, {
    description = "quit awesome",
    group = "awesome"
  }),
  awful.key(
    {altkey, "Shift"},
    "l",
    function()
      awful.tag.incmwfact(0.05)
    end,
    {description = "increase master width factor", group = "layout"}
  ),
  awful.key(
    {altkey, "Shift"},
    "h",
    function()
      awful.tag.incmwfact(-0.05)
    end,
    {description = "decrease master width factor", group = "layout"}
  ),
  awful.key(
    {modkey, "Shift"},
    "h",
    function()
      awful.tag.incnmaster(1, nil, true)
    end,
    {description = "increase the number of master clients", group = "layout"}
  ),
  awful.key(
    {modkey, "Shift"},
    "l",
    function()
      awful.tag.incnmaster(-1, nil, true)
    end,
    {description = "decrease the number of master clients", group = "layout"}
  ),
  awful.key(
    {modkey, "Control"},
    "h",
    function()
      awful.tag.incncol(1, nil, true)
    end,
    {description = "increase the number of columns", group = "layout"}
  ),
  awful.key(
    {modkey, "Control"},
    "l",
    function()
      awful.tag.incncol(-1, nil, true)
    end,
    {description = "decrease the number of columns", group = "layout"}
  ),
  awful.key(
    {modkey},
    "space",
    function()
      awful.layout.inc(1)
    end,
    {description = "select next", group = "layout"}
  ),
  awful.key(
    {modkey, "Shift"},
    "space",
    function()
      awful.layout.inc(-1)
    end,
    {description = "select previous", group = "layout"}
  ),
  awful.key(
    {modkey, "Control"},
    "n",
    function()
      local c = awful.client.restore()
      if c then
        client.focus = c
        c:raise()
      end
    end,
    {description = "restore minimized", group = "client"}
  ),
  awful.key(
    {altkey},
    "c",
    function()
      if beautiful.cal then
        beautiful.cal.show()
      end
    end,
    {description = "show calendar", group = "widgets"}
  ),
  awful.key(
    {},
    "XF86MonBrightnessUp",
    function()
      beautiful.brightness_widget.inc_brightness()
    end,
    {description = "brightness +5%", group = "hotkeys"}
  ),
  awful.key(
    {},
    "XF86MonBrightnessDown",
    function()
      beautiful.brightness_widget.dec_brightness()
    end,
    {description = "brightness -5%", group = "hotkeys"}
  ),
  awful.key(
    {},
    "XF86AudioRaiseVolume",
    function()
      os.execute("pactl -- set-sink-volume @DEFAULT_SINK@ +5%")
    end,
    {description = "volume +5%", group = "hotkeys"}
  ),
  awful.key(
    {},
    "XF86AudioLowerVolume",
    function()
      os.execute("pactl -- set-sink-volume @DEFAULT_SINK@ -5%")
    end,
    {description = "volume -5%", group = "hotkeys"}
  ),
  awful.key(
    {},
    "XF86AudioMute",
    function()
      os.execute("pactl -- set-sink-mute @DEFAULT_SINK@ toggle")
    end,
    {description = "toggle mute", group = "hotkeys"}
  ),
  awful.key({altkey, "Control"}, "Up", mpc_command("toggle"), {
    description = "mpc toggle",
    group = "widgets"
  }),
  awful.key({altkey, "Control"}, "Down", mpc_command("stop"), {
    description = "mpc stop",
    group = "widgets"
  }),
  awful.key({altkey, "Control"}, "Left", mpc_command("perv"), {
    description = "mpc prev",
    group = "widgets"
  }),
  awful.key({altkey, "Control"}, "Right", mpc_command("next"), {
    description = "mpc next",
    group = "widgets"
  }),
  awful.key(
    {modkey},
    "q",
    function()
      awful.spawn(browser)
    end,
    {description = "run browser", group = "launcher"}
  ),
  awful.key(
    {modkey},
    "r",
    function()
      awful.screen.focused().mypromptbox:run()
    end,
    {description = "run prompt", group = "launcher"}
  ),
  awful.key(
    {modkey},
    "e",
    function()
      os.execute("splatmoji type")
    end,
    {description = "type emoji", group = "launcher"}
  ),
  awful.key(
    {modkey},
    "x",
    function()
      awful.prompt.run {
        prompt = "lua: ",
        textbox = awful.screen.focused().mypromptbox.widget,
        exe_callback = awful.util.eval,
        history_path = awful.util.get_cache_dir() .. "/history_eval",
      }
    end,
    {description = "lua execute prompt", group = "awesome"}
  )
)

clientkeys = gears.table.join(
  awful.key({altkey, "Shift"}, "m", lain.util.magnify_client, {
    description = "magnify client",
    group = "client"
  }),
  awful.key(
    {modkey},
    "f",
    function(c)
      c.fullscreen = not c.fullscreen
      c:raise()
    end,
    {description = "toggle fullscreen", group = "client"}
  ),
  awful.key(
    {modkey, "Shift"},
    "c",
    function(c)
      c:kill()
    end,
    {description = "close", group = "client"}
  ),
  awful.key({modkey, "Control"}, "space", awful.client.floating.toggle, {
    description = "toggle floating",
    group = "client"
  }),
  awful.key(
    {modkey, "Control"},
    "Return",
    function(c)
      c:swap(awful.client.getmaster())
    end,
    {description = "move to master", group = "client"}
  ),
  awful.key(
    {modkey},
    "o",
    function(c)
      c:move_to_screen()
    end,
    {description = "move to screen", group = "client"}
  ),
  awful.key(
    {modkey},
    "t",
    function(c)
      c.ontop = not c.ontop
    end,
    {description = "toggle keep on top", group = "client"}
  ),
  awful.key(
    {modkey},
    "n",
    function(c)
      c.minimized = true
    end,
    {description = "minimize", group = "client"}
  ),
  awful.key(
    {modkey},
    "m",
    function(c)
      c.maximized = not c.maximized
      c:raise()
    end,
    {description = "maximize", group = "client"}
  )
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i, v in pairs(awful.util.tagnames) do
  local key_code = "#" .. (v + 9)
  globalkeys = gears.table.join(
    globalkeys,
    awful.key(
      {modkey},
      key_code,
      function()
        local screen = awful.screen.focused()
        local tag = screen.tags[v]
        if tag then
          tag:view_only()
        end
      end,
      {description = "view tag #", group = "tag"}
    ),
    awful.key(
      {modkey, "Control"},
      key_code,
      function()
        local screen = awful.screen.focused()
        local tag = screen.tags[v]
        if tag then
          awful.tag.viewtoggle(tag)
        end
      end,
      {description = "toggle tag #", group = "tag"}
    ),
    awful.key(
      {modkey, "Shift"},
      key_code,
      function()
        if client.focus then
          local tag = client.focus.screen.tags[v]
          if tag then
            client.focus:move_to_tag(tag)
          end
        end
      end,
      {description = "move focused client to tag #", group = "tag"}
    ),
    awful.key(
      {modkey, "Control", "Shift"},
      key_code,
      function()
        if client.focus then
          local tag = client.focus.screen.tags[v]
          if tag then
            client.focus:toggle_tag(tag)
          end
        end
      end,
      {description = "toggle focused client on tag #", group = "tag"}
    )
  )
end

clientbuttons = gears.table.join(
  awful.button({}, 1, function(c)
    c:emit_signal("request::activate", "mouse_click", {raise = true})
  end),
  awful.button({modkey}, 1, function(c)
    c:emit_signal("request::activate", "mouse_click", {raise = true})
    awful.mouse.client.move(c)
  end),
  awful.button({modkey}, 3, function(c)
    c:emit_signal("request::activate", "mouse_click", {raise = true})
    awful.mouse.client.resize(c)
  end)
)

root.keys(globalkeys)

-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
  -- All clients will match this rule.
  {
    rule = {},
    properties = {
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = awful.client.focus.filter,
      raise = true,
      keys = clientkeys,
      buttons = clientbuttons,
      screen = awful.screen.preferred,
      placement = awful.placement.no_overlap + awful.placement.no_offscreen,
      size_hints_honor = false,
    },
  },
  {
    rule_any = {type = {"dialog", "normal"}},
    properties = {titlebars_enabled = false}
  },
  {rule = {instance = "konsole"}, properties = {maximized = false}},
  {
    rule = {instance = ".blueman-assistant-wrapped"},
    properties = {floating = true}
  },
  {
    rule = {instance = ".blueman-manager-wrapped"},
    properties = {floating = true}
  },
  {
    rule = {class = "Gimp", role = "gimp-image-window"},
    properties = {maximized = true}
  },
}

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
  if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
    awful.placement.no_offscreen(c)
  end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
  if beautiful.titlebar_fun then
    beautiful.titlebar_fun(c)
    return
  end

  -- buttons for the titlebar
  local buttons = gears.table.join(
    awful.button({}, 1, function()
      c:emit_signal("request::activate", "titlebar", {raise = true})
      awful.mouse.client.move(c)
    end),
    awful.button({}, 2, function()
      c:kill()
    end),
    awful.button({}, 3, function()
      c:emit_signal("request::activate", "titlebar", {raise = true})
      awful.mouse.client.resize(c)
    end)
  )

  awful.titlebar(c, {size = dpi(16)}):setup {
    {
      awful.titlebar.widget.iconwidget(c),
      buttons = buttons,
      layout = wibox.layout.fixed.horizontal,
    },
    {
      {
        align = "center",
        widget = awful.titlebar.widget.titlewidget(c),
      },
      buttons = buttons,
      layout = wibox.layout.flex.horizontal,
    },
    {
      awful.titlebar.widget.floatingbutton(c),
      awful.titlebar.widget.maximizedbutton(c),
      awful.titlebar.widget.stickybutton(c),
      awful.titlebar.widget.ontopbutton(c),
      awful.titlebar.widget.closebutton(c),
      layout = wibox.layout.fixed.horizontal(),
    },
    layout = wibox.layout.align.horizontal,
  }
end)

client.connect_signal("mouse::enter", function(c)
  c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c)
  c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
  c.border_color = beautiful.border_normal
end)
