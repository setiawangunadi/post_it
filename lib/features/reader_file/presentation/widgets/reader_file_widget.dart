import 'package:flutter/material.dart';
import '../../domain/entities/reader_file.dart';

class ReaderFileWidget extends StatelessWidget {
  final ReaderFile data;
  const ReaderFileWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Text(data.id);
  }
}
