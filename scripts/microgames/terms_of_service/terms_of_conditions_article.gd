extends VBoxContainer

const TERMS_OF_CONDITIONS_LOCATION :String = "res://scripts/microgames/terms_of_service/the_terms_of_service.txt"
var terms_of_conditions_array : Array[String] = []
@onready var terms_of_conditions_article: Control = $TermsOfConditionsArticle
var loaded : = false
func _ready() -> void:
	if loaded: return
	load_articles()
	loaded = true

func load_articles() -> void:
	const TEXT_PARAGRAPH_OFFSET := 23
	var file := FileAccess.open(TERMS_OF_CONDITIONS_LOCATION, FileAccess.READ)
	var prev_article_offset : Vector2 = Vector2.ZERO
	var prev_line_count : int = 0
	
	terms_of_conditions_array.append_array(file.get_as_text().split("[br][br]"))
	
	var first := true
	for paragraph in terms_of_conditions_array:
		var cur_rich_text : Control
		if !first:
			cur_rich_text = terms_of_conditions_article.duplicate()
			add_child(cur_rich_text)
			cur_rich_text.get_child(0).owner = self
		else:
			cur_rich_text = terms_of_conditions_article
		
		var tos_label := cur_rich_text.get_child(0)
		
		tos_label.position += Vector2.DOWN * (prev_article_offset.y + (prev_line_count  * TEXT_PARAGRAPH_OFFSET))
		
		cur_rich_text.owner = self
		tos_label.text = paragraph
		
		prev_article_offset = tos_label.position
		prev_line_count = tos_label.get_line_count()
		
		first = false
