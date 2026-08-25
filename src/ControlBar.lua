
ControlBar = class(Turbine.UI.Control)

function ControlBar:Constructor()
	Turbine.UI.Control.Constructor(self)

	self.onSyncClicked = nil
	self.onSendSyncInfoClicked = nil
	self.onSyncStartClicked = nil
	self.onShareWheeled = nil
	self.onTooltipChanged = nil

	self.syncStartVisible = false

	local self_ref = self

	self.musicSlot = self:CreateSlot(20)
	self.musicSlotShortcut = Turbine.UI.Lotro.Shortcut(Turbine.UI.Lotro.ShortcutType.Alias, Strings["cmd_music"])
	self.musicSlot.DragDrop = function(sender, args)
		if self_ref.musicSlotShortcut then
			self_ref.musicSlot:SetShortcut(self_ref.musicSlotShortcut)
		end
	end
	self.musicSlot:SetShortcut(self.musicSlotShortcut)
	self.musicSlot:SetVisible(true)

	self.playSlot = self:CreateSlot(60)
	self.playSlot.DragDrop = function(sender, args)
		if self_ref.playSlotShortcut then
			self_ref.playSlot:SetShortcut(self_ref.playSlotShortcut)
		end
	end

	self.readySlot = self:CreateSlot(120)
	self.readySlot:SetShortcut(Turbine.UI.Lotro.Shortcut(Turbine.UI.Lotro.ShortcutType.Alias, Strings["cmd_ready"]))

	self.syncSlot = self:CreateSlot(161)
	self.syncSlot.DragDrop = function(sender, args)
		if self_ref.syncSlotShortcut then
			self_ref.syncSlot:SetShortcut(self_ref.syncSlotShortcut)
		end
	end

	self.sendSyncInfoSlot = self:CreateSlot(202)
	self.sendSyncInfoSlot.DragDrop = function(sender, args)
		if self_ref.sendSyncInfoSlotShortcut then
			self_ref.sendSyncInfoSlot:SetShortcut(self_ref.sendSyncInfoSlotShortcut)
		end
	end

	self.syncStartSlot = self:CreateSlot(287)
	self.syncStartSlotShortcut = Turbine.UI.Lotro.Shortcut(Turbine.UI.Lotro.ShortcutType.Undefined, "")
	self.syncStartSlot.DragDrop = function(sender, args)
		if self_ref.syncStartSlotShortcut then
			self_ref.syncStartSlot:SetShortcut(self_ref.syncStartSlotShortcut)
		end
	end
	self.syncStartSlot:SetShortcut(self.syncStartSlotShortcut)
	self.syncStartSlot:SetVisible(false)

	self.shareSlot = self:CreateSlot(328)
	self.shareSlot.DragDrop = function(sender, args)
		if self_ref.shareSlotShortcut then
			self_ref.shareSlot:SetShortcut(self_ref.shareSlotShortcut)
		end
	end

	self.listchannelsSlot = self:CreateSlot(369)
	self.listchannelsSlotShortcut = Turbine.UI.Lotro.Shortcut(Turbine.UI.Lotro.ShortcutType.Alias, "/listchannels")
	self.listchannelsSlot.DragDrop = function(sender, args)
		if self_ref.listchannelsSlotShortcut then
			self_ref.listchannelsSlot:SetShortcut(self_ref.listchannelsSlotShortcut)
		end
	end
	self.listchannelsSlot:SetShortcut(self.listchannelsSlotShortcut)
	self.listchannelsSlot:SetVisible(true)

	self.joinUserChatSlot = self:CreateSlot(410)
	self.joinUserChatSlotShortcut = Turbine.UI.Lotro.Shortcut(Turbine.UI.Lotro.ShortcutType.Alias, "/joinchannel " .. SyncManager.userChatName)
	self.joinUserChatSlot.DragDrop = function(sender, args)
		if self_ref.joinUserChatSlotShortcut then
			self_ref.joinUserChatSlot:SetShortcut(self_ref.joinUserChatSlotShortcut)
		end
	end
	self.joinUserChatSlot:SetShortcut(self.joinUserChatSlotShortcut)
	self.joinUserChatSlot:SetVisible(true)

	self.musicIcon = self:CreateIcon(20, "icn_m")
	self.playIcon = self:CreateIcon(60, "icn_p")
	self.readyIcon = self:CreateIcon(120, "icn_r")
	self.syncIcon = self:CreateIcon(161, "icn_s")
	self.sendSyncInfoIcon = self:CreateIcon(202, "icn_send")
	self.syncStartIcon = self:CreateIcon(287, "icn_ss")
	self.syncStartIcon:SetVisible(false)
	self.shareIcon = self:CreateIcon(328, "icn_sh")
	self.listchannelsIcon = self:CreateIcon(369, "icn_listchannel")
	self.joinUserChatIcon = self:CreateIcon(410, "icn_joinchannel")

	self.musicSlot.MouseEnter = function(sender, args)
		self_ref.musicIcon:SetBackground(gDir .. "icn_m_hover.tga")
		if self_ref.onTooltipChanged then self_ref.onTooltipChanged(Strings["tt_music"]) end
	end
	self.musicSlot.MouseLeave = function(sender, args)
		self_ref.musicIcon:SetBackground(gDir .. "icn_m.tga")
		if self_ref.onTooltipChanged then self_ref.onTooltipChanged("") end
	end
	self.musicSlot.MouseDown = function(sender, args)
		self_ref.musicIcon:SetBackground(gDir .. "icn_m_down.tga")
	end
	self.musicSlot.MouseUp = function(sender, args)
		self_ref.musicIcon:SetBackground(gDir .. "icn_m_hover.tga")
	end

	self.playSlot.MouseEnter = function(sender, args)
		self_ref.playIcon:SetBackground(gDir .. "icn_p_hover.tga")
		if self_ref.onTooltipChanged then self_ref.onTooltipChanged(Strings["tt_play"]) end
	end
	self.playSlot.MouseLeave = function(sender, args)
		self_ref.playIcon:SetBackground(gDir .. "icn_p.tga")
		if self_ref.onTooltipChanged then self_ref.onTooltipChanged("") end
	end
	self.playSlot.MouseDown = function(sender, args)
		self_ref.playIcon:SetBackground(gDir .. "icn_p_down.tga")
	end
	self.playSlot.MouseUp = function(sender, args)
		self_ref.playIcon:SetBackground(gDir .. "icn_p_hover.tga")
	end

	self.readySlot.MouseEnter = function(sender, args)
		self_ref.readyIcon:SetBackground(gDir .. "icn_r_hover.tga")
		if self_ref.onTooltipChanged then self_ref.onTooltipChanged(Strings["tt_ready"]) end
	end
	self.readySlot.MouseLeave = function(sender, args)
		self_ref.readyIcon:SetBackground(gDir .. "icn_r.tga")
		if self_ref.onTooltipChanged then self_ref.onTooltipChanged("") end
	end
	self.readySlot.MouseDown = function(sender, args)
		self_ref.readyIcon:SetBackground(gDir .. "icn_r_down.tga")
	end
	self.readySlot.MouseUp = function(sender, args)
		self_ref.readyIcon:SetBackground(gDir .. "icn_r_hover.tga")
	end

	self.syncSlot.MouseEnter = function(sender, args)
		self_ref.syncIcon:SetBackground(gDir .. "icn_s_hover.tga")
		if self_ref.onTooltipChanged then self_ref.onTooltipChanged(Strings["tt_sync"]) end
	end
	self.syncSlot.MouseLeave = function(sender, args)
		if SyncManager.correctInstrument then
			self_ref.syncIcon:SetBackground(gDir .. "icn_s.tga")
		else
			self_ref.syncIcon:SetBackground(gDir .. "icn_s_f.tga")
		end
		if self_ref.onTooltipChanged then self_ref.onTooltipChanged("") end
	end
	self.syncSlot.MouseDown = function(sender, args)
		self_ref.syncIcon:SetBackground(gDir .. "icn_s_down.tga")
	end
	self.syncSlot.MouseUp = function(sender, args)
		self_ref.syncIcon:SetBackground(gDir .. "icn_s_hover.tga")
	end
	self.syncSlot.MouseClick = function(sender, args)
		if self_ref.onSyncClicked then self_ref.onSyncClicked() end
	end

	self.sendSyncInfoSlot.MouseEnter = function(sender, args)
		self_ref.sendSyncInfoIcon:SetBackground(gDir .. "icn_send_hover.tga")
		if self_ref.onTooltipChanged then self_ref.onTooltipChanged("Send Sync Info") end
	end
	self.sendSyncInfoSlot.MouseLeave = function(sender, args)
		self_ref.sendSyncInfoIcon:SetBackground(gDir .. "icn_send.tga")
		if self_ref.onTooltipChanged then self_ref.onTooltipChanged("") end
	end
	self.sendSyncInfoSlot.MouseDown = function(sender, args)
		self_ref.sendSyncInfoIcon:SetBackground(gDir .. "icn_send_down.tga")
	end
	self.sendSyncInfoSlot.MouseUp = function(sender, args)
		self_ref.sendSyncInfoIcon:SetBackground(gDir .. "icn_send_hover.tga")
	end
	self.sendSyncInfoSlot.MouseClick = function(sender, args)
		if self_ref.onSendSyncInfoClicked then self_ref.onSendSyncInfoClicked() end
	end

	self.listchannelsSlot.MouseEnter = function(sender, args)
		self_ref.listchannelsIcon:SetBackground(gDir .. "icn_listchannel_hover.tga")
		if self_ref.onTooltipChanged then self_ref.onTooltipChanged("Recover User Channel") end
	end
	self.listchannelsSlot.MouseLeave = function(sender, args)
		self_ref.listchannelsIcon:SetBackground(gDir .. "icn_listchannel.tga")
		if self_ref.onTooltipChanged then self_ref.onTooltipChanged("") end
	end
	self.listchannelsSlot.MouseDown = function(sender, args)
		self_ref.listchannelsIcon:SetBackground(gDir .. "icn_listchannel_down.tga")
	end
	self.listchannelsSlot.MouseUp = function(sender, args)
		self_ref.listchannelsIcon:SetBackground(gDir .. "icn_listchannel_hover.tga")
	end

	self.joinUserChatSlot.MouseEnter = function(sender, args)
		self_ref.joinUserChatIcon:SetBackground(gDir .. "icn_joinchannel_hover.tga")
		if self_ref.onTooltipChanged then self_ref.onTooltipChanged("Join Songbook User Channel") end
	end
	self.joinUserChatSlot.MouseLeave = function(sender, args)
		self_ref.joinUserChatIcon:SetBackground(gDir .. "icn_joinchannel.tga")
		if self_ref.onTooltipChanged then self_ref.onTooltipChanged("") end
	end
	self.joinUserChatSlot.MouseDown = function(sender, args)
		self_ref.joinUserChatIcon:SetBackground(gDir .. "icn_joinchannel_down.tga")
	end
	self.joinUserChatSlot.MouseUp = function(sender, args)
		self_ref.joinUserChatIcon:SetBackground(gDir .. "icn_joinchannel_hover.tga")
	end

	self.syncStartSlot.MouseEnter = function(sender, args)
		self_ref.syncStartIcon:SetBackground(gDir .. "icn_ss_hover.tga")
		if self_ref.onTooltipChanged then self_ref.onTooltipChanged(Strings["tt_start"]) end
	end
	self.syncStartSlot.MouseLeave = function(sender, args)
		self_ref.syncStartIcon:SetBackground(gDir .. "icn_ss.tga")
		if self_ref.onTooltipChanged then self_ref.onTooltipChanged("") end
	end
	self.syncStartSlot.MouseDown = function(sender, args)
		self_ref.syncStartIcon:SetBackground(gDir .. "icn_ss_down.tga")
	end
	self.syncStartSlot.MouseUp = function(sender, args)
		self_ref.syncStartIcon:SetBackground(gDir .. "icn_ss_hover.tga")
	end
	self.syncStartSlot.MouseClick = function(sender, args)
		if self_ref.onSyncStartClicked then self_ref.onSyncStartClicked() end
	end

	self.shareSlot.MouseEnter = function(sender, args)
		self_ref.shareIcon:SetBackground(gDir .. "icn_sh_hover.tga")
		if self_ref.onTooltipChanged and Settings.Commands[Settings.DefaultCommand].Title then
			self_ref.onTooltipChanged(Settings.Commands[Settings.DefaultCommand].Title)
		end
	end
	self.shareSlot.MouseLeave = function(sender, args)
		self_ref.shareIcon:SetBackground(gDir .. "icn_sh.tga")
		if self_ref.onTooltipChanged then self_ref.onTooltipChanged("") end
	end
	self.shareSlot.MouseDown = function(sender, args)
		self_ref.shareIcon:SetBackground(gDir .. "icn_sh_down.tga")
	end
	self.shareSlot.MouseUp = function(sender, args)
		self_ref.shareIcon:SetBackground(gDir .. "icn_sh_hover.tga")
	end
	self.shareSlot.MouseWheel = function(sender, args)
		if self_ref.onShareWheeled then self_ref.onShareWheeled(args.Direction) end
	end
