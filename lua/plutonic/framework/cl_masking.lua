/**************************************************************************/
/*	cl_masking.lua 											              */
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



--- The core level functionality of Plutonic.
-- @module Framework
--- Starts a mask to draw a model to the stencil buffer, this is used for sights
-- @param ent The entity to draw to the stencil buffer
-- @realm client
Plutonic.Framework.Mask = function(...)
	render.SetStencilReferenceValue(0)
	render.SetStencilPassOperation(STENCIL_KEEP)
	render.SetStencilZFailOperation(STENCIL_KEEP)
	render.ClearStencil()
	render.SetStencilEnable(true)
	render.SetStencilWriteMask(0xF0)
	render.ClearStencilBufferRectangle(0, 0, ScrW(), ScrH(), 0x0F)
	render.SetStencilCompareFunction(STENCIL_NEVER)
	render.SetStencilTestMask(0x00)
	render.SetStencilFailOperation(STENCIL_INCR)
	-- Draw the model to the stencil buffer
	local masks = {...}
	for _, ent in ipairs(masks) do
		ent:DrawModel()
	end

	render.SetStencilTestMask(0xFF)
	render.SetStencilReferenceValue(0x1F)
	render.SetStencilCompareFunction(STENCIL_EQUAL)
end

Plutonic.Framework.InverseMask = function(...)
	render.SetStencilReferenceValue(0)
	render.SetStencilPassOperation(STENCIL_KEEP)
	render.SetStencilZFailOperation(STENCIL_KEEP)
	render.ClearStencil()
	render.SetStencilEnable(true)
	render.SetStencilWriteMask(0xF0)
	render.ClearStencilBufferRectangle(0, 0, ScrW(), ScrH(), 0x0F)
	render.SetStencilCompareFunction(STENCIL_NEVER)
	render.SetStencilTestMask(0x00)
	render.SetStencilFailOperation(STENCIL_INCR)
	-- Draw the model to the stencil buffer
	local masks = {...}
	for _, ent in ipairs(masks) do
		ent:DrawModel()
	end

	render.SetStencilTestMask(0xFF)
	render.SetStencilReferenceValue(0x1F)
	render.SetStencilCompareFunction(STENCIL_NOTEQUAL)
end


function Plutonic:Mask(...)
	Plutonic.Framework.Mask(...)
end

function Plutonic:RenderMask(ent, renderFunc)
	local success, err;
	success, err = pcall(self.Framework.Mask, ent);
	if not success then MsgC(Color(255, 0, 0), "Plutonic:RenderMask failed: " .. err .. "\n") return end
	success, err = pcall(renderFunc);
	if not success then MsgC(Color(255, 0, 0), "Plutonic:RenderMask<Anonymous> failed: " .. err .. "\n") return end
	success, err = pcall(self.Framework.UnMask)
	if not success then MsgC(Color(255, 0, 0), "Plutonic:UnMask failed: " .. err .. "\n") return end
end

--- Ends a mask
-- @realm client
Plutonic.Framework.UnMask = function()
	render.SetStencilWriteMask(0xFF)
	render.SetStencilTestMask(0xFF)
	render.SetStencilReferenceValue(0)
	render.SetStencilCompareFunction(STENCIL_ALWAYS)
	render.SetStencilPassOperation(STENCIL_KEEP)
	render.SetStencilFailOperation(STENCIL_KEEP)
	render.SetStencilZFailOperation(STENCIL_KEEP)
	render.ClearStencil()
	render.SetStencilEnable(false)
end

function Plutonic:UnMask()
	Plutonic.Framework.UnMask()
end