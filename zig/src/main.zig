const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var rnd = std.rand.DefaultPrng.init(0);

    // Get user input
    const height: u64 = try ask_for_number("Height: ");
    const width: u64 = try ask_for_number("Width: ");
    // _ = try ask_for_string("Living cell symbol: ");
    // _ = try ask_for_string("Dead cell symbol: ");

    const matrix: [][]u64 = try allocator.alloc([]u64, height); // [[1,0,1,0],[0,1,0,0]]

    for (0..height) |i| {
        const row: []u64 = try allocator.alloc(u64, width);
        matrix[i] = row;
    }

    for (0..height) |x| {
        for (0..width) |y| {
            //Random seed
            matrix[x][y] = if (rnd.random().boolean()) 1 else 0;
            print("{} ", .{matrix[x][y]});
        }
        print("\n", .{});
    }

    // printMatrix(testMat);

    // var generation: u16 = 0;
    //
    // while (generation <= 100) {
    //     generation += 1;
    // }

    std.debug.print("Width = {}, height = {}", .{ width, height });

    // Dealloc matrix
    for (matrix) |row| {
        _ = allocator.free(row);
    }
    _ = allocator.free(matrix);
}

fn ask_for_number(str: []const u8) !u64 {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var buf: [10]u8 = undefined;

    print("{s}", .{str});
    try stdout.print("", .{});

    if (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |user_input| {
        print("Typeof {s}: {}\n", .{ user_input, @TypeOf(user_input) });
        return std.fmt.parseInt(u64, user_input, 10);
    } else {
        return @as(u64, 0);
    }
}

fn ask_for_string(str: []const u8) ![]u8 {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var buf: [10]u8 = undefined;

    print("{s}", .{str});
    try stdout.print("", .{});

    if (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |user_input| {
        return user_input;
    } else {
        return null;
    }
}
