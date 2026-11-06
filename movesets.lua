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
LUNKY_MISSILE_WEAK = audio_sample_load("lunky_missile_weak.ogg")
LUNKY_MISSILE_MEDIUM = audio_sample_load("lunky_missile_medium.ogg")
LUNKY_MISSILE_STRONG = audio_sample_load("lunky_missile_strong.ogg")
LUNKY_MISSILE_CHARGE = audio_sample_load("lunky_green_missile_charge.ogg")

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

gStateExtras = {}
for i = 0, (MAX_PLAYERS - 1) do
    gStateExtras[i] = {}
    local m = gMarioStates[i]
    local e = gStateExtras[i]

    e.forca = 0
    e.timer = 0
    e.rotAngle = 0
    e.saved_pos = {}
    e.saved_pos.x = 0
    e.saved_pos.y = 0
    e.saved_pos.z = 0
    e.saved_transition_timer = 0

end

ACT_WALL_STICK = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_MOVING | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)

function act_wall_stick(m)
    if (m.input & INPUT_A_PRESSED) ~= 0 then
        local rc = set_mario_action(m, ACT_WALL_KICK_AIR, 0)
        m.vel.y = 52.0

        if m.forwardVel < 30.0 then
            m.forwardVel = 30.0
        end
        m.wallKickTimer = 0
        return rc
    end

    -- attempt to stick to the wall a bit. if it's 0, sometimes you'll get kicked off of slightly sloped walls
    mario_set_forward_vel(m, -1.0)

    set_mario_animation(m, MARIO_ANIM_START_WALLKICK)
    m.marioBodyState.eyeState = MARIO_EYES_LOOK_RIGHT

    if perform_air_step(m, 0) == AIR_STEP_LANDED then
        mario_set_forward_vel(m, 0.0)
        if check_fall_damage_or_get_stuck(m, ACT_HARD_BACKWARD_GROUND_KB) == 0 then
            return set_mario_action(m, ACT_FREEFALL_LAND, 0)
        end
    end

    m.actionTimer = m.actionTimer + 1
    if m.wall == nil and m.actionTimer > 2 then
        mario_set_forward_vel(m, 0.0)
        return set_mario_action(m, ACT_FREEFALL, 0)
    end

    -- gravity
    if m.controller.stickMag == 64 then
        m.vel.y = m.vel.y + 2
        m.particleFlags = m.particleFlags | PARTICLE_DUST
        play_sound(SOUND_MOVING_TERRAIN_SLIDE + m.terrainSoundAddend, m.marioObj.header.gfx.cameraToObject)
    else
        m.vel.y = 0
    end

    return 0
end

hook_mario_action(ACT_WALL_STICK, act_wall_stick)

ACT_LUNKY_CYCLONE = allocate_mario_action(ACT_FLAG_MOVING | ACT_FLAG_ATTACKING)

function act_lunky_cyclone(m)
	if (m == nil) then return 0 end

	-- Argument variables

    smlua_anim_util_set_animation(m.marioObj, "lunky_cyclone")

	-- Animation
    if m.actionTimer == 0 then
        m.faceAngle.y = m.intendedYaw
        if m.input & INPUT_NONZERO_ANALOG ~= 0 then
            m.forwardVel = 5
        end
    elseif m.actionTimer < 35 then
        m.faceAngle.y = approach_s16_symmetric(m.faceAngle.y, m.intendedYaw, 0x200)

        if m.actionTimer <= 20 then
            if (m.actionTimer % 3) == 0 then
                play_sound(SOUND_ACTION_TWIRL, m.marioObj.header.gfx.cameraToObject)
            end
        elseif m.actionTimer == 27 then
            play_sound_with_freq_scale(SOUND_ACTION_TWIRL, m.marioObj.header.gfx.cameraToObject, 0.8)
        end
    end

    if m.actionTimer < 30 then
        m.marioBodyState.eyeState = MARIO_EYES_CLOSED
    elseif m.actionTimer < 40 then
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

    if m.actionTimer < 20 then
        if m.actionTimer > -1 then
            m.particleFlags = m.particleFlags | PARTICLE_DUST
            m.vel.y = 18 - (m.actionTimer * (m.forwardVel/25))
        end
    else
        m.vel.y = m.vel.y + 3
    end

	m.actionTimer = m.actionTimer + 1

    if m.actionTimer > 40 then
        set_mario_action(m, ACT_FREEFALL_LAND_STOP, 1)
    end

    return 0
