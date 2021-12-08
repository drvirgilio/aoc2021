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
fn letter(c: u8) u3 {
    assert(c >= 'a');
    assert(c <= 'g');
    return @truncate(u3, c - 'a');
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
            var index: usize = 0;
            while (entries.next()) |pattern| : (index += 1) {
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

    { // part 1
        var count: u32 = 0;
        for (input) |entry| {
            for (entry.output) |pattern| {
                const segment_count = @popCount(u7, pattern);
                switch (segment_count) {
                    2, 4, 3, 7 => count += 1,
                    else => {},
                }
            }
        }
        assert(count == 349);
        print("{}\n", .{count});
    }

    { // part 2
        var answer: u32 = 0;
        for (input) |entry| {
            var patterns: [10]u7 = undefined; // how to light up each digit

            // fill out patterns for 1 4 7 8
            for (entry.unique) |pattern| {
                switch (@popCount(u7, pattern)) {
                    2 => patterns[1] = pattern,
                    3 => patterns[7] = pattern,
                    4 => patterns[4] = pattern,
                    7 => patterns[8] = pattern,
                    else => {},
                }
            }

            // fill out patterns for remaining digits
            for (entry.unique) |pattern| {
                switch (@popCount(u7, pattern)) {
                    2, 3, 4, 7 => {}, // 1 4 7 8 done already
                    5 => { // 2 3 5
                        var index: usize = undefined;
                        if (pattern | patterns[4] == patterns[8]) {
                            index = 2;
                        } else if (pattern | patterns[7] == pattern) {
                            index = 3;
                        } else {
                            index = 5;
                        }
                        patterns[index] = pattern;
                    },
                    6 => { // 0 6 9
                        var index: usize = undefined;
                        if (pattern | patterns[7] == patterns[8]) {
                            index = 6;
                        } else if (pattern | patterns[4] == patterns[8]) {
                            index = 0;
                        } else {
                            index = 9;
                        }
                        patterns[index] = pattern;
                    },
                    else => unreachable,
                }
            }

            // find corresponding digits for output section
            const output: u32 = blk: {
                var digits: [4]u8 = undefined;
                for (entry.output) |output, place| {
                    for (patterns) |pattern, index| {
                        if (output == pattern) {
                            digits[place] = @truncate(u8, '0' + index);
                            break;
                        }
                    } else unreachable;
                }
                break :blk try parseInt(u32, &digits, 10);
            };

            answer += output;
        }

        assert(answer == 1070957);
        print("{d}\n", .{answer});
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
