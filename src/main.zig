const std = @import("std");
const mem = std.mem;
const glfw = @import("zglfw");
const gl = @import("gl");
const utils = @import("structs.zig");

pub const Error = error{
    FailedToInitializeSDL2Window,
    FailedToLoadTextureFile,
    FailedToCompileAndLinkShader,
    FailedToRetrieveShaderLocation,
    FailedToRetrieveUniformBlockIndex,
    FailedToDeserializeMapGeometry,
    OutOfAvailableUboBindingPoints,
};

pub fn main() !void {
    try glfw.init();
    defer glfw.terminate();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    const gl_major = 4;
    const gl_minor = 0;
    glfw.windowHintTyped(.context_version_major, gl_major);
    glfw.windowHintTyped(.context_version_minor, gl_minor);
    glfw.windowHintTyped(.opengl_profile, .opengl_core_profile);
    glfw.windowHintTyped(.opengl_forward_compat, true);
    glfw.windowHintTyped(.client_api, .opengl_api);
    glfw.windowHintTyped(.doublebuffer, true);

    var window = try glfw.Window.create(1600, 900, "GLFW & OpenGL Learning", null);
    defer window.destroy();

    glfw.makeContextCurrent(window);

    try gl.load({}, getProcAddress);

    var vertices = [_]f32{
        -0.70, 0.70, 0.0, 0.0, // topleft vert
        0.70, 0.70, 1.0, 0.0, // topright vert
        0.70, -0.70, 1.0, 1.0, // bottomright vert
        -0.70, -0.70, 0.0, 1.0, // bottomright vert
    };
    var indices = [_]i32{
        0, 2, 4,
        0, 6, 4,
    };

    const vertexShader: [*:0]const u8 = @embedFile("./vertex_shader_source.vert");
    const firstError = gl.getError();
    if (firstError != gl.NO_ERROR) {
        std.debug.print("primer error {}, antes del programa\n", .{firstError});
        return;
    }

    const shaderProgram: c_uint = gl.createProgram();
    defer gl.deleteProgram(shaderProgram);

    const segundo = gl.getError();
    if (segundo != gl.NO_ERROR) {
        std.debug.print("segundo error aca {}, luego de crear el programa\n", .{segundo});
        return;
    }

    const vertexShaderId = try compileShader(gpa.allocator(), gl.VERTEX_SHADER, vertexShader);
    errdefer gl.deleteShader(vertexShaderId);

    const fragmentShader: [*:0]const u8 = @embedFile("./fragment_shader_source.frag");
    const fragShaderId = try compileShader(gpa.allocator(), gl.FRAGMENT_SHADER, fragmentShader);
    errdefer gl.deleteShader(fragShaderId);

    std.debug.print("this is the program ID: {}\n", .{shaderProgram});

    gl.attachShader(shaderProgram, vertexShaderId);
    gl.attachShader(shaderProgram, fragShaderId);

    gl.linkProgram(shaderProgram);

    var VAO = utils.VAO{};
    var VBO = utils.VBO{};
    var EBO = utils.EBO{};

    var texture = try utils.Texture.new("test.png");

    VAO.initVAO();
    defer VAO.delete();

    try VBO.initBuffer(f32, &vertices, &VAO);
    try EBO.initBuffer(i32, &indices, &VAO);

    texture.bind(null);
    defer texture.unBind();

    const beforeVertex = gl.getError();
    if (beforeVertex != gl.NO_ERROR) {
        std.debug.print("error justo antes del vertexAttribPointer {}\n ", .{beforeVertex});
        return;
    }

    VAO.linkVBO(&VBO, 0, 2, gl.FLOAT, 2 * @sizeOf(f32), null);
    VAO.linkVBO(&VBO, 1, 2, gl.FLOAT, 2 * @sizeOf(f32), @ptrFromInt(2 * @sizeOf(f32)));

    const beforeAttach = gl.getError();
    if (beforeAttach != gl.NO_ERROR) {
        std.debug.print("error justo luego del vertexAttribPointer {}\n ", .{beforeAttach});
        return;
    }
    gl.useProgram(shaderProgram);
    const uniformId = gl.getUniformLocation(shaderProgram, "u_Color");
    gl.uniform4f(uniformId, 0.2, 0.2, 0.2, 1.0);

    const textureUniform = gl.getUniformLocation(shaderProgram, "u_Texture");
    gl.uniform1i(textureUniform, 0);

    VAO.unBind();
    VBO.unBind();
    EBO.unBind();

    var Renderer = utils.Renderer{
        .vertices = &vertices,
        .indices = &indices,
        .window = window,
        .shaderProgram = shaderProgram,
        .vao = &VAO,
    };

    try Renderer.draw();
}

fn compileShader(allocator: std.mem.Allocator, shader_type: c_uint, source: [*:0]const u8) !c_uint {
    const shader = gl.createShader(shader_type);
    if (shader == 0) {
        return Error.FailedToCompileAndLinkShader;
    }
    errdefer gl.deleteShader(shader);
    gl.shaderSource(shader, 1, &source, null);
    gl.compileShader(shader);

    var status: c_int = undefined;
    gl.getShaderiv(shader, gl.COMPILE_STATUS, &status);
    if (status != gl.FALSE) {
        std.debug.print("this is the shader value: {}\n", .{shader});
        return shader;
    }

    var buffer_length: c_int = undefined;
    gl.getShaderiv(shader, gl.INFO_LOG_LENGTH, &buffer_length);

    var buffer = try allocator.alloc(u8, @intCast(buffer_length));
    defer allocator.free(buffer);

    var string_length: c_int = undefined;
    gl.getShaderInfoLog(shader, @intCast(buffer.len), &string_length, buffer.ptr);

    std.log.err("failed to compile shader: {s}", .{buffer[0..@intCast(string_length)]});

    return Error.FailedToCompileAndLinkShader;
}

fn getProcAddress(_: void, name: [:0]const u8) ?*anyopaque {
    const proc = glfw.getProcAddress(name);
    return @as(?*anyopaque, @ptrFromInt(@intFromPtr(proc)));
}

fn framebuffer_size_callback(window: glfw.Window, width: u32, height: u32) void {
    _ = window;
    gl.viewport(0, 0, @intCast(width), @intCast(height));
}
