--[[
╔═════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
║   ██████████      ███████       ██████   █████    ███████    ███████████    ██████████ ██████████   █████ ███████████ ███ ███   ║
║  ▒▒███▒▒▒▒███   ███▒▒▒▒▒███    ▒▒██████ ▒▒███   ███▒▒▒▒▒███ ▒█▒▒▒███▒▒▒█   ▒▒███▒▒▒▒▒█▒▒███▒▒▒▒███ ▒▒███ ▒█▒▒▒███▒▒▒█▒███▒███   ║
║   ▒███   ▒▒███ ███     ▒▒███    ▒███▒███ ▒███  ███     ▒▒███▒   ▒███  ▒     ▒███  █ ▒  ▒███   ▒▒███ ▒███ ▒   ▒███  ▒ ▒███▒███   ║
║   ▒███    ▒███▒███      ▒███    ▒███▒▒███▒███ ▒███      ▒███    ▒███        ▒██████    ▒███    ▒███ ▒███     ▒███    ▒███▒███   ║
║   ▒███    ▒███▒███      ▒███    ▒███ ▒▒██████ ▒███      ▒███    ▒███        ▒███▒▒█    ▒███    ▒███ ▒███     ▒███    ▒███▒███   ║
║   ▒███    ███ ▒▒███     ███     ▒███  ▒▒█████ ▒▒███     ███     ▒███        ▒███ ▒   █ ▒███    ███  ▒███     ▒███    ▒▒▒ ▒▒▒    ║
║   ██████████   ▒▒▒███████▒      █████  ▒▒█████ ▒▒▒███████▒      █████       ██████████ ██████████   █████    █████    ███ ███   ║
║  ▒▒▒▒▒▒▒▒▒▒      ▒▒▒▒▒▒▒       ▒▒▒▒▒    ▒▒▒▒▒    ▒▒▒▒▒▒▒       ▒▒▒▒▒       ▒▒▒▒▒▒▒▒▒▒ ▒▒▒▒▒▒▒▒▒▒   ▒▒▒▒▒    ▒▒▒▒▒    ▒▒▒ ▒▒▒    ║
╠═════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
║ This file is imported from its dedicated GitHub repository and is automatically updated to always be in sync with the canonical ║
║ LibFC API. Editing it to add new functions will not add new features to the API, though if it's something that can be added to  ║
║ the base API without requiring game-side updates, please create a pull request to get it added for everyone to use.             ║
╚═════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝
]]
local LibFC = { CharacterAPI = {}, MapAPI = {}, ItemAPI = {}, NPCAPI = {} }

type CharacterData = {
	Name: string,
	MaxHealth: number,
	WalkSpeed: number,
	RunSpeed: number,
	Moves: {
		Melee: { Move },
		Skill: { Move },
		Special: { Move },
	},

	CreateMove: (self: CharacterData, move: Move) -> Move,
}

export type Character = typeof(setmetatable({} :: CharacterData, LibFC.CharacterAPI))

export type Node = {
	Name: string,
	Properties: { [string]: any },
}

export type Branch = { Node }

export type Move = {
	Name: string,
	Conditions: {}?,
	Properties: {}?,
	Branches: {
		Main: { Node },
		[string]: { Node },
	},
}

