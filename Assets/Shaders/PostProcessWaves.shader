// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/PostProcessWaves"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Frequency ("Frequency", Float) = 150
        _Phase ("Phase", Float) = 0
        _hDivisions ("Line Divisions", Float) = 30
    }

    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #include "UnityCG.cginc"

            static const float PI = 3.14159265f;
 
            struct appdata_t
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 texcoord : TEXCOORD0;
            };
             
            struct v2f
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 texcoord : TEXCOORD0;
                float2 screenpos : TEXCOORD1;
            };
            
            uniform sampler2D _MainTex;
            float _Intensity;
            float _Frequency;
            float _Phase;
            float _hDivisions;

            float mapRange(float a, float b, float c, float d, float t) { return lerp(c, d, (t-a)/(b-a)); }
            
            v2f vert(appdata_t IN)
            {
                v2f OUT;
                OUT.vertex = UnityObjectToClipPos(IN.vertex);
                OUT.texcoord = IN.texcoord;
                OUT.color = IN.color;
                OUT.screenpos = ComputeScreenPos(OUT.vertex);
                 
                return OUT;
            }
            
            fixed4 frag (v2f i) : COLOR
            {
                float4 c = tex2D(_MainTex, i.texcoord);
                float4 result = c;
                
                // calculate the grayscale of the pixel, with the correct scale for each colour
                float lum = c.r*.3 + c.g*.59 + c.b*.11;

                // animate the waves
                _Phase = _Phase + _Time.w*2;
                
                // calculate the base y position for each division
                float hDivisionSize = 1 / _hDivisions;
                float maxAmp = hDivisionSize/2;
                float currentDivision = floor(mapRange(0, 1, 0, _hDivisions, i.screenpos.y));
                float y = (hDivisionSize/2) + (currentDivision * hDivisionSize);

                // calculate the y position of the pixel
                float angle = mapRange( 0, 1, 0, PI*2, i.screenpos.x);
                float sinValue = sin(_Phase + angle * _Frequency);
                float amplitude = mapRange(0, 1, 0, maxAmp, lum);
                float ypos = y + sinValue*amplitude;
                
                //render the wave lines
                UNITY_FLATTEN if(i.screenpos.y > (ypos-(0.001+0.0001*(0.2*_Frequency))) && i.screenpos.y < (ypos+(0.001+0.0001*(0.2*_Frequency))))
                {
                    result.rgb = 1;
                }
                else
                {
                    result.rgb = 0;
                }

                // to visualize the division lines
                //UNITY_FLATTEN if (i.screenpos.y > y-0.001 && i.screenpos.y < y+0.001)
                //{
                //    result.rgb = float3(0, 0, 0);
                //}

                // just to check values if we need
                //result.r = y; //mapRange(0, _hDivisions, 0, 1, currentDivision);
                //result.gb = 0;
                
                return result;
            }

            ENDCG
        }
    }
}
