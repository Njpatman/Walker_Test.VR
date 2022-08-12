params 
[
	"_pos", 
	"_walker_overall_speed", 
	"_walker_walk_height_param", 
	"_walker_num_of_legs",  
	"_walker_segment_color", 
	"_walker_joint_color",
	"_walker_side",
	"_walker_hates_everybody",
	"_walker_weapons_enabled",
	"_walker_searchlight_enabled",
	"_walker_weapons_invincible",
	"_walker_legs_invincible",
	"_walker_weapons_random"
];

_walker_num_of_legs = round _walker_num_of_legs;
_walker_walk_height = 20;
_walker_arm_length = 13;
_walker_num_segments = 4; 

switch (_walker_walk_height_param) do {
	case "Low": 
	{ 
		_walker_walk_height = 20;
		_walker_arm_length = 13;
		_walker_num_segments = 4; 
	};
	case "Medium": 
	{ 
		_walker_walk_height = 35;
		_walker_arm_length = 14;
		_walker_num_segments = (round (_walker_walk_height * 2) / _walker_arm_length); 
	};
	case "High": 
	{ 
		_walker_walk_height = 70;
		_walker_arm_length = 14;
		_walker_num_segments = (round (_walker_walk_height * 2) / _walker_arm_length); 
	};
	default {"Medium"};
};

_AI_targets = [];
_AI_targets_main_array = [];
if (_walker_hates_everybody) then {_walker_side = [sideEnemy];};
for "_e" from 0 to ((count _walker_side) - 1) do { 
	_side = _walker_side select _e;
	_side = str _side;
	switch (_side) do {
		case "WEST": 
		{ 
			_AI_targets = ["CBA_B_InvisibleTarget", "CBA_B_InvisibleTargetVehicle", "CBA_B_InvisibleTargetAir", WEST, "B_UAV_AI_F"];
		};
		case "EAST": 
		{ 
			_AI_targets = ["CBA_O_InvisibleTarget", "CBA_O_InvisibleTargetVehicle", "CBA_O_InvisibleTargetAir", EAST, "O_UAV_AI_F"];
		};
		case "GUER": 
		{ 
			_AI_targets = ["CBA_I_InvisibleTarget", "CBA_I_InvisibleTargetVehicle", "CBA_I_InvisibleTargetAir", independent, "I_UAV_AI_F"];
		};
		case "CIV": 
		{ 
			_AI_targets = ["CBA_I_InvisibleTarget", "CBA_I_InvisibleTargetVehicle", "CBA_I_InvisibleTargetAir", civilian, "C_UAV_AI_F"];
		};
		case "ENEMY": 
		{ 
			_AI_targets = ["CBA_I_InvisibleTarget", "CBA_I_InvisibleTargetVehicle", "CBA_I_InvisibleTargetAir", civilian, "C_UAV_AI_F"];
		};
		default {"EAST"};
	};
	_AI_targets_main_array pushBack _AI_targets;
};

_grp = createGroup (_AI_targets select 3);
_walker_point_max_rot_speed = (360/90) * (_walker_overall_speed / (_walker_num_segments)); 
_walker_total_leg_length = _walker_arm_length * _walker_num_segments; 
_walker_point_max_angle = 135/90; 
_walker_segment_object = ("Land_Cargo40" + _walker_segment_color); 
_walker_point_object = ("Land_Cargo10" + _walker_joint_color); 
_walker_target_object = "Land_HelipadEmpty_F";
_walker_leg_neutral_position = [-_walker_arm_length * 0.25, 2.25 * _walker_arm_length, 0.345 * _walker_walk_height]; 
_walker_leg_active_position = [-_walker_arm_length * 0, 2.25 * _walker_arm_length, 0]; 
_walker_max_iterations = 4; 
_walker_minimum_distance = 0.1; 
_walker_max_rot_speed = (5/90) * _walker_overall_speed; 
_walker_move_speed = 4 * _walker_overall_speed; 
_walker_leg_sleep = 1.865 / _walker_overall_speed; 

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

