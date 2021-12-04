const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day04.txt");

pub fn main() !void {
    const input = outer: {
        var iter = tokenize(u8, data, "\n\r ");
        const numbers = blk: { // drawing numbers
            var numbers = std.ArrayList(u8).init(gpa);
            const line1 = iter.next().?;
            var line1_tokens = tokenize(u8, line1, ",");
            while (line1_tokens.next()) |s| {
                const n = try parseInt(u8, s, 10);
                try numbers.append(n);
            }
            break :blk numbers.toOwnedSlice();
        };
        const boards = blk: { // boards
            var boards = std.ArrayList([5][5]u8).init(gpa);
            var index: usize = 0;
            var board: [5][5]u8 = undefined;
            while(iter.next()) |line| {
                const i: usize = (index / 5) % 5;
                const j: usize = index % 5;
                const n = try parseInt(u8, line, 10);
                board[i][j] = n;
                if (i==4 and j==4) try boards.append(board);
                index += 1;
            }
            break :blk boards.toOwnedSlice();
        };
        break :outer .{.numbers = numbers, .boards = boards};
    };
    const numbers = input.numbers;
    const boards = input.boards;
    
    { // part 1
        var winning_board_index: usize = 0;
        var winning_number_index: usize = 0;
        
        loop: for (numbers) |_, index| {
            for (boards) |board, board_index| {
                if (isWinner(numbers[0..index+1], board)) {
                    winning_board_index = board_index;
                    winning_number_index = index;
                    break :loop;
                }
            }
        }
        
        const win_board = boards[winning_board_index];
        const win_nums = numbers[0..winning_number_index+1];
        
        // put all numbers from winning board into one array
        var board_nums: [25]u8 = undefined;
        {
            var index: usize = 0;
            for (win_board) |line| {
                for (line) |n| {
                    board_nums[index] = n;
                    index += 1;
                }
            }
        }
        
        var sum: u32 = 0;
        for (board_nums) |n| {
            for (win_nums) |m| {
                if (n == m) {
                    break;
                }
            } else {
                sum += n;
            }
        }
        
        print("{}\n", .{sum * win_nums[win_nums.len-1]});
        
    }
    
    { // part 2
        var max_board_index: usize = 0;
        var max_index: usize = 0;
        for (boards) |board, board_index| {
            for (numbers) |_, index| {
                if (isWinner(numbers[0..index+1], board)) {
                    if (index > max_index) {
                        max_board_index = board_index;
                        max_index = index;
                    }
                    break;
                }
            }
        }
        
        const win_board = boards[max_board_index];
        const win_nums = numbers[0..max_index+1];
        
        // put all numbers from winning board into one array
        var board_nums: [25]u8 = undefined;
        {
            var index: usize = 0;
            for (win_board) |line| {
                for (line) |n| {
                    board_nums[index] = n;
                    index += 1;
                }
            }
        }
        
        var sum: u32 = 0;
        for (board_nums) |n| {
            for (win_nums) |m| {
                if (n == m) {
                    break;
                }
            } else {
                sum += n;
            }
        }
        
        print("{}\n", .{sum * win_nums[win_nums.len-1]});
    }
}

fn isWinner (numbers: []u8, board: [5][5]u8) bool {
    if (numbers.len < 5) return false;
    { // check each row
        var i: usize = 0;
        while (i < 5) {
            var j: usize = 0;
            var allMatch = true;
            while (j < 5) {
                const n = board[i][j];
                for (numbers) |m| {
                    if (m == n) break;
                } else {
                    allMatch = false;
                }
                j += 1;
            }
            if (allMatch) return true;
            i += 1;
        }
    }
    { // check each column
        var j: usize = 0;
        while (j < 5) {
            var i: usize = 0;
            var allMatch = true;
            while (i < 5) {
                const n = board[i][j];
                for (numbers) |m| {
                    if (m == n) break;
                } else {
                    allMatch = false;
                }
                i += 1;
            }
            if (allMatch) return true;
            j += 1;
        }
    }

    return false;
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
