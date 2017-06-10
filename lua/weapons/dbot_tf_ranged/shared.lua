local BaseClass = baseclass.Get('dbot_tf_weapon_base')
SWEP.Base = 'dbot_tf_weapon_base'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2'
SWEP.PrintName = 'TF2 Melee Base'
SWEP.Spawnable = false
SWEP.AdminSpawnable = false
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
SWEP.Slot = 2
SWEP.SlotPos = 16
SWEP.Primary = {
  ['Ammo'] = 'SMG1',
  ['ClipSize'] = 15,
  ['DefaultClip'] = 15,
  ['Automatic'] = true
}
SWEP.Secondary = {
  ['Ammo'] = 'none',
  ['ClipSize'] = -1,
  ['DefaultClip'] = 0,
  ['Automatic'] = false
}
SWEP.DrawTime = 0.66
SWEP.DrawTimeAnimation = 1.16
SWEP.PreFire = 0.05
SWEP.ReloadDeployTime = 0.4
SWEP.ReloadTime = 0.5
SWEP.ReloadFinishAnimTime = 0.3
SWEP.ReloadFinishAnimTimeIdle = 0.96
SWEP.ReloadBullets = 15
SWEP.TakeBulletsOnFire = 1
SWEP.CooldownTime = 0.7
SWEP.BulletDamage = 12
SWEP.DefaultSpread = Vector(0, 0, 0)
SWEP.BulletsAmount = 1
SWEP.DefaultViewPunch = Angle(0, 0, 0)
SWEP.MuzzleAttachment = 'muzzle'
SWEP.CritChance = 2
SWEP.CritExponent = 0.05
SWEP.CritExponentMax = 10
SWEP.SingleCrit = false
SWEP.SingleReloadAnimation = false
SWEP.ReloadLoopRestart = true
SWEP.DrawAnimation = 'fj_draw'
SWEP.IdleAnimation = 'fj_idle'
SWEP.AttackAnimation = 'fj_fire'
SWEP.AttackAnimationCrit = 'fj_fire'
SWEP.ReloadStart = 'fj_reload_start'
SWEP.ReloadLoop = 'fj_reload_loop'
SWEP.ReloadEnd = 'fj_reload_end'
SWEP.Reloadable = true
SWEP.SetupDataTables = function(self)
  return BaseClass.SetupDataTables(self)
end
SWEP.Initialize = function(self)
  BaseClass.Initialize(self)
  self.isReloading = false
  self.reloadNext = 0
  self.lastEmptySound = 0
end
SWEP.Reload = function(self)
  if not self.Reloadable then
    return false
  end
  if self:Clip1() == self:GetMaxClip1() then
    return false
  end
  if self.isReloading then
    return false
  end
  if self:GetNextPrimaryFire() > CurTime() then
    return false
  end
  if self:GetOwner():IsPlayer() and self:GetOwner():GetAmmoCount(self.Primary.Ammo) <= 0 then
    return false
  end
  self.isReloading = true
  self.reloadNext = CurTime() + self.ReloadDeployTime
  self:SendWeaponSequence(self.ReloadStart)
  self:ClearTimeredAnimation()
  return true
end
SWEP.Deploy = function(self)
  BaseClass.Deploy(self)
  self.isReloading = false
  self.lastEmptySound = 0
  return true
end
SWEP.GetBulletSpread = function(self)
  return self.DefaultSpread
end
SWEP.GetBulletAmount = function(self)
  return self.BulletsAmount
end
SWEP.GetViewPunch = function(self)
  return self.DefaultViewPunch
end
SWEP.UpdateBulletData = function(self, bulletData)
  if bulletData == nil then
    bulletData = { }
  end
  if CLIENT then
    local viewModel = self:GetTF2WeaponModel()
    do
      local muzzle = viewModel:GetAttachment(viewModel:LookupAttachment(self.MuzzleAttachment))
      if muzzle then
        local Pos, Ang
        Pos, Ang = muzzle.Pos, muzzle.Ang
        bulletData.Src = Pos
        local dir = self:GetOwner():GetEyeTrace().HitPos - Pos
        dir:Normalize()
        bulletData.Dir = dir
      end
    end
  end
  bulletData.Spread = self:GetBulletSpread()
  bulletData.Num = self:GetBulletAmount()
end
SWEP.PlayFireSound = function(self, isCrit)
  if isCrit == nil then
    isCrit = self.incomingCrit
  end
  if not isCrit then
    if self.FireSoundsScript then
      return self:EmitSound('DTF2_' .. self.FireSoundsScript)
    end
    local playSound
    if self.FireSounds then
      playSound = table.Random(self.FireSounds)
    end
    if playSound then
      return self:EmitSound(playSound, SNDLVL_GUNSHOT, 100, .7, CHAN_WEAPON)
    end
  else
    if self.FireCritSoundsScript then
      return self:EmitSound('DTF2_' .. self.FireCritSoundsScript)
    end
    local playSound
    if self.FireCritSounds then
      playSound = table.Random(self.FireCritSounds)
    end
    if playSound then
      return self:EmitSound(playSound, SNDLVL_GUNSHOT, 100, .7, CHAN_WEAPON)
    end
  end
