const std = @import("std");
const Allocator = std.mem.Allocator;
const Reader = std.io.Reader;

/// Size of a model in voxels.
pub const ModelSize = extern struct {
    x: u32 = 0,
    y: u32 = 0,
    z: u32 = 0,
};

/// A voxel.
pub const Voxel = extern struct {
    x: u8,
    y: u8,
    z: u8,
    /// An index of the color of the voxel inside of the model palette.
    color: u8,
};

/// The palette of the file encoded in RGBA hex format.
pub const Palette = extern struct {
    colors: [256]u32,

    const DEFAULT_PALETTE: @This() = .{
        .colors = [_]u32{
            0x00000000, 0xffffffff, 0xffccffff, 0xff99ffff, 0xff66ffff, 0xff33ffff, 0xff00ffff, 0xffffccff,
            0xffccccff, 0xff99ccff, 0xff66ccff, 0xff33ccff, 0xff00ccff, 0xffff99ff, 0xffcc99ff, 0xff9999ff,
            0xff6699ff, 0xff3399ff, 0xff0099ff, 0xffff66ff, 0xffcc66ff, 0xff9966ff, 0xff6666ff, 0xff3366ff,
            0xff0066ff, 0xffff33ff, 0xffcc33ff, 0xff9933ff, 0xff6633ff, 0xff3333ff, 0xff0033ff, 0xffff00ff,
            0xffcc00ff, 0xff9900ff, 0xff6600ff, 0xff3300ff, 0xff0000ff, 0xffffffcc, 0xffccffcc, 0xff99ffcc,
            0xff66ffcc, 0xff33ffcc, 0xff00ffcc, 0xffffcccc, 0xffcccccc, 0xff99cccc, 0xff66cccc, 0xff33cccc,
            0xff00cccc, 0xffff99cc, 0xffcc99cc, 0xff9999cc, 0xff6699cc, 0xff3399cc, 0xff0099cc, 0xffff66cc,
            0xffcc66cc, 0xff9966cc, 0xff6666cc, 0xff3366cc, 0xff0066cc, 0xffff33cc, 0xffcc33cc, 0xff9933cc,
            0xff6633cc, 0xff3333cc, 0xff0033cc, 0xffff00cc, 0xffcc00cc, 0xff9900cc, 0xff6600cc, 0xff3300cc,
            0xff0000cc, 0xffffff99, 0xffccff99, 0xff99ff99, 0xff66ff99, 0xff33ff99, 0xff00ff99, 0xffffcc99,
            0xffcccc99, 0xff99cc99, 0xff66cc99, 0xff33cc99, 0xff00cc99, 0xffff9999, 0xffcc9999, 0xff999999,
            0xff669999, 0xff339999, 0xff009999, 0xffff6699, 0xffcc6699, 0xff996699, 0xff666699, 0xff336699,
            0xff006699, 0xffff3399, 0xffcc3399, 0xff993399, 0xff663399, 0xff333399, 0xff003399, 0xffff0099,
            0xffcc0099, 0xff990099, 0xff660099, 0xff330099, 0xff000099, 0xffffff66, 0xffccff66, 0xff99ff66,
            0xff66ff66, 0xff33ff66, 0xff00ff66, 0xffffcc66, 0xffcccc66, 0xff99cc66, 0xff66cc66, 0xff33cc66,
            0xff00cc66, 0xffff9966, 0xffcc9966, 0xff999966, 0xff669966, 0xff339966, 0xff009966, 0xffff6666,
            0xffcc6666, 0xff996666, 0xff666666, 0xff336666, 0xff006666, 0xffff3366, 0xffcc3366, 0xff993366,
            0xff663366, 0xff333366, 0xff003366, 0xffff0066, 0xffcc0066, 0xff990066, 0xff660066, 0xff330066,
            0xff000066, 0xffffff33, 0xffccff33, 0xff99ff33, 0xff66ff33, 0xff33ff33, 0xff00ff33, 0xffffcc33,
            0xffcccc33, 0xff99cc33, 0xff66cc33, 0xff33cc33, 0xff00cc33, 0xffff9933, 0xffcc9933, 0xff999933,
            0xff669933, 0xff339933, 0xff009933, 0xffff6633, 0xffcc6633, 0xff996633, 0xff666633, 0xff336633,
            0xff006633, 0xffff3333, 0xffcc3333, 0xff993333, 0xff663333, 0xff333333, 0xff003333, 0xffff0033,
            0xffcc0033, 0xff990033, 0xff660033, 0xff330033, 0xff000033, 0xffffff00, 0xffccff00, 0xff99ff00,
            0xff66ff00, 0xff33ff00, 0xff00ff00, 0xffffcc00, 0xffcccc00, 0xff99cc00, 0xff66cc00, 0xff33cc00,
            0xff00cc00, 0xffff9900, 0xffcc9900, 0xff999900, 0xff669900, 0xff339900, 0xff009900, 0xffff6600,
            0xffcc6600, 0xff996600, 0xff666600, 0xff336600, 0xff006600, 0xffff3300, 0xffcc3300, 0xff993300,
            0xff663300, 0xff333300, 0xff003300, 0xffff0000, 0xffcc0000, 0xff990000, 0xff660000, 0xff330000,
            0xff0000ee, 0xff0000dd, 0xff0000bb, 0xff0000aa, 0xff000088, 0xff000077, 0xff000055, 0xff000044,
            0xff000022, 0xff000011, 0xff00ee00, 0xff00dd00, 0xff00bb00, 0xff00aa00, 0xff008800, 0xff007700,
            0xff005500, 0xff004400, 0xff002200, 0xff001100, 0xffee0000, 0xffdd0000, 0xffbb0000, 0xffaa0000,
            0xff880000, 0xff770000, 0xff550000, 0xff440000, 0xff220000, 0xff110000, 0xffeeeeee, 0xffdddddd,
            0xffbbbbbb, 0xffaaaaaa, 0xff888888, 0xff777777, 0xff555555, 0xff444444, 0xff222222, 0xff111111,
        },
    };
};

