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

--[[ACT_LUNKY_ANIM_SCALE = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_INVULNERABLE | ACT_FLAG_CUSTOM_ACTION)


local function lunky_anim_scale(m)
    local e = gPlayerSyncTable[m.playerIndex]

    if e.power_anim ~= 0 then
        m.action = m.action | ACT_FLAG_INVULNERABLE | ACT_FLAG_INTANGIBLE
    end

    if e.power_anim == 1 or e.power_anim == 2 or e.power_anim == 3 then
        e.anim_timer = e.anim_timer + 1
        if e.anim_timer == 1 then
            vec3f_copy(e.prev_pos, m.pos)
        end
        m.vel.x = 0
        m.vel.z = 0
        m.vel.y = 0
        m.forwardVel = 0
        if e.anim_timer >= 2 then
            vec3f_copy(m.pos, e.prev_pos)
        end
        if e.anim_timer > 25 then
            m.invincTimer = 50
        end
        if e.anim_timer > 30 then
            vec3f_copy(m.vel, e.prev_speed)
            m.forwardVel = e.prev_forward_speed
            e.anim_timer = 0
            e.power_anim = 0
        end
    end


    local powerchange = {
        3,
        2,
        3,
        2,
        2,
        3,
        2,
        3,
        3,
        2,
        1,
        2,
        2,
        1,
        2,
        1,
        1,
        1,
    }

    if e.power_anim == 1 then
        local modelFunctions = {
            (m.marioObj.header.gfx.scale.y == 1),
            (m.marioObj.header.gfx.scale.y == 0.875),
            (m.marioObj.header.gfx.scale.y == 0.75),
        }


        local idx = e.anim_timer // 2 % 18

    end
    if e.power_anim == 2 then
        local modelFunctions = {
            (m.marioObj.header.gfx.scale.y == 0.75),
            (m.marioObj.header.gfx.scale.y == 0.875),
            (m.marioObj.header.gfx.scale.y == 1)
        }


        local idx = e.anim_timer // 2 % 18

    end
end
hook_event(HOOK_MARIO_UPDATE, lunky_anim_scale)]]

function lunky_update(m)
    local e = gExtraStates[m.playerIndex]
    if m.health <= (0x500) then
        m.marioObj.header.gfx.scale.y = 0.75
        m.marioObj.header.gfx.scale.x = 1
        m.marioObj.header.gfx.scale.z = 1
    else
        m.marioObj.header.gfx.scale.y = 1
        m.marioObj.header.gfx.scale.x = 1
        m.marioObj.header.gfx.scale.z = 1
    end
    if m.flags & MARIO_METAL_CAP == 0 then
        return nil
    else
        if m.capTimer < 2 and m.capTimer > 0 then

            if m.action == ACT_WALKING then
                m.marioObj.header.gfx.animInfo.animID = -1
            end
            network_player_reset_override_palette(np)
        else
            if m.flags & MARIO_METAL_CAP ~= 0 then
                local rate = 85
                local max = 255 - rate
                local min = 0 + rate
                if e.playerR == 255 and m.playerG ~= 255 then
                    if m.playerB >= min then
                        m.playerB = m.playerB - rate
                    elseif m.playerG <= max then
                        m.playerG = m.playerG + rate
                    end
                elseif m.playerG == 255 and e.playerB ~= 255 then
                    if e.playerR >= min then
                        e.playerR = e.playerR - rate
                    elseif m.playerB <= max then
                        m.playerB = m.playerB + rate
                    end
                elseif m.playerB == 255 and e.playerR ~= 255 then
                    if m.playerG >= min then
                        m.playerG = m.playerG - rate
                    elseif e.playerR <= max then
                        e.playerR = e.playerR + rate
                    end
                end
                network_player_set_override_palette_color(np, EMBLEM,   {r = e.playerR, g = m.playerG, b = m.playerB})
                network_player_set_override_palette_color(np, CAP,      {r = e.playerR, g = m.playerG, b = m.playerB})
                network_player_set_override_palette_color(np, HAIR,     {r = e.playerR, g = m.playerG, b = m.playerB})
                network_player_set_override_palette_color(np, SKIN,     {r = e.playerR, g = m.playerG, b = m.playerB})
                network_player_set_override_palette_color(np, SHIRT,    {r = e.playerR, g = m.playerG, b = m.playerB})
                network_player_set_override_palette_color(np, GLOVES,   {r = e.playerR, g = m.playerG, b = m.playerB})
                network_player_set_override_palette_color(np, PANTS,    {r = e.playerR, g = m.playerG, b = m.playerB})
                network_player_set_override_palette_color(np, SHOES,    {r = e.playerR, g = m.playerG, b = m.playerB})

                --m.particleFlags = m.particleFlags | PARTICLE_SPARKLES

                if m.action == ACT_WALKING then
                    m.marioBodyState.torsoAngle.x = 0
                    m.marioBodyState.handState = MARIO_HAND_OPEN
                end

                m.peakHeight = m.pos.y

                if (m.action == ACT_WALKING) and m.forwardVel < 60 and m.forwardVel > 0 then
                    m.forwardVel = m.forwardVel * 1.15
                end
            end
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

