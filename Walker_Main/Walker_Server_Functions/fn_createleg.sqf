params 
[
	"_base", 
	"_target",
	"_grp",
	"_walker_point_max_rot_speed", 
	"_walker_arm_length", 
	"_walker_point_max_angle", 
	"_walker_total_leg_length", 
	"_walker_minimum_distance",
	"_walker_num_segments",
	"_walker_segment_object",
	"_walker_point_object",
	"_walker_max_iterations",
	"_AI_targets_main_array",
	"_walker_legs_invincible"
];
_segments = []; 
for "_i" from 1 to _walker_num_segments do { 
	private _segment_obj = _walker_segment_object createvehicle [0, 0, 0]; 
	_segments pushBack _segment_obj;
	_segment_obj setVariable ["destroyed", false]; 
}; 
_points = []; 
{ 
	private _pointobj = createvehicle [_walker_point_object, [0, 0, 0], [], 0, "NONE"]; 
	_points pushBack _pointobj;
	_pointobj setVariable ["destroyed", false];
} forEach _segments; 
_points_dmg = []; 
if !(_walker_legs_invincible) then {
	{ 
		_pointobj_dmg = "Land_PowerGenerator_F" createVehicle [0,0,0];
		_pointobj_dmg attachTo [_x,[0,0.35,-0.5]]; 
		_pointobj_dmg setVariable ["destroyed", false];
		_points_dmg pushBack _pointobj_dmg;
	} forEach _points;
};
{ 
	_x attachto [_points#_forEachindex, [0, _walker_arm_length/2, 0]]; 
	_x setDir 90; 
} forEach _segments;
_AI_target_obj_array = [];
for "_i" from 0 to (count _AI_targets_main_array) - 1 do { 
	_AI_targets = _AI_targets_main_array select _i;
	for "_e" from 0 to 2 do { 
		_AI_target = _AI_targets select _e;
		_AI_target_obj = _AI_target createVehicle getPosATL _legBase;
		_AI_target_obj attachTo [_legBase, [0,0,-0.895]];
		_AI_target_obj_array pushBack _AI_target_obj;
		_AI_target_obj allowDamage false;
		_man = _grp createUnit [(_AI_targets select 4), [0,0,0], [], 0, "CARGO"];
		waitUntil {!isNull _man};
		_man moveInAny _AI_target_obj;
	};
};
private _lastPoint = createvehicle [_walker_point_object, [0, 0, 0], [], 0, "NONE"]; 
_lastPoint setVariable ["destroyed", false]; 
_points pushBack _lastPoint;
_base setVariable ["Walker_points", _points]; 
_base setVariable ["Walker_segments", _segments]; 
_base setVariable ["Walker_points_dmg", _points_dmg];
_base setVariable ["_AI_target_obj_array", _AI_target_obj_array];
private _objects = _segments + _points + _points_dmg + _AI_target_obj_array + [_target]; 
_base setVariable ["Walker_objects", _objects]; 
_base setVariable ["Walker_target", _target]; 
_base setVariable ["Walker_currentEndPoint", [0, 0, 0]]; 
_handle = [{ 
	params ["_args", "_handle"]; 
	_args params 
	[
		"_base", 
		"_walker_point_max_rot_speed", 
		"_walker_arm_length", 
		"_walker_point_max_angle", 
		"_walker_total_leg_length", 
		"_walker_minimum_distance",
		"_walker_num_segments",
		"_walker_max_iterations"
	]; 
	private _points = _base getVariable "Walker_points"; 
	private _target = _base getVariable "Walker_target"; 
	[_base, ASLtoAGL (getPosASL _target), _walker_point_max_rot_speed, _walker_arm_length, _walker_point_max_angle, _walker_total_leg_length, _walker_minimum_distance, _walker_num_segments, _walker_max_iterations] call Walker_fnc_moveLeg; 
}, 0, [_base, _walker_point_max_rot_speed, _walker_arm_length, _walker_point_max_angle, _walker_total_leg_length, _walker_minimum_distance, _walker_num_segments, _walker_max_iterations]] call CBA_fnc_addPerFrameHandler; 
_base setVariable ["Walker_handle", _handle]; 