const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day14.txt");
const edata =
    \\NNCB
    \\
    \\CH -> B
    \\HH -> N
    \\CB -> H
    \\NH -> C
    \\HB -> C
    \\HC -> B
    \\HN -> C
    \\NN -> C
    \\BH -> H
    \\NC -> B
    \\NB -> B
    \\BN -> B
    \\BB -> N
    \\BC -> B
    \\CC -> N
    \\CN -> C
;

const Rule = [3]u8;

const Input = struct {
    list: []u8,
    rules: []Rule,
};

pub fn main() !void {
    const input: Input = blk: {
        var list = List(u8).init(gpa);
        var lines = tokenize(u8, data, "\r\n");
        const fst = lines.next().?;
        for (fst) |c| {
            try list.append(c);
        }
        var rules = List(Rule).init(gpa);
        while (lines.next()) |line| {
            var cols = tokenize(u8, line, " ->");
            const pair = cols.next().?;
            const insert = cols.next().?;
            try rules.append(.{ pair[0], pair[1], insert[0] });
        }
        break :blk .{.list = list.toOwnedSlice(), .rules = rules.toOwnedSlice()};
    };

    //print("{s}:\n{s}\n\n", .{ input.list, input.rules });
    
    { // part 1
        // copy input into mutable array
        var list = List(u8).init(gpa);
        for (input.list) |c| {
            try list.append(c);
        }
        const rules = input.rules;
        
        var step: usize = 1;
        while (step <= 10) : (step += 1) {
            const Insertion = struct {
                index: usize, // character will be inserted before this index
                char: u8,
            };

            // This list must be kept in decending order by index number
            var insertions = List(Insertion).init(gpa);
            defer insertions.deinit();
            {
                var index: usize = list.items.len - 1;
                while (index > 0) : (index -= 1) {
                    for (rules) |rule| {
                        if (std.mem.eql(u8, rule[0..2], list.items[index - 1 .. index + 1])) {
                            try insertions.append(.{ .index = index, .char = rule[2] });
                        }
                    }
                }
            }

            var outlist = List(u8).init(gpa);
            defer outlist.deinit();
            for (list.items) |c, index| {
                // if index is in insertion list, pop insertion off list and append it to outlist
                if (insertions.items.len != 0) {
                    const insertion = insertions.items[insertions.items.len - 1];
                    if (insertion.index == index) {
                        try outlist.append(insertion.char);
                        _ = insertions.pop();
                    }
                }
                try outlist.append(c);
            }
            // copy outlist into list
            try list.resize(outlist.items.len);
            for (outlist.items) |c, index| {
                list.items[index] = c;
            }
        }

        // get counts of each letter
        var counts = std.AutoArrayHashMap(u8, usize).init(gpa);
        defer counts.deinit();
        for (list.items) |c| {
            if (counts.get(c)) |count| {
                try counts.put(c, count + 1);
            } else {
                try counts.put(c, 1);
            }
        }
        var max_count: usize = 0;
        var min_count: usize = std.math.maxInt(usize);
        while (counts.popOrNull()) |entry| {
            max_count = max(max_count, entry.value);
            min_count = min(min_count, entry.value);
        }

        const answer = max_count - min_count;
        assert(answer == 2745);
        print("{}\n", .{answer});
    }
    
    { // part 2
        // This time, track the number of each pair
        // Each insertion simply removes one pair and creates two pairs
        // The count for each of these pairs needs to be tracked
        // To get the answer, the number of each character needs to be tracked
        
        const Pair = struct {
            a: u8,
            b: u8,
        };
        var pair_counts = std.AutoArrayHashMap(Pair, usize).init(gpa);
        defer pair_counts.deinit();
        var char_counts = std.AutoArrayHashMap(u8, usize).init(gpa);
        defer char_counts.deinit();
        
        // get initial counts
        for (input.list) |c, i| {
            // pair count
            if (i+1 < input.list.len) {
                const pair: Pair = .{.a=input.list[i], .b=input.list[i+1]};
                try pair_counts.put(pair, if (pair_counts.get(pair)) |count| count+1 else 1);
            }
            
            // char count
            try char_counts.put(c, if (char_counts.get(c)) |count| count+1 else 1);
        }
        
        { var step: usize = 1; while (step <= 40) : (step += 1) {
            var pair_deletions = List(Pair).init(gpa);
            defer pair_deletions.deinit();
            var pair_additions = std.AutoArrayHashMap(Pair, usize).init(gpa);
            defer pair_additions.deinit();
            for (input.rules) |rule| {
                const pair0: Pair = .{.a=rule[0], .b=rule[1]};
                const pair1: Pair = .{.a=rule[0], .b=rule[2]};
                const pair2: Pair = .{.a=rule[2], .b=rule[1]};
                
                const count0 = if (pair_counts.get(pair0)) |n| n else 0;
                const count1 = if (pair_additions.get(pair1)) |n| n else 0;
                const count2 = if (pair_additions.get(pair2)) |n| n else 0;
                
                try pair_deletions.append(pair0);
                try pair_additions.put(pair1, count1+count0);
                try pair_additions.put(pair2, count2+count0);
                
                const char_count = if (char_counts.get(rule[2])) |n| n else 0;
                try char_counts.put(rule[2], char_count + count0);
                
                if (count0 != 0) {
                    //print("{c}{c} -> {c}{c}, {c}{c} {d} times\n", .{pair0.a,pair0.b,pair1.a,pair1.b,pair2.a,pair2.b,count0});
                }
            }
            
            for (pair_deletions.items) |pair_to_delete| {
                try pair_counts.put(pair_to_delete, 0);
            }
            
            {
            var iter = pair_additions.iterator();
            while (iter.next()) |entry| {
                const pair = entry.key_ptr.*;
                const delta = entry.value_ptr.*;
                const count = if (pair_counts.get(pair)) |n| n else 0;
                try pair_counts.put(pair, count+delta);
                //print("add {d} to {c}{c}\n", .{delta,pair.a,pair.b});
            }
            }
            
            if (false) {
                {var iter = pair_counts.iterator();
                while (iter.next()) |entry| {
                    const pair = entry.key_ptr.*;
                    const count = entry.value_ptr.*;
                    if (count != 0) print("{c}{c}: {d}\n", .{pair.a, pair.b, count});
                }}
                {var iter = char_counts.iterator();
                while (iter.next()) |entry| {
                    const char = entry.key_ptr.*;
                    const count = entry.value_ptr.*;
                    if (count != 0) print("{c}: {d}\n", .{char, count});
                }}
                print("\n",.{});
            }
            
            
        }}
        
        var max_count: usize = 0;
        var min_count: usize = std.math.maxInt(usize);
        while (char_counts.popOrNull()) |entry| {
            max_count = max(max_count, entry.value);
            min_count = min(min_count, entry.value);
        }

        const answer = max_count - min_count;
        assert(answer == 3420801168962);
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