_core = createVehicle ["Submarine_01_F", [(_pos select 0), (_pos select 1), (_pos select 2) + 20], [], 0, "NONE"]; 
_core setVectorUp (surfaceNormal position _core);
_core enableSimulationGlobal false;
private _tractor = createVehicle ["C_Tractor_01_F", [0,0,100000], [], 0, "NONE"]; 
_core_2 = createVehicle ["Submarine_01_F",[0,0,10000] , [], 0, "NONE"]; 
_tractor allowDamage false; 
_human = _grp createUnit [(_AI_targets select 4), _core, [], 0, "NONE"]; 
_human moveInDriver _tractor; 
_core allowDamage false;
_core_2 allowDamage false;  
_human disableAI "all"; 
_human allowDamage false; 
_tractor attachto [_core, [0, 15, 6.25]]; 
_core_2 attachto [_core, [0, 0, 0]];
_core_Dir = getDir _core;
_core_2 setDir (_core_Dir + 180);
_core setVariable ["Walker_group", _grp]; 
_core setVariable ["Walker_driver", _human];
_core setVariable ["legs_destroyed", 0]; 
private _bbr = boundingBoxReal _core;
private _p1 = _bbr select 0;
private _p2 = _bbr select 1;
private _bodyWidth = abs ((_p2 select 0) - (_p1 select 0));
_bodyWidth = _bodyWidth - 6.5;
private _bodyLength = abs ((_p2 select 1) - (_p1 select 1));
private _height = abs ((_p2 select 2) - (_p1 select 2));
_height = _height - (_height + 8.5);
private _handles = []; 
private _objects = [_core, _tractor, _human]; 
private _leg_arrays = []; 
_core setVariable ["Walker_handles", _handles]; 
_core setVariable ["Walker_objects", _objects]; 
_core setVariable ["Walker_phase", 0]; 
_core setVariable ["Walker_nextUpdate", time + 5];
private _legs = []; 
_turret_array = [];

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

