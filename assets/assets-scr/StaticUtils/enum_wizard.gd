class_name EnumWizard
extends RefCounted #enum_wizard.gd

func random_value_from(_enum):
	return _enum.keys()[randi() % _enum.size()]
