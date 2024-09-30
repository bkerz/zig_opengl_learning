pub const packages = struct {
    pub const @"12204438698dfab10cdb8a3fe9b8973a9c14d36ed6e5b9a08bf9b6b9e687d1cf0d71" = struct {
        pub const build_root = "/home/bkerz/dev/zig_graphics_learnings/libs/system-sdk";
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"12206e7794113e4019f0f20935b9c320e4f5209c72d256da027dbf98904a01ea040b" = struct {
        pub const build_root = "/home/bkerz/dev/zig_graphics_learnings/libs/zglfw";
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
};

pub const root_deps: []const struct { []const u8, []const u8 } = &.{
    .{ "zglfw", "12206e7794113e4019f0f20935b9c320e4f5209c72d256da027dbf98904a01ea040b" },
    .{ "system_sdk", "12204438698dfab10cdb8a3fe9b8973a9c14d36ed6e5b9a08bf9b6b9e687d1cf0d71" },
};
