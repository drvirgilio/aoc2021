const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day10.txt");

pub fn main() !void {
    const input: [][]u8 = blk: {
        var list = std.ArrayList([]u8).init(gpa);
        var iter = tokenize(u8, data, "\r\n");
        while (iter.next()) |line| {
            var list2 = std.ArrayList(u8).init(gpa);
            for (line) |c| {
                try list2.append(c);
            }
            try list.append(list2.toOwnedSlice());
        }
        break :blk list.toOwnedSlice();
    };
    
    { // part 1
        var score: u32 = 0;
        for (input) |line, line_index| {
            var stack = std.ArrayList(u8).init(gpa);
            const result: Result = for (line) |c, col_index| {
                switch(c) {
                    '(', '[', '{', '<' => try stack.append(c),
                    ')', ']', '}', '>' => {
                        const last_or_null = stack.popOrNull();
                        if (last_or_null) |last| {
                            if (isMatch(last, c)) {
                                continue;
                            } else {
                                break Result{.corrupted = c};
                            }
                        } else {
                            break Result.incomplete;
                        }
                    },
                    else => {
                        print("{d}:{s} :: {d}:{c}\n", .{line_index, line, col_index, c});
                        unreachable;
                    },
                }
            } else blk: {
                break :blk Result.complete;
            };
            
            switch (result) {
                Result.complete => {},
                Result.incomplete => {},
                Result.corrupted => |c| switch (c) {
                    ')' => score += 3,
                    ']' => score += 57,
                    '}' => score += 1197,
                    '>' => score += 25137,
                    else => unreachable,
                }
            }
            
        }
        
        print("{d}\n", .{score});
    }
}

const Result = union(enum) {
    complete: void,
    incomplete: void,
    corrupted: u8,
};

fn isMatch(fst: u8, snd: u8) bool {
    const expected_snd: u8 = switch(fst) {
        '(' => ')',
        '[' => ']',
        '{' => '}',
        '<' => '>',
        else => unreachable,
    };
    return if (snd == expected_snd) true else false;
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