end

function ControlBar:CreateSlot(left)
	local slot = Turbine.UI.Lotro.Quickslot()
	slot:SetParent(self)
	slot:SetPosition(left, 0)
	slot:SetSize(32, 30)
	slot:SetZOrder(100)
	slot:SetAllowDrop(false)
	slot:SetVisible(true)
	return slot
end

function ControlBar:CreateIcon(left, sImageName)
	local icon = Turbine.UI.Control()
	icon:SetParent(self)
	icon:SetPosition(left, 0)
	icon:SetSize(35, 35)
	icon:SetZOrder(110)
	icon:SetMouseVisible(false)
	icon:SetBlendMode(Turbine.UI.BlendMode.AlphaBlend)
	icon:SetBackground(gDir .. sImageName .. ".tga")
	return icon
end

function ControlBar:SetWidth(w)
	Turbine.UI.Control.SetWidth(self, w)
end

function ControlBar:SetHeight(h)
	Turbine.UI.Control.SetHeight(self, h)
end

function ControlBar:SetVisible(bVisible)
	Turbine.UI.Control.SetVisible(self, bVisible)
	self.musicSlot:SetVisible(bVisible)
	self.musicIcon:SetVisible(bVisible)
	self.playSlot:SetVisible(bVisible)
	self.playIcon:SetVisible(bVisible)
	self.readySlot:SetVisible(bVisible)
	self.readyIcon:SetVisible(bVisible)
	self.syncSlot:SetVisible(bVisible)
	self.syncIcon:SetVisible(bVisible)
	self.sendSyncInfoSlot:SetVisible(bVisible)
	self.sendSyncInfoIcon:SetVisible(bVisible)
	self.shareSlot:SetVisible(bVisible)
	self.shareIcon:SetVisible(bVisible)
	self.listchannelsSlot:SetVisible(bVisible)
	self.listchannelsIcon:SetVisible(bVisible)
	self.joinUserChatSlot:SetVisible(bVisible)
	self.joinUserChatIcon:SetVisible(bVisible)
	self.syncStartSlot:SetVisible(bVisible and self.syncStartVisible)
	self.syncStartIcon:SetVisible(bVisible and self.syncStartVisible)
