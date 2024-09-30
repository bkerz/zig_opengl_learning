const std = @import("std");
const mem = std.mem;
const glfw = @import("zglfw");
const zopengl = @import("zopengl");

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

    const window = try glfw.Window.create(1600, 900, "GLFW & OpenGL Learning", null);
    defer window.destroy();

    glfw.makeContextCurrent(window);

    try zopengl.loadCoreProfile(glfw.getProcAddress, gl_major, gl_minor);

    const gl = zopengl.bindings;

    // const vertices = [_]gl.Float{
    //     -0.5, -0.5, 0.0, 1.0, 0.0, 0.0,
    //     0.5,  -0.5, 0.0, 0.0, 1.0, 0.0,
    //     0.0,  0.5,  0.0, 0.0, 0.0, 1.0,
    // };
    // const vertices = [_]gl.Float{
    //     -1.0, 1.0, -0.0, // topleft vert
    //     1.0, 1.0, -0.0, // topright vert
    //     1.0, -1.0, -0.0, // bottomright vert
    //     -1.0, -1.0, -0.0, // bottomleft vert
    // };
    const vertices = [_]f32{
        -0.5, -0.5, 0.0, 1.0, 0.0, 0.0,
        0.5,  -0.5, 0.0, 0.0, 1.0, 0.0,
        0.0,  0.5,  0.0, 0.0, 0.0, 1.0,
    };

    const vertexShader: [*:0]const u8 = @embedFile("./vertex_shader_source.vert");
    const firstError = gl.getError();
    if (firstError != gl.NO_ERROR) {
        std.debug.print("primer error {}, antes del programa\n", .{firstError});
        return;
    }

    const shaderProgram: gl.Uint = gl.createProgram();
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

    gl.genVertexArrays(1, &VAO);
    defer gl.deleteVertexArrays(1, &VAO);

    gl.genBuffers(1, &VBO);
    defer gl.deleteBuffers(1, &VBO);

    gl.bindBuffer(gl.ARRAY_BUFFER, VBO);

    // gl.bufferData(gl.ARRAY_BUFFER, vertices.len, &vertices, gl.STATIC_DRAW);
    // gl.bufferData(gl.ARRAY_BUFFER, @sizeOf(f32) * vertices.len, &vertices, gl.STATIC_DRAW);
    gl.bufferData(gl.ARRAY_BUFFER, vertices.len * @sizeOf(f32), &vertices, gl.STATIC_DRAW);
    // const stride: c_int = @intCast(@sizeOf(f64));
    // const currentOffset = @sizeOf(bool);
    const beforeVertex = gl.getError();
    if (beforeVertex != gl.NO_ERROR) {
        std.debug.print("error justo antes del vertexAttribPointer {}\n ", .{beforeVertex});
        return;
    }

    gl.vertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 6 * @sizeOf(f32), null);
    gl.enableVertexAttribArray(0);

    const offset: [*c]c_uint = (3 * @sizeOf(f32));
    gl.vertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 6 * @sizeOf(f32), offset);
    gl.enableVertexAttribArray(0);

    const beforeAttach = gl.getError();
    if (beforeAttach != gl.NO_ERROR) {
        std.debug.print("error justo luego del vertexAttribPointer {}\n ", .{beforeAttach});
        return;
    }

    // const offset: [*c]c_uint = (3 * @sizeOf(f32));
    // gl.vertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, 6 * @sizeOf(f32), offset);
    // gl.enableVertexAttribArray(1);

    gl.bindVertexArray(VAO);

    gl.clearColor(1.0, 0.0, 0.0, 1.0);
    gl.viewport(0, 0, 1600, 900); // Render on the whole framebuffer, complete from the lower left corner to the upper right
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
        gl.drawArrays(gl.TRIANGLES, 0, 3);
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
    const gl = zopengl.bindings;
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

