# Mantener clases de Isar para evitar errores en Release
-keep class io.isar.** { *; }
-keep class * extends io.isar.IsarCollection { *; }
-keep class * implements io.isar.IsarLink { *; }
-keep @io.isar.Collection class * { *; }
-keep @io.isar.Index class * { *; }

# Google ML Kit - Idiomas opcionales no incluidos en el APK base
# (Generado automáticamente por Android Gradle Plugin)
-dontwarn com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions
