GDPC                 
                                                                         P   res://.godot/exported/133200997/export-0ac7124299b9c2b9735e9e9cb80176e2-rope.scn 6      v      $A�h[��-�%�    \   res://.godot/exported/133200997/export-176b3652f885f810abceb657bf9c86ae-player_health_ui.scn�%      �      ��OL����'�Q��r>�    X   res://.godot/exported/133200997/export-2bea4e275ec4146fdf2e1a99cab9bc41-rope_piece.scn  p<      a      ��[�5��ץzo�    \   res://.godot/exported/133200997/export-537f7ab4834de991aed3d903a9e72a24-rope_end_piece.scn  �8      �      �vB/OqJ����Z���    T   res://.godot/exported/133200997/export-6dc351d0aa33c8c9359ec60a0d0cff40-level_0.scn �@      �      5�n{�ٱ���ݲ�    T   res://.godot/exported/133200997/export-7ec4f56097d651596b126122d79c30eb-knight.scn         Q      �
��E��9�����R    T   res://.godot/exported/133200997/export-94ac7a95b932d7103c68a5776a7128f3-enemy.scn   �      L      s�_&.��BȠK(    X   res://.godot/exported/133200997/export-d4e83b31417540e021f1ffd2ec82c3cc-main_menu.scn   �E      �      d��z��4���n?6�    ,   res://.godot/global_script_class_cache.cfg  �Y             ��Р�8���8~$}P�    D   res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex�H      �      �Yz=������������       res://.godot/uid_cache.bin  �Y      �      �FMػ 7�H�$8        res://entities/enemy/enemy.gd           �      qPAgsO=L�y�gJDQ    (   res://entities/enemy/enemy.tscn.remap   @V      b       �T���Agt#C���O    $   res://entities/knight/Camera2D.gd   �            �"���%��A����FZ�        res://entities/knight/knight.gd  	            ;�>�xxМ=9���    (   res://entities/knight/knight.tscn.remap �V      c       	%�]�K�wıË�L�    ,   res://entities/knight/player_health_ui.gd   �$            :�����t��`�R��%    4   res://entities/knight/player_health_ui.tscn.remap    W      m       ;�d������(A�       res://entities/lasso/rope.gdp)      �      �D	EF|�1B�.*�    $   res://entities/lasso/rope.tscn.remap�W      a       ���q0m�Gj8E���h    0   res://entities/lasso/rope_end_piece.tscn.remap   X      k       �q���&v7��2c�T�    $   res://entities/lasso/rope_piece.gd  0<      =       ��5U�
Ɂ���>T�    ,   res://entities/lasso/rope_piece.tscn.remap  pX      g       �o]80�۹@q�4}z��       res://icon.svg.import   pU      �       ��wFŽ��R�"���        res://levels/level_0.tscn.remap �X      d       �]LG˻�<�5��7�    $   res://levels/main_menu.tscn.remap   PY      f       ���p��!c����#v�       res://project.binaryp[      0      $h�:���'�jeT\    extends CharacterBody2D

@export var speed = 50
@export var damage : int = 1
@export var moving: bool = true

@onready var player = get_parent().get_node("Knight")

func _physics_process(delta):
	if is_instance_valid(player) and moving:
		var direction = (player.position - position).normalized()
		if is_in_group("captured"):
			direction *= -1
		velocity = direction * speed
	
	move_and_slide()
   RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name    custom_solver_bias    size    script 	   _bundled       Script    res://entities/enemy/enemy.gd ��������
   Texture2D    res://icon.svg �rO3t��b      local://RectangleShape2D_sdnq0 �         local://PackedScene_5jdce �         RectangleShape2D       
      B   B         PackedScene          	         names "         Enemy 	   modulate    collision_layer    collision_mask    script    CharacterBody2D 	   Sprite2D    scale    texture    CollisionShape2D    shape    	   variants            �?          �?                      
     �>  �>                         node_count             nodes     #   ��������       ����                                              ����                           	   	   ����   
                conn_count              conns               node_paths              editable_instances              version             RSRC    extends Camera2D

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
@export var lasso_speed : float = 2.0
@export var constraint : float = 10.0

