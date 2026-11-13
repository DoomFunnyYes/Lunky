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

local function render_number(num, x, y, full) -- 'full' is the maximum amount. If the number is equal to or higher, it will be orange.
	local text = tostring(num)
	local col = 0
	if num < full then col = 8 end
	for i = 1, #text do
		local number = tonumber(text:sub(i,i))
		if number == nil then return end
		djui_hud_render_texture_tile(TEX_LUNKY_NUMBERS, x + ((i-1) * (8)), y, 1, 1, number*8, col, 8, 8)
	end
end

local function render_box(num, x, y, sizeX, sizeY)
	if num < 10 then
		djui_hud_render_texture(TEX_LUNKY_LIVES_FOREGROUND1, x, y, sizeX, sizeY)
	elseif num < 100 then
		djui_hud_render_texture(TEX_LUNKY_LIVES_FOREGROUND2, x, y, sizeX, sizeY)
	else
		djui_hud_render_texture(TEX_LUNKY_LIVES_FOREGROUND3, x, y, sizeX, sizeY)
	end
end

function lunky_health_hud()
    hud_hide()
    djui_hud_set_resolution(RESOLUTION_N64)
    local scWidth = djui_hud_get_screen_width()
    local m = gMarioStates[0]
	local e = gStateExtras[m.playerIndex]
    local health = math.ceil((m.health - 256)/256)
    local lives = (hud_get_value(HUD_DISPLAY_LIVES))
    local stars = (hud_get_value(HUD_DISPLAY_STARS))
    local coins = (hud_get_value(HUD_DISPLAY_COINS))
    local valueShift = {0,0}
    local powerUp = 0
    local x = 9
    local y = 9
    local x2 = scWidth - 72
	
	-- Shift the position of the numbers based on values, 'cuz it looks nicer
	
	if coins < 10 then
        valueShift[1] = 31
    elseif coins < 100 then
        valueShift[1] = 23
    else
        valueShift[1] = 14
    end

    if stars < 10 then
        valueShift[2] = 31
    elseif stars < 100 then
        valueShift[2] = 23
    else
        valueShift[2] = 14
    end
	
	-- HEALTH AND LIVES
	if hud_get_value(HUD_DISPLAY_FLAGS) & HUD_DISPLAY_FLAG_CAMERA_AND_POWER ~= 0 then
		djui_hud_render_texture(TEX_LUNKY_HEALTH_BACKGROUND, x, y, 1, 1)

		if m.flags & MARIO_METAL_CAP ~= 0 then
			powerUp = 32
			djui_hud_set_color((starColor.r), starColor.g, starColor.b, 255) -- fourth input is alpha
			--render the tile here
		elseif e.fireform ~= 0 then
			powerUp = 16
		else
			powerUp = 0
		end

		if health > 4 then
			djui_hud_render_texture_tile(TEX_LUNKY_POWERUPS, x + 4, y + 4, 1, 1, powerUp, 0, 16, 16)
		end
		
		djui_hud_set_color(255,255,255,255) -- reset the color afterwards
		render_number(health, x + 38, y + 11, 8) -- Health
		render_number(8, x + 58, y + 11, 16-health) -- Full health (8)
		djui_hud_render_texture(TEX_LUNKY_HEALTH_FOREGROUND, x, y, 1, 1)
		
		djui_hud_render_texture(TEX_LUNKY_LIVES_BACKGROUND, x, y + 25, 1, 1)
		render_box(lives, x, y + 25, 1, 1)
		render_number(lives, x + 25, y +36, 99)
	end
	
	-- STARS
	if hud_get_value(HUD_DISPLAY_FLAGS) & HUD_DISPLAY_FLAG_STAR_COUNT ~= 0 then
		djui_hud_render_texture(TEX_LUNKY_STAR_BACKGROUND, x2, y, 1, 1)
		render_box(stars, x2 + 64, y, -1, 1)
		render_number(stars, x2 + valueShift[2], y + 11, 120)
	end
	
	-- COINS
	if hud_get_value(HUD_DISPLAY_FLAGS) & HUD_DISPLAY_FLAG_COIN_COUNT ~= 0 then
		djui_hud_render_texture(TEX_LUNKY_COIN_BACKGROUND, x2, y + 25, 1, 1)
		render_box(coins, x2 + 64, y + 25, -1, 1)
		render_number(coins, x2 + valueShift[1], y + 36, 999)
	end
end

_G.charSelect.character_hook_moveset(CT_LUNKY, HOOK_ON_HUD_RENDER_BEHIND, lunky_health_hud)