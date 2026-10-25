import 'package:flutter/foundation.dart';

class CookTimer {
  CookTimer(this.id, this.label, this.total, this.endsAt);
  final int id;
  final String label;
  final Duration total;
  final DateTime endsAt;
  bool done = false;
}

/// Several kitchen timers at once. They run on the clock (end time), so a stalled UI never makes them drift.
class CookTimers extends ChangeNotifier {
  CookTimers({DateTime Function()? clock, this.onDone}) : _clock = clock ?? DateTime.now;
  final DateTime Function() _clock;

  /// Called once per timer when it runs out.
  final void Function(CookTimer t)? onDone;
  final timers = <CookTimer>[];
  int _next = 1;

  CookTimer start(int seconds, String label) {
    final t = CookTimer(_next++, label, Duration(seconds: seconds), _clock().add(Duration(seconds: seconds)));
    timers.add(t);
    notifyListeners();
    return t;
  }

  Duration remaining(CookTimer t) {
    final d = t.endsAt.difference(_clock());
    return d.isNegative ? Duration.zero : d;
  }

  double fraction(CookTimer t) => t.total.inSeconds == 0 ? 0 : remaining(t).inMilliseconds / t.total.inMilliseconds;

  void cancel(CookTimer t) {
    timers.remove(t);
    notifyListeners();
  }

  bool get running => timers.any((t) => !t.done);

  /// Call about once a second.
  void tick() {
    for (final t in timers) {
      if (!t.done && remaining(t) == Duration.zero) {
        t.done = true;
        onDone?.call(t);
      }
    }
    notifyListeners();
  }
}

String clockText(Duration d) {
  final s = (d.inMilliseconds + 999) ~/ 1000; // a timer shows the second it is still in
  final h = s ~/ 3600, m = (s % 3600) ~/ 60, x = s % 60;
  String two(int v) => v.toString().padLeft(2, '0');
  return h > 0 ? '$h:${two(m)}:${two(x)}' : '${two(m)}:${two(x)}';
}
