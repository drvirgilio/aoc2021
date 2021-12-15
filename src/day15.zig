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

const Location = struct {
    row: usize,
    col: usize,
};

fn locationToIndex(location: Location) usize {
    const index = location.row * num_cols + location.col;
    return index;
}

fn indexToLocation(index: usize) Location {
    const col = index % num_cols;
    const row = index / num_cols;
    return .{ .col = col, .row = row };
}

fn taxiLocation(a: Location, b: Location) usize {
    const row_delta = max(a.row, b.row) - min(a.row, b.row);
    const col_delta = max(a.col, b.col) - min(a.col, b.col);
    return row_delta + col_delta;
}

fn taxiIndex(a: usize, b: usize) usize {
    return taxiLocation(indexToLocation(a), indexToLocation(b));
}

fn getNeighbors(buf: []usize, index: usize) []usize {
    var buffer = buf;
    assert(buffer.len >= 4);
    const loc = indexToLocation(index);
    assert(loc.row < num_rows);
    assert(loc.col < num_cols);

    const up_exists = loc.row > 0;
    const left_exists = loc.col > 0;
    const down_exists = loc.row + 1 < num_rows;
    const right_exists = loc.col + 1 < num_cols;

    var i: usize = 0;
    if (up_exists) {
        const up = locationToIndex(.{ .row = loc.row - 1, .col = loc.col });
        buffer[i] = up;
        i += 1;
    }
    if (left_exists) {
        const left = locationToIndex(.{ .row = loc.row, .col = loc.col - 1 });
        buffer[i] = left;
        i += 1;
    }
    if (down_exists) {
        const down = locationToIndex(.{ .row = loc.row + 1, .col = loc.col });
        buffer[i] = down;
        i += 1;
    }
    if (right_exists) {
        const left = locationToIndex(.{ .row = loc.row, .col = loc.col + 1 });
        buffer[i] = left;
        i += 1;
    }

    return buffer[0..i];
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

    { // part 1
        const start = 0;
        const end = locationToIndex(.{ .row = num_rows - 1, .col = num_cols - 1 }); // bottom right corner

        // set of nodes that need to be expanded
        var open_set = try BitSet.initEmpty(num_cols * num_rows, gpa);
        open_set.set(start); // start index

        // value is preceding node on cheapest path from start to key
        var came_from = Map(usize, usize).init(gpa);
        defer came_from.deinit();

        // value is cost of cheapest path from start to key
        var g_score = [_]usize{std.math.maxInt(usize)} ** (num_rows * num_cols);
        g_score[start] = 0;

        // value is best guess of cheapest total cost from start to finish which goes through key
        var f_score = [_]usize{std.math.maxInt(usize)} ** (num_rows * num_cols);
        f_score[start] = taxiIndex(start, end);

        while (open_set.count() > 0) {
            // node in open_set with lowest f_score
            // O(N) - but would be O(1) if open_set were min-heap or priority queue
            const current: usize = blk: {
                var iter = open_set.iterator(.{});
                var min_f_score: usize = std.math.maxInt(usize);
                var ret: usize = undefined; // ret must be set at least once in while loop
                while (iter.next()) |index| {
                    if (min_f_score >= f_score[index]) {
                        min_f_score = f_score[index];
                        ret = index;
                    }
                }
                break :blk ret;
            };

            if (current == end) {
                break;
            }

            open_set.unset(current);

            var buf: [4]usize = undefined;
            const neighbors: []usize = getNeighbors(&buf, current);
            for (neighbors) |neighbor| {
                // cost of edge from current to neighbor
                // same as value in cell of neighbor
                const d = blk: {
                    const loc = indexToLocation(neighbor);
                    break :blk input[loc.row][loc.col];
                };

                // cost of path from start to neighbor through current
                const tentative_g_score = g_score[current] + d;
                if (tentative_g_score < g_score[neighbor]) {
                    // This path to neighbor is cheaper than previously recorded paths to neighbor
                    try came_from.put(neighbor, current);
                    g_score[neighbor] = tentative_g_score;
                    f_score[neighbor] = tentative_g_score + taxiIndex(neighbor, end);
                    open_set.set(neighbor);
                }
            }

            //print("{d}\n", .{neighbors});
        }

        // part1 is the g_score of the end node
        const part1 = g_score[end];
        print("{d}\n", .{part1});
        if (part1 == std.math.maxInt(usize)) {
            print("g_score[end] never set\n", .{});
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