end

hook_mario_action(ACT_LUNKY_CYCLONE, act_lunky_cyclone, INT_KICK)

ACT_LUNKY_MISSILE_FULL =         allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ATTACKING | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)

function act_lunky_missile_full(m)
    local arg = m.actionArg
    local e = gStateExtras[m.playerIndex]

    if arg == 2 then
        if m.actionTimer < 10 then -- for the first ten frames
            m.pos.y = m.pos.y + 75
        end
    else
        m.vel.y = 25 - m.actionTimer * 2
    end

	m.particleFlags = m.particleFlags | PARTICLE_DUST | PARTICLE_FIRE

	if m.actionTimer == 1 then
        if arg == 2 then
            return m.pos.y == (m.pos.y + 36 + e.forca)
        else
            mario_set_forward_vel(m, 36 + e.forca)
        end
		LUNKY_MISSILE_MAXIMUM = audio_sample_load("lunky_missile_maximum.ogg");
		audio_sample_play(LUNKY_MISSILE_MAXIMUM, gMarioStates[0].pos, 0.32);
		set_camera_shake_from_point(SHAKE_POS_MEDIUM, m.pos.x, m.pos.y, m.pos.z)
	    m.squishTimer = 1.33
		m.particleFlags = m.particleFlags | PARTICLE_VERTICAL_STAR
	else
        if arg == 2 then
            return m.pos.y == (m.pos.y - m.actonTimer / 32)
        else
	        mario_set_forward_vel(m, m.forwardVel - m.actionTimer / 32)
        end
	end

    if m.actionTimer > 64 then
        set_mario_action(m, ACT_FREEFALL, 0)
	end

	if m.forwardVel < 0 then
	    mario_set_forward_vel(m, 0)
	end

    local stepResult = perform_air_step(m, 0)
    if stepResult == AIR_STEP_LANDED then
	    set_mario_action(m, ACT_FORWARD_GROUND_KB, 0)
    elseif stepResult == AIR_STEP_HIT_WALL then
        set_mario_action(m, ACT_HARD_BACKWARD_AIR_KB, 0)
    end

    set_mario_animation(m, MARIO_ANIM_FLUTTERKICK)
    set_anim_to_frame(m, 7)

    m.actionTimer = m.actionTimer + 1
    return 0
end

hook_mario_action(ACT_LUNKY_MISSILE_FULL, act_lunky_missile_full, INT_KICK)

ACT_LUNKY_MISSILE = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ATTACKING | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)

function act_lunky_missile(m)
    local arg = m.actionArg
    local e = gStateExtras[m.playerIndex]

    if arg == 2 then
        if m.actionTimer < 10 then -- for the first ten frames
            m.pos.y = m.pos.y + 75
        end
    else
        m.vel.y = 25 - m.actionTimer * 2
    end

	m.particleFlags = m.particleFlags | PARTICLE_DUST

	if m.actionTimer == 1 then
        if arg == 2 then
            return m.pos.y == (m.pos.y + 36 + e.forca)
        else
            mario_set_forward_vel(m, 36 + e.forca)
        end
        if e.forca < 20 then
		    audio_sample_play(LUNKY_MISSILE_WEAK, gMarioStates[0].pos, 0.32);
        elseif e.forca < 30 then
            audio_sample_play(LUNKY_MISSILE_MEDIUM, gMarioStates[0].pos, 0.32);
        elseif e.forca > 29 then
            audio_sample_play(LUNKY_MISSILE_STRONG, gMarioStates[0].pos, 0.32);
        end
	else

        if arg == 2 then
            return m.pos.y == (m.pos.y - m.actonTimer / 32)
        else
	        mario_set_forward_vel(m, m.forwardVel - m.actionTimer / 32)
        end
	end

    if m.actionTimer > 64 then
        set_mario_action(m, ACT_FREEFALL, 0)
	end

	if m.forwardVel < 0 then
	    mario_set_forward_vel(m, 0)
	end

    local stepResult = perform_air_step(m, 0)
    if stepResult == AIR_STEP_LANDED then
	    set_mario_action(m, ACT_FORWARD_GROUND_KB, 0)
    elseif stepResult == AIR_STEP_HIT_WALL then
        set_mario_action(m, ACT_HARD_BACKWARD_AIR_KB, 0)
    end

    set_mario_animation(m, MARIO_ANIM_FLUTTERKICK)
    set_anim_to_frame(m, 7)

    m.actionTimer = m.actionTimer + 1
    return 0
