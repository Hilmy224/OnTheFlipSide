RSRC                    VisualShader            ��������                                            �      resource_local_to_scene    resource_name    output_port_for_preview    default_input_values    expanded_output_ports    linked_parent_graph_frame    input_name    script    op_type    noise_type    seed 
   frequency    offset    fractal_type    fractal_octaves    fractal_lacunarity    fractal_gain    fractal_weighted_strength    fractal_ping_pong_strength    cellular_distance_function    cellular_jitter    cellular_return_type    domain_warp_enabled    domain_warp_type    domain_warp_amplitude    domain_warp_frequency    domain_warp_fractal_type    domain_warp_fractal_octaves    domain_warp_fractal_lacunarity    domain_warp_fractal_gain    width    height    invert    in_3d_space    generate_mipmaps 	   seamless    seamless_blend_skirt    as_normal_map    bump_strength 
   normalize    color_ramp    noise    source    texture    texture_type 	   operator 	   function    parameter_name 
   qualifier    default_value_enabled    default_value    code    graph_offset    mode    modes/blend    modes/depth_draw    modes/cull    modes/diffuse    modes/specular    flags/depth_prepass_alpha    flags/depth_test_disabled    flags/sss_mode_skin    flags/unshaded    flags/wireframe    flags/skip_vertex_transform    flags/world_vertex_coords    flags/ensure_correct_normals    flags/shadows_disabled    flags/ambient_light_disabled    flags/shadow_to_opacity    flags/vertex_lighting    flags/particle_trails    flags/alpha_to_coverage     flags/alpha_to_coverage_and_one    flags/debug_shadow_splits    flags/fog_disabled    nodes/vertex/0/position    nodes/vertex/3/node    nodes/vertex/3/position    nodes/vertex/4/node    nodes/vertex/4/position    nodes/vertex/5/node    nodes/vertex/5/position    nodes/vertex/6/node    nodes/vertex/6/position    nodes/vertex/connections    nodes/fragment/0/position    nodes/fragment/2/node    nodes/fragment/2/position    nodes/fragment/3/node    nodes/fragment/3/position    nodes/fragment/4/node    nodes/fragment/4/position    nodes/fragment/5/node    nodes/fragment/5/position    nodes/fragment/6/node    nodes/fragment/6/position    nodes/fragment/7/node    nodes/fragment/7/position    nodes/fragment/8/node    nodes/fragment/8/position    nodes/fragment/9/node    nodes/fragment/9/position    nodes/fragment/10/node    nodes/fragment/10/position    nodes/fragment/12/node    nodes/fragment/12/position    nodes/fragment/13/node    nodes/fragment/13/position    nodes/fragment/14/node    nodes/fragment/14/position    nodes/fragment/15/node    nodes/fragment/15/position    nodes/fragment/16/node    nodes/fragment/16/position    nodes/fragment/17/node    nodes/fragment/17/position    nodes/fragment/18/node    nodes/fragment/18/position    nodes/fragment/connections    nodes/light/0/position    nodes/light/connections    nodes/start/0/position    nodes/start/connections    nodes/process/0/position    nodes/process/connections    nodes/collide/0/position    nodes/collide/connections    nodes/start_custom/0/position    nodes/start_custom/connections     nodes/process_custom/0/position !   nodes/process_custom/connections    nodes/sky/0/position    nodes/sky/connections    nodes/fog/0/position    nodes/fog/connections        $   local://VisualShaderNodeInput_tmsm5 �      ,   local://VisualShaderNodeVectorCompose_7tgk8 /      $   local://VisualShaderNodeInput_p1fcf ]      .   local://VisualShaderNodeVectorDecompose_bma0h �         local://FastNoiseLite_y4co2          local://NoiseTexture2D_tyoyu 9      &   local://VisualShaderNodeTexture_ppk08 h      &   local://VisualShaderNodeFloatOp_7t5tp �      $   local://VisualShaderNodeInput_lv3kc       +   local://VisualShaderNodeUVPolarCoord_aaprt A      (   local://VisualShaderNodeColorFunc_d0b6r �      (   local://VisualShaderNodeFloatFunc_foyjr �      '   local://VisualShaderNodeVectorOp_uf3th 2      '   local://VisualShaderNodeVectorOp_27ury s      -   local://VisualShaderNodeColorParameter_7f1t1 �      (   local://VisualShaderNodeFloatFunc_jvlkp       $   local://VisualShaderNodeInput_07l6u X      .   local://VisualShaderNodeVectorDecompose_5wrli �      &   local://VisualShaderNodeFloatOp_khgf0 �      %   local://VisualShaderNodeUVFunc_nqkr1 $      (   local://VisualShaderNodeFloatFunc_ycdsg K      &   local://VisualShaderNodeFloatOp_m7gtb �      $   res://BloodSplatter/blood_spot.tres �         VisualShaderNodeInput             instance_id          VisualShaderNodeVectorCompose             VisualShaderNodeInput             instance_custom           VisualShaderNodeVectorDecompose                                                         FastNoiseLite    	                            NoiseTexture2D    )                     VisualShaderNodeTexture    +                     VisualShaderNodeFloatOp                                                �@-                  VisualShaderNodeInput             uv          VisualShaderNodeUVPolarCoord                             
      ?   ?           �?                      VisualShaderNodeColorFunc                       VisualShaderNodeFloatFunc              .                  VisualShaderNodeVectorOp              -                  VisualShaderNodeVectorOp    -                  VisualShaderNodeColorParameter    /         ColorParameter 1         2        �?    �Ē=  �?         VisualShaderNodeFloatFunc              .                  VisualShaderNodeInput             color           VisualShaderNodeVectorDecompose             VisualShaderNodeFloatOp                                 )   �������?-                  VisualShaderNodeUVFunc             VisualShaderNodeFloatFunc              .                  VisualShaderNodeFloatOp                    )   �������?             -                  VisualShader .   3      �  shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;

