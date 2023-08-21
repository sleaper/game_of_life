const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;

const Cell = enum(u8) { alive = 1, dead = 0 };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const height: u64 = try ask_for_number("Height: ");
    const width: u64 = try ask_for_number("Width: ");
    // const generations: u64 = try ask_for_number("Number of generations: ");
    // const live_symbol = try ask_for_string("Living cell symbol: ", allocator);
    // const dead_symbol = try ask_for_string("Dead cell symbol: ", allocator);

    var matrix: [][]u8 = undefined;
    matrix = try initMatrix(width, height, allocator);
    randomizeMatrix(matrix);

    while (true) {
        print_matrix(matrix);
        try step(&matrix, width, height, allocator);
    }
}

fn step(matrix: *[][]u8, width: usize, height: usize, allocator: Allocator) !void {
    var newMatrix: [][]u8 = undefined;
    newMatrix = try initMatrix(width, height, allocator);

    for (matrix.*, 0..) |row, x| {
        for (row, 0..) |cell, y| {
            const aliveNeighbors = countAliveNeighbors(matrix.*, x, y, width, height);
            //ERROR here
            switch (cell) {
                @intFromEnum(Cell.alive) => {
                    if (aliveNeighbors < 2 or aliveNeighbors > 3) {
                        newMatrix[x][y] = @intFromEnum(Cell.dead);
                    } else {
                        newMatrix[x][y] = @intFromEnum(Cell.alive);
                    }
                },
                @intFromEnum(Cell.dead) => {
                    if (aliveNeighbors == 3) {
                        newMatrix[x][y] = @intFromEnum(Cell.alive);
                    } else {
                        newMatrix[x][y] = @intFromEnum(Cell.dead);
                    }
                },
                else => newMatrix[x][y] = @intFromEnum(Cell.alive),
            }
        }
    }

    for (matrix.*, 0..) |row, x| {
        for (row, 0..) |_, y| {
            matrix[x][y] = newMatrix[x][y];
        }
    }
}

fn countAliveNeighbors(matrix: [][]u8, x: usize, y: usize, width: usize, height: usize) usize {
    var count: usize = 0;
    var k: isize = @as(isize, @intCast(x)) - 1;
    while (k <= x + 1) {
        var l: isize = @as(isize, @intCast(y)) - 1;
        while (l <= y + 1) {
            if ((k >= 0 and k < height and l >= 0 and l < width) and (k != x or l != y)) {
                const cK = @as(usize, @intCast(k));
                const cL = @as(usize, @intCast(l));
                if (matrix[cK][cL] == @intFromEnum(Cell.alive)) {
                    count += 1;
                }
            }
            l += 1;
        }
        k += 1;
    }

    return count;
}

fn initMatrix(width: u64, height: u64, allocator: Allocator) ![][]u8 {
    var matrix = try allocator.alloc([]u8, height);
    for (matrix) |*row| {
        row.* = try allocator.alloc(u8, width);
    }
    return matrix;
}

fn randomizeMatrix(matrix: [][]u8) void {
    var rnd = std.rand.DefaultPrng.init(0);
    for (matrix) |row| {
        for (row) |*cell| {
            cell.* = if (rnd.random().boolean()) @intFromEnum(Cell.alive) else @intFromEnum(Cell.dead);
        }
    }
}

fn print_matrix(matrix: [][]u8) void {
    for (matrix) |row| {
        for (row) |cell| {
            print("{} ", .{cell});
        }
        print("\n", .{});
    }
}

fn ask_for_number(str: []const u8) !u64 {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    while (true) {
        var buf: [10]u8 = undefined;
        var buf_stream = std.io.fixedBufferStream(&buf);

        std.debug.print("{s}", .{str});
        try stdout.print("", .{});

        stdin.streamUntilDelimiter(buf_stream.writer(), '\n', null) catch continue;

        const buf_trimmed = std.mem.trim(u8, buf_stream.getWritten(), " \n\r");
        var num = std.fmt.parseInt(u64, buf_trimmed, 10) catch continue;

        if (num > 0) return num;
    }
    return @as(u64, 0);
}

fn ask_for_string(str: []const u8, allocator: Allocator) ![]const u8 {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();
    var buf = try allocator.alloc(u8, 2);
    var buf_stream = std.io.fixedBufferStream(buf);

    std.debug.print("{s}", .{str});
    try stdout.print("", .{});

    try stdin.streamUntilDelimiter(buf_stream.writer(), '\n', null);
    const buf_trimmed = std.mem.trim(u8, buf_stream.getWritten(), " \n\r");
    return buf_trimmed;
}
