

local Plater = Plater
local GameCooltip = GameCooltip2
local DF = DetailsFramework
local _

--sort scripts
function Plater.SortScripts (t1, t2)
	--> index 4 stores if the script is enabled
	if (t1[4] > t2[4]) then
		return true
	elseif (t1[4] < t2[4]) then
		return false
	else
		--> index 3 stores the script name
		return t1[3] < t2[3]
	end
end

--tab indexes
local PLATER_OPTIONS_SCRIPTING_TAB = 13
local PLATER_OPTIONS_HOOKING_TAB = 14

--options
local start_y = -130
local main_frames_size = {600, 400}
local edit_script_size = {620, 431}

local scrollbox_size = {200, 405}
local scrollbox_lines = 13
local scrollbox_line_height = 30

local triggerbox_size = {180, 288}
local triggerbox_lines = 11
local triggerbox_line_height = 25

local scrollbox_line_backdrop_color = {0, 0, 0, 0.5}
local scrollbox_line_backdrop_not_inuse = {0, 0, 0, 0.4}
local scrollbox_line_backdrop_color_selected = {.6, .6, .1, 0.7}

local buttons_size = {120, 20}
local luaeditor_backdrop_color = {.2, .2, .2, .5}
local luaeditor_border_color = {0, 0, 0, 1}

