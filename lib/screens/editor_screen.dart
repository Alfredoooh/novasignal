import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uuid/uuid.dart';
import '../models/document.dart';
import '../services/document_service.dart';
import '../services/auth_service.dart';
import '../widgets/theme.dart';
import 'auth_screen.dart';
import 'settings_screen.dart';
import 'agenda_screen.dart';
import 'editor_screen_native.dart';

// ─── SVGs ──────────────────────────────────────────────────────────
const _svgChatOutline = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="m19,4h-1.101c-.465-2.279-2.485-4-4.899-4H5C2.243,0,0,2.243,0,5v12.854c0,.794.435,1.52,1.134,1.894.318.171.667.255,1.015.255.416,0,.831-.121,1.19-.36l2.95-1.967c.691,1.935,2.541,3.324,4.711,3.324h5.697l3.964,2.643c.36.24.774.361,1.19.361.348,0,.696-.085,1.015-.256.7-.374,1.134-1.1,1.134-1.894v-12.854c0-2.757-2.243-5-5-5ZM2.23,17.979c-.019.012-.075.048-.152.007-.079-.042-.079-.109-.079-.131V5c0-1.654,1.346-3,3-3h8c1.654,0,3,1.346,3,3v7c0,1.654-1.346,3-3,3h-6c-.327,0-.541.159-.565.175l-4.205,2.804Zm19.77,3.876c0,.021,0,.089-.079.131-.079.041-.133.005-.151-.007l-4.215-2.811c-.164-.109-.357-.168-.555-.168h-6c-1.304,0-2.415-.836-2.828-2h4.828c2.757,0,5-2.243,5-5v-6h1c1.654,0,3,1.346,3,3v12.854Z"/></svg>';
const _svgChatFilled = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="m13-.004H5C2.243-.004,0,2.239,0,4.996v12.854c0,.793.435,1.519,1.134,1.894.318.171.667.255,1.015.255.416,0,.831-.121,1.191-.36l3.963-2.643h5.697c2.757,0,5-2.243,5-5v-7C18,2.239,15.757-.004,13-.004Zm11,9v12.854c0,.793-.435,1.519-1.134,1.894-.318.171-.667.255-1.015.256-.416,0-.831-.121-1.19-.36l-3.964-2.644h-5.697c-1.45,0-2.747-.631-3.661-1.62l.569-.38h5.092c3.859,0,7-3.141,7-7v-7c0-.308-.027-.608-.065-.906,2.311.44,4.065,2.469,4.065,4.906Z"/></svg>';
const _svgPreviewOutline = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M20.466,1.967L14.78,.221c-2.614-.797-5.406,.664-6.225,3.24l-.188,.539h-3.368C2.243,4,0,6.243,0,9v10c0,2.757,2.243,5,5,5h6c1.596,0,3.004-.766,3.92-1.934,.231,.032,.461,.052,.688,.052,2.167,0,4.144-1.414,4.775-3.564l3.413-10.397c.767-2.613-.727-5.39-3.331-6.189ZM11,22H5c-1.654,0-3-1.346-3-3V9c0-1.654,1.346-3,3-3h6c1.654,0,3,1.346,3,3v10c0,1.654-1.346,3-3,3ZM21.887,7.562l-3.412,10.397c-.358,1.214-1.413,2.022-2.603,2.132,.079-.353,.128-.716,.128-1.092V9c0-2.757-2.243-5-5-5h-.507c.534-1.501,2.163-2.341,3.7-1.867l5.686,1.746c1.562,.479,2.459,2.146,2.008,3.684Z"/></svg>';
const _svgPreviewFilled = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M23.799,8.156l-3.413,10.398c-.447,1.519-1.57,2.658-2.952,3.203,.365-.847,.568-1.779,.568-2.758V9c0-3.86-3.141-7-7-7h-1.665C10.566,.381,12.723-.408,14.782,.221l5.686,1.746c2.604,.8,4.098,3.576,3.331,6.189Zm-7.797,.844v10c0,2.757-2.243,5-5,5H5.002C2.245,24,.002,21.757,.002,19V9C.002,6.243,2.245,4,5.002,4h6c2.757,0,5,2.243,5,5Z"/></svg>';
const _svgAgenda = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M18,12.5c0,.829-.672,1.5-1.5,1.5H7.5c-.828,0-1.5-.671-1.5-1.5s.672-1.5,1.5-1.5h9c.828,0,1.5,.671,1.5,1.5Zm-6.5,3.5H7.5c-.828,0-1.5,.671-1.5,1.5s.672,1.5,1.5,1.5h4c.828,0,1.5-.671,1.5-1.5s-.672-1.5-1.5-1.5ZM24,7.5v11c0,3.033-2.468,5.5-5.5,5.5H5.5c-3.032,0-5.5-2.467-5.5-5.5V7.5C0,4.467,2.468,2,5.5,2h.5v-.5c0-.829,.672-1.5,1.5-1.5s1.5,.671,1.5,1.5v.5h6v-.5c0-.829,.672-1.5,1.5-1.5s1.5,.671,1.5,1.5v.5h.5c3.032,0,5.5,2.467,5.5,5.5Zm-3,11V9H3v9.5c0,1.378,1.121,2.5,2.5,2.5h13c1.379,0,2.5-1.122,2.5-2.5Z"/></svg>';
const _svgUser = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="m12,0C5.383,0,0,5.383,0,12s5.383,12,12,12,12-5.383,12-12S18.617,0,12,0Zm-4,21.164v-.164c0-2.206,1.794-4,4-4s4,1.794,4,4v.164c-1.226.537-2.578.836-4,.836s-2.774-.299-4-.836Zm9.925-1.113c-.456-2.859-2.939-5.051-5.925-5.051s-5.468,2.192-5.925,5.051c-2.47-1.823-4.075-4.753-4.075-8.051C2,6.486,6.486,2,12,2s10,4.486,10,10c0,3.298-1.605,6.228-4.075,8.051Zm-5.925-15.051c-2.206,0-4,1.794-4,4s1.794,4,4,4,4-1.794,4-4-1.794-4-4-4Zm0,6c-1.103,0-2-.897-2-2s.897-2,2-2,2,.897,2,2-.897,2-2,2Z"/></svg>';
const _svgNewChat = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="m12.854.03c-3.478-.243-6.883,1.029-9.339,3.485C1.059,5.971-.211,9.375.03,12.854c.44,6.354,6.065,11.146,13.083,11.146h5.888c2.943,0,4.999-2.404,4.999-5.847v-5.815C24,5.869,19.104.463,12.854.03Zm9.146,18.123c0,2.301-1.205,3.847-2.999,3.847h-5.888c-6.052,0-10.715-3.905-11.088-9.285-.201-2.901.857-5.74,2.904-7.786,1.882-1.882,4.432-2.929,7.086-2.929.232,0,.466.008.7.024,5.207.361,9.285,4.891,9.285,10.312v5.815Zm-5-6.153c0,.552-.448,1-1,1h-3v3c0,.552-.448,1-1,1s-1-.448-1-1v-3h-3c-.552,0-1-.448-1-1s.448-1,1-1h3v-3c0-.552.448-1,1-1s1,.448,1,1v3h3c.552,0,1,.448,1,1Z"/></svg>';
const _svgRemoveBg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="m18,8c0,1.105-.895,2-2,2s-2-.895-2-2,.895-2,2-2,2,.895,2,2Zm5.707,15.707c-.195.195-.451.293-.707.293s-.512-.098-.707-.293L.293,1.707C-.098,1.316-.098.684.293.293S1.316-.098,1.707.293l1.536,1.536c.814-.538,1.771-.829,2.757-.829h12c2.757,0,5,2.243,5,5v12c0,.987-.291,1.944-.829,2.757l1.536,1.536c.391.391.391,1.023,0,1.414ZM4.707,3.293l16,16c.191-.4.293-.842.293-1.293V6c0-1.654-1.346-3-3-3H6c-.451,0-.892.102-1.293.293Zm12.293,17.707H6c-1.523,0-2.783-1.14-2.974-2.612l4.681-4.681c.391-.391.391-1.023,0-1.414s-1.023-.391-1.414,0l-3.293,3.293V7c0-.553-.448-1-1-1s-1,.447-1,1v11c0,2.757,2.243,5,5,5h11c.552,0,1-.447,1-1s-.448-1-1-1Z"/></svg>';
const _svgClearImg = '<svg version="1.1" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg"><g transform="matrix(1.3333333,0,0,-1.3333333,0,32)"><g><g clip-path="url(#a)"><g transform="translate(11,7)"><path d="m0,0h8c2.209,0,4,1.791,4,4v8c0,2.209-1.791,4-4,4H0c-2.209,0-4-1.791-4-4V4C-4,1.791-2.209,0,0,0Z" style="fill:none;stroke:#000;stroke-width:2;stroke-linecap:round;stroke-linejoin:round"/></g><g transform="translate(8,12)"><path d="m0,0h-3c-2.209,0-4-1.791-4-4v-3c0-2.209,1.791-4,4-4h3c2.209,0,4,1.791,4,4v3C4-1.791,2.209,0,0,0Z" style="fill:none;stroke:#000;stroke-width:2;stroke-linecap:round;stroke-linejoin:round"/></g><g transform="translate(11,11)"><path d="M0,0,7,7" style="fill:none;stroke:#000;stroke-width:2;stroke-linecap:round;stroke-linejoin:round"/></g><g transform="translate(14,19)"><path d="M0,0H3C4.104,0,5-.896,5-2V-5" style="fill:none;stroke:#000;stroke-width:2;stroke-linecap:round;stroke-linejoin:round"/></g></g></g></g><defs><clipPath id="a" clipPathUnits="userSpaceOnUse"><path d="M0,24H24V0H0Z"/></clipPath></defs></svg>';
const _svgCode = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M7,0h-3C1.794,0,0,1.794,0,4v3c0,2.206,1.794,4,4,4h3c2.206,0,4-1.794,4-4V4C11,1.794,9.206,0,7,0Zm2,7c0,1.103-.897,2-2,2h-3c-1.103,0-2-.897-2-2V4c0-1.103,.897-2,2-2h3c1.103,0,2,.897,2,2v3Zm-2-2v1c0,.552-.448,1-1,1h-1c-.552,0-1-.448-1-1v-1c0-.552,.448-1,1-1h1c.552,0,1,.448,1,1Zm10,6h3c2.206,0,4-1.794,4-4V4C24,1.794,22.206,0,20,0h-3C14.794,0,13,1.794,13,4v3c0,2.206,1.794,4,4,4Zm-2-7c0-1.103,.897-2,2-2h3c1.103,0,2,.897,2,2v3c0,1.103-.897,2-2,2h-3c-1.103,0-2-.897-2-2V4Zm2,2v-1c0-.552,.448-1,1-1h1c.552,0,1,.448,1,1v1c0,.552-.448,1-1,1h-1c-.552,0-1-.448-1-1ZM7,13h-3c-2.206,0-4,1.794-4,4v3c0,2.206,1.794,4,4,4h3c2.206,0,4-1.794,4-4v-3c0-2.206-1.794-4-4-4Zm2,7c0,1.103-.897,2-2,2h-3c-1.103,0-2-.897-2-2v-3c0-1.103,.897-2,2-2h3c1.103,0,2,.897,2,2v3Zm-2-2v1c0,.552-.448,1-1,1h-1c-.552,0-1-.448-1-1v-1c0-.552,.448-1,1-1h1c.552,0,1,.448,1,1Zm10-3.5v1c0,.828-.672,1.5-1.5,1.5h-1c-.828,0-1.5-.672-1.5-1.5v-1c0-.828,.672-1.5,1.5-1.5h1c.828,0,1.5,.672,1.5,1.5Zm3,4h0c0,.828-.672,1.5-1.5,1.5h0c-.828,0-1.5-.672-1.5-1.5h0c0-.828,.672-1.5,1.5-1.5h0c.828,0,1.5,.672,1.5,1.5Zm-3,3v1c0,.828-.672,1.5-1.5,1.5h-1c-.828,0-1.5-.672-1.5-1.5v-1c0-.828,.672-1.5,1.5-1.5h1c.828,0,1.5,.672,1.5,1.5Zm7-7v1c0,.828-.672,1.5-1.5,1.5h-1c-.828,0-1.5-.672-1.5-1.5v-1c0-.828,.672-1.5,1.5-1.5h1c.828,0,1.5,.672,1.5,1.5Z"/></svg>';
const _svgNote = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="m18.813,10c.309,0,.601-.143.79-.387s.255-.562.179-.861c-.311-1.217-.945-2.329-1.833-3.217l-3.485-3.485c-1.322-1.322-3.08-2.05-4.95-2.05h-4.515C2.243,0,0,2.243,0,5v14c0,2.757,2.243,5,5,5h3c.552,0,1-.448,1-1s-.448-1-1-1h-3c-1.654,0-3-1.346-3-3V5c0-1.654,1.346-3,3-3h4.515c.163,0,.325.008.485.023v4.977c0,1.654,1.346,3,3,3h5.813Zm-6.813-3V2.659c.379.218.732.488,1.05.806l3.485,3.485c.314.314.583.668.803,1.05h-4.338c-.551,0-1-.449-1-1Zm11.122,4.879c-1.134-1.134-3.11-1.134-4.243,0l-6.707,6.707c-.755.755-1.172,1.76-1.172,2.829v1.586c0,.552.448,1,1,1h1.586c1.069,0,2.073-.417,2.828-1.172l6.707-6.707c.567-.567.879-1.32.879-2.122s-.312-1.555-.878-2.121Zm-1.415,2.828l-6.708,6.707c-.377.378-.879.586-1.414.586h-.586v-.586c0-.534.208-1.036.586-1.414l6.708-6.707c.377-.378,1.036-.378,1.414,0,.189.188.293.439.293.707s-.104.518-.293.707Z"/></svg>';
const _svgReminder = '<svg version="1.1" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg"><g transform="matrix(1.3333333,0,0,-1.3333333,0,32)"><g><g clip-path="url(#b)"><g transform="translate(2,11)"><path d="m0,0c0-5.523,4.477-10,10-10,5.523,0,10,4.477,10,10C20,5.523,15.523,10,10,10,4.477,10,0,5.523,0,0Z" style="fill:none;stroke:#000;stroke-width:2;stroke-linecap:round;stroke-linejoin:round"/></g><g transform="translate(23,19.5)"><path d="M0,0C0,1.839-1.5,3.5-3.785,3.5" style="fill:none;stroke:#000;stroke-width:2;stroke-linecap:round;stroke-linejoin:round"/></g><g transform="translate(1,19.5)"><path d="M0,0C0,1.839,1.5,3.5,3.785,3.5" style="fill:none;stroke:#000;stroke-width:2;stroke-linecap:round;stroke-linejoin:round"/></g><g transform="translate(3,1)"><path d="M0,0C0,2,2,2.222,2,2.222" style="fill:none;stroke:#000;stroke-width:2;stroke-linecap:round;stroke-linejoin:round"/></g><g transform="translate(21,1)"><path d="M0,0C0,2-2,2.222-2,2.222" style="fill:none;stroke:#000;stroke-width:2;stroke-linecap:round;stroke-linejoin:round"/></g><g transform="translate(12,21)"><path d="M0,0V2" style="fill:none;stroke:#000;stroke-width:2;stroke-linecap:round;stroke-linejoin:round"/></g><g transform="translate(12,18)"><path d="m0,0c-0.553,0-1-0.447-1-1v-5c0-0.266,0.105-0.52,0.293-0.707l3-3C2.488-9.902,2.744-10,3-10c0.256,0,0.512,0.098,0.707,0.293,0.391,0.391,0.391,1.023,0,1.414L1-5.586V-1C1-0.447,0.553,0,0,0" style="fill:#000;fill-rule:nonzero;stroke:none"/></g></g></g></g><defs><clipPath id="b" clipPathUnits="userSpaceOnUse"><path d="M0,24H24V0H0Z"/></clipPath></defs></svg>';
const _svgDesign = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="m17.565,15.019c-2.496,0-4.527,2.019-4.527,4.5,0,2.576,2.646,4.5,5.013,4.5h3.489c.822,0,1.592-.387,2.058-1.034.44-.611.557-1.368.321-2.076-1.269-3.799-3.525-5.891-6.354-5.891Zm4.411,6.797c-.092.127-.254.203-.436.203h-3.489c-1.365,0-3.013-1.115-3.013-2.5s1.133-2.5,2.527-2.5c2.435,0,3.768,2.46,4.457,4.524.012.035.048.142-.046.272Zm2.062-18.174c0-.969-.376-1.878-1.06-2.562h-.001c-1.367-1.368-3.76-1.368-5.122,0L1.558,17.375c-.98.981-1.52,2.284-1.52,3.67v1.973c0,.552.448,1,1,1h1.974c1.387,0,2.69-.54,3.67-1.52L22.979,6.203c.684-.684,1.06-1.593,1.06-2.562ZM5.269,21.085c-.603.603-1.404.934-2.256.934h-.974v-.973c0-.852.332-1.654.934-2.256L15.319,6.444l2.295,2.295-12.345,12.345ZM21.564,4.789l-2.537,2.537-2.295-2.295,2.538-2.538c.61-.611,1.682-.61,2.293,0h.001c.305.307.474.714.474,1.149s-.168.842-.474,1.147ZM1.098,6.203C.415,5.519.039,4.609.039,3.642S.415,1.763,1.098,1.08c1.369-1.37,3.759-1.369,5.125,0l3.839,3.839c.391.391.391,1.023,0,1.414s-1.023.391-1.414,0l-3.84-3.84c-.611-.612-1.683-.611-2.294,0-.307.307-.475.714-.475,1.149s.168.842.474,1.148l3.839,3.839c.391.39.391,1.023,0,1.414-.195.195-.451.293-.707.293s-.512-.098-.707-.293l-3.84-3.839Z"/></svg>';

