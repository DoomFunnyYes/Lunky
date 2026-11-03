SHRINKING_SOUND = audio_sample_load("lunky_hurt.ogg")
GROWING_SOUND = audio_sample_load("lunky_grow.ogg")
LUNKY_JUMP = audio_sample_load("lunky_jump.ogg")
LUNKY_DOUBLE_JUMP = audio_sample_load("lunky_double_jump.ogg")
LUNKY_TRIPLE_JUMP = audio_sample_load("lunky_triple_jump.ogg")
LUNKY_LONG_JUMP = audio_sample_load("lunky_long_jump.ogg")
SMALL_LUNKY_JUMP = audio_sample_load("small_lunky_jump.ogg")
SMALL_LUNKY_DOUBLE_JUMP = audio_sample_load("small_lunky_double_jump.ogg")
SMALL_LUNKY_TRIPLE_JUMP = audio_sample_load("small_lunky_triple_jump.ogg")
SMALL_LUNKY_LONG_JUMP = audio_sample_load("small_lunky_long_jump.ogg")

local function find_HSL_hue(color)
	local R = color.r/255
	local G = color.g/255
	local B = color.b/255
	local cMax = math.max(R, G, B)
	local cMin = math.min(R, G, B)
	
	local tri = cMax - cMin
	
	local H = 0
	if (tri == 0) then
		return 0
	elseif (cMax == R) then
		H = 60 * (((G-B)/tri) % 6)
	elseif (cMax == G) then
		H = 60 * (((B-R)/tri) + 2)
	elseif (cMax == B) then
		H = 60 * (((R-G)/tri) + 4)
	end
	return H 
end

local function find_HSV_hue(color)
	return find_HSL_hue(color)
end

local function find_HSL_saturation(color)
	local cMax = math.max(color.r/255, color.g/255, color.b/255)
	local cMin = math.min(color.r/255, color.g/255, color.b/255)
	local tri = cMax - cMin
	if (tri == 0) then
		return 0
	end
	local lightness = (cMax + cMin)/2
	return 100*tri/(1-math.abs(2*lightness - 1))
end

local function find_HSV_saturation(color)
	local cMax = math.max(color.r/255, color.g/255, color.b/255)
	if (cMax == 0) then
		return 0
	end
	local cMin = math.min(color.r/255, color.g/255, color.b/255)
	return 100*(cMax-cMin)/cMax
end

local function find_HSL_lightness(color)
	local cMax = math.max(color.r/255, color.g/255, color.b/255)
	local cMin = math.min(color.r/255, color.g/255, color.b/255)
	local lightness = (cMax + cMin)/2
	return lightness
end

local function find_HSV_value(color)
	local cMax = math.max(color.r/255, color.g/255, color.b/255)
	local cMin = math.min(color.r/255, color.g/255, color.b/255)
	local lightness = (cMax + cMin)/2
	return cMax
end

local function HSL_to_RGB(H, saturation, L)
	local S = saturation/100
	local C = (1-math.abs(2*L-1))*S
	local X = C * (1 - math.abs((H/60) % 2 - 1))
	local m = L - C/2
	if (H < 60) then
		return {
		r = math.floor(255*(m + C)),
		g = math.floor(255*(m + X)),
		b = math.floor(255*(m + 0))
		}
	elseif (H < 120) then
		return {
		r = math.floor(255*(m + X)),
		g = math.floor(255*(m + C)),
		b = math.floor(255*(m + 0))
		}
	elseif (H < 180) then
		return {
		r = math.floor(255*(m + 0)),
		g = math.floor(255*(m + C)),
		b = math.floor(255*(m + X))
		}
	elseif (H < 240) then
		return {
		r = math.floor(255*(m + 0)),
		g = math.floor(255*(m + X)),
		b = math.floor(255*(m + C))
		}
	elseif (H < 300) then
		return {
		r = math.floor(255*(m + X)),
		g = math.floor(255*(m + 0)),
		b = math.floor(255*(m + C))
		}
	elseif (H < 360) then
		return {
		r = math.floor(255*(m + C)),
		g = math.floor(255*(m + 0)),
		b = math.floor(255*(m + X))
		}
	end
	return {r = 255, g = 255, b = 255}
