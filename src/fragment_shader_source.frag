#version 330 core
#extension GL_ARB_separate_shader_objects : enable

layout (location = 0) out vec4 color;

in vec2 v_TexCoord;
out vec4 FragColor;

uniform sampler2D u_Texture;
uniform vec4 u_Color;

void main() {
	vec4 texColor = texture(u_Texture, v_TexCoord);
	color = texColor;
}
