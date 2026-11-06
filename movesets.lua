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

function limit_angle(a)
	return (a + 0x8000) % 0x10000 - 0x8000
end

local function HSV_to_RGB(h, s, v)
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    local r, g, b
    i = i % 6
    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    else r, g, b = v, p, q end
    return {r = math.floor(r * 255 + 0.5), g = math.floor(g * 255 + 0.5), b = math.floor(b * 255 + 0.5)}
end

ACT_LUNKY_CYCLONE = allocate_mario_action(ACT_FLAG_MOVING | ACT_FLAG_ATTACKING)

function act_lunky_cyclone(m)
	if (m == nil) then return 0 end

	-- Argument variables

    smlua_anim_util_set_animation(m.marioObj, "evilswag_moveset_anim_tornado")
    m.marioObj.header.gfx.animInfo.animAccel = 32768 * 3

	-- Animation
    if m.actionTimer == 0 then
        m.faceAngle.y = m.intendedYaw
        if m.input & INPUT_NONZERO_ANALOG ~= 0 then
            m.forwardVel = 5
        end
    elseif m.actionTimer < 17.5 then
        m.faceAngle.y = approach_s16_symmetric(m.faceAngle.y, m.intendedYaw, 0x200)

        if m.actionTimer <= 10 then
            if (m.actionTimer % 3) == 0 then
                play_sound(SOUND_ACTION_TWIRL, m.marioObj.header.gfx.cameraToObject)
            end
        elseif m.actionTimer == 13.5 then
            play_sound_with_freq_scale(SOUND_ACTION_TWIRL, m.marioObj.header.gfx.cameraToObject, 0.8)
        end
    end

    if m.actionTimer < 15 then
        m.marioBodyState.eyeState = MARIO_EYES_CLOSED
    elseif m.actionTimer < 20 then
        m.marioBodyState.eyeState = MARIO_EYES_OPEN
    end

    if (m.input & INPUT_NONZERO_ANALOG) ~= 0 then
        mario_set_forward_vel(m, math.abs(m.forwardVel))
    end
	
	local stepResult = perform_ground_step(m)

	apply_slope_accel(m)
	m.faceAngle.y = m.intendedYaw - approach_s32(limit_angle(m.intendedYaw - m.faceAngle.y), 0, 0x250, 0x250)
	
	if stepResult == GROUND_STEP_HIT_WALL then
		if m.wall ~= nil and m.wall.object ~= nil and (m.wall.object.oInteractType == INTERACT_DOOR or m.wall.object.oInteractType == INTERACT_WARP_DOOR) then return end
	end
	
	if (should_begin_sliding(m) ~= 0) then
		return set_mario_action(m, ACT_BEGIN_SLIDING, 0);
	end

    if m.actionTimer < 10 then
        if m.actionTimer > -1 then
            m.particleFlags = m.particleFlags | PARTICLE_DUST
            m.vel.y = 18 - (m.actionTimer * (m.forwardVel/25))
        end
    else
        m.vel.y = m.vel.y + 3
    end

	m.actionTimer = m.actionTimer + 1

    if m.actionTimer > 20 then
        set_mario_action(m, ACT_FREEFALL_LAND_STOP, 1)
    end

    return 0
end

hook_mario_action(ACT_LUNKY_CYCLONE, act_lunky_cyclone, INT_KICK)


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
        starHue = starHue + 0.07
        if starHue > 1 then
            starHue = 0
        end
        network_player_set_override_palette_color(gNetworkPlayers[m.playerIndex], CAP, HSV_to_RGB(starHue, 1, 1))
        network_player_set_override_palette_color(gNetworkPlayers[m.playerIndex], PANTS, HSV_to_RGB(starHue, 1, 1))

        if m.action == ACT_WALKING and m.forwardVel < 60 and m.forwardVel > 0 then
            m.forwardVel = m.forwardVel * 1.15
        end
        if m.action == ACT_WALKING then
            m.marioBodyState.torsoAngle.x = 0
            smlua_anim_util_set_animation(m.marioObj, "lunky_star_running")
            m.marioObj.header.gfx.animInfo.animAccel = 32768 * 15
            m.marioBodyState.handState = MARIO_HAND_OPEN
        end
        m.particleFlags = m.particleFlags | PARTICLE_SPARKLES
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
    if m.action == ACT_SPECIAL_TRIPLE_JUMP and m.pos.y == m.floorHeight and m.vel.y < 0 then
        set_mario_action(m, ACT_FREEFALL_LAND, 0)
    end
end

