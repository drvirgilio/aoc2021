const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day13.txt");
const edata = 
\\6,10
\\0,14
\\9,10
\\0,3
\\10,4
\\4,11
\\6,0
\\6,12
\\4,1
\\0,13
\\10,12
\\3,4
\\3,0
\\8,4
\\1,10
\\2,14
\\8,10
\\9,0
\\
\\fold along y=7
\\fold along x=5
;

const Point = struct {
    x: usize,
    y: usize,
};

const Fold = struct {
    axis: Axis,
    offset: usize,
    
    const Axis = enum {
        x,
        y,
    };
};

const Input = struct {
    points: []Point,
    folds: []Fold,
};

fn foldPoints(points: []Point, fold: Fold) void {
    for (points) |*point| {
        switch (fold.axis) {
            .x => {
                if (point.x > fold.offset) {
                    point.x = fold.offset - (point.x - fold.offset);
                }
            },
            .y => {
                if (point.y > fold.offset) {
                    point.y = fold.offset - (point.y - fold.offset);
                }
            },
        }
    }
}

fn printPoints(points: []Point) void {
    for (points) |point| {
        print("{},{}\n", .{point.x, point.y});
    }
}

fn pointBounds(points: []Point) Point {
    var max_x: usize = 0;
    var max_y: usize = 0;
    for (points) |point| {
        max_x = max(max_x, point.x);
        max_y = max(max_y, point.y);
    }
    return Point{.x=max_x, .y=max_y};
}

fn displayPoints(points: []Point) void {
    const bounds = pointBounds(points);
    var y: usize = 0;
    while (y <= bounds.y) : (y += 1) {
        var x: usize = 0;
        while (x <= bounds.x) : (x+=1) {
            for (points) |point| {
                if (point.x == x and point.y == y) {
                    print("#",.{});
                    break;
                }
            } else {
                print(" ", .{});
            }
        }
        print("\n",.{});
    }
}

fn pointLessThan(_: void, a: Point, b: Point) bool {
    if (a.x < b.x) return true;
    if (a.x > b.x) return false;
    if (a.y < b.y) return true;
    return false;
}

pub fn main() !void {
    var input: Input = blk: {
        var point_list = List(Point).init(gpa);
        var fold_list = List(Fold).init(gpa);
    
        var sections = split(u8, data, "\n\n");
        const fst = sections.next().?;
        const snd = sections.next().?;
        var fst_iter = tokenize(u8, fst, "\n");
        while (fst_iter.next()) |line| {
            var iter = split(u8, line, ",");
            const x = try parseInt(usize, iter.next().?, 10);
            const y = try parseInt(usize, iter.next().?, 10);
            try point_list.append(Point{.x=x, .y=y});
        }
        var snd_iter = tokenize(u8, snd, "\n");
        while (snd_iter.next()) |line| {
            var iter = tokenize(u8, line, "fold along=");
            const axis: Fold.Axis = switch(iter.next().?[0]) {
                'x' => .x,
                'y' => .y,
                else => unreachable,
            };
            const offset: usize = try parseInt(usize, iter.next().?, 10);
            try fold_list.append(Fold{.axis = axis, .offset=offset});
        }
        
        break :blk Input{.points = point_list.toOwnedSlice(), .folds = fold_list.toOwnedSlice()};
    };


    const part1 = blk: {
        foldPoints(input.points, input.folds[0]);
        sort(Point, input.points, {}, pointLessThan);
        var point_map = std.AutoArrayHashMap(Point, bool).init(gpa);
        defer point_map.deinit();
        for (input.points) |point| {
            try point_map.put(point, true);
        }
        break :blk point_map.count();
    };
    
    print("{}\n", .{part1});
    
    {
        for (input.folds[1..input.folds.len]) |fold| {
            foldPoints(input.points, fold);
        }
        sort(Point, input.points, {}, pointLessThan);
        var point_map = std.AutoArrayHashMap(Point, bool).init(gpa);
        defer point_map.deinit();
        for (input.points) |point| {
            try point_map.put(point, true);
        }
        displayPoints(input.points);
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