end

function ControlBar:SetSyncStartVisible(state)
	self.syncStartVisible = state
	self.syncStartSlot:SetVisible(state and self:IsVisible())
	self.syncStartIcon:SetVisible(state and self:IsVisible())
end

function ControlBar:SetSyncIconState(correctInstrument)
	if correctInstrument then
		self.syncIcon:SetBackground(gDir .. "icn_s.tga")
	else
		self.syncIcon:SetBackground(gDir .. "icn_s_f.tga")
	end
end

function ControlBar:SetPlayShortcut(alias)
	self.playSlotShortcut = Turbine.UI.Lotro.Shortcut(Turbine.UI.Lotro.ShortcutType.Alias, alias)
	self.playSlot:SetShortcut(self.playSlotShortcut)
	self.playSlot:SetVisible(true)
end

function ControlBar:SetSyncSlotShortcut(alias)
	self.syncSlotShortcut = Turbine.UI.Lotro.Shortcut(Turbine.UI.Lotro.ShortcutType.Alias, alias)
	self.syncSlot:SetShortcut(self.syncSlotShortcut)
	self.syncSlot:SetVisible(true)
end

function ControlBar:SetShareShortcut(alias)
	self.shareSlotShortcut = Turbine.UI.Lotro.Shortcut(Turbine.UI.Lotro.ShortcutType.Alias, alias)
	self.shareSlot:SetShortcut(self.shareSlotShortcut)
	self.shareSlot:SetVisible(true)
