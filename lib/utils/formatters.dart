String formatarStatus(String status) {
  if (status.isEmpty) return 'Agendado';
  if (status.contains('Finished') || status == 'FT') return 'Terminado';
  if (status == 'AET') return 'Prorrogação';
  if (status == 'HT') return 'Intervalo';
  if (status == 'LIVE') return 'Ao Vivo';
  if (status.contains("'")) return 'Ao Vivo';
  if (status == 'PEN') return 'Pênaltis';
  return status;
}

String escapeHtml(String? texto) {
  if (texto == null) return '';
  return texto
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#039;');
}