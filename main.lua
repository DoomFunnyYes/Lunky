-- name: [CS] Lunky
-- description: CS version of all my playermodels.

TOGGLE_STARMAN_THEME = mod_storage_load_bool("starman_theme")

LUNKY_INVINCIBILITY = audio_stream_load("lunky_invincibility.ogg")
audio_stream_set_loop_points(LUNKY_INVINCIBILITY, 94050, 6109156)
audio_stream_set_looping(LUNKY_INVINCIBILITY, true)

LUNKY_INVINCIBILITY_SNES = audio_stream_load("lunky_invincibility_snes.ogg")
audio_stream_set_looping(LUNKY_INVINCIBILITY_SNES, true)

local TEXT_MOD_NAME = "[CS] Lunky"

-- Stops mod from loading if Character Select isn't on, Does not need to be touched
if not _G.charSelectExists then
    djui_popup_create("\\#ffffdc\\\n"..TEXT_MOD_NAME.."\nRequires the Character Select Mod\nto use as a Library!\n\nPlease turn on the Character Select Mod\nand Restart the Room!", 6)
    return 0
end

local E_MODEL_LUNKY =      smlua_model_util_get_id("lunky_geo")      -- Located in "actors"
local E_MODEL_LUNKY_FLESH =      smlua_model_util_get_id("lunky_flesh_geo")

local E_MODEL_RAINBOW_STAR =      smlua_model_util_get_id("rainbow_star_geo")


local TEX_LUNKY_LIFE_ICON = get_texture_info("lunky_icon")

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
  [CHAR_ANIM_START_GROUND_POUND] = function(m, frame)
    m.marioObj.header.gfx.angle.y = get_global_timer() * 0x5000
    set_mario_animation(m, CHAR_ANIM_TWIRL)
    if (m.actionTimer % 3) == 0 then
      play_sound(SOUND_ACTION_TWIRL, m.marioObj.header.gfx.cameraToObject)
    end
  end,
  [CHAR_ANIM_TRIPLE_JUMP_GROUND_POUND] = function(m, frame)
    m.marioObj.header.gfx.angle.y = get_global_timer() * 0x5000
    set_mario_animation(m, CHAR_ANIM_TWIRL)
    if (m.actionTimer % 3) == 0 then
      play_sound(SOUND_ACTION_TWIRL, m.marioObj.header.gfx.cameraToObject)
    end
  end,
  [CHAR_ANIM_GROUND_POUND] = function(m, frame)
    m.marioObj.header.gfx.angle.y = get_global_timer() * 0x5000
    set_mario_animation(m, CHAR_ANIM_TWIRL)
    if (m.actionTimer % 3) == 0 then
      play_sound(SOUND_ACTION_TWIRL, m.marioObj.header.gfx.cameraToObject)
    end
  end,
  [CHAR_ANIM_FAST_LONGJUMP] = function(m, frame)
    set_mario_anim_with_accel(m, CHAR_ANIM_SLOW_LONGJUMP, 0x10000)
  end,
    [CHAR_ANIM_RUNNING] = function(m, frame)
    return "lunky_running"
  end,
}

