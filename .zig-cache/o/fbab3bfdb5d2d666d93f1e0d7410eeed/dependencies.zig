pub const packages = struct {
    pub const @"12201cd57356a0a5d5ff3a98ce1a973d746261a7a972d3461fb08efd63d45ae2fa28" = struct {
        pub const build_root = "/home/bkerz/dev/zig_graphics_learnings/libs/zopengl";
        pub const build_zig = @import("12201cd57356a0a5d5ff3a98ce1a973d746261a7a972d3461fb08efd63d45ae2fa28");
        pub const deps: []const struct { []const u8, []const u8 } = &.{
        };
    };
    pub const @"12204438698dfab10cdb8a3fe9b8973a9c14d36ed6e5b9a08bf9b6b9e687d1cf0d71" = struct {
        pub const build_root = "/home/bkerz/dev/zig_graphics_learnings/libs/system-sdk";
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"12206e7794113e4019f0f20935b9c320e4f5209c72d256da027dbf98904a01ea040b" = struct {
        pub const build_root = "/home/bkerz/dev/zig_graphics_learnings/libs/zglfw";
        pub const build_zig = @import("12206e7794113e4019f0f20935b9c320e4f5209c72d256da027dbf98904a01ea040b");
        pub const deps: []const struct { []const u8, []const u8 } = &.{
            .{ "system_sdk", "12204438698dfab10cdb8a3fe9b8973a9c14d36ed6e5b9a08bf9b6b9e687d1cf0d71" },
        };
    };
};

pub const root_deps: []const struct { []const u8, []const u8 } = &.{
    .{ "zopengl", "12201cd57356a0a5d5ff3a98ce1a973d746261a7a972d3461fb08efd63d45ae2fa28" },
    .{ "zglfw", "12206e7794113e4019f0f20935b9c320e4f5209c72d256da027dbf98904a01ea040b" },
    .{ "system_sdk", "12204438698dfab10cdb8a3fe9b8973a9c14d36ed6e5b9a08bf9b6b9e687d1cf0d71" },
};
