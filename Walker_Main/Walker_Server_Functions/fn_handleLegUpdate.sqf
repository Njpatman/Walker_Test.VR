params 
[
	"_core",  
	"_walker_num_segments", 
	"_walker_leg_neutral_position",  
	"_walker_minimum_distance",   
	"_walker_leg_sleep", 
	"_walker_leg_active_position"
];  
private _nextUpdate = _core getVariable "Walker_nextUpdate"; 
if (time > _nextUpdate) then { 
	_core setVariable ["Walker_nextUpdate", time + _walker_leg_sleep]; 
	private _phase = _core getVariable "Walker_phase"; 
	private _legGroup1 = _core getVariable "Walker_legGroup1"; 
	private _legGroup2 = _core getVariable "Walker_legGroup2"; 
	if !(_core getVariable "Walker_active") exitWith { 
		{ 
			[_x, false, _walker_leg_active_position, _walker_num_segments, _walker_minimum_distance, _walker_leg_sleep] call Walker_fnc_placeLegGroup; 
		} forEach [_legGroup1, _legGroup2]; 
		_core setVariable ["Walker_phase", 1]; 
	}; 
	switch _phase do { 
		case 0: { 
			[_legGroup2, nil, _walker_leg_active_position, _walker_num_segments, _walker_minimum_distance, _walker_leg_sleep] call Walker_fnc_placeLegGroup; 
			_core setVariable ["Walker_phase", 1]; 
		}; 
		case 1: { 
			[_legGroup1, _walker_leg_neutral_position] call Walker_fnc_liftLegGroup; 
			_core setVariable ["Walker_phase", 2]; 
		}; 
		case 2: { 
			[_legGroup1, nil, _walker_leg_active_position, _walker_num_segments, _walker_minimum_distance, _walker_leg_sleep] call Walker_fnc_placeLegGroup; 
			_core setVariable ["Walker_phase", 3]; 
		}; 
		case 3: { 
			[_legGroup2, _walker_leg_neutral_position] call Walker_fnc_liftLegGroup; 
			_core setVariable ["Walker_phase", 0]; 
		}; 
	}; 
}; 