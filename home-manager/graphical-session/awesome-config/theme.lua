local gears = require("gears")
local lain = require("lain")
local awful = require("awful")
local wibox = require("wibox")
local dpi = require("beautiful.xresources").apply_dpi

local font_size = "9"
local base_font = "Fira Sans"
local theme = {}
theme.dir = os.getenv("HOME") .. "/.config/awesome/"
theme.wallpaper = theme.dir .. "/cx_sunset.jpg"
theme.font = base_font .. " " .. font_size
theme.fg_normal = "#BBBBBB"
theme.fg_focus = "#78A4FF"
theme.bg_normal = "#111111"
theme.bg_focus = "#111111"
theme.fg_urgent = "#000000"
theme.bg_urgent = "#FFFFFF"
theme.border_width = dpi(1)
theme.border_normal = "#141414"
theme.border_focus = "#93B6FF"
theme.taglist_fg_focus = "#FFFFFF"
theme.taglist_bg_focus = "#111111"
theme.taglist_bg_normal = "#111111"
theme.titlebar_bg_normal = "#191919"
theme.titlebar_bg_focus = "#262626"
theme.systray_icon_spacing = dpi(3)
theme.menu_height = dpi(16)
theme.menu_width = dpi(130)
theme.tasklist_disable_icon = true
theme.awesome_icon = theme.dir .. "/icons/awesome.png"
theme.menu_submenu_icon = theme.dir .. "/icons/submenu.png"
theme.taglist_squares_sel = theme.dir .. "/icons/square_unsel.png"
theme.taglist_squares_unsel = theme.dir .. "/icons/square_unsel.png"
theme.vol = theme.dir .. "/icons/vol.png"
theme.vol_low = theme.dir .. "/icons/vol_low.png"
theme.vol_no = theme.dir .. "/icons/vol_no.png"
theme.vol_mute = theme.dir .. "/icons/vol_mute.png"
theme.disk = theme.dir .. "/icons/disk.png"
theme.ac = theme.dir .. "/icons/ac.png"
theme.bat = theme.dir .. "/icons/bat.png"
theme.bat_low = theme.dir .. "/icons/bat_low.png"
theme.bat_no = theme.dir .. "/icons/bat_no.png"
theme.play = theme.dir .. "/icons/play.png"
theme.pause = theme.dir .. "/icons/pause.png"
theme.stop = theme.dir .. "/icons/stop.png"
theme.layout_tile = theme.dir .. "/icons/tile.png"
theme.layout_tileleft = theme.dir .. "/icons/tileleft.png"
theme.layout_tilebottom = theme.dir .. "/icons/tilebottom.png"
theme.layout_tiletop = theme.dir .. "/icons/tiletop.png"
theme.layout_fairv = theme.dir .. "/icons/fairv.png"
theme.layout_fairh = theme.dir .. "/icons/fairh.png"
theme.layout_spiral = theme.dir .. "/icons/spiral.png"
theme.layout_dwindle = theme.dir .. "/icons/dwindle.png"
theme.layout_max = theme.dir .. "/icons/max.png"
theme.layout_fullscreen = theme.dir .. "/icons/fullscreen.png"
theme.layout_magnifier = theme.dir .. "/icons/magnifier.png"
theme.layout_floating = theme.dir .. "/icons/floating.png"
theme.useless_gap = 0
theme.titlebar_close_button_focus = theme.dir .. "/icons/titlebar/close_focus.png"
theme.titlebar_close_button_normal = theme.dir .. "/icons/titlebar/close_normal.png"
theme.titlebar_ontop_button_focus_active = theme.dir .. "/icons/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active = theme.dir .. "/icons/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive = theme.dir .. "/icons/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive = theme.dir .. "/icons/titlebar/ontop_normal_inactive.png"
theme.titlebar_sticky_button_focus_active = theme.dir .. "/icons/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active = theme.dir .. "/icons/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive = theme.dir .. "/icons/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive = theme.dir .. "/icons/titlebar/sticky_normal_inactive.png"
theme.titlebar_floating_button_focus_active = theme.dir .. "/icons/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active = theme.dir .. "/icons/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive = theme.dir .. "/icons/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive = theme.dir .. "/icons/titlebar/floating_normal_inactive.png"
theme.titlebar_maximized_button_focus_active = theme.dir .. "/icons/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active = theme.dir .. "/icons/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive = theme.dir .. "/icons/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = theme.dir .. "/icons/titlebar/maximized_normal_inactive.png"

-- lain related
theme.layout_centerfair = theme.dir .. "/icons/centerfair.png"
theme.layout_termfair = theme.dir .. "/icons/termfair.png"
theme.layout_centerwork = theme.dir .. "/icons/centerwork.png"

function run_cmd(cmd)
  return io.popen(cmd):read("*all"):match("^%s*(.-)%s*$")
end

local markup = lain.util.markup
local blue = theme.fg_focus
local red = "#EB8F8F"
local green = "#8FEB8F"
local yellow = "#F8ED62"
local teal = "#008080"
local mono_font = "Fira Mono"

local spr_color = "#777777"
local small_spr_raw = markup.font(mono_font .. " Bold 4", " ")
local small_spr = wibox.widget.textbox(small_spr_raw)
local bar_spr_raw = small_spr_raw .. markup.fontfg(
  mono_font .. " " .. font_size,
  spr_color,
  "|"
) .. small_spr_raw
local bar_spr = wibox.widget.textbox(bar_spr_raw)

