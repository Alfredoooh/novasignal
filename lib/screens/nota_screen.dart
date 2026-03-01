import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/theme.dart';

class _Nota {
  String id, title, html;
  DateTime updatedAt;
  _Nota({required this.id,required this.title,required this.html,required this.updatedAt});
  Map<String,dynamic> toJson()=>{'id':id,'title':title,'html':html,'updatedAt':updatedAt.toIso8601String()};
  factory _Nota.fromJson(Map<String,dynamic> j)=>_Nota(
    id:j['id']??'',title:j['title']??'Nota sem título',
    html:j['html']??'',updatedAt:DateTime.tryParse(j['updatedAt']??'')??DateTime.now());
}

class NotaScreen extends StatefulWidget {
  const NotaScreen({super.key});
  @override State<NotaScreen> createState()=>_NotaScreenState();
}

class _NotaScreenState extends State<NotaScreen> {
  List<_Nota> _notas=[];
  bool _loading=true;

  @override void initState(){super.initState();themeNotifier.addListener(_onTheme);_load();}
  @override void dispose(){themeNotifier.removeListener(_onTheme);super.dispose();}
  void _onTheme()=>setState((){});

  Future<void> _load() async {
    final p=await SharedPreferences.getInstance();
    final raw=p.getString('aria_notas_v2');
    if(raw!=null){
      try{
        final l=jsonDecode(raw) as List;
        _notas=l.map((j)=>_Nota.fromJson(j as Map<String,dynamic>)).toList();
        _notas.sort((a,b)=>b.updatedAt.compareTo(a.updatedAt));
      }catch(_){}
    }
    if(mounted)setState(()=>_loading=false);
  }

  Future<void> _save() async {
    final p=await SharedPreferences.getInstance();
    await p.setString('aria_notas_v2',jsonEncode(_notas.map((n)=>n.toJson()).toList()));
  }

  Future<void> _open(_Nota nota,bool isNew) async {
    final r=await Navigator.push<_Nota>(context,MaterialPageRoute(builder:(_)=>_EditorScreen(nota:nota,isNew:isNew)));
    if(r!=null){
      _notas.removeWhere((n)=>n.id==r.id);
      if(r.html.isNotEmpty||r.title!='Nota sem título')_notas.insert(0,r);
      _notas.sort((a,b)=>b.updatedAt.compareTo(a.updatedAt));
      await _save();
      if(mounted)setState((){});
    }
  }

  void _new()=>_open(_Nota(id:DateTime.now().millisecondsSinceEpoch.toString(),title:'Nota sem título',html:'',updatedAt:DateTime.now()),true);

  Future<void> _delete(_Nota n) async {
    final isDark=themeNotifier.isDark;
    final ok=await showDialog<bool>(context:context,builder:(_)=>AlertDialog(
      backgroundColor:isDark?AppColors.darkSurface:Colors.white,
      title:Text('Eliminar nota?',style:TextStyle(color:isDark?AppColors.darkTextPrimary:AppColors.textPrimary,fontWeight:FontWeight.w700)),
      actions:[
        TextButton(onPressed:()=>Navigator.pop(context,false),child:Text('Cancelar',style:TextStyle(color:accColor(isDark)))),
        TextButton(onPressed:()=>Navigator.pop(context,true),child:const Text('Eliminar',style:TextStyle(color:Colors.red))),
      ],
    ));
    if(ok==true){_notas.removeWhere((x)=>x.id==n.id);await _save();if(mounted)setState((){});}
  }

  String _preview(String html)=>html.replaceAll(RegExp(r'<[^>]+>'),' ').replaceAll(RegExp(r'\s+'),' ').trim();
  String _date(DateTime d){
    final diff=DateTime.now().difference(d);
    if(diff.inMinutes<1)return 'agora';
    if(diff.inHours<1)return '${diff.inMinutes}m';
    if(diff.inDays<1)return '${diff.inHours}h';
    if(diff.inDays<7)return '${diff.inDays}d';
    return '${d.day}/${d.month}';
  }

  @override
  Widget build(BuildContext c){
    final isDark=themeNotifier.isDark;
    final bg=isDark?AppColors.darkBackground:AppColors.background;
    final tp=isDark?AppColors.darkTextPrimary:AppColors.textPrimary;
    final ts=isDark?AppColors.darkTextSecondary:AppColors.textSecondary;
    final div=isDark?AppColors.darkDivider:AppColors.divider;
    final acc=accColor(isDark);
    return Scaffold(
      backgroundColor:bg,
      floatingActionButton:FloatingActionButton(onPressed:_new,backgroundColor:acc,child:const Icon(Icons.add_rounded,color:Colors.white)),
      body:_loading
        ?Center(child:CircularProgressIndicator(color:acc))
        :_notas.isEmpty
          ?Center(child:Column(mainAxisSize:MainAxisSize.min,children:[
            Icon(Icons.notes_rounded,size:56,color:ts.withOpacity(.3)),
            const SizedBox(height:14),
            Text('Sem notas',style:GoogleFonts.roboto(color:tp,fontSize:18,fontWeight:FontWeight.w700)),
            const SizedBox(height:6),
            Text('Toca no + para criar',style:GoogleFonts.roboto(color:ts,fontSize:14)),
          ]))
          :ListView.separated(
            padding:const EdgeInsets.fromLTRB(16,12,16,100),
            itemCount:_notas.length,
            separatorBuilder:(_,__)=>Divider(color:div,height:1),
            itemBuilder:(_,i){
              final n=_notas[i];
              return Dismissible(
                key:Key(n.id),direction:DismissDirection.endToStart,
                onDismissed:(_)=>_delete(n),
                background:Container(color:Colors.red,alignment:Alignment.centerRight,
                  padding:const EdgeInsets.only(right:20),
                  child:const Icon(Icons.delete_outline_rounded,color:Colors.white)),
                child:ListTile(
                  contentPadding:const EdgeInsets.symmetric(horizontal:4,vertical:6),
                  title:Text(n.title,maxLines:1,overflow:TextOverflow.ellipsis,
                    style:GoogleFonts.roboto(color:tp,fontWeight:FontWeight.w700,fontSize:15)),
                  subtitle:Text(_preview(n.html),maxLines:2,overflow:TextOverflow.ellipsis,
                    style:GoogleFonts.roboto(color:ts,fontSize:13)),
                  trailing:Text(_date(n.updatedAt),style:GoogleFonts.roboto(color:ts,fontSize:11)),
                  onTap:()=>_open(n,false),onLongPress:()=>_delete(n),
                ),
              );
            },
          ),
    );
  }
}

