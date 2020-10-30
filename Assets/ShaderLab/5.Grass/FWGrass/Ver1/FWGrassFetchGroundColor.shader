// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "FWGrassFetchGroundColor"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		_MainTex("_MainTex", 2D) = "white" {}
		_WindDir("风向", Vector) = (1,0,1,0)
		_TextureSample0("风噪图", 2D) = "white" {}
		_WindSpeed("风速", Range( 0 , 10)) = 1.5
		_WindWaveDensity("风波频率", Range( 0 , 10)) = 4.294952
		_WindTintStrength("草地风浪着色强度", Range( 0 , 2)) = 1
		_Top("顶色", Color) = (0.9150943,0.7514122,0.2115077,1)
		_GrassPeakColorFactor("草色混合系数", Range( 0 , 1)) = 0.55
		_GroundPeakColorFactor1("地面色混合系数", Range( 0 , 1)) = 0.55
		_Root("底色", Color) = (0.169,0.468,0.07164473,1)
		_WindStrength("风强", Float) = 0.12
		_Float3("Y方向顶点下沉系数", Range( 0 , 1.5)) = 0
		_NoWindOffset("无风自动距离(默认Sin)", Vector) = (1,1,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
		
		Cull Off
		HLSLINCLUDE
		#pragma target 2.0
		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }
			
			Blend SrcAlpha OneMinusSrcAlpha , One OneMinusSrcAlpha
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			#pragma multi_compile_instancing
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 999999

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			#if ASE_SRP_VERSION <= 70108
			#define REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
			#endif

			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef ASE_FOG
				float fogFactor : TEXCOORD2;
				#endif
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _TextureSample0;
			sampler2D _GroundTexture;
			float3 _GroundPosition;
			sampler2D _MainTex;
			CBUFFER_START( UnityPerMaterial )
			float2 _NoWindOffset;
			float _WindWaveDensity;
			float _WindSpeed;
			float3 _WindDir;
			float _WindStrength;
			float _Float3;
			float _WindTintStrength;
			float4 _Root;
			float4 _Top;
			float _GrassPeakColorFactor;
			float _GroundPeakColorFactor1;
			float4 _MainTex_ST;
			CBUFFER_END


			
			VertexOutput vert ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float2 uv0341 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float2 appendResult6_g15 = (float2(ase_worldPos.x , ase_worldPos.z));
				float temp_output_21_0_g15 = ( _WindWaveDensity * 0.01 );
				float2 appendResult22_g15 = (float2(_WindDir.x , _WindDir.z));
				float2 normalizeResult31_g15 = normalize( appendResult22_g15 );
				float4 break334 = tex2Dlod( _TextureSample0, float4( ( ( appendResult6_g15 * temp_output_21_0_g15 ) + -( temp_output_21_0_g15 * _WindSpeed * ( _TimeParameters.x ) * normalizeResult31_g15 ) ), 0, 0.0) );
				float2 appendResult360 = (float2(break334.r , break334.b));
				float2 break391 = ( ( 0.1 * ( sin( ( _TimeParameters.y * _NoWindOffset ) ) + 2.0 ) * uv0341.y ) + ( uv0341.y * appendResult360 * _WindStrength ) );
				float2 uv0354 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float3 appendResult340 = (float3(break391.x , ( break334.g * -_Float3 * uv0354.y ) , break391.y));
				float4 transform363 = mul(GetWorldToObjectMatrix(),float4( appendResult340 , 0.0 ));
				
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = transform363.xyz;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				#ifdef ASE_FOG
				o.fogFactor = ComputeFogFactor( positionCS.z );
				#endif
				o.clipPos = positionCS;
				return o;
			}

			half4 frag ( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif
				float2 appendResult6_g16 = (float2(WorldPosition.x , WorldPosition.z));
				float temp_output_21_0_g16 = ( _WindWaveDensity * 0.01 );
				float2 appendResult22_g16 = (float2(_WindDir.x , _WindDir.z));
				float2 normalizeResult31_g16 = normalize( appendResult22_g16 );
				float4 matrixToPos448 = float4( float4x4( 1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1 )[3][0],float4x4( 1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1 )[3][1],float4x4( 1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1 )[3][2],float4x4( 1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1 )[3][3]);
				float4 transform450 = mul(GetObjectToWorldMatrix(),matrixToPos448);
				float4 break446 = ( transform450 - float4( _GroundPosition , 0.0 ) );
				float2 appendResult447 = (float2(break446.x , break446.z));
				float4 appendResult169 = (float4(_Root.r , _Root.g , _Root.b , 0.0));
				float4 appendResult170 = (float4(_Top.r , _Top.g , _Top.b , 0.0));
				float4x4 break192 = GetObjectToWorldMatrix();
				float temp_output_174_0 = frac( ( break192[ 0 ][ 3 ] + break192[ 1 ][ 3 ] + break192[ 2 ][ 3 ] + break192[ 3 ][ 3 ] ) );
				float4 lerpResult166 = lerp( appendResult169 , appendResult170 , ( ( IN.ase_texcoord3.xy.y + (-1.0 + (_GrassPeakColorFactor - 0.0) * (0.0 - -1.0) / (1.0 - 0.0)) ) * temp_output_174_0 ));
				float4 lerpResult453 = lerp( tex2D( _GroundTexture, ( appendResult447 / float2( 10,10 ) ) ) , lerpResult166 , _GroundPeakColorFactor1);
				float2 uv_MainTex = IN.ase_texcoord3.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode47 = tex2D( _MainTex, uv_MainTex );
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( ( tex2D( _TextureSample0, ( ( appendResult6_g16 * temp_output_21_0_g16 ) + -( temp_output_21_0_g16 * _WindSpeed * ( _TimeParameters.x ) * normalizeResult31_g16 ) ) ) * _WindTintStrength * 0.07 ) + ( lerpResult453 * tex2DNode47 ) ).rgb;
				float Alpha = tex2DNode47.a;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				return half4( Color, Alpha );
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual

			HLSLPROGRAM
			#pragma multi_compile_instancing
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 999999

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex ShadowPassVertex
			#pragma fragment ShadowPassFragment

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _TextureSample0;
			sampler2D _MainTex;
			CBUFFER_START( UnityPerMaterial )
			float2 _NoWindOffset;
			float _WindWaveDensity;
			float _WindSpeed;
			float3 _WindDir;
			float _WindStrength;
			float _Float3;
			float _WindTintStrength;
			float4 _Root;
			float4 _Top;
			float _GrassPeakColorFactor;
			float _GroundPeakColorFactor1;
			float4 _MainTex_ST;
			CBUFFER_END


			
			float3 _LightDirection;

			VertexOutput ShadowPassVertex( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float2 uv0341 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float2 appendResult6_g15 = (float2(ase_worldPos.x , ase_worldPos.z));
				float temp_output_21_0_g15 = ( _WindWaveDensity * 0.01 );
				float2 appendResult22_g15 = (float2(_WindDir.x , _WindDir.z));
				float2 normalizeResult31_g15 = normalize( appendResult22_g15 );
				float4 break334 = tex2Dlod( _TextureSample0, float4( ( ( appendResult6_g15 * temp_output_21_0_g15 ) + -( temp_output_21_0_g15 * _WindSpeed * ( _TimeParameters.x ) * normalizeResult31_g15 ) ), 0, 0.0) );
				float2 appendResult360 = (float2(break334.r , break334.b));
				float2 break391 = ( ( 0.1 * ( sin( ( _TimeParameters.y * _NoWindOffset ) ) + 2.0 ) * uv0341.y ) + ( uv0341.y * appendResult360 * _WindStrength ) );
				float2 uv0354 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float3 appendResult340 = (float3(break391.x , ( break334.g * -_Float3 * uv0354.y ) , break391.y));
				float4 transform363 = mul(GetWorldToObjectMatrix(),float4( appendResult340 , 0.0 ));
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = transform363.xyz;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				float3 normalWS = TransformObjectToWorldDir( v.ase_normal );

				float4 clipPos = TransformWorldToHClip( ApplyShadowBias( positionWS, normalWS, _LightDirection ) );

				#if UNITY_REVERSED_Z
					clipPos.z = min(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
				#else
					clipPos.z = max(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				o.clipPos = clipPos;

				return o;
			}

			half4 ShadowPassFragment(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_MainTex = IN.ase_texcoord2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode47 = tex2D( _MainTex, uv_MainTex );
				
				float Alpha = tex2DNode47.a;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0

			HLSLPROGRAM
			#pragma multi_compile_instancing
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 999999

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _TextureSample0;
			sampler2D _MainTex;
			CBUFFER_START( UnityPerMaterial )
			float2 _NoWindOffset;
			float _WindWaveDensity;
			float _WindSpeed;
			float3 _WindDir;
			float _WindStrength;
			float _Float3;
			float _WindTintStrength;
			float4 _Root;
			float4 _Top;
			float _GrassPeakColorFactor;
			float _GroundPeakColorFactor1;
			float4 _MainTex_ST;
			CBUFFER_END


			
			VertexOutput vert( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float2 uv0341 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float2 appendResult6_g15 = (float2(ase_worldPos.x , ase_worldPos.z));
				float temp_output_21_0_g15 = ( _WindWaveDensity * 0.01 );
				float2 appendResult22_g15 = (float2(_WindDir.x , _WindDir.z));
				float2 normalizeResult31_g15 = normalize( appendResult22_g15 );
				float4 break334 = tex2Dlod( _TextureSample0, float4( ( ( appendResult6_g15 * temp_output_21_0_g15 ) + -( temp_output_21_0_g15 * _WindSpeed * ( _TimeParameters.x ) * normalizeResult31_g15 ) ), 0, 0.0) );
				float2 appendResult360 = (float2(break334.r , break334.b));
				float2 break391 = ( ( 0.1 * ( sin( ( _TimeParameters.y * _NoWindOffset ) ) + 2.0 ) * uv0341.y ) + ( uv0341.y * appendResult360 * _WindStrength ) );
				float2 uv0354 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float3 appendResult340 = (float3(break391.x , ( break334.g * -_Float3 * uv0354.y ) , break391.y));
				float4 transform363 = mul(GetWorldToObjectMatrix(),float4( appendResult340 , 0.0 ));
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = transform363.xyz;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				o.clipPos = TransformWorldToHClip( positionWS );
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				return o;
			}

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_MainTex = IN.ase_texcoord2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode47 = tex2D( _MainTex, uv_MainTex );
				
				float Alpha = tex2DNode47.a;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}
			ENDHLSL
		}

	
	}
	CustomEditor "UnityEditor.ShaderGraph.PBRMasterGUI"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=18000
2564;162;2560;976;2889.617;471.9248;1.3;True;True
Node;AmplifyShaderEditor.CommentaryNode;392;-1743.674,-178.8873;Inherit;False;1052.294;356.7249;无风时视为有微风, 草轻微晃动;8;385;370;373;378;371;381;387;386;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SinTimeNode;381;-1614.696,-128.8873;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;371;-1693.674,13.83769;Inherit;False;Property;_NoWindOffset;无风自动距离(默认Sin);14;0;Create;False;0;0;False;0;1,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;378;-1452.081,-34.09312;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;457;-2082.568,611.5864;Inherit;True;GustTint;1;;15;019ff3f718d9a00408e2bfd223fd1cb8;0;0;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;386;-1185.879,47.10507;Inherit;False;Constant;_Float4;Float 4;10;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;366;-1373.86,199.4912;Inherit;False;693.7967;401.4466;XZ方向噪声图偏移量;4;349;341;360;362;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SinOpNode;373;-1292.193,-30.94279;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;334;-1813.597,617.7966;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleAddOpNode;385;-1033.456,-33.52446;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;360;-1286.402,419.791;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;387;-1084.785,-110.5424;Inherit;False;Constant;_Float5;Float 5;10;0;Create;True;0;0;False;0;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;349;-1298.667,517.94;Inherit;False;Property;_WindStrength;风强;11;0;Create;False;0;0;False;0;0.12;-0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;341;-1310.86,266.4377;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;370;-853.3797,-57.76962;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;362;-816.2091,377.0957;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;365;-1752.314,833.9737;Inherit;False;Property;_Float3;Y方向顶点下沉系数;12;0;Create;False;0;0;False;0;0;0;0;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;354;-1304.663,925.2936;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;390;-455.7662,41.53282;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NegateNode;388;-1262.732,840.252;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;384;-989.9697,783.6489;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;391;-330.9663,44.13282;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.CommentaryNode;141;-1469.355,-530.3478;Inherit;False;761.2413;290.6606;TextureMapping;2;47;48;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;205;-1496.509,-1359.355;Inherit;False;784.8807;799.1548;ColorMapping;12;166;142;169;171;172;206;190;208;207;50;170;165;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;194;-2428.712,-1356.64;Inherit;False;906.9198;523.2603;利用M矩阵分量生成基于位置的, 针对所有顶点的随机值;5;189;191;193;192;174;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;340;28.36166,27.30478;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;335;1304.21,-39.39701;Inherit;False;592.7019;302;物件世界坐标提取XZ分量;2;337;336;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;48;-1421.356,-480.3479;Inherit;True;Property;_MainTex;_MainTex;0;0;Create;True;0;0;False;0;baac77a69801b814db973a5b99aa0733;baac77a69801b814db973a5b99aa0733;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.CommentaryNode;444;-2131.049,-1913.719;Inherit;False;1975.652;512.3893;求草在地块中的相对位置;9;450;448;434;437;446;447;442;443;452;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;427;527.1788,-877.3125;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;450;-1917.149,-1850.568;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FractNode;174;-1762.08,-1002.148;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;50;-1400.409,-1326.055;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;165;-1473.74,-751.7795;Inherit;False;Property;_Top;顶色;7;0;Create;False;0;0;False;0;0.9150943,0.7514122,0.2115077,1;0.9150943,0.7514122,0.2115077,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;319;797.9788,-718.0126;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;315;125.9698,-695.6484;Inherit;False;Constant;_Float2;Float 2;6;0;Create;True;0;0;False;0;0.07;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;169;-1186.702,-882.5849;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;453;-278.0148,-873.2224;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;443;-1731.705,-1660.792;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.PosVertexDataNode;336;1310.12,5.603099;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;447;-1315.586,-1561.779;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;170;-1190.19,-723.3397;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;172;-1484.972,-1205.288;Inherit;False;Property;_GrassPeakColorFactor;草色混合系数;8;0;Create;False;0;0;False;0;0.55;0.55;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;47;-1188.187,-482.3849;Inherit;True;Property;_TextureSample0;Texture Sample 0;2;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;192;-2200.956,-1293.979;Inherit;False;FLOAT4x4;1;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;207;-1452.102,-1125.14;Inherit;False;Constant;_Float0;Float 0;5;0;Create;True;0;0;False;0;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;454;-610.0294,-789.2119;Inherit;False;Property;_GroundPeakColorFactor1;地面色混合系数;9;0;Create;False;0;0;False;0;0.55;0.55;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RoundOpNode;189;-1662.091,-1265.04;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;200;693.1121,-412.4238;Inherit;False;Constant;_ClipThreshold;ClipThreshold;4;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;142;-1473.361,-926.1525;Inherit;False;Property;_Root;底色;10;0;Create;False;0;0;False;0;0.169,0.468,0.07164473,1;0.169,0.468,0.07164473,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;446;-1538.586,-1573.779;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;208;-1447.402,-1048.14;Inherit;False;Constant;_Float1;Float 1;5;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;337;1485.87,4.815985;Inherit;True;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;143;-156.1582,-523.4986;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;437;-888.3242,-1709.666;Inherit;True;Property;_TextureSample1;Texture Sample 1;13;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;206;-1188.16,-1200.365;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;193;-1935.184,-1287.239;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;190;-1020.502,-1025.265;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;434;-1194.655,-1792.813;Inherit;True;Global;_GroundTexture;_GroundTexture;13;0;Create;True;0;0;False;0;None;;True;bump;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.LerpOp;166;-885.8469,-851.3373;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ObjectToWorldMatrixNode;191;-2378.712,-1288.578;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.Vector3Node;442;-1999.837,-1612.098;Inherit;False;Global;_GroundPosition;_GroundPosition;15;0;Create;True;0;0;False;0;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;171;-983.6301,-1260.701;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosFromTransformMatrix;448;-2117.013,-1858;Inherit;False;1;0;FLOAT4x4;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;452;-1056.809,-1537.837;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;10,10;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldToObjectTransfNode;363;313.0105,-9.231208;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;458;118.6968,-993.9148;Inherit;True;GustTint;1;;16;019ff3f718d9a00408e2bfd223fd1cb8;0;0;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;426;65.89661,-802.1149;Inherit;False;Property;_WindTintStrength;草地风浪着色强度;6;0;Create;False;0;0;False;0;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;419;1359.67,-388.5227;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;420;1359.67,-388.5227;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;418;1359.67,-388.5227;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;416;1359.67,-388.5227;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;417;1695.593,-618.4207;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;FWGrassFetchGroundColor;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;7;False;False;False;True;2;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;0;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;11;Surface;1;  Blend;0;Two Sided;0;Cast Shadows;1;Receive Shadows;1;GPU Instancing;1;LOD CrossFade;0;Built-in Fog;0;Meta Pass;0;Extra Pre Pass;0;Vertex Position,InvertActionOnDeselection;1;0;5;False;True;True;True;False;False;;0
WireConnection;378;0;381;4
WireConnection;378;1;371;0
WireConnection;373;0;378;0
WireConnection;334;0;457;0
WireConnection;385;0;373;0
WireConnection;385;1;386;0
WireConnection;360;0;334;0
WireConnection;360;1;334;2
WireConnection;370;0;387;0
WireConnection;370;1;385;0
WireConnection;370;2;341;2
WireConnection;362;0;341;2
WireConnection;362;1;360;0
WireConnection;362;2;349;0
WireConnection;390;0;370;0
WireConnection;390;1;362;0
WireConnection;388;0;365;0
WireConnection;384;0;334;1
WireConnection;384;1;388;0
WireConnection;384;2;354;2
WireConnection;391;0;390;0
WireConnection;340;0;391;0
WireConnection;340;1;384;0
WireConnection;340;2;391;1
WireConnection;427;0;458;0
WireConnection;427;1;426;0
WireConnection;427;2;315;0
WireConnection;450;0;448;0
WireConnection;174;0;193;0
WireConnection;319;0;427;0
WireConnection;319;1;143;0
WireConnection;169;0;142;1
WireConnection;169;1;142;2
WireConnection;169;2;142;3
WireConnection;453;0;437;0
WireConnection;453;1;166;0
WireConnection;453;2;454;0
WireConnection;443;0;450;0
WireConnection;443;1;442;0
WireConnection;447;0;446;0
WireConnection;447;1;446;2
WireConnection;170;0;165;1
WireConnection;170;1;165;2
WireConnection;170;2;165;3
WireConnection;47;0;48;0
WireConnection;192;0;191;0
WireConnection;189;0;174;0
WireConnection;446;0;443;0
WireConnection;337;0;336;0
WireConnection;143;0;453;0
WireConnection;143;1;47;0
WireConnection;437;0;434;0
WireConnection;437;1;452;0
WireConnection;206;0;172;0
WireConnection;206;3;207;0
WireConnection;206;4;208;0
WireConnection;193;0;192;3
WireConnection;193;1;192;7
WireConnection;193;2;192;11
WireConnection;193;3;192;15
WireConnection;190;0;171;0
WireConnection;190;1;174;0
WireConnection;166;0;169;0
WireConnection;166;1;170;0
WireConnection;166;2;190;0
WireConnection;171;0;50;2
WireConnection;171;1;206;0
WireConnection;452;0;447;0
WireConnection;363;0;340;0
WireConnection;417;2;319;0
WireConnection;417;3;47;4
WireConnection;417;4;200;0
WireConnection;417;5;363;0
ASEEND*/
//CHKSM=2A62D56BDEA91B9A9DA073645E7581F3963BF741