import 'dart:collection';

class IdList<T extends dynamic> extends MapBase<String, T> {
  final Map<String, T> _innerMap = <String, T>{};

  IdList();

  @override
  T operator [](String index) => _innerMap[index];
  @override
  void operator []=(String index, T value) {
    _innerMap[index] = value;
  }

  @override
  void clear() => _innerMap.clear();

  @override
  Iterable<String> get keys => _innerMap.keys;

  @override
  T remove(String key) => _innerMap.remove(key);

  void add(T item) {
    this._innerMap[item.id] = item;
  }

  void addAllItems(Iterable<T> items) {
    for (T item in items) this.add(item);
  }
}
