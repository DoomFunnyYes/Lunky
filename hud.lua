TEX_LUNKY_HEALTH_FOREGROUND = get_texture_info("lunky_health_foreground")
TEX_LUNKY_HEALTH_BACKGROUND = get_texture_info("lunky_health_background")
TEX_LUNKY_NUMBERS = get_texture_info("lunky_hud_numbers")
TEX_LUNKY_POWERUPS = get_texture_info("lunky_powerups")

function lunky_health_hud()
    djui_hud_set_resolution(RESOLUTION_N64)
    local scWidth = djui_hud_get_screen_width()
    local m = gMarioStates[0]
    local health = math.ceil((m.health - 256)/256)
    local x = 4
    local y = 4
    djui_hud_render_texture(TEX_LUNKY_HEALTH_BACKGROUND, x, y, 1, 1)
    djui_hud_render_texture(TEX_LUNKY_HEALTH_FOREGROUND, x, y, 1, 1)
end

hook_event(HOOK_ON_HUD_RENDER_BEHIND, function()
    lunky_health_hud()
end)