/// A model in a .vox file.
pub const Model = struct {
    size: ModelSize,
    voxels: []Voxel = &[_]Voxel{},

    pub fn deinit(self: *const @This(), allocator: Allocator) void {
        allocator.free(self.voxels);
    }
};

/// A parsed .vox file.
pub const VoxFile = struct {
    format_version: u32 = 150,
    models: []Model = &[_]Model{},
    palette: Palette = Palette.DEFAULT_PALETTE,

    //TODO: add support for MV new material chunks

    pub fn from_reader(reader: *Reader, allocator: Allocator) !VoxFile {
        var file: VoxFile = .{};

        // Checking file header by taking the first 4 bytes
        const header = try reader.take(4);
        if (!std.mem.eql(u8, header, "VOX "))
            return error.VoxFileInvalidHeader;

        // Getting file version by peeking the next int
        const format_ver = try reader.takeInt(u32, .little);
        file.format_version = format_ver;

        var current_model: usize = 0;

        var models: std.ArrayList(Model) = try .initCapacity(allocator, 1);
        errdefer models.deinit(allocator);
        errdefer for (models.items) |model| {
            model.deinit(allocator);
        };

        while (true) {
            read_chunk(reader, &file, &models, &current_model, allocator) catch |err| switch (err) {
                error.EndOfStream => break,
                else => return err,
            };
        }

        file.models = try models.toOwnedSlice(allocator);
        return file;
    }

    pub fn deinit(self: *const @This(), allocator: Allocator) void {
        for (self.models) |model| {
            model.deinit(allocator);
        }
        allocator.free(self.models);
    }
};

/// Struct for a chunk header
const ChunkHeader = extern struct {
    id: [4]u8,
    content_size: u32,
    children_size: u32,
};

fn read_chunk(reader: *Reader, file: *VoxFile, models: *std.ArrayList(Model), current_model: *usize, alloc: Allocator) !void {
    const chunk_header = try reader.takeStruct(ChunkHeader, .little);

    if (std.mem.eql(u8, &chunk_header.id, "MAIN")) {
        return;
    } else if (std.mem.eql(u8, &chunk_header.id, "SIZE")) {
        const size = try reader.takeStruct(ModelSize, .little);
        try models.append(alloc, Model{ .size = size });
    } else if (std.mem.eql(u8, &chunk_header.id, "XYZI")) {
        const num_voxels = try reader.takeInt(u32, std.builtin.Endian.little);

        const voxels: []Voxel = try alloc.alloc(Voxel, @intCast(num_voxels));
        errdefer alloc.free(voxels);

        for (voxels) |*voxel| {
            voxel.* = try reader.takeStruct(Voxel, .little);
        }

        models.items[current_model.*].voxels = voxels;
        current_model.* += 1;
    } else if (std.mem.eql(u8, &chunk_header.id, "RGBA")) {
        const palette = try reader.takeStruct(Palette, .little);
        file.palette = palette;
    } else {
        try reader.discardAll(chunk_header.content_size);
    }
}

test "Loading a basic model" {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .init;
    const alloc = gpa.allocator();
    defer _ = gpa.deinit();

    // allocate a buffer for the file content reader
    const reader_buffer = try alloc.alloc(u8, 2048);
    defer alloc.free(reader_buffer);

    const file = try std.fs.cwd().openFile("testing/chicken.vox", .{ .mode = .read_only });
    defer file.close();

    var reader = file.reader(reader_buffer);

    const voxfile = try VoxFile.from_reader(&reader.interface, alloc);
    defer voxfile.deinit(alloc);

    try std.testing.expect(voxfile.models.len == 1);

    const model = voxfile.models[0];

    try std.testing.expectEqual(40, model.size.x);
    try std.testing.expectEqual(40, model.size.y);
    try std.testing.expectEqual(40, model.size.z);

    for (model.voxels) |voxel| {
        if (voxel.x == 22 and voxel.y == 13 and voxel.z == 24) {
            try std.testing.expectEqual(voxel.color, 18);
        }
    }
}

test "Loading a multi model file" {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .init;
    const alloc = gpa.allocator();
    defer _ = gpa.deinit();

    // allocate a buffer for the file content reader
    const reader_buffer = try alloc.alloc(u8, 2048);
    defer alloc.free(reader_buffer);

    const file = try std.fs.cwd().openFile("testing/multi_model.vox", .{ .mode = .read_only });
    defer file.close();

    var reader = file.reader(reader_buffer);

    const voxfile = try VoxFile.from_reader(&reader.interface, alloc);
    defer voxfile.deinit(alloc);

    try std.testing.expect(voxfile.models.len == 2);
}
