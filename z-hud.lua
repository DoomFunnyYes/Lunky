TEX_LUNKY_HEALTH_FOREGROUND = get_texture_info("lunky_health_foreground")
TEX_LUNKY_HEALTH_BACKGROUND = get_texture_info("lunky_health_background")
TEX_LUNKY_LIVES_FOREGROUND1 = get_texture_info("lunky_lives_foreground1")
TEX_LUNKY_LIVES_FOREGROUND2 = get_texture_info("lunky_lives_foreground2")
TEX_LUNKY_LIVES_FOREGROUND3 = get_texture_info("lunky_lives_foreground3")
TEX_LUNKY_LIVES_BACKGROUND = get_texture_info("lunky_lives_background")
TEX_LUNKY_COIN_BACKGROUND = get_texture_info("lunky_coin_background")
TEX_LUNKY_STAR_BACKGROUND = get_texture_info("lunky_star_background")
TEX_LUNKY_NUMBERS = get_texture_info("lunky_hud_numbers")
TEX_LUNKY_CROWN = get_texture_info("lunky_hud_crown")
TEX_LUNKY_POWERUPS = get_texture_info("lunky_powerups")

function lunky_health_hud()
    hud_hide()
    djui_hud_set_resolution(RESOLUTION_N64)
    local scWidth = djui_hud_get_screen_width()
    local m = gMarioStates[0]
    local e = gStateExtras[m.playerIndex]
    local health = math.ceil((m.health - 256)/256)
    local tileY = 0
    local tileY2 = 0
    local tileY3 = 0
    local lives = (hud_get_value(HUD_DISPLAY_LIVES))
    local stars = (hud_get_value(HUD_DISPLAY_STARS))
    local coins = (hud_get_value(HUD_DISPLAY_COINS))
    if health < 8 then
        tileY = 8
    end
    if lives < 100 then
        tileY2 = 8
    end
    if stars < 120 then
        tileY3 = 8
    end
    local valueShift = 0
    local valueShift2 = 0
    local powerUp = 0
    local x = 9
    local y = 9
    local x2 = scWidth - 72

    if e.fireform ~= 0 then
        prevPowerUp = 16
    else
        prevPowerUp = 0
    end

    djui_hud_render_texture(TEX_LUNKY_HEALTH_BACKGROUND, x, y, 1, 1)

    if m.flags & MARIO_METAL_CAP ~= 0 then
        powerUp = 32
        djui_hud_set_color((starColor.r), starColor.g, starColor.b, 255) -- fourth input is alpha
        --render the tile here
    else
        powerUp = prevPowerUp
    end

    if health > 4 then
        djui_hud_render_texture_tile(TEX_LUNKY_POWERUPS, x + 4, y + 4, 1, 1, powerUp, 0, 16, 16)
    end
    
    djui_hud_set_color(255,255,255,255) -- reset the color afterwards
    djui_hud_render_texture_tile(TEX_LUNKY_NUMBERS, x + 38, y + 11, 1, 1, (health*8), tileY, 8, 8)
    djui_hud_render_texture_tile(TEX_LUNKY_NUMBERS, x + 58, y + 11, 1, 1, (8*8), tileY, 8, 8)
    djui_hud_render_texture(TEX_LUNKY_HEALTH_FOREGROUND, x, y, 1, 1)
    djui_hud_render_texture(TEX_LUNKY_LIVES_BACKGROUND, x, y + 25, 1, 1)

    if lives < 10 then
        djui_hud_render_texture(TEX_LUNKY_LIVES_FOREGROUND1, x, y + 25, 1, 1)
    elseif lives < 100 then
        djui_hud_render_texture(TEX_LUNKY_LIVES_FOREGROUND2, x, y + 25, 1, 1)
    else
        djui_hud_render_texture(TEX_LUNKY_LIVES_FOREGROUND3, x, y + 25, 1, 1)
    end

    if coins < 10 then
        valueShift = 31
    elseif coins < 100 then
        valueShift = 23
    else
        valueShift = 14
    end

    if stars < 10 then
        valueShift2 = 31
    elseif stars < 100 then
        valueShift2 = 23
    else
        valueShift2 = 14
    end

    lives = tostring(lives)
    for i = 1, #lives do
        local number = tonumber(lives:sub(i,i))
        if number == nil then return end
        djui_hud_render_texture_tile(TEX_LUNKY_NUMBERS, x + 25 + ((i-1) * (8)), y + 36, 1, 1, number*8, tileY2, 8, 8) -- you'll have to change the values up a little
    end

    djui_hud_render_texture(TEX_LUNKY_STAR_BACKGROUND, x2, y, 1, 1)

    if stars < 10 then
        djui_hud_render_texture(TEX_LUNKY_LIVES_FOREGROUND1, x2 + 64, y, -1, 1)
    elseif stars < 100 then
        djui_hud_render_texture(TEX_LUNKY_LIVES_FOREGROUND2, x2 + 64, y, -1, 1)
    else
        djui_hud_render_texture(TEX_LUNKY_LIVES_FOREGROUND3, x2 + 64, y, -1, 1)
    end

    stars = tostring(stars)
        for i = 1, #stars do
            local number = tonumber(stars:sub(i,i))
            if number == nil then return end
            djui_hud_render_texture_tile(TEX_LUNKY_NUMBERS, x2 + valueShift2 + ((i-1) * (8)), y + 11, 1, 1, number*8, tileY3, 8, 8) -- you'll have to change the values up a little
        end

    djui_hud_render_texture(TEX_LUNKY_COIN_BACKGROUND, x2, y + 25, 1, 1)

    if coins < 10 then
        djui_hud_render_texture(TEX_LUNKY_LIVES_FOREGROUND1, x2 + 64, y + 25, -1, 1)
    elseif coins < 100 then
        djui_hud_render_texture(TEX_LUNKY_LIVES_FOREGROUND2, x2 + 64, y + 25, -1, 1)
    else
        djui_hud_render_texture(TEX_LUNKY_LIVES_FOREGROUND3, x2 + 64, y + 25, -1, 1)
    end

    coins = tostring(coins)
    for i = 1, #coins do
        local number = tonumber(coins:sub(i,i))
        if number == nil then return end
        djui_hud_render_texture_tile(TEX_LUNKY_NUMBERS, x2 + valueShift + ((i-1) * (8)), y + 36, 1, 1, number*8, 8, 8, 8) -- you'll have to change the values up a little
    end
end

_G.charSelect.character_hook_moveset(CT_LUNKY, HOOK_ON_HUD_RENDER_BEHIND, lunky_health_hud)