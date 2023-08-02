hook.Add( "PlayerNoClip", "Prisel::AdminMode::NoClip", function( ply )
  return ply:HasAdminMode() or DarkRP.notify( ply, 1, 4, "Vous ne pouvez pas utiliser le noclip hors service.")
end)