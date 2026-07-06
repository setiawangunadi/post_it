# ML Kit text recognition ships optional per-script recognizers (Chinese,
# Devanagari, Japanese, Korean); we only use the default (Latin) recognizer,
# so those classes aren't bundled and R8 can't resolve them. Safe to ignore.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
