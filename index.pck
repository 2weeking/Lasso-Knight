GDPC                �	                                                                         \   res://.godot/exported/133200997/export-176b3652f885f810abceb657bf9c86ae-player_health_ui.scn�8      �      Xf�v��$q�ʰX!�\    X   res://.godot/exported/133200997/export-41a665b0cc927053a3c3b5d615e927db-verlet_rope.scn �E            �lG�`ͩ���@�    T   res://.godot/exported/133200997/export-6dc351d0aa33c8c9359ec60a0d0cff40-level_0.scn �H            C��Uc6z���+#/�    T   res://.godot/exported/133200997/export-7ec4f56097d651596b126122d79c30eb-knight.scn  p!      3      �%,��=%��,9.��    T   res://.godot/exported/133200997/export-94ac7a95b932d7103c68a5776a7128f3-enemy.scn   P      �      ;6�Ru{��~B��u}    X   res://.godot/exported/133200997/export-d4e83b31417540e021f1ffd2ec82c3cc-main_menu.scn   N      �      f�K[7����2Q�    ,   res://.godot/global_script_class_cache.cfg   a             ��Р�8���8~$}P�    D   res://.godot/imported/bar.png-896d62b42881b636c10bbbd1eaaf1e05.ctex         d       322�B2���aeJ�t    D   res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex�P      �      �Yz=������������    D   res://.godot/imported/rope.png-6bfdbd61a20abe205a2ba707c4f1f8b5.ctex0      �       ���dS��g;`��z�       res://.godot/uid_cache.bin  @a      u      y��1��Œ���}͠        res://assets/rope/bar.png.importp       �       Y�X�no�b��t�
    $   res://assets/rope/rope.png.import   �      �       �ͫe��� �,�i�"        res://entities/enemy/enemy.gd   �      �      I{�j3\�o"��4y�    (   res://entities/enemy/enemy.tscn.remap   �^      b       �T���Agt#C���O    $   res://entities/knight/Camera2D.gd   �            �"���%��A����FZ�        res://entities/knight/knight.gd       U      ��du#��n/�,�    (   res://entities/knight/knight.tscn.remap �^      c       	%�]�K�wıË�L�    ,   res://entities/knight/player_health_ui.gd   �7            :�����t��`�R��%    4   res://entities/knight/player_health_ui.tscn.remap   `_      m       ;�d������(A�    $   res://entities/lasso/verlet_rope.gd �<      #	      �*x�dYw�}A���J�    ,   res://entities/lasso/verlet_rope.tscn.remap �_      h       �[G�:�3|�?9A���       res://icon.svg.import   �]      �       ��wFŽ��R�"���        res://levels/level_0.tscn.remap @`      d       �]LG˻�<�5��7�    $   res://levels/main_menu.tscn.remap   �`      f       ���p��!c����#v�       res://project.binary�b      X      A"NR
