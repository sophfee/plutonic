/**************************************************************************/
/*	shared/anim.lua											      		  */
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

function SWEP:PlayAnim(act)
	if self:GetOwner():IsNPC() then return end
	if self.CustomEvents[act] then
		act = self.CustomEvents[act]
	end

	if isstring(act) then
		local vmodel = self:GetOwner():GetViewModel()
		if not IsValid(vmodel) then return end
		
		local seq = vmodel:LookupSequence(act)
		vmodel:ResetSequenceInfo()
		vmodel:ResetSequence(seq)
		vmodel:SetCycle(0)
		vmodel:SetSequence(seq)
		self:QueueIdle()
	else
		local vmodel = self:GetOwner():GetViewModel()

		if not IsValid(vmodel) then return end

		local seq = vmodel:SelectWeightedSequence(act)
		vmodel:SendViewModelMatchingSequence(seq)
	end
end

function SWEP:PlayAnimWorld(act)
	local wmodel = self
	local seq = wmodel:SelectWeightedSequence(act)
	self:ResetSequence(seq)
end

SWEP.VM_LayeredSequences = {}
function SWEP:PlayViewModelSequence(sqid)
	local vm = self:GetOwner():GetViewModel()
	if not IsValid(vm) then return end
	vm:SetCycle(0)
	vm:SetPlaybackRate(1)
	vm:SetSequence(sqid)
end

function SWEP:PlaySequence(seq)
	local vm = self:GetOwner():GetViewModel()
	if not IsValid(vm) then return end
	local sqid = isstring(seq) and vm:LookupSequence(seq) or seq
	local dur = vm:SequenceDuration() --
	if not vm:IsSequenceFinished() then
		timer.Simple(
			dur,
			function()
				if IsValid(self) and IsValid(vm) then
					self:PlayViewModelSequence(sqid)
				end
			end
		)
	else
		self:PlayViewModelSequence(sqid)
	end
end