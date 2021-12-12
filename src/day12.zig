const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day12.txt");
//const data = "start-A\nstart-b\nA-c\nA-b\nb-d\nA-end\nb-end";
const edata =
    \\fs-end
    \\he-DX
    \\fs-he
    \\start-DX
    \\pj-DX
    \\end-zg
    \\zg-sl
    \\zg-pj
    \\pj-he
    \\RW-he
    \\fs-DX
    \\pj-RW
    \\zg-RW
    \\start-pj
    \\he-WI
    \\zg-he
    \\pj-fs
    \\start-RW
;

const Size = enum {
    big,
    small,
};

const Cave = struct {
    size: Size,
    name: []const u8,
    connections: []*Cave = undefined,
    visits: usize = 0,
};

pub fn main() !void {
    // Scan the input to build a slice of caves
    var caves: []Cave = blk: {
        var lines = tokenize(u8, data, "\r\n-");
        var map = StrMap(Cave).init(gpa);
        defer map.deinit();
        while (lines.next()) |name| {
            const cave = Cave{
                .size = if (name[0] >= 'a') .small else .big,
                .name = name,
            };
            try map.put(name, cave);
        }
        var list = List(Cave).init(gpa);
        var iter = map.iterator();
        while (iter.next()) |cave| {
            try list.append(cave.value_ptr.*);
        }
        break :blk list.toOwnedSlice();
    };

    // Put pointers to each cave into a hashmap indexed by name
    var cave_names = StrMap(*Cave).init(gpa);
    for (caves) |*cave| {
        try cave_names.put(cave.name, cave);
    }

    // For each cave, scan the input to populate the connections field
    for (caves) |*cave| {
        var cave_connection_list = List(*Cave).init(gpa);
        var lines = tokenize(u8, data, "\r\n");
        while (lines.next()) |line| {
            var cols = tokenize(u8, line, "-");
            const fst = cols.next().?;
            const snd = cols.next().?;
            if (std.mem.eql(u8, cave.name, fst)) {
                const cave_ptr = cave_names.get(snd).?;
                try cave_connection_list.append(cave_ptr);
            } else if (std.mem.eql(u8, cave.name, snd)) {
                const cave_ptr = cave_names.get(fst).?;
                try cave_connection_list.append(cave_ptr);
            }
        }
        cave.connections = cave_connection_list.toOwnedSlice();
    }

    // print connections
    if (false) {
        print("Connections:\n", .{});
        for (caves) |cave| {
            print("{s}: ", .{cave.name});
            for (cave.connections) |cave_2, index| {
                print("{s}", .{cave_2.name});
                if (index + 1 < cave.connections.len) {
                    print(", ", .{});
                } else {
                    print("\n", .{});
                }
            }
        }
        print("\n", .{});
    }

    var part1: usize = 0;
    var part2: usize = 0;
    
    var stack = List(Move).init(gpa);
    try stack.append(Move{ .cave = cave_names.get("start").? });
    while (stack.items.len != 0) {
        const move: *Move = &stack.items[stack.items.len - 1];
        const cave: *Cave = move.cave;

        if (false) {
            for (stack.items) |m, index| {
                print("{s}", .{m.cave.name});
                if (index + 1 < stack.items.len) {
                    print(",", .{});
                } else {
                    print("\n", .{});
                }
            }
        }

        if (move.index) |*index| {
            index.* += 1;
        } else {
            cave.visits += 1;
            move.index = 0;
        }

        if (std.mem.eql(u8, cave.name, "end")) {
            if (false) {
                for (stack.items) |m, index| {
                    print("{s}", .{m.cave.name});
                    if (index + 1 < stack.items.len) {
                        print(",", .{});
                    } else {
                        print("\n", .{});
                    }
                }
            }
            var visit_small_twice = false;
            for (caves) |c| {
                if (c.size == .small and c.visits > 1) {
                    visit_small_twice = true;
                    break;
                }
            }
            if (!visit_small_twice) part1 += 1;
            part2 += 1;
            
            cave.visits -= 1;
            _ = stack.pop();
            continue;
        }

        if (cave.size == Size.small and cave.visits > 2) {
            cave.visits -= 1;
            _ = stack.pop();
            continue;
        }

        if (cave.size == Size.small and cave.visits > 1) {
            if (std.mem.eql(u8, cave.name, "start")) {
                cave.visits -= 1;
                _ = stack.pop();
                continue;
            }
            // check for any other small caves with visits > 1
            var flag: bool = false;
            for (caves) |*c| {
                if (c.size == .small and c != cave and c.visits > 1) {
                    flag = true;
                    break;
                }
            }
            if (flag) {
                cave.visits -= 1;
                _ = stack.pop();
                continue;
            }
        }

        if (move.index.? >= cave.connections.len) {
            // nowhere else to go from this cave so backtrack
            cave.visits -= 1;
            _ = stack.pop();
            continue;
        }

        // go to next cave
        const next_cave = cave.connections[move.index.?];
        try stack.append(Move{ .cave = next_cave });
    }

    assert(part1 == 4775);
    assert(part2 == 152480);

    print("{}\n", .{part1});
    print("{}\n", .{part2});
}

const Move = struct {
    cave: *Cave,
    index: ?usize = null,
};

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
