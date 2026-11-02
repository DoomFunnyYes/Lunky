-- name: [CS] Lunky
-- description: CS version of all my playermodels.

local TEXT_MOD_NAME = "[CS] Lunky"

-- Stops mod from loading if Character Select isn't on, Does not need to be touched
if not _G.charSelectExists then
    djui_popup_create("\\#ffffdc\\\n"..TEXT_MOD_NAME.."\nRequires the Character Select Mod\nto use as a Library!\n\nPlease turn on the Character Select Mod\nand Restart the Room!", 6)
    return 0
end

local E_MODEL_LUNKY =      smlua_model_util_get_id("lunky_geo")      -- Located in "actors"

local ANIMTABLE_LUNKY = {
  [CHAR_ANIM_SINGLE_JUMP] = function(m, frame)
    m.marioObj.header.gfx.animInfo.animAccel = 32768 * 15
    return "luigi_float"
  end,
  [CHAR_ANIM_DOUBLE_JUMP_RISE] = function(m, frame)
    m.marioObj.header.gfx.angle.y = get_global_timer() * 0x3000
    set_mario_animation(m, CHAR_ANIM_TWIRL)
  end,
  [CHAR_ANIM_DOUBLE_JUMP_FALL] = function(m, frame)
    m.marioObj.header.gfx.angle.y = get_global_timer() * 0x3000
    set_mario_animation(m, CHAR_ANIM_TWIRL)
  end,
  [CHAR_ANIM_TRIPLE_JUMP] = function(m, frame)
    m.marioObj.header.gfx.angle.x = get_global_timer() * 0x3000
    set_mario_animation(m, CHAR_ANIM_FORWARD_SPINNING)
  end,
    [CHAR_ANIM_FAST_LONGJUMP] = function(m, frame)
    set_mario_anim_with_accel(m, CHAR_ANIM_SLOW_LONGJUMP, 0x10000)
  end,
    [CHAR_ANIM_RUNNING] = function(m, frame)
    local val04 = m.intendedMag > m.forwardVel and m.intendedMag or m.forwardVel
    if val04 < 4 then
        val04 = 4
    end
    set_mario_anim_with_accel(m, CHAR_ANIM_WALKING, ((val04 / 4.0 * 0x10000)))
  end,
}

local VOICETABLE_LUNKY = {
    [CHAR_SOUND_ATTACKED] = 'lunky_hurt.ogg',
    [CHAR_SOUND_COUGHING1] = '.ogg',
    [CHAR_SOUND_COUGHING2] = '.ogg',
    [CHAR_SOUND_COUGHING3] = '.ogg',
    [CHAR_SOUND_DOH] = '.ogg',
    [CHAR_SOUND_DROWNING] = '.ogg',
    [CHAR_SOUND_DYING] = '.ogg',
    [CHAR_SOUND_EEUH] = '.ogg',
    [CHAR_SOUND_GAME_OVER] = '.ogg',
    [CHAR_SOUND_GROUND_POUND_WAH] = '.ogg',
    [CHAR_SOUND_HAHA] = '.ogg',
    [CHAR_SOUND_HAHA_2] = '.ogg',
    [CHAR_SOUND_HELLO] = '.ogg',
    [CHAR_SOUND_HERE_WE_GO] = '.ogg',
    [CHAR_SOUND_HOOHOO] = 'lunky_double_jump.ogg',
    [CHAR_SOUND_HRMM] = '.ogg',
    [CHAR_SOUND_IMA_TIRED] = '.ogg',
    [CHAR_SOUND_LETS_A_GO] = 'lunky_letsago.ogg',
    [CHAR_SOUND_MAMA_MIA] = 'lunky_grow.ogg',
    [CHAR_SOUND_OKEY_DOKEY] = 'lunky_okiedokie.ogg',
    [CHAR_SOUND_ON_FIRE] = '.ogg',
    [CHAR_SOUND_OOOF] = 'lunky_hurt.ogg',
    [CHAR_SOUND_OOOF2] = 'lunky_hurt.ogg',
    [CHAR_SOUND_PANTING] = '.ogg',
    [CHAR_SOUND_PANTING_COLD] = '.ogg',
    [CHAR_SOUND_PRESS_START_TO_PLAY] = '.ogg',
    [CHAR_SOUND_PUNCH_HOO] = '.ogg',
    [CHAR_SOUND_PUNCH_WAH] = '.ogg',
    [CHAR_SOUND_PUNCH_YAH] = '.ogg',
    [CHAR_SOUND_SNORING1] = '.ogg',
    [CHAR_SOUND_SNORING2] = '.ogg',
    [CHAR_SOUND_SNORING3] = '.ogg',
    [CHAR_SOUND_SO_LONGA_BOWSER] = '.ogg',
    [CHAR_SOUND_TWIRL_BOUNCE] = '.ogg',
    [CHAR_SOUND_UH] = '.ogg',
    [CHAR_SOUND_UH2] = '.ogg',
    [CHAR_SOUND_UH2_2] = '.ogg',
    [CHAR_SOUND_WAAAOOOW] = '.ogg',
    [CHAR_SOUND_WAH2] = '.ogg',
    [CHAR_SOUND_WHOA] = '.ogg',
    [CHAR_SOUND_YAHOO] = 'lunky_long_jump.ogg',
    [CHAR_SOUND_YAHOO_WAHA_YIPPEE] = 'lunky_triple_jump.ogg',
    [CHAR_SOUND_YAH_WAH_HOO] = 'lunky_jump.ogg',
    [CHAR_SOUND_YAWNING] = '.ogg',
}

local PALETTE_LUNKY = {
    [PANTS]  = "ffffff",
    [SHIRT]  = "ffffff",
    [GLOVES] = "ffffff",
    [SHOES]  = "ffffff",
    [HAIR]   = "ffffff",
    [SKIN]   = "ffffff",
    [CAP]    = "ffffff",
	[EMBLEM] = "ffffff"
}

local CSloaded = false
local function on_character_select_load()
    -- Adds the custom character to the Character Select Menu
    CT_LUNKY = _G.charSelect.character_add(
        "Lunky", -- Character Name
        "SwagSkeleton95's Mario model.", -- Description
        "SwagSkeleton95", -- Credits
        "ffffff",           -- Menu Color
        E_MODEL_LUNKY,       -- Character Model
        CT_LUIGI,           -- Override Character
	1.0
    )

    _G.charSelect.character_add_animations(E_MODEL_LUNKY, ANIMTABLE_LUNKY)

    _G.charSelect.character_add_voice(E_MODEL_LUNKY, VOICETABLE_LUNKY)

    _G.charSelect.character_add_palette_preset(E_MODEL_LUNKY, PALETTE_LUNKY, 'LUNKY')

----

    CSloaded = true
end

_G.charSelect.config_character_sounds()
hook_event(HOOK_ON_MODS_LOADED, on_character_select_load)