end

local function HSV_to_RGB(H, saturation, V)
	local S = saturation/100
	local C = V * S
	local X = C * (1 - math.abs((H/60) % 2 - 1))
	local m = V - C
	if (H < 60) then
		return {
		r = math.floor(255*(m + C)),
		g = math.floor(255*(m + X)),
		b = math.floor(255*(m + 0))
		}
	elseif (H < 120) then
		return {
		r = math.floor(255*(m + X)),
		g = math.floor(255*(m + C)),
		b = math.floor(255*(m + 0))
		}
	elseif (H < 180) then
		return {
		r = math.floor(255*(m + 0)),
		g = math.floor(255*(m + C)),
		b = math.floor(255*(m + X))
		}
	elseif (H < 240) then
		return {
		r = math.floor(255*(m + 0)),
		g = math.floor(255*(m + X)),
		b = math.floor(255*(m + C))
		}
	elseif (H < 300) then
		return {
		r = math.floor(255*(m + X)),
		g = math.floor(255*(m + 0)),
		b = math.floor(255*(m + C))
		}
	elseif (H < 360) then
		return {
		r = math.floor(255*(m + C)),
		g = math.floor(255*(m + 0)),
		b = math.floor(255*(m + X))
		}
	end
	return {r = 255, g = 255, b = 255}
end

local starHue = 0

function lunky_update(m)
    if m.health <= (0x500) then
        m.marioObj.header.gfx.scale.y = 0.75
        m.marioObj.header.gfx.scale.x = 1
        m.marioObj.header.gfx.scale.z = 1
    else
        m.marioObj.header.gfx.scale.y = 1
        m.marioObj.header.gfx.scale.x = 1
        m.marioObj.header.gfx.scale.z = 1
    end
    if m.flags & MARIO_METAL_CAP ~= 0 then
        starHue = starHue + 48
        if starHue > 255 then
            starHue = 0
        end
        network_player_set_override_palette_color(gNetworkPlayers[0], CAP, HSV_to_RGB(starHue, 255, 255))

        if m.action == ACT_WALKING and m.forwardVel < 60 and m.forwardVel > 0 then
            m.forwardVel = m.forwardVel * 1.15
        end
        if m.action == ACT_WALKING then
            m.marioBodyState.torsoAngle.x = 0
            smlua_anim_util_set_animation(m.marioObj, "lunky_star_running")
            m.marioObj.header.gfx.animInfo.animAccel = 32768 * 15
            m.marioBodyState.handState = MARIO_HAND_OPEN
        end
    end
end

function lunky_on_set_action(m)
    if (m.action == ACT_JUMP or m.action == ACT_SIDE_FLIP or m.action == ACT_BACKFLIP or m.action == ACT_WALL_KICK_AIR or m.action == ACT_STEEP_JUMP or m.action == ACT_WATER_JUMP) then -- Should be self explanatory
        if m.health <= (0x500) then
            audio_sample_play(SMALL_LUNKY_JUMP, m.pos, 1)
        else
            audio_sample_play(LUNKY_JUMP, m.pos, 1)
        end
    end
    if (m.action == ACT_DOUBLE_JUMP) then -- Should be self explanatory
        if m.health <= (0x500) then
            audio_sample_play(SMALL_LUNKY_DOUBLE_JUMP, m.pos, 1)
        else
            audio_sample_play(LUNKY_DOUBLE_JUMP, m.pos, 1)
        end
    end
    if (m.action == ACT_TRIPLE_JUMP or m.action == ACT_SPECIAL_TRIPLE_JUMP) then -- Should be self explanatory
        if m.health <= (0x500) then
            audio_sample_play(SMALL_LUNKY_TRIPLE_JUMP, m.pos, 1)
        else
            audio_sample_play(LUNKY_TRIPLE_JUMP, m.pos, 1)
        end
    end
    if (m.action == ACT_LONG_JUMP) then -- Should be self explanatory
        if m.health <= (0x500) then
            audio_sample_play(SMALL_LUNKY_LONG_JUMP, m.pos, 1)
        else
            audio_sample_play(LUNKY_LONG_JUMP, m.pos, 1)
        end
    end
end

