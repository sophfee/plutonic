AddCSLuaFile();
SWEP.Base = "plutonic_base_chargeup";
SWEP.PrintName = "Chargeup Example";
SWEP.Category = "Plutonic";
SWEP.UseHands = true;
SWEP.Spawnable = true;
SWEP.AdminOnly = false;
SWEP.HoldType = "shotgun"; 
SWEP.ViewModel = "models/weapons/v_pistol.mdl";
SWEP.WorldModel = "models/weapons/w_pistol.mdl";
SWEP.ViewModelFOV = 64;
SWEP.ViewModelOffset = Vector(-1.4, -4, .4);
SWEP.Slot = 2;
SWEP.SlotPos = 1;

SWEP.CanBreachDoors = true; -- Wether or not doors can be shot off by a SWEP
SWEP.Enum = {};
SWEP.Enum.WeaponType = Plutonic.Enum.WeaponType.SubmachineGun;
SWEP.BarrelLength = 14;
SWEP.CSMuzzleFlashes = false;

SWEP.ReloadSound = Sound("Weapon_SMG1.Reload");
SWEP.EmptySound = Sound("Weapon_SMG1.Empty");

sound.Add({
	name = "Plutonic.WindupTest_Fire",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = SNDLVL_GUNFIRE,
	pitch = {95, 105},
	sound = {"357/357_fire2.wav","357/357_fire2.wav"}
})

SWEP.Primary.Sound = Sound("Plutonic.WindupTest_Fire"); -- Please never use a sound path in here, the sound gets buggy. Please use sound.Add examples above.
SWEP.ChargeSound = Sound("items/ammo_pickup.wav") -- Sound that plays when charging up.
SWEP.Primary.Recoil = 1.24; -- base recoil value, SWEP.Spread mods can change this
SWEP.Primary.RecoilRecoveryRate = 1.5;
SWEP.Primary.Damage = 12;
SWEP.Primary.NumShots = 1;
SWEP.Primary.Cone = 0.012;
SWEP.Primary.Delay = Plutonic.FireRate.RPM(250); -- Rounds Per Minute, (RPM) can also use Rounds Per Second (RPS).
SWEP.Primary.PenetrationScale = 1;
SWEP.CannotChamber = true; -- Wether or not you can chamber a round.

SWEP.Primary.Ammo = "smg1";
SWEP.Primary.Automatic = true;
SWEP.Primary.ClipSize = 10;
SWEP.Primary.DefaultClip = 10;

SWEP.Secondary.Ammo = "none";
SWEP.Secondary.Automatic = true;
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = -1;

SWEP.Primary.StartFalloff = 1200;
SWEP.Primary.EndFalloff = 1800;

SWEP.Spread = {};
SWEP.Spread.Min = 0;
SWEP.Spread.Max = 0.1;
SWEP.Spread.IronsightsMod = 0.5; -- multiply
SWEP.Spread.CrouchMod = 0.8; -- crouch effect (multiply)
SWEP.Spread.AirMod = 1.2; -- how does if the player is in the air effect spread (multiply)
SWEP.Spread.RecoilMod = 0.09; -- how does the recoil effect the spread (sustained fire) (additional)
SWEP.Spread.VelocityMod = 04.42; -- movement speed effect on spread (additonal)

SWEP.IronsightsPos = Vector(-4.75, -3.5, 3.7); -- Where to display the ironsight positon/angle, suggested you use SWEP Creation Kit for this.
SWEP.IronsightsAng = Angle(0, -2, -0); -- Not centered, but it gets the point across.
SWEP.IronsightsFOV = 0.85;
SWEP.IronsightsSensitivity = 0.8;
SWEP.IronsightsCrosshair = true;
SWEP.IronsightsRecoilVisualMultiplier = 1;

SWEP.BlowbackPos = Vector(0, -5.08, 1.1); -- Vector to move bone <or root> relative to bone <or view> orientation while firing.
SWEP.BlowbackAngle = Angle(0, 0, 0);

SWEP.MuzzleEffect = "muzzleflash_shotgun"; -- Muzzleflash that is shown, see lua/autorun/plutonic_init.lua line 29 for more information.
SWEP.MuzzleFlashSize = 1024;
SWEP.MuzzleAttachment = "muzzle"
SWEP.MuzzleFlashColor = Color(0, 0, 0);
SWEP.MuzzleFlashShadow = true;

SWEP.LoweredPos = Vector(0, -9, -11); -- Positon/Angle that the SWEP is moved into while running. This disables the ability to shoot.
SWEP.LoweredAng = Angle(45, 5, -10);
SWEP.lastplayed = 0;
SWEP.CenteredPos = Vector(-2.631, 1.22, -6.58); -- Centered Positon for when plutonic_centered is active.
SWEP.CenteredAng = Angle(2.92, 2.509, -17.216);