/**************************************************************************/
/*	cl_rt_scope.lua											              */
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

local math = math;
local render = render;
local reticule = Material("models/weapons/insurgency_sandstorm/ins2_sandstorm/kobra_reticle");
local abs = math.abs;
local min = math.min;
local max = math.max;
local clamp = math.Clamp;
local sin = math.sin;
local cos = math.cos;
local deg = math.deg;
local Curtime = UnPredictedCurTime;
local Frametime = RealFrameTime;
local Realtime = RealTime;
local vec = Vector;
local lerp = Lerp;
local lerpAngle = LerpAngle;
local lerpVector = LerpVector;
local approach = math.Approach;
local easeOutQuad = Plutonic.Ease.OutQuad;
local easeOutCirc = Plutonic.Ease.OutCirc;
local easeInQuad = Plutonic.Ease.InQuad;
local easeInCirc = Plutonic.Ease.InSine;
local VECTOR_ZERO = vec(0, 0, 0);
local ANGLE_ZERO = Angle(0, 0, 0);
local PushRenderTarget = render.PushRenderTarget;
local PopRenderTarget = render.PopRenderTarget;
local Clear = render.Clear;
local Start3D = cam.Start3D;
local End3D = cam.End3D;
local DrawScreenQuad = render.DrawScreenQuad;
local DrawQuadEasy = render.DrawQuadEasy;
local UpdateRefractTexture = render.UpdateRefractTexture;
local UpdateFullScreenDepthTexture = render.UpdateFullScreenDepthTexture;
local UpdatePowerOfTwoTexture = render.UpdatePowerOfTwoTexture;
local UpdateScreenEffectTexture = render.UpdateScreenEffectTexture;
local RenderView = render.RenderView;
local SetRenderMaterial = render.SetMaterial;

-- instances

local scope_rt = GetRenderTarget(
    "plutonic_scope", 
    512, 
    512
)

local scope_material = CreateMaterial("plutonic_optic", "VertexLitGeneric", {
    ["$basetexture"]        = scope_rt:GetName(),
	["$bumpmap"]            = "effects/arc9/glass_nm",
	["$translucent"]        = 1,
	["$phong"]              = 1,
	["$phongboost"]         = 8,
	["$phongexponent"]      = 0,
	["$envmap"]             = "env_cubemap",
	["$envmapfresnel"]      = -200.0,
	["$phongfresnelranges"] = "[0.01 0.35 3.0]"
})

scope_material:SetTexture("$basetexture", scope_rt:GetName())
scope_material:SetTexture("$bumpmap", "effects/arc9/glass_nm")
scope_material:SetInt("$translucent", 1)
scope_material:SetFloat("$phong", 1)
scope_material:SetFloat("$phongboost", 64)
scope_material:SetFloat("$phongexponent", 512)
scope_material:SetTexture("$envmap", "")
scope_material:SetFloat("$envmapfresnel", 1.5)
scope_material:SetVector("$phongfresnelranges", Vector(1, 1, 1))
scope_material:SetVector("$envmaptint", Vector(0, 0,0))
scope_material:SetInt("$ignorez", 1)
-- use bump map alpha as envmap mask
scope_material:SetInt("$normalmapalphaenvmapmask", 0)
scope_material:Recompute()

local pp_ca_base, pp_ca_r, pp_ca_g, pp_ca_b = Material("pp/arccw/ca_base"), Material("pp/arccw/ca_r"), Material("pp/arccw/ca_g"), Material("pp/arccw/ca_b")
local pp_ca_r_thermal, pp_ca_g_thermal, pp_ca_b_thermal = Material("pp/arccw/ca_r_thermal"), Material("pp/arccw/ca_g_thermal"), Material("pp/arccw/ca_b_thermal")

pp_ca_r:SetTexture("$basetexture", render.GetScreenEffectTexture())
pp_ca_g:SetTexture("$basetexture", render.GetScreenEffectTexture())
pp_ca_b:SetTexture("$basetexture", render.GetScreenEffectTexture())

pp_ca_r_thermal:SetTexture("$basetexture", render.GetScreenEffectTexture())
pp_ca_g_thermal:SetTexture("$basetexture", render.GetScreenEffectTexture())
pp_ca_b_thermal:SetTexture("$basetexture", render.GetScreenEffectTexture())

local greenColor = Color(0, 255, 0)  -- optimized +10000fps
local whiteColor = Color(255, 255, 255)
local blackColor = Color(0, 0, 0)

