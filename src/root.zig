// This is a minimal root module to satisfy std library's import
pub const std = @import("std");
// Add any other declarations your std library might expect from root
const c = @cImport({
    @cInclude("check-main.h");
});
pub fn main() !void {
    std.debug.print("start from root.zig", .{});

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    // Get command line arguments
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    _ = c.cmain(1, null);
}
