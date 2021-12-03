const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day03.txt");

pub fn main() !void {
    // create list
    var list = std.ArrayList(u12).init(gpa);
    defer list.deinit();
    
    // parse data and append to list
    {
        var iter = tokenize(u8, data, "\n\r");
        while(iter.next()) |line| {
            const n = try parseInt(u12, line, 2);
            try list.append(n);
        }
    }
    
    { // Part 1
        // sum the bits of each position
        // the number of 1 bits is the sum
        // the number of 0 bits it the array length minus the sum
        var sums = [_]u32{0} ** 12;
        for (list.items) |n| {
            var j: u4 = 0;
            for (sums) |*sum| {
                sum.* += (n >> j) & 1;
                j += 1;
            }
        }
        //print("{d}\n", .{sums});
        var gamma: u12 = undefined;
        for (sums) |sum, j| {
            if (list.items.len/2 > sum) {
                gamma |= @as(u12,1) << @truncate(u4, j);
            } else {
                gamma &= ~(@as(u12,1) << @truncate(u4, j));
            }
        }
        const answer : u32 = @as(u32, gamma) * @as(u32, ~gamma);
        print("{d}\n", .{answer});
    }
    
    { // Part 2
        const num1: u32 = filter1(list.items, 11)[0];        
        const num2: u32 = filter2(list.items, 11)[0];
        print("{d}\n", .{num1*num2});
    }
}

// recursively remove the elements from the slice based on the bit criteria
fn filter1 (numbers: []u12, bit: u4) []u12 {
    var nums = numbers;
    assert (nums.len > 0);

    sort(u12, nums, {}, comptime asc(u12));
    
    // count the number of zeros and the number of ones at the given bit
    const count_ones = blk: {
        var count: u32 = 0;
        for (nums) |n| {
            count += 1 & (n >> bit);
        }
        break :blk count;
    };
    const count_zeros = nums.len - count_ones;
    
    // use the counts to determine which side of array to keep
    if (count_ones >= count_zeros) {
        nums = nums[count_zeros..nums.len];
    } else {
        nums = nums[0..(nums.len-count_ones)];
    }
    
    assert (nums.len > 0);
    if (nums.len == 1) {
        return nums;
    } else {
        return filter1(nums, bit-1);
    }
}

fn filter2 (numbers: []u12, bit: u4) []u12 {
    var nums = numbers;
    assert (nums.len > 0);
    
    sort(u12, nums, {}, comptime asc(u12));
    
    // count the number of zeros and the number of ones at the given bit
    const count_ones = blk: {
        var count: u32 = 0;
        for (nums) |n| {
            count += 1 & (n >> bit);
        }
        break :blk count;
    };
    const count_zeros = nums.len - count_ones;
    
    // use the counts to determine which side of array to keep
    if (count_ones < count_zeros) {
        nums = nums[count_zeros..nums.len];
    } else {
        nums = nums[0..(nums.len-count_ones)];
    }
    
    assert (nums.len > 0);
    if (nums.len == 1) {
        return nums;
    } else {
        return filter2(nums, bit-1);
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
