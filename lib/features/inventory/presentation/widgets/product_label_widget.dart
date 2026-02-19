import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ProductLabelWidget extends StatelessWidget {
  final String productName;
  final String sku;
  final String size;
  final double price;
  final bool showPrice;

  // Definimos medidas fijas para evitar conflictos de layout en Dialogs
  static const double _cardWidth = 240.0;
  static const double _cardHeight = 180.0; // 240 / (4/3)

  const ProductLabelWidget({
    super.key,
    required this.productName,
    required this.sku,
    required this.size,
    required this.price,
    this.showPrice = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _cardWidth,
      height: _cardHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        // Sombra suave para visualización en pantalla (no sale impreso)
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. NOMBRE DEL PRODUCTO (Ajustable para no cortarse)
          SizedBox(
            height: 35, // Altura fija reservada para el título
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown, // Reduce el texto si es muy largo
                child: Text(
                  productName.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14, // Tamaño ideal máximo
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Colors.black12),
          const SizedBox(height: 6),

          // 2. ZONA CENTRAL (QR y Datos)
          Expanded(
            child: Row(
              children: [
                // QR (Izquierda)
                Expanded(
                  flex: 3,
                  child: Center(
                    child: QrImageView(
                      data: sku,
                      version: QrVersions.auto,
                      padding: EdgeInsets.zero,
                      gapless: false,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Colors.black,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // INFO LATERAL (Derecha)
                Expanded(
                  flex: 2,
                  child: Column(
                    // LÓGICA DE ALINEACIÓN:
                    // Si hay precio: Espacio entre elementos (uno arriba, uno abajo).
                    // Si NO hay precio: Centrar todo el contenido (la talla).
                    mainAxisAlignment: showPrice
                        ? MainAxisAlignment.spaceBetween
                        : MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // TALLA EN CÍRCULO
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Colors.black87,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          size,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      // PRECIO (Solo si showPrice es true)
                      if (showPrice)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              "USD",
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              "\$${price.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. SKU Texto (Pie de página, pequeño)
          const SizedBox(height: 4),
          Text(
            sku,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 7,
              color: Colors.grey,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
