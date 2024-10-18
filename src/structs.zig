const std = @import("std");
const gl = @import("gl");
const glfw = @import("zglfw");
const stb = @cImport({
    @cInclude("stb_image.h");
});

pub const VAO = struct {
    const Self = @This();
    ID: c_uint = undefined,

    pub fn initVAO(self: *Self) void {
        gl.genVertexArrays(1, &self.ID);
    }

    pub fn linkVBO(_: *Self, vbo: *VBO, layout: c_uint, totalComponents: c_int, glTypeEnum: comptime_int, size: c_int, offset: ?*const anyopaque) void {
        vbo.bind();
        gl.vertexAttribPointer(layout, totalComponents, glTypeEnum, gl.FALSE, size, offset); // position
        gl.enableVertexAttribArray(layout);
        vbo.unBind();
    }
    pub fn bind(self: *Self) void {
        gl.bindVertexArray(self.ID);
    }
    pub fn unBind(_: *Self) void {
        gl.enableVertexAttribArray(0);
        gl.bindVertexArray(0);
    }

    pub fn delete(self: *Self) void {
        gl.deleteVertexArrays(1, &self.ID);
    }
};
pub const VBO = struct {
    const Self = @This();
    ID: c_uint = undefined,

    pub fn initBuffer(self: *Self, comptime T: type, vertices: []const T, vao: ?*VAO) !void {
        gl.genBuffers(1, &self.ID);
        if (vao) |value| {
            value.bind();
        }
        gl.bindBuffer(gl.ARRAY_BUFFER, self.ID);
        gl.bufferData(gl.ARRAY_BUFFER, @intCast(@sizeOf(T) * vertices.len), vertices.ptr, gl.STATIC_DRAW);
    }

    pub fn bind(self: *Self) void {
        gl.bindBuffer(gl.ARRAY_BUFFER, self.ID);
    }

    pub fn unBind(_: *Self) void {
        gl.bindBuffer(gl.ARRAY_BUFFER, 0);
    }

    pub fn delete(self: *Self) void {
        gl.deleteBuffers(1, &self.ID);
    }
};

pub const EBO = struct {
    const Self = @This();
    ID: c_uint = undefined,

    pub fn initBuffer(self: *Self, comptime T: type, vertices: []const T, vao: ?*VAO) !void {
        gl.genBuffers(1, &self.ID);
        if (vao) |value| {
            value.bind();
        }
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, self.ID);
        gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, @intCast(@sizeOf(T) * vertices.len), vertices.ptr, gl.STATIC_DRAW);
    }

    pub fn bind(self: *Self) void {
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, self.ID);
    }

    pub fn unBind(_: *Self) void {
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0);
    }

    pub fn delete(self: *Self) void {
        gl.deleteBuffers(1, &self.ID);
    }
};

pub const Texture = struct {
    const Self = @This();

    rendererId: c_uint,
    filePath: []const u8,
    localBuffer: [*c]u8,
    width: c_int,
    height: c_int,
    bpp: c_int,

    pub fn new(path: []const u8) !Self {
        const ownedFp: [:0]const u8 = try std.heap.c_allocator.dupeZ(u8, path);
        defer std.heap.c_allocator.free(ownedFp);
        var id: c_uint = undefined;

        var width: c_int = undefined;
        var height: c_int = undefined;
        var bpp: c_int = undefined;
        const buffer = stb.stbi_load(ownedFp.ptr, &width, &height, &bpp, 4);
        if (buffer > 0) {
            std.debug.print("everything good, these are the data x: {d}, y: {d}, channels: {d}", .{ width, height, bpp });
        }
        std.debug.print("texture created succesfully", .{});

        gl.genTextures(1, &id);
        gl.bindTexture(gl.TEXTURE_2D, id);

        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);

        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA8, width, height, 0, gl.RGBA, gl.UNSIGNED_BYTE, buffer);
        gl.bindTexture(gl.TEXTURE_2D, 0);

        stb.stbi_image_free(buffer);

        return Self{
            .rendererId = id,
            .filePath = path,
            .width = width,
            .height = height,
            .localBuffer = buffer,
            .bpp = bpp,
        };
    }

    pub fn delete(self: *Self) void {
        gl.deleteTextures(1, &self.rendererId);
    }

    pub fn bind(self: *Self, slot: ?c_uint) void {
        if (slot) |value| {
            gl.activeTexture(gl.TEXTURE0 + value);
            gl.bindTexture(gl.TEXTURE_2D, self.rendererId);
            return;
        }
        gl.activeTexture(gl.TEXTURE0);
        gl.bindTexture(gl.TEXTURE_2D, self.rendererId);
    }

    pub fn unBind(_: *Self) void {
        gl.bindTexture(gl.TEXTURE_2D, 0);
    }
};

pub const Renderer = struct {
    const Self = @This();
    vertices: []f32,
    indices: []i32,
    shaderProgram: c_uint,
    window: *glfw.Window,
    vao: *VAO,

    pub fn draw(self: *Self) !void {
        gl.clearColor(0.0, 0.0, 0.0, 1.0);
        while (!self.window.shouldClose()) {
            gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
            self.vao.bind();
            gl.drawElements(gl.TRIANGLES, @intCast(self.indices.len), gl.UNSIGNED_INT, null);
            glfw.pollEvents();
            self.window.swapBuffers();
            const erro2r_ = gl.getError();
            if (erro2r_ != gl.NO_ERROR) {
                std.debug.print("\nhubo un error {} \n", .{erro2r_});
                return;
            }
        }
    }
};
