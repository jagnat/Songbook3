-- resizable popup holding a scrolled list box; base for the sync popups
ListWindow = class(Turbine.UI.Lotro.Window)

local MIN_WIDTH = 300
local MIN_HEIGHT = 200
local RESIZE_SIZE = 20

function ListWindow:Constructor(title, width, height)
	Turbine.UI.Lotro.Window.Constructor(self)

	self:SetSize(width, height)
	self:SetText(title)
	self:SetVisible(false)
	self:SetOpacity(0.9)

	self.listBox = Turbine.UI.ListBox()
	self.listBox:SetParent(self)
	self.listBox:SetPosition(30, 50)

	self.scrollBarV = self:CreateScrollBar(Turbine.UI.Orientation.Vertical)
	self.listBox:SetVerticalScrollBar(self.scrollBarV)
	self.scrollBarH = self:CreateScrollBar(Turbine.UI.Orientation.Horizontal)
	self.listBox:SetHorizontalScrollBar(self.scrollBarH)

	self.resizeCtrl = Turbine.UI.Control()
	self.resizeCtrl:SetParent(self)
	self.resizeCtrl:SetSize(RESIZE_SIZE, RESIZE_SIZE)
	self.resizeCtrl:SetZOrder(200)

	self.resizeCtrl.MouseDown = function(sender, args)
		sender.dragStartX = args.X
		sender.dragStartY = args.Y
		sender.dragging = true
	end

	self.resizeCtrl.MouseUp = function(sender, args)
		sender.dragging = false
		self:ResizeEnded()
	end

	self.resizeCtrl.MouseMove = function(sender, args)
		if sender.dragging then
			local width, height = self:GetSize()
			local displayWidth, displayHeight = Turbine.UI.Display.GetSize()

			width = width + args.X - sender.dragStartX
			height = height + args.Y - sender.dragStartY

			if width < MIN_WIDTH then width = MIN_WIDTH end
			if height < MIN_HEIGHT then height = MIN_HEIGHT end
			if self:GetLeft() + width > displayWidth then width = displayWidth - self:GetLeft() end
			if self:GetTop() + height > displayHeight then height = displayHeight - self:GetTop() end

			self:SetSize(width, height)
		end
		self:LayoutList()
	end

	self:LayoutList()
end

function ListWindow:CreateScrollBar(orientation)
	local scrollBar = Turbine.UI.Lotro.ScrollBar()
	scrollBar:SetParent(self)
	scrollBar:SetOrientation(orientation)
	scrollBar:SetBackColor(Turbine.UI.Color(.1, .1, .1))
	scrollBar:SetZOrder(120)
	scrollBar:SetValue(0)
	return scrollBar
end

function ListWindow:LayoutList()
	local width, height = self:GetSize()
	local list = self.listBox
	list:SetSize(width - 60, height - 80)
	self.scrollBarV:SetPosition(list:GetLeft() + list:GetWidth(), list:GetTop())
	self.scrollBarV:SetSize(10, list:GetHeight())
	self.scrollBarH:SetPosition(list:GetLeft(), list:GetTop() + list:GetHeight())
	self.scrollBarH:SetSize(list:GetWidth(), 10)
	self.resizeCtrl:SetPosition(width - RESIZE_SIZE, height - RESIZE_SIZE)
end

function ListWindow:ResizeEnded()
end
