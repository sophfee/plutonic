--[[************************************************************************]]
--[[	cl_rt_scope.lua											              ]]
--[[************************************************************************]]
--[[                      This file is a part of PLUTONIC                   ]]
--[[                              (c) 2022-2023                             ]]
--[[                  Written by Sophie (github.com/sophfee)                ]]
--[[************************************************************************]]
--[[ Copyright (c) 2022-2023 Sophie S. (https://github.com/sophfee)		  ]]
--[[ Copyright (c) 2019-2021 Jake Green (https://github.com/vingard)		  ]]
--[[                                                                        ]]
--[[ Permission is hereby granted, free of charge, to any person obtaining  ]]
--[[ a copy of this software and associated documentation files (the        ]]
--[[ "Software"), to deal in the Software without restriction, including    ]]
--[[ without limitation the rights to use, copy, modify, merge, publish,    ]]
--[[ distribute, sublicense, and/or sell copies of the Software, and to     ]]
--[[ permit persons to whom the Software is furnished to do so, subject to  ]]
--[[ the following conditions:                                              ]]
--[[                                                                        ]]
--[[ The above copyright notice and this permission notice shall be         ]]
--[[ included in all copies or substantial portions of the Software.        ]]
--[[                                                                        ]]
--[[ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,        ]]
--[[ EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF     ]]
--[[ MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. ]]
--[[ IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY   ]]
--[[ CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,   ]]
--[[ TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE      ]]
--[[ SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                 ]]
--[[************************************************************************]]

local render = render;

-- instances
local scope_rt = GetRenderTarget("plutonic_scope", 512, 512);
local scope_material = CreateMaterial(
    "plutonic_scope",
    "VertexLitGeneric",
    {
        ["$basetexture"] = scope_rt:GetName(),
        ["$bumpmap"] = "effects/arc9/glass_nm",
        ["$translucent"] = 0,
        ["$phong"] = 1,
        ["$phongboost"] = 8,
        ["$phongexponent"] = 0,
        ["$envmap"] = "env_cubemap",
        ["$envmapfresnel"] = 4.0,
        ["$phongfresnelranges"] = "[0.01 0.35 3.0]"
    }
);

scope_material:SetTexture("$basetexture", scope_rt:GetName());
scope_material:SetTexture("$bumpmap", "effects/arc9/glass_nm");
scope_material:SetInt("$translucent", 1);
scope_material:SetFloat("$phong", 1);
scope_material:SetFloat("$phongboost", 4);
scope_material:SetFloat("$phongexponent", 512);
scope_material:SetTexture("$envmap", "env_cubemap");
scope_material:SetFloat("$envmapfresnel", 0);
scope_material:SetVector("$phongfresnelranges", Vector(0.4, 0.9, 1));
scope_material:SetVector("$envmaptint", Vector(0, 0, 0));
scope_material:SetInt("$ignorez", 1);
-- use bump map alpha as envmap mask
scope_material:SetInt("$normalmapalphaenvmapmask", 0);
scope_material:Recompute();
local pp_ca_r, pp_ca_g, pp_ca_b = Material("pp/arccw/ca_r"), Material("pp/arccw/ca_g"), Material("pp/arccw/ca_b");
local pp_ca_r_thermal, pp_ca_g_thermal, pp_ca_b_thermal = Material("pp/arccw/ca_r_thermal"), Material("pp/arccw/ca_g_thermal"), Material("pp/arccw/ca_b_thermal");
pp_ca_r:SetTexture("$basetexture", render.GetScreenEffectTexture());
pp_ca_g:SetTexture("$basetexture", render.GetScreenEffectTexture());
pp_ca_b:SetTexture("$basetexture", render.GetScreenEffectTexture());
pp_ca_r_thermal:SetTexture("$basetexture", render.GetScreenEffectTexture());
pp_ca_g_thermal:SetTexture("$basetexture", render.GetScreenEffectTexture());
pp_ca_b_thermal:SetTexture("$basetexture", render.GetScreenEffectTexture());
local tex_shadow = Material("models/weapons/tfa_ins2/optics/mk4_crosshair.vtf"); -- Material("models/weapons/tfa_ins2/optics/po4x_reticule")
local mat_black = Material("arccw/hud/black.png");
local tex_black = mat_black:GetTexture("$basetexture");
local tex_glass = Material("models/weapons/arc9_eft_shared/atts/optic/transparent_glass", "mips smooth");
local tex_white = Material("models/debug/debugwhite");
local tex_refract = Material("pp/arccw/refract_rt", "mips smooth");
tex_refract:SetFloat("$envmap", 0);
tex_refract:SetFloat("$envmaptint", 0);
tex_refract:SetFloat("$refractamount", 0.250);
tex_refract:SetInt("$ignorez", 1);
tex_refract:Recompute();
function Plutonic:PushScopeRT()
    render.PushRenderTarget(self.ScopeRenderTarget, 0, 0, 512, 512);
end

function Plutonic:PopScopeRT()
    render.PopRenderTarget();
end

function Plutonic:BlendOverride(source_blend, dest_blend, blend_func, src_blend_alpha, dest_blend_alpha, blend_func_alpha)
    render.OverrideBlend(true, source_blend, dest_blend, blend_func, src_blend_alpha, dest_blend_alpha, blend_func_alpha);
end

function Plutonic:DisableBlendOverride()
    render.OverrideBlend(false);
end

function Plutonic:NoTexture()
    draw.NoTexture();
end

local res = {ScrW(), ScrH()};
local sfx = function(x) return x * 1024 / res[1]; end;
local sfy = function(y) return y * 1024 / res[2]; end;
local framebuffer = Material("pp/fb");
framebuffer:SetInt("$translucent", 1);
--framebuffer:

local mat_ReticuleAxis = CreateMaterial(
    "plutonic_reticule_2",
    "VertexLitGeneric",
    {
        ["$basetexture"] = tex_shadow:GetTexture("$basetexture"):GetName(),
        ["$bumpmap"] = tex_glass:GetTexture("$bumpmap"):GetName(),
        ["$translucent"] = 1,
        ["$phong"] = 1,
        ["$phongboost"] = 8,
        ["$phongexponent"] = 0,
        ["$envmap"] = 0,
        ["$envmapfresnel"] = 0.0,
        ["$phongfresnelranges"] = "[1.0 1.35 1.0]",
        ["$refractamount"] = 1.0
    }
);

local function DrawTextureOnScope(mat, x, y, w, h)
    render.SetMaterial(mat);
    render.DrawScreenQuadEx(x, y, w, h);
end

local screen_width, screen_height = ScrW(), ScrH();

local function screenRatioX(x)
    return screen_width * (x / 100);
end

local function screenRatioY(y)
    return screen_height * (y / 100);
end

local blur_amt = 0

function Plutonic:DrawScopeShadow(x, y)
    local yaw = LocalPlayer():GetActiveWeapon().c_oxq or 0;
    x = x - (yaw * -1000)
    local pitch = LocalPlayer():GetActiveWeapon().c_oyq or 0;
    y = y - (pitch * 50)

    local bob = vtx.util.bob(VECTOR_ZERO, ANGLE_ZERO, 90, .5);
    x = x + (bob.x * 2000);
    y = y + (bob.z * 2000);

    DrawTextureOnScope(mat_ReticuleAxis, x + screenRatioX(-9.5), y + screenRatioY(-9.5), screenRatioX(118), screenRatioY(118));

    local vel = LocalPlayer():GetVelocity():Length2D();
    if vel > 20 then
        blur_amt = math.Approach(blur_amt, vel / 20, FrameTime() * 5.2);
        render.BlurRenderTarget(scope_rt, math.Round(blur_amt, 4), math.Round(blur_amt, 4), 4);
    end

    --render.DrawTextureToScreenRect(tex_black, x - 256 - 512, y - 256, 2048 + 512, 256)
    --render.DrawTextureToScreenRect(tex_black, x - 256 + 512 + 512, y - 256, 256, 1024)
    --render.DrawTextureToScreenRect(tex_black, x - 256, y - 256 - 512, 512, 512 + 512)
    --render.DrawTextureToScreenRect(tex_black, x - 256, y + 256, 512, 512 + 512)
end

function Plutonic:RenderScope(Weapon, ViewModel, AttachmentData, Attachment)
    if not Weapon:GetIronsights() then return; end
    if not Attachment.plutonic_scope then
        Attachment:SetSubMaterial(0, "");
        Attachment:SetSubMaterial(1, "!plutonic_scope");
        Attachment.plutonic_scope = true;
    end

    --DrawBokehDOF(24 * Weapon.VMIronsights, 0.0025, 0.5)
    DrawToyTown(4, ScrH()/2)

    local AVDir = Attachment:GetAngles();
    AVDir:RotateAroundAxis(AVDir:Right(), 180);
    AVDir:RotateAroundAxis(AVDir:Forward(), 180);
    local pos = Attachment:GetPos() + AVDir:Forward() * 24;
    local ang = Attachment:GetAngles();
    ang:RotateAroundAxis(ang:Right(), 180);
    ang:RotateAroundAxis(ang:Up(), -90);
    --cam.Start2D();
    render.PushRenderTarget(scope_rt, 0, 0, 512, 512);
    render.Clear(0, 0, 0, 0, true, true);
    Plutonic.Framework.Overdraw = true;
    --cam.Start3D(pos, ang, 90, 0, 0, 512, 512, 16, 4096);
    render.Clear(0, 0, 0, 0, true, true);
    --render.OverrideAlphaWriteEnable(true, false);
    render.RenderView(
        {
            origin = pos + AVDir:Forward() * 8,
            angles = AVDir,
            fov = LocalPlayer():GetFOV() / (AttachmentData.Magnification or 8),
            x = 0,
            y = 0,
            w = 1920,
            h = 1080,
            drawviewmodel = false,
            drawhud = false,
            aspectratio = 1
        }
    );

    render.SetBlend(1);
    --cam.End3D();
    render.SetMaterial(tex_shadow);
    --render.DrawScreenQuad()
    DrawMaterialOverlay("models/weapons/arc9_eft_shared/atts/optic/transparent_glass", 1.0);
    Plutonic:DrawScopeShadow(Weapon.c_oxq or 0, 0);

    
    Plutonic.Framework.Overdraw = false;
    render.PopRenderTarget();
    -- cam.End2D();
end

Plutonic:DefineBehavior(
    "rt_scope",
    {
        onFrame = function(Weapon, ViewModel, AttData_t, EAttachment)
            local success, err = pcall(
                function()
                    Plutonic:RenderScope(Weapon, ViewModel, AttData_t, EAttachment);
                end
            );

            if not success and err then
                MsgC(Color(255, 0, 0), "Plutonic:RenderScope failed: " .. err .. "\n");
            end
        end
    }
);

local RWeapon, RViewModel, RAttData_t, REAttachment;
local function Plutonic_RenderHolographicReticule_renderCallback()
    local Plutonic = Plutonic;
    local Weapon = RWeapon;
    local ViewModel = RViewModel;
    local AttData_t = RAttData_t;
    local EAttachment = REAttachment;
    local Attachment = ViewModel:GetAttachment(EAttachment);
    local ang = EAttachment:GetAngles();
    local up, forward, right = ang:Up(), ang:Forward(), ang:Right();
    --ang:RotateAroundAxis(right, -180)
    ang:RotateAroundAxis(ang:Up(), -180);
    local reticule = AttData_t.Reticule;
    local reticuleMaterial = reticule.Material;
    local reticuleColor = reticule.Color;
    local reticuleSize = reticule.Size;
    local reticulePos = EAttachment:GetPos() + reticule.Pos;
    --reticulePos = reticulePos + EAttachment:GetAngles():Forward() * 0.1;
    render.SetMaterial(reticuleMaterial);
    render.DrawSprite(reticulePos, reticuleSize, reticuleSize, reticuleColor, 18);
end

function Plutonic:RenderHolographicReticule(Weapon, ViewModel, AttData_t, EAttachment)
    RWeapon, RViewModel, RAttData_t, REAttachment = Weapon, ViewModel, AttData_t, EAttachment;
    Plutonic_RenderHolographicReticule_renderCallback(); -- Plutonic:RenderMask(EAttachment, Plutonic_RenderHolographicReticule_renderCallback);
end

Plutonic:DefineBehavior(
    "1x_scope",
    {
        onFrame = function(Weapon, ViewModel, AttData_t, EAttachment)
            Plutonic:RenderHolographicReticule(Weapon, ViewModel, AttData_t, EAttachment);
        end
    }
);