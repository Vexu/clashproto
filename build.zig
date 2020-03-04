const std = @import("std");
const Builder = std.build.Builder;

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{
        .default_target = if (std.Target.current.os.tag == .windows) .{ .abi = .gnu } else .{},
    });
    const mode = b.standardReleaseOptions();
    const exe = b.addExecutable("clashproto", "src/main.zig");
    exe.addCSourceFile("deps/stb_image.c", &[_][]const u8{"-std=c99"});
    exe.addIncludeDir("deps");
    exe.addPackagePath("bog", "../bog/src/bog.zig");
    exe.setBuildMode(mode);
    exe.setTarget(target);

    if (target.getOsTag() == .windows and target.getAbi() == .gnu) {
        @import("deps/zig-sdl/build.zig").linkArtifact(b, .{
            .artifact = exe,
            .prefix = "deps/zig-sdl",
            .override_mode = .ReleaseFast,
        });
        @import("deps/libsoundio/build.zig").linkArtifact(b, .{
            .artifact = exe,
            .prefix = "deps/libsoundio",
            .override_mode = .ReleaseFast,
        });
    } else {
        exe.linkSystemLibrary("SDL2");
        exe.linkSystemLibrary("soundio");
    }

    exe.linkLibC();
    exe.install();

    // can't use this since child stdin is ignored
    // const run_cmd = exe.run();
    // run_cmd.step.dependOn(b.getInstallStep());

    // const run_step = b.step("run", "Run the app");
    // run_step.dependOn(&run_cmd.step);
}