// ─── Worker & model ────────────────────────────────────────────────
const _kWorker = 'https://dawn-sun-590a.alfredopjonas.workers.dev';


// ─── Chat Models ───────────────────────────────────────────────────
class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

// Modelos disponíveis
const _kModelCompound     = 'compound-beta';
const _kModelCompoundMini = 'compound-beta-mini';

class ChatConversation {
  final String id;
  String title;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  String model;
  ChatConversation({required this.id, required this.title,
    required this.messages, required this.createdAt,
    this.model = _kModelCompound});
}

class ConversationStore {
  static final instance = ConversationStore._();
  ConversationStore._();
  final List<ChatConversation> _convs = [];
  List<ChatConversation> get all => List.unmodifiable(_convs);

  ChatConversation newConversation({String model = _kModelCompound}) {
    final c = ChatConversation(
      id: const Uuid().v4(), title: '…',
      messages: [], createdAt: DateTime.now(), model: model);
    _convs.insert(0, c);
    return c;
  }

  void updateTitle(String id, String msg) {
    final c = _convs.firstWhere((x) => x.id == id, orElse: () => _convs.first);
    c.title = msg.length > 32 ? '${msg.substring(0,32)}…' : msg;
  }
}

// ─── Drawer icon ───────────────────────────────────────────────────
class _DrawerIcon extends StatelessWidget {
  final Color color;
  const _DrawerIcon({required this.color});
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(width: 22, height: 2,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(height: 5),
      Container(width: 14, height: 2,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
    ],
  );
}