@onready var hurtbox = $HurtBox

@onready var animation_player = $AnimationPlayer
@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

@onready var rope_obj = preload("res://entities/lasso/rope.tscn")
@onready var rope_end_piece = preload("res://entities/lasso/rope_end_piece.tscn")

var bodies = []

func die():
	queue_free()

func _ready():
	hp = hp

func _physics_process(_delta):
	# Movement
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	
	# Lasso
	if Input.is_action_just_pressed("whip") and not animation_player.is_playing():
		hurtbox.look_at(get_global_mouse_position())
		animation_player.play("attack")
	
	velocity = input_direction * move_speed
	
	for body in bodies:
		if (int(velocity.x) ^ int(body.velocity.x)) < 0:
			print(body.velocity.normalized())
			if abs(velocity.x - body.velocity.x) < constraint:
				body.velocity = Vector2.ZERO
			velocity += body.velocity
	
	move_and_slide()

func add_new_rope(body):
	body.add_to_group("captured")
	var rope = rope_obj.instantiate()
	var rope_start = rope_end_piece.instantiate()
	add_child(rope_start)
	var rope_end = rope_end_piece.instantiate()
	body.add_child(rope_end)
	rope.rope_start_piece = rope_start
	rope.rope_end_piece = rope_end
	get_parent().add_child(rope)
	rope.spawn_rope()

func _on_hit_box_body_entered(body):
	if body.is_in_group("enemies") and not body.is_in_group("captured"):
		hp -= body.damage
