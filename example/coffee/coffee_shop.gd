class_name CoffeeShop extends RefCounted


var _coffee_maker: CoffeeMaker
var _staff_member: StaffMember


func _init(
	__: ChildScope,
	coffee_maker: CoffeeMaker,
	staff_member: StaffMember,
) -> void:
	self._coffee_maker = coffee_maker
	self._staff_member = staff_member
