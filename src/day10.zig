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
const example_data =
    \\[({(<(())[]>[[{[]{<()<>>
    \\[(()[<>])]({[<{<<[]>>(
    \\{([(<{}[<>[]}>{[]{[(<()>
    \\(((({<>}<{<{<>}{[]{[]{}
    \\[[<[([]))<([[{}[[()]]]
    \\[{[{({}]{}}([{[{{{}}([]
    \\{<[[]]>}<{[{[{[]{()[[[]
    \\[<(<(<(<{}))><([]([]()
    \\<{([([[(<>()){}]>(<<{{
    \\<{([{{}}[<[[[<>{}]]]>[]]
;
//const data = example_data;

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
    
    {
        var part1: u64 = 0;
        var part2 = std.ArrayList(u64).init(gpa);
        
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
                            print("{d}:{s} :: {d}:{c}\n", .{line_index, line, col_index, c});
                            unreachable; // not sure how to articulate this property of our puzzle input
                        }
                    },
                    else => {
                        print("{d}:{s} :: {d}:{c}\n", .{line_index, line, col_index, c});
                        unreachable;
                    },
                }
            } else blk: {
                if (stack.items.len == 0) {
                    break :blk .complete;
                } else {
                    break :blk Result{.incomplete = stack.toOwnedSlice()};
                }
            };
            
            switch (result) {
                Result.complete => {},
                Result.incomplete => |s| {
                    var score: u64 = 0;
                    std.mem.reverse(u8, s);
                    for (s) |c| {
                        score *= 5;
                        switch (c) {
                            '(' => score += 1,
                            '[' => score += 2,
                            '{' => score += 3,
                            '<' => score += 4,
                            else => unreachable,
                        }
                    }
                    try part2.append(score);
                    //print("{d}: {s}\n", .{score, s});
                },
                Result.corrupted => |c| switch (c) {
                    ')' => part1 += 3,
                    ']' => part1 += 57,
                    '}' => part1 += 1197,
                    '>' => part1 += 25137,
                    else => unreachable,
                }
            }
            
        }
        
        print("{d}\n", .{part1});
        
        sort(u64, part2.items, {}, comptime asc(u64));
        const middle_index = part2.items.len / 2;
        print("{d}\n", .{part2.items[middle_index]});
    }
}

const Result = union(enum) {
    complete: void,
    incomplete: []u8,
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
