extends TextureProgress

enum HealthType {
	HEALTH,
	ARMOUR,
	MAGICAL,
	ENERGY
}

export (Texture) var health_bar_under
export (Texture) var health_bar_progress

export (Texture) var armour_bar_under
export (Texture) var armour_bar_progress

export (Texture) var magical_bar_under
export (Texture) var magical_bar_progress

export (Texture) var energy_shield_bar_under
export (Texture) var energy_shield_bar_progress

var health_type


func set_textures() -> void:
	match health_type:
		HealthType.HEALTH:
			self.texture_under = health_bar_under
			self.texture_progress = health_bar_progress
		HealthType.ARMOUR:
			self.texture_under = armour_bar_under
			self.armour_bar_progress = armour_bar_progress
		HealthType.MAGICAL:
			self.texture_under = magical_bar_under
			self.texture_progress = magical_bar_progress
		HealthType.ENERGY:
			self.texture_under = energy_shield_bar_under
			self.texture_progress = energy_shield_bar_progress
