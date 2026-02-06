extends Node2D

enum MenuType {
	SETTINGS,
	CREDITS
}

@onready var windowmenustuff: Control = $menuStuff/windowmenustuff
@onready var menus: Control = $menuStuff/windowmenustuff/menus

func _on_credits_pressed() -> void:
	open_menu(MenuType.CREDITS)

func _on_settings_pressed() -> void:
	open_menu(MenuType.SETTINGS)

func open_menu(menu_type : MenuType) -> void:
	windowmenustuff.visible = true

	for i in menus.get_children():
		i.visible = false
	
	menus.get_child(menu_type).visible = true


func _on_close_menu_pressed() -> void:
	windowmenustuff.visible = false