// ─── EditorController ──────────────────────────────────────────────
abstract class EditorController {
  ADocument? get document;
  DocType get docType;
  String? get importHtml;
  String? get importTitle;
  String? get importDocxBase64;
  Future<void> handleSaveMessage(Map<String, dynamic> data);
  void handleBack();
  void setSaving(bool v);
}

// ─── EditorScreen ──────────────────────────────────────────────────
class EditorScreen extends StatefulWidget {
  final ADocument? document;
  final DocType docType;
  final String? importHtml;
  final String? importTitle;
  final String? importDocxBase64;
  final bool isRoot;

  const EditorScreen({super.key, this.document, this.docType = DocType.document,
    this.importHtml, this.importTitle, this.importDocxBase64, this.isRoot = false});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen>
    with SingleTickerProviderStateMixin implements EditorController {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late final TabController _tab;
  int _tabIndex = 1;
  late ChatConversation _activeConv;

  @override ADocument? get document        => widget.document;
  @override DocType    get docType         => widget.document?.docType ?? widget.docType;
  @override String?    get importHtml       => widget.importHtml;
  @override String?    get importTitle      => widget.importTitle;
  @override String?    get importDocxBase64 => widget.importDocxBase64;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this, initialIndex: 1);
    _tab.addListener(() { if (!_tab.indexIsChanging) setState(() => _tabIndex = _tab.index); });
    themeNotifier.addListener(_onTheme);
    _activeConv = ConversationStore.instance.newConversation();
  }

  @override
  void dispose() {
    _tab.dispose();
    themeNotifier.removeListener(_onTheme);
    super.dispose();
  }

  void _onTheme() => setState(() {});

  @override
  Future<void> handleSaveMessage(Map<String, dynamic> data) async {
    final inner = jsonDecode(data['data'] as String) as Map<String, dynamic>;
    final now = DateTime.now();
    final id = (data['id'] as String?)?.isNotEmpty == true ? data['id'] as String
        : widget.document?.id ?? const Uuid().v4();
    final raw = (inner['title'] as String?)?.trim();
    final doc = ADocument(
      id: id, title: (raw == null || raw.isEmpty) ? 'Sem título' : raw,
      htmlContent: inner['html'] as String? ?? '',
      plainText: inner['text'] as String? ?? '',
      wordCount: inner['words'] as int? ?? 0,
      createdAt: widget.document?.createdAt ?? now, updatedAt: now,
      docType: widget.document?.docType ?? widget.docType,
    );
    await DocumentService.instance.save(doc);
    if (AuthService.instance.loggedIn) AuthService.instance.syncDocument(doc.toJson()).ignore();
    if (mounted) setState(() {});
  }

  @override
  void handleBack() {
    if (widget.isRoot) _scaffoldKey.currentState?.openDrawer();
    else Navigator.of(context).pop();
  }

  @override
  void setSaving(bool v) { if (mounted) setState(() {}); }

  void _switchTab(int i) {
    _tab.animateTo(i, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    setState(() => _tabIndex = i);
  }

  void _newConv() {
    setState(() => _activeConv = ConversationStore.instance.newConversation());
    _scaffoldKey.currentState?.closeDrawer();
    Future.delayed(const Duration(milliseconds: 280), () => _switchTab(0));
  }

  void _openConv(ChatConversation c) {
    setState(() => _activeConv = c);
    _scaffoldKey.currentState?.closeDrawer();
    Future.delayed(const Duration(milliseconds: 280), () => _switchTab(0));
  }

  @override
  Widget build(BuildContext context) {
    final isDark   = themeNotifier.isDark;
    final bg       = isDark ? AppColors.darkBackground : AppColors.background;
    final navBg    = isDark ? const Color(0xFF1A1A1A)  : AppColors.navBg;
    final sel      = isDark ? AppColors.darkNavSelected   : AppColors.navSelected;
    final unsel    = isDark ? AppColors.darkNavUnselected : AppColors.navUnselected;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bg,
      drawer: widget.isRoot ? _AppDrawer(
        activeConvId: _activeConv.id,
        onNewChat: _newConv,
        onOpenConv: _openConv,
      ) : null,
      body: _FadeTabView(
        controller: _tab,
        children: [
          _ChatScreen(
            key: ValueKey(_activeConv.id),
            conversation: _activeConv,
            scaffoldKey: _scaffoldKey,
            isRoot: widget.isRoot,
            onConvUpdated: () => setState(() {}),
          ),
          buildEditorView(context, this),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        index: _tabIndex, onTap: _switchTab,
        sel: sel, unsel: unsel, navBg: navBg, isDark: isDark,
      ),
    );
  }
}

