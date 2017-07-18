
class Diff<T> {
  final List<T> different = <T>[];
  final List<T> onlyFirst = <T>[];
  final List<T> onlySecond = <T>[];
  final List<T> both = <T>[];
  Diff(Iterable<T> a, Iterable<T> b) {
    for (T ta in a) {
      bool found = false;
      for (T tb in b) {
        if (ta == tb) {
          found = true;
          break;
        }
      }
      if (!found) {
        different.add(ta);
        onlyFirst.add(ta);
      } else {
        both.add(ta);
      }
    }

    for (T tb in b) {
      bool found = false;
      for (T ta in a) {
        if (ta == tb) {
          found = true;
          break;
        }
      }
      if (!found) {
        onlySecond.add(tb);
        different.add(tb);
      }
    }
  }
}