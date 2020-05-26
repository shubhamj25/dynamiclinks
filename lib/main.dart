import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:http/http.dart' as http;

String apiKey="Nzg1MDYjIyMyMDE4LTA2LTA2IDE2OjUzOjQ1";
Map<String, dynamic> emailData = {
  "subject":"Account Registration details",
  "from":"support@juvlon.com",
  "body":null,
  "to":null,
};


Future<void> main() async{
  ErrorWidget.builder = (FlutterErrorDetails details) => Container();
  WidgetsFlutterBinding.ensureInitialized();
    await FirebaseApp.configure(
        name:'voicemail-firestore',
        options: Platform.isAndroid
            ?const FirebaseOptions(
            googleAppID: '1:1085491046947:android:d3eff448527f7f1846df96',
            apiKey: "AIzaSyDTZ0KA7nwFQcuTnHhO1HSV6T1AKpIvE6o",
            databaseURL: "https://dynamiclinks-d200f.firebaseio.com/"
        ):null);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.vpn_key)),
                Tab(icon: Icon(Icons.person_add)),
              ],
            ),
            title: Text('Tabs Demo'),
          ),
          body: TabBarView(
            children: <Widget>[
              _LoginScreen(),
              _MainScreen(),
            ],
          ),
        ),
      ),
      title: 'Dynamic Links Example',
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        '/helloworld': (BuildContext context) => _DynamicLinkScreen(),
      },
    );
  }
}

class _MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends State<_MainScreen> {
  String _linkMessage;
  bool _isCreatingLink = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController=TextEditingController();
  final _nameController=TextEditingController();
  final _passwordController=TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey=new GlobalKey<ScaffoldState>();
  bool sendingSignUpLink=false;
  bool hidepass=true;
  @override
  void initState() {
    super.initState();
    initDynamicLinks();
  }

  void initDynamicLinks() async {
    final PendingDynamicLinkData data =
    await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    if (deepLink != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context){
            return _DynamicLinkScreen(message: deepLink.queryParameters['message']);
          }
      ));
    }

    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
          final Uri deepLink = dynamicLink?.link;
          if (deepLink != null) {
            Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context){
                  return _DynamicLinkScreen(message: deepLink.queryParameters['message'],email: deepLink.queryParameters['email'],password: deepLink.queryParameters['password'],);
                }
            ));
          }
        }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });
  }

  Future<String> _createDynamicLink(bool short,String email,String password) async {
    setState(() {
      _isCreatingLink = true;
    });

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://dynamiclinks101.page.link',
      link: Uri.parse('https://dynamiclinks101.page.link/post?message=If+you+are+seeing+this+page+that+means+you+have+successfully+implemented+dynamic+links+inside+the+app+.+Make+sure+app+is+installed+and+properly+setup+on+your+phone+.+Email+Service+is+implemented+using+Juvlon+API&email=$email&password=$password'),
      androidParameters: AndroidParameters(
        packageName: 'com.example.dynamiclinks',
      ),
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      ),
    );

    Uri url;
    if (short) {
      final ShortDynamicLink shortLink = await parameters.buildShortLink();
      url = shortLink.shortUrl;
    } else {
      url = await parameters.buildUrl();
    }

    setState(() {
      _linkMessage = url.toString();
      _isCreatingLink = false;
    });
    return _linkMessage;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        key: _scaffoldKey,
        body: Builder(builder: (BuildContext context) {
          return Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                 Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Card(
                      elevation: 10.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0))
                      ),
                      child: Column(
                        children: <Widget>[
                          sendingSignUpLink?LinearProgressIndicator():Container(),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: <Widget>[
                                  TextFormField(
                                    decoration: InputDecoration(
                                      hintText: "Name",
                                      suffixIcon: Icon(Icons.person)
                                    ),
                                    validator: (String val){
                                      if(val==null||val==""){
                                        return "Please fill this field";
                                      }
                                      else{
                                        return null;
                                      }
                                    },
                                    controller: _nameController,
                                  ),
                                  TextFormField(
                                    decoration: InputDecoration(
                                        hintText: "Password",
                                        suffixIcon: IconButton(icon: Icon(hidepass?Icons.lock:Icons.lock_open),onPressed: (){
                                          setState(() {
                                            if(hidepass==true){
                                              hidepass=false;
                                            }
                                            else if(hidepass==false){
                                              hidepass=true;
                                            }
                                          });
                                        },),
                                    ),
                                    validator: (String val){
                                      if(val.length<8){
                                        return "Password must contain atlest 8 characters";
                                      }
                                      else{
                                        return null;
                                      }
                                    },
                                    obscureText: hidepass,
                                    controller: _passwordController,
                                  ),
                                  TextFormField(
                                    decoration: InputDecoration(
                                      hintText: "Email",
                                      suffixIcon: Icon(Icons.email),
                                    ),
                                    onSaved: (String value){
                                      setState(() {
                                        emailData['to']=_emailController.text.trim();
                                      });
                                    },
                                    validator:(String value){
                                      Pattern pattern =
                                          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                      RegExp regex = new RegExp(pattern);
                                      if (!regex.hasMatch(value)) {
                                       return "Please enter a valid email";
                                      }
                                      else{
                                        return null;
                                      }
                                    },
                                    controller: _emailController,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: RaisedButton(
                                      onPressed:() async {
                                        if(_formKey.currentState.validate()){
                                          setState(() {
                                            sendingSignUpLink=true;
                                          });
                                          _formKey.currentState.save();
                                          String link;
                                          if(!_isCreatingLink){
                                            link=await _createDynamicLink(true,_emailController.text.trim(),_passwordController.text.trim());
                                          }
                                          emailData['body']="Click on the link below to confirm your account\n$link";
                                          sendMail();
                                          _scaffoldKey.currentState.showSnackBar(SnackBar(backgroundColor: Colors.green,content: Row(
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.all(5.0),
                                                child: Icon(Icons.check_circle,color: Colors.white,),
                                              ),
                                              Text("Confirmation sent to your Email"),
                                            ],
                                          ),));
                                        }
                                      },
                                      child: const Text('SignUp'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}


class _DynamicLinkScreen extends StatefulWidget {
  final String message,email,password;
  _DynamicLinkScreen({this.email,this.password,this.message});
  @override
  __DynamicLinkScreenState createState() => __DynamicLinkScreenState();
}

class __DynamicLinkScreenState extends State<_DynamicLinkScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    createUser();
  }

  void createUser() async{
    final FirebaseAuth auth = FirebaseAuth.instance;
    await auth.createUserWithEmailAndPassword(email: widget.email, password: widget.password);
  }

  final GlobalKey<ScaffoldState> _scaffoldKey=new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        child: Scaffold(
          key: _scaffoldKey,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(width:MediaQuery.of(context).size.width,height:40.0,color: Colors.blueAccent,child: Padding(
                padding: const EdgeInsets.symmetric(horizontal:20.0),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Icon(Icons.account_circle,color: Colors.white,),
                    ),
                    Text("Signed Up Successfully",style: TextStyle(color: Colors.white,fontSize:16.0),),
                  ],
                ),
              ),),

              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text('Welcome to\nDynamicLinks!',style: TextStyle(fontSize: 24.0,fontWeight: FontWeight.w700),),
              ),
              widget.message!=null?
              Padding(
                padding: const EdgeInsets.symmetric(vertical:40.0,horizontal: 32.0),
                child: Text("${widget.message}",style: TextStyle(fontSize: 20.0),),
              ):Container(),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 1,
            child: Icon(Icons.exit_to_app),
            onPressed: ()=>Navigator.of(context).pushReplacementNamed('/'),
          ),
        ),
      ),
    );
  }
}


