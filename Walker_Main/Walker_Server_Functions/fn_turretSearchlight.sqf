params ["_veh_armed"];

_veh_turr_beg = getText (configfile >> "CfgVehicles" >> (typeOf _veh_armed) >> "Turrets" >> "MainTurret" >> "gunBeg");
_veh_turr_end = getText (configfile >> "CfgVehicles" >> (typeOf _veh_armed) >> "Turrets" >> "MainTurret" >> "gunEnd");

_obiect_lit = createSimpleObject ["Sign_Sphere10cm_F", [0,0,0]]; _obiect_lit setObjectTextureGlobal [0,"#(argb,8,8,3)color(0,0,0,0,ca)"]; _obiect_lit attachTo [_veh_armed, [0,0,-0.2], _veh_turr_end, true];
_obiect_comp = createSimpleObject ["A3\data_f\VolumeLight_searchLight.p3d",[0,0,0]];_obiect_comp hideObjectGlobal true;	_obiect_comp attachTo [_obiect_lit, [0,-2,0]];
_obiect_dec = createVehicle ["Land_FloodLight_F", getpos _veh_armed, [], 0, "CAN_COLLIDE"];	_obiect_dec disableCollisionWith _veh_armed;
_obiect_dec attachTo [_veh_armed, [0,0,-0.2],_veh_turr_end,true];
_obiect_dec setDir ((getDir _veh_armed) - 90);
_obiect_lit setVectorDirAndUp [(_veh_armed selectionPosition _veh_turr_beg) vectorFromTo (_veh_armed selectionPosition _veh_turr_end),[0,0,1]];
_obiect_comp hideObjectGlobal false;
waitUntil {sleep 5; (!alive _veh_armed)};
deleteVehicle _obiect_lit;
deleteVehicle _obiect_comp;
deleteVehicle _obiect_dec;