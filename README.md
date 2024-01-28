# `zvox`

### Installation

Using Zig's package manager.

### Usage

```zig

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const alloc = gpa.allocator();
defer _ = gpa.deinit();

const file = try std.fs.cwd().openFile("testing/chicken.vox", .{ .mode = .read_only });
defer file.close();

const reader = file.reader();
const voxfile = try VoxFile.from_reader(reader, alloc);
std.log.info("Got {} models loaded", voxfile.models.len);
defer voxfile.deinit(alloc);
```

### License

Licensed under the MIT License.