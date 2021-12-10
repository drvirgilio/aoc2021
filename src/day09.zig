const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day09.txt");
//const data = "2199943210\n3987894921\n9856789892\n8767896789\n9899965678";

pub fn main() !void {
    const input: [][]u4 = outer: {
        var iter = tokenize(u8, data, "\r\n");
        var rows = std.ArrayList([]u4).init(gpa);
        while (iter.next()) |line| {
            const row: []u4 = inner: {
                var cols = std.ArrayList(u4).init(gpa);
                for (line) |c| {
                    const n = try parseInt(u4, &[1]u8{c}, 10);
                    try cols.append(n);
                }
                break :inner cols.toOwnedSlice();
            };
            try rows.append(row);
        }
        break :outer rows.toOwnedSlice();
    };
    
    { // part 1
        var risk: u32 = 0;
        for (input) |line, row| {
            for (line) |cell, col| {
                const left = if (col == 0) 9 else line[col-1];
                const right = if (col+1 == line.len) 9 else line[col+1];
                const up = if (row == 0) 9 else input[row-1][col];
                const down = if (row+1 == input.len) 9 else input[row+1][col];
                
                if (cell<left and cell<right and cell<up and cell<down) {
                    risk += cell + 1;
                }
            }
        }
        print("{}\n", .{risk});
    }
    
    { // part 2
        //const num_rows = input.len;
        //const num_cols = input[0].len;
        
        // Create an array of basins
        // The u16 is the basin number
        // Null means not in any basin
        var basins: [][]?u16 = blk: {
            var list = std.ArrayList([]?u16).init(gpa);
            var basin_number: u16 = 0;
            for (input) |line, row| {
                var list_cols = std.ArrayList(?u16).init(gpa);
                for (line) |cell, col| {
                    const left = if (col == 0) 9 else line[col-1];
                    const right = if (col+1 == line.len) 9 else line[col+1];
                    const up = if (row == 0) 9 else input[row-1][col];
                    const down = if (row+1 == input.len) 9 else input[row+1][col];
                    
                    if (cell!=9 and cell<left and cell<right and cell<up and cell<down) {
                        try list_cols.append(basin_number);
                        basin_number += 1;
                    } else {
                        try list_cols.append(null);
                    }
                }
                try list.append(list_cols.toOwnedSlice());
            }
            
            break :blk list.toOwnedSlice();
        };
        
        // Find each non-9 cell that is next to a basin and isn't a basin
        // Change that cell to be a basin with an adjacent basin number
        // Do this until all non-9 cells have a basin number
        var incomplete = true;
        while (incomplete) {
            incomplete = false;
            for (input) |line, row| {
                for (line) |cell, col| {
                    if (cell == 9) continue;
                    if (basins[row][col] != null) continue;
                    
                    const left = if (col==0) null else basins[row][col-1];
                    const right = if (col+1==line.len) null else basins[row][col+1];
                    const up = if (row==0) null else basins[row-1][col];
                    const down = if (row+1==input.len) null else basins[row+1][col];
                    
                    if (left) |num| basins[row][col] = num;
                    if (right) |num| basins[row][col] = num;
                    if (up) |num| basins[row][col] = num;
                    if (down) |num| basins[row][col] = num;
                    
                    if (basins[row][col] == null) incomplete = true;
                }
            }
        }
        
        // count how many cells are in each basin
        var counts = Map(u16,u32).init(gpa);
        for (basins) |line| {
            for (line) |cell| {
                if (cell) |num| {
                    if (counts.get(num)) |count| {
                        try counts.put(num, count+1);
                    } else {
                        try counts.put(num, 1);
                    }
                }
            }
        }
        
        // put the count values into a list then sort it
        var counts_iter = counts.iterator();
        var counts_list = std.ArrayList(u32).init(gpa);
        while (counts_iter.next()) |entry| {
            try counts_list.append(entry.value_ptr.*);
        }
        sort(u32, counts_list.items, {}, comptime desc(u32));
        //for (counts_list.items) |item| {
        //    print("{}\n", .{item});
        //}
        
        const answer = counts_list.items[0] * counts_list.items[1] * counts_list.items[2];
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
