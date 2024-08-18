
extension WordExtension on String{
  bool get noWords  => RegExp(r'\W+').hasMatch(this);
}
