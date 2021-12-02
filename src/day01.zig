const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day01.txt");

pub fn main() !void {
    // create list
    var list = std.ArrayList(u32).init(gpa);
    defer list.deinit();
    
    // parse data and append to list
    {
        var iter = split(u8, data, "\n");
        while(iter.next()) |s| {
            const n = parseInt(u32, s, 10) catch continue;
            try list.append(n);
        }
    }
    
    { // Part 1
        var count: u32 = 0;
        for (list.items) |n, index| {
            if (index >= 1) {
                const n1 = list.items[index - 1];
                if (n > n1) count += 1;
            }
        }
        print("{}\n", .{count});
    }
    
    { // Part 2
        var count: u32 = 0;
        for (list.items) |n, index| {
            if (index >= 3) {
                const n1 = list.items[index - 1];
                const n2 = list.items[index - 2];
                const n3 = list.items[index - 3];
                if (n+n1+n2 > n1+n2+n3) count += 1;
            }
        }
        print("{}\n", .{count});
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
