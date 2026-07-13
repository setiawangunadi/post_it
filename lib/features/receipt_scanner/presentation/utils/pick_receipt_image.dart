import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../generated/l10n.dart';

/// Shows a bottom sheet to choose Camera or Gallery, then picks the image.
/// Returns the picked file path, or null if the user cancelled.
Future<String?> pickReceiptImage(BuildContext context) async {
  final l10n = S.of(context);
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined),
            title: Text(l10n.takePhoto),
            onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(l10n.chooseFromGallery),
            onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  if (source == null) return null;

  final picked =
      await ImagePicker().pickImage(source: source, imageQuality: 90);
  return picked?.path;
}