end

function ControlBar:SetSendSyncInfoShortcut(alias)
	self.sendSyncInfoSlotShortcut = Turbine.UI.Lotro.Shortcut(Turbine.UI.Lotro.ShortcutType.Alias, alias)
	self.sendSyncInfoSlot:SetShortcut(self.sendSyncInfoSlotShortcut)
	self.sendSyncInfoSlot:SetVisible(true)
end

function ControlBar:SetSyncStartShortcut(alias)
	if alias then
		self.syncStartSlotShortcut = Turbine.UI.Lotro.Shortcut(Turbine.UI.Lotro.ShortcutType.Alias, alias)
	else
		self.syncStartSlotShortcut = Turbine.UI.Lotro.Shortcut(Turbine.UI.Lotro.ShortcutType.Undefined, "")
	end
	self.syncStartSlot:SetShortcut(self.syncStartSlotShortcut)
	self.syncStartSlot:SetVisible(self.syncStartVisible and self:IsVisible())
end

function ControlBar:ClearSongShortcuts()
	self.playSlotShortcut = Turbine.UI.Lotro.Shortcut(Turbine.UI.Lotro.ShortcutType.Undefined, "")
	self.syncSlotShortcut = Turbine.UI.Lotro.Shortcut(Turbine.UI.Lotro.ShortcutType.Undefined, "")
	self.sendSyncInfoSlotShortcut = Turbine.UI.Lotro.Shortcut(Turbine.UI.Lotro.ShortcutType.Undefined, "")
	self.playSlot:SetShortcut(self.playSlotShortcut)
	self.syncSlot:SetShortcut(self.syncSlotShortcut)
	self.sendSyncInfoSlot:SetShortcut(self.sendSyncInfoSlotShortcut)
	self:SetSyncStartShortcut(nil)
end

function ControlBar:SetJoinUserChatShortcut(channelName)
	self.joinUserChatSlotShortcut = Turbine.UI.Lotro.Shortcut(Turbine.UI.Lotro.ShortcutType.Alias, "/joinchannel " .. channelName)
	self.joinUserChatSlot:SetShortcut(self.joinUserChatSlotShortcut)
	self.joinUserChatSlot:SetVisible(true)
end
