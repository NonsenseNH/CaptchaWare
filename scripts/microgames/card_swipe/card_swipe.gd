extends Microgame

@onready var card: Node2D = $card
@onready var text_anim: AnimationPlayer = $textAnim

var complete := false

func _on_card_swipe_completed() -> void:
	text_anim.play("task completed")
	skip_timer.emit()
	complete = true

func isWinning() -> bool:
	return complete