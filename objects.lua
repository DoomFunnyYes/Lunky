local E_MODEL_GREEN_FLAME = smlua_model_util_get_id("green_flame_geo")
local E_MODEL_LUNKY_FIREBALL = smlua_model_util_get_id("lunky_fireball_geo")

local SOUND_LUNKY_FIREBALL_SHOOT    = audio_sample_load("lunky_attack.ogg")
--local SOUND_LUNKY_FIREBALL_FAIL     = audio_sample_load("")
local SOUND_LUNKY_FIREBALL_HIT      = audio_sample_load("lunky_ground_pound.ogg")

local lunkyFireballLifetime = 100

local function pause_check()
    local m = gMarioStates[0]

    if (_G.charSelectExists and _G.charSelect.is_menu_open()) or is_game_paused() then
        return 0
    elseif m.action == ACT_START_SLEEPING or m.action == ACT_SLEEPING or (m.actionTimer < 80 and (m.action == ACT_STAR_DANCE_EXIT or m.action == ACT_STAR_DANCE_NO_EXIT or m.action == ACT_STAR_DANCE_WATER)) then
        return 0.2
    else
        return 1
    end
end

local function bhv_greenFlame_init(o)
    obj_set_billboard(o)
end
local function bhv_greenFlame_loop(o)
	if o.oTimer % 2 == 0 then
		o.oAnimState = o.oAnimState + 1
	end
    obj_scale(o, (10 - o.oTimer)/10)
    if o.oTimer > 10 then
        obj_mark_for_deletion(o)
        return
    end
end

id_bhvGreenFlame = hook_behavior(nil, OBJ_LIST_UNIMPORTANT, false, bhv_greenFlame_init, bhv_greenFlame_loop, 'bhvGreenFlame')

---@param o Object
local function bhv_projectile_init_lunk(o)
    local hitboxSize = 300
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.activeFlags = o.activeFlags | ACTIVE_FLAG_UNK9
    o.oGraphYOffset         = 40
    o.oGravity              = 4
    o.oBounciness           = 0
    o.oDragStrength         = 0
    o.oFriction             = 1
    o.oBuoyancy             = 2
    o.oWallHitboxRadius     = 0
    o.hitboxDownOffset      = hitboxSize/2
    o.hitboxRadius          = hitboxSize/15
    o.hitboxHeight          = hitboxSize
    o.hurtboxRadius         = hitboxSize/15
    o.hurtboxHeight         = hitboxSize
    o.oDamageOrCoinValue    = 0
    o.oForwardVel           = 65
    o.oAction               = 0
    o.oTimer                = 0
    o.oCapUnkF4             = 0
    cur_obj_become_tangible()
end

local function bhv_projectile_loop_lunk(o)
    local puType = o.oBehParams

    --[[if o.oTimer == 1 then
        audio_sample_play(SOUND_LUNKY_FIREBALL_SHOOT, {x = o.oPosX, y = o.oPosY, z = o.oPosZ}, pause_check())
    end]]
    obj_set_model_extended(o, E_MODEL_LUNKY_FIREBALL)

    local step = object_step_without_floor_orient()
    if step & OBJ_COL_FLAGS_LANDED ~= 0 then
        o.oVelY = 30
    end
    if step & OBJ_COL_FLAG_HIT_WALL ~= 0 then
        o.oForwardVel = 30
    else
        o.oForwardVel = 65
    end
    if step & OBJ_COL_FLAG_UNDERWATER ~= 0 then
        spawn_mist_particles_with_sound(SOUND_GENERAL_FLAME_OUT)
        o.oAction = -1
    end

    if o.oAction == 0 then
        local targetDist = 0x20000
        for key, hit_effect in pairs(projectileHitInteracts) do
            local hitObj = cur_obj_nearest_object_with_behavior(get_behavior_from_id(key))
            if hitObj ~= nil then
                if projectileHitInteracts[key] ~= nil then
                    local dist = dist_between_objects(o, hitObj)
                    if dist < targetDist then
                        targetDist = dist
                    end
                    if obj_check_hitbox_overlap(o, hitObj) then
                        if projectileHitInteracts[key] then
                            hit_effect(o, hitObj)
                        end
                    end
                end
            end
        end
    end

    local range = 20
    local offsetX = math.random(-range, range)
    local offsetY = math.random(-range, range) + o.oGraphYOffset/2
    local offsetZ = math.random(-range, range)
    spawn_non_sync_object(id_bhvGreenFlame, E_MODEL_GREEN_FLAME, o.oPosX + offsetX, o.oPosY + offsetY, o.oPosZ + offsetZ, nil)
    o.oFaceAnglePitch = o.oFaceAnglePitch + 0x1200
    o.oFaceAngleYaw = o.oMoveAngleYaw

    if o.oTimer >= lunkyFireballLifetime then
        o.oAction = -1
    end
    if o.oAction == -1 then
        spawn_mist_particles_with_sound(SOUND_OBJ_DEFAULT_DEATH)
        --spawn_mist_particles()
        --audio_sample_play(SOUND_LUNKY_FIREBALL_FAIL, {x = o.oPosX, y = o.oPosY, z = o.oPosZ}, pause_check())
        obj_mark_for_deletion(o)
        return
    elseif o.oAction == 1 then
        spawn_mist_particles()
        audio_sample_play(SOUND_LUNKY_FIREBALL_HIT, {x = o.oPosX, y = o.oPosY, z = o.oPosZ}, pause_check()*2)
        obj_mark_for_deletion(o)
    end
end
id_bhvLunkyGreenball = hook_behavior(nil, OBJ_LIST_GENACTOR, true, bhv_projectile_init_lunk, bhv_projectile_loop_lunk, "bhvLunkyGreenball")

-- Uncomment this to take a look at the models
--[[
local function on_level_init()
    spawn_non_sync_object(
        id_bhvGreenFlame,
        E_MODEL_GREEN_FLAME,
        0, 850, 0,
        function(o)
			obj_scale(o, 3)
		end
    )
	spawn_non_sync_object(
        id_bhvGreenFlame,
        E_MODEL_LUNKY_FIREBALL,
        100, 850, 0,
        nil
    )
end
hook_event(HOOK_ON_LEVEL_INIT, on_level_init)
]]