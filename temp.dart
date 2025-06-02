import 'dart:io';

void main() async {
    int tally = 0;
    int start = 0;
    int end = 0;

    int A = 0;
    int B = 0;
    int C = 0;

    for (int i = 0; i < 5; i++) {
        start = DateTime.now().millisecondsSinceEpoch;
        final list = Directory("/proc/").listSync();
        for (final subdir in list) {
            tally += subdir.path.length;
        };
        end = DateTime.now().millisecondsSinceEpoch;
        C += end - start;
        
        start = DateTime.now().millisecondsSinceEpoch;
        Directory("/proc/").listSync().forEach((subdir) {
            tally += subdir.path.length;
        });
        end = DateTime.now().millisecondsSinceEpoch;
        B += end - start;
        
        start = DateTime.now().millisecondsSinceEpoch;
        await for (final subdir in Directory("/proc/").list()) {
            tally += subdir.path.length;
        }
        end = DateTime.now().millisecondsSinceEpoch;
        A += end - start;
    }

    print("await   ${A / 5}");
    print("forEach ${B / 5}");
    print("for     ${C / 5}");
    print(tally);
    
}