end
SWEP.PlayEmptySound = function(self)
  if self.lastEmptySound > CurTime() then
    return 
  end
  self.lastEmptySound = CurTime() + 1
  if self.EmptySoundsScript then
    return self:EmitSound('DTF2_' .. self.EmptySoundsScript)
  end
  local playSound
  if self.EmptySounds then
    playSound = table.Random(self.EmptySounds)
  end
  if playSound then
    return self:EmitSound(playSound, 75, 100, .7, CHAN_WEAPON)
  end
end
SWEP.EmitMuzzleFlash = function(self)
  local viewModel = self:GetTF2WeaponModel()
  local Pos, Ang
  do
    local _obj_0 = viewModel:GetAttachment(viewModel:LookupAttachment(self.MuzzleAttachment))
    Pos, Ang = _obj_0.Pos, _obj_0.Ang
  end
  local emmiter = ParticleEmitter(Pos, false)
  if not emmiter then
    return 
  end
  for i = 1, math.random(3, 5) do
    do
      local _with_0 = emmiter:Add('effects/muzzleflash' .. math.random(1, 4), Pos)
      _with_0:SetDieTime(0.1)
      local size = math.random(20, 60) / 6
      _with_0:SetStartSize(size)
      _with_0:SetEndSize(size)
      _with_0:SetColor(255, 255, 255)
      _with_0:SetRoll(math.random(-180, 180))
    end
  end
  return emmiter:Finish()
end
SWEP.OnHit = function(self, ...)
  return BaseClass.OnHit(self, ...)
end
SWEP.OnMiss = function(self)
  return BaseClass.OnMiss(self)
end
SWEP.AfterFire = function(self, bulletData)
  if bulletData == nil then
    bulletData = { }
  end
end
SWEP.ReloadCall = function(self)
  local oldClip = self:Clip1()
  local newClip = math.Clamp(oldClip + self.ReloadBullets, 0, self:GetMaxClip1())
  if SERVER then
    self:SetClip1(newClip)
    if self:GetOwner():IsPlayer() then
      self:GetOwner():RemoveAmmo(newClip - oldClip, self.Primary.Ammo)
    end
  end
  return oldClip, newClip
end
SWEP.Think = function(self)
  BaseClass.Think(self)
  if self.isReloading and self.reloadNext < CurTime() then
    if self:GetOwner():IsPlayer() and self:GetOwner():GetAmmoCount(self.Primary.Ammo) > 0 then
      self.reloadNext = CurTime() + self.ReloadTime
      local oldClip, newClip = self:ReloadCall()
      if not self.SingleReloadAnimation then
        if self.ReloadLoopRestart then
          self:SendWeaponSequence(self.ReloadLoop)
        else
          if not self.reloadLoopStart then
            self:SendWeaponSequence(self.ReloadLoop)
          end
          self.reloadLoopStart = true
        end
      end
      if newClip == self:GetMaxClip1() then
        self.isReloading = false
        self.reloadLoopStart = false
        if not self.SingleReloadAnimation then
          self:WaitForSequence(self.ReloadEnd, self.ReloadFinishAnimTime, (function()
            if IsValid(self) then
              return self:WaitForSequence(self.IdleAnimation, self.ReloadFinishAnimTimeIdle)
            end
          end))
        end
        if self.SingleReloadAnimation then
          self:SendWeaponSequence(self.IdleAnimation, self.ReloadFinishAnimTimeIdle)
        end
      end
    elseif self:GetOwner():IsPlayer() and self:GetOwner():GetAmmoCount(self.Primary.Ammo) <= 0 or newClip == self:GetMaxClip1() then
      self.isReloading = false
      self.reloadLoopStart = false
      if not self.SingleReloadAnimation then
        self:WaitForSequence(self.ReloadEnd, self.ReloadFinishAnimTime, (function()
          if IsValid(self) then
            return self:WaitForSequence(self.IdleAnimation, self.ReloadFinishAnimTimeIdle)
          end
        end))
      end
      if self.SingleReloadAnimation then
        self:SendWeaponSequence(self.IdleAnimation, self.ReloadFinishAnimTimeIdle)
      end
    end
  end
  self:NextThink(CurTime() + 0.1)
  return true
end
SWEP.PrimaryAttack = function(self)
  if self:GetNextPrimaryFire() > CurTime() then
    return false
  end
  if self:Clip1() <= 0 then
    self:Reload()
    self:PlayEmptySound()
    return false
  end
  local status = BaseClass.PrimaryAttack(self)
  if status == false then
    return status
  end
  self.isReloading = false
  self:TakePrimaryAmmo(self.TakeBulletsOnFire)
  self:PlayFireSound()
  self:GetOwner():ViewPunch(self:GetViewPunch())
  if game.SinglePlayer() and SERVER then
    self:CallOnClient('EmitMuzzleFlash')
  end
  if CLIENT and self:GetOwner() == LocalPlayer() and self.lastMuzzle ~= FrameNumber() then
    self.lastMuzzle = FrameNumber()
    self:EmitMuzzleFlash()
  end
  return true
end