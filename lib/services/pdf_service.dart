import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:http/http.dart' as http;
import '../models/order.dart';
import '../config/env.dart';
import 'token_service.dart';

class PdfService {
  static double _parseNumber(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String)
      return double.parse(value.replaceAll(RegExp(r'[^\d.]'), ''));
    return 0.0;
  }

  static Future<Uint8List> _loadLogoFromAssets() async {
    return await rootBundle
        .load('assets/logo.png')
        .then((byteData) => byteData.buffer.asUint8List());
  }

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

  static String _formatDate(String date) {
    try {
      final formatter = DateTime.parse(date);
      return "${formatter.day} de ${_getMonthName(formatter.month)} del ${formatter.year}";
    } catch (e) {
      return date;
    }
  }

  static String _getMonthName(int month) {
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre'
    ];
    return months[month - 1];
  }

  static pw.Widget _buildHeaderSection(
      String orderId, String date, pw.MemoryImage logo) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(
            children: [
              pw.Container(
                width: 80,
                height: 80,
                child: pw.Image(logo),
              ),
              pw.SizedBox(width: 10),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Empresa Ficticia S.A.',
                      style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue800)),
                  pw.Text('RUC: 1234567890001',
                      style:
                          pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                  pw.Text('Dirección: Av. Amazonas N34-451',
                      style:
                          pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                  pw.Text('Quito, Ecuador',
                      style:
                          pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                ],
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Fecha de emisión:',
                  style: pw.TextStyle(
                      fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.Text(_formatDate(date),
                  style: pw.TextStyle(fontSize: 13, color: PdfColors.blue800)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInvoiceInfoSection(Map<String, dynamic> orderDetails) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Factura',
                  style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900)),
              pw.SizedBox(height: 5),
              pw.Text('Nº: ${orderDetails['orden_id']}',
                  style: pw.TextStyle(
                      fontSize: 11, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildItemsTable(List<dynamic> items) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(1.5),
        5: const pw.FlexColumnWidth(1.5),
        6: const pw.FlexColumnWidth(1.5),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.blue100),
          children: [
            _buildTableHeader('Cod.'),
            _buildTableHeader('Producto'),
            _buildTableHeader('Cant.'),
            _buildTableHeader('P. Unit'),
            _buildTableHeader('Subtotal'),
            _buildTableHeader('IVA'),
            _buildTableHeader('Total'),
          ],
        ),
        ...items.map((item) {
          final precio = _parseNumber(item['precio_unitario']);
          final cantidad = _parseNumber(item['cantidad']);
          final subtotal = precio * cantidad;
          final iva = subtotal * 0.15;
          final total = _parseNumber(item['total']);

          return pw.TableRow(
            children: [
              _buildTableCell(item['producto']['producto_id'].toString(),
                  alignment: pw.TextAlign.center),
              _buildTableCell(item['producto']['nombre']),
              _buildTableCell(cantidad.toStringAsFixed(0),
                  alignment: pw.TextAlign.right),
              _buildTableCell('\$${precio.toStringAsFixed(2)}',
                  alignment: pw.TextAlign.right),
              _buildTableCell('\$${subtotal.toStringAsFixed(2)}',
                  alignment: pw.TextAlign.right),
              _buildTableCell('\$${iva.toStringAsFixed(2)}',
                  alignment: pw.TextAlign.right),
              _buildTableCell('\$${total.toStringAsFixed(2)}',
                  alignment: pw.TextAlign.right),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildTableHeader(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900),
      ),
    );
  }

  static pw.Widget _buildTableCell(String text,
      {pw.TextAlign alignment = pw.TextAlign.left}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        textAlign: alignment,
        style: const pw.TextStyle(fontSize: 10),
      ),
    );
  }

  static Future<String> generateInvoice(
      Order order, BuildContext context) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) throw Exception('Token no encontrado');

      final orderDetails = await _getOrderDetails(order.id, token);
      final logoBytes = await _loadLogoFromAssets();
      final logoImage = pw.MemoryImage(logoBytes);

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(orderDetails['orden_id'].toString(),
                    orderDetails['fecha_orden'], logoImage),
                _buildInvoiceInfoSection(orderDetails),
                pw.SizedBox(height: 20),
                _buildItemsTable(orderDetails['items']),
                pw.SizedBox(height: 20),
                pw.Container(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      _buildSummaryRow('Subtotal:', orderDetails['subtotal']),
                      _buildSummaryRow('IVA (15%):', orderDetails['iva_total']),
                      pw.Divider(color: PdfColors.grey400),
                      _buildSummaryRow('Total:', orderDetails['total'],
                          isTotal: true),
                    ],
                  ),
                ),
                pw.Spacer(),
                pw.Container(
                  alignment: pw.Alignment.center,
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'Gracias por su compra',
                        style: pw.TextStyle(
                            fontSize: 14,
                            color: PdfColors.grey700,
                            fontStyle: pw.FontStyle.italic),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'Términos de pago: Netos 30 días',
                        style: pw.TextStyle(
                            fontSize: 10, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      final directory = Platform.isAndroid
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

  static pw.Widget _buildSummaryRow(String label, dynamic value,
      {bool isTotal = false}) {
    final numericValue = _parseNumber(value);
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: isTotal ? 12 : 10,
              fontWeight: isTotal ? pw.FontWeight.bold : null,
            ),
          ),
          pw.SizedBox(width: 20),
          pw.Text(
            '\$${numericValue.toStringAsFixed(2)}',
            style: pw.TextStyle(
              fontSize: isTotal ? 12 : 10,
              fontWeight: isTotal ? pw.FontWeight.bold : null,
              color: isTotal ? PdfColors.blue800 : null,
            ),
          ),
        ],
      ),
    );
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
