const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day08.txt");
//const data = "acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf";
const example_data = 
    \\be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
    \\edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
    \\fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
    \\fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
    \\aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
    \\fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
    \\dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
    \\bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
    \\egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
    \\gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce
;

fn encodePattern(s: []const u8) u7 {
    var pattern: u7 = 0;
    for (s) |c| {
        assert(c >= 'a');
        assert(c <= 'g');
        const i: u3 = @truncate(u3, c - 'a');
        pattern |= @as(u7, 1) << i;
    }
    return pattern;
}
fn segmentCount(pattern: u7) u3 {
    var count: u3 = 0;
    var i: usize = 0; while (i < 7) : (i += 1) {
        const segment = (pattern >> @truncate(u3, i)) & 1;
        if (segment == 1) count += 1;
    }
    return count;
}

const Entry = struct {
    unique: [10]u7,
    output: [4]u7,
};

pub fn main() !void {
    const input: []Entry = blk: {
        var lines = tokenize(u8, data, "\r\n");
        var list = std.ArrayList(Entry).init(gpa);
        while (lines.next()) |line| {
            var entries = tokenize(u8, line, " |");
            var entry: Entry = undefined;
            var index: usize = 0; while (entries.next()) |pattern| : (index += 1) {
                if (index < 10) {
                    entry.unique[index] = encodePattern(pattern);
                } else {
                    entry.output[index - 10] = encodePattern(pattern);
                }
            }
            try list.append(entry);
        }
        break :blk list.toOwnedSlice();
    };
    
    //print("{d}\n", .{input[0].unique});
    
    { // part 1
        var count: u32 = 0;
        for (input) |entry| {
            for (entry.output) |pattern| {
                const segment_count = segmentCount(pattern);
                switch (segment_count) {
                    2, 4, 3, 7 => count += 1,
                    else => {},
                }
            }
        }
        print ("{}\n", .{count});
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