local VOICETABLE_LUNKY = {
    [CHAR_SOUND_ATTACKED] = 'lunky_real_hurt.ogg',
    [CHAR_SOUND_COUGHING1] = 'lunky_silence.ogg',
    [CHAR_SOUND_COUGHING2] = 'lunky_silence.ogg',
    [CHAR_SOUND_COUGHING3] = 'lunky_silence.ogg',
    [CHAR_SOUND_DOH] = 'lunky_silence.ogg',
    [CHAR_SOUND_DROWNING] = 'lunky_silence.ogg',
    [CHAR_SOUND_DYING] = 'lunky_silence.ogg',
    [CHAR_SOUND_EEUH] = 'lunky_silence.ogg',
    [CHAR_SOUND_GAME_OVER] = 'lunky_silence.ogg',
    [CHAR_SOUND_GROUND_POUND_WAH] = 'lunky_ground_pound.ogg',
    [CHAR_SOUND_HAHA] = 'lunky_silence.ogg',
    [CHAR_SOUND_HAHA_2] = 'lunky_silence.ogg',
    [CHAR_SOUND_HELLO] = 'lunky_silence.ogg',
    [CHAR_SOUND_HERE_WE_GO] = 'lunky_silence.ogg',
    [CHAR_SOUND_HOOHOO] = 'lunky_silence.ogg',
    [CHAR_SOUND_HRMM] = 'lunky_silence.ogg',
    [CHAR_SOUND_IMA_TIRED] = 'lunky_silence.ogg',
    [CHAR_SOUND_LETS_A_GO] = 'lunky_letsago.ogg',
    [CHAR_SOUND_MAMA_MIA] = 'lunky_mamamia.ogg',
    [CHAR_SOUND_OKEY_DOKEY] = 'lunky_okiedokie.ogg',
    [CHAR_SOUND_ON_FIRE] = 'lunky_silence.ogg',
    [CHAR_SOUND_OOOF] = 'lunky_silence.ogg',
    [CHAR_SOUND_OOOF2] = 'lunky_silence.ogg',
    [CHAR_SOUND_PANTING] = 'lunky_silence.ogg',
    [CHAR_SOUND_PANTING_COLD] = 'lunky_silence.ogg',
    [CHAR_SOUND_PRESS_START_TO_PLAY] = 'lunky_silence.ogg',
    [CHAR_SOUND_PUNCH_HOO] = 'lunky_attack.ogg',
    [CHAR_SOUND_PUNCH_WAH] = 'lunky_attack.ogg',
    [CHAR_SOUND_PUNCH_YAH] = 'lunky_attack.ogg',
    [CHAR_SOUND_SNORING1] = 'lunky_silence.ogg',
    [CHAR_SOUND_SNORING2] = 'lunky_silence.ogg',
    [CHAR_SOUND_SNORING3] = 'lunky_silence.ogg',
    [CHAR_SOUND_SO_LONGA_BOWSER] = 'lunky_silence.ogg',
    [CHAR_SOUND_TWIRL_BOUNCE] = 'lunky_silence.ogg',
    [CHAR_SOUND_UH] = 'lunky_silence.ogg',
    [CHAR_SOUND_UH2] = 'lunky_silence.ogg',
    [CHAR_SOUND_UH2_2] = 'lunky_silence.ogg',
    [CHAR_SOUND_WAAAOOOW] = 'lunky_silence.ogg',
    [CHAR_SOUND_WAH2] = 'lunky_silence.ogg',
    [CHAR_SOUND_WHOA] = 'lunky_silence.ogg',
    [CHAR_SOUND_YAHOO] = 'lunky_silence.ogg',
    [CHAR_SOUND_YAHOO_WAHA_YIPPEE] = 'lunky_silence.ogg',
    [CHAR_SOUND_YAH_WAH_HOO] = 'lunky_silence.ogg',
    [CHAR_SOUND_YAWNING] = 'lunky_silence.ogg',
}

local PALETTE_LUNKY = {
    [PANTS]  = "008c1b",
    [SHIRT]  = "0e2770",
    [GLOVES] = "ffffff",
    [SHOES]  = "522910",
    [HAIR]   = "6c1800",
    [SKIN]   = "ffaa72",
    [CAP]    = "008c1b",
	  [EMBLEM] = "008c1b"
}
local PALETTE_LUNKY_FLESH = {
    [PANTS]  = "008c1b",
    [SHIRT]  = "0e2770",
    [GLOVES] = "ffffff",
    [SHOES]  = "522910",
    [HAIR]   = "6c1800",
    [SKIN]   = "ffaa72",
    [CAP]    = "008c1b",
	  [EMBLEM] = "008c1b"
}

CAPTABLE_LUNKY = {
    normal = E_MODEL_LUIGIS_CAP,
    wing = E_MODEL_RAINBOW_STAR,
    metal = E_MODEL_RAINBOW_STAR,
    metalWing = E_MODEL_RAINBOW_STAR,
}

local CSloaded = false
local function on_character_select_load()
    -- Adds the custom character to the Character Select Menu
    CT_LUNKY = _G.charSelect.character_add(
        "Lunky", -- Character Name
        "This is Lunky! Full of joy!.", -- Description
        "Boomer?", -- Credits
        "ffffff",           -- Menu Color
        E_MODEL_LUNKY,       -- Character Model
        CT_LUIGI,           -- Override Character
        TEX_LUNKY_LIFE_ICON, -- Life Icon
	1.0
    )

    CT_LUNKY_FLESH = _G.charSelect.character_add_costume(
    CT_LUNKY,
        "Lunky With No Protection", -- Character Name
        "This is Lunky! Full of joy!.", -- Description
        "Boomer?", -- Credits
        "ffffff",           -- Menu Color
        E_MODEL_LUNKY_FLESH,       -- Character Model
        CT_LUIGI,           -- Override Character
        TEX_LUNKY_LIFE_ICON, -- Life Icon
	1.0
    )

