const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day05.txt");

const Line = struct {
    x1: u32,
    y1: u32,
    x2: u32,
    y2: u32,
};

pub fn main() !void {
    const lines: []Line = blk: {
        var iter_lines = tokenize(u8, data, "\n\r");
        var list = std.ArrayList(Line).init(gpa);
        while (iter_lines.next()) |s| {
            var iter_nums = tokenize(u8, s, ", ->");
            var line: Line = undefined;
            line.x1 = try parseInt(u32, iter_nums.next().?, 10);
            line.y1 = try parseInt(u32, iter_nums.next().?, 10);
            line.x2 = try parseInt(u32, iter_nums.next().?, 10);
            line.y2 = try parseInt(u32, iter_nums.next().?, 10);
            try list.append(line);
        }
        break :blk list.toOwnedSlice();
    };
    
    // only consider lines where x1==x2 or y1==y2
    const axial_lines: []Line = blk: {
        var list = std.ArrayList(Line).init(gpa);
        for (lines) |line| {
            if (line.x1==line.x2 or line.y1==line.y2) {
                try list.append(line);
            }
        }
        break :blk list.toOwnedSlice();
    };
    
    { // Part 1
        var coverage = [_][991]u8{[_]u8{0}**991}**991;
        for (axial_lines) |line| {
            if (line.x1 == line.x2) {
                var y: usize = min(line.y1, line.y2);
                while (y <= max(line.y1, line.y2)) : (y += 1) {
                    coverage[line.x1][y] += 1;
                }
            } else if (line.y1 == line.y2) {
                var x: usize = min(line.x1, line.x2);
                while (x <= max(line.x1, line.x2)) : (x += 1) {
                    coverage[x][line.y1] += 1;
                }
            } else unreachable;
        }
        var count: u32 = 0;
        for (coverage) |row| {
            for (row) |val| {
                if (val >= 2) {
                    count += 1;
                }
            }
        }
        print("{d}\n", .{count});
    }
    
    { // Part 2
        var coverage = [_][991]u8{[_]u8{0}**991}**991;
        for (lines) |line| {
             if (line.x1 == line.x2) {
                var y: usize = min(line.y1, line.y2);
                while (y <= max(line.y1, line.y2)) : (y += 1) {
                    coverage[line.x1][y] += 1;
                }
            } else if (line.y1 == line.y2) {
                var x: usize = min(line.x1, line.x2);
                while (x <= max(line.x1, line.x2)) : (x += 1) {
                    coverage[x][line.y1] += 1;
                }
            } else {
                var x: usize = line.x1;
                var y: usize = line.y1;
                while (true) {
                    coverage[x][y] += 1;
                    if (x == line.x2) {
                        assert(y == line.y2);
                        break;
                    }
                    x = if (line.x1 < line.x2) x+1 else x-1;
                    y = if (line.y1 < line.y2) y+1 else y-1;
                }
            }
        }
        var count: u32 = 0;
        for (coverage) |row| {
            for (row) |val| {
                if (val >= 2) {
                    count += 1;
                }
            }
        }
        print("{d}\n", .{count});
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
