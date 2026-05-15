import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart' show TableHelper;
import 'package:printing/printing.dart';

class PdfGenerator {
  static Future<void> generateMovementPdf(Map<String, dynamic> data) async {
    final pdf = pw.Document();
    final currency = NumberFormat.currency(symbol: "C\$ ", decimalDigits: 2);

    final String title = data['tipo'];
    final String fecha = DateFormat(
      'dd MMM yyyy, hh:mm a',
    ).format(data['fecha']);
    final String referencia = data['referencia_externa'];
    final String orign = data['origen'];
    final String destin = data['destino'];
    final String estado = data['estado'];
    final String usuario = data['usuario'];

    final items = data['items'] as List<dynamic>;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "Reporte de Movimiento",
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(estado, style: pw.TextStyle(fontSize: 16)),
                ],
              ),
              pw.SizedBox(height: 20),

              // General Info
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Tipo de Movimiento: $title",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text("Fecha: $fecha"),
                    pw.Text("Referencia: $referencia"),
                    pw.Text("Origen: $orign"),
                    pw.Text("Destino: $destin"),
                    pw.Text("Usuario: $usuario"),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Table Products
              pw.Text(
                "Detalle de Productos",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),

              TableHelper.fromTextArray(
                context: context,
                border: pw.TableBorder.all(color: PdfColors.grey300),
                headerAlignment: pw.Alignment.centerLeft,
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.blueGrey,
                ),
                cellAlignment: pw.Alignment.centerLeft,
                headers: [
                  'Nombre del Producto',
                  'Cantidad',
                  'Precio Compra',
                  'Precio Venta',
                  'Subtotal',
                ],
                data: items.expand((dynamic item) {
                  final List<List<dynamic>> rows = [];

                  // Fila Principal del Producto
                  rows.add([
                    item['nombre'],
                    item['cantidad']?.toString() ?? "0",
                    currency.format(item['precio_compra'] ?? 0),
                    currency.format(item['precio_venta'] ?? 0),
                    currency.format(
                      (item['cantidad'] ?? 0) * (item['precio_compra'] ?? 0),
                    ),
                  ]);

                  // Si hay variantes, agregar sub-filas
                  final variaciones = item['variantes'] as List<dynamic>? ?? [];
                  if (variaciones.isNotEmpty) {
                    for (var v in variaciones) {
                      final String talla = v['talla']?.toString() ?? "General";
                      final num qty = v['cantidad'] ?? 0;
                      final num? p = v['precio'];
                      final String pStr = p != null ? currency.format(p) : "-";

                      rows.add([
                        "   ↳ Talla: $talla",
                        qty.toString(),
                        "-",
                        pStr,
                        "-",
                      ]);
                    }
                  }
                  return rows;
                }).toList(),
              ),

              pw.SizedBox(height: 20),
              // Footer
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    "Total:",
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Text(
                    currency.format(data['costo_productos']),
                    style: pw.TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: "Movimiento_$referencia.pdf",
    );
  }
}
