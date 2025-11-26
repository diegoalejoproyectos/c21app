import 'matriz.dart';
import 'movimiento_bancario.dart';

/// Modelo para resumen de pagos agrupados por código
class ResumenPago {
  final String codPago;
  final double totalMonto;

  ResumenPago({required this.codPago, required this.totalMonto});
}

/// Modelo para un reporte individual por código
class ReporteIndividual {
  final int codigo;
  final List<ResumenPago> resumenPagos;
  final List<PagoMatriz> detallePagos;
  final List<MovimientoBancario> datosExtracto;

  ReporteIndividual({
    required this.codigo,
    required this.resumenPagos,
    required this.detallePagos,
    required this.datosExtracto,
  });
}