clock_font = mono_font .. " Bold " .. font_size
local myclock = wibox.widget.textclock(
  markup.fontfg(clock_font, yellow, "%d %b %Y ") .. markup.fontfg(
    clock_font,
    green,
    "%H:%M:%S"
  ),
  0.1
)

hostname = wibox.widget.textbox(markup.font(mono_font .. " Bold " .. font_size, run_cmd("hostname")))

theme.cal = lain.widget.cal({
  attach_to = {myclock},
  week_start = 1,
  three = true,
  notification_preset = {
    font = mono_font .. " " .. font_size,
    fg = theme.fg_normal,
    bg = theme.bg_normal,
    timeout = 7,
  },
})

local mpdicon = wibox.widget.imagebox()
theme.mpd = lain.widget.mpd({
  timeout = 0.1,
  settings = function()
    if mpd_now.state == "play" or mpd_now.state == "pause" then
      title = mpd_now.title
      artist = " " .. mpd_now.artist
      if mpd_now.state == "play" then
        mpdicon:set_image(theme.play)
      else
        mpdicon:set_image(theme.pause)
      end
    else
      title = ""
      artist = "none"
      mpdicon:set_image(theme.stop)
    end
    title = markup.fontfg(base_font .. " Bold " .. font_size, blue, title)
    artist = markup.font(base_font .. " Italic " .. font_size, artist)
    widget:set_markup(title .. artist)
  end,
})

-- Battery
local arc_symbolic = os.getenv("HOME") .. "/.nix-profile/share/icons/Arc/status/symbolic"
local bat_group = nil
local battery_widget = require("awesome-wm-widgets.battery-widget.battery")
local my_battery_widget = battery_widget {
  path_to_icons = arc_symbolic .. "/",
  show_current_level = true,
  display_notification = true,
  font = mono_font .. " " .. font_size
}
if run_cmd("ls -1 /sys/class/power_supply") ~= "" then
  bat_group = {
    layout = wibox.layout.fixed.horizontal,
    bar_spr,
    my_battery_widget,
  }
end

local cpu_widget = require("awesome-wm-widgets.cpu-widget.cpu-widget")
local my_cpu_widget = cpu_widget({width = 70, step_width = 2, step_spacing = 0, color = '#434c5e'})
local ram_widget = require("awesome-wm-widgets.ram-widget.ram-widget")
local my_ram_widget = ram_widget()
local brightness_widget = require("awesome-wm-widgets.brightnessarc-widget.brightnessarc")
theme.brightness_widget = brightness_widget({path_to_icon = arc_symbolic .. "/display-brightness-symbolic.svg"})

local orig_filter = awful.widget.taglist.filter.all
awful.widget.taglist.filter.all = function(t, args)
  if t.selected or #t:clients() > 0 then
    return orig_filter(t, args)
  end
end

function theme.at_screen_connect(s)
  local wallpaper = theme.wallpaper
  if type(wallpaper) == "function" then
    wallpaper = wallpaper(s)
  end
  gears.wallpaper.maximized(wallpaper, s, false)

  awful.tag(awful.util.tagnames, s, awful.layout.layouts)

  -- Create a promptbox for each screen
  s.mypromptbox = awful.widget.prompt({font = mono_font .. " " .. font_size, prompt = "run: "})
  s.mylayoutbox = awful.widget.layoutbox(s)
  s.mylayoutbox:buttons(gears.table.join(
    awful.button({}, 1, function()
      awful.layout.inc(1)
    end),
    awful.button({}, 2, function()
      awful.layout.set(awful.layout.layouts[1])
    end),
    awful.button({}, 3, function()
      awful.layout.inc(-1)
    end),
    awful.button({}, 4, function()
      awful.layout.inc(1)
    end),
    awful.button({}, 5, function()
      awful.layout.inc(-1)
    end)
  ))

  s.mytaglist = awful.widget.taglist(
    s,
    awful.widget.taglist.filter.all,
    awful.util.taglist_buttons
  )
  s.mytasklist = awful.widget.tasklist(
    s,
    awful.widget.tasklist.filter.currenttags,
    awful.util.tasklist_buttons
  )
  s.mywibox = awful.wibar {
    position = "top",
    screen = s,
    bg = theme.bg_normal,
    fg = theme.fg_normal
  }

  local systray_group = nil
  if s == screen.primary then
    systray_group = {
      layout = wibox.layout.fixed.horizontal,
      bar_spr,
      wibox.widget.systray()
    }
  end

  s.mywibox:setup {
    layout = wibox.layout.align.horizontal,
    {
      layout = wibox.layout.fixed.horizontal,
      small_spr,
      s.mylayoutbox,
      bar_spr,
      s.mytaglist,
      small_spr,
      s.mypromptbox,
    },
    s.mytasklist,
    {
      layout = wibox.layout.fixed.horizontal,
      mpdicon,
      theme.mpd.widget,
      systray_group,
      bat_group,
      bar_spr,
      theme.brightness_widget,
      bar_spr,
      my_cpu_widget,
      my_ram_widget,
      bar_spr,
      hostname,
      bar_spr,
      myclock,
      small_spr,
    },
  }
end

return theme
