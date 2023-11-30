/**************************************************************************/
/*	sh_enum.lua											              */
/**************************************************************************/
/*                      This file is a part of PLUTONIC                   */
/*                              (c) 2022-2023                             */
/*                  Written by Sophie (github.com/sophfee)                */
/**************************************************************************/
/* Copyright (c) 2022-2023 Sophie S. (https://github.com/sophfee)         */
/* Copyright (c) 2019-2021 Jake Green (https://github.com/vingard)        */
/*                                                                        */
/* Permission is hereby granted, free of charge, to any person obtaining  */
/* a copy of this software and associated documentation files (the        */
/* "Software"), to deal in the Software without restriction, including    */
/* without limitation the rights to use, copy, modify, merge, publish,    */
/* distribute, sublicense, and/or sell copies of the Software, and to     */
/* permit persons to whom the Software is furnished to do so, subject to  */
/* the following conditions:                                              */
/*                                                                        */
/* The above copyright notice and this permission notice shall be         */
/* included in all copies or substantial portions of the Software.        */
/*                                                                        */
/* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,        */
/* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF     */
/* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. */
/* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY   */
/* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,   */
/* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE      */
/* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                 */
/**************************************************************************/

--- Enumerations used throughout Plutonic.
-- @module Enum
Plutonic.Enum = Plutonic.Enum or {}
Plutonic.Enum.WeaponType = {
	SubmachineGun = 1,
	AutomaticRifle = 2,
	MarksmanRifle = 3,
	Pistol = 5,
	Sniper = 6,
	Shotgun = 7
}

--- The different types of weaponry.
-- @realm shared
-- @field SubmachineGun
-- @field AutomaticRifle
-- @field MarksmanRifle
-- @field Pistol
-- @field Sniper
-- @field Shotgun
-- @table WeaponType
Plutonic.Enum.BarrelLength = {
	Short = 5.04,
	Medium = 10.16,
	Long = 15.24,
	Custom = function(len) return len end
}

-- we do this cus it looks cool
--- The different barrel lengths. Generally use Custom.
-- @realm shared
-- @field Short
-- @field Medium
-- @field Long
-- @field Custom
-- @table BarrelLength
Plutonic.Enum.Modification = {
	BarrelExtension = "barrel_ext",
	Barrel = "barrel",
	Stock = "stock",
	Optic = "sight",
	Handguard = "handguard",
	Foregrip = "grip",
	Rail = "att",
	Trigger = "trigger"
}

--- The different types of modifications.
-- @realm shared
-- @field BarrelExtension
-- @field Barrel
-- @field Stock
-- @field Optic
-- @field Handguard
-- @field Foregrip
-- @field Rail
-- @field Trigger
-- @table Modification
Plutonic.Enum.Sound = {
	GunShot = 140,
	GunShotSilence = 85,
	Generic = 60
}

Plutonic.Enum.FireMode = {Safety, Semi, Burst, Auto}
Plutonic.Enum.ANIMATION_PROCEDURAL = 0
Plutonic.Enum.ANIMATION_ACTIVITY = 1
Plutonic.Enum.ANIMATION_SEQUENCE = 2
Plutonic.Enum.ANIMATION_TYPE = {
	Procedural = Plutonic.Enum.ANIMATION_PROCEDURAL,
	Activity = Plutonic.Enum.ANIMATION_ACTIVITY,
	Sequence = Plutonic.Enum.ANIMATION_SEQUENCE
}

Plutonic.Enum.Value = 0x1
Plutonic.Enum.ValueIfEmpty = 0x2
Plutonic.Enum.ValueIfForegrip = 0x3
Plutonic.Enum.ValueIfForegripAndEmpty = 0x4
VECTOR_UP = Angle():Up()
VECTOR_RIGHT = Angle():Right()
VECTOR_FORWARD = Angle():Forward()