--get templates
local options_text_template = DF:GetTemplate ("font", "OPTIONS_FONT_TEMPLATE")
local options_dropdown_template = DF:GetTemplate ("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
local options_switch_template = DF:GetTemplate ("switch", "OPTIONS_CHECKBOX_TEMPLATE")
local options_slider_template = DF:GetTemplate ("slider", "OPTIONS_SLIDER_TEMPLATE")
local options_button_template = DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE")

Plater.APIList = {
	{Name = "RefreshNameplateColor", 		Signature = "Plater.RefreshNameplateColor (unitFrame)", 				Desc = "Check which color the nameplate should have and set it."},
	{Name = "SetNameplateColor", 		Signature = "Plater.SetNameplateColor (unitFrame, color)", 				Desc = "Set the color of the nameplate.\n\nColor formats are:\n|cFFFFFF00Just Values|r: r, g, b\n|cFFFFFF00Index Table|r: {r, g, b}\n|cFFFFFF00Hash Table|r: {r = 1, g = 1, b = 1}\n|cFFFFFF00Hex|r: '#FFFF0000' or '#FF0000'\n|cFFFFFF00Name|r: 'yellow' 'white'"},
	{Name = "SetCastBarBorderColor", 		Signature = "Plater.SetCastBarBorderColor (castBar, color)", 			Desc = "Set the color of the castbar.\n\nColor formats are:\n|cFFFFFF00Just Values|r: r, g, b, a\n|cFFFFFF00Index Table|r: {r, g, b}\n|cFFFFFF00Hash Table|r: {r = 1, g = 1, b = 1}\n|cFFFFFF00Hex|r: '#FFFF0000' or '#FF0000'\n|cFFFFFF00Name|r: 'yellow' 'white'"},
	{Name = "FlashNameplateBorder", 		Signature = "Plater.FlashNameplateBorder (unitFrame [, duration])", 		Desc = "Do a quick flash in the nameplate border, duration is optional."},
	{Name = "FlashNameplateBody", 		Signature = "Plater.FlashNameplateBody (unitFrame [, text [, duration]])", 	Desc = "Flash the healthbar portion of the nameplate, text and duration are optionals."},
	{Name = "UpdateNameplateThread", 	Signature = "Plater.UpdateNameplateThread (unitFrame)", 				Desc = "Perform an Aggro update on the nameplate changing color to the current thread situation."},
	{Name = "GetNpcIDFromGUID", 		Signature = "Plater.GetNpcIDFromGUID (GUID)", 					Desc = "Extract the npcID from a GUID, guarantee to always return a number."},
	{Name = "NameplateInRange", 		Signature = "Plater.NameplateInRange (unitFrame)", 					Desc = "Return true if the nameplate is in range of the selected spell for range check.\n\nIt also updates the range flag for unitFrame.namePlateInRange."},
	{Name = "GetRaidMark", 			Signature = "Plater.GetRaidMark (unitFrame)", 						Desc = "Return which raid mark the nameplate has. Always return false if the nameplate is the personal health bar."},
	{Name = "IsInCombat", 			Signature = "Plater.IsInCombat()", 								Desc = "Return 'true' if the player is in combat."},
	{Name = "IsPlayerTank", 			Signature = "Plater.IsPlayerTank()", 							Desc = "Return 'true' if the player is in the tank role."},
}

Plater.FrameworkList = {
	{Name = "CreateFlash",		 		Signature = "Plater.CreateFlash (parent, duration, amountOfFlashes, color)", 	Desc = "Creates a custom flash which can be triggered by the ReturnValue:Play()\n\nUse:\n|cFFFFFF00ReturnedValue:Play()|r on OnShow.\n|cFFFFFF00ReturnedValue:Stop()|r on OnHide.", AddVar = true, AddCall = "--@ENV@:Play() --@ENV@:Stop()"},
	--{Name = "CreateFrameShake",		Signature = "Plater:CreateFrameShake (parent, duration, amplitude, frequency, bAbsoluteSineX, bAbsoluteSineY, scaleX, scaleY, fadeInTime, fadeOutTime)",	Desc = "Creates a shake for the frame.\n\nStore the returned table inside the envTable and call parent:PlayFrameShake (returned table) to play the shake.", AddVar = true, AddCall = "--parent:PlayFrameShake(@ENV@)"}, -- --parent:StopFrameShake(@ENV@)
	
	{Name = "CreateLabel",		 		Signature = "Plater:CreateLabel (parent, text, size, color, font, member, name, layer)",	Desc = "Creates a simple text to show in the nameplate, all parameters after 'parent' are optional.\n\nUse:\n|cFFFFFF00ReturnedValue:Show()|r on OnShow.\n|cFFFFFF00ReturnedValue:Hide()|r on OnHide.\n\nMembers:\n.text = 'new text'\n.textcolor = 'red'\n.textsize = 12\n.textfont = 'fontName'", AddVar = true, AddCall = "@ENV@:SetPoint ('center', 0, 0)"},
	{Name = "CreateImage",		 	Signature = "Plater:CreateImage (parent, texture, w, h, layer, coords, member, name)",	Desc = "Creates a image to show in the nameplate, all parameters after 'parent' are optional.\n\nUse:\n|cFFFFFF00ReturnedValue:Show()|r on OnShow.\n|cFFFFFF00ReturnedValue:Hide()|r on OnHide.\n\nMembers:\n.texture = 'texture path'\n.alpha = 0.5\n.width = 300\n.height = 200", AddVar = true, AddCall = "@ENV@:SetPoint ('center', 0, 0)"},
	{Name = "CreateBar",		 		Signature = "Plater:CreateBar (parent, texture, w, h, value, member, name)",			Desc = "Creates progress bar, all parameters after 'parent' are optional.\n\nUse:\n|cFFFFFF00ReturnedValue:Show()|r on OnShow.\n|cFFFFFF00ReturnedValue:Hide()|r on OnHide.\n\nMembers:\n.value = 50\n.texture = 'texture path'\n.icon = 'texture path'\n.lefttext = 'new text'\n.righttext = 'new text'\n.color = color\n.width = 300\n.height = 200", AddVar = true, AddCall = "@ENV@:SetPoint ('center', 0, 0)"},
	
	{Name = "SetFontSize",		 	Signature = "Plater:SetFontSize (fontString, fontSize, ...)",						Desc = "Set the size of a text, accept more than one size, automatically picks the bigger one."},
	{Name = "SetFontFace",		 	Signature = "Plater:SetFontFace (fontString, fontFace)",						Desc = "Set the font of a text."},
	{Name = "SetFontColor",		 	Signature = "Plater:SetFontColor (fontString, r, g, b, a)",						Desc = "Set the color of a text.\n\nColor formats are:\n|cFFFFFF00Just Values|r: r, g, b, a\n|cFFFFFF00Index Table|r: {r, g, b}\n|cFFFFFF00Hash Table|r: {r = 1, g = 1, b = 1}\n|cFFFFFF00Hex|r: '#FFFF0000' or '#FF0000'\n|cFFFFFF00Name|r: 'yellow' 'white'"},
	
	{Name = "CreateAnimationHub",		Signature = "Plater:CreateAnimationHub (parent, onShowFunc, onHideFunc)",		Desc = "Creates an object to hold animations, see 'CreateAnimation' to add animations to the hub. When ReturnedValue:Play() is called all animations in the hub start playing respecting the Order set in the CreateAnimation().\n\nUse onShowFunc and onHideFunc to show or hide custom frames, textures or text.\n\nMethods:\n|cFFFFFF00ReturnedValue:Play()|r plays all animations in the hub.\n|cFFFFFF00ReturnedValue:Stop()|r: stop all animations in the hub.", AddVar = true, AddCall = "--@ENV@:Play() --@ENV@:Stop()"},
	{Name = "CreateAnimation",			Signature = "Plater:CreateAnimation (animationHub, animationType, order, duration, |cFFCCCCCCarg1|r, |cFFCCCCCCarg2|r, |cFFCCCCCCarg3|r, |cFFCCCCCCarg4|r)",	Desc = "Creates an animation within an animation hub.\n\nOrder: integer between 1 and 10, lower play first. Animations with the same Order play at the same time.\n\nDuration: how much time this animation takes to complete.\n\nAnimation Types:\n|cFFFFFF00\"Alpha\"|r:\n|cFFCCCCCCarg1|r: Alpha Start Value, |cFFCCCCCCarg2|r: Alpha End Value.\n\n|cFFFFFF00\"Scale\"|r:\n|cFFCCCCCCarg1|r: X Start, |cFFCCCCCCarg2|r: Y Start, |cFFCCCCCCarg3|r: X End, |cFFCCCCCCarg4|r: Y End.\n\n|cFFFFFF00\"Rotation\"|r:\n |cFFCCCCCCarg1|r: Rotation Degrees.\n\n|cFFFFFF00\"Translation\"|r:\n |cFFCCCCCCarg1|r: X Offset, |cFFCCCCCCarg2|r: Y Offset."},
	
	{Name = "CreateIconGlow",			Signature = "Plater.CreateIconGlow (self)",						Desc = "Creates a glow effect around an icon.\n\nUse:\n|cFFFFFF00ReturnedValue:Show()|r on OnShow.\n|cFFFFFF00ReturnedValue:Hide()|r on OnHide.\n|cFFFFFF00ReturnedValue:SetColor(dotColor, glowColor)|r to adjust the color.", AddVar = true, AddCall = "--@ENV@:Show() --@ENV@:Hide()"},
	{Name = "CreateNameplateGlow",		Signature = "Plater.CreateNameplateGlow (unitFrame.healthBar)",	Desc = "Creates a glow effect around the nameplate.\n\nUse:\n|cFFFFFF00ReturnedValue:Show()|r on OnShow.\n|cFFFFFF00ReturnedValue:Hide()|r on OnHide.\n|cFFFFFF00ReturnedValue:SetColor(dotColor, glowColor)|r to adjust the color.\n\nUse offsets to adjust the dot animation to fit the nameplate.", AddVar = true, AddCall = "--@ENV@:Show() --@ENV@:Hide() --@ENV@:SetOffset (-27, 25, 5, -7)"},

	{Name = "FormatNumber",			Signature = "Plater.FormatNumber (number)",	Desc = "Format a number to be short as possible.\n\nExample:\n300000 to 300K\n2500000 to 2.5M"},
	{Name = "CommaValue",			Signature = "Plater:CommaValue (number)",	Desc = "Format a number separating by thousands and millions.\n\nExample: 300000 to 300.000\n2500000 to 2.500.000"},
	{Name = "IntegerToTimer",			Signature = "Plater:IntegerToTimer (number)",	Desc = "Format a number to time\n\nExample: 94 to 1:34"},
	
	{Name = "RemoveRealmName",		Signature = "Plater:RemoveRealmName (playerName)",	Desc = "Removes the realm name from a player name."},
	{Name = "Trim",					Signature = "Plater:Trim (string)",			Desc = "Removes spaces in the begining and end of a string."},
	
}

Plater.UnitFrameMembers = {
	"unitFrame.castBar",
	"unitFrame.castBar.Text",
	"unitFrame.castBar.FrameOverlay",
	"unitFrame.castBar.percentText",
	--"unitFrame.castBar.extraBackground",
	"unitFrame.healthBar",
	"unitFrame.healthBar.actorName",
	--"unitFrame.healthBar.actorLevel",
	"unitFrame.healthBar.lifePercent",
	"unitFrame.healthBar.border",
	--"unitFrame.healthBar.healthCutOff",
	"unitFrame.BuffFrame",
	"unitFrame.BuffFrame2",
	--"unitFrame.ExtraIconFrame",
	"unitFrame.Top3DFrame",
	--"unitFrame.FocusIndicator",
	"unitFrame.TargetNeonUp",
	"unitFrame.TargetNeonDown",
}

Plater.NameplateComponents = {
	["unitFrame - Members"] = {
		"namePlateUnitToken",
		"namePlateUnitGUID",
		"namePlateNpcId",
		"namePlateIsQuestObjective",
		"namePlateUnitReaction",
		"namePlateClassification",
		"namePlateInRange",
		"namePlateUnitName",
		"namePlateUnitNameLower",
		"namePlateIsTarget",
		"namePlateThreatPercent",
	},
	
	["unitFrame - Frames"] = {
		"healthBar",
		"castBar",
		"aggroGlowUpper",
		"aggroGlowLower",
		"BuffFrame",
		"BuffFrame2",
		"PlaterRaidTargetFrame",
		"TargetNeonUp",
		"TargetNeonDown",
		"ExtraRaidMark",
		"ExtraIconFrame",
		"Top3DFrame",
		"ActorNameSpecial",
		"ActorTitleSpecial",
	},

	["healthBar - Members"] = {
		"CurrentHealth",
		"CurrentHealthMax",
	},
	
	["healthBar - Frames"] = {
		"actorName",
		"actorLevel",
		"lifePercent",
		"ExecuteRangeHealthCutOff",
		"ExecuteRangeBar",
		"ExecuteGlowUp",
		"ExecuteGlowDown",
		"ExtraRaidMark",
		"FocusIndicator",
	},
	
	["castBar - Members"] = {
		"unit",
		"ThrottleUpdate",
		"SpellName",
		"SpellID",
		"SpellTexture",
		"SpellStartTime",
		"SpellEndTime",
		"CanInterrupt",
		"IsInterrupted",
	},
	
	["castBar - Frames"] = {
		"percentText",
		"Text",
		"FrameOverlay",
		"TargetName",
		"BorderShield",
	},
	
}

Plater.TriggerDefaultMembers = {
	[1] = {
		"envTable._SpellID",
		"envTable._UnitID",
		"envTable._SpellName",
		"envTable._Texture",
		"envTable._Caster",
		"envTable._StackCount",
		"envTable._Duration",
		"envTable._StartTime",
		"envTable._EndTime",
		"envTable._RemainingTime",
	},
	[2] = {
		"envTable._SpellID",
		"envTable._UnitID",
		"envTable._SpellName",
		"envTable._Texture",
		"envTable._Caster",
		"envTable._Duration",
		"envTable._StartTime",
		"envTable._EndTime",
		"envTable._RemainingTime",
		"envTable._CastPercent",
		"envTable._CanInterrupt",
	},
	[3] = {
		"envTable._UnitID",
		"envTable._NpcID",
		"envTable._UnitName",
		"envTable._UnitGUID",
		"envTable._HealthPercent",
	},
}

--shared functions between all script tabs

	local onclick_menu_scroll_line = function (self, scriptId, option, mainFrame)
		if (option == "editscript") then
			mainFrame.EditScript (scriptId)
			
		elseif (option == "remove") then
			mainFrame.RemoveScript (scriptId)
			
		elseif (option == "duplicate") then
			mainFrame.DuplicateScript (scriptId)
			
		elseif (option == "export") then
			mainFrame.ExportScript (scriptId)
		
		elseif (option == "sendtogroup") then
			if (not IsInGroup()) then
				Plater:Msg ("You need to be in a group to use this export option.")
				return
			end
			Plater.ExportScriptToGroup (scriptId, mainFrame.ScriptType)
		end
		
		GameCooltip:Hide()
	end

	--when the user hover over a scrollbox line
	local onenter_scroll_line = function (self)
		self:SetBackdropColor (.3, .3, .3, .6)
	end
	
	--when the user leaves a scrollbox line from a hover over
	local onleave_scroll_line = function (self)
		local mainFrame = self.MainFrame
		local currentScript = mainFrame.GetCurrentScriptObject()
		
		--check if the hover overed button is the current script being edited
		if (currentScript == self.Data) then
			self:SetBackdropColor (unpack (scrollbox_line_backdrop_color_selected))
		else
			self:SetBackdropColor (unpack (scrollbox_line_backdrop_color))
		end
	end
	
	--when the user clicks on a scrollbox line
	local onclick_scroll_line = function (self, button)
		
		local mainFrame = self.MainFrame
		
		if (button == "LeftButton") then
			local currentScriptObject = mainFrame.GetCurrentScriptObject()
			--check if isn't the same script
			local scriptToBeEdited = mainFrame.GetScriptObject (self.ScriptId)
			if (scriptToBeEdited == currentScriptObject) then
				--no need to load the new script if is the same
				return
			end
			
			--save the current script if any
			if (currentScriptObject) then
				mainFrame.SaveScript()
			end
			
			--select the script to start edit
			mainFrame.EditScript (self.ScriptId)
			--refresh the script list to update the backdrop color of the selected script
			mainFrame.ScriptSelectionScrollBox:Refresh()
			
			--check if the import/export text field is shown and hide it
			if (mainFrame.ImportTextEditor:IsShown()) then
				mainFrame.ImportTextEditor:Hide()
			end
			
		elseif (button == "RightButton") then
			--open menu
			GameCooltip:Preset (2)
			GameCooltip:SetType ("menu")
			GameCooltip:SetOption ("TextSize", 10)
			GameCooltip:SetOption ("FixedWidth", 200)
			GameCooltip:SetOption ("ButtonsYModSub", -1)
			GameCooltip:SetOption ("YSpacingModSub", -4)
			GameCooltip:SetOwner (self, "topleft", "topright", 2, 0)
			GameCooltip:SetFixedParameter (self.ScriptId)

			GameCooltip:AddLine ("Edit Script")
			GameCooltip:AddMenu (1, onclick_menu_scroll_line, "editscript", mainFrame)
			GameCooltip:AddIcon ([[Interface\BUTTONS\UI-GuildButton-PublicNote-Up]], 1, 1, 16, 16)
			
			GameCooltip:AddLine ("Duplicate")
			GameCooltip:AddMenu (1, onclick_menu_scroll_line, "duplicate", mainFrame)
			GameCooltip:AddIcon ([[Interface\AddOns\Plater\images\icons]], 1, 1, 16, 16, 3/512, 21/512, 215/512, 233/512)

			GameCooltip:AddLine ("Export")
			GameCooltip:AddIcon ([[Interface\BUTTONS\UI-GuildButton-MOTD-Up]], 1, 1, 16, 16, 1, 0, 0, 1)
			
			GameCooltip:AddLine ("As a Text String", "", 2)
			GameCooltip:AddIcon ([[Interface\BUTTONS\UI-GuildButton-MOTD-Up]], 2, 1, 16, 16, 1, 0, 0, 1)
			GameCooltip:AddMenu (2, onclick_menu_scroll_line, "export", mainFrame)

			GameCooltip:AddLine ("Send to Your Party/Raid", "", 2)
			GameCooltip:AddIcon ([[Interface\BUTTONS\UI-GuildButton-MOTD-Up]], 2, 1, 16, 16, 1, 0, 0, 1)
			GameCooltip:AddMenu (2, onclick_menu_scroll_line, "sendtogroup", mainFrame)
			
			GameCooltip:AddLine ("Remove")
			GameCooltip:AddMenu (1, onclick_menu_scroll_line, "remove", mainFrame)
			GameCooltip:AddIcon ([[Interface\AddOns\Plater\images\icons]], 1, 1, 16, 16, 3/512, 21/512, 235/512, 257/512)
			
			GameCooltip:Show()
		end
	end
	
	local update_line = function (self, script_id, data)
		local icon_texture, script_name, script_type = data.Icon, data.Name, data.ScriptType
		
		self.ScriptId = script_id
		self.Data = data
		self.Icon:SetTexture (icon_texture)
		self.Icon:SetTexCoord (.1, .9, .1, .9)
		self.ScriptName:SetText (script_name)
		
		local scriptTypeName = self.MainFrame.GetScriptTriggerTypeName (script_type)
		self.ScriptType:SetText (scriptTypeName)
		
		self.EnabledCheckbox:SetValue (data.Enabled)
		self.EnabledCheckbox:SetFixedParameter (script_id)
	end
	
	local onclick_remove_script = function (self)
		local parent = self:GetParent() --get the line
		local scriptId = parent.ScriptId
		parent.MainFrame.RemoveScript (scriptId)
	end
	
	local cooltip_scriptsscrollbox = function (self, fixed_parameter)
		GameCooltip:Preset (2)
		GameCooltip:SetOption ("TextSize", 10)
		GameCooltip:SetOption ("FixedWidth", 200)
		
		local mainFrame = self.MainFrame
		
		local scriptObject = mainFrame.GetScriptObject (self.ScriptId)
		local lastEdited = date ("%d/%m/%Y", scriptObject.Time)
		
		GameCooltip:AddLine (scriptObject.Name, nil, 1, "yellow", "yellow", 11, "Friz Quadrata TT", "OUTLINE")
		if (scriptObject.Icon ~= "") then
			GameCooltip:AddIcon (scriptObject.Icon)
		end

		GameCooltip:AddLine ("Last Edited:", lastEdited)
		
		local scriptTypeName = mainFrame.GetScriptTriggerTypeName (scriptObject.ScriptType)
		GameCooltip:AddLine ("Trigger Type:", scriptTypeName)
		
		GameCooltip:AddLine ("Author:", scriptObject.Author or "--x--x--")
		
		if (scriptObject.Desc and scriptObject.Desc ~= "") then
			GameCooltip:AddLine (scriptObject.Desc, "", 1, "gray")
		end
		
	end
	
	local cooltip_inject_table_scriptsscrollbox = {
		Type = "tooltip",
		BuildFunc = cooltip_scriptsscrollbox,
		ShowSpeed = 0.016,
		MyAnchor = "topleft",
		HisAnchor = "topright",
		X = 10,
		Y = 0,
	}

	local toggle_script_enabled = function (self, scriptId, value)
		local mainFrame = self:GetParent().MainFrame
		local scriptObject = Plater.GetScriptObject (scriptId, self.ScriptType)
		if (scriptObject) then
			scriptObject.Enabled = value
			if (not value) then
				Plater.WipeAndRecompileAllScripts (mainFrame.ScriptType) --TODO added the if conditions need to make the logic
			else
				if (mainFrame.ScriptType == "script") then
					Plater.CompileScript (scriptObject)
					
				elseif (mainFrame.ScriptType == "hook") then
					Plater.CompileHook (scriptObject)
				end
			end
		end
		
		mainFrame.ScriptSelectionScrollBox:Refresh()
	end
	
	--create a line in the scroll box
	local create_line_scrollbox = function (self, index)
		--create a new line
		local line = CreateFrame ("button", "$parentLine" .. index, self)
		--get the scripting frame and store in the line
		line.MainFrame = self:GetParent()
		
		--set its parameters
		line:SetPoint ("topleft", self, "topleft", 1, -((index-1) * (scrollbox_line_height+1)) - 1)
		line:SetSize (scrollbox_size[1]-2, scrollbox_line_height)
		line:RegisterForClicks ("LeftButtonDown", "RightButtonDown")
		
		line:SetScript ("OnEnter", onenter_scroll_line)
		line:SetScript ("OnLeave", onleave_scroll_line)
		line:SetScript ("OnClick", onclick_scroll_line)
		
		line.CoolTip = cooltip_inject_table_scriptsscrollbox
		GameCooltip:CoolTipInject (line)
		
		line:SetBackdrop ({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true, edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1})
		line:SetBackdropColor (unpack (scrollbox_line_backdrop_color))
		line:SetBackdropBorderColor (0, 0, 0, 1)
		
		local icon = line:CreateTexture ("$parentIcon", "overlay")
		icon:SetSize (scrollbox_line_height-4, scrollbox_line_height-4)
		
		local script_name = DF:CreateLabel (line, "", DF:GetTemplate ("font", "PLATER_SCRIPTS_NAME"))
		local script_type = DF:CreateLabel (line, "", DF:GetTemplate ("font", "PLATER_SCRIPTS_TYPE"))
		
		local remove_button = CreateFrame ("button", "$parentRemoveButton", line, "UIPanelCloseButton")
		remove_button:SetSize (16, 16)
		remove_button:SetScript ("OnClick", onclick_remove_script)
		remove_button:SetPoint ("topright", line, "topright")
		remove_button:GetNormalTexture():SetDesaturated (true)
		remove_button:SetAlpha (.4)
		
		--hide the remove button
		remove_button:Hide()
		
		--create the enabled box
		--the with_label value with passing an empty string "" making the switch create a label and anchor the checkbox to it
		--after that it anchor the checkbox again here making the checkbox to be anchor to two different widgets making it not move while its parent moves
		local enabled_checkbox = DF:CreateSwitch (line, toggle_script_enabled, true, _, _, _, _, "enabledCheckbox", "$parentScriptToggle" .. index, _, _, _, nil, DF:GetTemplate ("switch", "OPTIONS_CHECKBOX_BRIGHT_TEMPLATE"))
		enabled_checkbox.ScriptType = line.MainFrame.ScriptType
		enabled_checkbox:SetAsCheckBox()
		
		--setup anchors
		icon:SetPoint ("left", line, "left", 2, 0)
		script_name:SetPoint ("topleft", icon, "topright", 2, -2)
		script_type:SetPoint ("topleft", script_name, "bottomleft", 0, 0)
		enabled_checkbox:SetPoint ("right", line, "right", -2, 0)
		
		line.Icon = icon
		line.ScriptName = script_name
		line.ScriptType = script_type
		line.EnabledCheckbox = enabled_checkbox
		
		line.UpdateLine = update_line

		return line
	end
	
	--refresh the list of scripts already created
	local refresh_script_scrollbox = function (self, data, offset, total_lines)
		--get the main frame
		local mainFrame = self:GetParent()
		
		--alphabetical order
		local dataInOrder = {}
		
		if (mainFrame.SearchString ~= "") then
			for i = 1, #data do
				if (data [i].Name:lower():find (mainFrame.SearchString)) then
					dataInOrder [#dataInOrder+1] = {i, data [i], data[i].Name, data[i].Enabled and 1 or 0}
				end
			end
		else
			for i = 1, #data do
				dataInOrder [#dataInOrder+1] = {i, data [i], data[i].Name, data[i].Enabled and 1 or 0}
			end
		end
		
		table.sort (dataInOrder, Plater.SortScripts)
		
		local currentScript = mainFrame.GetCurrentScriptObject()
		
		--update the scroll
		for i = 1, total_lines do
			local index = i + offset
			local t = dataInOrder [index]
			if (t) then
				--get the data
				local scriptId = t [1]
				local data = t [2]
				--update the line
				local line = self:GetLine (i)
				line:UpdateLine (scriptId, data)
				
				if (data == currentScript) then
					line:SetBackdropColor (unpack (scrollbox_line_backdrop_color_selected))
				else
					line:SetBackdropColor (unpack (scrollbox_line_backdrop_color))
				end
			end
		end
		
		--update overlap button
		if (mainFrame.UpdateOverlapButton) then
			mainFrame.UpdateOverlapButton()
		end
	end
	
	local create_script_control_header = function (mainFrame, scriptDB)
	
		local onclick_create_new_script_button = function()
			mainFrame.CreateNewScript()
		end
		
		--create new script script button, it does use the width of the scrollbox to select a created script	
		local create_new_script_button = DF:CreateButton (mainFrame, onclick_create_new_script_button, scrollbox_size[1] - (28*3), buttons_size[2], "New Script", -1, nil, nil, "CreateButton", nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
		create_new_script_button:SetPoint ("topleft", mainFrame, "topleft", 10, start_y)
		create_new_script_button:SetIcon ([[Interface\BUTTONS\UI-PlusButton-Up]], 20, 20, "overlay", {0, 1, 0, 1})
		
		--create the trash restore button
		local restore_script_button = DF:CreateButton (mainFrame, function() GameCooltip:Hide() end, 26, buttons_size[2], "", nil, nil, nil, nil, nil, false, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"))
		restore_script_button:SetPoint ("left", create_new_script_button, "right", 2, 0)
		restore_script_button:SetIcon ([[Interface\AddOns\Plater\images\icons]], 16, 16, "overlay", {0, 64/512, 0, 64/512}, {0.945, .635, 0}, nil, nil, nil, false)
		mainFrame.RestoreScriptButton = restore_script_button
		
		local restore_from_trashcan = function (self, fixed_parameter, script_id)
			local restoredScriptObject = Plater.db.profile [scriptDB .. "_data_trash"] [script_id]
			
			restoredScriptObject.__TrashAt = nil
			
			tinsert (Plater.db.profile [scriptDB .. "_data"], restoredScriptObject)
			tremove (Plater.db.profile [scriptDB .. "_data_trash"], script_id)
			
			--start editing the restored script
			mainFrame.EditScript (#Plater.db.profile [scriptDB .. "_data"])
			
			--refresh the script selection scrollbox
			mainFrame.ScriptSelectionScrollBox:Refresh()

			GameCooltip:Hide()
		end
		
		local build_restore_menu = function()
			local data = Plater.db.profile [scriptDB .. "_data_trash"]
			local timeToday = time()
			
			GameCooltip:Preset (2)
			GameCooltip:SetOption ("TextSize", 10)
			GameCooltip:SetOption ("FixedWidth", 200)
			
			if (#data == 0) then
				GameCooltip:SetType ("tooltip")
				GameCooltip:AddLine ("Recycle Bin", "", 1, "yellow", "yellow", 12, nil, "OUTLINE")
				GameCooltip:AddLine ("All deleted scripts are moved to here for 30 days where they can be restored during this period")
			else
				for i = 1, #data do
					local scriptObject = data [i]
					local age = timeToday - scriptObject.__TrashAt

					GameCooltip:AddLine (scriptObject.Name, floor (age/60/60/24) .. " days")
					GameCooltip:AddIcon (scriptObject.Icon  ~= "" and scriptObject.Icon or [[Interface\ICONS\INV_Misc_QuestionMark]], 1, 1, 20, 20)
					GameCooltip:AddMenu (1, restore_from_trashcan, i)
				end
			end
		end

		restore_script_button.CoolTip = {
			Type = "menu",
			BuildFunc = build_restore_menu,
			ShowSpeed = 0.05,
		}
		
		local GameCooltip = GameCooltip2
		GameCooltip:CoolTipInject (restore_script_button)
		
		--import button
		local import_script_button = DF:CreateButton (mainFrame, mainFrame.ShowImportTextField, 26, buttons_size[2], "", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
		import_script_button:SetPoint ("left", restore_script_button, "right", 2, 0)
		import_script_button:SetIcon ([[Interface\AddOns\Plater\images\icons]], 16, 16, "overlay", {5/512, 19/512, 195/512, 210/512}, {1, .8, .2}, nil, nil, nil, false)
		
		import_script_button:HookScript ("OnEnter", function()
			GameCooltip:Preset (2)
			GameCooltip:SetOption ("TextSize", 10)
			GameCooltip:SetOption ("FixedWidth", 200)
			GameCooltip:SetOwner  (import_script_button.widget)
			
			GameCooltip:AddLine ("Import Script", "", 1, "yellow", "yellow", 12, nil, "OUTLINE")
			GameCooltip:AddLine ("Add a new script from a previous exported string.\n\nYou can export to string by right clicking a script in the menu below.")
			
			GameCooltip:Show()
		end)	
		import_script_button:HookScript ("OnLeave", function()
			GameCooltip:Hide()
		end)
		
		--help button
		local help_script_button = DF:CreateButton (mainFrame, function() mainFrame.HelpFrame:Show() end, 26, buttons_size[2], "", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
		help_script_button:SetPoint ("left", import_script_button, "right", 2, 0)
		help_script_button:SetIcon ([[Interface\GossipFrame\ActiveQuestIcon]], 18, 18, "overlay", {0, 1, 0, 1}, nil, 0, -1, nil, false)	
	
		--scroll panel to select which script to edit
		local script_scrollbox_label = DF:CreateLabel (mainFrame, "Scripts", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
		local enabled_scrollbox_label = DF:CreateLabel (mainFrame, "Enabled", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
		
		mainFrame.ScriptScrollLabel = script_scrollbox_label
		mainFrame.ScriptEnabledLabel = enabled_scrollbox_label
		
		local data
		if (mainFrame.ScriptType == "script") then
			data = Plater.db.profile.script_data
		elseif (mainFrame.ScriptType == "hook") then
			data = Plater.db.profile.hook_data
		end
		
		local script_scroll_box = DF:CreateScrollBox (mainFrame, "$parentScrollBox", refresh_script_scrollbox, data, scrollbox_size[1], scrollbox_size[2], scrollbox_lines, scrollbox_line_height)
		DF:ReskinSlider (script_scroll_box)

		mainFrame.ScriptSelectionScrollBox = script_scroll_box

		--create the scrollbox lines
		for i = 1, scrollbox_lines do 
			script_scroll_box:CreateLine (create_line_scrollbox)
		end
		
		--script search box
		function mainFrame.OnSearchBoxTextChanged()
			local text = mainFrame.ScriptSearchTextEntry:GetText()
			mainFrame.SearchString = text:lower()
			script_scroll_box:Refresh()
		end

		local script_search_textentry = DF:CreateTextEntry (mainFrame, function()end, 200, 20, "ScriptSearchTextEntry", _, _, options_dropdown_template)
		script_search_textentry:SetPoint ("topleft", mainFrame.CreateButton, "bottomleft", 0, -20)
		script_search_textentry:SetHook ("OnChar", mainFrame.OnSearchBoxTextChanged)
		script_search_textentry:SetHook ("OnTextChanged", mainFrame.OnSearchBoxTextChanged)
		script_search_label = DF:CreateLabel (mainFrame, "Search:", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
		script_search_label:SetPoint ("bottomleft", script_search_textentry, "topleft", 0, 2)	
	
	end
	
	local create_script_namedesc = function (mainFrame, parent)
		--textentry to insert the name of the script
		local script_name_label = DF:CreateLabel (parent, "Script Name:", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
		local script_name_textentry = DF:CreateTextEntry (parent, function()end, 156, 20, "ScriptNameTextEntry", _, _, options_dropdown_template)
		script_name_textentry:SetPoint ("topleft", script_name_label, "bottomleft", 0, -2)
		mainFrame.ScriptNameTextEntry = script_name_textentry
	
		--icon selection
		local script_icon_callback = function (texture)
			mainFrame.ScriptIconButton:SetIcon (texture)
		end
		local script_icon_label = DF:CreateLabel (parent, "Icon:", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
		local script_icon_button = DF:CreateButton (parent, function() DF:IconPick (script_icon_callback, true) end, 20, 20, "", 0, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"))
		script_icon_button:SetPoint ("topleft", script_icon_label, "bottomleft", 0, -2)
		mainFrame.ScriptIconButton = script_icon_button
	
		--description
		local script_desc_label = DF:CreateLabel (parent, "Description:", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
		local script_desc_textentry = DF:CreateTextEntry (parent, function()end, 156, 20, "ScriptDescriptionTextEntry", _, _, options_dropdown_template)
		script_desc_textentry:SetPoint ("topleft", script_desc_label, "bottomleft", 0, -2)
		mainFrame.ScriptDescTextEntry = script_desc_textentry
		
		parent.ScriptNameLabel = script_name_label
		parent.ScriptIconLabel = script_icon_label
		parent.ScriptDescLabel = script_desc_label
	end
	
	local create_import_box = function (parent, mainFrame)
		--import and export string text editor
		local import_text_editor = DF:NewSpecialLuaEditorEntry (parent, edit_script_size[1], edit_script_size[2], "ImportEditor", "$parentImportEditor", true)
		import_text_editor:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
		import_text_editor:SetBackdropBorderColor (unpack (luaeditor_border_color))
		import_text_editor:SetBackdropColor (unpack (luaeditor_backdrop_color))
		import_text_editor:Hide()
		
		--hide the code editor when the import text editor is shown
		import_text_editor:SetScript ("OnShow", function()
			mainFrame.CodeEditorLuaEntry:Hide()
		end)
		
		--show the code editor when the import text editor is hide
		import_text_editor:SetScript ("OnHide", function()
			mainFrame.CodeEditorLuaEntry:Show()
		end)
		
		mainFrame.ImportTextEditor = import_text_editor
		
		--import info
		local info_import_label = DF:CreateLabel (import_text_editor, "IMPORT INFO:", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
		info_import_label:SetPoint ("bottomleft", import_text_editor, "topleft", 0, 2)
		mainFrame.ImportTextEditor.TextInfo = info_import_label
		
		--import button
		local okay_import_button = DF:CreateButton (import_text_editor, mainFrame.ImportScript, buttons_size[1], buttons_size[2], "Okay", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
		okay_import_button:SetIcon ([[Interface\BUTTONS\UI-Panel-BiggerButton-Up]], 20, 20, "overlay", {0.1, .9, 0.1, .9})
	
		--cancel button
		local cancel_import_button = DF:CreateButton (import_text_editor, function() mainFrame.ImportTextEditor:Hide() end, buttons_size[1], buttons_size[2], "Cancel", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
		cancel_import_button:SetIcon ([[Interface\BUTTONS\UI-Panel-MinimizeButton-Up]], 20, 20, "overlay", {0.1, .9, 0.1, .9})
		
		import_text_editor.OkayButton = okay_import_button
		import_text_editor.CancelButton = cancel_import_button
	end
	
	local create_code_editor = function (parent, mainFrame)
		local code_editor = DF:NewSpecialLuaEditorEntry (parent, edit_script_size[1], edit_script_size[2], "CodeEditor", "$parentCodeEditor")
		
		code_editor.scroll:SetBackdrop (nil)
		code_editor.editbox:SetBackdrop (nil)
		code_editor:SetBackdrop (nil)
		
		DF:ReskinSlider (code_editor.scroll)
		
		--DF:ApplyStandardBackdrop (code_editor, false, 1)
		
		if (not code_editor.__background) then
			code_editor.__background = code_editor:CreateTexture (nil, "background")
		end
		
		code_editor:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1})
		code_editor:SetBackdropBorderColor (0, 0, 0, 1)
		
		code_editor.__background:SetColorTexture (0.2317647, 0.2317647, 0.2317647)
		code_editor.__background:SetVertexColor (0.27, 0.27, 0.27)
		code_editor.__background:SetAlpha (0.8)
		code_editor.__background:SetVertTile (true)
		code_editor.__background:SetHorizTile (true)
		code_editor.__background:SetAllPoints()				
		
		mainFrame.CodeEditorLuaEntry = code_editor

		--add api palette dropdown
		local on_select_FW_option = function (self, fixed_parameter, option_selected)
			local api = Plater.APIList [option_selected]
			code_editor.editbox:Insert (api.Signature)
		end
		
		local build_API_dropdown_options = function()
			local t = {}
			for i = 1, #Plater.APIList do 
				local api = Plater.APIList [i]
				t [#t + 1] = {label = api.Name, value = i, onclick = on_select_FW_option, desc = "Signature:\n|cFFFFFF00" .. api.Signature .. "|r\n\n" .. api.Desc, tooltipwidth = 300}
			end
			return t
		end
		
		local add_API_label = DF:CreateLabel (parent, "API Palette:", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
		local add_API_dropdown = DF:CreateDropDown (parent, build_API_dropdown_options, 1, 130, 20, "AddAPIDropdown", _, DF:GetTemplate ("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
		mainFrame.AddAPIDropdown = add_API_dropdown
		add_API_dropdown:SetFrameStrata (code_editor:GetFrameStrata())
		add_API_dropdown:SetFrameLevel (code_editor:GetFrameLevel()+100)

		--top right of the code editor
		add_API_dropdown:SetPoint ("bottomright", code_editor, "topright", 0, 2)
		add_API_label:SetPoint ("right", add_API_dropdown, "left", -2, 0)

		--add framework palette dropdowns
		local frameworkSelected
		local memberNameCallback = function (text)
			if (text and text ~= "" and not text:find ("%s")) then
				text = DF:Trim (text)
				local textToAdd = frameworkSelected.Signature
				
				--save the current cursor position
				code_editor.editbox:SetFocus (true)
				local cursorPosition = code_editor.editbox:GetCursorPosition()
				
				--insert the text
				local textToInsert = "envTable." .. text .. " = envTable." .. text .. " or " .. frameworkSelected.Signature
				code_editor.editbox:Insert (textToInsert)
				
				if (frameworkSelected.AddCall) then
					code_editor.editbox:Insert ("\n")
					local addCallString = frameworkSelected.AddCall
					addCallString = addCallString:gsub ("@ENV@", "envTable." .. text)
					code_editor.editbox:Insert (addCallString)
					code_editor.editbox:Insert ("\n")
				end

				--restore the cursor position
				local argumentStart = textToInsert:find ("%(")
				code_editor.editbox:SetCursorPosition (cursorPosition + argumentStart)
				
			else
				Plater:Msg ("Invalid variable name.")
			end
		end
		
		local on_select_FW_option = function (self, fixed_parameter, option_selected)
			local framework = Plater.FrameworkList [option_selected]
			
			if (framework.AddVar) then
				frameworkSelected = framework
				DF:ShowTextPromptPanel ("Name the variable using letters, numbers and no spaces (e.g. myFlash, overlayTexture, animation1)", memberNameCallback)
			else
				code_editor.editbox:Insert (framework.Signature)
			end
		end
		
		local build_FW_dropdown_options = function()
			local t = {}
			for i = 1, #Plater.FrameworkList do 
				local api = Plater.FrameworkList [i]
				t [#t + 1] = {label = api.Name, value = i, onclick = on_select_FW_option, desc = "Signature:\n|cFFFFFF00" .. api.Signature .. "|r\n\n" .. api.Desc, tooltipwidth = 300}
			end
			return t
		end
		
		local add_FW_label = DF:CreateLabel (parent, "Framework Palette:", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
		local add_FW_dropdown = DF:CreateDropDown (parent, build_FW_dropdown_options, 1, 130, 20, "AddFWDropdown", _, DF:GetTemplate ("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
		mainFrame.AddFWDropdown = add_FW_dropdown
		add_FW_dropdown:SetFrameStrata (code_editor:GetFrameStrata())
		add_FW_dropdown:SetFrameLevel (code_editor:GetFrameLevel()+100)
	
		add_FW_dropdown:SetPoint ("right", add_API_label, "left", -10, 0)
		add_FW_label:SetPoint ("right", add_FW_dropdown, "left", -2, 0)
			
		--error text
		local errortext_frame = CreateFrame ("frame", nil, code_editor)
		errortext_frame:SetPoint ("bottomleft", code_editor, "bottomleft", 1, 1)
		errortext_frame:SetPoint ("bottomright", code_editor, "bottomright", -1, 1)
		errortext_frame:SetHeight (20)
		errortext_frame:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
		errortext_frame:SetBackdropBorderColor (unpack (luaeditor_border_color))
		errortext_frame:SetBackdropColor (0, 0, 0)
		
		local errortext_label = DF:CreateLabel (errortext_frame, "", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
		errortext_label.textcolor = "red"
		--errortext_label:SetPoint ("bottomright", code_editor, "topright", 0, 2)
		errortext_label:SetPoint ("left", errortext_frame, "left", 3, 0)
		
		code_editor.NextCodeCheck = 0.33
		
		code_editor:HookScript ("OnUpdate", function (self, deltaTime)
		
			code_editor.NextCodeCheck = code_editor.NextCodeCheck - deltaTime
			
			if (code_editor.NextCodeCheck < 0) then
			
				local script = code_editor:GetText()
				script = "return " .. script
				local func, errortext = loadstring (script, "Q")
				if (not func) then
					local firstLine = strsplit ("\n", script, 2)
					errortext = errortext:gsub (firstLine, "")
					errortext = errortext:gsub ("%[string \"", "")
					errortext = errortext:gsub ("...\"]:", "")
					errortext = errortext:gsub ("Q\"]:", "")
					errortext = "Line " .. errortext
					errortext_label.text = errortext
				else
					errortext_label.text = ""
				end
				
				code_editor.NextCodeCheck = 0.33
			end
			--
		end)
		
		--apply button
		local apply_script_button = DF:CreateButton (code_editor, mainFrame.ApplyScript, buttons_size[1], buttons_size[2], "Apply", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
		apply_script_button:SetIcon ([[Interface\BUTTONS\UI-Panel-BiggerButton-Up]], 20, 20, "overlay", {0.1, .9, 0.1, .9})
		
		--save button
		local save_script_button = DF:CreateButton (code_editor, mainFrame.SaveScript, buttons_size[1], buttons_size[2], "Save", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
		save_script_button:SetIcon ([[Interface\BUTTONS\UI-Panel-ExpandButton-Up]], 20, 20, "overlay", {0.1, .9, 0.1, .9})
		
		--cancel button
		local cancel_script_button = DF:CreateButton (code_editor, mainFrame.CancelEditing, buttons_size[1], buttons_size[2], "Cancel", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
		cancel_script_button:SetIcon ([[Interface\BUTTONS\UI-Panel-MinimizeButton-Up]], 20, 20, "overlay", {0.1, .9, 0.1, .9})
		
		mainFrame.ApplyScriptButton = apply_script_button
		mainFrame.SaveScriptButton = save_script_button
		mainFrame.CancelScriptButton = cancel_script_button
		
	end
	

function Plater.CreateHookingPanel()
	
	--controi o menu principal
	local f = PlaterOptionsPanelFrame
	local mainFrame = PlaterOptionsPanelContainer
	
--[=[	
		Plater.db.profile.hook_data
		Plater.db.profile.hook_data_trash
		Plater.db.profile.hook_auto_imported
		Plater.db.profile.hook_banned_user
	
		hook_data = {},
		hook_data_trash = {}, --deleted scripts are placed here, they can be restored in 30 days
		hook_auto_imported = {}, --store the name and revision of scripts imported from the Plater script library
		hook_banned_user = {}, --players banned from sending scripts to this player
	--]=]

	local hookFrame = mainFrame.AllFrames [14]
	
	--holds the current text to search
	hookFrame.SearchString = ""
	hookFrame.ScriptType = "hook"
	hookFrame.LastAddedHookTime = GetTime()
	currentEditingScript = nil
	
	function hookFrame.GetCurrentScriptObject()
		return currentEditingScript
	end
	
	function hookFrame.GetScriptObject (script_id)
		local script = Plater.db.profile.hook_data [script_id]
		if (script) then
			return script
		else
			Plater:Msg ("GetScriptObject could find the script id")
			return
		end
	end
	
	--restore the values on the text fields and scroll boxes to the values on the object
	function hookFrame.CancelEditing (is_deleting)
		if (not is_deleting) then
			--re fill all the text entried and dropdowns to the default from the script
			--doing this to restore the script so it can do a hot reload
			hookFrame.UpdateEditingPanel()
			
			--hot reload restored scripts
			hookFrame.ApplyScript()
		end
		
		--clear current editing script
		currentEditingScript = nil
		
		--lock the editing panel
		hookFrame.EditScriptFrame:LockFrame()

		--reload the script selection scrollbox in case the script got renamed
		hookFrame.ScriptSelectionScrollBox:Refresh()
	end
	
	--must have this for the shared frames
	function hookFrame.GetScriptTriggerTypeName()
		return ""
	end
	
	--save all values
	function hookFrame.SaveScript()
		--get the current editing object
		local scriptObject = hookFrame.GetCurrentScriptObject()
		
		--script name
		scriptObject.Name = hookFrame.ScriptNameTextEntry.text
		--script icon
		scriptObject.Icon = hookFrame.ScriptIconButton:GetIconTexture()
		--script description
		scriptObject.Desc = hookFrame.ScriptDescTextEntry.text
		--time and revision
		scriptObject.Time = time()
		scriptObject.Revision = scriptObject.Revision + 1
		
		--reload the script selection scrollbox in case the script got renamed
		hookFrame.ScriptSelectionScrollBox:Refresh()
		
		--remove focus of everything
		hookFrame.CodeEditorLuaEntry:ClearFocus()
		hookFrame.ScriptNameTextEntry:ClearFocus()
		hookFrame.ScriptDescTextEntry:ClearFocus()
		
		--transfer code from temp table to hook table
		for hookName, _ in pairs (scriptObject.Hooks) do
			scriptObject.Hooks [hookName] = scriptObject.HooksTemp [hookName]
		end

		--save the current code for the hook being edited now
		if (scriptObject.LastHookEdited ~= "" and scriptObject.Hooks [scriptObject.LastHookEdited]) then
			local currentCode = hookFrame.CodeEditorLuaEntry:GetText()
			scriptObject.Hooks [scriptObject.LastHookEdited] = currentCode
			scriptObject.HooksTemp [scriptObject.LastHookEdited] = currentCode
		end
		
		--do a hot reload on the script
		hookFrame.ApplyScript()
		
		--refresh all nameplates shown in the screen
		Plater.FullRefreshAllPlates()
	end
	
	--hot reload the script by compiling it and applying it to the nameplates without saving
	function hookFrame.ApplyScript()
		Plater.WipeAndRecompileAllScripts ("hook")
	end
	
	function hookFrame.RemoveScript (scriptId)
		local scriptObjectToBeRemoved = hookFrame.GetScriptObject (scriptId)
		local currentScript = hookFrame.GetCurrentScriptObject()
		
		--check if the script to be removed is valid
		if (not scriptObjectToBeRemoved) then
			return
		end
		
		--if is the current script being edited, cancel the edit
		if (currentScript == scriptObjectToBeRemoved) then
			--cancel the editing process
			hookFrame.CancelEditing (true)
		end
		
		--set the time when the script has been moved to trash
		scriptObjectToBeRemoved.__TrashAt = time()
		
		tinsert (Plater.db.profile.hook_data_trash, scriptObjectToBeRemoved)
		tremove (Plater.db.profile.hook_data, scriptId)
		
		--refresh the script selection scrollbox
		hookFrame.ScriptSelectionScrollBox:Refresh()
		
		GameCooltip:Hide()
		Plater:Msg ("Script moved to trash.")
		
		--reload all scripts
		Plater.WipeAndRecompileAllScripts (hookFrame.ScriptType)
	end
	
	function hookFrame.DuplicateScript (scriptId)
		local scriptToBeCopied = hookFrame.GetScriptObject (scriptId)
		local newScript = DF.table.copy ({}, scriptToBeCopied)
		
		tinsert (Plater.db.profile.hook_data, newScript)
		hookFrame.ScriptSelectionScrollBox:Refresh()
		
		Plater:Msg ("Script duplicated!.")
	end	
	
	--called from the context menu when right click an option in the script menu
	function hookFrame.ExportScript (scriptId)
		local scriptToBeExported = hookFrame.GetScriptObject (scriptId)
		
		--convert the script table into a index table for smaller size
		local tableToExport = Plater.PrepareTableToExport (scriptToBeExported)
		--compress the index table
		local encodedString = Plater.CompressData (tableToExport, "print")
		
		hookFrame.ImportTextEditor.IsImporting = false
		hookFrame.ImportTextEditor.IsExporting = true
		
		hookFrame.ImportTextEditor:Show()
		hookFrame.ImportTextEditor:SetText (encodedString)
		hookFrame.ImportTextEditor.TextInfo.text = "Exporting '" .. scriptToBeExported.Name .. "'"
		
		--if there's anything being edited, start editing the script which is being exported
		if (not hookFrame.GetCurrentScriptObject()) then
			hookFrame.EditScript (scriptId)
		end
		
		hookFrame.EditScriptFrame:Show()
		
		C_Timer.After (0.3, function()
			hookFrame.ImportTextEditor.editbox:SetFocus (true)
			hookFrame.ImportTextEditor.editbox:HighlightText()
		end)
	end

	function hookFrame.ShowImportTextField()
		--if editing a script, save it and close it
		local scriptObject = hookFrame.GetCurrentScriptObject()
		if (scriptObject) then
			hookFrame.SaveScript()
			hookFrame.CancelEditing()
			--refresh the script selection scrollbox
			hookFrame.ScriptSelectionScrollBox:Refresh()
		end
		
		--lock the editing panel
		hookFrame.EditScriptFrame:LockFrame()
		
		hookFrame.EditScriptFrame:Show()
		hookFrame.ImportTextEditor:Show()
		hookFrame.ImportTextEditor:SetText ("")
		hookFrame.ImportTextEditor.IsImporting = true
		hookFrame.ImportTextEditor.IsExporting = false
		hookFrame.ImportTextEditor:SetFocus (true)
		hookFrame.ImportTextEditor.TextInfo.text = "Paste the string:"
	end
	
	--this is only called from the 'okay' button in the import text editor
	function hookFrame.ImportScript()
	
		--if clicked in the 'okay' button when the import text editor is showing a string to export, just hide the import editor
		if (hookFrame.ImportTextEditor.IsExporting) then
			hookFrame.ImportTextEditor.IsImporting = nil
			hookFrame.ImportTextEditor.IsExporting = nil
			hookFrame.ImportTextEditor:Hide()
			return
		end
	
		local text = hookFrame.ImportTextEditor:GetText()

		--cleanup the text removing extra spaces and break lines
		text = DF:Trim (text)
		
		if (string.len (text) > 0) then
		
			local indexScriptTable = Plater.DecompressData (text, "print")

			if (indexScriptTable and type (indexScriptTable) == "table") then
			
				local scriptType = Plater.GetDecodedScriptType (indexScriptTable)
				if (scriptType ~= "hook") then
					--the user inserted a string for a script into the hook import
					--call the external function to import this script with ignoreRevision, overrideExisting and showDebug
					local importSuccess, newObject = Plater.ImportScriptString (text, true, true, true)
					if (importSuccess) then
						PlaterOptionsPanelContainer:SelectIndex (Plater, PLATER_OPTIONS_SCRIPTING_TAB)
						local mainFrame = PlaterOptionsPanelContainer
						local scriptingFrame = mainFrame.AllFrames [PLATER_OPTIONS_SCRIPTING_TAB]
						scriptingFrame.EditScript (newObject)
						scriptingFrame.ScriptSelectionScrollBox:Refresh()
					end
					
					hookFrame.ImportTextEditor.IsImporting = nil
					hookFrame.ImportTextEditor:Hide()
					
					return
				end
				
				local newScript = Plater.BuildScriptObjectFromIndexTable (indexScriptTable, "hook")
				if (newScript) then
					tinsert (Plater.db.profile.hook_data, newScript)
					hookFrame.ScriptSelectionScrollBox:Refresh()
					hookFrame.EditScript (#Plater.db.profile.hook_data)
					--refresh the script selection scrollbox
					hookFrame.ScriptSelectionScrollBox:Refresh()
				else
					Plater:Msg ("Cannot import: data imported is invalid")
				end
			else
				Plater:Msg ("Cannot import: data imported is invalid")
			end

		end
		
		hookFrame.ImportTextEditor.IsImporting = nil
		hookFrame.ImportTextEditor:Hide()
	end

	--set all values from the current editing script object to all text entried and scroll fields
	function hookFrame.UpdateEditingPanel()
		--get the current editing object
		local scriptObject = hookFrame.GetCurrentScriptObject()
		
		--set the data from the object in the widgets
		hookFrame.ScriptNameTextEntry.text =  scriptObject.Name
		hookFrame.ScriptNameTextEntry:ClearFocus()
		hookFrame.ScriptIconButton:SetIcon (scriptObject.Icon)
		hookFrame.ScriptDescTextEntry.text = scriptObject.Desc or ""
		hookFrame.ScriptDescTextEntry:ClearFocus()
		
		hookFrame.HookScrollBox:Refresh()
		hookFrame.HookTypeDropdown:Refresh()
		
		--validate the latest selected hook
		scriptObject.LastHookEdited = scriptObject.LastHookEdited or next (scriptObject.Hooks)
		
		--check if the hook script for the last selected hook exists
		if (scriptObject.LastHookEdited ~= "" and scriptObject.Hooks [scriptObject.LastHookEdited]) then
			hookFrame.CodeEditorLuaEntry:SetText (scriptObject.Hooks [scriptObject.LastHookEdited])
		else	
			--try to get a new last hook
			scriptObject.LastHookEdited = next (scriptObject.Hooks) or ""
			if (scriptObject.LastHookEdited ~= "") then
				hookFrame.CodeEditorLuaEntry:SetText (scriptObject.Hooks [scriptObject.LastHookEdited])
			else
				hookFrame.CodeEditorLuaEntry:SetText ("") 
			end
		end
		
		hookFrame.CodeEditorLuaEntry:ClearFocus()
		
		--copy scripts to the temp tables
		for hookName, codeText in pairs (scriptObject.Hooks) do
			scriptObject.HooksTemp [hookName] = codeText
		end
		
		hookFrame.HookTypeDropdown:Select (scriptObject.LastHookEdited)
	end

	--start editing a script
	function hookFrame.EditScript (script_id)
		local scriptObject
	
		--> check if passed a script object
		if (type (script_id) == "table") then
			scriptObject = script_id
		else
			scriptObject = hookFrame.GetScriptObject (script_id)
		end
		
		if (not scriptObject) then
			return
		end
		
		hookFrame.EditScriptFrame:UnlockFrame()
		hookFrame.EditScriptFrame:Show()
		
		--set the new editing script
		currentEditingScript = scriptObject
		
		--load the values in the frame
		hookFrame.UpdateEditingPanel()
	end	
	
	
	hookFrame:SetScript ("OnShow", function()
		--update the hook scripts scrollbox
		hookFrame.ScriptSelectionScrollBox:Refresh()
		
		--check trash can timeout
		local timeout = 60 * 60 * 24 * 30
		
		for i = #Plater.db.profile.hook_data_trash, 1, -1 do
			local scriptObject = Plater.db.profile.hook_data_trash [i]
			if (not scriptObject.__TrashAt or scriptObject.__TrashAt + timeout < time()) then
				tremove (Plater.db.profile.hook_data_trash, i)
			end
		end
	end)
	
	hookFrame:SetScript ("OnHide", function()
		--save
		local hookObject = hookFrame.GetCurrentScriptObject()
		if (hookObject) then
			hookFrame.SaveScript()
		end
	end)
	
	hookFrame.DefaultScript = [=[
		function (self, unitId, unitFrame, envTable)
			
		end
	]=]
	
	--a new script has been created
	function hookFrame.CreateNewScript()

		--build the table of the new script
		local newScriptObject = {
			Enabled = true,
			Name = "New Script",
			Icon = "",
			Desc = "",
			Author = UnitName ("Player") .. "-" .. GetRealmName(),
			Time = time(),
			Revision = 1,
			PlaterCore = Plater.CoreVersion,
			Hooks = {
				--["Function Name"] = " CODE " ??
			},
			HooksTemp = {},
			LastHookEdited = "",
			LoadConditions = DF:UpdateLoadConditionsTable ({}),
		}
		
		--add it to the database
		tinsert (Plater.db.profile.hook_data, newScriptObject)
		
		--start editing the new script
		hookFrame.EditScript (#Plater.db.profile.hook_data)
		
		--refresh the scrollbox showing all scripts created
		hookFrame.ScriptSelectionScrollBox:Refresh()
	end
	
	function hookFrame.AddHookToScript (hookName)
		local scriptObject = hookFrame.GetCurrentScriptObject()
		if (not scriptObject) then
			return
		end
		
		--add the hook to the script object
		if (not scriptObject.Hooks [hookName]) then
			--try to restore code from the temp table
			scriptObject.Hooks [hookName] = scriptObject.HooksTemp [hookName] or hookFrame.DefaultScript
			scriptObject.HooksTemp [hookName] = hookFrame.DefaultScript
		end
		
		--when adding, it start to edit the code for the hook added, check if there's a code being edited and save it
		local lastEditedHook = scriptObject.LastHookEdited
		if (lastEditedHook ~= "") then
			scriptObject.HooksTemp [lastEditedHook] = hookFrame.CodeEditorLuaEntry:GetText()
		end
		hookFrame.CodeEditorLuaEntry:SetText (scriptObject.Hooks [hookName])
		scriptObject.LastHookEdited = hookName
		
		--update the hook scroll list
		hookFrame.HookScrollBox:Refresh()
		
		--refresh the hook selection dropdown
		hookFrame.HookTypeDropdown:Refresh()
		hookFrame.HookTypeDropdown:Select (hookName)
	end
	
	function hookFrame.RemoveHookFromScript (hookName)
		local scriptObject = hookFrame.GetCurrentScriptObject()
		if (not scriptObject) then
			return
		end
		
		--remove the hook from this script object
		if (scriptObject.Hooks [hookName]) then
			scriptObject.Hooks [hookName] = nil
			--won't delete the old hook script, instead just let the code there if the hook is added back later
			--scriptObject.HooksTemp [hookName] = nil
		end

		--refresh the hook selection dropdown
		hookFrame.HookTypeDropdown:Refresh()
		
		--if the removed hook was the hook being edited, try to select another hook and start editing its code
		if (scriptObject.LastHookEdited == hookName) then
			scriptObject.LastHookEdited = next (scriptObject.Hooks) or ""
			if (scriptObject.LastHookEdited ~= "") then
				hookFrame.CodeEditorLuaEntry:SetText (scriptObject.Hooks [scriptObject.LastHookEdited])
				hookFrame.HookTypeDropdown:Select (scriptObject.LastHookEdited)
			else
				hookFrame.CodeEditorLuaEntry:SetText ("")
			end
		end
	
		--update the hook scroll list
		hookFrame.HookScrollBox:Refresh()
	end
	
	--create the frame which will hold the create panel
	local edit_script_frame = CreateFrame ("frame", "$parentCreateScript", hookFrame)
	edit_script_frame:SetSize (unpack (main_frames_size))
	edit_script_frame:SetScript ("OnShow", function()

	end)
	edit_script_frame:SetScript ("OnHide", function()

	end)
	edit_script_frame:Hide()
	hookFrame.EditScriptFrame = edit_script_frame	
	
	function edit_script_frame.UnlockFrame()
		hookFrame.ScriptNameTextEntry:Enable()
		hookFrame.ScriptIconButton:Enable()
		hookFrame.ScriptDescTextEntry:Enable()

		hookFrame.AddAPIDropdown:Enable()
		hookFrame.AddFWDropdown:Enable()
		
		hookFrame.CodeEditorLuaEntry:Enable()
		hookFrame.SaveScriptButton:Enable()
		hookFrame.CancelScriptButton:Enable()
		hookFrame.HookTypeDropdown:Enable()
		hookFrame.LoadConditionsButton:Enable()
		hookFrame.ComponentsButton:Enable()
		
	end
	
	function edit_script_frame.LockFrame()
		hookFrame.ScriptNameTextEntry:SetText ("")
		hookFrame.ScriptNameTextEntry:Disable()
		hookFrame.ScriptIconButton:SetIcon ("")
		hookFrame.ScriptIconButton:Disable()
		hookFrame.ScriptDescTextEntry:SetText ("")
		hookFrame.ScriptDescTextEntry:Disable()

		hookFrame.AddAPIDropdown:Disable()
		hookFrame.AddFWDropdown:Disable()
		
		hookFrame.CodeEditorLuaEntry:SetText ("")
		hookFrame.CodeEditorLuaEntry:Disable()
		hookFrame.SaveScriptButton:Disable()
		hookFrame.CancelScriptButton:Disable()
		hookFrame.HookTypeDropdown:Disable()
		
		hookFrame.LoadConditionsButton:Disable()
		hookFrame.ComponentsButton:Disable()
		
		hookFrame.HookScrollBox:Refresh()
	end
	
	function hookFrame.HideEditPanel()
		edit_script_frame:Hide()
	end
	
	--end of the logic part
	
	--create help frame
	do
		local help_popup = DF:CreateSimplePanel (UIParent, 1000, 480, "Plater Hook Help", "PlaterHookHelp")
		help_popup:SetFrameStrata ("DIALOG")
		help_popup:SetPoint ("center")
		DF:ApplyStandardBackdrop (help_popup, false, 1.2)
		help_popup:Hide()
		
		hookFrame.HelpFrame = help_popup
	
		local scripting_help_label = DF:CreateLabel (help_popup, "", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
		
		local frontpageText_Welcome = "Hooking allows you to run code in a nameplate after a certain event happened.\n"
		local frontpageText_Lua = "A basic knowledge of Lua programming may be required.\n\n"
		local frontpageText_Triggers = "|cFFFFFF00How a Plater Hook Works:|r\n\nYou add an event and when the event is triggered at any nameplate it runs the code for that specific nameplate.\n"
		local frontpageText_Scripts = "There's many types of events and they share an environment table between them for each nameplate.\n"
		local frontpageText_Function = "\n|cFFFFFF00Function Parameters:|r\n\n|cFFC0C0C0function (self, unit, unitFrame, envTable)\n    --code\nend|r\n\n|cFFFF5500self|r: is different for each type of event, for instance, self is the castBar frame for 'Cast Start' event and the unitFrame for 'Nameplate Added'.\n|cFFFF5500unit|r: unitId of the unit shown in the nameplate, use to query data, for example: UnitName (unitId).\n|cFFFF5500unitFrame|r: is the nameplate unit frame (parent of all widgets).\n|cFFFF5500envTable|r: a table where you can store data, this table is shared between each event script but not different nameplates.\n"
		local frontpageText_ReturnValues = "\nWhat is a |cFFFF5500ReturnValue|r?\nIs what a function returns after a calling it, example:\nenvTable.MyFlash = Plater.CreateFlash (unitFrame.healthBar, 0.05, 2, 'white')\nPlater.CreateFlash() returned an object with information about the flash created, then this information is stored inside '|cFFFF5500envTable.MyFlash|r'\nYou can use it later to play the flash with '|cFFFF5500envTable.MyFlash:Play()|r' or stop it with '|cFFFF5500envTable.MyFlash:Stop()|r'."
		local frontpageText_Parent = "\n\nWhat is a |cFFFF5500Parent|r?\nThe parent field required for create some widgets is the frame which will hold it, in other words: where it will be attach to."
		
		scripting_help_label.text = frontpageText_Welcome .. frontpageText_Lua .. frontpageText_Triggers .. frontpageText_Scripts .. frontpageText_Function .. frontpageText_ReturnValues .. frontpageText_Parent
		scripting_help_label.fontsize = 14
		scripting_help_label:SetPoint ("topleft", help_popup, "topleft", 5, -25)
	end
	
	--create the header and script scroll box
	create_script_control_header (hookFrame, "hook")
	
	--create the script name and desc frames
	create_script_namedesc (hookFrame, edit_script_frame)

	local onEnterHookButton = function (self)
		if (self.CanAddHook or self.CanRemoveHook) then
			self:SetBackdropColor (.3, .3, .3, 0.7)
		end
		
		GameCooltip2:Preset (2)
		GameCooltip2:AddLine (self.tooltip)
		GameCooltip2:ShowCooltip (self, "tooltip")
	end
	
	local onLeaveHookButton = function (self)
		if (self.IsEditing) then
			self:SetBackdropColor (1, .6, 0, 0.5)
		else
			self:SetBackdropColor (unpack (scrollbox_line_backdrop_color))
		end
		GameCooltip2:Hide()
	end
	
	local updateHookLine = function (self, index, hookName)
		self.HookName:SetText (hookName)
		self.tooltip = Plater.HookScriptsDesc [hookName]
		self.Hook = hookName
		self:SetBackdropBorderColor (0, 0, 0, 0)
		self.AddedLabel:SetText ("")
		self.RemoveButton:Hide()
		self.AddButton:Hide()
		self.CanAddHook = false
		self.CanRemoveHook = false
		self.IsEditing = false
		self:SetAlpha (1)
		
		local scriptObject = hookFrame.GetCurrentScriptObject()
		if (not scriptObject) then
			self:SetAlpha (.5)
			return
		end

		--does this scriptObject has this hook?
		if (scriptObject.Hooks [hookName]) then
			self.AddedLabel:SetText ("ADDED")
			self.RemoveButton:Show()
			self:SetBackdropBorderColor (1, .6, 0, 0.5)
			self.CanRemoveHook = true
			self:SetAlpha (1)
			
			--if this hook being edited?
			if (scriptObject.LastHookEdited == hookName) then
				self:SetBackdropColor (1, .6, 0, 0.5)
				self.IsEditing = true
			else
				self:SetBackdropColor (unpack (scrollbox_line_backdrop_color))
			end
		else
			self.CanAddHook = true
			self.AddButton.Hook = hookName
			self.AddButton:Show()
			self:SetBackdropColor (unpack (scrollbox_line_backdrop_not_inuse))
			self:SetAlpha (.75)
		end
		
		--self.Icon:SetTexture ("")
	end
	
	local selectHookToEdit = function (self)
		if (not self.CanAddHook) then
			local scriptObject = hookFrame.GetCurrentScriptObject()
			if (scriptObject) then
				--save the current code
				local lastEditedHook = scriptObject.LastHookEdited
				if (lastEditedHook ~= "") then
					scriptObject.HooksTemp [lastEditedHook] = hookFrame.CodeEditorLuaEntry:GetText()
				end
				
				scriptObject.LastHookEdited = self.Hook
				
				--load the code
				hookFrame.CodeEditorLuaEntry:SetText (scriptObject.HooksTemp [self.Hook])
				
				--refresh the hook selection scroll
				hookFrame.HookScrollBox:Refresh()
				
				--refresh the hook selection dropdown
				hookFrame.HookTypeDropdown:Select (self.Hook)
			end
			return
		end
	end
	
	local addHookToScriptObject = function (self)
		if (hookFrame.LastAddedHookTime+0.5 >= GetTime()) then
			return
		end
		
		local hookName = self.Hook
		hookFrame.AddHookToScript (hookName)
		
		hookFrame.LastAddedHookTime = GetTime()
	end
	
	local removeHookFromScriptObject = function (self)
		self = self:GetParent()
		if (not self.CanRemoveHook) then
			return
		end
		
		local hookName = self.Hook
		hookFrame.RemoveHookFromScript (hookName)
	end
	
	local refreshHookScrollBox = function (self, data, offset, totalLines)
		local hookList = {}
		local scriptObject = hookFrame.GetCurrentScriptObject()
		if (scriptObject) then
			for index, hookName in ipairs (Plater.HookScripts) do
				if (scriptObject.Hooks [hookName]) then
					tinsert (hookList, hookName)
				end
			end
			for index, hookName in ipairs (Plater.HookScripts) do
				if (not scriptObject.Hooks [hookName]) then
					tinsert (hookList, hookName)
				end
			end
		else
			hookList = Plater.HookScripts
		end

		for i = 1, totalLines do
			local index = i + offset

			local hook = hookList [i]
			if (hook) then
				local line = self:GetLine (i)
				line:UpdateLine (index, hook)
			end
		end
	end
	
	local hookListCreateLine = function (self, index)
		--create a new line
		local line = CreateFrame ("button", "$parentLine" .. index, self)
		
		--set its parameters
		line:SetPoint ("topleft", self, "topleft", 0, -((index-1) * (triggerbox_line_height+1)))
		line:SetSize (triggerbox_size[1], triggerbox_line_height)
		line:SetScript ("OnEnter", onEnterHookButton)
		line:SetScript ("OnLeave", onLeaveHookButton)
		line:SetScript ("OnMouseUp", selectHookToEdit)
		line:SetBackdrop ({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true, edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1})
		line:SetBackdropColor (unpack (scrollbox_line_backdrop_color))
		line:SetBackdropBorderColor (0, 0, 0, 0)
		
		local icon = line:CreateTexture ("$parentIcon", "overlay")
		icon:SetSize (triggerbox_line_height - 2, triggerbox_line_height - 2)
		icon:SetTexture ([[Interface\ICONS\INV_Hand_1H_PirateHook_B_01]])
		icon:SetTexCoord (.1, .9, .1, .9)
		
		local hookNameLabel = DF:CreateLabel (line, "", DF:GetTemplate ("font", "PLATER_SCRIPTS_NAME"))
		local addedLabel = DF:CreateLabel (line, "", DF:GetTemplate ("font", "PLATER_SCRIPTS_TRIGGER_SPELLID"))
		
		local removeButton = CreateFrame ("button", "$parentRemoveButton", line, "UIPanelCloseButton")
		removeButton:SetSize (16, 16)
		removeButton:SetScript ("OnClick", removeHookFromScriptObject)
		removeButton:SetPoint ("topright", line, "topright")
		removeButton:GetNormalTexture():SetDesaturated (true)
		
		local addButton = CreateFrame ("button", "$parentRemoveButton", line)
		addButton:SetSize (16, 16)
		addButton:SetScript ("OnClick", addHookToScriptObject)
		addButton:SetPoint ("right", line, "right")
		addButton:SetNormalTexture ([[Interface\BUTTONS\UI-PlusButton-Up]])
		addButton:SetPushedTexture ([[Interface\BUTTONS\UI-PlusButton-Down]])
		addButton:SetDisabledTexture ([[Interface\BUTTONS\UI-PlusButton-Disabled]])
		addButton:SetHighlightTexture ([[Interface\BUTTONS\UI-PlusButton-Hilight]])

		icon:SetPoint ("left", line, "left", 2, 0)
		hookNameLabel:SetPoint ("topleft", icon, "topright", 4, -2)
		addedLabel:SetPoint ("topleft", hookNameLabel, "bottomleft", 0, 0)
		
		line.Icon = icon
		line.HookName = hookNameLabel
		line.AddedLabel = addedLabel
		line.RemoveButton = removeButton
		line.AddButton = addButton
	
		line.UpdateLine = updateHookLine
		line:Hide()
		
		return line
	end
	
	--scroll showing all triggers of the script
	local hookLabel = DF:CreateLabel (edit_script_frame, "Add Hooks:", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
	local hookScrollbox = DF:CreateScrollBox (edit_script_frame, "$parentHookScrollBox", refreshHookScrollBox, {}, triggerbox_size[1], triggerbox_size[2]+75, scrollbox_lines, triggerbox_line_height)
	hookScrollbox:SetPoint ("topleft", hookLabel.widget, "bottomleft", 0, -4)
	hookScrollbox:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
	hookScrollbox:SetBackdropColor (0, 0, 0, 0.2)
	hookScrollbox:SetBackdropBorderColor (0, 0, 0, 1)
	hookFrame.HookScrollBox = hookScrollbox
	DF:ReskinSlider (hookScrollbox)
	
	--create the scrollbox lines
	for i = 1, scrollbox_lines do 
		hookScrollbox:CreateLine (hookListCreateLine)
	end
	
	local onLoadConditionsChange = function()
		--reload all hook scripts
		Plater.WipeAndRecompileAllScripts ("hook")
		
		--local scriptObject = hookFrame.GetCurrentScriptObject()
		--print ("condition changed")
		--Details:Dump (scriptObject.LoadConditions)
	end
	
	--create load conditions button
	local openConditionsPanel = function()
		local scriptObject = hookFrame.GetCurrentScriptObject()
		if (scriptObject) then
			DF:OpenLoadConditionsPanel (scriptObject.LoadConditions, onLoadConditionsChange, {title = "Hook Load Conditions", name = scriptObject.Name})
		end
	end
	local loadConditionsButton = DF:CreateButton (edit_script_frame, openConditionsPanel, triggerbox_size[1], 20, "Load Conditions", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
	--add_trigger_button:SetIcon ([[Interface\BUTTONS\UI-PlusButton-Up]], 20, 20, "overlay", {0, 1, 0, 1})
	loadConditionsButton:SetPoint ("top", hookScrollbox, "bottom", 0, -4)
	hookFrame.LoadConditionsButton = loadConditionsButton
	
	--create the code editor
	create_import_box (edit_script_frame, hookFrame)
	create_code_editor (edit_script_frame, hookFrame)
	
	--create the components button and cooltip
		--api help small frame
		local componentsButton = DF:CreateButton (hookFrame.CodeEditorLuaEntry, function() end, 100, 20, "Components", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
		componentsButton:SetIcon ([[Interface\FriendsFrame\UI-FriendsList-Large-Up]], 16, 16, "overlay", {.2, .74, .27, .75}, nil, 4)
		hookFrame.ComponentsButton = componentsButton
		
		local onSelectComponentMember = function (a, d, member)
			hookFrame.CodeEditorLuaEntry.editbox:Insert (member)
			GameCooltip:Hide()
		end
		
		local buildComponentTableMenu = function()
			GameCooltip:Preset (2)
			GameCooltip:SetOption ("TextSize", 11)
			GameCooltip:SetOption ("FixedWidth", 300)
			
			GameCooltip:AddLine ("Nameplate Components", "", 1, "yellow", "yellow", 12, nil, "OUTLINE")
			
			local backgroundAlpha = 0.2
			
			for bracketName, listTable in pairs (Plater.NameplateComponents) do
				GameCooltip:AddLine (bracketName)
				GameCooltip:AddStatusBar (100, 1, 0, 0, 0, backgroundAlpha)
				GameCooltip:AddIcon ("", 2, 1, 16, 16)
				--GameCooltip:AddMenu (1, onSelectComponentMember, Plater.UnitFrameMembers [i])
				
				for i, commandName in ipairs (listTable) do
					GameCooltip:AddLine (commandName, "", 2)
					GameCooltip:AddStatusBar (100, 2, 0, 0, 0, backgroundAlpha)
					GameCooltip:AddIcon ("", 2, 1, 18, 18)
					GameCooltip:AddMenu (2, onSelectComponentMember, commandName)
				end
			end
			
			GameCooltip:AddLine ("$div")
			GameCooltip:AddLine ("Help")
			GameCooltip:AddLine ("|cFFFFFF22unitFrame|r is where things are connected.\n\n|cFFFFFF22Members|r just store information, they are read-only.\n|cFFFFFF22Frames|r are widgets that can be textures, fontstrings, etc.\n\nTo access a widget from the unitFrame:\n|cFFFFFF22castBar|r: unitFrame.castBar\n|cFFFFFF22healthBar|r: unitFrame.healthBar\n\nExamples:\n|cFFFFFF22- |rTo know if a cast can be interrupted use 'unitFrame.castBar.CanInterrupt'\n|cFFFFFF22- |rTo get the fontString for the health amount use 'unitFrame.healthBar.lifePercent'.", "", 2)			
		end

		componentsButton.CoolTip = {
			Type = "menu",
			BuildFunc = buildComponentTableMenu,
			ShowSpeed = 0.05,
		}
		
		GameCooltip2:CoolTipInject (componentsButton)	

	--create the hook selector dropdown
	local onSelectHook =  function (self, fixedParameter, valueSelected)
		--get the current editing script
		local scriptObject = hookFrame.GetCurrentScriptObject()
		
		--save the current code
		local lastEditedHook = scriptObject.LastHookEdited
		if (lastEditedHook ~= "") then
			scriptObject.HooksTemp [lastEditedHook] = hookFrame.CodeEditorLuaEntry:GetText()
		end
		
		scriptObject.LastHookEdited = valueSelected
		
		--load the code
		hookFrame.CodeEditorLuaEntry:SetText (scriptObject.HooksTemp [valueSelected])
	end
	
	local buildHookDropdownList = function()
		local t = {}
		local scriptObject = hookFrame.GetCurrentScriptObject()
		if (scriptObject) then
			for hookName, _ in pairs (scriptObject.Hooks) do
				tinsert (t, {label = hookName, value = hookName, desc = hookName, onclick = onSelectHook})
			end
		end
		return t
	end
	
	local hookTypeLabel = DF:CreateLabel (hookFrame.CodeEditorLuaEntry, "Edit Hook:", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
	local hookTypeDropdown = DF:CreateDropDown (hookFrame.CodeEditorLuaEntry, buildHookDropdownList, 1, 160, 20, "HookTypeDropdown", _, DF:GetTemplate ("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
	hookTypeDropdown:SetPoint ("left", hookTypeLabel, "right", 2, 0)
	hookTypeDropdown.CodeType = 1
	hookFrame.HookTypeDropdown = hookTypeDropdown
	
	--when the profile has changed
	function hookFrame:RefreshOptions()
		--update the script data for the scroll and refresh
		hookFrame.ScriptSelectionScrollBox:SetData (Plater.db.profile.hook_data)
		hookFrame.ScriptSelectionScrollBox:Refresh()
	end

	hookFrame.ScriptSelectionScrollBox:SetPoint ("topleft", hookFrame.ScriptSearchTextEntry.widget, "bottomleft", 0, -20)
	hookFrame.ScriptScrollLabel:SetPoint ("bottomleft", hookFrame.ScriptSelectionScrollBox, "topleft", 0, 2)
	hookFrame.ScriptEnabledLabel:SetPoint ("bottomright", hookFrame.ScriptSelectionScrollBox, "topright", 0, 2)

	--create frame holding the script options
	edit_script_frame:SetPoint ("topleft", hookFrame, "topleft", scrollbox_size[1] + 30, start_y)
	
	--script options
	edit_script_frame.ScriptNameLabel:SetPoint ("topleft", edit_script_frame, "topleft", 10, 2)
	edit_script_frame.ScriptIconLabel:SetPoint ("topleft", edit_script_frame, "topleft", 170, 0)
	edit_script_frame.ScriptDescLabel:SetPoint ("topleft", edit_script_frame, "topleft", 10, -40)
	
	hookLabel:SetPoint ("topleft", edit_script_frame, "topleft", 10, -80)

	--lua code editor
	hookFrame.CodeEditorLuaEntry:SetPoint ("topleft", edit_script_frame, "topleft", 230, -20)
	--import editor
	hookFrame.ImportTextEditor:SetPoint ("topleft", edit_script_frame, "topleft", 230, -20)
	
	hookFrame.SaveScriptButton:SetPoint ("topright", hookFrame.CodeEditorLuaEntry, "bottomright", 0, -10)
	hookFrame.CancelScriptButton:SetPoint ("right", hookFrame.SaveScriptButton, "left", -20, 0)
	
	hookTypeLabel:SetPoint ("topleft", hookFrame.CodeEditorLuaEntry, "bottomleft", 0, -15)
	
	--import control buttons
	hookFrame.ImportTextEditor.OkayButton:SetPoint ("topright", hookFrame.CodeEditorLuaEntry, "bottomright", 0, -10)
	hookFrame.ImportTextEditor.CancelButton:SetPoint ("right", hookFrame.ImportTextEditor.OkayButton, "left", -20, 0)

	componentsButton:SetPoint ("bottomleft", hookFrame.CodeEditorLuaEntry, "topleft", 0, 2)
	
	hookFrame.EditScriptFrame:LockFrame()
	hookFrame.EditScriptFrame:Show()
	
end

function Plater.CreateScriptingPanel()

	--controi o menu principal
	local f = PlaterOptionsPanelFrame
	local mainFrame = PlaterOptionsPanelContainer
	
	local profile = Plater.db.profile
	
	local scriptingFrame = mainFrame.AllFrames [13]
	scriptingFrame.ScriptType = "script"
	
	local currentEditingScript = nil
	
	--localized names of the different trigger types and description
	scriptingFrame.TriggerTypes = {
		"Buffs & Debuffs",
		"Spell Casting",
		"Unit Name",
	}
	scriptingFrame.TriggerTypesDesc = {
		"When an unit receives an aura (buff or debuff), the aura name is checked against all the spell names added in the trigger box below.",
		"When an unit starts to cast a spell, the name of the spell is checked against all the spell names added in the trigger box below.",
		"When a nameplate is shown, the name of the unit is checked against all the spell names added in the trigger box below.",
	}
	
	scriptingFrame.CodeTypes = {
		{Name = "Constructor", Desc = "Is executed only once, create your custom stuff here like frames, textures, animations and store them inside |cFFFFFF00envTable|r.\n\nAlso check if the frame already exists before creating it!", Value = 2},
		{Name = "On Show", Desc = "Executed when the trigger match!\n\nUse to show your custom frames, textures, play animations, etc.", Value = 4},
		{Name = "On Update", Desc = "Executed after Plater updates the nameplate (does not run every frame).\n\nUse this to update your custom stuff or override values that Plater might have set during the nameplate update, e.g. the nameplate color due to aggro checks.", Value = 1},
		{Name = "On Hide", Desc = "Executed when the widget is Hide() or trigger doesn't match anymore.\n\nUse to hide your custom frames, textures, stop animations, etc.", Value = 3},
	}
	
	--store all spells from the game in a hash table and also on the index table
	--these are loaded on demand and cleared when the scripting frame is hided
	scriptingFrame.SpellHashTable = {}
	scriptingFrame.SpellIndexTable = {}
	scriptingFrame.SearchString = ""
	
	scriptingFrame:SetScript ("OnShow", function()
		--update the created scripts scrollbox
		scriptingFrame.ScriptSelectionScrollBox:Refresh()
		
		--check trash can timeout
		local timeout = 60 * 60 * 24 * 30
		--local timeout = 60 * 60 * 24 * 1 --for testing, setting this to 1 day
		
		for i = #Plater.db.profile.script_data_trash, 1, -1 do
			local scriptObject = Plater.db.profile.script_data_trash [i]
			if (not scriptObject.__TrashAt or scriptObject.__TrashAt + timeout < time()) then
				tremove (Plater.db.profile.script_data_trash, i)
			end
		end
	end)
	
	scriptingFrame:SetScript ("OnHide", function()
		--save
		local scriptObject = scriptingFrame.GetCurrentScriptObject()
		if (scriptObject) then
			scriptingFrame.SaveScript()
		end
		
		--clean the spell hash table
		wipe (scriptingFrame.SpellHashTable)
		wipe (scriptingFrame.SpellIndexTable)
		collectgarbage()
	end)
	
	-- scriptingFrame.ScriptNameTextEntry --name of the script (text entry)
	-- scriptingFrame.ScriptIconButton -- icon pick button
	-- scriptingFrame.ScriptTypeDropdown --type of the script (dropdown)
	-- scriptingFrame.TriggerTextEntry --text entry for the trigger add (text entry)
	-- scriptingFrame.TriggerScrollBox --scrollbox for the triggers (scrollbox)
	-- scriptingFrame.CodeEditorLuaEntry --text entry for the lua editor
	-- scriptingFrame.ScriptSelectionScrollBox --scrollbox with all script created to select
	-- scriptingFrame.CodeTypeDropdown --dropdown for the type of code being edited (runtime or constructor)
	
	scriptingFrame.DefaultScript = [=[
		function (self, unitId, unitFrame, envTable)
			
		end
	]=]
	
	--a new script has been created
	function scriptingFrame.CreateNewScript()

		--build the table of the new script
		local newScriptObject = {
			Enabled = true,
			ScriptType = 0x1,
			Name = "New Script",
			SpellIds = {},
			NpcNames = {},
			Icon = "",
			Desc = "",
			Author = "",
			Time = time(), --is set when the save button is pressed
			Revision = 1, --increase everytime the save button is pressed
			PlaterCore = Plater.CoreVersion, --store the version of plater required to run this script
		}
		
		--scripts
		for i = 1, #Plater.CodeTypeNames do
			local memberName = Plater.CodeTypeNames [i]
			newScriptObject [memberName] = scriptingFrame.DefaultScript
			newScriptObject ["Temp_" .. memberName] = scriptingFrame.DefaultScript
		end

		local playerName = UnitName ("player")
		local realm = GetRealmName()
		
		newScriptObject.Author = playerName .. "-" .. realm
		
		--add it to the database
		tinsert (Plater.db.profile.script_data, newScriptObject)
		
		--start editing the new script
		scriptingFrame.EditScript (#Plater.db.profile.script_data)
		
		--refresh the scrollbox showing all scripts created
		scriptingFrame.ScriptSelectionScrollBox:Refresh()
	end
	
	function scriptingFrame.GetScriptObject (script_id)
		local script = Plater.db.profile.script_data [script_id]
		if (script) then
			return script
		else
			Plater:Msg ("GetScriptObject could find the script id")
			return
		end
	end
	
	function scriptingFrame.GetCurrentScriptObject()
		return currentEditingScript
	end
	
	function scriptingFrame.LoadGameSpells()
		if (not next (scriptingFrame.SpellHashTable)) then
			--load all spells in the game
			DF:LoadAllSpells (scriptingFrame.SpellHashTable, scriptingFrame.SpellIndexTable)
			return true
		end
	end
	
	--restore the values on the text fields and scroll boxes to the values on the object
	function scriptingFrame.CancelEditing (is_deleting)
		if (not is_deleting) then
			--re fill all the text entried and dropdowns to the default from the script
			--doing this to restore the script so it can do a hot reload
			scriptingFrame.UpdateEditingPanel()
			
			--hot reload restored scripts
			scriptingFrame.ApplyScript()
		end
		
		--clear current editing script
		currentEditingScript = nil
		
		--lock the editing panel
		scriptingFrame.EditScriptFrame:LockFrame()
		
		--hide the editing frame
		--scriptingFrame.HideEditPanel()
		
		--reload the script selection scrollbox in case the script got renamed
		scriptingFrame.ScriptSelectionScrollBox:Refresh()
	end
	
	--save all values
	function scriptingFrame.SaveScript()
		--get the current editing object
		local scriptObject = scriptingFrame.GetCurrentScriptObject()
		
		--script name
		scriptObject.Name = scriptingFrame.ScriptNameTextEntry.text
		--script icon
		scriptObject.Icon = scriptingFrame.ScriptIconButton:GetIconTexture()
		--script description
		scriptObject.Desc = scriptingFrame.ScriptDescTextEntry.text
		--script type
		scriptObject.ScriptType = scriptingFrame.ScriptTypeDropdown.value
		
		--triggers are auto save
		
		--transfer the temporarily code saved to the scrip object
		for i = 1, #Plater.CodeTypeNames do
			local memberName = Plater.CodeTypeNames [i]
			scriptObject [memberName] = scriptObject ["Temp_" .. memberName]
		end

		--save the current code
		scriptObject [Plater.CodeTypeNames [scriptingFrame.CodeTypeDropdown.CodeType]] = scriptingFrame.CodeEditorLuaEntry:GetText()

		scriptObject.Time = time()
		scriptObject.Revision = scriptObject.Revision + 1
		
		--do a hot reload on the script
		scriptingFrame.ApplyScript (true)
		
		--reload the script selection scrollbox in case the script got renamed
		scriptingFrame.ScriptSelectionScrollBox:Refresh()
		
		--remove the focus from the editing code textentry
		scriptingFrame.CodeEditorLuaEntry:ClearFocus()
		
		--update the overlapp button
		scriptingFrame.UpdateOverlapButton()
		
		--remove focus of everything
		scriptingFrame.ScriptNameTextEntry:ClearFocus()
		scriptingFrame.ScriptDescTextEntry:ClearFocus()
		scriptingFrame.TriggerTextEntry:ClearFocus()
	end
	
	--hot reload the script by compiling it and applying it to the nameplates without saving
	function scriptingFrame.ApplyScript (on_save)
		--get the text from the text fields, compile and apply the changes to the nameplate without saving the script

		--doing this since the framework send 'self' in the first parameter of the button click
		on_save = type (on_save) == "boolean" and on_save
		
		local code = {}
		--prebuild the code table with the code types (constructor/onupdate etc)
		for i = 1, #Plater.CodeTypeNames do
			local memberName = Plater.CodeTypeNames [i]
			code [memberName] = ""
		end		

		local scriptObject = scriptingFrame.GetCurrentScriptObject()

		if (not on_save) then
			--is hot reload, get the code from the code editor
			for i = 1, #Plater.CodeTypeNames do
				local memberName = Plater.CodeTypeNames [i]
				code [memberName] = scriptObject ["Temp_" .. memberName]
			end
			
			code [Plater.CodeTypeNames [scriptingFrame.CodeTypeDropdown.CodeType]] = scriptingFrame.CodeEditorLuaEntry:GetText()
		else
			--is a save, get the code from the object
			for i = 1, #Plater.CodeTypeNames do
				local memberName = Plater.CodeTypeNames [i]
				code [memberName] = scriptObject [memberName]
			end
		end

		do
			local t = {}
			--build a script table for the comppiler
			for i = 1, #Plater.CodeTypeNames do
				local memberName = Plater.CodeTypeNames [i]
				tinsert (t, code [memberName])
			end
			Plater.CompileScript (scriptObject, unpack (t))
		end
		
		--remove the focus so the user can cast spells etc
		scriptingFrame.CodeEditorLuaEntry:ClearFocus()
	end
	
	--when deleting or disabling a script object, it needs to stop any running script
	function scriptingFrame.KillRunningScriptsForObject (scriptObject)
		--kill scripts running for this script object
		for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
			local unitFrame = plateFrame.UnitFrame

			if (scriptObject.ScriptType == 1) then
				--buff and debuffs
				--iterate among all icons shown in the nameplate and attempt to kill the script by its trigger
				for _, iconAuraFrame in ipairs (unitFrame.BuffFrame.PlaterBuffList) do
					for _, spellID in ipairs (scriptObject.SpellIds) do
						iconAuraFrame:KillScript (spellID)
					end
				end
				for _, iconAuraFrame in ipairs (unitFrame.BuffFrame2.PlaterBuffList) do
					for _, spellID in ipairs (scriptObject.SpellIds) do
						iconAuraFrame:KillScript (spellID)
					end
				end
				
			elseif (scriptObject.ScriptType == 2) then
				--cast bar
				for _, spellID in ipairs (scriptObject.SpellIds) do
					unitFrame.castBar:KillScript (spellID)
				end

			elseif (scriptObject.ScriptType == 3) then
				--nameplate
				for _, triggerID in ipairs (scriptObject.NpcNames) do
					unitFrame:KillScript (triggerID)
				end

			end
			
		end
	end
	
	function scriptingFrame.RemoveScript (scriptId)
		local scriptObjectToBeRemoved = scriptingFrame.GetScriptObject (scriptId)
		local currentScript = scriptingFrame.GetCurrentScriptObject()
		
		--check if the script to be removed is valid
		if (not scriptObjectToBeRemoved) then
			return
		end
		
		scriptingFrame.KillRunningScriptsForObject (scriptObjectToBeRemoved)
		
		--if is the current script being edited, cancel the edit
		if (currentScript == scriptObjectToBeRemoved) then
			--cancel the editing process
			scriptingFrame.CancelEditing (true)
		end
		
		--set the time when the script has been moved to trash
		scriptObjectToBeRemoved.__TrashAt = time()
		
		tinsert (Plater.db.profile.script_data_trash, scriptObjectToBeRemoved)
		tremove (Plater.db.profile.script_data, scriptId)
		
		--refresh the script selection scrollbox
		scriptingFrame.ScriptSelectionScrollBox:Refresh()
		
		GameCooltip:Hide()
		Plater:Msg ("Script moved to trash.")
		
		--reload all scripts
		Plater.WipeAndRecompileAllScripts (scriptingFrame.ScriptType)
		
		--update overlap button
		scriptingFrame.UpdateOverlapButton()
	end
	
	function scriptingFrame.DuplicateScript (scriptId)
		local scriptToBeCopied = scriptingFrame.GetScriptObject (scriptId)
		local newScript = DF.table.copy ({}, scriptToBeCopied)
		
		tinsert (Plater.db.profile.script_data, newScript)
		scriptingFrame.ScriptSelectionScrollBox:Refresh()
		
		Plater:Msg ("Script duplicated. Make sure to use different triggers.")
		
		--update overlap button
		scriptingFrame.UpdateOverlapButton()
	end
	
	--called from the context menu when right click an option in the script menu
	function scriptingFrame.ExportScript (scriptId)
		local scriptToBeExported = scriptingFrame.GetScriptObject (scriptId)
		
		--convert the script table into an index table for smaller size
		local tableToExport = Plater.PrepareTableToExport (scriptToBeExported)
		--compress the index table
		local encodedString = Plater.CompressData (tableToExport, "print")
	
		scriptingFrame.ImportTextEditor.IsImporting = false
		scriptingFrame.ImportTextEditor.IsExporting = true

		scriptingFrame.ImportTextEditor:Show()
		scriptingFrame.ImportTextEditor:SetText (encodedString)
		scriptingFrame.ImportTextEditor.TextInfo.text = "Exporting '" .. scriptToBeExported.Name .. "'"
		
		--if there's anything being edited, start editing the script which is being exported
		if (not scriptingFrame.GetCurrentScriptObject()) then
			scriptingFrame.EditScript (scriptId)
		end
		
		scriptingFrame.EditScriptFrame:Show()
		
		C_Timer.After (0.3, function()
			scriptingFrame.ImportTextEditor.editbox:SetFocus (true)
			scriptingFrame.ImportTextEditor.editbox:HighlightText()
		end)
	end
	
	function scriptingFrame.ShowImportTextField()
		--if editing a script, save it and close it
		local scriptObject = scriptingFrame.GetCurrentScriptObject()
		if (scriptObject) then
			scriptingFrame.SaveScript()
			scriptingFrame.CancelEditing()
			--refresh the script selection scrollbox
			scriptingFrame.ScriptSelectionScrollBox:Refresh()
		end
		
		--lock the editing panel
		scriptingFrame.EditScriptFrame:LockFrame()
		
		scriptingFrame.EditScriptFrame:Show()
		scriptingFrame.ImportTextEditor:Show()
		scriptingFrame.ImportTextEditor:SetText ("")
		scriptingFrame.ImportTextEditor.IsImporting = true
		scriptingFrame.ImportTextEditor.IsExporting = false
		scriptingFrame.ImportTextEditor:SetFocus (true)
		scriptingFrame.ImportTextEditor.TextInfo.text = "Paste the string:"
	end
	
	--this is only called from the 'okay' button in the import text editor
	function scriptingFrame.ImportScript()
	
		--if clicked in the 'okay' button when the import text editor is showing a string to export, just hide the import editor
		if (scriptingFrame.ImportTextEditor.IsExporting) then
			scriptingFrame.ImportTextEditor.IsImporting = nil
			scriptingFrame.ImportTextEditor.IsExporting = nil
			scriptingFrame.ImportTextEditor:Hide()
			return
		end
	
		local text = scriptingFrame.ImportTextEditor:GetText()

		--cleanup the text removing extra spaces and break lines
		text = DF:Trim (text)
		
		if (string.len (text) > 0) then
		
			local indexScriptTable = Plater.DecompressData (text, "print")
			
			if (indexScriptTable and type (indexScriptTable) == "table") then
			
				local scriptType = Plater.GetDecodedScriptType (indexScriptTable)
				if (scriptType ~= "script") then
					--the user inserted a string for a hook into the script import
					--call the external function to import this script with ignoreRevision, overrideExisting and showDebug
					local importSuccess, newObject = Plater.ImportScriptString (text, true, true, true)
					if (importSuccess) then
						PlaterOptionsPanelContainer:SelectIndex (Plater, PLATER_OPTIONS_HOOKING_TAB)
						local mainFrame = PlaterOptionsPanelContainer
						local hookFrame = mainFrame.AllFrames [PLATER_OPTIONS_HOOKING_TAB]
						hookFrame.EditScript (newObject)
						hookFrame.ScriptSelectionScrollBox:Refresh()
					end
					
					scriptingFrame.ImportTextEditor.IsImporting = nil
					scriptingFrame.ImportTextEditor:Hide()
					
					return
				end
			
				local newScript = Plater.BuildScriptObjectFromIndexTable (indexScriptTable, "script")
				if (newScript) then
					tinsert (Plater.db.profile.script_data, newScript)
					scriptingFrame.ScriptSelectionScrollBox:Refresh()
					scriptingFrame.EditScript (#Plater.db.profile.script_data)
					--refresh the script selection scrollbox
					scriptingFrame.ScriptSelectionScrollBox:Refresh()
				else
					Plater:Msg ("Cannot import: data imported is invalid")
				end
			else
				Plater:Msg ("Cannot import: data imported is invalid")
			end
		end
		
		scriptingFrame.ImportTextEditor.IsImporting = nil
		scriptingFrame.ImportTextEditor:Hide()
	end
	
	--set all values from the current editing script object to all text entried and scroll fields
	function scriptingFrame.UpdateEditingPanel()
		--get the current editing object
			local scriptObject = scriptingFrame.GetCurrentScriptObject()
		
		--set the data from the object in the widgets
			scriptingFrame.ScriptNameTextEntry.text =  scriptObject.Name
			scriptingFrame.ScriptNameTextEntry:ClearFocus()
			scriptingFrame.ScriptIconButton:SetIcon (scriptObject.Icon)
			scriptingFrame.ScriptDescTextEntry.text = scriptObject.Desc or ""
			scriptingFrame.ScriptDescTextEntry:ClearFocus()
			scriptingFrame.ScriptTypeDropdown:Select (scriptObject.ScriptType, true)
			scriptingFrame.TriggerTextEntry.text = ""
			scriptingFrame.TriggerTextEntry:ClearFocus()
			
			--trigger box data
			if (scriptObject.ScriptType == 1 or scriptObject.ScriptType == 2) then
				scriptingFrame.TriggerScrollBox:SetData (scriptObject.SpellIds)
			elseif (scriptObject.ScriptType == 3) then
				scriptingFrame.TriggerScrollBox:SetData (scriptObject.NpcNames)
			end
			scriptingFrame.TriggerScrollBox:Refresh()
			
			--refresh the code editing
			for i = 1, #Plater.CodeTypeNames do
				local memberName = Plater.CodeTypeNames [i]
				scriptObject ["Temp_" .. memberName] = scriptObject [memberName]
			end
			
			--use the runtime code as the default editing script
			scriptingFrame.CodeEditorLuaEntry:SetText (scriptObject [Plater.CodeTypeNames [2]]) 
			scriptingFrame.CodeEditorLuaEntry:ClearFocus()
			
			--update the code type dropdown
			scriptingFrame.CodeTypeDropdown:Select (2)
			scriptingFrame.CodeTypeDropdown.CodeType = 2
	end
	
	--start editing a script
	function scriptingFrame.EditScript (script_id)
	
		local scriptObject
	
		--> check if passed a script object
		if (type (script_id) == "table") then
			scriptObject = script_id
		else
			scriptObject = scriptingFrame.GetScriptObject (script_id)
		end
		
		if (not scriptObject) then
			return
		end
		
		scriptingFrame.EditScriptFrame:UnlockFrame()
		
		scriptingFrame.EditScriptFrame:Show()
		
		--set the new editing script
		currentEditingScript = scriptObject
		
		--load the values in the frame
		scriptingFrame.UpdateEditingPanel()
	end
	
	--add a trigger to the current editing script
	function scriptingFrame.AddTrigger()
		--get the text on the addon trigger text entry
		local text = scriptingFrame.TriggerTextEntry.text
		scriptingFrame.TriggerTextEntry:ClearFocus()
		
		--check the text if is valid
		text = DF:trim (text)
		if (text == "" or string.len (text) < 2) then
			Plater:Msg ("Invalid trigger")
			return
		end

		local scriptObject = scriptingFrame.GetCurrentScriptObject()
		
		if (scriptObject.ScriptType == 1 or scriptObject.ScriptType == 2) then --require a spellId
			--cast the string to number
			local spellId = tonumber (text)
			if (not spellId or not GetSpellInfo (spellId)) then
				--load spell hash table
				scriptingFrame.LoadGameSpells()
				
				--attempt to get the spellId from the hash table
				spellId = scriptingFrame.SpellHashTable [string.lower (text)]
				--if still fail, stop here
				if (not spellId) then
					Plater:Msg ("Trigger requires a valid spell name or an ID of a spell")
					return
				end
			end
			
			--add the spell id
			tinsert (scriptObject.SpellIds, spellId)
			
			--refresh the trigger box
			scriptingFrame.TriggerScrollBox:Refresh()
			
			--check if the script has an icon, if not set the icon
			if (not scriptObject.Icon or scriptObject.Icon == "") then
				local _, _, spellIcon = GetSpellInfo (spellId)
				scriptingFrame.ScriptIconButton:SetIcon (spellIcon)
			end
			
		elseif (scriptObject.ScriptType == 3) then
			--add the npc name
			tinsert (scriptObject.NpcNames, text)
			
			--refresh the trigger box
			scriptingFrame.TriggerScrollBox:Refresh()
		end
		
		--update overlap button
		scriptingFrame.UpdateOverlapButton()
		
		--recompile all
		Plater.WipeAndRecompileAllScripts (scriptingFrame.ScriptType)
		
		--clear the trigger box
		scriptingFrame.TriggerTextEntry:SetText ("")
		scriptingFrame.TriggerTextEntry:ClearFocus()
		
		Plater:Msg ("Trigger added!")
	end
	
	--store the script object which is currently being edited
	
	function scriptingFrame.GetScriptTriggerTypeName (script_type)
		return scriptingFrame.TriggerTypes [script_type] or "none", scriptingFrame.TriggerTypesDesc [script_type] or ""
	end

	do
		local help_popup = DF:CreateSimplePanel (UIParent, 1000, 480, "Plater Scripting Help", "PlaterScriptingHelp")
		help_popup:SetFrameStrata ("DIALOG")
		help_popup:SetPoint ("center")
		DF:ApplyStandardBackdrop (help_popup, false, 1.2)
		help_popup:Hide()
		
		scriptingFrame.HelpFrame = help_popup
	
		local scripting_help_label = DF:CreateLabel (help_popup, "Script Name:", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
		
		local frontpageText_Welcome = "Scripting allows you to apply a more depth customization into the nameplate.\n"
		local frontpageText_Lua = "A basic knowledge of Lua programming may be required.\n\n"
		local frontpageText_Triggers = "|cFFFFFF00How a Script Works:|r\n\nThere's three types of triggers: |cFFFF5500Auras|r, |cFFFF5500Spell Cast|r and |cFFFF5500Unit Name|r, when a condition for the trigger matches, it begins to run its code.\n\n"
		local frontpageText_Scripts = "There's four types of code:\n|cFFFF5500Constructor|r: runs only once, use to create your custom frames, texture and animations.\n|cFFFF5500On Show|r: is executed each time the script triggers. Use this to show or play frames and animations created inside the constructor.\n|cFFFF5500On Update|r runs every time Plater updates the nameplate. Use this to override something that Plater have set, the nameplate color for example, or, update some information from your custom stuff.\n|cFFFF5500On Hide|r: executed when the trigger doesn't match the condition any more. Use this to hide and stop all your frames and animations.\n"
		local frontpageText_Function = "\n|cFFFFFF00Function Parameters:|r\n\n|cFFC0C0C0function (self, unit, unitFrame, envTable)\n    --code\nend|r\n\n|cFFFF5500self|r: is different for each trigger, for buffs is the frame of the icon, spell casting passes the frame of the cast bar and the unit frame is passed for unit names.\n|cFFFF5500unit|r: unitId of the unit shown in the nameplate, use to query data, for example: UnitName (unitId).\n|cFFFF5500unitFrame|r: is the nameplate unit frame (parent of all widgets), the tooltip of the ? button has all the members to access all components of the nameplate from the unit frame.\n|cFFFF5500envTable|r: a table where you can store data, it also store information about the aura, cast and the unit shown depending on the type of the trigger.\n"
		local frontpageText_ReturnValues = "\nWhat is a |cFFFF5500ReturnValue|r?\nIs what a function returns after a calling it, example:\nenvTable.MyFlash = Plater.CreateFlash (unitFrame.healthBar, 0.05, 2, 'white')\nPlater.CreateFlash() returned an object with information about the flash created, then this information is stored inside '|cFFFF5500envTable.MyFlash|r'\nYou can use it later to play the flash with '|cFFFF5500envTable.MyFlash:Play()|r' or stop it with '|cFFFF5500envTable.MyFlash:Stop()|r'."
		local frontpageText_Parent = "\n\nWhat is a |cFFFF5500Parent|r?\nThe parent field required for create some widgets is the frame which will hold it, in other words: where it will be attach to."
		
		scripting_help_label.text = frontpageText_Welcome .. frontpageText_Lua .. frontpageText_Triggers .. frontpageText_Scripts .. frontpageText_Function .. frontpageText_ReturnValues .. frontpageText_Parent
		scripting_help_label.fontsize = 14
		scripting_help_label:SetPoint ("topleft", help_popup, "topleft", 5, -25)
	end
	
	--create the frame which will hold the create panel
	local edit_script_frame = CreateFrame ("frame", "$parentCreateScript", scriptingFrame)
	edit_script_frame:SetSize (unpack (main_frames_size))
	edit_script_frame:SetScript ("OnShow", function()

	end)
	edit_script_frame:SetScript ("OnHide", function()

	end)
	edit_script_frame:Hide()
	scriptingFrame.EditScriptFrame = edit_script_frame

	
	
	function edit_script_frame.UnlockFrame()
		scriptingFrame.ScriptNameTextEntry:Enable()
		scriptingFrame.ScriptIconButton:Enable()
		scriptingFrame.ScriptDescTextEntry:Enable()
		scriptingFrame.ScriptTypeDropdown:Enable()
		scriptingFrame.TriggerTextEntry:Enable()
		scriptingFrame.AddTriggerButton:Enable()
		
		scriptingFrame.AddAPIDropdown:Enable()
		scriptingFrame.AddFWDropdown:Enable()
		
		scriptingFrame.CodeEditorLuaEntry:Enable()
		scriptingFrame.CodeTypeDropdown:Enable()
		scriptingFrame.ApplyScriptButton:Enable()
		scriptingFrame.SaveScriptButton:Enable()
		scriptingFrame.CancelScriptButton:Enable()
	end
	
	function edit_script_frame.LockFrame()
		scriptingFrame.ScriptNameTextEntry:SetText ("")
		scriptingFrame.ScriptNameTextEntry:Disable()
		scriptingFrame.ScriptIconButton:SetIcon ("")
		scriptingFrame.ScriptIconButton:Disable()
		scriptingFrame.ScriptDescTextEntry:SetText ("")
		scriptingFrame.ScriptDescTextEntry:Disable()
		scriptingFrame.ScriptTypeDropdown:Disable()
		scriptingFrame.TriggerTextEntry:SetText ("")
		scriptingFrame.TriggerTextEntry:Disable()
		scriptingFrame.AddTriggerButton:Disable()
		scriptingFrame.TriggerScrollBox:SetData ({})
		scriptingFrame.TriggerScrollBox:Refresh()
		
		scriptingFrame.AddAPIDropdown:Disable()
		scriptingFrame.AddFWDropdown:Disable()
		
		scriptingFrame.CodeEditorLuaEntry:SetText ("")
		scriptingFrame.CodeEditorLuaEntry:Disable()
		scriptingFrame.CodeTypeDropdown:Disable()
		scriptingFrame.ApplyScriptButton:Disable()
		scriptingFrame.SaveScriptButton:Disable()
		scriptingFrame.CancelScriptButton:Disable()
	end
	
	function scriptingFrame.HideEditPanel()
		edit_script_frame:Hide()
	end
	
	--create new script frame widgets
	create_script_namedesc (scriptingFrame, edit_script_frame)
	
	--triggers, this part is unique to scripts
		--dropdown to select which type of trigger / frame it'll use
			local on_select_tracking_option = function (self, fixed_parameter, value_selected)
				local scriptObject = scriptingFrame.GetCurrentScriptObject()
				
				scriptObject.ScriptType = value_selected
				
				--change the trigger type
					--auras or spellcast
					if (value_selected == 1 or value_selected == 2) then
						scriptingFrame.TriggerScrollBox:SetData (scriptObject.SpellIds)
						scriptingFrame.TriggerLabel.text = "Add Trigger (Spell Id or Spell Name)"
						
					--npc name
					elseif (value_selected == 3) then
						scriptingFrame.TriggerScrollBox:SetData (scriptObject.NpcNames)
						scriptingFrame.TriggerLabel.text = "Add Trigger (Unit Name)"
						
					end
					
					scriptingFrame.TriggerScrollBox:Refresh()
				
				--recompile all
				Plater.WipeAndRecompileAllScripts ("script")
			end
			
			local build_script_type_dropdown_options = function()
				local t = {
					{label = scriptingFrame.GetScriptTriggerTypeName (1), value = 1, onclick = on_select_tracking_option, desc = select (2, scriptingFrame.GetScriptTriggerTypeName (1))},
					{label = scriptingFrame.GetScriptTriggerTypeName (2), value = 2, onclick = on_select_tracking_option, desc = select (2, scriptingFrame.GetScriptTriggerTypeName (2))},
					{label = scriptingFrame.GetScriptTriggerTypeName (3), value = 3, onclick = on_select_tracking_option, desc = select (2, scriptingFrame.GetScriptTriggerTypeName (3))},
				}
				return t
			end
			
			local script_type_label = DF:CreateLabel (edit_script_frame, "Trigger Type:", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
			local script_type_dropdown = DF:CreateDropDown (edit_script_frame, build_script_type_dropdown_options, 1, 160, 20, "ScriptTypeDropdown", _, DF:GetTemplate ("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
			script_type_dropdown:SetPoint ("topleft", script_type_label, "bottomleft", 0, -2)
			script_type_dropdown.tooltip = "The type of event when the script check for trigger matches, only the selected option is used.\n\n|cFFFFFF00Buffs & Debuffs|r: an aura shown in the nameplate.\n\n|cFFFFFF00Spell Casting|r: the spell the unit is casting.\n\n|cFFFFFF00Unit Name|r: the unit name shown in the nameplate."
			scriptingFrame.ScriptTypeDropdown = script_type_dropdown
		
		--button to add a spellId or npc name trigger
			local add_trigger_label = DF:CreateLabel (edit_script_frame, "Add Trigger (Spell Id or Spell Name)", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
			local add_trigger_textentry = DF:CreateTextEntry (edit_script_frame, function()end, 140, 20, "ScriptTriggerTextEntry", _, _, options_dropdown_template)
			add_trigger_textentry:SetPoint ("topleft", add_trigger_label, "bottomleft", 0, -2)
			add_trigger_textentry.tooltip = "Enter data based on the trigger selected:\n\n|cFFFFFF00Buff and Spell Cast|r: Enter the spell name using lower case letters.\n\n|cFFFFFF00Unit Name|r: Enter the unit name or the npcID."
			scriptingFrame.TriggerTextEntry = add_trigger_textentry
			scriptingFrame.TriggerLabel = add_trigger_label
			
			add_trigger_textentry:SetHook ("OnEditFocusGained", function (self, capsule)
				--if ithe script is for aura or castbar and if the textentry box doesnt have an auto complete table yet
				local scriptObject = scriptingFrame.GetCurrentScriptObject()
				if ((scriptObject.ScriptType == 1 or scriptObject.ScriptType == 2) and (not add_trigger_textentry.SpellAutoCompleteList or not scriptingFrame.SpellIndexTable[1])) then
					--load spell hash table
					scriptingFrame.LoadGameSpells()
					add_trigger_textentry.SpellAutoCompleteList = scriptingFrame.SpellIndexTable
					add_trigger_textentry:SetAsAutoComplete ("SpellAutoCompleteList", nil, true)
				end
			end)

			local add_trigger_button = DF:CreateButton (edit_script_frame, scriptingFrame.AddTrigger, 50, 20, "Add", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
			add_trigger_button:SetIcon ([[Interface\BUTTONS\UI-PlusButton-Up]], 20, 20, "overlay", {0, 1, 0, 1})
			add_trigger_button:SetPoint ("left", add_trigger_textentry, "right", 2, 0)
			--add_trigger_button.tooltip = 
			
			add_trigger_button:SetHook ("OnEnter", function()
				GameCooltip:Preset (2)
				--GameCooltip:SetOption ("TextSize", 11)
				GameCooltip:SetOption ("FixedWidth", 300)
				
				local scriptObject = scriptingFrame.GetCurrentScriptObject()
				
				if ((scriptObject.ScriptType == 1 or scriptObject.ScriptType == 2)) then
					GameCooltip:AddLine ("|cFFFFFF00Important|r: it's normal for the Icon and Description of the spell you added to be different, The name of the spell is used to active the script.\n\nYou can enter the SpellID as well.")
				else
					GameCooltip:AddLine ("|cFFFFFF00Important|r: npc name isn't case-sensitive.\n\n|cFFFFFF00Important|r: you can use the npcId as well for the multi-language support of your script.")
				end
				
				GameCooltip:SetOwner (add_trigger_button.widget)
				GameCooltip:Show()
			end)
			
			add_trigger_button:SetHook ("OnLeave", function()
				GameCooltip:Hide()
			end)
			
			scriptingFrame.AddTriggerButton = add_trigger_button
		
		--list of spells or npc names for this script
			--refresh the list of scripts already created
				local refresh_trigger_scrollbox = function (self, data, offset, total_lines)
					local data
					local scriptObject = scriptingFrame.GetCurrentScriptObject()
					if (scriptObject) then
						if (scriptObject.ScriptType == 1 or scriptObject.ScriptType == 2) then
							data = scriptObject.SpellIds
						elseif (scriptObject.ScriptType == 3) then
							data = scriptObject.NpcNames
						end
					
						--update the scroll
						for i = 1, total_lines do
							local index = i + offset
							local trigger = data [index]
							if (trigger) then
								--update the line
								local line = self:GetLine (i)
								line:UpdateLine (index, trigger)
							end
						end
					end
					
					--update overlap button
					scriptingFrame.UpdateOverlapButton()
				end
			
			--when the user hover over a scrollbox line
				local onenter_trigger_line = function (self)
					if (self.SpellID) then
						GameTooltip:SetOwner (self, "ANCHOR_RIGHT")
						GameTooltip:SetSpellByID (self.SpellID)
						GameTooltip:AddLine (" ")
						GameTooltip:Show()
					end
					self:SetBackdropColor (.3, .3, .3, 0.7)
				end
			
			--when the user leaves a scrollbox line from a hover over
				local onleave_trigger_line = function (self)
					GameTooltip:Hide()
					self:SetBackdropColor (unpack (scrollbox_line_backdrop_color))
				end
			
			--update the trigger line
			local update_trigger_line = function (self, trigger_id, trigger)
				local scriptObject = scriptingFrame.GetCurrentScriptObject()
				
				if (scriptObject.ScriptType == 1 or scriptObject.ScriptType == 2) then
					--spellname
					local spellName, _, spellIcon = GetSpellInfo (trigger)
					self.Icon:SetTexture (spellIcon)
					self.Icon:SetTexCoord (.1, .9, .1, .9)
					self.Icon:SetDesaturated (false)
					self.Icon:SetAlpha (1)
					self.SpellID = trigger
					self.TriggerName:SetText (spellName)
					self.TriggerID:SetText (trigger)
					
				elseif (scriptObject.ScriptType == 3) then
					--npc name
					self.Icon:SetTexture ([[Interface\ICONS\INV_Misc_SeagullPet_01]])
					self.Icon:SetTexCoord (.9, .1, .1, .9)
					self.Icon:SetDesaturated (true)
					self.Icon:SetAlpha (0.5)
					self.SpellID = nil
					self.TriggerName:SetText (trigger)
					self.TriggerID:SetText ("")
				end
				
				self.TriggerId = trigger_id
			end
			
			local onclick_remove_trigger_line = function (self)
				local scriptObject = scriptingFrame.GetCurrentScriptObject()
				local parent = self:GetParent()
				
				local triggerId = parent.TriggerId
				
				--remove the trigger
				if (scriptObject.ScriptType == 1 or scriptObject.ScriptType == 2) then
					--spellname
					tremove (scriptObject.SpellIds, triggerId)
					
				elseif (scriptObject.ScriptType == 3) then
					--npc name
					tremove (scriptObject.NpcNames, triggerId)
				
				end
				
				--refresh the trigger box
				scriptingFrame.TriggerScrollBox:Refresh()
				
				--update overlap button
				scriptingFrame.UpdateOverlapButton()
				
				--recompile all
				Plater.WipeAndRecompileAllScripts ("script")
			end
			
			--create a line in the scroll box
				local create_line_triggerbox = function (self, index)
					--create a new line
					local line = CreateFrame ("button", "$parentLine" .. index, self)
					--set its parameters
					line:SetPoint ("topleft", self, "topleft", 0, -((index-1) * (triggerbox_line_height+1)))
					line:SetSize (triggerbox_size[1], triggerbox_line_height)
					line:SetScript ("OnEnter", onenter_trigger_line)
					line:SetScript ("OnLeave", onleave_trigger_line)
					line:SetBackdrop ({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
					line:SetBackdropColor (unpack (scrollbox_line_backdrop_color))
					
					local icon = line:CreateTexture ("$parentIcon", "overlay")
					icon:SetSize (triggerbox_line_height - 2, triggerbox_line_height - 2)
					
					local trigger_name = DF:CreateLabel (line, "", DF:GetTemplate ("font", "PLATER_SCRIPTS_NAME"))
					local trigger_id = DF:CreateLabel (line, "", DF:GetTemplate ("font", "PLATER_SCRIPTS_TRIGGER_SPELLID"))
					
					local remove_button = CreateFrame ("button", "$parentRemoveButton", line, "UIPanelCloseButton")
					remove_button:SetSize (16, 16)
					remove_button:SetScript ("OnClick", onclick_remove_trigger_line)
					remove_button:SetPoint ("topright", line, "topright")
					remove_button:GetNormalTexture():SetDesaturated (true)

					icon:SetPoint ("left", line, "left", 2, 0)
					trigger_name:SetPoint ("topleft", icon, "topright", 4, -2)
					trigger_id:SetPoint ("topleft", trigger_name, "bottomleft", 0, 0)
					
					line.Icon = icon
					line.TriggerName = trigger_name
					line.TriggerID = trigger_id
					line.RemoveButton = remove_button

					line.UpdateLine = update_trigger_line
					line:Hide()
					
					return line
				end
			
			--scroll showing all triggers of the script
				local trigger_scrollbox_label = DF:CreateLabel (edit_script_frame, "Triggers:", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
				local trigger_scrollbox = DF:CreateScrollBox (edit_script_frame, "$parentTriggerScrollBox", refresh_trigger_scrollbox, {}, triggerbox_size[1], triggerbox_size[2], triggerbox_lines, triggerbox_line_height)
				trigger_scrollbox:SetPoint ("topleft", trigger_scrollbox_label.widget, "bottomleft", 0, -4)
				trigger_scrollbox:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
				trigger_scrollbox:SetBackdropColor (0, 0, 0, 0.2)
				trigger_scrollbox:SetBackdropBorderColor (0, 0, 0, 1)
				scriptingFrame.TriggerScrollBox = trigger_scrollbox
				DF:ReskinSlider (trigger_scrollbox)
				
				local overlapFrame = DF:CreateSimplePanel (UIParent, 600, 400, "Trigger Overlap", "PlaterScriptTriggerOverlap")
				overlapFrame:SetFrameStrata ("DIALOG")
				overlapFrame:SetPoint ("center")
				DF:ApplyStandardBackdrop (overlapFrame, false, 1.2)
				overlapFrame.OverlappedScriptFrames = {}
				overlapFrame:Hide()
				
				local enableScriptFromOverlapPanel = function (self, fixedParameter, scriptObject, value2)
					scriptObject.Enabled = true
					
					scriptingFrame.UpdateOverlapButton()
					scriptingFrame.ScriptSelectionScrollBox:Refresh()
					overlapFrame.RefreshPanel()
				end
				
				local disableScriptFromOverlapPanel = function (self, fixedParameter, scriptObject, value2)
					scriptObject.Enabled = false
					
					scriptingFrame.UpdateOverlapButton()
					scriptingFrame.ScriptSelectionScrollBox:Refresh()
					overlapFrame.RefreshPanel()
				end
				
				local removeTriggerFromOverlapPanel = function (self, fixedParameter, scriptObject, triggerId)
					if (scriptObject.ScriptType == 0x1 or scriptObject.ScriptType == 0x2) then
						for index, trigger in ipairs (scriptObject.SpellIds) do
							if (trigger == triggerId) then
								tremove (scriptObject.SpellIds, index)
								break
							end
						end
					else
						for index, trigger in ipairs (scriptObject.NpcNames) do
							if (trigger == triggerId) then
								tremove (scriptObject.NpcNames, index)
								break
							end
						end
					end
					
					scriptingFrame.UpdateOverlapButton()
					overlapFrame.RefreshPanel()
					
					--reload all scripts
					Plater.WipeAndRecompileAllScripts ("script")
				end
				
				local onEnterOverlapPanelLine = function (self)
					self:SetBackdropColor (0.5, 0.5, 0.5, 1)
				end
				
				local onLeaveOverlapPanelLine = function (self)
					self:SetBackdropColor (unpack (self.OriginalBackdropColor))
				end
				
				local onClickOverlapPanelLine = function (self)
					if (self.ScriptObject) then
						local currentScriptObject = scriptingFrame.GetCurrentScriptObject()
						--check if isn't the same script
						local scriptToBeEdited = self.ScriptObject
						if (scriptToBeEdited == currentScriptObject) then
							--no need to load the new script if is the same
							return
						end
						
						--save the current script if any
						if (currentScriptObject) then
							scriptingFrame.SaveScript()
						end
						
						--select the script to start edit
						scriptingFrame.EditScript (self.ScriptObject)
						--refresh the script list to update the backdrop color of the selected script
						scriptingFrame.ScriptSelectionScrollBox:Refresh()
						
						--check if the import/export text field is shown and hide it
						if (scriptingFrame.ImportTextEditor:IsShown()) then
							scriptingFrame.ImportTextEditor:Hide()
						end
					end
				end

				overlapFrame.RefreshPanel = function()
				
					if (not overlapFrame:IsShown()) then
						return
					end
				
					if (not overlapFrame.CreateNewFrameTable) then
					
						local reset = function (f)
							f.TriggerName.text = ""
							f.TriggerId.text = ""
							
							for i = 1, #f.Scripts do
								f.Scripts [i].Parent:Hide()
							end
						end
					
						function overlapFrame:CreateNewFrameTable()
							local i = #overlapFrame.OverlappedScriptFrames + 1
							local f = CreateFrame ("frame", "$parentTriggerCluster" .. i, overlapFrame)
							f:SetSize (590, 20)
							f.Reset = reset
							DF:ApplyStandardBackdrop (f, true, 0.1)
							
							if (i == 1) then
								f:SetPoint ("topleft", overlapFrame, "topleft", 5, -26)
							else
								f:SetPoint ("topleft", overlapFrame.OverlappedScriptFrames [i - 1], "bottomleft", 0, -2)
							end
							
							f.TriggerName = DF:CreateLabel (f)
							f.TriggerIcon = DF:CreateImage (f, "", 18, 18)
							f.TriggerIcon:SetPoint (5, -5)
							f.TriggerName:SetPoint ("left", f.TriggerIcon, "right", 2, 0)
							
							f.TriggerId = DF:CreateLabel (f)
							f.TriggerId:SetPoint (250, -5)
							
							f.Scripts = {}
							
							for o = 1, 2 do
								overlapFrame:CreateFrameForScript (f, o)
							end
							
							tinsert (overlapFrame.OverlappedScriptFrames, f)
							
							return f
						end
						
						function overlapFrame:CreateFrameForScript (f, i)
							local ff = CreateFrame ("frame", "$parentLine" .. i, f)
							ff:SetSize (580, 22)
							ff:SetPoint ("topleft", f, "topleft", 0, -24 - ((i - 1) * 23))
							DF:ApplyStandardBackdrop (ff, true, 0.8)
							ff:SetBackdropBorderColor (0, 0, 0, 0)
							ff:SetFrameLevel (f:GetFrameLevel() + 5)
							
							ff.OriginalBackdropColor = {ff:GetBackdropColor()}
							
							local scriptName = DF:CreateLabel (ff)
							local enableScript = DF:CreateButton (ff, enableScriptFromOverlapPanel, 120, 20, "Enable Script", nil, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
							local disableScript = DF:CreateButton (ff, disableScriptFromOverlapPanel, 120, 20, "Disable Script", nil, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
							local removeTrigger = DF:CreateButton (ff, removeTriggerFromOverlapPanel, 120, 20, "Remove Trigger", nil, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
							
							--> create a background below the script name to make an impression it's a button
							local nameBackdrop = CreateFrame ("frame", nil, ff)
							nameBackdrop:SetSize (140, 20)
							DF:ApplyStandardBackdrop (nameBackdrop)
							nameBackdrop:SetPoint ("topleft", ff, "topleft", 3, 0)
							nameBackdrop:EnableMouse (false)
							nameBackdrop:SetBackdropColor (0, 0, 0, 0)
							nameBackdrop.__background:Hide()
							
							scriptName:SetPoint (5, -4)
							enableScript:SetPoint (160, 0)
							disableScript:SetPoint ("left", enableScript, "right", 2, 0)
							removeTrigger:SetPoint ("left", disableScript, "right", 2, 0)
							
							ff:SetScript ("OnEnter", onEnterOverlapPanelLine)
							ff:SetScript ("OnLeave", onLeaveOverlapPanelLine)
							ff:SetScript ("OnMouseDown", onClickOverlapPanelLine)
							
							tinsert (f.Scripts, {ScriptName = scriptName, EnableButton = enableScript, DisableButton = disableScript, RemoveButton = removeTrigger, Parent = ff})
							
							return f.Scripts [#f.Scripts]
						end
					end
				
					local overlaps = scriptingFrame.OverlapButton.OverlapTable
					if (overlaps) then
					
						--reset frames
						for i, frame in ipairs (overlapFrame.OverlappedScriptFrames) do
							frame:Reset()
							frame:Hide()
						end
						
						local i = 1
						
						for triggerTypeName, overlapTable in pairs (scriptingFrame.OverlapButton.OverlapTable) do
							for triggerId, scriptsTable in pairs (overlapTable) do
							
								local frameTable = overlapFrame.OverlappedScriptFrames [i]
								if (not frameTable) then
									frameTable = overlapFrame:CreateNewFrameTable()
								end
								
								frameTable:Reset()
								frameTable:Show()
								
								local triggerName = triggerId
								local triggerIcon = ""
								if (scriptsTable[1].ScriptType == 0x1 or scriptsTable[1].ScriptType == 0x2) then
									triggerName, _, triggerIcon = GetSpellInfo (triggerId)
									frameTable.TriggerIcon.texture = triggerIcon
									frameTable.TriggerIcon:SetTexCoord (.1, .9, .1, .9)
								else
									frameTable.TriggerIcon.texture = ""
								end
								
								frameTable.TriggerName.text = triggerName
								frameTable.TriggerId.text = triggerId .. " [" .. ((scriptingFrame.TriggerTypes [triggerTypeName == "Auras" and 1 or triggerTypeName == "Casts" and 2 or triggerTypeName == "Npcs" and 3]) or "") .. "]"

								for o = 1, #scriptsTable do
									local scriptF = frameTable.Scripts [o]
									if (not scriptF) then
										scriptF = overlapFrame:CreateFrameForScript (frameTable, o)
									end
									
									local scriptObject = scriptsTable [o]
									
									scriptF.ScriptName.text = scriptObject.Name
									scriptF.Parent.ScriptObject = scriptObject
									
									if (not scriptObject.Enabled) then
										scriptF.EnableButton:SetClickFunction (enableScriptFromOverlapPanel, scriptObject)
										scriptF.EnableButton:Enable()
									else
										scriptF.EnableButton:Disable()
									end
									
									if (scriptObject.Enabled) then
										scriptF.DisableButton:SetClickFunction (disableScriptFromOverlapPanel, scriptObject)
										scriptF.DisableButton:Enable()
									else
										scriptF.DisableButton:Disable()
									end
									
									scriptF.RemoveButton:SetClickFunction (removeTriggerFromOverlapPanel, scriptObject, triggerId)
									scriptF.Parent:Show()
								end
								
								frameTable:SetHeight (22 + (#scriptsTable * 26))
								
								i = i + 1
							end
						end
						
					else
						overlapFrame:Hide()
					end
				end
				
				overlapFrame:SetScript ("OnShow", function()
					overlapFrame.RefreshPanel()
				end)
				
				--add script overlap button / frame
				local overlapButton = Plater:CreateButton (scriptingFrame, function() overlapFrame:Show() end, 160, 20, "Trigger Overlaps: 0", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
				overlapButton:SetPoint ("topleft", trigger_scrollbox, "bottomleft", 0, -2)
				overlapButton:SetPoint ("topright", trigger_scrollbox, "bottomright", 0, -2)
				scriptingFrame.OverlapButton = overlapButton
				
				overlapButton:SetHook ("OnEnter", function (self)
					GameCooltip:Preset (2)
					GameCooltip:SetOption ("TextSize", 11)
					GameCooltip:SetOption ("FixedWidth", 300)
					
					GameCooltip:AddLine ("Trigger Overlaps", "", 1, "yellow", "yellow", 12, nil, "OUTLINE")
					GameCooltip:AddLine ("A SpellID, NpcName or NpcID cannot be used in more than 1 script with the same Trigger Type.")
					
					GameCooltip:AddLine (" ")
					GameCooltip:AddLine ("Trigger Name", "Trigger ID", 1, "yellow", "yellow", 12)
					
					if (overlapButton.OverlapAmount and overlapButton.OverlapAmount > 0) then
						for triggerId, scriptsTable in pairs (overlapButton.OverlapTable.Auras) do
							local triggerName = GetSpellInfo (triggerId)
							GameCooltip:AddLine (triggerName, triggerId .. " [" .. scriptingFrame.TriggerTypes [1] .. "]")
						end
						for triggerId, scriptsTable in pairs (overlapButton.OverlapTable.Casts) do
							local triggerName = GetSpellInfo (triggerId)
							GameCooltip:AddLine (triggerName, triggerId .. " [" .. scriptingFrame.TriggerTypes [1] .. "]")
						end
						for triggerId, scriptsTable in pairs (overlapButton.OverlapTable.Npcs) do
							local triggerName = triggerId
							GameCooltip:AddLine (triggerName, triggerId .. " [" .. scriptingFrame.TriggerTypes [1] .. "]")
						end
						
						GameCooltip:AddLine (" ")
						GameCooltip:AddLine ("click for more information", "", 1, "green")
					end

					GameCooltip:SetOwner (self)
					GameCooltip:Show()
				end)
				overlapButton:SetHook ("OnLeave", function()
					GameCooltip:Hide()
				end)
				
				function scriptingFrame.UpdateOverlapButton()
					local overlappedTriggers, amoutOfOverlaps = Plater.CheckScriptTriggerOverlap()
					overlapButton:SetText ("Trigger Overlaps: " .. amoutOfOverlaps)
					
					if (amoutOfOverlaps > 0) then
						overlapButton:SetTemplate (DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"))
						overlapButton:SetTextColor (DF:GetTemplate ("font", "PLATER_BUTTON").color)
					else
						overlapButton:SetTemplate (DF:GetTemplate ("button", "PLATER_BUTTON_DISABLED"))
						local r, g, b = unpack (DF:GetTemplate ("font", "PLATER_BUTTON").color)
						overlapButton:SetTextColor (r/2, g/2, b/2)
					end
					
					overlapButton.OverlapAmount = amoutOfOverlaps
					overlapButton.OverlapTable = overlappedTriggers
					
					PlaterScriptTriggerOverlap.RefreshPanel()
				end
				
			--create the scrollbox lines
				for i = 1, scrollbox_lines do 
					trigger_scrollbox:CreateLine (create_line_triggerbox)
				end
		
		create_import_box (edit_script_frame, scriptingFrame)
		create_code_editor (edit_script_frame, scriptingFrame)

				--api help small frame
				local unit_frame_components_menu = DF:CreateButton (scriptingFrame.CodeEditorLuaEntry, function() end, 100, 20, "Components", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
				unit_frame_components_menu:SetIcon ([[Interface\FriendsFrame\UI-FriendsList-Large-Up]], 16, 16, "overlay", {.2, .74, .27, .75}, nil, 4)
				
				local onSelectComponentMember = function (a, d, member)
					scriptingFrame.CodeEditorLuaEntry.editbox:Insert (member)
					GameCooltip:Hide()
				end
				
				local buildComponentTableMenu = function()
					GameCooltip:Preset (2)
					GameCooltip:SetOption ("TextSize", 11)
					GameCooltip:SetOption ("FixedWidth", 300)
					
					GameCooltip:AddLine ("Nameplate Components", "", 1, "yellow", "yellow", 12, nil, "OUTLINE")
					
					local backgroundAlpha = 0.2
					
					for i = 1, #Plater.UnitFrameMembers do 
						GameCooltip:AddLine (Plater.UnitFrameMembers [i])
						GameCooltip:AddMenu (1, onSelectComponentMember, Plater.UnitFrameMembers [i])
						GameCooltip:AddStatusBar (100, 1, 0, 0, 0, backgroundAlpha)
					end
				end

				unit_frame_components_menu.CoolTip = {
					Type = "menu",
					BuildFunc = buildComponentTableMenu,
					ShowSpeed = 0.05,
				}
				
				GameCooltip2:CoolTipInject (unit_frame_components_menu)
				
				--script env helper
				local script_env_helper = DF:CreateButton (scriptingFrame.CodeEditorLuaEntry, function() end, 100, 20, "envTable", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
				script_env_helper:SetIcon ([[Interface\FriendsFrame\UI-FriendsList-Small-Up]], 16, 16, "overlay", {.2, .74, .27, .75}, nil, 4)
				
				local onSelectEnvTableMember = function (a, d, member)
					scriptingFrame.CodeEditorLuaEntry.editbox:Insert (member)
					GameCooltip:Hide()
				end
				
				local buildEnvTableMenu = function()
				
					local scriptObject = scriptingFrame.GetCurrentScriptObject()
				
					if (not scriptObject) then
						GameCooltip:Preset (2)
						GameCooltip:SetOption ("TextSize", 11)
						GameCooltip:SetOption ("FixedWidth", 400)
						GameCooltip:AddLine ("*No script loaded", "", 1, "red")
						GameCooltip:AddLine ("Use this menu to quick add to your code a member from envTable")
						return
					end
				
					GameCooltip:Preset (2)
					GameCooltip:SetOption ("TextSize", 11)
					GameCooltip:SetOption ("FixedWidth", 400)

					local backgroundAlpha = 0.2
					--if (scriptObject.ScriptType == 0x1) then
					if (not scriptObject or scriptObject.ScriptType == 0x1) then
						GameCooltip:AddLine ("envTable Members for Trigger Buffs and Debuffs", "", 1, "yellow", "yellow", 12, nil, "OUTLINE")
						
						for index, member in ipairs (Plater.TriggerDefaultMembers [1]) do
							GameCooltip:AddLine (member, "", 1, "orange", "white"); GameCooltip:AddStatusBar (100, 1, 0, 0, 0, backgroundAlpha)
							GameCooltip:AddMenu (1, onSelectEnvTableMember, member)
						end
						
						--adds a space to separate from the infor of the next trigger
						if (not scriptObject) then
							GameCooltip:AddLine (" ")
						end
					end
					
					if (not scriptObject or scriptObject.ScriptType == 0x2) then
						GameCooltip:AddLine ("envTable Members for Trigger Spell Casting", "", 1, "yellow", "yellow", 12, nil, "OUTLINE")
						
						for index, member in ipairs (Plater.TriggerDefaultMembers [2]) do
							GameCooltip:AddLine (member, "", 1, "orange", "white"); GameCooltip:AddStatusBar (100, 1, 0, 0, 0, backgroundAlpha)
							GameCooltip:AddMenu (1, onSelectEnvTableMember, member)
						end
						
						--adds a space to separate from the infor of the next trigger
						if (not scriptObject) then
							GameCooltip:AddLine (" ")
						end
					end
					
					if (not scriptObject or scriptObject.ScriptType == 0x3) then
						GameCooltip:AddLine ("envTable Members for Trigger Unit Name", "", 1, "yellow", "yellow", 12, nil, "OUTLINE")
					
						for index, member in ipairs (Plater.TriggerDefaultMembers [3]) do
							GameCooltip:AddLine (member, "", 1, "orange", "white"); GameCooltip:AddStatusBar (100, 1, 0, 0, 0, backgroundAlpha)
							GameCooltip:AddMenu (1, onSelectEnvTableMember, member)
						end
					end
					
					GameCooltip:AddLine (" ")
					GameCooltip:AddLine ("envTable Members From Constructor Code:", "", 1, "yellow", "yellow", 12, nil, "OUTLINE")
					
					--> get the constructor code from the editor if the current editing is the constructor or get the temporarily saved script from the script object
					local code = scriptingFrame.CodeTypeDropdown.CodeType == 2 and scriptingFrame.CodeEditorLuaEntry:GetText() or scriptObject ["Temp_" .. Plater.CodeTypeNames [2]]
					if (code) then
						--> find all member names added to the envTable
						--> add all members in the comments too
						local alreadyAdded = {}
						for _, memberName in code:gmatch ("(envTable%.)(.-)(%s)") do
							memberName = DF:Trim (memberName)
							if (not memberName:find ("%s") and not alreadyAdded [memberName]) then
								alreadyAdded [memberName] = memberName
								GameCooltip:AddLine ("envTable." .. memberName, "", 1, "orange", "white"); GameCooltip:AddStatusBar (100, 1, 0, 0, 0, backgroundAlpha)
								GameCooltip:AddMenu (1, onSelectEnvTableMember, "envTable." .. memberName)
							end
						end
					end
						
				end
				
				script_env_helper.CoolTip = {
					Type = "menu",
					BuildFunc = buildEnvTableMenu,
					ShowSpeed = 0.05,
				}
				
				GameCooltip2:CoolTipInject (script_env_helper)

		--top left of the code editor
		script_env_helper:SetPoint ("bottomleft", scriptingFrame.CodeEditorLuaEntry, "topleft", 0, 2)
		unit_frame_components_menu:SetPoint ("left", script_env_helper, "right", 2, 0)

		--change the script code type (when the user select from normal runtime code or constructor code)
			local on_select_code_type =  function (self, fixed_parameter, value_selected)
				--get the current editing script
				local scriptObject = scriptingFrame.GetCurrentScriptObject()
				
				--save the current code
				scriptObject ["Temp_" .. Plater.CodeTypeNames [scriptingFrame.CodeTypeDropdown.CodeType]] = scriptingFrame.CodeEditorLuaEntry:GetText()
				
				--load the code
				scriptingFrame.CodeEditorLuaEntry:SetText (scriptObject ["Temp_" .. Plater.CodeTypeNames [value_selected]])
				
				--update the code type
				scriptingFrame.CodeTypeDropdown.CodeType = value_selected
			end
			
			local build_script_code_dropdown_options = function()
				local t = {}
				for i = 1, #scriptingFrame.CodeTypes do
					local thisType = scriptingFrame.CodeTypes [i]
					tinsert (t, {label = thisType.Name, value = thisType.Value, desc = thisType.Desc, onclick = on_select_code_type})
				end
				return t
			end
			
			local code_type_label = DF:CreateLabel (scriptingFrame.CodeEditorLuaEntry, "Code Type:", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
			local code_type_dropdown = DF:CreateDropDown (scriptingFrame.CodeEditorLuaEntry, build_script_code_dropdown_options, 1, 160, 20, "CodeTypeDropdown", _, DF:GetTemplate ("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
			code_type_dropdown:SetPoint ("left", code_type_label, "right", 2, 0)
			code_type_dropdown.CodeType = 1
			scriptingFrame.CodeTypeDropdown = code_type_dropdown
	
	--create the header
	create_script_control_header (scriptingFrame, "script")

	--when the profile has changed
	function scriptingFrame:RefreshOptions()
		--update the script data for the scroll and refresh
		scriptingFrame.ScriptSelectionScrollBox:SetData (Plater.db.profile.script_data)
		scriptingFrame.ScriptSelectionScrollBox:Refresh()
	end
	
	--anchors
		--scroll to select which script to edit
		--script_scrollbox_label:SetPoint ("topleft", create_new_script_button.widget, "bottomleft", 0, -12)
		
		scriptingFrame.ScriptSelectionScrollBox:SetPoint ("topleft", scriptingFrame.ScriptSearchTextEntry.widget, "bottomleft", 0, -20)
		scriptingFrame.ScriptScrollLabel:SetPoint ("bottomleft", scriptingFrame.ScriptSelectionScrollBox, "topleft", 0, 2)
		scriptingFrame.ScriptEnabledLabel:SetPoint ("bottomright", scriptingFrame.ScriptSelectionScrollBox, "topright", 0, 2)
	
		--create frame holding the script options
		edit_script_frame:SetPoint ("topleft", scriptingFrame, "topleft", scrollbox_size[1] + 30, start_y)
		
		--script options
		edit_script_frame.ScriptNameLabel:SetPoint ("topleft", edit_script_frame, "topleft", 10, 2)
		edit_script_frame.ScriptIconLabel:SetPoint ("topleft", edit_script_frame, "topleft", 170, 0)
		edit_script_frame.ScriptDescLabel:SetPoint ("topleft", edit_script_frame, "topleft", 10, -40)
		
		script_type_label:SetPoint ("topleft", edit_script_frame, "topleft", 10, -80)
		
		add_trigger_label:SetPoint ("topleft", edit_script_frame, "topleft", 10, -120)
		trigger_scrollbox_label:SetPoint ("topleft", edit_script_frame, "topleft", 10, -160)
		
		--lua code editor
		scriptingFrame.CodeEditorLuaEntry:SetPoint ("topleft", edit_script_frame, "topleft", 230, -20)
		--import editor
		scriptingFrame.ImportTextEditor:SetPoint ("topleft", edit_script_frame, "topleft", 230, -20)
		
		--scriptingFrame.ApplyScriptButton:SetPoint ("topright", scriptingFrame.CodeEditorLuaEntry, "bottomright", 0, -10)
		scriptingFrame.SaveScriptButton:SetPoint ("topright", scriptingFrame.CodeEditorLuaEntry, "bottomright", 0, -10)
		scriptingFrame.CancelScriptButton:SetPoint ("right", scriptingFrame.SaveScriptButton, "left", -20, 0)
		
		--import control buttons
		scriptingFrame.ImportTextEditor.OkayButton:SetPoint ("topright", scriptingFrame.CodeEditorLuaEntry, "bottomright", 0, -10)
		scriptingFrame.ImportTextEditor.CancelButton:SetPoint ("right", scriptingFrame.ImportTextEditor.OkayButton, "left", -20, 0)

		--code type
		code_type_label:SetPoint ("topleft", scriptingFrame.CodeEditorLuaEntry, "bottomleft", 0, -15)
	
	
	scriptingFrame.EditScriptFrame:LockFrame()
	scriptingFrame.EditScriptFrame:Show()
end

--endd ends