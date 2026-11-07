const GeoLayout rainbow_star_geo_opt_1[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_DISPLAY_LIST(LAYER_TRANSPARENT, rainbow_star_Metal_Cap_DL_mesh_layer_1_with_layer_5_revert),
	GEO_CLOSE_NODE(),
	GEO_RETURN(),
};
const GeoLayout rainbow_star_geo_opt_2[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_DISPLAY_LIST(LAYER_OPAQUE, rainbow_star_Metal_Cap_DL_mesh_layer_1_opt_2_with_layer_1_revert),
	GEO_CLOSE_NODE(),
	GEO_RETURN(),
};
const GeoLayout rainbow_star_geo_opt_3[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_DISPLAY_LIST(LAYER_TRANSPARENT, rainbow_star_Metal_Cap_DL_mesh_layer_1_opt_2_with_layer_1_revert),
	GEO_CLOSE_NODE(),
	GEO_RETURN(),
};
const GeoLayout rainbow_star_geo[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_SHADOW(0, 180, 75),
		GEO_OPEN_NODE(),
			GEO_SCALE(LAYER_FORCE, 16384),
			GEO_OPEN_NODE(),
				GEO_ASM(10, geo_update_layer_transparency),
				GEO_SWITCH_CASE(2, geo_switch_anim_state),
				GEO_OPEN_NODE(),
					GEO_NODE_START(),
					GEO_OPEN_NODE(),
						GEO_DISPLAY_LIST(LAYER_OPAQUE, rainbow_star_Metal_Cap_DL_mesh_layer_1_with_layer_1_revert),
					GEO_CLOSE_NODE(),
					GEO_BRANCH(1, rainbow_star_geo_opt_1),
					GEO_BRANCH(1, rainbow_star_geo_opt_2),
					GEO_BRANCH(1, rainbow_star_geo_opt_3),
				GEO_CLOSE_NODE(),
			GEO_CLOSE_NODE(),
		GEO_CLOSE_NODE(),
	GEO_CLOSE_NODE(),
	GEO_END(),
};
