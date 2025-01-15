#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

[[ stitchable ]] half4 circleMesh(float2 position,
                                  half4 color,
                                  float4 bounds,
								  float cols,
								  float timeScale,
                                  float secs) {
    float PI2 = 6.2831853071795864769252867665590;

    vector_float2 uv = position/bounds.zw;

    float circle_rows = (cols * bounds.w) / bounds.z;
    float scaledTime = secs * timeScale / 10;

    float circle = -cos((uv.x - scaledTime) * PI2 * cols) * cos((uv.y + scaledTime) * PI2 * circle_rows);
    float stepCircle = step(circle, -sin(secs + uv.x - uv.y));

    vector_float4 background = vector_float4(0, 0, 0, 0);
    vector_float4 circles = vector_float4(color.x, color.y, color.z, color.w);

    return half4(mix(background, circles, stepCircle));
}