// ─── Fade Tab View ─────────────────────────────────────────────────
class _FadeTabView extends StatefulWidget {
  final TabController controller;
  final List<Widget> children;
  const _FadeTabView({required this.controller, required this.children});
  @override State<_FadeTabView> createState() => _FadeTabViewState();
}

class _FadeTabViewState extends State<_FadeTabView> {
  @override
  void initState() { super.initState(); widget.controller.addListener(() => setState(() {})); }

  @override
  Widget build(BuildContext context) {
    return Stack(children: List.generate(widget.children.length, (i) {
      final active = i == widget.controller.index;
      return AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        opacity: active ? 1.0 : 0.0,
        child: IgnorePointer(ignoring: !active, child: widget.children[i]),
      );
    }));
  }
}

// ─── Bottom Bar ────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  final Color sel, unsel, navBg;
  final bool isDark;
  const _BottomBar({required this.index, required this.onTap,
    required this.sel, required this.unsel, required this.navBg, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: navBg,
        border: Border(top: BorderSide(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0), width: 1)),
      ),
      child: SafeArea(top: false, child: SizedBox(height: 52, child: Row(children: [
        Expanded(child: _TBtn(outline: _svgChatOutline, filled: _svgChatFilled,
          label: 'Chat', active: index == 0, sel: sel, unsel: unsel, onTap: () => onTap(0))),
        Expanded(child: _TBtn(outline: _svgPreviewOutline, filled: _svgPreviewFilled,
          label: 'Preview', active: index == 1, sel: sel, unsel: unsel, onTap: () => onTap(1))),
      ]))),
    );
  }
}

