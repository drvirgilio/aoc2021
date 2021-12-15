const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day15.txt");
const num_rows = 100;
const num_cols = 100;

//const data = "1163751742\n1381373672\n2136511328\n3694931569\n7463417111\n1319128137\n1359912421\n3125421639\n1293138521\n2311944581";
//const num_cols = 10;
//const num_rows = 10;

const Size = struct {
    height: usize,
    width: usize,
};

const Location = struct {
    row: usize,
    col: usize,
};

fn locationToIndex(location: Location, size: Size) usize {
    assert(location.row < size.height);
    assert(location.col < size.width);
    const index = location.row * size.height + location.col;
    return index;
}

fn indexToLocation(index: usize, size: Size) Location {
    const col = index % size.width;
    const row = index / size.width;
    return .{ .col = col, .row = row };
}

fn taxiLocation(a: Location, b: Location) usize {
    const row_delta = max(a.row, b.row) - min(a.row, b.row);
    const col_delta = max(a.col, b.col) - min(a.col, b.col);
    return row_delta + col_delta;
}

fn taxiIndex(a: usize, b: usize, size: Size) usize {
    const a_loc = indexToLocation(a, size);
    const b_loc = indexToLocation(b, size);

    assert(a_loc.row < size.height and a_loc.col < size.width);
    assert(b_loc.row < size.height and b_loc.col < size.width);

    return taxiLocation(a_loc, b_loc);
}

fn getNeighbors(buf: []usize, index: usize, size: Size) []usize {
    var buffer = buf;
    assert(buffer.len >= 4);
    const loc = indexToLocation(index, size);
    assert(loc.row < size.height);
    assert(loc.col < size.width);

    const up_exists = loc.row > 0;
    const left_exists = loc.col > 0;
    const down_exists = loc.row + 1 < size.height;
    const right_exists = loc.col + 1 < size.width;

    var i: usize = 0;
    if (up_exists) {
        const up = locationToIndex(.{ .row = loc.row - 1, .col = loc.col }, size);
        buffer[i] = up;
        i += 1;
    }
    if (left_exists) {
        const left = locationToIndex(.{ .row = loc.row, .col = loc.col - 1 }, size);
        buffer[i] = left;
        i += 1;
    }
    if (down_exists) {
        const down = locationToIndex(.{ .row = loc.row + 1, .col = loc.col }, size);
        buffer[i] = down;
        i += 1;
    }
    if (right_exists) {
        const left = locationToIndex(.{ .row = loc.row, .col = loc.col + 1 }, size);
        buffer[i] = left;
        i += 1;
    }

    return buffer[0..i];
}

fn aStar(input: []const u8, start: usize, end: usize, size: Size) !usize {
    assert(start < input.len);
    assert(end < input.len);

    // set of nodes that need to be expanded
    var open_set = try BitSet.initEmpty(input.len, gpa);
    open_set.set(start); // start index

    // value is preceding node on cheapest path from start to key
    var came_from = Map(usize, usize).init(gpa);
    defer came_from.deinit();

    // value is cost of cheapest path from start to key
    var g_score = Map(usize, usize).init(gpa);
    defer g_score.deinit();
    try g_score.put(start, 0);

    // value is best guess of cheapest total cost from start to finish which goes through key
    var f_score = Map(usize, usize).init(gpa);
    defer f_score.deinit();
    try f_score.put(start, taxiIndex(start, end, size));

    while (open_set.count() > 0) {
        // node in open_set with lowest f_score
        // O(N) - but would be O(1) if open_set were min-heap or priority queue
        const current: usize = blk: {
            var iter = open_set.iterator(.{});
            var min_f_score: usize = std.math.maxInt(usize);
            var ret: usize = undefined; // ret must be set at least once in while loop
            while (iter.next()) |index| {
                if (min_f_score >= f_score.get(index).?) {
                    min_f_score = f_score.get(index).?;
                    ret = index;
                }
            }
            break :blk ret;
        };

        if (current == end) {
            break;
        }

        //        print("{x}\n", .{current});

        open_set.unset(current);

        var buf: [4]usize = undefined;
        const neighbors: []usize = getNeighbors(&buf, current, size);
        for (neighbors) |neighbor| {
            // cost of edge from current to neighbor
            // same as value in cell of neighbor
            const d = input[neighbor];

            // cost of path from start to neighbor through current
            const tentative_g_score = if (g_score.get(current)) |g| d + g else std.math.maxInt(usize);
            if (tentative_g_score < if (g_score.get(neighbor)) |g| g else std.math.maxInt(usize)) {
                // This path to neighbor is cheaper than previously recorded paths to neighbor
                try came_from.put(neighbor, current);
                try g_score.put(neighbor, tentative_g_score);
                try f_score.put(neighbor, tentative_g_score + taxiIndex(neighbor, end, size));
                open_set.set(neighbor);
                //                print("{d:0>2}: set gs to {d}\n", .{neighbor, tentative_g_score});
            }

            //            print("neighbor: {d:0>2} :: tgs: {d}\n", .{neighbor, tentative_g_score});
        }
    }

    //    print("end: {d}\n", .{end});

    // cost is the g_score of the end node
    const cost = g_score.get(end).?;
    return cost;
}

pub fn main() !void {
    const input: [num_rows][num_cols]u8 = blk: { // parse data
        var rows = try std.BoundedArray([num_cols]u8, num_rows).init(0);
        var lines = tokenize(u8, data, "\r\n");
        while (lines.next()) |line| {
            var cols = try std.BoundedArray(u8, num_rows).init(0);
            for (line) |char| {
                const n = try parseInt(u8, &[1]u8{char}, 10);
                try cols.append(n);
            }
            assert(cols.len == num_cols);
            try rows.append(cols.buffer);
        }
        assert(rows.len == num_rows);
        break :blk rows.buffer;
    };

    const input_1: [num_rows * num_cols]u8 = blk: {
        var list = try std.BoundedArray(u8, num_cols * num_rows).init(0);
        for (input) |rows| {
            for (rows) |cell| {
                try list.append(cell);
            }
        }
        break :blk list.buffer;
    };

    const input_2: [num_rows * num_cols * 25]u8 = blk: {
        var ret: [num_rows * num_cols * 25]u8 = undefined;
        for (ret) |*cell, index| {
            const row = index / (num_rows * 5);
            const col = index % (num_cols * 5);

            const row_in = row % num_rows;
            const col_in = col % num_cols;

            const row_add = row / num_rows;
            const col_add = col / num_cols;

            cell.* = @truncate(u8, (input[row_in][col_in] + row_add + col_add - 1) % 9 + 1);
        }

        break :blk ret;
    };

    const part1 = try aStar(&input_1, 0, input_1.len - 1, Size{ .height = num_rows, .width = num_cols });
    assert(part1 == 415);
    print("{d}\n", .{part1});

    const part2 = try aStar(&input_2, 0, input_2.len - 1, Size{ .height = num_rows * 5, .width = num_cols * 5 });
    assert(part2 == 2864);
    print("{d}\n", .{part2});

    if (false) {
        for (input_2) |n, index| {
            print("{d}", .{n});
            if ((index + 1) % (num_cols * 5) == 0) print("\n", .{});
        }
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
