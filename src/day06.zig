const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day06.txt");

pub fn main() !void {
    const input: []u8 = blk: {
        var iter = tokenize(u8, data, ",\n\r");
        var list = std.ArrayList(u8).init(gpa);
        while (iter.next()) |s| {
            const n = try parseInt(u8, s, 10);
            try list.append(n);
        }
        break :blk list.toOwnedSlice();
    };

    { // part 1
        var list = std.ArrayList(u8).init(gpa);
        for (input) |n| {
            try list.append(n);
        }
        var day: usize = 0; while(day < 80) : (day += 1) {
            var additions = std.ArrayList(u8).init(gpa);
            for (list.items) |*fish| {
                if (fish.* == 0) {
                    fish.* = 6;
                    try additions.append(8);
                } else {
                    fish.* -= 1;
                }
            }
            for (additions.items) |new_fish| {
                try list.append(new_fish);
            }
        }
        print("{d}\n", .{list.items.len});
    }
    
    { // part 2
        // we cannot keep track of each individual fish. There are too many.
        // instead, track the number of fish of each age
        
        // set initial fish population
        var fish = [_]u64{0} ** 9;
        for (input) |n| {
            fish[n] += 1;
        }
        
        var day: usize = 0; while (day < 256) : (day += 1) {
            const new_fish: u64 = fish[0];
            fish[0] = fish[1];
            fish[1] = fish[2];
            fish[2] = fish[3];
            fish[3] = fish[4];
            fish[4] = fish[5];
            fish[5] = fish[6];
            fish[6] = fish[7] + new_fish;
            fish[7] = fish[8];
            fish[8] = new_fish;
        }
        
        var sum: u64 = 0;
        for (fish) |n| {
            sum += n;
        }
        print("{d}\n", .{sum});
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
