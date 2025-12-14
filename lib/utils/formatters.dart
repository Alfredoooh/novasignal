import 'package:flutter/material.dart';

String formatarStatus(String status) {
  if (status.isEmpty) return 'Agendado';
  
  if (status.contains("'") || status == 'LIVE') return 'Ao Vivo';
  if (status == 'HT') return 'Intervalo';
  if (status.contains('Finished') || status == 'FT') return 'Terminado';
  if (status.contains('Postponed') || status.contains('PST')) return 'Adiado';
  if (status.contains('Cancelled')) return 'Cancelado';
  if (status == 'AET') return 'Prorrogação';
  if (status == 'PEN') return 'Pênaltis';
  
  return status;
}

Color getStatusColor(String status, BuildContext context) {
  if (status.contains("'") || status == 'LIVE') {
    return const Color(0xFF4CAF50); // Verde - Ao vivo
  }
  if (status == 'HT') {
    return const Color(0xFF2196F3); // Azul - Intervalo
  }
  if (status.contains('Finished') || status == 'FT') {
    return const Color(0xFFF44336); // Vermelho - Terminado
  }
  if (status.contains('Postponed') || status.contains('PST')) {
    return const Color(0xFFFF9800); // Laranja - Adiado
  }
  
  return Theme.of(context).colorScheme.onSurfaceVariant;
}