---@param proj Object -- projectile obj
---@param target Object -- the obj fireball hit
local function general_hit_disallow(proj, target)
    proj.oAction = -1
end
local function fire_hit_generic(proj, target)
    target.oInteractStatus = target.oInteractStatus | ATTACK_FAST_ATTACK | INT_STATUS_WAS_ATTACKED | INT_STATUS_INTERACTED | INT_STATUS_TOUCHED_BOB_OMB-- | ATTACK_FROM_ABOVE
    proj.oAction = 1
    if obj_has_behavior_id(target, id_bhvMoneybag) ~= 0 then
        target.parentObj.activeFlags = ACTIVE_FLAG_DEACTIVATED
        target.oAction = MONEYBAG_ACT_DEATH
        target.oTimer = 1
    elseif obj_has_behavior_id(target, id_bhvPiranhaPlant) ~= 0 then
        if target.oAction ~= PIRANHA_PLANT_ACT_ATTACKED then
            play_sound(SOUND_OBJ2_PIRANHA_PLANT_DYING, target.header.gfx.cameraToObject);
            -- Spawn 20 intangible purple particles that quickly dissipate.
            for i = 1, 20 do
                spawn_non_sync_object(id_bhvPurpleParticle, E_MODEL_PURPLE_MARBLE, target.oPosX, target.oPosY, target.oPosZ, nil);
            end
            stop_secondary_music(1000)
            target.oAction = PIRANHA_PLANT_ACT_ATTACKED
        else
            general_hit_disallow(proj, target)
        end
    end
end
local function fire_hit_snowman(proj, target)
    for i=0, 2 do
        spawn_non_sync_object(id_bhvSingleCoinGetsSpawned, E_MODEL_YELLOW_COIN, target.oPosX, target.oPosY, target.oPosZ, nil)
    end
    target.oFaceAngleRoll = 0x3000
    target.oMrBlizzardHeldObj = nil
    target.prevObj = target.oMrBlizzardHeldObj
    if target.oAnimState ~= 0 then
        save_file_clear_flags(SAVE_FLAG_CAP_ON_MR_BLIZZARD);

        spawn_non_sync_object(id_bhvNormalCap, E_MODEL_MARIOS_CAP, target.oPosX, target.oPosY, target.oPosZ, function(cap)
            cap.oFaceAngleYaw = target.oFaceAngleYaw
            cap.oForwardVel = 0
            cap.oVelY = 30
        end)

        -- Mr. Blizzard no longer spawns with Mario's cap on.
        target.oAnimState = 0
    end
    obj_mark_for_deletion(target)
    proj.oAction = 1
end
local function fire_hit_heaveho(proj, target)
    spawn_non_sync_object(id_bhvMrIBlueCoin, E_MODEL_BLUE_COIN, target.oPosX, target.oPosY, target.oPosZ, nil)
    play_sound(SOUND_GENERAL_BREAK_BOX, target.header.gfx.cameraToObject)
    spawn_triangle_break_particles(30, 138, 3.0, 4)
    obj_mark_for_deletion(target)
    proj.oAction = 1
end
local function fire_hit_eyeball(proj, target)
    if target.header.gfx.scale.y > 1 then
        general_hit_disallow(proj, target)
        return
    end
    spawn_non_sync_object(id_bhvMrIBlueCoin, E_MODEL_BLUE_COIN, target.oPosX, target.oPosY, target.oPosZ, nil)
    play_sound(SOUND_OBJ_MRI_DEATH, target.header.gfx.cameraToObject)
    obj_mark_for_deletion(target)
    proj.oAction = 1
end
local function fire_hit_bully(proj, target)
    target.oInteractStatus = target.oInteractStatus | ATTACK_FAST_ATTACK | INT_STATUS_WAS_ATTACKED | INT_STATUS_INTERACTED
    target.oMoveAngleYaw = proj.oMoveAngleYaw
    target.oForwardVel = 30
    proj.oAction = 1
end
local function fire_hit_small_box(proj, target)
    for i=0, 2 do
        spawn_non_sync_object(id_bhvSingleCoinGetsSpawned, E_MODEL_YELLOW_COIN, target.oPosX, target.oPosY, target.oPosZ, function(coin)
            coin.oVelY = 20
        end)
    end
    create_sound_spawner(SOUND_GENERAL_BREAK_BOX)
    obj_mark_for_deletion(target)
    proj.oAction = 1
