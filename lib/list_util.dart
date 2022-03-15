/// 除非确实需要分组, 否则不宜分组, 此会降低性能.
/// 比如把某个组传递给另外的函数使用
List<List<T>> groupByPartSize<T>(List<T> array, int partSize) {
  final List<List<T>> groups = [];
  for (var eachStart = 0; eachStart < array.length;) {
    var eachEnd = eachStart + partSize;
    if (eachEnd > array.length) eachEnd = array.length;
    // if "eachEnd" > "array.length", slice() will use "array.length"
    groups.add(array.sublist(eachStart, eachEnd));
    eachStart = eachEnd;
  }
  return groups;
}

bool bothHave(List<dynamic> l1, List<dynamic> l2) {
  final len = l1.length >= l2.length ? l1.length : l2.length;
  for (var i = 0; i < len; i++) {
    if (l1[i] != l2[i]) {
      return false;
    }
  }
  return true;
}
