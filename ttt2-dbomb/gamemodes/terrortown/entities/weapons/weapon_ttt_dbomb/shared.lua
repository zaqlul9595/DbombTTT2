SWEP.Author = "cheezbawlz"

if SERVER then
	AddCSLuaFile()
	resource.AddFile( "materials/vgui/ttt/icon_dbomb.vmt" )
	util.AddNetworkString("ttt_update_cook_convar")
end

--Convar!
CreateConVar("ttt_can_cook_dbomb", "1", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Allows the user to cook the grenade or not", 0,1)

SWEP.Icon = "vgui/ttt/icon_dbomb"
SWEP.PrintName = "Discombombulator"
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
   desc = "An Explosive Frag Grenade.\nLooks identical to the Discombobulator."
};

if CLIENT then
	net.Receive("ttt_update_cook_convar", function()
		cookCheck = net.ReadUInt(16)
	end)
end

--Overides the base grenade Think function
--since we want this nade to only start the fuse after we throw it
function SWEP:Think()
	-- get local player
	local ply = self:GetOwner()
	-- check if player is real
	if not IsValid(ply) then return end
	if self:GetPin() then
		-- this is called when player releases grenade
		if not ply:KeyDown(IN_ATTACK) then
			self:StartThrow()
			self:SetPin(false)
			self:SendWeaponAnim(ACT_VM_THROW)
			--reset the detonation time to 5 seconds once thrown
			self:SetDetTime( CurTime() + 5 )	
			if SERVER then
				self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
			end
		-- this is called while waiting for player to throw
		else
			-- if timer expires, blow up in face
			if SERVER and self:GetDetTime() < CurTime() and cookCheck == 1 then
				self:BlowInFace()
			end
		end
	elseif self:GetThrowTime() > 0 and self:GetThrowTime() < CurTime() then
		self:SetDetTime( CurTime() + 5 )
		self:Throw()
	end
end
function SWEP:GetGrenadeName()
	return "ttt_dbomb_proj"
end
if SERVER then
	hook.Add("TTTPrepareRound","ttt_send_cook_convar",function()
		cookCheck = GetConVar("ttt_can_cook_dbomb"):GetInt()
		--send convar to client
		net.Start("ttt_update_cook_convar")
		net.WriteUInt(cookCheck, 16)
		net.Broadcast()
	end)
end
