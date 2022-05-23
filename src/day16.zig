const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day16.txt");

const PacketType = enum(u3) {
    literal_value = 4,
    operator,
};

const Payload = union(PacketType) {
    literal_value: u64,
};

const Packet = struct {
    version: u3,
    type: PacketType,
    payload: Payload,
};

fn readLiteralValue(reader: anytype) u64 {
    var reader_ = reader;
    var ret: u64 = 0;
    var count: usize = 0;
    while (true) : (count += 1) {
        var num_bits: usize = undefined;
        const group_type = try reader_.readBits(u1, 1, &num_bits);
        assert(num_bits == 1);
        const group_bits = try reader_.readBits(u4, 4, &num_bits);
        assert(num_bits == 4);
        ret <<= 4;
        ret &= group_bits;
        if (group_type == 0) break;
    }
    return ret;
}

pub fn main() !void {
    const input: []u8 = blk: {
        var iter = tokenize(u8, data, "\r\n");
        const line = iter.next().?;
        var buf = try gpa.alloc(u8, line.len/2);
        const bytes = try std.fmt.hexToBytes(buf, line);
        break :blk bytes;
    };
    
    if (false) {
    print("\n", .{});
    for (input) |c| {
        print("{b:0>8}", .{c});
    }
    print("\n\n", .{});
    }
    
    var bit_stream = std.io.bitReader(.Big, std.io.fixedBufferStream(input).reader());
    var num_bits: usize = undefined;
    
    const version = try bit_stream.readBits(u3, 3, &num_bits);
    print("version: {}\n", .{version});
    
    const type_id = try bit_stream.readBits(u3, 3, &num_bits);
    print("type: {}\n", .{type_id});
    
    if (type_id == 4) {
        const literal = readLiteralValue(bit_stream);
        print("{}\n", .{literal});
    } else {
        const length_type_id = try bit_stream.readBits(u1, 1, &num_bits);
        if (length_type_id == 1) {
            const length_bits = try bit_stream.readBits(u15, 15, &num_bits);
            print("length in bits: {}\n", .{length_bits});
        } else {
            const length_pkts = try bit_stream.readBits(u11, 11, &num_bits);
            print("length in subpackets: {}\n", .{length_pkts});
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
