local function lunky_update(m)
    if m.health <= (1348) then
        m.marioObj.header.gfx.scale.y = 0.5
        else
        m.marioObj.header.gfx.scale.y = 1
    end
end

_G.charSelect.character_hook_moveset(CT_LUNKY, HOOK_MARIO_UPDATE, lunky_update)