����X���MC            GST2              ����                          ,   RIFF$   WEBPVP8L   /���Lڦ��K�����            [remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://cg4xatg7ceowa"
path="res://.godot/imported/bar.png-896d62b42881b636c10bbbd1eaaf1e05.ctex"
metadata={
"vram_texture": false
}
 GST2              ����                          J   RIFFB   WEBPVP8L5   /� Hq�,HRYwj�`�'�����5�0��$%9���❳�gE�x               [remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://cu1g5p63v14nh"
path="res://.godot/imported/rope.png-6bfdbd61a20abe205a2ba707c4f1f8b5.ctex"
metadata={
"vram_texture": false
}
                extends CharacterBody2D

@export var speed = 50
@export var damage : int = 1
@export var moving: bool = true

@onready var player = get_parent().get_node("Knight")

var desired_velocity = Vector2.ZERO

func _physics_process(_delta):
	if is_instance_valid(player) and moving:
		var direction = (player.position - position).normalized()
		desired_velocity = direction * speed
		if is_in_group("capturing"):
			direction *= -1
			velocity.x = desired_velocity.x - player.desired_velocity.x
		else:
			# Speed up towards player to simulate reel in effect
			if is_in_group("captured"):
				speed += 5
			velocity = desired_velocity
	
	move_and_slide()


func _on_hitbox_area_entered(_area):
	pass
           RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name    custom_solver_bias    size    script 	   _bundled       Script    res://entities/enemy/enemy.gd ��������
   Texture2D    res://icon.svg �rO3t��b      local://RectangleShape2D_sdnq0 �         local://RectangleShape2D_bra3n          local://RectangleShape2D_ark4w A         local://PackedScene_csdxv r         RectangleShape2D       
      B   B         RectangleShape2D       
      B   B         RectangleShape2D       
     B  B         PackedScene          	         names "         Enemy    collision_layer    script    enemy    CharacterBody2D 	   Sprite2D    scale    texture    CollisionShape2D    shape    debug_color    Hitbox    collision_mask    Area2D    Hurtbox 	   position    _on_hitbox_area_entered    area_entered    	   variants                       
     �>  �>                          ��?��3?���>   
                   ��%?��p>���>             
          ?            ��n?��\>���>���>      node_count             nodes     P   ��������       ����                                    ����                                 ����   	      
                        ����                                 ����   	      
                        ����      	      
                    ����         	      
                conn_count             conns                                      node_paths              editable_instances              version             RSRC       extends Camera2D

# Radius of the zone in the middle of the screen where the cam doesn't move
const DEAD_ZONE = 80

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion: # If the mouse moved...
		var _target = event.position - get_viewport().get_visible_rect().size * 0.5	# Get the mouse position relative to the middle of the screen
		if _target.length() < DEAD_ZONE:	# If we're in the middle (dead zone)...
			self.position = Vector2(0,0)	# ... reset the camera to the middle (= center on player)
		else:
			# _target.normalized() is the direction in which to move
			# _target.length() - DEAD_ZONE is the distance the mouse is outside of the dead zone
			# 0.5 is an arbitrary scalar
			self.position = _target.normalized() * (_target.length() - DEAD_ZONE) * 0.5
            extends CharacterBody2D

signal hp_changed(old_value: int, new_value: int)

@export var hp : int = 3 :
	get:
		return hp
	set(new_hp):
		if new_hp <= 0:
			die()
		hp_changed.emit(hp, new_hp)
		hp = new_hp

@export var move_speed : float = 150.0
@export var lasso_speed : float = 2
@export var lasso_range: float = 250.0
@export var lasso_goldilocks: float = 0.5

@onready var verlet_rope = preload("res://entities/lasso/verlet_rope.tscn")
#@onready var lasso_pathfollow = $HurtBox/Path2D/PathFollow2D
@onready var lasso_bar = $LassoBar
#@onready var hurtbox = $HurtBox

@onready var lasso_path = $Path2D
@onready var lasso_pathfollow = $Path2D/PathFollow2D
@onready var hurtbox = $Path2D/PathFollow2D/HurtBox

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

var lasso_bar_bound_lower = (lasso_range/2)-(lasso_range*lasso_goldilocks/2)
var lasso_bar_bound_upper = (lasso_range/2)+(lasso_range*lasso_goldilocks/2)

var ropes = []
var desired_velocity = Vector2.ZERO
var whipping = false

func die():
	queue_free()

func _ready():
	hp = hp
	# Set up lasso bar
	lasso_bar.visible = false
	lasso_bar.max_value = lasso_range
	
	# Gradient dependent on lasso range
	var gradient_texture = GradientTexture1D.new()
	var gradient = Gradient.new()
	
	gradient.set_color(0, Color.CRIMSON) # bottom
	gradient.set_color(1, Color.CRIMSON) # top
	gradient.add_point(lasso_bar_bound_lower/lasso_range, Color.YELLOW) # q1
	gradient.add_point(0.5, Color.GREEN) # middle
	gradient.add_point(lasso_bar_bound_upper/lasso_range, Color.YELLOW) # q3
	
	gradient_texture.gradient = gradient
	lasso_bar.texture_under = gradient_texture

func _physics_process(delta):
	# Movement
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	
	# Lasso
	if Input.is_action_just_pressed("whip") and not whipping:
		# Initiate whipping with hurtbox
		lasso_path.look_at(get_global_mouse_position())
		hurtbox.set_collision_mask_value(3, true)
		lasso_pathfollow.progress_ratio = 0
		whipping = true
	
	# Whipping state to latch on to enemies
	if whipping:
		lasso_pathfollow.progress_ratio += lasso_speed * delta
		# Reset whipping and hurtbox
		if lasso_pathfollow.progress_ratio >= 0.95:
			hurtbox.set_collision_mask_value(3, false)
			whipping = false
	
	# Desired_velocity to used to counteract movement during rope capturing
	desired_velocity = input_direction * move_speed
	
	velocity = desired_velocity
	
	# Deal with ropes children to knight and captured enemies attached
	for rope in ropes:
		var enemy = rope.target
		var timer = rope.capture_timer
		
		# Counteract own velocity with enemy velocity to stimulate rope tension
		velocity -= enemy.desired_velocity
		
		var dist = position.distance_to(enemy.position)
		
		# Adjust progress bar and convert dist to bar offset
		lasso_bar.visible = true
		lasso_bar.texture_progress_offset.x = -(dist/lasso_range*50)
		# If in range, resume capture timer
		if dist > lasso_bar_bound_lower and dist < lasso_bar_bound_upper:
			timer.paused = false
		else:
			timer.paused = true
		
		# If timer is done, finish capturing enemy
		if timer.get_time_left() == 0:
			enemy.remove_from_group("capturing")
			enemy.add_to_group("captured")
			enemy.modulate = Color.GREEN
			lasso_bar.visible = false
		# If player is outside lasso range, break rope and reset enemy state
		elif dist > lasso_range:
			enemy.remove_from_group("capturing")
			# Queue free rope attached to enemy
			rope.queue_free()
			ropes.erase(rope)
			lasso_bar.visible = false
	
	move_and_slide()

func add_rope(body: CharacterBody2D):
	# Attach rope to enemy
	var rope = verlet_rope.instantiate()
	rope.target = body
	add_child(rope)
	ropes.append(rope)
	
	# Attach capturing timer to enemy
	var timer = Timer.new()
	rope.capture_timer = timer
	timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	timer.wait_time = 3
	timer.one_shot = true
	timer.autostart = true
	rope.add_child(timer)
	
	body.add_to_group("capturing")

func remove_rope(body: CharacterBody2D, kill: bool):
	# First delete rope associated with body
	for rope in ropes:
		if body == rope.target:
			rope.queue_free()
			ropes.erase(rope)
	
	# Optionally delete body attached
	if kill:
		body.queue_free()

func _on_hit_box_body_entered(body):
	if body.is_in_group("enemy"):
		if body.is_in_group("captured"):
			remove_rope(body, true)
		else:
			hp -= body.damage

func _on_hurtbox_body_entered(body):
	if body.is_in_group("enemy") and not body.is_in_group("capturing") and not body.is_in_group("captured"):
		call_deferred("add_rope", body)
           RSRC                    PackedScene            ��������                                            =      ..    Path2D    PathFollow2D    HurtBox    collision_mask    AnimationPlayer    resource_local_to_scene    resource_name    bake_interval    _data    point_count    script    custom_solver_bias    size    length 
   loop_mode    step    tracks/0/type    tracks/0/imported    tracks/0/enabled    tracks/0/path    tracks/0/interp    tracks/0/loop_wrap    tracks/0/keys    auto_triangles 
   min_space 
   max_space    snap    x_label    y_label    blend_mode    sync    xfade_time    xfade_curve    reset 	   priority    switch_mode    advance_mode    advance_condition    advance_expression    state_machine_type    allow_transition_to_self    reset_ends    states/End/node    states/End/position    states/Idle/node    states/Idle/position    states/Start/node    states/Start/position    states/Walk/node    states/Walk/position    transitions    graph_offset    diffuse_texture    normal_texture    specular_texture    specular_color    specular_shininess    texture_filter    texture_repeat 	   _bundled       Script     res://entities/knight/knight.gd ��������   PackedScene &   res://entities/lasso/verlet_rope.tscn �6�4k��
   Texture2D    res://icon.svg �rO3t��b   Script "   res://entities/knight/Camera2D.gd ��������   PackedScene ,   res://entities/knight/player_health_ui.tscn �y���      local://Curve2D_v218c          local://RectangleShape2D_an74c �         local://RectangleShape2D_vcw2b �         local://Animation_audbw *	         local://AnimationLibrary_a50b0 M
      (   local://AnimationNodeBlendSpace2D_va5ow �
      (   local://AnimationNodeBlendSpace2D_8tqgi �
      2   local://AnimationNodeStateMachineTransition_qojdq       2   local://AnimationNodeStateMachineTransition_1x020 I      (   local://AnimationNodeStateMachine_yrndm �         local://RectangleShape2D_nid7g |         local://CanvasTexture_3xjrk �         local://PackedScene_s6bt4 �         Curve2D    	               points %                              4����/K>4��B�/K�  �B  ��                  C    �ԑB�U?�ԑ��U�  �B  �A                        
                  RectangleShape2D             RectangleShape2D       
      B   B      
   Animation 
            attack          ?         value                                                                         times !             ?      transitions !        �?  �?      values                          update                AnimationLibrary    	               attack                   AnimationNodeBlendSpace2D       
     ���̌�   
     �?�̌?                  AnimationNodeBlendSpace2D          $   AnimationNodeStateMachineTransition          $   AnimationNodeStateMachineTransition    %                   AnimationNodeStateMachine 
   +      -            .   
    ��C  �B/      0   
     /C  �B1            2   
     �C  �B3               Start       Idle                Idle       Walk          4   
     ��  ��         RectangleShape2D       
      B   B         CanvasTexture             PackedScene    <      	         names "   4      Knight    collision_layer    script    CharacterBody2D    Path2D    curve    PathFollow2D 	   rotation    rotates    Lasso    z_index    target    ropeLength    HurtBox    collision_mask    Area2D    CollisionShape2D    shape    debug_color 	   Sprite2D    scale    texture    AnimationPlayer 
   libraries    AnimationTree 
   tree_root    anim_player    parameters/Idle/blend_position    parameters/Walk/blend_position 	   Camera2D    process_callback    position_smoothing_enabled    HitBox    HUD    CanvasLayer    PlayerHealthUI    offset 
   transform 	   LassoBar    offset_left    offset_top    offset_right    offset_bottom    value 
   fill_mode    nine_patch_stretch    texture_progress    tint_progress    TextureProgressBar    _on_hurtbox_body_entered    body_entered    _on_hit_box_body_entered    	   variants    %                                ��_�                                             HB   ��_>                           �?        ���>
     �>  �>                                              	                
   `��7M��
                                      
      ���>��?���>���>         
      A   A   ���=        ���=   A   A     ��     ��     �A     ��     �@                          �?      node_count             nodes     �   ��������       ����                                  ����                          ����                          ���	         
        @                          ����      	      
                          ����                                 ����                                 ����                           ����                           ����                                                   ����                                        ����                                 ����                           "   !   ����               ���#         $      %                  0   &   ����	   '      (      )       *   !   +   "   ,      -      .   #   /   $             conn_count             conns               2   1                     2   3                    node_paths              editable_instances              version             RSRC             extends CanvasLayer

@onready var player = get_parent().get_parent()
@onready var HealthUIFull = $HealthUIFull

func _ready():
	if player:
		player.hp_changed.connect(_on_player_hp_changed)

func _on_player_hp_changed(_hp, new_hp):
	if new_hp >= 0:
		HealthUIFull.size.x = new_hp * 128
  RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script *   res://entities/knight/player_health_ui.gd ��������
   Texture2D    res://icon.svg �rO3t��b      local://PackedScene_j5d4f J         PackedScene          	         names "         PlayerHealthUI    scale 
   transform    script    CanvasLayer    HealthUIFull    offset_right    offset_bottom    texture    stretch_mode    TextureRect    	   variants       
   ���=���=   ���=        ���=                        B                     node_count             nodes        ��������       ����                                  
      ����                     	                conn_count              conns               node_paths              editable_instances              version             RSRC            extends Node2D

@export var target: Node2D
@export var capture_timer: Timer

@export var ropeLength: float = 30
@export var constrain: float = 1	# distance between points
@export var gravity: Vector2 = Vector2(0,9.8)
@export var dampening: float = 0.9
@export var startPin: bool = true
@export var endPin: bool = true

@onready var line2D: = $Line2D

var pos: PackedVector2Array
var posPrev: PackedVector2Array
var pointCount: int

func _ready()->void:
	pointCount = get_pointCount(ropeLength)
	resize_arrays()
	init_position()

func get_pointCount(distance: float)->int:
	return int(ceil(distance / constrain))

func resize_arrays():
	pos.resize(pointCount)
	posPrev.resize(pointCount)

func init_position()->void:
	for i in range(pointCount):
		pos[i] = position + Vector2(constrain *i, 0)
		posPrev[i] = position + Vector2(constrain *i, 0)
	position = Vector2.ZERO

func _process(delta)->void:
	#set_start(to_local(target.global_position))
	set_last(to_local(target.global_position))
	update_points(delta)
	update_constrain()
	
	#update_constrain()	#Repeat to get tighter rope
	#update_constrain()
	
	# Send positions to Line2D for drawing
	line2D.points = pos

func set_start(p:Vector2)->void:
	pos[0] = p
	posPrev[0] = p

func set_last(p:Vector2)->void:
	pos[pointCount-1] = p
	posPrev[pointCount-1] = p

func update_points(delta)->void:
	for i in range (pointCount):
		# not first and last || first if not pinned || last if not pinned
		if (i!=0 && i!=pointCount-1) || (i==0 && !startPin) || (i==pointCount-1 && !endPin):
			var velocity = (pos[i] -posPrev[i]) * dampening
			posPrev[i] = pos[i]
			pos[i] += velocity + ((gravity.rotated(-global_rotation)) * delta)

func update_constrain()->void:
	for i in range(pointCount):
		if i == pointCount-1:
			return
		var distance = pos[i].distance_to(pos[i+1])
		var difference = constrain - distance
		var percent = difference / distance
		var vec2 = pos[i+1] - pos[i]
		
		# if first point
		if i == 0:
			if startPin:
				pos[i+1] += vec2 * percent
			else:
				pos[i] -= vec2 * (percent/2)
				pos[i+1] += vec2 * (percent/2)
		# if last point, skip because no more points after it
		elif i == pointCount-1:
			pass
		# all the rest
		else:
			if i+1 == pointCount-1 && endPin:
				pos[i] -= vec2 * percent
			else:
				pos[i] -= vec2 * (percent/2)
				pos[i+1] += vec2 * (percent/2)
             RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script $   res://entities/lasso/verlet_rope.gd ��������
   Texture2D    res://assets/rope/rope.png �~>p�wV      local://PackedScene_a3iut P         PackedScene          	         names "         Rope    script    Node2D    Line2D    texture    texture_mode    	   variants                                      node_count             nodes        ��������       ����                            ����                         conn_count              conns               node_paths              editable_instances              version             RSRC      RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name    diffuse_texture    normal_texture    specular_texture    specular_color    specular_shininess    texture_filter    texture_repeat    script 	   _bundled       PackedScene "   res://entities/knight/knight.tscn �}�J��%l   PackedScene     res://entities/enemy/enemy.tscn ����s�	      local://CanvasTexture_yebod          local://PackedScene_py27v ,         CanvasTexture    	         PackedScene    
      	         names "         Level0    Node2D    TextureRect    offset_left    offset_top    offset_right    offset_bottom    texture    Knight    Enemy 	   position    speed    Enemy2    	   variants    
        ��     ��     �     l�                             
     #C  T�   d   
     dC  �B      node_count             nodes     3   ��������       ����                      ����                                              ���                      ���	         
                        ���         
   	             conn_count              conns               node_paths              editable_instances              version       	      RSRC      RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script           local://PackedScene_flcsy �          PackedScene          	         names "      	   MainMenu    Node2D    Label    offset_right    offset_bottom    text    	   variants             B     �A      LassoKnight       node_count             nodes        ��������       ����                      ����                                conn_count              conns               node_paths              editable_instances              version             RSRC           GST2   �   �      ����               � �        �  RIFF�  WEBPVP8L�  /������!"2�H�$�n윦���z�x����դ�<����q����F��Z��?&,
ScI_L �;����In#Y��0�p~��Z��m[��N����R,��#"� )���d��mG�������ڶ�$�ʹ���۶�=���mϬm۶mc�9��z��T��7�m+�}�����v��ح����mow�*��f�&��Cp�ȑD_��ٮ}�)� C+���UE��tlp�V/<p��ҕ�ig���E�W�����Sթ�� ӗ�A~@2�E�G"���~ ��5tQ#�+�@.ݡ�i۳�3�5�l��^c��=�x�Н&rA��a�lN��TgK㼧�)݉J�N���I�9��R���$`��[���=i�QgK�4c��%�*�D#I-�<�)&a��J�� ���d+�-Ֆ
��Ζ���Ut��(Q�h:�K��xZ�-��b��ٞ%+�]�p�yFV�F'����kd�^���:[Z��/��ʡy�����EJo�񷰼s�ɿ�A���N�O��Y��D��8�c)���TZ6�7m�A��\oE�hZ�{YJ�)u\a{W��>�?�]���+T�<o�{dU�`��5�Hf1�ۗ�j�b�2�,%85�G.�A�J�"���i��e)!	�Z؊U�u�X��j�c�_�r�`֩A�O��X5��F+YNL��A��ƩƗp��ױب���>J�[a|	�J��;�ʴb���F�^�PT�s�)+Xe)qL^wS�`�)%��9�x��bZ��y
Y4�F����$G�$�Rz����[���lu�ie)qN��K�<)�:�,�=�ۼ�R����x��5�'+X�OV�<���F[�g=w[-�A�����v����$+��Ҳ�i����*���	�e͙�Y���:5FM{6�����d)锵Z�*ʹ�v�U+�9�\���������P�e-��Eb)j�y��RwJ�6��Mrd\�pyYJ���t�mMO�'a8�R4��̍ﾒX��R�Vsb|q�id)	�ݛ��GR��$p�����Y��$r�J��^hi�̃�ūu'2+��s�rp�&��U��Pf��+�7�:w��|��EUe�`����$G�C�q�ō&1ŎG�s� Dq�Q�{�p��x���|��S%��<
\�n���9�X�_�y���6]���մ�Ŝt�q�<�RW����A �y��ػ����������p�7�l���?�:������*.ո;i��5�	 Ύ�ș`D*�JZA����V^���%�~������1�#�a'a*�;Qa�y�b��[��'[�"a���H�$��4� ���	j�ô7�xS�@�W�@ ��DF"���X����4g��'4��F�@ ����ܿ� ���e�~�U�T#�x��)vr#�Q��?���2��]i�{8>9^[�� �4�2{�F'&����|���|�.�?��Ȩ"�� 3Tp��93/Dp>ϙ�@�B�\���E��#��YA 7 `�2"���%�c�YM: ��S���"�+ P�9=+D�%�i �3� �G�vs�D ?&"� !�3nEФ��?Q��@D �Z4�]�~D �������6�	q�\.[[7����!��P�=��J��H�*]_��q�s��s��V�=w�� ��9wr��(Z����)'�IH����t�'0��y�luG�9@��UDV�W ��0ݙe)i e��.�� ����<����	�}m֛�������L ,6�  �x����~Tg����&c�U��` ���iڛu����<���?" �-��s[�!}����W�_�J���f����+^*����n�;�SSyp��c��6��e�G���;3Z�A�3�t��i�9b�Pg�����^����t����x��)O��Q�My95�G���;w9�n��$�z[������<w�#�)+��"������" U~}����O��[��|��]q;�lzt�;��Ȱ:��7�������E��*��oh�z���N<_�>���>>��|O�׷_L��/������զ9̳���{���z~����Ŀ?� �.݌��?�N����|��ZgO�o�����9��!�
Ƽ�}S߫˓���:����q�;i��i�]�t� G��Q0�_î!�w��?-��0_�|��nk�S�0l�>=]�e9�G��v��J[=Y9b�3�mE�X�X�-A��fV�2K�jS0"��2!��7��؀�3���3�\�+2�Z`��T	�hI-��N�2���A��M�@�jl����	���5�a�Y�6-o���������x}�}t��Zgs>1)���mQ?����vbZR����m���C��C�{�3o��=}b"/�|���o��?_^�_�+��,���5�U��� 4��]>	@Cl5���w��_$�c��V��sr*5 5��I��9��
�hJV�!�jk�A�=ٞ7���9<T�gť�o�٣����������l��Y�:���}�G�R}Ο����������r!Nϊ�C�;m7�dg����Ez���S%��8��)2Kͪ�6̰�5�/Ӥ�ag�1���,9Pu�]o�Q��{��;�J?<�Yo^_��~��.�>�����]����>߿Y�_�,�U_��o�~��[?n�=��Wg����>���������}y��N�m	n���Kro�䨯rJ���.u�e���-K��䐖��Y�['��N��p������r�Εܪ�x]���j1=^�wʩ4�,���!�&;ج��j�e��EcL���b�_��E�ϕ�u�$�Y��Lj��*���٢Z�y�F��m�p�
�Rw�����,Y�/q��h�M!���,V� �g��Y�J��
.��e�h#�m�d���Y�h�������k�c�q��ǷN��6�z���kD�6�L;�N\���Y�����
�O�ʨ1*]a�SN�=	fH�JN�9%'�S<C:��:`�s��~��jKEU�#i����$�K�TQD���G0H�=�� �d�-Q�H�4�5��L�r?����}��B+��,Q�yO�H�jD�4d�����0*�]�	~�ӎ�.�"����%
��d$"5zxA:�U��H���H%jس{���kW��)�	8J��v�}�rK�F�@�t)FXu����G'.X�8�KH;���[          [remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://c8n7jy45rivst"
path="res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex"
metadata={
"vram_texture": false
}
                [remap]