func _on_hurtbox_body_entered(body):
	if body.is_in_group("enemies") and not body.is_in_group("captured"):
		call_deferred("add_new_rope", body)
		bodies.append(body)
           RSRC                    PackedScene            ��������                                            ;      HurtBox    collision_mask 	   Sprite2D    visible    ..    AnimationPlayer    resource_local_to_scene    resource_name    custom_solver_bias    size    script    length 
   loop_mode    step    tracks/0/type    tracks/0/imported    tracks/0/enabled    tracks/0/path    tracks/0/interp    tracks/0/loop_wrap    tracks/0/keys    tracks/1/type    tracks/1/imported    tracks/1/enabled    tracks/1/path    tracks/1/interp    tracks/1/loop_wrap    tracks/1/keys    _data    auto_triangles 
   min_space 
   max_space    snap    x_label    y_label    blend_mode    sync    xfade_time    xfade_curve    reset 	   priority    switch_mode    advance_mode    advance_condition    advance_expression    state_machine_type    allow_transition_to_self    reset_ends    states/End/node    states/End/position    states/Idle/node    states/Idle/position    states/Start/node    states/Start/position    states/Walk/node    states/Walk/position    transitions    graph_offset 	   _bundled       Script     res://entities/knight/knight.gd ��������
   Texture2D    res://icon.svg �rO3t��b   Script "   res://entities/knight/Camera2D.gd ��������   PackedScene ,   res://entities/knight/player_health_ui.tscn �y���      local://RectangleShape2D_vcw2b h         local://Animation_audbw �         local://AnimationLibrary_a50b0 �	      (   local://AnimationNodeBlendSpace2D_va5ow �	      (   local://AnimationNodeBlendSpace2D_8tqgi 8
      2   local://AnimationNodeStateMachineTransition_qojdq b
      2   local://AnimationNodeStateMachineTransition_1x020 �
      (   local://AnimationNodeStateMachine_yrndm �
         local://RectangleShape2D_an74c �         local://RectangleShape2D_nid7g �         local://PackedScene_f81eu +         RectangleShape2D    	   
      B   B
      
   Animation             attack          ?         value                                                                    times !             ?      transitions !        �?  �?      values                          update                value                                                                       times !             ?      transitions !        �?  �?      values                          update       
         AnimationLibrary                   attack          
         AnimationNodeBlendSpace2D       
     ���̌�   
     �?�̌?#         
         AnimationNodeBlendSpace2D    
      $   AnimationNodeStateMachineTransition    
      $   AnimationNodeStateMachineTransition    *          
         AnimationNodeStateMachine 
   0      2            3   
    ��C  �B4      5   
     /C  �B6            7   
     �C  �B8               Start       Idle                Idle       Walk          9   
     ��  ��
         RectangleShape2D    	   
     �B  B
         RectangleShape2D    	   
      B   B
         PackedScene    :      	         names "   "      Knight    collision_layer    script    CharacterBody2D 	   Sprite2D    scale    texture    CollisionShape2D    shape    AnimationPlayer 
   libraries    AnimationTree 
   tree_root    anim_player    parameters/Idle/blend_position    parameters/Walk/blend_position 	   Camera2D    process_callback    position_smoothing_enabled    HurtBox    collision_mask    Area2D 	   position    debug_color    visible    HitBox    HUD    CanvasLayer    PlayerHealthUI    offset 
   transform    _on_hurtbox_body_entered    body_entered    _on_hit_box_body_entered    	   variants                       
     �>  �>                                                              
   `��7M��
                                 
     �B                  �?        ���>       
     x?  �>            	      ���>��?���>���>         
      A   A   ���=        ���=   A   A      node_count             nodes     �   ��������       ����                                  ����                                 ����                     	   	   ����   
                        ����   
                           	                     ����      
                                 ����      
      
                    ����                                      ����                                             ����                    	             ����                                 ����               ���                               conn_count             conns                                 	           !                    node_paths              editable_instances              version       
      RSRC               extends CanvasLayer

@onready var player = get_parent().get_parent()
@onready var HealthUIFull = $HealthUIFull

func _ready():
	if player:
		player.hp_changed.connect(_on_player_hp_changed)

func _on_player_hp_changed(_hp, new_hp):
	if new_hp >= 0:
		HealthUIFull.size.x = new_hp * 128
  RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script *   res://entities/knight/player_health_ui.gd ��������
   Texture2D    res://icon.svg �rO3t��b      local://PackedScene_va5bv J         PackedScene          	         names "         PlayerHealthUI    scale 
   transform    script    CanvasLayer    HealthUIFull    offset_right    offset_bottom    texture    stretch_mode    TextureRect    	   variants       
   ���=���=   ���=        ���=                        B                     node_count             nodes        ��������       ����                                  
      ����                     	                conn_count              conns               node_paths              editable_instances              version             RSRC            extends Node2D

var RopePiece = preload("res://entities/lasso/rope_piece.tscn")
var piece_length := 12.0
var rope_parts := []
var rope_close_tolerance := 4.0
var rope_points: PackedVector2Array = []

#@export var rope_start_piece_path: NodePath
#@export var rope_end_piece_path: NodePath
@export var rope_gravity: float = 1
@export var rope_linear_damp: float = 1
@export var rope_angular_damp = 1
@export var joint_softness: float = 0.1 
@export var joint_bias: float = 0.1

@export var rope_start_piece: RigidBody2D
@export var rope_end_piece: RigidBody2D
@onready var rope_start_joint = rope_start_piece.get_node("CollisionShape2D/PinJoint2D")
@onready var rope_end_joint = rope_end_piece.get_node("CollisionShape2D/PinJoint2D")

func spawn_rope():
	# Setup rope start and end pieces position
	#rope_start_piece.global_position = start_pos
	#rope_end_piece.global_position = end_pos
	
	# Get position of joints
	var start_pos = rope_start_joint.global_position
	var end_pos = rope_end_joint.global_position
	
	# Calculate amount of pieces to generate between start and end points
	var distance = start_pos.distance_to(end_pos)
	var pieces_amount = round(distance / piece_length)
	# Angle between points
	var spawn_angle = (end_pos - start_pos).angle() - PI/2
	
	create_rope(pieces_amount, rope_start_piece, end_pos, spawn_angle)

func create_rope(pieces_amount: int, parent: Object, end_pos: Vector2, spawn_angle: float):
	# Start chaining pieces from start piece as parent
	for i in pieces_amount:
		# Assign parent as new piece
		parent = add_piece(parent, i, spawn_angle)
		parent.set_name("rope_piece_"+str(i))
		rope_parts.append(parent)
		
		# Get current joint, exclusing joint end pieces
		var parent_joint = parent.get_node("CollisionShape2D/PinJoint2D")
		# Setting current joint parameters
		parent_joint.softness = joint_softness
		parent_joint.bias = joint_bias
		# Stop chaining when approaching rope end piece
		if parent_joint.global_position.distance_to(end_pos) < rope_close_tolerance:
			break
	
	rope_end_joint.node_a = rope_end_piece.get_path()
	rope_end_joint.node_b = rope_parts[-1].get_path()

func add_piece(parent: Object, id: int, spawn_angle: float) -> Object:
	# Get joint info on current parent
	var joint : PinJoint2D = parent.get_node("CollisionShape2D/PinJoint2D") as PinJoint2D
	# Generate new rope piece
	var piece : Object = RopePiece.instantiate() as Object
	# Set position and rotation of new piece equal to parent joint
	piece.global_position = joint.global_position
	piece.rotation = spawn_angle
	# Set new piece parent as current piece
	piece.parent = self
	piece.id = id
	# Setting rope piece parameters
	piece.gravity_scale = rope_gravity
	piece.linear_damp = rope_linear_damp
	piece.angular_damp = rope_angular_damp
	
	add_child(piece)
	
	joint.node_a = parent.get_path()
	joint.node_b = piece.get_path()
	
	return piece

func get_rope_points():
	rope_points.clear()
	
	rope_points.append(rope_start_joint.global_position)
	for r in rope_parts:
		rope_points.append(r.global_position)
	rope_points.append(rope_end_joint.global_position)

func _process(_delta):
	queue_redraw()

func _draw():
	get_rope_points()
	draw_polyline(rope_points, Color.SADDLE_BROWN, 1)
       RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script    res://entities/lasso/rope.gd ��������      local://PackedScene_r3bay          PackedScene          	         names "         Rope    script    Node2D    	   variants                       node_count             nodes     	   ��������       ����                    conn_count              conns               node_paths              editable_instances              version             RSRC          RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name    custom_solver_bias    radius    script 	   _bundled           local://CircleShape2D_pps58 *         local://PackedScene_w0tch T         CircleShape2D            @@         PackedScene          	         names "   
      RopeEndPiece    collision_layer    gravity_scale    freeze    RigidBody2D    CollisionShape2D    shape    PinJoint2D    bias 	   softness    	   variants                                       ���=      node_count             nodes     !   ��������       ����                                        ����                          ����         	                conn_count              conns               node_paths              editable_instances              version             RSRC   extends RigidBody2D

var id := -1
var parent : Object = null
   RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name    custom_solver_bias    radius    height    script 	   _bundled       Script #   res://entities/lasso/rope_piece.gd ��������      local://CapsuleShape2D_8kwix p         local://PackedScene_nn2xs �         CapsuleShape2D             @         A         PackedScene          	         names "      
   RopePiece 	   position    collision_layer    linear_damp    angular_damp    script    RigidBody2D    CollisionShape2D    shape    PinJoint2D    bias 	   softness    	   variants       
          @           �?          
         @@          
         �@   ���=      node_count             nodes     )   ��������       ����                                                    ����                          	   	   ����         
                      conn_count              conns               node_paths              editable_instances              version             RSRC               RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name    diffuse_texture    normal_texture    specular_texture    specular_color    specular_shininess    texture_filter    texture_repeat    script 	   _bundled       PackedScene "   res://entities/knight/knight.tscn �}�J��%l   PackedScene     res://entities/enemy/enemy.tscn ����s�	      local://CanvasTexture_yebod          local://PackedScene_qpvcg ,         CanvasTexture    	         PackedScene    
      	         names "         Level0    Node2D    TextureRect    offset_left    offset_top    offset_right    offset_bottom    texture    Knight 	   position    Enemy    enemies    	   variants    	        ��     ��     �     l�                    
     �A  �A         
    ��C  ��      node_count             nodes     +   ��������       ����                      ����                                              ���         	                  ���
         	                  conn_count              conns               node_paths              editable_instances              version       	      RSRC       RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script           local://PackedScene_qjj5r �          PackedScene          	         names "      	   MainMenu    Node2D    Label    offset_right    offset_bottom    text    	   variants             B     �A      LassoKnight       node_count             nodes        ��������       ����                      ����                                conn_count              conns               node_paths              editable_instances              version             RSRC           GST2   �   �      ����               � �        �  RIFF�  WEBPVP8L�  /������!"2�H�$�n윦���z�x����դ�<����q����F��Z��?&,
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

path="res://.godot/exported/133200997/export-0ac7124299b9c2b9735e9e9cb80176e2-rope.scn"
               [remap]

path="res://.godot/exported/133200997/export-537f7ab4834de991aed3d903a9e72a24-rope_end_piece.scn"
     [remap]

path="res://.godot/exported/133200997/export-2bea4e275ec4146fdf2e1a99cab9bc41-rope_piece.scn"
         [remap]

path="res://.godot/exported/133200997/export-6dc351d0aa33c8c9359ec60a0d0cff40-level_0.scn"
            [remap]

path="res://.godot/exported/133200997/export-d4e83b31417540e021f1ffd2ec82c3cc-main_menu.scn"
          list=Array[Dictionary]([])
     	   ����s�	   res://entities/enemy/enemy.tscn�}�J��%l!   res://entities/knight/knight.tscn�y���+   res://entities/knight/player_health_ui.tscn��N��   res://entities/lasso/rope.tscnG	(%�^ (   res://entities/lasso/rope_end_piece.tscn�B�a���`$   res://entities/lasso/rope_piece.tscn�yG= 8�   res://levels/level_0.tscn��+��)b   res://levels/main_menu.tscn�rO3t��b   res://icon.svg         ECFG      application/config/name         LassoKnight    application/run/main_scene$         res://levels/level_0.tscn      application/config/features(   "         4.2    GL Compatibility    "   display/window/size/viewport_width         #   display/window/size/viewport_height      �     display/window/stretch/mode         canvas_items   display/window/stretch/scale         @   editor_plugins/enabled8   "      *   res://addons/coi_serviceworker/plugin.cfg      input/up�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   W   	   key_label             unicode    w      echo          script      
   input/left�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   A   	   key_label             unicode    a      echo          script      
   input/down�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   S   	   key_label             unicode    s      echo          script         input/right�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   D   	   key_label             unicode    d      echo          script      
   input/whip�              deadzone      ?      events              InputEventMouseButton         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          button_mask          position     C  �A   global_position      C  �B   factor       �?   button_index         canceled          pressed          double_click          script         input/reel_in�              deadzone      ?      events              InputEventMouseButton         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          button_mask          position     C  �A   global_position      C  �B   factor       �?   button_index         canceled          pressed          double_click          script         layer_names/2d_physics/layer_1         ground     layer_names/2d_physics/layer_2         player     layer_names/2d_physics/layer_3         enemies    layer_names/2d_physics/layer_4         rope   physics/2d/default_gravity        pB9   rendering/textures/canvas_textures/default_texture_filter          #   rendering/renderer/rendering_method         gl_compatibility*   rendering/renderer/rendering_method.mobile         gl_compatibility4   rendering/textures/vram_compression/import_etc2_astc         