params ["_tip", "_target", "_walker_minimum_distance", "_walker_leg_sleep"]; 
[ 
	{ 
		params ["_tip", "_target", "_walker_minimum_distance"]; 
		private _distancetoTarget = (getPosASL _tip) vectorDistance (getPosASL _target); 
		_distancetoTarget < _walker_minimum_distance 
	}, 
	{ 
		params ["_tip", "_target"]; 
		private _targetPos = getPos _target; 
		_targetPos set [2, -5]; 
		_sfx = selectRandom ["Step", "Step_2"];
		[_tip, [_sfx, 1250]] remoteExec ["say3D", 0, false];
		{ 
			_x setDamage 1; 
		} forEach (nearestTerrainObjects [_target, [], 10, false]); 
	}, 
	[_tip, _target, _walker_minimum_distance], 
	_walker_leg_sleep, 
	{} 
] call CBA_fnc_waitUntilAndExecute 