LibFC["Nodes"] = {
	--[=[
    Plays an animation.
    @param animationID The ID of the animation to play.
    @param speed The speed of the animation.
    @param priority The priority of the animation.
    @param fadeTime The fade time of the animation.
    @return The created node.
    ]=]
	Animation = function(
		animationID: number,
		speed: number?,
		priority: Enum.AnimationPriority?,
		fadeTime: number?
	): Node
		return {
			Name = "Animation",
			Properties = {
				ID = animationID,
				Speed = speed or 1,
				Priority = priority or Enum.AnimationPriority.Action,
				FadeTime = fadeTime or 0.25,
			},
		}
	end,

	--[=[
    Plays a sound.
    @param soundID The ID of the sound to play.
    @param playbackSpeed The playback speed of the sound.
    @param volume The volume of the sound.
    @param playbackRegion The region of the sound to play.
    @return The created node.
    ]=]
	Sound = function(soundID: number, playbackSpeed: number?, volume: number?): Node
		return {
			Name = "Sound",
			Properties = {
				ID = soundID,
				PlaybackSpeed = playbackSpeed or 1,
				Volume = volume or 1,
			},
		}
	end,

	--[=[
    Propel the player with a force.
    @param force The force to apply.
    @param duration The duration of the force.
    @param direction The direction of the force.
    @param alignDirection If true, the character model will be aligned with the direction of the force.
    @param easingStyle The easing style of the force.
    @param easingDirection The easing direction of the force.
    @return The created node.
    ]=]
	Velocity = function(
		force: number,
		duration: number?,
		direction: Vector3?,
		alignDirection: boolean?,
		easingStyle: Enum.EasingStyle?,
		easingDirection: Enum.EasingDirection?
	): Node
		return {
			Name = "Velocity",
			Properties = {
				Force = force,
				Duration = duration or 0.2,
				Direction = direction or Vector3.new(0, 0, 1),
				AlignDirection = alignDirection or false,
				EasingStyle = easingStyle or Enum.EasingStyle.Linear,
				EasingDirection = easingDirection or Enum.EasingDirection.Out,
			},
		}
	end,

	--[=[
	Modify the player's health directly. Recommended to use Heal or Damage instead.
    @param amount The amount of health to modify. Can be negative to subtract health.
    @return The created node.
    ]=]
	Health = function(amount: number): Node
		return {
			Name = "Health",
			Properties = {
				Amount = amount,
			},
		}
	end,

	--[=[
	Damage the player.
	@param damage The damage to deal.
	@param damageType The type of damage to deal.
	@param bypassCounter If true, the player will not be able to counter the attack.
	@return The created node.
	]=]
	Damage = function(damage: number, damageType: "Melee" | "Ranged"?, bypassCounter: boolean?): Node
		return {
			Name = "Damage",
			Properties = {
				Damage = damage,
				DamageType = damageType or "Melee",
				BypassCounter = bypassCounter or false,
			},
		}
	end,

	--[=[
	Heal the player.
	@param amount The amount of health to heal.
	@return The created node.
	]=]
	Heal = function(amount: number): Node
		return {
			Name = "Heal",
			Properties = {
				Amount = amount,
			},
		}
	end,

	--[=[
	Highlight the player.
	@param fillTransparency The fill transparency of the highlight.
	@param outlineTransparency The outline transparency of the highlight.
	@param fillColor The fill color of the highlight.
	@param outlineColor The outline color of the highlight.
	@param duration The duration of the highlight.
	@param transparencyEasingStyle The easing style of the transparency.
	@param transparencyEasingDirection The easing direction of the transparency.
	@param transparencyEasingDuration The easing duration of the transparency.
	@return The created node.
	]=]
	Highlight = function(
		fillTransparency: number?,
		outlineTransparency: number?,
		fillColor: Color3?,
		outlineColor: Color3?,
		duration: number?,
		occlusionMode: "Occluded" | "AlwaysOnTop"?,
		transparencyEasingStyle: Enum.EasingStyle?,
		transparencyEasingDirection: Enum.EasingDirection?,
		transparencyEasingDuration: number?
	): Node
		return {
			Name = "Highlight",
			Properties = {
				FillTransparency = fillTransparency or 0.5,
				OutlineTransparency = outlineTransparency or 1,
				FillColor = fillColor or Color3.new(1, 1, 1),
				OutlineColor = outlineColor or Color3.new(0, 0, 0),
				Duration = duration or 0.5,
				TransparencyEasingStyle = transparencyEasingStyle or Enum.EasingStyle.Linear,
				TransparencyEasingDirection = transparencyEasingDirection or Enum.EasingDirection.Out,
				TransparencyEasingDuration = transparencyEasingDuration or 0.5,
				OcclusionMode = occlusionMode or "Occluded",
			},
		}
	end,

	--[=[
	Wait for a specific amount of time.
	@param duration The duration to wait.
	@return The created node.
	]=]
	Wait = function(duration: number)
		return {
			Name = "Wait",
			Properties = {
				Duration = duration,
			},
		}
	end,
	
	--[=[
	Create a hitbox.
	@param size The size of the hitbox.
	@param offset The offset of the hitbox.
	@param onhit The branch to run when the hitbox hits something. This branch will be ran on every person hit.
	]=]
	Hitbox = function(size: Vector3, offset: CFrame, onhit: {Node}): Node
		return {
			Name = "Hitbox",
			Properties = {
				size = size,
				offset = offset,
				onhit = onhit,
			}
		}
	end,
}

--[=[
   Create a new character.
   @param name The name of the character.
   @param maxHealth The maximum health of the character.
   @param walkSpeed The walk speed of the character.
   @param runSpeed The run speed of the character.
   @param moves The moves of the character.
   @return The created character itself.
]=]
function LibFC.CharacterAPI.new(name: string, maxHealth: number?, walkSpeed: number?, runSpeed: number?): Character
	local self: CharacterData = {
		Name = name,
		MaxHealth = maxHealth or 100,
		WalkSpeed = walkSpeed or 16,
		RunSpeed = runSpeed or 24,
		Moves = {
			Melee = {},
			Skill = {},
			Special = {},
		},

		CreateMove = function(self: CharacterData, Move: Move): Move
			table.insert(self.Moves.Skill, Move)
			return Move
		end,
	}

	return setmetatable(self, LibFC.CharacterAPI)
end

export type LibFC = typeof(LibFC)
return LibFC