fn triangle(window: glfw.Window, gl: zopengl.bindings, shaderProgram: c_int) !void {
    // defer glfw.terminate();
    // defer window.destroy();
    // window.setUserPointer(&input_manager);
    // window.setKeyCallback(Input.InputManager.keyPressCallback);
    // window.setScrollCallback(Input.InputManager.scrollBackCallback);

    // const proc: glfw.GLProc = undefined;
    // try gl.load(proc, getProcAddress);
    //
    // camera = Camera{
    //     .aspect_ratio = 16.0 / 9.0,
    //     .screen_width = 1920,
    //     .samples_per_pixel = 1,
    //     .max_bounces = 50,
    //     .position = Vec3f.new(0, 0, -5),
    // };
    // input_manager = Input.InputManager{};
    // shader = ShaderProgram{};
    // try shader.compile(alloc);
    const vertices = [12]f32{
        -1.0, 1.0, -0.0, // topleft vert
        1.0, 1.0, -0.0, // topright vert
        1.0, -1.0, -0.0, // bottomright vert
        -1.0, -1.0, -0.0, // bottomleft vert
    };
    const indices = [6]u32{
        0, 1, 2, 2, 3, 0,
    };
    var vao: u32 = undefined;
    gl.genVertexArrays(1, &vao);
    defer gl.deleteVertexArrays(1, &vao);

    var vbo: u32 = undefined;
    gl.genBuffers(1, &vbo);
    defer gl.deleteBuffers(1, &vbo);

    var ebo: u32 = undefined;
    gl.genBuffers(1, &ebo);
    defer gl.deleteBuffers(1, &ebo);

    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo);
    gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, indices.len * @sizeOf(u32), indices[0..].ptr, gl.STATIC_DRAW);

    gl.bindVertexArray(vao);

    gl.bindBuffer(gl.ARRAY_BUFFER, vbo);
    gl.bufferData(gl.ARRAY_BUFFER, vertices.len * @sizeOf(f32), vertices[0..].ptr, gl.STATIC_DRAW);

    gl.vertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3 * @sizeOf(f32), null);
    gl.enableVertexAttribArray(0);

    gl.bindBuffer(gl.ARRAY_BUFFER, 0);
    gl.bindVertexArray(0);

    var frame_buffer_name: u32 = 0;
    gl.genFramebuffers(1, &frame_buffer_name);
    gl.bindFramebuffer(gl.FRAMEBUFFER, frame_buffer_name);

    // The texture we're going to render to
    // var rendered_texture: u32 = 0;
    // gl.genTextures(1, &rendered_texture);

    // "Bind" the newly created texture : all future texture functions will modify this texture
    // gl.bindTexture(gl.TEXTURE_2D, rendered_texture);

    // Give an empty image to OpenGL ( the last "0" )
    // gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGB, 1024, 768, 0, gl.RGB, gl.UNSIGNED_BYTE, null);
    //
    // // Poor filtering. Needed !
    // gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
    // gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);

    // Set "renderedTexture" as our colour attachement #0
    // gl.framebufferTexture(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, rendered_texture, 0);

    // Set the list of draw buffers.
    const DrawBuffers: [1]gl = [1]gl.GLenum{gl.COLOR_ATTACHMENT0};
    gl.drawBuffers(1, &DrawBuffers); // "1" is the size of DrawBuffers

    // var last_update = glfw.getTime();
    // window.setInputModeCursor(.disabled);

    while (!window.shouldClose()) {
        glfw.pollEvents();
        // const size = window.getSize();
        // camera.screen_width = size.width;
        // camera.screen_height = size.height;

        // get frametime
        // const current = glfw.getTime();
        // const elapsed = current - last_update;
        // last_update = current;

        gl.clearColor(1.0, 0.0, 0.0, 1.0);
        gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

        gl.useProgram(shaderProgram);
        gl.activeTexture(gl.TEXTURE0);

        // try setUniform(gl.getUniformLocation(shader.program, "view_matrix"), camera.getViewMatrix());
        // try setUniform(gl.getUniformLocation(shader.program, "model_matrix"), camera.getModelMatrix());
        // try setUniform(gl.getUniformLocation(shader.program, "projection_matrix"), camera.getProjectionMatrix());
        // try setUniform(gl.getUniformLocation(shader.program, "camera_position"), camera.position);

        // const w: f32 = @floatFromInt(camera.screen_width);
        // const y: f32 = @floatFromInt(camera.screen_height);
        // try setUniform(gl.getUniformLocation(shader.program, "resolution"), Vec2f.new(w, y));
        gl.bindVertexArray(vao);
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo);

        // Render to our framebuffer
        gl.viewport(0, 0, 1920, 1080); // Render on the whole framebuffer, complete from the lower left corner to the upper right
        gl.bindFramebuffer(gl.FRAMEBUFFER, 0);
        const erro2r_ = gl.getError();
        if (erro2r_ != gl.NO_ERROR) {
            std.debug.print("\nwtf {} \n", .{erro2r_});
            return;
        }

        // Always check that our framebuffer is ok
        if (gl.checkFramebufferStatus(gl.FRAMEBUFFER) != gl.FRAMEBUFFER_COMPLETE) {
            std.debug.print("!!!\nERROR framebuffer\n!!!", .{});
            return;
        }

        gl.drawElements(gl.TRIANGLES, @intCast(indices.len), gl.UNSIGNED_INT, null);
        window.swapBuffers();
        // input_manager.newFrame();
        // camera.input(&window, elapsed);
    }
}

fn glGetProcAddress(p: glfw.GlProc, proc: [:0]const u8) ?glfw.GlProc {
    _ = p;
    return glfw.getProcAddress(proc);
}

fn framebuffer_size_callback(window: glfw.Window, width: u32, height: u32) void {
    _ = window;
    zopengl.bindings.viewport(0, 0, @intCast(width), @intCast(height));
}
