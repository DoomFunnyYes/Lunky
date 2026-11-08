E_MODEL_GREEN_FLAME = smlua_model_util_get_id("green_flame_geo")
E_MODEL_LUNKY_FIREBALL = smlua_model_util_get_id("lunky_fireball_geo")

local function bhv_greenFlame_loop(o)
	if o.oTimer % 2 == 0 then
		o.oAnimState = o.oAnimState + 1
	end
end

id_bhvGreenFlame = hook_behavior(nil, OBJ_LIST_UNIMPORTANT, false, function(o)
end, bhv_greenFlame_loop,'bhvGreenFlame')

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

local projData = {
    {model = E_MODEL_LUNKY_FIREBALL, trail = E_MODEL_GREEN_FLAME,          spawnSound = CHAR_SOUND_PUNCH_YAH,  deathSound = SOUND_GENERAL_FLAME_OUT,  hitSound = SOUND_GENERAL_FLAME_OUT,      lifetime = fireballLifetime},
}

local function bhv_projectile_loop_lunk(o)
    local puType = o.oBehParams

    if o.oTimer == 1 then
        audio_sample_play(projData[puType].spawnSound, {x = o.oPosX, y = o.oPosY, z = o.oPosZ}, pause_check())
    end
    obj_set_model_extended(o, projData[puType].model)

    local step = object_step_without_floor_orient()
    if step & OBJ_COL_FLAGS_LANDED ~= 0 then
        o.oVelY = 30
        -- if puType == POWERUP_GOLD and step & OBJ_COL_FLAG_UNDERWATER == 0 and o.oCapUnkF4 > 7 then
        --     spawn_non_sync_object(id_bhvSingleCoinGetsSpawned, E_MODEL_YELLOW_COIN, o.oPosX, o.oPosY, o.oPosZ, function(coin)
        --         coin.oVelY = 20
        --     end)
        -- end
        --o.oCapUnkF4 = 0
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
        local hitType = puType -- change this when gold interacts are done
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
    spawn_non_sync_object(id_bhvShrinkParticle, projData[puType].trail, o.oPosX + offsetX, o.oPosY + offsetY, o.oPosZ + offsetZ, nil)
    o.oFaceAnglePitch = o.oFaceAnglePitch + 0x1200
    o.oFaceAngleYaw = o.oMoveAngleYaw

    if o.oTimer >= projData[puType].lifetime then
        spawn_mist_particles()
        audio_sample_play(projData[puType].deathSound, {x = o.oPosX, y = o.oPosY, z = o.oPosZ}, pause_check())
        o.oAction = -1
    end
    if o.oAction == -1 then
        spawn_mist_particles()
        audio_sample_play(projData[puType].deathSound, {x = o.oPosX, y = o.oPosY, z = o.oPosZ}, pause_check())
        obj_mark_for_deletion(o)
        return
    elseif o.oAction == 1 then
        spawn_mist_particles()
        audio_sample_play(projData[puType].hitSound, {x = o.oPosX, y = o.oPosY, z = o.oPosZ}, pause_check())
        o.oAction = -1
    end

    --o.oCapUnkF4 = (puType == POWERUP_GOLD) and o.oCapUnkF4 + 1 or 0
end
hook_behavior(nil, OBJ_LIST_GENACTOR, true, bhv_projectile_init_lunk, bhv_projectile_loop_lunk, "bhvFireOrIceball")

-- Uncomment this to take a look at the models
--hook_event(HOOK_ON_LEVEL_INIT, on_level_init)