Shader "Custom/VertexLit"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Min ("Min angle", Range(-1,1)) = 0.0
        _Max ("Max angle", Range(-1,1)) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model
        #pragma surface surf Standard noforwardadd vertex:vert

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            fixed highlight;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float _Min;
        float _Max;

        void vert (inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            float4 posWorld = mul(unity_ObjectToWorld, v.vertex);
            float3 normalWorld = UnityObjectToWorldNormal(v.normal);
            float3 lightPos =
                float3(
                    unity_4LightPosX0.x,
                    unity_4LightPosX0.y,
                    unity_4LightPosX0.z);
            float3 lightVector = normalize(lightPos - posWorld.xyz);
            o.highlight = dot(lightVector, normalWorld);
        }

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Emission =
                unity_LightColor[0].rgb *
                smoothstep(_Min, _Max, IN.highlight);

            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
