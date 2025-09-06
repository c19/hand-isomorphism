const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zig_lib = b.addLibrary(.{
        .linkage = .dynamic,
        .name = "zig_lib",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/zig_lib.zig"),
            .target = target,
            .optimize = optimize,
        }),
        .version = .{ .major = 1, .minor = 0, .patch = 0 },
    });

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .strip = false,
    });

    const exe = b.addExecutable(.{
        .name = "check",
        .root_module = exe_mod,
    });

    exe.root_module.linkLibrary(zig_lib);

    // Add C source files with appropriate flags
    exe_mod.addCSourceFiles(.{
        .files = &.{
            "src/deck.c",
            "src/hand_index.c",
            "src/check-main.c",
        },
        .flags = &.{
            "-std=c99",
            "-Wall",
            // "-Wextra",
            // "-Werror",

            // // Critical for ReleaseFast compatibility
            // "-fno-omit-frame-pointer",
            // "-fno-stack-protector",
            // "-D_FORTIFY_SOURCE=0",
            // "-U_FORTIFY_SOURCE",

            // // Disable aggressive optimizations that might break C code
            // "-fno-strict-aliasing",
            // "-fno-delete-null-pointer-checks",
        },
    });

    // Add include directories
    exe.addIncludePath(.{ .cwd_relative = "src" });

    // Link against libm
    exe.linkLibC();
    exe.linkSystemLibrary("m");

    // Install the executable
    b.installArtifact(exe);

    // Create a run step for the check target
    const run_cmd = b.addRunArtifact(exe);
    const run_step = b.step("check", "Run the check executable");
    run_step.dependOn(&run_cmd.step);

    // Create a step to build everything
    const build_step = b.step("all", "Build all targets");
    build_step.dependOn(&exe.step);

    // Create a clean step
    const clean_step = b.step("clean", "Clean build artifacts");

    // Remove the executable using system command
    const rm_exe = b.addSystemCommand(&.{ "rm", "-f", "zig-out/bin/check" });
    clean_step.dependOn(&rm_exe.step);
}
