import '../../domain/entities/reader_file.dart';

class ReaderFileModel extends ReaderFile {
  const ReaderFileModel({required super.id});

  factory ReaderFileModel.fromJson(Map<String, dynamic> json) {
    return ReaderFileModel(
      id: json['id'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'id': id};
}