class _LoginScreen extends StatefulWidget {
  @override
  __LoginScreenState createState() => __LoginScreenState();
}

class __LoginScreenState extends State<_LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController=TextEditingController();
  final _passwordController=TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey=new GlobalKey<ScaffoldState>();
  bool hidepass=true;
  bool loggingin=false;
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        key: _scaffoldKey,
        body: Builder(builder: (BuildContext context) {
          return Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Card(
                      elevation: 10.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0))
                      ),
                      child: Column(
                        children: <Widget>[
                          loggingin?LinearProgressIndicator():Container(),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: <Widget>[
                                  TextFormField(
                                    decoration: InputDecoration(
                                      hintText: "Email",
                                      suffixIcon: Icon(Icons.email),
                                    ),
                                    onSaved: (String value){
                                      setState(() {
                                        emailData['to']=_emailController.text.trim();
                                      });
                                    },
                                    controller: _emailController,
                                  ),
                                  TextFormField(
                                    decoration: InputDecoration(
                                      hintText: "Password",
                                      suffixIcon: IconButton(icon: Icon(hidepass?Icons.lock:Icons.lock_open),onPressed: (){
                                        setState(() {
                                          if(hidepass==true){
                                            hidepass=false;
                                          }
                                          else if(hidepass==false){
                                            hidepass=true;
                                          }
                                        });
                                      },),
                                    ),
                                    obscureText: hidepass,
                                    controller: _passwordController,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: RaisedButton(
                                      child: Text("Login"),
                                      onPressed: () async {
                                        setState(() {
                                          loggingin=true;
                                        });
                                        try {
                                          final FirebaseAuth auth = FirebaseAuth
                                              .instance;
                                          await auth
                                              .signInWithEmailAndPassword(
                                              email: _emailController.text
                                                  .trim(),
                                              password: _passwordController.text
                                                  .trim()).then((user){
                                                    if(user!=null){
                                                      setState(() {
                                                        _scaffoldKey.currentState.showSnackBar(SnackBar(backgroundColor: Colors.green,content: Row(
                                                          children: <Widget>[
                                                            Padding(
                                                              padding: const EdgeInsets.all(5.0),
                                                              child: Icon(Icons.verified_user,color:Colors.white),
                                                            ),
                                                            Text("Logged In Succesfully !"),
                                                          ],
                                                        ),));
                                                      });
                                                      setState(() {
                                                        loggingin=false;
                                                      });
                                                    }
                                          });
                                        } catch (e) {
                                          setState(() {
                                            _scaffoldKey.currentState.showSnackBar(SnackBar(backgroundColor: Colors.red,content: Row(
                                              children: <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets.all(5.0),
                                                  child: Icon(Icons.close,color:Colors.white),
                                                ),
                                                Text("Invalid Credentials"),
                                              ],
                                            ),));
                                          });
                                          setState(() {
                                            loggingin=false;
                                          });
                                        }
                                      }
                                    )
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}


sendMail() async{
  var uri = new Uri.http('api2.juvlon.com', '/v4/httpSendMail');
  var data=json.encode({
    "ApiKey":apiKey,
    "requests":[emailData],
  });
  print(data);
  http.Response response = await http.post(uri,
      headers: {
        "Content-Type": "application/json"
      },
      body: data
  );
   print(response);
}