path="res://.godot/exported/133200997/export-94ac7a95b932d7103c68a5776a7128f3-enemy.scn"
              [remap]

path="res://.godot/exported/133200997/export-7ec4f56097d651596b126122d79c30eb-knight.scn"
             [remap]

path="res://.godot/exported/133200997/export-176b3652f885f810abceb657bf9c86ae-player_health_ui.scn"
   [remap]

path="res://.godot/exported/133200997/export-41a665b0cc927053a3c3b5d615e927db-verlet_rope.scn"
        [remap]

path="res://.godot/exported/133200997/export-6dc351d0aa33c8c9359ec60a0d0cff40-level_0.scn"
            [remap]

path="res://.godot/exported/133200997/export-d4e83b31417540e021f1ffd2ec82c3cc-main_menu.scn"
          list=Array[Dictionary]([])
     	   d����[�H   res://assets/rope/bar.png�~>p�wV   res://assets/rope/rope.png����s�	   res://entities/enemy/enemy.tscn�}�J��%l!   res://entities/knight/knight.tscn�y���+   res://entities/knight/player_health_ui.tscn�6�4k��%   res://entities/lasso/verlet_rope.tscn�yG= 8�   res://levels/level_0.tscn��+��)b   res://levels/main_menu.tscn�rO3t��b   res://icon.svg           ECFG      application/config/name         LassoKnight    application/run/main_scene$         res://levels/level_0.tscn      application/config/features(   "         4.2    GL Compatibility    "   display/window/size/viewport_width         #   display/window/size/viewport_height      �     display/window/size/mode            display/window/stretch/mode         canvas_items   display/window/stretch/scale         @   editor_plugins/enabled8   "      *   res://addons/coi_serviceworker/plugin.cfg      input/up�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   W   	   key_label             unicode    w      echo          script      
   input/left�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   A   	   key_label             unicode    a      echo          script      
   input/down�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   S   	   key_label             unicode    s      echo          script         input/right�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   D   	   key_label             unicode    d      echo          script      
   input/whip�              deadzone      ?      events              InputEventMouseButton         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          button_mask          position     C  �A   global_position      C  �B   factor       �?   button_index         canceled          pressed          double_click          script         input/reel_in�              deadzone      ?      events              InputEventMouseButton         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          button_mask          position     C  �A   global_position      C  �B   factor       �?   button_index         canceled          pressed          double_click          script         layer_names/2d_physics/layer_1         ground     layer_names/2d_physics/layer_2         player     layer_names/2d_physics/layer_3         enemy      layer_names/2d_physics/layer_4         rope   physics/2d/default_gravity        pB9   rendering/textures/canvas_textures/default_texture_filter          #   rendering/renderer/rendering_method         gl_compatibility*   rendering/renderer/rendering_method.mobile         gl_compatibility4   rendering/textures/vram_compression/import_etc2_astc                 