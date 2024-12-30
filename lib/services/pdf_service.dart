import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:http/http.dart' as http;
import '../models/order.dart';
import '../config/env.dart';
import 'token_service.dart';

class PdfService {
  static Future<Map<String, dynamic>> _getOrderDetails(
      String orderId, String token) async {
    final response = await http.get(
      Uri.parse('${Env.apiUrl}/ordenes/$orderId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Error obteniendo detalles de la orden');
    }

    return json.decode(response.body);
  }

  static Future<String> generateInvoice(
      Order order, BuildContext context) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) throw Exception('Token no encontrado');

      final orderDetails = await _getOrderDetails(order.id, token);
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('FACTURA',
                          style: pw.TextStyle(
                              fontSize: 24, fontWeight: pw.FontWeight.bold)),
                      pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: orderDetails['id'],
                        width: 80,
                        height: 80,
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Orden #${orderDetails['orden_id']}'),
                        pw.Text(
                            'Fecha: ${DateTime.parse(orderDetails['fecha_orden']).toString().substring(0, 16)}'),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),
                pw.Text('Detalle de Productos',
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: pw.FlexColumnWidth(3),
                    1: pw.FlexColumnWidth(1),
                    2: pw.FlexColumnWidth(1),
                    3: pw.FlexColumnWidth(1.5),
                  },
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text('Descripción')),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text('Cantidad')),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text('P. Unit')),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text('Total')),
                      ],
                    ),
                    ...(orderDetails['items'] as List)
                        .map((item) => pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(5),
                                  child: pw.Text(item['producto']['nombre']),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(5),
                                  child: pw.Text(item['cantidad'].toString(),
                                      textAlign: pw.TextAlign.center),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(5),
                                  child: pw.Text('\$${item['precio_unitario']}',
                                      textAlign: pw.TextAlign.right),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(5),
                                  child: pw.Text('\$${item['total']}',
                                      textAlign: pw.TextAlign.right),
                                ),
                              ],
                            )),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Container(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Subtotal: \$${orderDetails['subtotal']}'),
                      pw.Text('IVA: \$${orderDetails['iva_total']}'),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'Total: \$${orderDetails['total']}',
                        style: pw.TextStyle(
                            fontSize: 16, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 40),
                pw.Text('Gracias por su compra',
                    style: pw.TextStyle(
                        fontSize: 14, fontStyle: pw.FontStyle.italic)),
              ],
            );
          },
        ),
      );

      Directory? directory = Platform.isAndroid
          ? Directory('/storage/emulated/0/Documents')
          : await getApplicationDocumentsDirectory();

      if (Platform.isAndroid && !await directory.exists()) {
        await directory.create(recursive: true);
      }

      final fileName =
          'factura_${orderDetails['orden_id']}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '${directory.path}${Platform.pathSeparator}$fileName';
      final file = File(filePath);

      await file.writeAsBytes(await pdf.save());
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
