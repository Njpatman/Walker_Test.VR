params ["_prevDir", "_targetDir", "_walker_point_max_angle"]; 
private _constDiff = _targetDir vectorDiff _prevDir; 
private _constMagnitude = vectorMagnitude _constDiff; 
if (_constMagnitude > _walker_point_max_angle) then { 
	_targetDir = _prevDir vectorAdd (_constDiff vectorMultiply _walker_point_max_angle/_constMagnitude); 
}; 
_targetDir 