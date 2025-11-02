/// MIT License
/// Copyright (c) 2025 by sub131
class Named {
  final String name;
  final Map<String,String> metaData = {};
  Named(this.name);
  @override
  String toString() {
    return name;
  }
}
