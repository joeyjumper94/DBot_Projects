local BaseClass = baseclass.Get('weapon_base')
SWEP.Base = 'weapon_base'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2'
SWEP.PrintName = 'TF2 Weapon Base'
SWEP.Spawnable = false
SWEP.AdminSpawnable = false
SWEP.UseHands = true
SWEP.DrawCrosshair = true
SWEP.DrawTime = 0.66
SWEP.DrawTimeAnimation = 1.16
SWEP.PreFire = 0
SWEP.CooldownTime = 0.96
SWEP.BulletRange = 32000
SWEP.BulletDamage = 65
SWEP.BulletForce = 1
SWEP.BulletHull = 1
SWEP.AttackAnimation = ACT_VM_PRIMARYATTACK
SWEP.Initialize = function(self)
  self:SetPlaybackRate(0.5)
  self:SendWeaponAnim(ACT_VM_IDLE)
  self.incomingFire = false
  self.incomingFireTime = 0
end
SWEP.WaitForAnimation = function(self, anim, time, callback)
  if anim == nil then
    anim = ACT_VM_IDLE
  end
  if time == nil then
    time = 0
  end
  if callback == nil then
    callback = (function() end)
  end
  return timer.Create("DTF2.WeaponAnim." .. tostring(self:EntIndex()), time, 1, function()
    if not IsValid(self) then
      return 
    end
    if not IsValid(self:GetOwner()) then
      return 
    end
    if self:GetOwner():GetActiveWeapon() ~= self then
      return 
    end
    self:SendWeaponAnim(anim)
    return callback()
  end)
end
SWEP.ClearTimeredAnimation = function(self)
  return timer.Remove("DTF2.WeaponAnim." .. tostring(self:EntIndex()))
end
SWEP.Deploy = function(self)
  self:SendWeaponAnim(ACT_VM_DRAW)
  self:WaitForAnimation(ACT_VM_IDLE, self.DrawTimeAnimation)
  self:SetNextPrimaryFire(CurTime() + self.DrawTime)
  self.incomingFire = false
  return true
end
SWEP.Holster = function(self)
  return self:GetNextPrimaryFire() < CurTime()
end
SWEP.OnMiss = function(self) end
SWEP.OnHit = function(self, hitEntity, tr, dmginfo)
  if hitEntity == nil then
    hitEntity = NULL
  end
  if tr == nil then
    tr = { }
  end
end
SWEP.BulletCallback = function(self, tr, dmginfo)
  if tr == nil then
    tr = { }
  end
  local weapon = self:GetActiveWeapon()
  weapon.bulletCallbackCalled = true
  if tr.Hit then
    return weapon:OnHit(tr.Entity, tr, dmginfo)
  else
    return weapon:OnMiss(tr, dmginfo)
  end
end
SWEP.UpdateBulletData = function(self, bulletData)
  if bulletData == nil then
    bulletData = { }
  end
end
SWEP.Think = function(self)
  if self.incomingFire and self.incomingFireTime < CurTime() then
    self.suppressing = true
    if SERVER and self:GetOwner():IsPlayer() then
      SuppressHostEvents(self:GetOwner())
    end
    self.incomingFire = false
    self.bulletCallbackCalled = false
    local bulletData = {
      ['Damage'] = self.BulletDamage,
      ['Attacker'] = self:GetOwner(),
      ['Callback'] = self.BulletCallback,
      ['Src'] = self:GetOwner():EyePos(),
      ['Dir'] = self:GetOwner():GetAimVector(),
      ['Distance'] = self.BulletRange,
      ['HullSize'] = self.BulletHull,
      ['Force'] = self.BulletForce
    }
    self:UpdateBulletData(bulletData)
    self:FireBullets(bulletData)
    if not self.bulletCallbackCalled then
      self:OnMiss()
    end
    if SERVER then
      SuppressHostEvents(NULL)
    end
    self.suppressing = false
  end
end
SWEP.PrimaryAttack = function(self)
  if self:GetNextPrimaryFire() > CurTime() then
    return false
  end
  self:SetNextPrimaryFire(CurTime() + self.CooldownTime)
  self:SendWeaponAnim(self.AttackAnimation)
  self:WaitForAnimation(ACT_VM_IDLE, self.CooldownTime)
  self.incomingFire = true
  self.incomingFireTime = CurTime() + self.PreFire
  self:NextThink(self.incomingFireTime)
  return true
end
SWEP.SecondaryAttack = function(self)
  return false
end