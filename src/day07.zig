const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day07.txt");
//const data = "16,1,2,0,4,2,7,1,2,14";

pub fn main() !void {
    const input: []u32 = blk: {
        var iter = tokenize(u8, data, ",\r\n");
        var list = std.ArrayList(u32).init(gpa);
        while (iter.next()) |s| {
            const n = try parseInt(u32, s, 10);
            try list.append(n);
        }
        break :blk list.toOwnedSlice();
    };
    
    { // part 1
        // find initial upper and lower bounds
        var low: u32 = comptime std.math.maxInt(u32);
        var high: u32 = 0;
        for (input) |n| {
            if (n > high) high = n;
            if (n < low) low = n;
        }
        
        var mincost: u32 = std.math.maxInt(u32);
        var testpoint = low; while (testpoint <= high) : (testpoint += 1) {
            var cost: u32 = 0;
            for (input) |n| {
                cost += if (testpoint < n) (n - testpoint) else (testpoint - n);
            }
            if (cost < mincost) mincost = cost;
        }
        
        print("{}\n", .{mincost});
    }
    { // part 2
        // find initial upper and lower bounds
        var low: u32 = comptime std.math.maxInt(u32);
        var high: u32 = 0;
        for (input) |n| {
            if (n > high) high = n;
            if (n < low) low = n;
        }
        
        var mincost: u32 = std.math.maxInt(u32);
        var testpoint = low; while (testpoint <= high) : (testpoint += 1) {
            var cost: u32 = 0;
            for (input) |n| {
                const d = if (testpoint < n) (n - testpoint) else (testpoint - n);
                cost += d*(d+1)/2;
            }
            if (cost < mincost) mincost = cost;
        }
        
        print("{}\n", .{mincost});
    }
}

// Useful stdlib functions
const tokenize = std.mem.tokenize;
const split = std.mem.split;
const indexOf = std.mem.indexOfScalar;
const indexOfAny = std.mem.indexOfAny;
const indexOfStr = std.mem.indexOfPosLinear;
const lastIndexOf = std.mem.lastIndexOfScalar;
const lastIndexOfAny = std.mem.lastIndexOfAny;
const lastIndexOfStr = std.mem.lastIndexOfLinear;
const trim = std.mem.trim;
const sliceMin = std.mem.min;
const sliceMax = std.mem.max;

const parseInt = std.fmt.parseInt;
const parseFloat = std.fmt.parseFloat;

const min = std.math.min;
const min3 = std.math.min3;
const max = std.math.max;
const max3 = std.math.max3;

const print = std.debug.print;
const assert = std.debug.assert;

const sort = std.sort.sort;
const asc = std.sort.asc;
const desc = std.sort.desc;
