params ["_legGroup", ["_doEffect", true], "_walker_leg_active_position", "_walker_num_segments", "_walker_minimum_distance", "_walker_leg_sleep"]; 
{ 
	private _leg = _x; 
	private _target = _leg getVariable "Walker_target"; 
	private _pos = +_walker_leg_active_position; 
	_pos set [0, (_pos#0) * (_leg getVariable "Walker_side")]; 
	detach _target; 
	private _pos = (_leg modeltoWorldWorld _pos); 
	_pos set [2, 0]; 
	_target setPos _pos; 
	_target setvectorDirAndUp [[0, 1, 0], [0, 0, 1]]; 
	if (_doEffect) then { 
		[(_leg getVariable "Walker_points")#_walker_num_segments, _target, _walker_minimum_distance, _walker_leg_sleep] call Walker_fnc_legPlacedEffect; 
	}; 
} forEach _legGroup; 