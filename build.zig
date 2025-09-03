const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zvox_module = b.addModule("zvox", .{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/zvox.zig"),
    });

    const tests = b.addTest(.{
        .name = "zvox_test",
        .root_module = zvox_module,
        .emit_object = true,
    });
    const test_run_step = b.addRunArtifact(tests);

    b.step("test", "Run tests")
        .dependOn(&test_run_step.step);
}
