const std = @import("std");
const day07 = @import("day07");

fn read_line(reader: *std.io.Reader, line: *std.io.Writer.Allocating) !void {
    line.clearRetainingCapacity();
    _ = try reader.streamDelimiter(&line.writer, '\n');
    _ = reader.toss(1);
}

fn solve(reader: *std.io.Reader, ally: std.mem.Allocator) !struct { u64, u64 } {
    var line = std.Io.Writer.Allocating.init(ally);
    defer line.deinit();

    try read_line(reader, &line);

    var dp = try ally.alloc(u64, line.written().len);
    var dp_next = try ally.alloc(u64, line.written().len);
    for (line.written(), 0..) |b, i| {
        if (b == 'S') {
            dp[i] = 1;
        } else {
            dp[i] = 0;
        }
    }

    var res1: u64 = 0;

    while (true) {
        _ = read_line(reader, &line) catch |err| {
            if (err == error.EndOfStream) break else return err;
        };
        for (dp_next) |*b| b.* = 0;
        for (line.written(), dp, 0..) |b, cur, i| {
            if (b == '^') {
                if (cur > 0) {
                    res1 += 1;
                    dp_next[i - 1] += cur;
                    dp_next[i + 1] += cur;
                }
            } else {
                dp_next[i] += cur;
            }
        }
        // Swap rows.
        const temp = dp;
        dp = dp_next;
        dp_next = temp;
    }

    var res2: u64 = 0;
    for (dp) |x| res2 += x;

    return .{ res1, res2 };
}

pub fn main() !void {
    var timer = try std.time.Timer.start();

    // 4 MiB ends up being enough.
    var buffer: [4 << 20]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const ally = fba.allocator();

    var stdin_buffer: [1024]u8 = undefined;
    var stdin_reader = std.fs.File.stdin().reader(&stdin_buffer);
    const stdin = &stdin_reader.interface;

    const result = try solve(stdin, ally);
    const elapsed_ns: f64 = @floatFromInt(timer.read());

    std.debug.print("Part 1: {d}\n", .{result[0]});
    std.debug.print("Part 2: {d}\n", .{result[1]});
    std.debug.print("Elapsed: {d} ms\n", .{elapsed_ns / std.time.ns_per_ms});
}
