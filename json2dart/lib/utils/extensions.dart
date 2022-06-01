extension EString on String {
  String get upper => toUpperCase();
  String get firstUpper =>
      this.substring(0, 1).toUpperCase() + this.substring(1);
  String get camel {
    if (contains("_")) {
      List<String> splited = split("_");
      return splited.map((e) {
        if (splited.first != e) {
          return e.firstUpper;
        }
        return e;
      }).join("");
    }
    return this;
  }
}
