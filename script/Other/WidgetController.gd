extends Area2D
class_name Widget_controller

var pool_name:String = "PowerPointPool"

func deactivate()->void:
	PoolManager.widget_pool_manager._deactivate_widget(pool_name,self);
	
