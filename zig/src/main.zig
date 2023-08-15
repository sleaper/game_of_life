const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var rnd = std.rand.DefaultPrng.init(0);

    // Get user input
    const height: u64 = try ask_for_number("Height: ");
    const width: u64 = try ask_for_number("Width: ");
    const generations: u64 = try ask_for_number("Number of generations: ");
    const live_symbol = try ask_for_string("Living cell symbol: ", &allocator);
    const dead_symbol = try ask_for_string("Dead cell symbol: ", &allocator);

    print("Live: {s}\n", .{live_symbol});
    print("Dead: {s}\n", .{dead_symbol});

    // It has to be 3D array, because string (for symbols) is []u8
    const matrix: [][][]u8 = try allocator.alloc([][]u8, height);

    for (0..height) |i| {
        const row: [][]u8 = try allocator.alloc([]u8, width);
        matrix[i] = row;
    }

    var generation: u16 = 0;

    //Life loop
    while (generation <= generations) {
        std.time.sleep(250000000);

        //Border
        for (0..width) |i| {
            if (i == 3) print("Generation: {}", .{generation}) else print("- ", .{});
        }

        print("\n", .{});

        //Draw matrix
        for (0..height) |x| {
            for (0..width) |y| {
                //Random seed
                matrix[x][y] = if (rnd.random().boolean()) live_symbol else dead_symbol;
                print("{s} ", .{matrix[x][y]});
            }
            print("\n", .{});
        }

        // Make the population alive

        generation += 1;
    }

    std.debug.print("Width = {}, height = {}", .{ width, height });

    // Dealloc matrix
    for (matrix) |row| {
        _ = allocator.free(row);
    }
    _ = allocator.free(matrix);
    _ = allocator.free(dead_symbol);
    _ = allocator.free(live_symbol);
}

fn ask_for_number(str: []const u8) !u64 {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    while (true) {
        var buf: [10]u8 = undefined;

        print("{s}", .{str});
        try stdout.print("", .{});

        // Deprecated use streamUntilDelimiter instead, now sure how yet
        if (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |user_input| {
            var num = std.fmt.parseInt(u64, user_input, 10) catch continue;
            if (num > 0) return num;
        }
    }
    return @as(u64, 0);
}

fn ask_for_string(str: []const u8, allocator: *const Allocator) ![]u8 {
    const buf = try allocator.alloc(u8, 2);
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    print("{s}", .{str});
    try stdout.print("", .{});

    if (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |user_input| {
        return user_input;
    } else {
        return "";
    }
}
