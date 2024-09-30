pub const packages = struct {
    pub const @"122010ea2654ae1142103e36594a8ea755aa644e943db01b70bc2e921ad419b928af" = struct {
        pub const build_root = "/home/bkerz/dev/zig_graphics_learnings/libs/zsdl";
        pub const build_zig = @import("122010ea2654ae1142103e36594a8ea755aa644e943db01b70bc2e921ad419b928af");
        pub const deps: []const struct { []const u8, []const u8 } = &.{
            .{ "sdl2-prebuilt-macos", "12205cb2da6fb4a7fcf28b9cd27b60aaf12f4d4a55be0260b1ae36eaf93ca5a99f03" },
            .{ "sdl2-prebuilt-x86_64-linux-gnu", "1220703f44b559bd5efe9effbdd90a55b80ed5cfa4c39e01652258433bba18aad672" },
            .{ "sdl2-prebuilt-x86_64-windows-gnu", "1220ade6b84d06d73bf83cef22c73ec4abc21a6d50b9f48875f348b7942c80dde11b" },
        };
    };
    pub const @"12204438698dfab10cdb8a3fe9b8973a9c14d36ed6e5b9a08bf9b6b9e687d1cf0d71" = struct {
        pub const build_root = "/home/bkerz/dev/zig_graphics_learnings/libs/system-sdk";
        pub const build_zig = @import("12204438698dfab10cdb8a3fe9b8973a9c14d36ed6e5b9a08bf9b6b9e687d1cf0d71");
        pub const deps: []const struct { []const u8, []const u8 } = &.{
        };
    };
    pub const @"12205cb2da6fb4a7fcf28b9cd27b60aaf12f4d4a55be0260b1ae36eaf93ca5a99f03" = struct {
        pub const available = false;
    };
    pub const @"12206e7794113e4019f0f20935b9c320e4f5209c72d256da027dbf98904a01ea040b" = struct {
        pub const build_root = "/home/bkerz/dev/zig_graphics_learnings/libs/zglfw";
        pub const build_zig = @import("12206e7794113e4019f0f20935b9c320e4f5209c72d256da027dbf98904a01ea040b");
        pub const deps: []const struct { []const u8, []const u8 } = &.{
            .{ "system_sdk", "12204438698dfab10cdb8a3fe9b8973a9c14d36ed6e5b9a08bf9b6b9e687d1cf0d71" },
        };
    };
    pub const @"1220703f44b559bd5efe9effbdd90a55b80ed5cfa4c39e01652258433bba18aad672" = struct {
        pub const available = true;
        pub const build_root = "/home/bkerz/.cache/zig/p/1220703f44b559bd5efe9effbdd90a55b80ed5cfa4c39e01652258433bba18aad672";
        pub const deps: []const struct { []const u8, []const u8 } = &.{
        };
    };
    pub const @"1220ade6b84d06d73bf83cef22c73ec4abc21a6d50b9f48875f348b7942c80dde11b" = struct {
        pub const available = false;
    };
};

pub const root_deps: []const struct { []const u8, []const u8 } = &.{
    .{ "zsdl", "122010ea2654ae1142103e36594a8ea755aa644e943db01b70bc2e921ad419b928af" },
    .{ "zglfw", "12206e7794113e4019f0f20935b9c320e4f5209c72d256da027dbf98904a01ea040b" },
    .{ "system_sdk", "12204438698dfab10cdb8a3fe9b8973a9c14d36ed6e5b9a08bf9b6b9e687d1cf0d71" },
    .{ "sdl2-prebuilt-macos", "12205cb2da6fb4a7fcf28b9cd27b60aaf12f4d4a55be0260b1ae36eaf93ca5a99f03" },
    .{ "sdl2-prebuilt-x86_64-linux-gnu", "1220703f44b559bd5efe9effbdd90a55b80ed5cfa4c39e01652258433bba18aad672" },
    .{ "sdl2-prebuilt-x86_64-windows-gnu", "1220ade6b84d06d73bf83cef22c73ec4abc21a6d50b9f48875f348b7942c80dde11b" },
};
