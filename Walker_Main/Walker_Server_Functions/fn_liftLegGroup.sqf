params ["_leggroup", "_walker_leg_neutral_position"]; 
{ 
	private _leg = _x; 
	_sfx = selectRandom ["Joint", "Joint_2"];
	[_leg, [_sfx, 850]] remoteExec ["say3D", 0, false];
	private _pos = + _walker_leg_neutral_position; 
	_pos = _leg modeltoWorld _pos; 
	_pos set [0, (_pos#0) * (_leg getVariable "Walker_side")]; 
	_pos set [2, _walker_leg_neutral_position#2]; 
	_pos set [0, (_pos#0) * (_leg getVariable "Walker_side")]; 
	private _target = _leg getVariable "Walker_target"; 
	_target setPosASL (AGLtoASL _pos); 
} forEach _leggroup; 