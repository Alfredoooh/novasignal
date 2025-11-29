// Import condicional - escolhe automaticamente web ou mobile ou stub
export 'web_utils_stub.dart'
    if (dart.library.html) 'web_utils_web.dart'
    if (dart.library.io) 'web_utils_mobile.dart';