class _TBtn extends StatelessWidget {
  final String outline, filled, label;
  final bool active;
  final Color sel, unsel;
  final VoidCallback onTap;
  const _TBtn({required this.outline, required this.filled, required this.label,
    required this.active, required this.sel, required this.unsel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = active ? sel : unsel;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: SvgPicture.string(active ? filled : outline, key: ValueKey(active),
            width: 20, height: 20, colorFilter: ColorFilter.mode(c, BlendMode.srcIn)),
        ),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(color: c, fontSize: 11,
          fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
      ]),
    );
  }
}

// ─── Chat Screen ───────────────────────────────────────────────────
class _ChatScreen extends StatefulWidget {
  final ChatConversation conversation;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool isRoot;
  final VoidCallback onConvUpdated;
  const _ChatScreen({super.key, required this.conversation,
    required this.scaffoldKey, required this.isRoot, required this.onConvUpdated});
  @override State<_ChatScreen> createState() => _ChatScreenState();
}

// Model label helper
String _modelLabel(String m) {
  if (m == _kModelCompoundMini) return 'Compound Mini';
  return 'Compound';
}

class _ChatScreenState extends State<_ChatScreen> with AutomaticKeepAliveClientMixin {
  @override bool get wantKeepAlive => true;

  final _ctrl   = TextEditingController();
  final _scroll = ScrollController();
  bool  _busy   = false;

