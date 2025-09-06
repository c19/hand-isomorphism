const std = @import("std");
const math = std.math;

// Comptime-generated lookup table
const nth_bit_table = blk: {
    @setEvalBranchQuota(1 << 20); // Increase branch quota for large table
    var table: [1 << 16][16]u8 = undefined;

    for (&table, 0..) |*row, i| {
        var set = @as(u16, @intCast(i));
        var count: u8 = 0;

        // Get all set bit positions
        while (set != 0) : (count += 1) {
            const lsb = @ctz(set);
            row.*[count] = @intCast(lsb);
            set &= set - 1;
        }

        // Fill remaining slots with sentinel value (0xFF indicates invalid)
        while (count < 16) : (count += 1) {
            row.*[count] = 0xFF;
        }
    }
    break :blk table;
};

export fn nth_bit(used: u64, bit: u8) u32 {
    var used_local = used;
    var bit_local: u8 = bit;

    for (0..4) |i| {
        const low16 = @as(u16, @truncate(used_local));
        const pop = @popCount(low16);

        if (pop > bit_local) {
            // Safety check
            if (bit_local >= 16) return math.maxInt(u32);
            const bit_pos = nth_bit_table[low16][bit_local];
            if (bit_pos == 0xFF) return math.maxInt(u32);
            return @as(u32, @intCast(16 * i + bit_pos));
        } else {
            used_local >>= 16;
            bit_local -%= pop; // Wrapping subtraction
        }
    }

    return math.maxInt(u32);
}
