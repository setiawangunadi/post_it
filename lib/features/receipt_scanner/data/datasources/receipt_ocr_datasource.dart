import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../../../core/error/exception.dart';
import '../../../../generated/l10n.dart';

abstract class ReceiptOcrDataSource {
  /// Runs on-device text recognition on the image at [imagePath] and
  /// returns the full recognition result, including per-line positions
  /// needed to reconstruct the receipt's row/column layout.
  Future<RecognizedText> recognize(String imagePath);
}

class ReceiptOcrDataSourceImpl implements ReceiptOcrDataSource {
  final TextRecognizer _recognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  @override
  Future<RecognizedText> recognize(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      return await _recognizer.processImage(inputImage);
    } catch (_) {
      throw ServerException(S.current.failedToRecognizeText);
    }
  }

  void dispose() {
    _recognizer.close();
  }
}