  List<ChatMessage> get _msgs => widget.conversation.messages;

  // Escuta tema directamente para actualizar imediatamente
  bool _isDark = false;

  @override
  void initState() {
    super.initState();
    _isDark = themeNotifier.isDark;
    themeNotifier.addListener(_onTheme);
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_onTheme);
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onTheme() {
    if (mounted) setState(() => _isDark = themeNotifier.isDark);
  }

  void _scrollBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _busy) return;
    final isFirst = _msgs.isEmpty;
    setState(() {
      _msgs.add(ChatMessage(text: text, isUser: true));
      _ctrl.clear();
      _busy = true;
    });
    if (isFirst) _generateTitle(text);
    _scrollBottom();
    _callAI(text);
  }

  Future<void> _callAI(String prompt) async {
    try {
      final history = _msgs
        .where((m) => m.isUser)
        .skip(1) // skip first (já é o prompt)
        .take(8)
        .map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text})
        .toList();

      final body = jsonEncode({
        'prompt': prompt,
        'model': widget.conversation.model,
        'history': history,
        'session_id': widget.conversation.id,
      });

      final client = HttpClient();
      final req = await client.postUrl(Uri.parse('$_kWorker/chat'));
      req.headers.set('Content-Type', 'application/json');
      req.write(body);
      final res = await req.close().timeout(const Duration(seconds: 90));
      final raw = await res.transform(utf8.decoder).join();
      final data = jsonDecode(raw) as Map<String, dynamic>;

      if (data['error'] != null) throw Exception(data['error']);

      final reply = (data['content'] ?? data['answer'] ?? data['text'] ?? '') as String;

      if (mounted) setState(() {
        _msgs.add(ChatMessage(text: reply.trim(), isUser: false));
        _busy = false;
      });
    } catch (e) {
      if (mounted) setState(() {
        _msgs.add(ChatMessage(text: 'Erro: $e', isUser: false));
        _busy = false;
      });
    }
    _scrollBottom();
  }

  // Gera título com IA (compound-beta-mini, rápido)
  Future<void> _generateTitle(String firstMessage) async {
    try {
      final client = HttpClient();
      final req = await client.postUrl(Uri.parse('$_kWorker/title'));
      req.headers.set('Content-Type', 'application/json');
      req.write(jsonEncode({'message': firstMessage}));
      final res = await req.close().timeout(const Duration(seconds: 15));
      final raw = await res.transform(utf8.decoder).join();
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final title = data['title'] as String? ?? '';
      if (title.isNotEmpty) {
        widget.conversation.title = title;
        if (mounted) widget.onConvUpdated();
      }
    } catch (_) {
      // silencia — título fica como está
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark  = _isDark;
    final bg      = isDark ? AppColors.darkBackground      : AppColors.background;
    final surface = isDark ? const Color(0xFF2A2A2A)        : const Color(0xFFEEEEEE);
    final textP   = isDark ? AppColors.darkTextPrimary      : AppColors.textPrimary;
    final textS   = isDark ? AppColors.darkTextSecondary    : AppColors.textSecondary;
    final inputBg = isDark ? const Color(0xFF161616)        : Colors.white;
    final sendC   = isDark ? AppColors.darkNavSelected      : AppColors.navSelected;

    return Container(
      color: bg,
      child: Column(children: [
        // AppBar — mesma altura que o editor nativo
        SafeArea(
          bottom: false,
          child: SizedBox(
            height: kToolbarHeight,
            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              if (widget.isRoot)
                IconButton(
                  icon: _DrawerIcon(color: textP),
                  onPressed: () => widget.scaffoldKey.currentState?.openDrawer(),
                )
              else
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: textP, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              Expanded(
                child: Text(
                  widget.conversation.title,
                  style: TextStyle(color: textP, fontSize: 17, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Selector de modelo
              GestureDetector(
                onTap: () {
                  final next = widget.conversation.model == _kModelCompound
                    ? _kModelCompoundMini : _kModelCompound;
                  setState(() => widget.conversation.model = next);
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    _modelLabel(widget.conversation.model),
                    style: TextStyle(color: textS, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ]),
          ),
        ),

        // Mensagens
        Expanded(
          child: _msgs.isEmpty
            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                SvgPicture.string(_svgChatOutline, width: 44, height: 44,
                  colorFilter: ColorFilter.mode(textS, BlendMode.srcIn)),
                const SizedBox(height: 12),
                Text('Começa uma conversa',
                  style: TextStyle(color: textS, fontSize: 15)),
              ]))
            : ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                itemCount: _msgs.length + (_busy ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i == _msgs.length) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(children: [
                        SizedBox(width: 14, height: 14,
                          child: CircularProgressIndicator(strokeWidth: 1.5, color: textS)),
                        const SizedBox(width: 10),
                        Text('A pensar…', style: TextStyle(color: textS, fontSize: 13)),
                      ]),
                    );
                  }
                  final msg = _msgs[i];
                  if (msg.isUser) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12, left: 56),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(msg.text, style: TextStyle(color: textP, fontSize: 15)),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16, right: 32),
                    child: Text(msg.text,
                      style: TextStyle(color: textP, fontSize: 15, height: 1.55)),
                  );
                },
              ),
        ),

        // Input flutuante — 100% rounded, sem tocar no bottom bar
        Padding(
          padding: EdgeInsets.fromLTRB(
            12, 8, 12,
            MediaQuery.of(context).padding.bottom + 10,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: inputBg,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
                  blurRadius: 12, offset: const Offset(0, 4)),
              ],
              border: Border.all(
                color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  style: TextStyle(color: textP, fontSize: 15),
                  maxLines: 4, minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Pergunta algo…',
                    hintStyle: TextStyle(color: textS),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _send,
                child: Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: sendC),
                  alignment: Alignment.center,
                  child: Icon(Icons.arrow_upward_rounded,
                    color: isDark ? AppColors.darkBackground : AppColors.background,
                    size: 17),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ─── Drawer ────────────────────────────────────────────────────────