uniform vec4 ColorParameter : source_color = vec4(1.000000, 0.000000, 0.071664, 1.000000);
uniform sampler2D tex_frg_2;



void vertex() {
// Input:3
	int n_out3p0 = INSTANCE_ID;


// Input:5
	vec4 n_out5p0 = INSTANCE_CUSTOM;


// VectorDecompose:6
	float n_out6p0 = n_out5p0.x;
	float n_out6p1 = n_out5p0.y;
	float n_out6p2 = n_out5p0.z;
	float n_out6p3 = n_out5p0.w;


// VectorCompose:4
	float n_in4p2 = 0.00000;
	vec3 n_out4p0 = vec3(float(n_out3p0), n_out6p1, n_in4p2);


// Output:0
	COLOR.rgb = n_out4p0;


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


// FloatFunc:17
	float n_out17p0 = 1.0 - n_out14p1;


// FloatOp:18
	float n_in18p0 = 0.90000;
	float n_out18p0 = n_in18p0 * n_out17p0;


// FloatFunc:12
	float n_out12p0 = 1.0 - n_out8p0.x;


// Output:0
	ALBEDO = n_out9p0;
	ALPHA = n_out18p0;
	ALPHA_SCISSOR_THRESHOLD = n_out12p0;


}
 4   
   ߠ�'�&�M             N   
     ��  �CO            P   
      B  �CQ            R   
     �  �CS            T   
     \�  �CU                                                                V   
    ��D   CW            X   
     HC  �CY            Z   
    @D ��C[            \   
     �  HC]         	   ^   
     �C  �B_         
   `   
     �C  �Ba            b   
     4D  �Bc            d   
     pD ��Ce            f   
    ��D  -Cg            h   
     pD  �Ai            j   
     �D  �Ck            l   
     u�  �Cm            n   
     �  �Co            p   
     ��  �Cq            r   
     ��  �Cs            t   
     \D  MDu            v   
    ��D  CDw       L                                                                                             	      
       	       	                                                                                                                                                              RSRC