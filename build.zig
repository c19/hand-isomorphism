const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create the main executable
    const exe = b.addExecutable(.{
        .name = "check",
        .target = target,
        .optimize = optimize,
    });

    // Add C source files with appropriate flags
    exe.addCSourceFiles(.{
        .files = &.{
            "src/deck.c",
            "src/hand_index.c",
            "src/check-main.c",
        },
        .flags = &.{
            "-std=c99",
            "-Wall",
            "-g",
            // "-O2",
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
