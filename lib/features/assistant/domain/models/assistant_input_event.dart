import 'package:inventario_v2/core/db/app_database.dart';

sealed class AssistantInputEvent {
  const AssistantInputEvent();
}

final class TextInputEvent extends AssistantInputEvent {
  final String text;
  const TextInputEvent(this.text);
}

final class VoiceInputEvent extends AssistantInputEvent {
  final String transcript;
  const VoiceInputEvent(this.transcript);
}

final class BarcodeInputEvent extends AssistantInputEvent {
  final String barcode;
  final Producto? resolvedProduct;
  const BarcodeInputEvent({required this.barcode, this.resolvedProduct});
}
