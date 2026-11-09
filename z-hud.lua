TEX_LUNKY_HEALTH_FOREGROUND = get_texture_info("lunky_health_foreground")
TEX_LUNKY_HEALTH_BACKGROUND = get_texture_info("lunky_health_background")
TEX_LUNKY_NUMBERS = get_texture_info("lunky_hud_numbers")
TEX_LUNKY_POWERUPS = get_texture_info("lunky_powerups")

function lunky_health_hud()
    djui_hud_set_resolution(RESOLUTION_N64)
    local scWidth = djui_hud_get_screen_width()
    local m = gMarioStates[0]
    local health = math.ceil((m.health - 256)/256)
    local x = 9
    local y = 9
    djui_hud_render_texture(TEX_LUNKY_HEALTH_BACKGROUND, x, y, 1, 1)
    djui_hud_render_texture_tile(TEX_LUNKY_POWERUPS, x + 4, y + 4, 1, 1, 0, 0, 16, 16)
    djui_hud_render_texture_tile(TEX_LUNKY_NUMBERS, x + 38, y + 11, 1, 1, 0, 0, 8, 8)
    djui_hud_render_texture_tile(TEX_LUNKY_NUMBERS, x + 58, y + 11, 1, 1, 70, 0, 8, 8)
    djui_hud_render_texture(TEX_LUNKY_HEALTH_FOREGROUND, x, y, 1, 1)
end

_G.charSelect.character_hook_moveset(CT_LUNKY, HOOK_ON_HUD_RENDER_BEHIND, lunky_health_hud)