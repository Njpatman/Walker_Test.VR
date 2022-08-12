params 
[
	"_core", 
	"_walker_walk_height", 
	"_walker_max_rot_speed", 
	"_walker_move_speed" 
]; 
private _group = _core getVariable "Walker_group"; 
private _start = getPosASL _core; 
private _pivot = _core worldToModel (ASLtoAGL _start); 
_start set [2, (getTerrainHeightASL _start) + _walker_walk_height]; 
private _currentWaypointindex = (currentWaypoint _group); 
private _hasWaypoint = count (waypoints _group) > 1; 
private _end = if (_hasWaypoint) then { 
	private _wpPos = waypointPosition [_group, _currentWaypointindex]; 
	AGLtoASL _wpPos; 
} else { _start; }; 
private _distancetoTarget = _start distance2D _end; 
private _active = _distancetoTarget > 20; 
if (!_active && _hasWaypoint) then { 
	deleteWaypoint [_group, (currentWaypoint _group)]; 
}; 
_core setVariable ["Walker_active", _active]; 
private _deltaT = 1/diag_fps; 
private _velocityAdd = [0, 0, 9.81*_deltaT]; 
private _currentDir = vectorDir _core; 
private _currentUp = vectorUp _core; 
if !(_active) exitwith { 
	_core setvelocityTransformation [ 
		_start, 
		_start, 
		_velocityAdd, 
		_velocityAdd, 
		_currentDir, 
		_currentDir, 
		_currentUp, 
		_currentUp, 
		1, 
		_pivot 
	]; 
}; 
private _dirtoTarget = _start vectorFromTo _end; 
private _newDir = [_currentDir, _dirtoTarget, _deltaT, _walker_max_rot_speed] call Walker_fnc_speedConstraint; 
private _velocity = (_newDir vectorMultiply (_walker_move_speed * _deltaT)); 
	
private _velocityNetwork = _velocity vectorAdd _velocityAdd; 
private _newPos = _start vectorAdd _velocity; 
_newPos set [2, (getTerrainHeightASL _newPos) + _walker_walk_height]; 
private _offset = _newDir vectorMultiply 40; 
private _front = _newPos vectorAdd _offset; 
private _back = _newPos vectorAdd (_offset vectorMultiply -1); 
{ 
	_x set [2, getTerrainHeightASL _x]; 
} forEach [_front, _back]; 
private _actualnewDir = _back vectorFromTo _front; 
	
private _targetUp = surfaceNormal _newPos; 
private _newUp = [_currentUp, _targetUp, _deltaT, _walker_max_rot_speed] call Walker_fnc_speedConstraint; 
_core setvelocityTransformation [ 
	_start, 
	_newPos, 
	_velocityNetwork, 
	_velocityNetwork, 
	_currentDir, 
	_actualnewDir, 
	_currentUp, 
	_newUp, 
	1, 
	_pivot 
]; 