/**************************************************************************/
/*	cl_settings.lua 											          */
/**************************************************************************/
/*                      This file is a part of PLUTONIC                   */
/*                              (c) 2022-2023                             */
/*                  Written by Sophie (github.com/sophfee)                */
/**************************************************************************/
/* Copyright (c) 2022-2023 Sophie S. (https://github.com/sophfee)		  */
/* Copyright (c) 2019-2021 Jake Green (https://github.com/vingard)		  */
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

Plutonic.Static = {}
Plutonic.Static.CachedSettings = {}
Plutonic.Static.Dirty = false
--- The core level functionality of Plutonic.
-- @module Framework
--- Empties the cache of all control data.
-- @realm client
-- @internal
function Plutonic.Framework.InvalidateControlCache()
	Plutonic.Static.CachedSettings = {}
	Plutonic.Static.Dirty = true -- We rebuild the cache on the next frame, and as needed.
end

--- Gets the value of a control.
-- @realm client
-- @string name The name of the control.
-- @treturn string The controls saved value.
function Plutonic.Framework.GetControl_Data(name)
	if Plutonic.Static.CachedSettings[name] == nil then
		Plutonic.Static.CachedSettings[name] = cookie.GetString("p0c0s0::" .. name, "")
	end

	return Plutonic.Static.CachedSettings[name] or ""
end

--- Gets the value of a control as a boolean.
-- @realm client
-- @string name The name of the control.
-- @bool[opt] default The default value of the control.
-- @treturn bool The controls saved value.
function Plutonic.Framework.GetControl_Bool(name, default)
	local Control_Data = Plutonic.Framework.GetControl_Data(name)
	if Control_Data == "" then
		Plutonic.Static.CachedSettings[name] = default

		return default
	end

	return Control_Data == "1"
end

--- Gets the value of a control as a number.
-- @realm client
-- @string name The name of the control.
-- @number[opt] default The default value of the control.
-- @treturn number The controls saved value.
function Plutonic.Framework.GetControl_Number(name, default)
	local Control_Data = Plutonic.Framework.GetControl_Data(name)
	if Control_Data == "" or tonumber(Control_Data) == nil then
		Plutonic.Static.CachedSettings[name] = default

		return default
	end

	return tonumber(Control_Data)
end

--- Gets the value of a control as a string.
-- @realm client
-- @string name The name of the control.
-- @string[opt] default The default value of the control.
-- @treturn string The controls saved value.
function Plutonic.Framework.GetControl_String(name, default)
	local Control_Data = Plutonic.Framework.GetControl_Data(name)
	if Control_Data == "" then
		Plutonic.Static.CachedSettings[name] = default

		return default
	end

	return Control_Data
end

--- Sets the value of a control.
-- @realm client
-- @string name The name of the control.
-- @param value The value to set the control to.
function Plutonic.Framework.SetControl(name, value)
	Plutonic.Static.CachedSettings[name] = value
	cookie.Set("p0c0s0::" .. name, value)
end

--- Sets the value of a control as a boolean.
-- @realm client
-- @string name The name of the control.
-- @bool value The value to set the control to.
function Plutonic.Framework.SetControl_Bool(name, value)
	Plutonic.Framework.SetControl(name, value and "1" or "0")
end

--- Sets the value of a control as a number.
-- @realm client
-- @string name The name of the control.
-- @number value The value to set the control to.
function Plutonic.Framework.SetControl_Number(name, value)
	Plutonic.Framework.SetControl(name, tostring(value))
end

--- Sets the value of a control as a string.
-- @realm client
-- @string name The name of the control.
-- @string value The value to set the control to.
function Plutonic.Framework.SetControl_String(name, value)
	Plutonic.Framework.SetControl(name, tostring(value))
end