RSRC                    VisualShader            ��������                                            �      resource_local_to_scene    resource_name    output_port_for_preview    default_input_values    expanded_output_ports    linked_parent_graph_frame    billboard_type    keep_scale    script    input_name    op_type    noise_type    seed 
   frequency    offset    fractal_type    fractal_octaves    fractal_lacunarity    fractal_gain    fractal_weighted_strength    fractal_ping_pong_strength    cellular_distance_function    cellular_jitter    cellular_return_type    domain_warp_enabled    domain_warp_type    domain_warp_amplitude    domain_warp_frequency    domain_warp_fractal_type    domain_warp_fractal_octaves    domain_warp_fractal_lacunarity    domain_warp_fractal_gain    width    height    invert    in_3d_space    generate_mipmaps 	   seamless    seamless_blend_skirt    as_normal_map    bump_strength 
   normalize    color_ramp    noise    source    texture    texture_type 	   operator 	   function    parameter_name 
   qualifier    default_value_enabled    default_value 	   constant    code    graph_offset    mode    modes/blend    modes/depth_draw    modes/cull    modes/diffuse    modes/specular    flags/depth_prepass_alpha    flags/depth_test_disabled    flags/sss_mode_skin    flags/unshaded    flags/wireframe    flags/skip_vertex_transform    flags/world_vertex_coords    flags/ensure_correct_normals    flags/shadows_disabled    flags/ambient_light_disabled    flags/shadow_to_opacity    flags/vertex_lighting    flags/particle_trails    flags/alpha_to_coverage     flags/alpha_to_coverage_and_one    flags/debug_shadow_splits    flags/fog_disabled    nodes/vertex/0/position    nodes/vertex/2/node    nodes/vertex/2/position    nodes/vertex/3/node    nodes/vertex/3/position    nodes/vertex/4/node    nodes/vertex/4/position    nodes/vertex/connections    nodes/fragment/0/position    nodes/fragment/2/node    nodes/fragment/2/position    nodes/fragment/3/node    nodes/fragment/3/position    nodes/fragment/4/node    nodes/fragment/4/position    nodes/fragment/5/node    nodes/fragment/5/position    nodes/fragment/6/node    nodes/fragment/6/position    nodes/fragment/7/node    nodes/fragment/7/position    nodes/fragment/8/node    nodes/fragment/8/position    nodes/fragment/9/node    nodes/fragment/9/position    nodes/fragment/10/node    nodes/fragment/10/position    nodes/fragment/11/node    nodes/fragment/11/position    nodes/fragment/12/node    nodes/fragment/12/position    nodes/fragment/13/node    nodes/fragment/13/position    nodes/fragment/14/node    nodes/fragment/14/position    nodes/fragment/15/node    nodes/fragment/15/position    nodes/fragment/16/node    nodes/fragment/16/position    nodes/fragment/connections    nodes/light/0/position    nodes/light/connections    nodes/start/0/position    nodes/start/connections    nodes/process/0/position    nodes/process/connections    nodes/collide/0/position    nodes/collide/connections    nodes/start_custom/0/position    nodes/start_custom/connections     nodes/process_custom/0/position !   nodes/process_custom/connections    nodes/sky/0/position    nodes/sky/connections    nodes/fog/0/position    nodes/fog/connections        (   local://VisualShaderNodeBillboard_3w3hf I      $   local://VisualShaderNodeInput_tmsm5       ,   local://VisualShaderNodeVectorCompose_7tgk8 �         local://FastNoiseLite_y4co2 �         local://NoiseTexture2D_tyoyu !      &   local://VisualShaderNodeTexture_ppk08 P      &   local://VisualShaderNodeFloatOp_7t5tp �      $   local://VisualShaderNodeInput_lv3kc �      +   local://VisualShaderNodeUVPolarCoord_aaprt )      (   local://VisualShaderNodeColorFunc_d0b6r �      (   local://VisualShaderNodeFloatFunc_foyjr �      '   local://VisualShaderNodeVectorOp_uf3th       '   local://VisualShaderNodeVectorOp_27ury [      -   local://VisualShaderNodeColorParameter_xmodr �      ,   local://VisualShaderNodeFloatConstant_mxgab �      (   local://VisualShaderNodeFloatFunc_jvlkp 8      $   local://VisualShaderNodeInput_07l6u z      .   local://VisualShaderNodeVectorDecompose_5wrli �      &   local://VisualShaderNodeFloatOp_khgf0 �      %   local://VisualShaderNodeUVFunc_nqkr1 F         res://BloodSplatter/blood.tres m         VisualShaderNodeBillboard                      VisualShaderNodeInput    	         instance_id          VisualShaderNodeVectorCompose             FastNoiseLite                                NoiseTexture2D    +                     VisualShaderNodeTexture    -                     VisualShaderNodeFloatOp                                                �@/                  VisualShaderNodeInput    	         uv          VisualShaderNodeUVPolarCoord                             
      ?   ?           �?                      VisualShaderNodeColorFunc                       VisualShaderNodeFloatFunc              0                  VisualShaderNodeVectorOp              /                  VisualShaderNodeVectorOp    /                  VisualShaderNodeColorParameter    1         ColorParameter 3         4        �?    �Ē=  �?         VisualShaderNodeFloatConstant    5      ��L?         VisualShaderNodeFloatFunc              0                  VisualShaderNodeInput    	         color           VisualShaderNodeVectorDecompose             VisualShaderNodeFloatOp                                 )   �������?/                  VisualShaderNodeUVFunc             VisualShader )   6      c	  shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;