end
local function fire_hit_boo_boss(proj, target)
    if target.oAction ~= 3 then
        target.oInteractStatus = target.oInteractStatus | ATTACK_FAST_ATTACK | INT_STATUS_WAS_ATTACKED | INT_STATUS_INTERACTED
        proj.oAction = 1
    else
        general_hit_disallow(proj, target)
    end
end
local function fire_hit_bowser(proj, target)
    local oBowser = target.parentObj
    if oBowser.oAction ~= 19 and oBowser.oAction ~= 4 and oBowser.oAction ~= 12 then
        oBowser.oMoveFlags = 0
        oBowser.oSubAction = 0
        oBowser.oMoveAngleYaw = proj.oMoveAngleYaw + 0x8000
        oBowser.oFaceAngleYaw = oBowser.oMoveAngleYaw + 0x8000
        oBowser.oAction = 1
        oBowser.oForwardVel = -30
        oBowser.oVelY = 50
        proj.oAction = 1
    else
        general_hit_disallow(proj, target)
    end
    obj_mark_for_deletion(proj)
end
---@param proj Object
---@param target Object
local function fire_hit_mario(proj, target)
    local m = get_mario_state_from_object(target)
    if not m then return end
    if network_local_index_from_global(proj.globalPlayerIndex) == m.playerIndex then return end

    if m.action == ACT_BUBBLED then
        mario_pop_bubble(m)
        proj.oAction = 1
        return
    end

    if gServerSettings.playerInteractions == PLAYER_INTERACTIONS_NONE then return end
    if is_player_active(m) == 0 or m.invincTimer ~= 0 then return end

    if m.action & (ACT_FLAG_INTANGIBLE | ACT_FLAG_INVULNERABLE) == 0 then
        if gServerSettings.playerInteractions == PLAYER_INTERACTIONS_PVP then
            m.hurtCounter = 4
        end
        m.faceAngle.y = proj.oMoveAngleYaw + 0x8000
        set_mario_action(m, ACT_BACKWARD_AIR_KB, 0)
        proj.oAction = 1
        return
    end
end

projectileHitInteracts = {
    [id_bhvMario]               = fire_hit_mario,
    [id_bhvGoomba]              = fire_hit_generic,
    [id_bhvBobomb]              = fire_hit_generic,
    [id_bhvKoopa]               = fire_hit_generic,
    [id_bhvMontyMole]           = fire_hit_generic,
    [id_bhvBoo]                 = fire_hit_generic,
    [id_bhvGhostHuntBoo]        = fire_hit_generic,
    [id_bhvMerryGoRoundBoo]     = fire_hit_generic,
    [id_bhvGhostHuntBigBoo]     = fire_hit_boo_boss,
    [id_bhvBalconyBigBoo]       = fire_hit_boo_boss,
    [id_bhvMerryGoRoundBigBoo]  = fire_hit_boo_boss,
    [id_bhvFlyingBookend]       = fire_hit_generic,
    [id_bhvSkeeter]             = fire_hit_generic,
    [id_bhvMoneybag]            = fire_hit_generic,
    [id_bhvSnufit]              = fire_hit_generic,
    [id_bhvSwoop]               = fire_hit_generic,
    [id_bhvFirePiranhaPlant]    = fire_hit_generic,
    [id_bhvEnemyLakitu]         = fire_hit_generic,
    [id_bhvPokeyBodyPart]       = fire_hit_generic,
    [id_bhvEyerokHand]          = fire_hit_generic,
    [id_bhvScuttlebug]          = fire_hit_generic,
    [id_bhvSmallBully]          = fire_hit_bully,
    [id_bhvBigBully]            = fire_hit_bully,
    [id_bhvBigBullyWithMinions] = fire_hit_bully,
    [id_bhvSmallChillBully]     = fire_hit_bully,
    [id_bhvBigChillBully]       = fire_hit_bully,
    [id_bhvSpindrift]           = fire_hit_generic,
    [id_bhvFlyGuy]              = fire_hit_generic,
    [id_bhvMrBlizzard]          = fire_hit_snowman,
    [id_bhvHeaveHo]             = fire_hit_heaveho,
    [id_bhvMrI]                 = fire_hit_eyeball,
    [id_bhvBreakableBox]        = fire_hit_generic,
    [id_bhvBreakableBoxSmall]   = fire_hit_small_box,
    [id_bhvHauntedChair]        = fire_hit_generic,
    [id_bhvBowserBodyAnchor]    = fire_hit_bowser,
    [id_bhvChuckya]             = general_hit_disallow,
    [id_bhvFirePiranhaPlant]    = fire_hit_generic,
    [id_bhvPiranhaPlant]        = fire_hit_generic,
}