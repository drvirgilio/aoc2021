const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day02.txt");

const Direction = enum {
    forward,
    down,
    up,
};

const Instruction = struct {
    direction: Direction,
    value: u32,
};

pub fn main() !void {
    // create list
    var list = std.ArrayList(Instruction).init(gpa);
    defer list.deinit();
    
    // parse data and append to list
    {
        var iter = split(u8, data, "\n");
        while(iter.next()) |line| {
            if (line.len == 0) continue;
            var instruction: Instruction = undefined;
            var iter2 = split(u8, line, " ");
            if (iter2.next()) |s| {
                switch (s[0]) {
                    'f' => instruction.direction = .forward,
                    'd' => instruction.direction = .down,
                    'u' => instruction.direction = .up,
                    else => unreachable,
                }
            }
            if (iter2.next()) |s| {
                const n = try parseInt(u32, s, 10);
                instruction.value = n;
            }
            try list.append(instruction);
        }
    }
    
    { // Part 1
        var depth: u32 = 0;
        var dist: u32 = 0;
        
        for (list.items) |instruction| {
            switch (instruction.direction) {
                .forward => { dist += instruction.value; },
                .up => { depth -= instruction.value; },
                .down => { depth += instruction.value; },
            }
        }
        
        const answer = dist * depth;
        print("{}\n", .{answer});
    }
    
    { // Part 2
        var depth: u32 = 0;
        var dist: u32 = 0;
        var aim: u32 = 0;
        
        for (list.items) |instruction| {
            switch (instruction.direction) {
                .forward => { 
                    dist += instruction.value;
                    depth += aim * instruction.value;
                },
                .up => { aim -= instruction.value; },
                .down => { aim += instruction.value; },
            }
        }
        
        const answer = dist * depth;
        print("{}\n", .{answer});
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
