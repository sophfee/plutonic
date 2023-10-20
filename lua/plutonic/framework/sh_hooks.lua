/**************************************************************************/
/*	sh_hooks.lua											              */
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

Plutonic.Hooks = Plutonic.Hooks or {}
Plutonic.Hooks.Data = Plutonic.Hooks.Data or {}
Plutonic.Hooks.Add = function(hookName, callback)
	if Plutonic.Hooks.Data[hookName] then
		Plutonic.Framework.Print("Hook: " .. hookName .. " already exists. Overwriting...")
		Plutonic.Hooks.Remove(hookName)
	end

	Plutonic.Framework.Print("Hook: " .. hookName .. " added.")
	Plutonic.Hooks.Data[hookName] = callback
	hook.Add(hookName, "Plutonic.Hooks." .. hookName, callback)
end

function Plutonic:Hook(hookName, callback)
	Plutonic.Hooks.Add(hookName, callback)
end

Plutonic.Hooks.Remove = function(hookName)
	if not Plutonic.Hooks.Data[hookName] then
		Plutonic.Framework.Print("Hook: " .. hookName .. " does not exist!")

		return
	end

	Plutonic.Framework.Print("Hook: " .. hookName .. " removed.")
	hook.Remove(hookName, "Plutonic.Hooks." .. hookName)
end

function Plutonic:Unhook(hookName)
	Plutonic.Hooks.Remove(hookName)
end