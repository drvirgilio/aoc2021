const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day11.txt");
//const data = "5483143223\n2745854711\n5264556173\n6141336146\n6357385478\n4167524645\n2176841721\n6882881134\n4846848554\n5283751526\n";

pub fn main() !void {
    const input: [][]u8 = blk: {
        var lines = std.ArrayList([]u8).init(gpa);
        var iter = tokenize(u8, data, "\r\n");
        while (iter.next()) |line| {
            var cols = std.ArrayList(u8).init(gpa);
            for (line) |c| {
                const n = try parseInt(u8, &[1]u8{c}, 10);
                try cols.append(n);
            }
            try lines.append(cols.toOwnedSlice());
        }
        break :blk lines.toOwnedSlice();
    };
    
    // Data structure to keep track of needed info
    const Cell = struct {
        value: u8,
        flashed: bool,
    };
    
    // copy input into mutable array of cells
    var array: [10][10]Cell = undefined;
    for (input) |row, i| {
        for (row) |cell, j| {
            array[i][j] = Cell {
                .value = cell,
                .flashed = false,
            };
        }
    }
    
    var flash_count: usize = 0;
    var step: usize = 1;
    while (true) : (step += 1) {
        // Add one to each input
        for (array) |*row| {
            for (row) |*cell| {
                cell.value += 1;
            }
        }
        
        // Flash every cell >9
        var keep_flashing: bool = true;
        while (keep_flashing) {
            keep_flashing = false;
            for (array) |*row, i| {
                for (row) |*cell, j| {
                    if (cell.value > 9 and !cell.flashed) {
                        cell.value = 10; // limit cell size to prevent possible overflow
                        keep_flashing = true;
                        cell.flashed = true;
                        flash_count += 1;
                        
                        // find index bounds
                        const up: usize = if (i==0) 0 else i-1;
                        const down: usize = if (i==9) 9 else i+1;
                        const left: usize = if (j==0) 0 else j-1;
                        const right: usize = if (j==9) 9 else j+1;
                        
                        // add one to all cells within bounds
                        var ii: usize = up;
                        while (ii <= down) : (ii += 1) {
                            var jj: usize = left;
                            while (jj <= right) : (jj += 1) {
                                array[ii][jj].value += 1;
                            }
                        }
                    }
                }
            }
        }
        
        // Set all flashed cells back to zero
        var all_cells_flash = true;
        for (array) |*row| {
            for (row) |*cell| {
                if (cell.flashed) {
                    assert(cell.value > 9);
                    cell.value = 0;
                    cell.flashed = false;
                } else {
                    all_cells_flash = false;
                }
            }
        }
        
        if (all_cells_flash) {
            assert(step == 351);
            print("{}\n", .{step});
            break;
        }
        
        if (step == 100) {
            assert(flash_count == 1669);
            print("{}\n", .{flash_count});
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
