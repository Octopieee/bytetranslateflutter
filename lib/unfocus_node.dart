import 'package:flutter/material.dart';

class UnfocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
