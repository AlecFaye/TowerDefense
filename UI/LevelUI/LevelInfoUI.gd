extends Control

onready var coins_amount = $"%GoldAmount"
onready var lives_amount = $"%LivesAmount"
onready var waves_amount = $"%WavesAmount"


func update_gold(var coins: int) -> void:
	coins_amount.text = str(coins)


func update_lives(var current_lives: int) -> void:
	lives_amount.text = str(current_lives)


func update_waves(var current_wave: int, var total_waves: int) -> void:
	waves_amount.text = str(current_wave) + "/" + str(total_waves)