local tex_shadow = Material("hud/scopes/shadow.png", "mips smooth")
local mat_black = Material("arccw/hud/black.png")
local tex_black = mat_black:GetTexture("$basetexture")
local tex_glass = Material("models/weapons/arc9_eft_shared/atts/optic/transparent_glass", "mips smooth")
local tex_white = Material("models/debug/debugwhite")
local tex_refract = Material("pp/arccw/refract_rt", "mips smooth")
tex_refract:SetFloat( "$envmap", 0 )
tex_refract:SetFloat( "$envmaptint", 0 )
tex_refract:SetFloat( "$refractamount", 0.250 )
tex_refract:SetInt( "$ignorez", 1)
tex_refract:Recompute()

function Plutonic:PushScopeRT()
    render.PushRenderTarget(self.ScopeRenderTarget, 0, 0, 512, 512)
end

function Plutonic:PopScopeRT()
    render.PopRenderTarget()
end

function Plutonic:BlendOverride(source_blend, dest_blend, blend_func, src_blend_alpha, dest_blend_alpha, blend_func_alpha)
    render.OverrideBlend(true, source_blend, dest_blend, blend_func, src_blend_alpha, dest_blend_alpha, blend_func_alpha)
end

function Plutonic:DisableBlendOverride()
    render.OverrideBlend(false)
end

function Plutonic:NoTexture()
    draw.NoTexture()
end

function Plutonic:DrawScopeShadow(x, y)

    render.SetMaterial(tex_shadow)
    render.DrawTextureToScreenRect(tex_shadow:GetTexture("$basetexture"), x - 512, y - 512, 1024, 1024)

    render.DrawTextureToScreenRect(tex_black, x - 256 - 2048, y - 256, 512 + 2048, 512)
    render.DrawTextureToScreenRect(tex_black, x + 256, y - 256, 512 + 2048, 512)
    render.DrawTextureToScreenRect(tex_black, x - 256, y - 256 - 2048, 512, 512 + 512)
    render.DrawTextureToScreenRect(tex_black, x - 256, y + 256, 512, 512 + 2048)


end

function Plutonic:RenderScope(Weapon, ViewModel, AttachmentData, Attachment)
    --print(self, viewmodel, attData, att)

    local Plutonic = self

    if (not Weapon:GetIronsights()) then
        return
    end

    if not Attachment.plutonic_optic then
        Attachment:SetSubMaterial(0, "")
        Attachment:SetSubMaterial(1, "!plutonic_optic")
        Attachment.plutonic_optic = true
    end

    local AVDir = Attachment:GetAngles()
    AVDir:RotateAroundAxis(AVDir:Right(), 180)
    AVDir:RotateAroundAxis(AVDir:Forward(), 180)

    local pos = Attachment:GetPos() + (AVDir:Forward() *  24)
    local ang = Attachment:GetAngles()
    ang:RotateAroundAxis(ang:Right(), 180)
    ang:RotateAroundAxis(ang:Up(), -90)


    render.PushRenderTarget(scope_rt, 0, 0, 512, 512)   

    Plutonic.Framework.Overdraw = true

    cam.Start3D(pos, ang, 90, 0, 0, 512, 512, 16, 4096)

    
    render.SetBlend(1)
    render.OverrideBlend(true, BLEND_SRC_ALPHA, BLEND_DST_ALPHA, BLENDFUNC_ADD)
    render.Clear( 0, 0, 0, 255, false, false)
    render.RenderView({
        origin = pos,
        angles = AVDir,
        fov = LocalPlayer():GetFOV() / (AttachmentData.Magnification or 4),
        x = 0,
        y = 0,
        w = ScrW(),
        h = ScrH(),
        drawviewmodel = false,
        drawhud = false,
        aspectratio = 1
    })
    render.OverrideBlend(false, BLEND_SRC_ALPHA, BLEND_DST_COLOR, BLENDFUNC_ADD)
render.SetBlend(1)
    cam.End3D()

    
    render.SetMaterial(tex_shadow)
    render.DrawScreenQuad()

    self:DrawScopeShadow(256, 256)
    Plutonic.Framework.Overdraw = false
    
    
    render.PopRenderTarget()
end

Plutonic:DefineBehavior("rt_scope", {
    onFrame = function(Weapon, ViewModel, AttData_t, EAttachment)
        local success, err = pcall(function() 
            Plutonic:RenderScope(Weapon, ViewModel, AttData_t, EAttachment);
        end);

        if !success and err then
            MsgC(Color(255, 0, 0), "Plutonic:RenderScope failed: " .. err .. "\n");
        end
    end
})