local HEALTH_METER_LUNKY = {
  djui_hud_set_resolution(RESOLUTION_N64),
  djui_hud_set_font(FONT_HUD),
	label = {
		left = get_texture_info("lunky_health_left"),
		right = get_texture_info("lunky_health_right"),
	},
	pie = {
		[1] = get_texture_info("lunky_health_none"),
		[2] = get_texture_info("lunky_health_none"),
		[3] = get_texture_info("lunky_health_none"),
		[4] = get_texture_info("lunky_health_none"),
		[5] = get_texture_info("lunky_health_shroom"),
		[6] = get_texture_info("lunky_health_shroom"),
		[7] = get_texture_info("lunky_health_shroom"),
		[8] = get_texture_info("lunky_health_flower"),
	}
}

    _G.charSelect.character_add_animations(E_MODEL_LUNKY, ANIMTABLE_LUNKY)
    _G.charSelect.character_add_animations(E_MODEL_LUNKY_FLESH, ANIMTABLE_LUNKY)

    _G.charSelect.character_add_voice(E_MODEL_LUNKY, VOICETABLE_LUNKY)
    _G.charSelect.character_add_voice(E_MODEL_LUNKY_FLESH, VOICETABLE_LUNKY)

    _G.charSelect.character_add_palette_preset(E_MODEL_LUNKY, PALETTE_LUNKY, 'LUNKY')
    _G.charSelect.character_add_palette_preset(E_MODEL_LUNKY_FLESH, PALETTE_LUNKY_FLESH, 'LUNKY WITH NO PROTECTION')

    _G.charSelect.character_add_health_meter(CT_LUNKY, HEALTH_METER_LUNKY)

    _G.charSelect.credit_add(TEXT_MOD_NAME, "saulis2cool4u", "Awesome Models!")
    _G.charSelect.credit_add(TEXT_MOD_NAME, "SwagSkeleton95", "Finalized Star Power code!")
    _G.charSelect.credit_add(TEXT_MOD_NAME, "JerThePear", "A metric TON of advice!")
	
	_G.charSelect.character_add_caps(E_MODEL_LUNKY,CAPTABLE_LUNKY)
	_G.charSelect.character_add_caps(E_MODEL_LUNKY_FLESH,CAPTABLE_LUNKY)

----
    _G.charSelect.character_hook_moveset(CT_LUNKY, HOOK_BEFORE_SET_MARIO_ACTION, lunky_before_set_action)
    _G.charSelect.character_hook_moveset(CT_LUNKY, HOOK_MARIO_UPDATE, lunky_update)
    _G.charSelect.character_hook_moveset(CT_LUNKY, HOOK_ON_SET_MARIO_ACTION, lunky_on_set_action)

function checkbox_starman_theme()
    if TOGGLE_STARMAN_THEME == true then
      _G.charSelect.character_add_sequence_replacement(CT_LUNKY, SEQ_EVENT_METAL_CAP, LUNKY_INVINCIBILITY_SNES)
    else
      _G.charSelect.character_add_sequence_replacement(CT_LUNKY, SEQ_EVENT_METAL_CAP, LUNKY_INVINCIBILITY)
    end
end

      _G.charSelect.character_add_sequence_replacement(CT_LUNKY, SEQ_EVENT_METAL_CAP, LUNKY_INVINCIBILITY)
      _G.charSelect.character_add_sequence_replacement(CT_LUNKY, SEQ_EVENT_POWERUP, LUNKY_INVINCIBILITY)

hook_mod_menu_checkbox("Toggle Starman Theme", true, checkbox_starman_theme)

    CSloaded = true

  end

_G.charSelect.config_character_sounds()

function lunky_before_set_action(m, inc, arg) --m is the mariostate input, inc is the incoming action, arg is the action's actionArg
    if (inc == ACT_JUMP) or (inc == ACT_DOUBLE_JUMP) or (inc == ACT_TRIPLE_JUMP) then -- Should be self explanatory
        if m.flags & MARIO_METAL_CAP == 0 then
        else
            m.vel.y = 70
            return ACT_SPECIAL_TRIPLE_JUMP
        end
    end
    if (inc == ACT_PUNCHING and arg == 9) or (inc == ACT_SLIDE_KICK) then
      return ACT_LUNKY_CYCLONE
    end
    if (inc == ACT_LONG_JUMP) then
      return set_mario_action(m, ACT_LUNKY_MISSILE_CHARGE, 1)
    end
    if (inc == ACT_BACKFLIP) then
      return set_mario_action(m, ACT_LUNKY_MISSILE_CHARGE, 2)
    end
    if (inc  == ACT_SOFT_BONK) then
        m.faceAngle.y = m.faceAngle.y + 0x8000
        return ACT_WALL_STICK
    end
end

hook_event(HOOK_ON_MODS_LOADED, on_character_select_load)