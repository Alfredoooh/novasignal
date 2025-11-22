import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:archive/archive.dart';

class ExportService {
  // Exportar como PDF
  static Future<void> exportAsPDF(String content) async {
    try {
      final pdf = pw.Document();

      // Dividir conteúdo em páginas (aproximadamente 3000 caracteres por página)
      final pages = _splitContentIntoPages(content, 3000);

      for (final pageContent in pages) {
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(72),
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    pageContent,
                    style: pw.TextStyle(
                      fontSize: 12,
                      lineSpacing: 1.5,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }

      // Salvar PDF
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/documento_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());

      // Compartilhar arquivo
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Documento PDF',
        text: 'Compartilhando documento',
      );
    } catch (e) {
      throw Exception('Erro ao exportar PDF: $e');
    }
  }

  // Exportar como EPUB
  static Future<void> exportAsEPUB(String content) async {
    try {
      final archive = Archive();

      // mimetype (deve ser o primeiro arquivo sem compressão)
      archive.addFile(
        ArchiveFile('mimetype', 20, 'application/epub+zip'.codeUnits)
          ..compress = false,
      );

      // META-INF/container.xml
      final containerXml = '''<?xml version="1.0"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
  <rootfiles>
    <rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/>
  </rootfiles>
</container>''';
      
      archive.addFile(
        ArchiveFile('META-INF/container.xml', containerXml.length, containerXml.codeUnits),
      );

      // OEBPS/content.opf
      final contentOpf = '''<?xml version="1.0" encoding="UTF-8"?>
<package xmlns="http://www.idpf.org/2007/opf" unique-identifier="bookid" version="2.0">
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
    <dc:title>Meu Documento</dc:title>
    <dc:creator>Autor</dc:creator>
    <dc:language>pt-BR</dc:language>
    <dc:identifier id="bookid">urn:uuid:${DateTime.now().millisecondsSinceEpoch}</dc:identifier>
  </metadata>
  <manifest>
    <item id="chapter1" href="chapter1.xhtml" media-type="application/xhtml+xml"/>
    <item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml"/>
  </manifest>
  <spine toc="ncx">
    <itemref idref="chapter1"/>
  </spine>
</package>''';

      archive.addFile(
        ArchiveFile('OEBPS/content.opf', contentOpf.length, contentOpf.codeUnits),
      );

      // OEBPS/toc.ncx
      final tocNcx = '''<?xml version="1.0" encoding="UTF-8"?>
<ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1">
  <head>
    <meta name="dtb:uid" content="urn:uuid:${DateTime.now().millisecondsSinceEpoch}"/>
  </head>
  <docTitle>
    <text>Meu Documento</text>
  </docTitle>
  <navMap>
    <navPoint id="navPoint-1" playOrder="1">
      <navLabel>
        <text>Capítulo 1</text>
      </navLabel>
      <content src="chapter1.xhtml"/>
    </navPoint>
  </navMap>
</ncx>''';

      archive.addFile(
        ArchiveFile('OEBPS/toc.ncx', tocNcx.length, tocNcx.codeUnits),
      );

      // OEBPS/chapter1.xhtml
      final contentEscaped = _escapeXml(content);
      final chapterXhtml = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <title>Capítulo 1</title>
  <style type="text/css">
    body { font-family: serif; font-size: 12pt; line-height: 1.5; margin: 2em; }
    p { text-align: justify; margin: 1em 0; }
  </style>
</head>
<body>
  <h1>Meu Documento</h1>
  ${_convertTextToXhtml(contentEscaped)}
</body>
</html>''';

      archive.addFile(
        ArchiveFile('OEBPS/chapter1.xhtml', chapterXhtml.length, chapterXhtml.codeUnits),
      );

      // Comprimir para ZIP (EPUB)
      final zipEncoder = ZipEncoder();
      final zipData = zipEncoder.encode(archive);

      if (zipData == null) {
        throw Exception('Erro ao criar arquivo EPUB');
      }

      // Salvar EPUB
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/documento_${DateTime.now().millisecondsSinceEpoch}.epub');
      await file.writeAsBytes(zipData);

      // Compartilhar arquivo
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Documento EPUB',
        text: 'Compartilhando livro eletrônico',
      );
    } catch (e) {
      throw Exception('Erro ao exportar EPUB: $e');
    }
  }

  // Exportar como TXT
  static Future<void> exportAsTXT(String content) async {
    try {
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/documento_${DateTime.now().millisecondsSinceEpoch}.txt');
      await file.writeAsString(content);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Documento TXT',
        text: 'Compartilhando documento de texto',
      );
    } catch (e) {
      throw Exception('Erro ao exportar TXT: $e');
    }
  }

  // Dividir conteúdo em páginas
  static List<String> _splitContentIntoPages(String content, int charsPerPage) {
    final pages = <String>[];
    int start = 0;

    while (start < content.length) {
      int end = start + charsPerPage;
      if (end > content.length) {
        end = content.length;
      } else {
        // Tentar quebrar em uma palavra
        while (end > start && content[end] != ' ' && content[end] != '\n') {
          end--;
        }
        if (end == start) {
          end = start + charsPerPage; // Se não encontrar espaço, cortar forçado
        }
      }

      pages.add(content.substring(start, end).trim());
      start = end;
    }

    return pages;
  }

  // Escapar XML
  static String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  // Converter texto para XHTML
  static String _convertTextToXhtml(String text) {
    final paragraphs = text.split('\n\n');
    final buffer = StringBuffer();

    for (final para in paragraphs) {
      if (para.trim().isNotEmpty) {
        buffer.write('<p>${para.trim()}</p>\n');
      }
    }

    return buffer.toString();
  }
}