end

hook_mario_action(ACT_LUNKY_MISSILE, act_lunky_missile, INT_KICK)

ACT_LUNKY_MISSILE_CHARGE = allocate_mario_action(ACT_FLAG_STATIONARY)

function act_lunky_missile_charge(m)
    local e = gStateExtras[m.playerIndex]

	m.particleFlags = m.particleFlags | PARTICLE_FIRE
    m.particleFlags = m.particleFlags | PARTICLE_WAVE_TRAIL

	if m.actionTimer % 7 == 0 and m.actionTimer < 42 then
	    m.particleFlags = m.particleFlags | PARTICLE_MIST_CIRCLE
          e.timer = 0
	end
    if m.actionTimer % 100 == 0 and m.actionTimer < 36 then
        audio_sample_play(LUNKY_MISSILE_CHARGE, gMarioStates[0].pos, 0.32)
    elseif m.actionTimer >= 53 then
        audio_sample_stop(LUNKY_MISSILE_CHARGE)
    end

	if m.actionTimer == 0 then
	    m.actionTimer = 1
		e.forca = 0
            e.timer = 0
	else
	    if m.forwardVel > 2 then
	        mario_set_forward_vel(m, m.forwardVel - 0.05 * (m.actionTimer / 2))
		else
		    mario_set_forward_vel(m, 2)
		end

		if e.forca < 72 then
		    e.forca = e.forca + 1
		end
	end

    if (m.controller.buttonDown & A_BUTTON) == 0 then
	    if m.actionTimer < 42 then
            audio_sample_stop(LUNKY_MISSILE_CHARGE)
            djui_chat_message_create("forca is "..tostring(e.forca))
            djui_chat_message_create("vel.Y is "..tostring(m.vel.y))
	        set_mario_action(m, ACT_LUNKY_MISSILE, m.actionArg)
		elseif m.actionTimer >= 42 then
            audio_sample_stop(LUNKY_MISSILE_CHARGE)
            djui_chat_message_create("forca is "..tostring(e.forca))
            djui_chat_message_create("vel.Y is "..tostring(m.vel.y))
		    set_mario_action(m, ACT_LUNKY_MISSILE_FULL, m.actionArg)
		end
	end
	if m.actionTimer > 52 then
		set_mario_action(m, ACT_SOFT_FORWARD_GROUND_KB, 0)
	end

	local stepResult = perform_ground_step(m)
    if stepResult == GROUND_STEP_HIT_WALL then
        set_mario_action(m, ACT_AIR_HIT_WALL, 0)
    end

	set_mario_animation(m, MARIO_ANIM_START_CROUCHING)
	set_anim_to_frame(m, 2)

    m.faceAngle.y = m.intendedYaw - approach_s32(convert_s16(m.intendedYaw - m.faceAngle.y), 0, 0x400, 0x400)

    m.actionTimer = m.actionTimer + 1
    e.timer = e.timer + 1
	return 0
end

hook_mario_action(ACT_LUNKY_MISSILE_CHARGE, act_lunky_missile_charge)

ACT_WALL_SLIDE = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_MOVING | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)

function convert_s16(num)
    local min = -32768
    local max = 32767
    while (num < min) do
        num = max + (num - min)
    end
    while (num > max) do
        num = min + (num - max)
    end
    return num
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

