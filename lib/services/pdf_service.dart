// lib/services/pdf_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
//import 'package:path/path.dart' as path;
import '../models/order.dart';

class PdfService {
  static Future<String> generateInvoice(
      Order order, BuildContext context) async {
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Header(level: 0, child: pw.Text('Invoice')),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Order ID: ${order.id}'),
                    pw.Text('Date: ${order.date.toString().substring(0, 16)}'),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.TableHelper.fromTextArray(
                  headers: ['Item', 'Price', 'Quantity', 'Total'],
                  data: order.items
                      .map((item) => [
                            item.name,
                            '\$${item.price}',
                            item.quantity.toString(),
                            '\$${item.price * item.quantity}',
                          ])
                      .toList(),
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Total: \$${order.total}',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );

      // Get the external storage directory for Documents
      Directory? directory;
      if (Platform.isAndroid) {
        // En Android, obtenemos el directorio de Documents
        directory = Directory('/storage/emulated/0/Documents');
        // Crear el directorio si no existe
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
      } else {
        // En iOS u otros, usar el directorio de documentos por defecto
        directory = await getApplicationDocumentsDirectory();
      }

      // Crear un nombre de archivo único con timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'invoice_${order.id}_$timestamp.pdf';
      // En lugar de path.join():
      final filePath = '${directory.path}${Platform.pathSeparator}$fileName';
      final file = File(filePath);

      // Guardar el PDF
      await file.writeAsBytes(await pdf.save());
      debugPrint('PDF guardado en: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('Error generando PDF: $e');
      rethrow;
    }
  }

  static Future<void> openPdfFile(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        throw Exception('No se pudo abrir el archivo: ${result.message}');
      }
    } catch (e) {
      debugPrint('Error abriendo PDF: $e');
      rethrow;
    }
  }
}
