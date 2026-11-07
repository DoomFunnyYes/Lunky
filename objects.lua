E_MODEL_GREEN_FLAME = smlua_model_util_get_id("green_flame_geo")
E_MODEL_LUNKY_FIREBALL = smlua_model_util_get_id("lunky_fireball_geo")

local function bhv_greenFlame_loop(o)
	if o.oTimer % 2 == 0 then
		o.oAnimState = o.oAnimState + 1
	end
end

id_bhvGreenFlame = hook_behavior(nil, OBJ_LIST_UNIMPORTANT, false, function(o)
end, bhv_greenFlame_loop,'bhvGreenFlame')

local function on_level_init()
    spawn_non_sync_object(
        id_bhvGreenFlame,
        E_MODEL_GREEN_FLAME,
        0, 850, 0,
        function(o)
			obj_set_billboard(o)
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

-- Uncomment this to take a look at the models
--hook_event(HOOK_ON_LEVEL_INIT, on_level_init)