
params ["_base", "_targetPos", "_walker_point_max_rot_speed", "_walker_arm_length", "_walker_point_max_angle", "_walker_total_leg_length", "_walker_minimum_distance", "_walker_num_segments", "_walker_max_iterations"]; 
private _origin = [0, 0, 0]; 
private _points = _base getVariable "Walker_points"; 
private _pointpositions = _points apply { 
	_base worldToModel (ASLtoAGL (getPosWorld _x)) 
}; 
private _targetPosmodelSpace = _base worldToModel _targetPos; 
private _targetDirto = _origin vectorFromTo _targetPosmodelSpace; 
if (_origin vectorDistance _targetPosmodelSpace > _walker_total_leg_length) then { 
	_targetPosmodelSpace = _targetDirto vectorMultiply (_walker_total_leg_length - _walker_minimum_distance); 
}; 
private _desiredDirs = [_base, _pointpositions, _origin, _targetPosmodelSpace, _walker_num_segments, _walker_point_max_angle, _walker_minimum_distance, _walker_arm_length, _walker_max_iterations] call Walker_fnc_fabrik; 
private _currentDirs = _points apply { 
	_base vectorworldToModel (vectorDir _x) 
}; 
[_base, _points, _currentDirs, _desiredDirs, _walker_point_max_rot_speed, _walker_arm_length, _walker_point_max_angle] call Walker_fnc_IKmove; 
