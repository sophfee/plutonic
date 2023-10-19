/**************************************************************************/
/*	shared/datatables.lua											      */
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

function SWEP:SetupDataTables()
	-- QUESTION:
	-- Could we migrate to SYNC vars, if Longsword is running in the impulse Framework (or derived)?
	-- Could provide a decent bump in performance. (sophie S.)
	self:NetworkVar("Bool", 0, "Ironsights")
	self:NetworkVar("Bool", 1, "Reloading")
	self:NetworkVar("Bool", 2, "Bursting")
	self:NetworkVar("Bool", 3, "Reliable")
	self:NetworkVar("Int", 0, "FireMode")
	self:NetworkVar("Float", 1, "IronsightsRecoil")
	self:NetworkVar("Float", 2, "Recoil")
	self:NetworkVar("Float", 3, "ReloadTime")
	self:NetworkVar("Float", 4, "NextIdle")
	if self.ExtraDataTables then
		self.ExtraDataTables(self)
	end
end