class _AppDrawer extends StatefulWidget {
  final String activeConvId;
  final VoidCallback onNewChat;
  final ValueChanged<ChatConversation> onOpenConv;
  const _AppDrawer({required this.activeConvId,
    required this.onNewChat, required this.onOpenConv});
  @override State<_AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<_AppDrawer> {
  @override
  void initState() { super.initState(); themeNotifier.addListener(_rebuild); }
  @override
  void dispose() { themeNotifier.removeListener(_rebuild); super.dispose(); }
  void _rebuild() => setState(() {});

  Widget _svg(String d, Color c, {double s = 20}) =>
    SvgPicture.string(d, width: s, height: s,
      colorFilter: ColorFilter.mode(c, BlendMode.srcIn));

  @override
  Widget build(BuildContext context) {
    final isDark   = themeNotifier.isDark;
    final bg       = isDark ? AppColors.darkDrawerBg        : AppColors.background;
    final textP    = isDark ? AppColors.darkTextPrimary      : AppColors.textPrimary;
    final textS    = isDark ? AppColors.darkTextSecondary    : AppColors.textSecondary;
    final surfBg   = isDark ? const Color(0xFF323232)        : const Color(0xFFF5F5F5);
    final toggleBg = isDark ? const Color(0xFF3A3A3A)        : const Color(0xFFF5F5F5);
    final divider  = isDark ? AppColors.darkDivider          : AppColors.divider;
    // Selected conversation bg goes edge-to-edge like WhatsApp
    final activeBg = isDark ? const Color(0xFF2C2C2C)        : const Color(0xFFEDEDED);

    final convs = ConversationStore.instance.all;

    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: bg,
      child: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 8),

          // ── Nova conversa
          _DrawerItem(svg: _svgNewChat, label: 'Nova conversa',
            textColor: textP, iconColor: textS, onTap: widget.onNewChat),

          // ── Agenda (mesma secção, sem divisória)
          _DrawerItem(svg: _svgAgenda, label: 'Agenda',
            textColor: textP, iconColor: textS, onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => AgendaPage()));
            }),

          // ── Criar notas
          _DrawerItem(svg: _svgNote, label: 'Criar notas',
            textColor: textP, iconColor: textS, onTap: () => Navigator.pop(context)),

          // ── Criar designs
          _DrawerItem(svg: _svgDesign, label: 'Criar designs',
            textColor: textP, iconColor: textS, onTap: () => Navigator.pop(context)),

          // ── Criar códigos
          _DrawerItem(svg: _svgCode, label: 'Criar códigos',
            textColor: textP, iconColor: textS, onTap: () => Navigator.pop(context)),

          // ── Lembretes
          _DrawerItem(svg: _svgReminder, label: 'Lembretes',
            textColor: textP, iconColor: textS, onTap: () => Navigator.pop(context)),

          // ── Remover fundo
          _DrawerItem(svg: _svgRemoveBg, label: 'Remover fundo',
            textColor: textP, iconColor: textS, onTap: () => Navigator.pop(context)),

          // ── Limpar imagem
          _DrawerItem(svg: _svgClearImg, label: 'Limpar imagem',
            textColor: textP, iconColor: textS, onTap: () => Navigator.pop(context)),

          const SizedBox(height: 4),

          // ── Conversas guardadas (sem label/divisória entre elas)
          if (convs.isNotEmpty)
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: convs.length,
                itemBuilder: (_, i) {
                  final conv = convs[i];
                  final isActive = conv.id == widget.activeConvId;
                  return GestureDetector(
                    onTap: () => widget.onOpenConv(conv),
                    child: Container(
                      width: double.infinity,
                      color: isActive ? activeBg : Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                      child: Text(conv.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isActive ? textP : textS,
                          fontSize: 14,
                          fontWeight: isActive ? FontWeight.w500 : FontWeight.w400)),
                    ),
                  );
                },
              ),
            )
          else
            const Spacer(),

          // ── Footer com divisória APENAS aqui
          Divider(height: 1, color: divider),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(children: [
              // Avatar
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()));
                },
                child: Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(color: surfBg, shape: BoxShape.circle),
                  child: AuthService.instance.loggedIn
                    ? Center(child: Text(
                        (AuthService.instance.user?.name ?? 'U')[0].toUpperCase(),
                        style: TextStyle(color: textP, fontSize: 18, fontWeight: FontWeight.w700)))
                    : Center(child: _svg(_svgUser, textS, s: 26)),
                ),
              ),
              const SizedBox(width: 12),
              // Theme toggle
              Expanded(
                child: GestureDetector(
                  onTap: themeNotifier.toggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: toggleBg, borderRadius: BorderRadius.circular(999)),
                    child: Row(children: [
                      Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                        color: textP, size: 20),
                      const SizedBox(width: 10),
                      Expanded(child: Text(
                        isDark ? 'Tema claro' : 'Tema escuro',
                        style: TextStyle(color: textP, fontSize: 14, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 6),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 40, height: 24,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: isDark ? textP : const Color(0xFFD0D0D0)),
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.all(3),
                            width: 18, height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark ? AppColors.darkDrawerBg : AppColors.background),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final String svg, label;
  final Color textColor, iconColor;
  final VoidCallback onTap;
  const _DrawerItem({required this.svg, required this.label,
    required this.textColor, required this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
        child: Row(children: [
          SvgPicture.string(svg, width: 20, height: 20,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn)),
          const SizedBox(width: 14),
          Text(label, style: TextStyle(color: textColor, fontSize: 15,
            fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}