if (_walker_weapons_enabled) then {
	_turret = createVehicle ["B_SAM_System_01_F", [0,0,999935], [], 0, "NONE"]; 
	_turret attachto [_core, [0, -15, 9.25]];
	_turret setDir (_core_Dir + 180);
	_turret_array pushBack [_turret, true];

	_turret = createVehicle ["B_SAM_System_01_F", [0,0,999535], [], 0, "NONE"]; 
	_turret attachto [_core, [0, 15, 9.25]]; 
	_turret_array pushBack [_turret, true];

	_turret = createVehicle ["I_E_UGV_01_rcws_F", [0,0,999035], [], 0, "NONE"]; 
	_turret attachto [_core, [1, 26.5, 4]]; 
	_turret_array pushBack [_turret, true];

	_turret = createVehicle ["I_E_UGV_01_rcws_F", [0,0,998535], [], 0, "NONE"]; 
	_turret attachto [_core, [-1, -26.5, 4]]; 
	_turret setDir (_core_Dir + 180);
	_turret_array pushBack [_turret, true];

	_turret = createVehicle ["I_E_UGV_01_rcws_F", [0,0,999035], [], 0, "NONE"]; 
	_turret attachto [_core, [-1.985, 26.5, 4]]; 
	_turret_array pushBack [_turret, true];

	_turret = createVehicle ["I_E_UGV_01_rcws_F", [0,0,998535], [], 0, "NONE"]; 
	_turret attachto [_core, [1.985, -26.5, 4]]; 
	_turret setDir (_core_Dir + 180);
	_turret_array pushBack [_turret, true];

	_turret = createVehicle ["I_E_UGV_01_rcws_F", [0,0,999035], [], 0, "NONE"]; 
	_turret attachto [_core, [-1.985, 0, 4]]; 
	_turret_array pushBack [_turret, true];

	_turret = createVehicle ["I_E_UGV_01_rcws_F", [0,0,999035], [], 0, "NONE"]; 
	_turret attachto [_core, [1, 0, 4]]; 
	_turret_array pushBack [_turret, true];

	_turret = createVehicle ["B_UGV_01_rcws_F", [0,0,997535], [], 0, "NONE"]; 
	_turret attachto [_core, [2.65, 16.5, 4.55]]; 
	// set exact yaw, pitch, and roll
	_y = 0; _p = 0; _r = 50;
	_turret setVectorDirAndUp [
		[sin _y * cos _p, cos _y * cos _p, sin _p],
		[[sin _r, -sin _p, cos _r * cos _p], -_y] call BIS_fnc_rotateVector2D
	];
	_turret_array pushBack [_turret, true];

	_turret = createVehicle ["B_T_UGV_01_rcws_olive_F", [0,0,996535], [], 0, "NONE"]; 
	_turret attachto [_core, [-3, 16.5, 4.15]]; 
	// set exact yaw, pitch, and roll
	_y = 0; _p = 0; _r = -50;
	_turret setVectorDirAndUp [
		[sin _y * cos _p, cos _y * cos _p, sin _p],
		[[sin _r, -sin _p, cos _r * cos _p], -_y] call BIS_fnc_rotateVector2D
	];
	_turret_array pushBack [_turret, true];

	_turret = createVehicle ["B_UGV_01_rcws_F", [0,0,995535], [], 0, "NONE"]; 
	_turret attachto [_core, [2.65, -16.5, 4.55]]; 
	// set exact yaw, pitch, and roll
	_y = 0; _p = 0; _r = 50;
	_turret setVectorDirAndUp [
		[sin _y * cos _p, cos _y * cos _p, sin _p],
		[[sin _r, -sin _p, cos _r * cos _p], -_y] call BIS_fnc_rotateVector2D
	];
	_turret_array pushBack [_turret, true];

	_turret = createVehicle ["B_T_UGV_01_rcws_olive_F", [0,0,994535], [], 0, "NONE"]; 
	_turret attachto [_core, [-3, -16.5, 4.15]]; 
	// set exact yaw, pitch, and roll
	_y = 0; _p = 0; _r = -50;
	_turret setVectorDirAndUp [
		[sin _y * cos _p, cos _y * cos _p, sin _p],
		[[sin _r, -sin _p, cos _r * cos _p], -_y] call BIS_fnc_rotateVector2D
	];
	_turret_array pushBack [_turret, true];

	_turret = createVehicle ["B_UGV_01_rcws_F", [0,0,994535], [], 0, "NONE"]; 
	_turret attachto [_core, [3.65, 0, 2.15]]; 
	// set exact yaw, pitch, and roll
	_y = 0; _p = 0; _r = 50;
	_turret setVectorDirAndUp [
		[sin _y * cos _p, cos _y * cos _p, sin _p],
		[[sin _r, -sin _p, cos _r * cos _p], -_y] call BIS_fnc_rotateVector2D
	];
	_turret_array pushBack [_turret, true];

	_turret = createVehicle ["B_T_UGV_01_rcws_olive_F", [0,0,994535], [], 0, "NONE"]; 
	_turret attachto [_core, [-4.15, 0, 1.685]]; 
	// set exact yaw, pitch, and roll
	_y = 0; _p = 0; _r = -50;
	_turret setVectorDirAndUp [
		[sin _y * cos _p, cos _y * cos _p, sin _p],
		[[sin _r, -sin _p, cos _r * cos _p], -_y] call BIS_fnc_rotateVector2D
	];
	_turret_array pushBack [_turret, true];

	for "_i" from 0 to ((count _turret_array) - 1) do {
		_loc_turret_array = _turret_array select _i; 
		_turret = _loc_turret_array select 0;
		_turret_bool = _loc_turret_array select 1;
		uiSleep 0.15;
		if (!isNull _turret) then {
			if (!(typeOf _turret isEqualTo "B_SAM_System_01_F") && _walker_searchlight_enabled) then {[_turret] spawn Walker_fnc_turretSearchlight;};
			if (_walker_weapons_invincible) then { _turret allowDamage false; };
			_turret allowCrewInImmobile true;
			_turret addEventHandler ["Fired",{(_turret select 0) setVehicleAmmo 1}];
			_man = _grp createUnit [(_AI_targets select 4), (getPosATL _turret), [], 0, "CARGO"];
			_man allowDamage false;
			waitUntil {!isNull _man};
			_man additem "NVGoggles";
			_man moveInGunner _turret;
			if (typeOf _turret isEqualTo "B_SAM_System_01_F") then {
				_turret setObjectTextureGlobal [0, '#(rgb,8,8,3)color(0.125,0.125,0.135,0.15)'];
				_turret setObjectTextureGlobal [1, '#(rgb,8,8,3)color(0.125,0.125,0.135,0.15)'];
				_turret setObjectTextureGlobal [2, '#(rgb,8,8,3)color(0.125,0.125,0.135,0.15)'];
			};
			if (typeOf _turret isEqualTo "I_E_UGV_01_rcws_F") then {
				_turret removeWeaponTurret ["GMG_40mm", [0]];
				_turret removeWeaponTurret ["HMG_127_UGV", [0]];
				_turret addWeaponTurret ["M134_minigun",[0]];
				_turret addWeaponTurret ["launcher_SPG9",[0]];
				for "_i" from 1 to 10 do { _turret addMagazineTurret ["5000Rnd_762x51_Belt",[0]]; };
				for "_i" from 1 to 8 do { _turret addMagazineTurret ["12rnd_SPG9_HEAT",[0]]; };
				_turret setObjectTextureGlobal [0, '#(rgb,8,8,3)color(0.125,0.125,0.135,0.15)'];
				_turret setObjectTextureGlobal [1, '#(rgb,8,8,3)color(0.125,0.125,0.135,0.15)'];
				_turret setObjectTextureGlobal [2, '#(rgb,8,8,3)color(0.125,0.125,0.135,0.15)'];
			};
			if (typeOf _turret isEqualTo "B_UGV_01_rcws_F" || typeOf _turret isEqualTo "B_T_UGV_01_rcws_olive_F") then {
				_turret removeWeaponTurret ["GMG_40mm", [0]];
				_turret removeWeaponTurret ["HMG_127_UGV", [0]];
				_turret addWeaponTurret ["HMG_M2",[0]];
				_turret addWeaponTurret ["launcher_SPG9",[0]];
				for "_i" from 1 to 100 do { _turret addMagazineTurret ["100Rnd_127x99_mag_Tracer_Red",[0]]; };
				for "_i" from 1 to 8 do { _turret addMagazineTurret ["12rnd_SPG9_HEAT",[0]]; };
				_turret setObjectTextureGlobal [0, '#(rgb,8,8,3)color(0.125,0.125,0.135,0.15)'];
				_turret setObjectTextureGlobal [1, '#(rgb,8,8,3)color(0.125,0.125,0.135,0.15)'];
				_turret setObjectTextureGlobal [2, '#(rgb,8,8,3)color(0.125,0.125,0.135,0.15)'];
			};
			_turret setVariable ["ace_cookoff_enableAmmoCookoff", false];
			_turret setVariable ["ace_cookoff_enable", false];
			_turret disableNVGEquipment false;
			_turret disableTIEquipment false;
			if (_turret_bool) then {
				[_turret, 4, _walker_weapons_random, _grp, _turret] Spawn {
					params ["_vik", "_delay", "_fire_y", "_grp", "_turret"];
					_ai_scan = gunner _vik;
					_rnd_fct = 0; 
					if (_fire_y) then {
						_tur_lans = (_vik weaponsTurret [0] select 0);
						[_vik, _tur_lans] Spawn {
							params ["_vik", "_tur_lans"];
							sleep 10;
							while {canFire _vik} do 
							{
								_burst = floor (random 15);
								while {_burst >0} do {_vik fire _tur_lans;_burst = _burst -1;sleep 0.1};
								sleep 1 + (random 5);
							};
						};
					};
					while {alive _ai_scan} do 
					{
						_angle = [(random 360),(random 360)*(-1)]call BIS_fnc_selectRandom;
						_altitude = [55, 90] call BIS_fnc_randomInt;
						if (typeOf _turret isEqualTo "B_UGV_01_rcws_F" || typeOf _turret isEqualTo "B_T_UGV_01_rcws_olive_F") then {
							_angle = [(random 180),0*(-1)]call BIS_fnc_selectRandom;
							_int = [35, 90] call BIS_fnc_randomInt;
							_altitude = -_int;
						};
						if (_altitude>0) then {_rnd_fct = 50} else {_rnd_fct=0};
						if (typeOf _turret isEqualTo "B_T_UGV_01_rcws_olive_F") then { _angle = [-(random 180),0*(-1)]call BIS_fnc_selectRandom; };
						if !((combatMode _grp) isEqualTo "RED") then {
							_ai_scan enableAI "move";
							_ai_scan enableAI "target";
							_ai_scan enableAI "autotarget";
							_ini_poz = getposASL _ai_scan;
							_ini_dir = getdir _ai_scan;
							_watchpos = _ini_poz getPos [20+(random 100),_ini_dir+_angle];
							_watchpos = [_watchpos select 0, _watchpos select 1, (_watchpos select 2) + _altitude + (random _rnd_fct)];
							_ai_scan dowatch _watchpos;
							sleep _delay + (random 3);
						};
					};
				};
			};
		};
	};
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

for "_pair" from 1 to _walker_num_of_legs do { 
	uiSleep 0.65;
	private _posY = _pair * _bodyLength/_walker_num_of_legs;
	_posY = _posY - _bodyLength * 0.645; 
	if (_walker_num_of_legs isEqualTo 1) then {
		_posY = _posY - _bodyLength * 0.385; 
	};
	if (_walker_num_of_legs isEqualTo 2) then {
		_posY = _posY - _bodyLength * 0.135; 
	};
	for "_side" from -1 to 1 step 2 do { 
		uiSleep 0.85;
		private _posX = _side * _bodyWidth/4; 
		private _legBasePos = [_posX, _posY, _height]; 
		private _legDir = _side * 90; 
		_legBase = _walker_target_object createvehicle [0, 0, 0]; 
		_legBase attachto [_core, _legBasePos]; 
		_legBase setDir _legDir; 
		_legBase setVariable ["on_fire", false];
		_legBase setVariable ["destroyed", true]; 
		private _legTarget = "Land_InvisibleBarrier_F" createvehicle [0, 0, 0];
		_legTarget setVariable ["destroyed", false]; 
		private _legTargetPos = _legBase modelToWorldWorld [0, 3 * _walker_total_leg_length, 3 * _walker_total_leg_length]; 
		_legTarget setPosASL _legTargetPos; 
		_legs pushBack _legBase; 
		_legBase setVariable ["Walker_side", _side]; 
		[
			_legBase, 
			_legTarget,
			_grp,
			_walker_point_max_rot_speed, 
			_walker_arm_length, 
			_walker_point_max_angle, 
			_walker_total_leg_length, 
			_walker_minimum_distance,
			_walker_num_segments,
			_walker_segment_object,
			_walker_point_object,
			_walker_max_iterations,
			_AI_targets_main_array,
			_walker_legs_invincible
		] call Walker_fnc_createLeg; 
		private _handle = _legBase getVariable "Walker_handle"; 
		_handles pushBack _handle; 
		_objects append (_legBase getVariable "Walker_objects"); 
		_loc_array= [];
		_loc_array pushBack _handle;
		_loc_array pushBack _legBase;
		_loc_array pushBack _legTarget;
		_loc_array append (_legBase getVariable "_AI_target_obj_array");
		_loc_array append (_legBase getVariable "Walker_segments");
		_loc_array append (_legBase getVariable "Walker_points");
		_loc_array append (_legBase getVariable "Walker_points_dmg");
		_leg_arrays pushBack _loc_array;
	}; 
}; 

_legGroup1 = []; 
_legGroup2 = []; 

if (_walker_num_of_legs isEqualTo 1) then {
	_legGroup1 = [_legs#0]; 
	_legGroup2 = [_legs#1]; 
};
if (_walker_num_of_legs isEqualTo 2) then {
	_legGroup1 = [_legs#0, _legs#3]; 
	_legGroup2 = [_legs#1, _legs#2]; 
};
if (_walker_num_of_legs isEqualTo 3) then {
	_legGroup1 = [_legs#0, _legs#3, _legs#4]; 
	_legGroup2 = [_legs#1, _legs#2, _legs#5]; 
};
if (_walker_num_of_legs isEqualTo 4) then {
	_legGroup1 = [_legs#0, _legs#3, _legs#4, _legs#7]; 
	_legGroup2 = [_legs#1, _legs#2, _legs#5, _legs#6]; 
};

_core setVariable ["Walker_legGroup1", _legGroup1]; 
_core setVariable ["Walker_legGroup2", _legGroup2];
_core setVariable ["legs_base", _legs]; 

[_tractor, _core] spawn { 
	params ["_tractor", "_core"]; 
	waitUntil {sleep 1; time > 5}; 
	{ 
		_x addCuratorEditableObjects [[_tractor, _core], true]; 
	} forEach (allCurators); 
}; 

_core enableSimulationGlobal true;

private _handle = [{ 
	params ["_args", "_handle"]; 
	_args params 
	[
		"_core", 
		"_walker_num_segments", 
		"_walker_walk_height", 
		"_walker_leg_neutral_position",  
		"_walker_minimum_distance", 
		"_walker_max_rot_speed", 
		"_walker_move_speed", 
		"_walker_leg_sleep", 
		"_walker_leg_active_position",
		"_walker_point_object"
	];

	[	
		_core, 
		_walker_walk_height, 
		_walker_max_rot_speed, 
		_walker_move_speed
	] call Walker_fnc_handlePosUpdate; 

	[	
		_core,  
		_walker_num_segments, 
		_walker_leg_neutral_position,  
		_walker_minimum_distance,   
		_walker_leg_sleep, 
		_walker_leg_active_position
	] call Walker_fnc_handleLegUpdate; 

}, 0, [		
	_core, 
	_walker_num_segments, 
	_walker_walk_height, 
	_walker_leg_neutral_position,  
	_walker_minimum_distance, 
	_walker_max_rot_speed, 
	_walker_move_speed, 
	_walker_leg_sleep, 
	_walker_leg_active_position,
	_walker_point_object
]] call CBA_fnc_addPerFrameHandler; 
_handles pushBack _handle; 

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

uiSleep 5;

[_human, _core] Spawn {
	params ["_human", "_core"];
	while {alive _human} do {
		[_core, ["Ambience", 2000]] remoteExec ["say3D", 0, false];
		uiSleep 30;
	};
};

[_human, _core_2] Spawn {
	params ["_human", "_core_2"];
	while {alive _human} do {
		[_core_2, ["Horn", 4500]] remoteExec ["say3D", 0, false];\
		_time = [120, 280] call BIS_fnc_randomInt;
		uiSleep _time;
	};
};


_legs_destroyed = _core getVariable "legs_destroyed"; 

while {alive _human} do {

	private _objects = _core getVariable "Walker_objects";  
	private _objectsMissing = _objects find objNull != -1;
	_legs_destroyed = _core getVariable "legs_destroyed"; 
	_override = false;

	for "_i" from 0 to ((count _leg_arrays) - 1) do {
		leg_object_destroyed = false;
		_leg_array = _leg_arrays select _i; 
		{  
			if (typename _x  != typename 0) then {
				_destroyed = _x getVariable "destroyed";
				if (!isNil "_destroyed") then {
					if (!alive _x && !_destroyed) then {
						leg_object_destroyed = true;
						_x setVariable ["destroyed", true];
					};
				};
			};
		} forEach _leg_array;
		if (leg_object_destroyed) then {
			[_core, _walker_point_object, _leg_array, _walker_segment_object] spawn {
				params ["_core", "_walker_point_object", "_leg_array", "_walker_segment_object"]; 
				{
					if (typename _x  != typename 0) then {
						if (typeOf _x isEqualTo _walker_point_object) then {
							_bomb = "ammo_Bomb_SDB" createvehicle getPosATL _x;
							triggerAmmo _bomb;
							uiSleep 0.125;
						};

						if (typeOf _x isEqualTo "Land_HelipadEmpty_F") then {
							_x setVariable ["on_fire", true];

							private["_pos","_fire","_smoke"];
							private["_light","_brightness","_color","_ambient","_intensity","_attenuation"];

							_pos = getPosASL _x;

							_fire = "BigDestructionFire";
							_brightness	= 4.0;
							_intensity = 1600;
							_attenuation = [0,0,0,1.6];
							_color = [1,0.85,0.6];
							_ambient = [1,0.3,0];

							if (!isNil "_fire") then {
								_eFire = "#particlesource" createVehicle _pos;
								_eFire attachTo [_x, [0, 0, 0]];
								_eFire setParticleClass _fire;
								_eFire setPosATL _pos;
							};

							_smoke = createVehicle ["test_EmptyObjectForSmoke", getPos _X, [], 0, "NONE"];
							_smoke attachTo [_x, [0,0,0]];

							//create lightsource
							_pos   = [_pos select 0,_pos select 1,(_pos select 2)+1];
							_light = createVehicle ["#lightpoint", _pos, [], 0, "CAN_COLLIDE"];
							_light attachTo [_x, [0, 0, 0]];
							[_light, _brightness] remoteExec ["setLightBrightness", 0];
							[_light, _color] remoteExec ["setLightColor", 0];
							[_light, _ambient] remoteExec ["setLightAmbient", 0];
							[_light, _intensity] remoteExec ["setLightIntensity", 0];
							[_light, _attenuation] remoteExec ["setLightAttenuation", 0];
							[_light, false] remoteExec ["setLightDayLight", 0];
						};
					};
				} forEach _leg_array;
				(_leg_array select 0) call CBA_fnc_removePerFrameHandler;
				{
					if (typename _x  != typename 0) then {
						deleteVehicleCrew _x;
						if !(typeOf _x isEqualTo "Land_HelipadEmpty_F") then {
							if (typeOf _x isEqualTo _walker_segment_object) then { detach _x; } else { deletevehicle _x; };
						};
						if (!alive _x) then { deletevehicle _x; };
					};
				} forEach _leg_array;
				_legs_destroyed = _core getVariable "legs_destroyed";
				_legs_destroyed = _legs_destroyed + 1;
				_core setVariable ["legs_destroyed", _legs_destroyed];
			};
			leg_object_destroyed = false; 
		};
	}; 

	if (_legs_destroyed >= (count _leg_arrays * 0.5)) then { deleteVehicle _tractor; _tractor deleteVehicleCrew _human; };

	uiSleep 2.85;
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

private _handles = _core getVariable "Walker_handles"; 
[_core, _walker_num_of_legs] spawn {
	params ["_core", "_walker_num_of_legs"];
	_leg_array_main = _core getVariable "legs_base"; 
	{ 
		_bomb = "Bomb_03_F" createvehicle position _x;
		triggerAmmo _bomb;
		if (_walker_num_of_legs isEqualTo 2 || _walker_num_of_legs isEqualTo 1) then {
			_on_fire = _x getVariable "on_fire";
			if (!_on_fire) then {
				_x setVariable ["on_fire", true];
				private["_pos","_fire","_smoke"];
				private["_light","_brightness","_color","_ambient","_intensity","_attenuation"];

				_pos = getPosASL _x;

				_fire = "BigDestructionFire";
				_brightness	= 4.0;
				_intensity = 1600;
				_attenuation = [0,0,0,1.6];
				_color = [1,0.85,0.6];
				_ambient = [1,0.3,0];

				if (!isNil "_fire") then {
					_eFire = "#particlesource" createVehicle _pos;
					_eFire attachTo [_x, [0, 0, 0]];
					_eFire setParticleClass _fire;
					_eFire setPosATL _pos;
				};

				_smoke = createVehicle ["test_EmptyObjectForSmoke", getPos _X, [], 0, "NONE"];
				_smoke attachTo [_x, [0,0,0]];

				//create lightsource
				_pos   = [_pos select 0,_pos select 1,(_pos select 2)+1];
				_light = createVehicle ["#lightpoint", _pos, [], 0, "CAN_COLLIDE"];
				_light attachTo [_x, [0, 0, 0]];
				[_light, _brightness] remoteExec ["setLightBrightness", 0];
				[_light, _color] remoteExec ["setLightColor", 0];
				[_light, _ambient] remoteExec ["setLightAmbient", 0];
				[_light, _intensity] remoteExec ["setLightIntensity", 0];
				[_light, _attenuation] remoteExec ["setLightAttenuation", 0];
				[_light, false] remoteExec ["setLightDayLight", 0];
			};
		};

		_legs_destroyed = _core getVariable "legs_destroyed";
		_legs_destroyed = _legs_destroyed + 1;
		_core setVariable ["legs_destroyed", _legs_destroyed];
		uiSleep 0.65; 
	} forEach _leg_array_main;
};
_handle call CBA_fnc_removePerFrameHandler;
_vel = velocity _core;
[_legGroup2, nil, _walker_leg_active_position, _walker_num_segments, _walker_minimum_distance, _walker_leg_sleep] call Walker_fnc_placeLegGroup; 
[_legGroup1, nil, _walker_leg_active_position, _walker_num_segments, _walker_minimum_distance, _walker_leg_sleep] call Walker_fnc_placeLegGroup; 
_speed = 32;
_dir = getDir _core;
_core setVelocity [(_vel select 0) + (sin _dir * _speed), (_vel select 1) + (cos _dir * _speed), (_vel select 2)];
[_core, ["Horn", 4500]] remoteExec ["say3D", 0, false];
uiSleep 6.15;
{ 
	if (typeOf _x isEqualTo _walker_point_object) then {
		_explosion = selectRandom [true, false , false];
		if (_explosion) then {
			_bomb = "ammo_Bomb_SDB" createvehicle getPosATL _x;
			triggerAmmo _bomb; 
		};
		deleteVehicle _x;
	}; 
	deleteVehicleCrew _x;
	if (typeOf _x isEqualTo "Land_PowerGenerator_F" || !alive _x) then { deleteVehicle _x; };
	if (typeOf _x isEqualTo _walker_segment_object) then {
		_deletion = selectRandom [true, true, false];
		if (_deletion) then {
			deleteVehicle _x; 
		};
	};
	if !(typeOf _x isEqualTo "Land_HelipadEmpty_F" || typeOf _x isEqualTo "Submarine_01_F") then {
		if (typeOf _x isEqualTo _walker_segment_object) then { detach _x; } else { deletevehicle _x; };
	};
} forEach _objects;
if (_walker_weapons_enabled) then {
	{
		_deletion = selectRandom [true, true, false];
		_turret = _x select 0; 
		deleteVehicleCrew _turret;
		_turret setDamage 1;
		if (_deletion) then {
			deleteVehicle _turret;
		};
	} forEach _turret_array;
};
{  
	_x call CBA_fnc_removePerFrameHandler; 
} forEach _handles;
uiSleep 20;
{ if (typeOf _x isEqualTo "Submarine_01_F") then {} else { _x enableSimulationGlobal false; };} forEach _objects;
uiSleep 600;
{ if (typeOf _x isEqualTo "Submarine_01_F") then {_x enableSimulationGlobal false;} else { deletevehicle _x; }; } forEach _objects;