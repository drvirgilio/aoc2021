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
    var i: usize = 0;
    while (i < 7) : (i += 1) {
        const segment = (pattern >> @truncate(u3, i)) & 1;
        if (segment == 1) count += 1;
    }
    return count;
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
                const segment_count = segmentCount(pattern);
                switch (segment_count) {
                    2, 4, 3, 7 => count += 1,
                    else => {},
                }
            }
        }
        print("{}\n", .{count});
    }

    { // part 2
        var answer: u32 = 0;
        for (input) |entry| {
            var maps: [7]u7 = undefined; // how to light up each segment
            var patterns: [10]u7 = undefined; // how to light up each digit

            // fill out patterns for 1, 7, 4, 8
            for (entry.unique) |pattern| {
                switch (segmentCount(pattern)) {
                    2 => patterns[1] = pattern,
                    3 => patterns[7] = pattern,
                    4 => patterns[4] = pattern,
                    7 => patterns[8] = pattern,
                    else => {},
                }
            }

            // a - use 1 and 7 patterns
            maps[letter('a')] = patterns[1] ^ patterns[7];

            // b, d
            //   use 1 and 4 to find b&d combintation
            //   0, 6, 9 each have 6 segments lit
            //   0 shares one segment with b&d
            //   6,9 share two segments with b&d
            //   use 0 to disambiguate b&d

            {
                const b_and_d = patterns[1] ^ patterns[4];
                for (entry.unique) |pattern| {
                    if (segmentCount(pattern) == 6) {
                        if (segmentCount(pattern & b_and_d) == 1) {
                            patterns[0] = pattern;
                            maps[letter('b')] = b_and_d & pattern;
                            maps[letter('d')] = b_and_d ^ maps[letter('b')];
                        }
                    }
                }
            }

            // what we know here:
            // patterns: 0 1 4 7 8
            // maps: a b d

            // c, f
            //   use 1 (c&f) to disambiguate 6, 9
            //   use 6,9 to disambiguate c, f
            for (entry.unique) |pattern| {
                const seg_pattern = segmentCount(pattern);
                const seg_pattern_and_d = segmentCount(pattern & maps[letter('d')]);
                if ((seg_pattern == 6) and (seg_pattern_and_d == 1)) {
                    if (segmentCount(pattern & patterns[1]) == 1) {
                        patterns[6] = pattern;
                    } else {
                        patterns[9] = pattern;
                    }
                }
            }
            maps[letter('c')] = (patterns[6] ^ patterns[9]) & patterns[1];
            maps[letter('f')] = (patterns[6] & patterns[9]) & patterns[1];

            // what we know here:
            // patterns: 0 1 4 6 7 8 9 (missing 2 3 5)
            // map: a b c d f (missing e g)

            // disambiguate 2 and 3
            for (entry.unique) |pattern| {
                const segs = segmentCount(pattern);
                const segs_c = segmentCount(pattern & maps[letter('c')]);
                const segs_1 = segmentCount(pattern & patterns[1]);
                if (segs == 5 and segs_c == 1) {
                    switch (segs_1) {
                        1 => patterns[2] = pattern,
                        2 => patterns[3] = pattern,
                        else => {},
                    }
                }
            }
            { // e
                const two = patterns[2] & ~maps[letter('f')];
                const three = patterns[3] & ~maps[letter('f')];
                maps[letter('e')] = two ^ three;
            }
            { // g
                maps[letter('g')] = std.math.maxInt(u7);
                for (maps) |map, index| {
                    if (index != letter('g')) {
                        maps[letter('g')] &= ~map;
                    }
                }
            }
            patterns[5] = patterns[6] & ~maps[letter('e')];

            // find corresponding digit for output section
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
