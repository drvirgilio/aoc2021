const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day17.txt");

const int = i64;

const Target = struct {
    min_x: int,
    max_x: int,
    min_y: int,
    max_y: int,
};

// We can do a brute search of all velocities and check each one for a hit on target
// To get the bounds of our search, we need to consider the following.
// v_x must be >0 to hit target so lower bound is zero
// v_x must be less than max_x otherwise it would miss the target so max_x is the upper bound inclusive
// v_y must be greater than min_y otherwise it would miss the target so min_y is the lower bound inclusive
// When shooting up, the projectile must come down. It comes exactly to zero with velocity -v0-1
// So on the next iteration, y will land at y=-v0-1. So min_y=-v0-1 -> -min_y-1=v0 is the upper bound

pub fn main() !void {
    const target = Target {.min_x = 135, .max_x = 155, .min_y=-102 , .max_y =-78 };
    //const target = Target {.min_x = 20, .max_x=30, .min_y=-10, .max_y=-5};
    var max_y_hit: int = 0;
    var count :int = 0;
    var vx_init:int = 0;
    while (vx_init <= target.max_x) : (vx_init += 1) {
        var vy_init:int = target.min_y;
        while (vy_init <= -target.min_y-1) : (vy_init += 1) {
            var max_y: int = 0;
            var vx = vx_init;
            var vy = vy_init;
            var x:int = 0;
            var y:int = 0;
            while (x <= target.max_x and y >= target.min_y) {
                max_y = max(max_y, y);
                //print("pos:{},{} vel:{},{}\n", .{x,y,vx,vy});
                if (x <= target.max_x and x >= target.min_x and y >= target.min_y and y <= target.max_y) {
                    max_y_hit = max(max_y_hit, max_y);
                    count += 1;
                    break;
                }
                x += vx;
                y += vy;
                vx = if (vx==0) 0 else if (vx>0) vx-1 else vx+1;
                vy -= 1;
            }
        }
    }
    assert(max_y_hit==5151);
    assert(count == 968);
    print("{}\n", .{max_y_hit});
    print("{}\n", .{count});
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
