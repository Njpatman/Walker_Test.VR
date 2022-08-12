[  
    "Walker",
    "Spawn Walker",
    {    
        private ["_pos", "_colors"];
        _colors = 
        [
            "_white_F",
            "_blue_F",
            "_red_F",
            "_cyan_F",
            "_yellow_F",
            "_grey_F",
            "_orange_F",
            "_sand_F",
            "_light_green_F",
            "_light_blue_F",
            "_brick_red_F",
            "_military_green_F"
        ];
        _colors_arrays = 
        [
            ["White", "", "", [1,1,1,0.85]],
            ["Blue", "", "", [0,0,1,0.85]],
            ["Red", "", "", [1,0,0,0.85]],
            ["Cyan", "", "", [0,1,1,0.85]],
            ["Yellow", "", "", [1,1,0,0.85]],
            ["Grey", "", "", [0.502,0.502,0.502,0.85]],
            ["Orange", "", "", [1,0.647,0,0.85]],
            ["Sand", "", "", [0.761,0.698,0.502,0.85]],
            ["Light Green", "", "", [0.565,0.933,0.565,0.85]],
            ["Light Blue", "", "", [0.678,0.847,0.902,0.85]],
            ["Brick Red", "", "", [0.796,0.255,0.329,0.85]],
            ["Military Green", "", "", [0.294,0.325,0.125,0.85]]
        ];
        _pos = (ASLToAGL (_this select 0));
        //Dialouge box for custom settings.
        ["Walker Options", 
            [
                ["SLIDER", ["Walker Speed", "Speed at which the Walker will move, note that higher speeds look excessively jank and will be mroe intensive on the server"], [1, 12, 2.85, 2]],
                ["SLIDER", ["Walker Legs", "How many legs on each side of the Walker"], [2, 4, 3, 0]],
                ["COMBO", ["Walker Height", "Height at which the Walker will move"], [["Low", "Medium", "High"], [["Low"], ["Medium"], ["High"]], 1]],
                ["COMBO", ["Walker Segment Color", "Walker Segment Color, Pretty Self Explanatory"], [_colors, _colors_arrays, 5]],
                ["COMBO", ["Walker Joint Color", "Walker Joint Color, Pretty Self Explanatory"], [_colors, _colors_arrays, 5]],
                ["SIDES", ["Walker Side", "Walker Side, sets Walkers weapons' side and is overridden by 'Everyone Hates Walker' & 'Walker Hates Everyone'"], east],    
                ["CHECKBOX", ["Everyone Hates Walker", "Everyone Hates the Walker and will engage it"], [false]],
                ["CHECKBOX", ["Walker Hates Everyone", "Walker Hates Everyone and will engage them with extreme prejudice"], [false]],
                ["CHECKBOX", ["Walker Has Weapons", "Walker Has Weapons"], [true]],
                ["CHECKBOX", ["Weapons Have Searchlights", "Walker Has Weapons"], [true]],
                ["CHECKBOX", ["Make Turrets Invincible", "The Walkers Weapons are invincible; This and 'Make Legs Invincible' will essentially make the Walker invincible"], [false]], 
                ["CHECKBOX", ["Make Legs Invincible", "The Walkers Legs are invincible; This and 'Make Turrets Invincible' will essentially make the Walker invincible"], [false]], 
                ["CHECKBOX", ["Make Weapons Fire Randomly", "The Walkers Weapons fires indiscriminately and randomly around it"], [false]] 
            ],
            {
                //Takes all the information from above and turns it into variables, then stuffs those variables into an array and executes it client side.
                params ["_dialog", "_args"];
                _args params ["_pos"];
                _dialog params 
                [
                    "_Walker_overall_speed", 
                    "_Walker_num_of_legs", 
                    "_Walker_walk_height", 
                    "_Walker_segment_color", 
                    "_Walker_joint_color",
                    "_Walker_side",
                    "_Walker_everybody_hates",
                    "_Walker_hates_everybody",
                    "_Walker_weapons_enabled",
                    "_Walker_searchlight_enabled",
                    "_Walker_weapons_invincible",
                    "_Walker_legs_invincible",
                    "_Walker_weapons_random"
                ];
                _Walker_side = [_Walker_side];
                [
                    _pos, 
                    _Walker_overall_speed, 
                    _Walker_walk_height, 
                    _Walker_num_of_legs, 
                    _Walker_segment_color, 
                    _Walker_joint_color,
                    _Walker_side,
                    _Walker_everybody_hates,
                    _Walker_hates_everybody,
                    _Walker_weapons_enabled,
                    _Walker_searchlight_enabled,
                    _Walker_weapons_invincible,
                    _Walker_legs_invincible,
                    _Walker_weapons_random
                ] remoteExec ["Walker_fnc_createWalker", 2, false];
            }, 
            {}, [_pos]
        ] call zen_dialog_fnc_create;
    }
] call zen_custom_modules_fnc_register;

[  
    "Walker",
    "Spawn Walker Horn",
    {    
        private ["_pos"];
        _pos = (ASLToAGL (_this select 0));
        //Dialouge box for custom settings.

        ["Walker Horn Options", 
            [
                ["SLIDER",["Sound Range","Range at which Players will hear the sound"], [100, 10000, 500, 0]]
            ],
            {
                //Takes all the information from above and turns it into variables, then stuffs those variables into an array and executes it client side.
                params ["_dialog", "_args"];
                _dialog params ["_Sound_Range"];
                _args params ["_pos"];
                [_pos, _Sound_Range] Spawn {
                    params ["_pos", "_Sound_Range"];
                    _Inv_Helipad = createVehicle ["Land_HelipadEmpty_F", _pos, [], 0, "CAN_COLLIDE"];
                    [_Inv_Helipad, ["Horn", _Sound_Range]] remoteExec ["say3D", 0, true];
                    uiSleep 18;
                    deleteVehicle _Inv_Helipad;
                };
            }, 
            {}, [_pos]
        ] call zen_dialog_fnc_create;
    }
] call zen_custom_modules_fnc_register;