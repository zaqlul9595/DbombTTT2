SWEP.Author = "cheezbawlz"

--Convars!
CreateConVar("ttt_can_cook_dbomb", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Allows the user to cook the grenade or not", 0)


if SERVER then
	AddCSLuaFile()
end

SWEP.Icon = "vgui/ttt/icon_dbomb"
SWEP.PrintName = "dbomb_name"
SWEP.Slot = 6

SWEP.Base = "weapon_tttbasegrenade"

SWEP.HoldType = "grenade"

SWEP.Kind = WEAPON_EQUIP1

SWEP.UseHands = true
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 54
SWEP.Spawnable = true
SWEP.AutoSpawnable = false	
SWEP.AllowDrop = true
SWEP.Weight = 5

SWEP.CanBuy = { ROLE_TRAITOR }

SWEP.ViewModel = "models/weapons/cstrike/c_eq_fraggrenade.mdl"
SWEP.WorldModel = "models/weapons/w_eq_fraggrenade.mdl"

SWEP.EquipMenuData = {
   type = "item_weapon",
   desc = "dbomb_desc"
};

--Overides the base grenade Think function
--since we want this nade to only start the fuse after we throw it
--ISSUE: The fuse time displayed on screen is no longer accurate
local cookCheck = GetConVar("ttt_can_cook_dbomb"):GetInt()
if cookCheck == 0 then
	function SWEP:Think()
	   local ply = self:GetOwner()
	   if not IsValid(ply) then return end
	   -- returns true when the pin is pulled
	   if self:GetPin() then
		  -- we will throw now
		  if not ply:KeyDown(IN_ATTACK) then
			 self:StartThrow()
			 self:SetPin(false)
			 self:SendWeaponAnim(ACT_VM_THROW)
			 --reset the detonation time to 5 seconds once thrown
			 self:SetDetTime( CurTime() + 5 )	
			 if SERVER then
				self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
			 end
		  end
	   elseif self:GetThrowTime() > 0 and self:GetThrowTime() < CurTime() then
		  self:SetDetTime( CurTime() + 5 )
		  self:Throw()
	   end
	end
end
	function SWEP:GetGrenadeName()
	   return "ttt_dbomb_proj"
	end