class _EditorScreen extends StatefulWidget {
  final _Nota nota;final bool isNew;
  const _EditorScreen({required this.nota,required this.isNew});
  @override State<_EditorScreen> createState()=>_EditorScreenState();
}

class _EditorScreenState extends State<_EditorScreen> {
  InAppWebViewController? _wvc;
  late _Nota _nota;
  bool _changed=false;
  late TextEditingController _titleCtrl;

  @override void initState(){
    super.initState();
    _nota=_Nota(id:widget.nota.id,title:widget.nota.title,html:widget.nota.html,updatedAt:widget.nota.updatedAt);
    _titleCtrl=TextEditingController(text:_nota.title);
    themeNotifier.addListener(_onTheme);
  }
  @override void dispose(){_titleCtrl.dispose();themeNotifier.removeListener(_onTheme);super.dispose();}
  void _onTheme(){setState((){});_wvc?.evaluateJavascript(source:'setTheme(${themeNotifier.isDark})');}

  Future<void> _pop() async {
    final html=(await _wvc?.evaluateJavascript(source:'getContent()'))?.toString()??_nota.html;
    final title=_titleCtrl.text.trim().isEmpty?'Nota sem título':_titleCtrl.text.trim();
    if(mounted)Navigator.pop(context,_Nota(id:_nota.id,title:title,html:html,updatedAt:DateTime.now()));
  }

  @override
  Widget build(BuildContext c){
    final isDark=themeNotifier.isDark;
    final bg=isDark?AppColors.darkBackground:AppColors.background;
    final tp=isDark?AppColors.darkTextPrimary:AppColors.textPrimary;
    final ts=isDark?AppColors.darkTextSecondary:AppColors.textSecondary;
    final acc=accColor(isDark);
    return PopScope(
      canPop:false,
      onPopInvoked:(did) async{if(!did)await _pop();},
      child:Scaffold(
        backgroundColor:bg,
        appBar:AppBar(
          backgroundColor:bg,elevation:0,scrolledUnderElevation:0,
          leading:IconButton(icon:Icon(Icons.arrow_back_ios_new_rounded,color:acc,size:20),onPressed:_pop),
          title:TextField(
            controller:_titleCtrl,
            style:GoogleFonts.roboto(color:tp,fontSize:17,fontWeight:FontWeight.w700),
            decoration:InputDecoration(border:InputBorder.none,isDense:true,
              hintText:'Título',hintStyle:GoogleFonts.roboto(color:ts,fontSize:17)),
            onChanged:(_){if(!_changed)setState(()=>_changed=true);},
          ),
          actions:[
            if(_changed)TextButton(onPressed:_pop,
              child:Text('Guardar',style:GoogleFonts.roboto(color:acc,fontWeight:FontWeight.w700))),
          ],
        ),
        body:InAppWebView(
          initialFile:'assets/nota/nota.html',
          initialSettings:InAppWebViewSettings(
            javaScriptEnabled:true,transparentBackground:true,
            allowFileAccessFromFileURLs:true,allowUniversalAccessFromFileURLs:true,
            supportZoom:false,
          ),
          onWebViewCreated:(ctrl){
            _wvc=ctrl;
            ctrl.addJavaScriptHandler(handlerName:'NotaBridge',callback:(args){
              try{
                final d=jsonDecode(args[0] as String) as Map<String,dynamic>;
                final action=d['action'] as String?;
                if(action=='autosave'){
                  _nota=_Nota(id:_nota.id,title:_titleCtrl.text,
                    html:d['html'] as String??_nota.html,updatedAt:DateTime.now());
                }
                if((action=='autosave'||action=='changed')&&!_changed&&mounted)setState(()=>_changed=true);
              }catch(_){}
            });
          },
          onLoadStop:(ctrl,_) async {
            await ctrl.evaluateJavascript(source:'setTheme(${themeNotifier.isDark})');
            if(_nota.html.isNotEmpty){
              final b64=base64Encode(utf8.encode(_nota.html));
              await ctrl.evaluateJavascript(source:'''(function(){
                const b="$b64";
                const h=decodeURIComponent(Array.from(atob(b)).map(c=>'%'+c.charCodeAt(0).toString(16).padStart(2,'0')).join(''));
                loadContent(h);
              })();''');
            }
          },
        ),
      ),
    );
  }
}