uniform vec4 ColorParameter : source_color = vec4(1.000000, 0.000000, 0.071664, 1.000000);
uniform sampler2D tex_frg_2;



void vertex() {
// Input:3
	int n_out3p0 = INSTANCE_ID;


// VectorCompose:4
	float n_in4p1 = 0.00000;
	float n_in4p2 = 0.00000;
	vec3 n_out4p0 = vec3(float(n_out3p0), n_in4p1, n_in4p2);


	mat4 n_out2p0;
// GetBillboardMatrix:2
	{
		mat4 __mvm = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
		__mvm = __mvm * mat4(vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0), vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0), vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0), vec4(0.0, 0.0, 0.0, 1.0));
		n_out2p0 = __mvm;
	}


// Output:0
	COLOR.rgb = n_out4p0;
	MODELVIEW_MATRIX = n_out2p0;


}

void fragment() {
// ColorParameter:10
	vec4 n_out10p0 = ColorParameter;


// Input:4
	vec2 n_out4p0 = UV;


	vec2 n_out5p0;
// UVPolarCoord:5
	vec2 n_in5p1 = vec2(0.50000, 0.50000);
	float n_in5p2 = 1.00000;
	float n_in5p3 = 0.00000;
	{
		vec2 __dir = n_out4p0 - n_in5p1;
		float __radius = length(__dir) * 2.0;
		float __angle = atan(__dir.y, __dir.x) * 1.0 / (PI * 2.0);
		n_out5p0 = vec2(__radius * n_in5p2, __angle * n_in5p3);
	}


	vec3 n_out6p0;
// ColorFunc:6
	{
		vec3 c = vec3(n_out5p0, 0.0);
		float max1 = max(c.r, c.g);
		float max2 = max(max1, c.b);
		n_out6p0 = vec3(max2, max2, max2);
	}


// FloatFunc:7
	float n_out7p0 = 1.0 - n_out6p0.x;


// Input:13
	vec4 n_out13p0 = COLOR;


// VectorDecompose:14
	float n_out14p0 = vec3(n_out13p0.xyz).x;
	float n_out14p1 = vec3(n_out13p0.xyz).y;
	float n_out14p2 = vec3(n_out13p0.xyz).z;


// FloatOp:15
	float n_in15p1 = 0.10000;
	float n_out15p0 = n_out14p0 * n_in15p1;


// UVFunc:16
	vec2 n_in16p1 = vec2(1.00000, 1.00000);
	vec2 n_out16p0 = vec2(n_out15p0) * n_in16p1 + n_out4p0;


// Texture2D:2
	vec4 n_out2p0 = texture(tex_frg_2, n_out16p0);


// FloatOp:3
	float n_in3p1 = 5.00000;
	float n_out3p0 = pow(n_out2p0.x, n_in3p1);


// VectorOp:8
	vec3 n_out8p0 = vec3(n_out7p0) * vec3(n_out3p0);


// VectorOp:9
	vec3 n_out9p0 = vec3(n_out10p0.xyz) * n_out8p0;


// FloatConstant:11
	float n_out11p0 = 0.800000;


// FloatFunc:12
	float n_out12p0 = 1.0 - n_out8p0.x;


// Output:0
	ALBEDO = n_out9p0;
	ALPHA = n_out11p0;
	ALPHA_SCISSOR_THRESHOLD = n_out12p0;


}
 P             Q   
     4�  DR            S   
     ��  �CT            U   
      B  �CV                     
                               W   
    ��D   CX            Y   
     HC  �CZ            [   
    @D ��C\            ]   
     �  HC^            _   
     �C  �B`         	   a   
     �C  �Bb         
   c   
     4D  �Bd            e   
     pD ��Cf            g   
    ��D  -Ch            i   
     kD  pBj            k   
     �D  �Cl            m   
     �D  �Cn            o   
     u�  �Cp            q   
     �  �Cr            s   
     ��  �Ct            u   
     ��  �Cv       D                                                                 	      
       	       	                                                                                                                                                                RSRC