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

    var VAO: c_uint = undefined;
    var VBO: c_uint = undefined;
    var EBO: c_uint = undefined;

    gl.genVertexArrays(1, &VAO);
    defer gl.deleteVertexArrays(1, &VAO);

    gl.genBuffers(1, &VBO);
    defer gl.deleteBuffers(1, &VBO);

    gl.genBuffers(1, &EBO);
    defer gl.deleteBuffers(1, &EBO);

    gl.bindVertexArray(VAO);

    gl.bindBuffer(gl.ARRAY_BUFFER, VBO);
    gl.bufferData(gl.ARRAY_BUFFER, @sizeOf(f32) * vertices.len, &vertices, gl.STATIC_DRAW);

    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, EBO);
    gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, @sizeOf(f32) * indices.len, &indices, gl.STATIC_DRAW);

    const beforeVertex = gl.getError();
    if (beforeVertex != gl.NO_ERROR) {
        std.debug.print("error justo antes del vertexAttribPointer {}\n ", .{beforeVertex});
        return;
    }

    // gl.vertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3 * @sizeOf(f32), @as(?*anyopaque, @ptrFromInt(0 * @sizeOf(f32)))); // position
    gl.vertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3 * @sizeOf(f32), null); // position

    // const offset: [*c]c_uint = (3 * @sizeOf(f32));
    // gl.vertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3 * @sizeOf(f32), offset);
    // gl.enableVertexAttribArray(0);

    const beforeAttach = gl.getError();
    if (beforeAttach != gl.NO_ERROR) {
        std.debug.print("error justo luego del vertexAttribPointer {}\n ", .{beforeAttach});
        return;
    }
    gl.enableVertexAttribArray(0);

    gl.bindBuffer(gl.ARRAY_BUFFER, 0);
    gl.bindVertexArray(0);
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0);

    // const offset: [*c]c_uint = (3 * @sizeOf(f32));
    // gl.vertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, 6 * @sizeOf(f32), offset);
    // gl.enableVertexAttribArray(1);

    gl.clearColor(0.0, 0.0, 0.0, 1.0);
    // gl.viewport(0, 0, 1600, 900); // Render on the whole framebuffer, complete from the lower left corner to the upper right
    const beforeWhileError = gl.getError();
    if (beforeWhileError != gl.NO_ERROR) {
        std.debug.print("error antes del while {}\n", .{beforeWhileError});
        return;
    }

    while (!window.shouldClose()) {
        // gl.clearBufferfv(gl.COLOR, 0, &[_]f32{ 0.0, 0.0, 0.0, 0.0 });
        gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
        gl.useProgram(shaderProgram);
        gl.bindVertexArray(VAO);
        gl.drawElements(gl.TRIANGLES, @intCast(indices.len), gl.UNSIGNED_INT, null);
        glfw.pollEvents();
        window.swapBuffers();
        const erro2r_ = gl.getError();
        if (erro2r_ != gl.NO_ERROR) {
            std.debug.print("\nhubo un error {} \n", .{erro2r_});
            return;
        }
    }
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
