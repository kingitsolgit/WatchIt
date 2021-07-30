import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watch_it/provider/languageprovider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Provider.debugCheckInvalidValueType = null;

  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
      supportedLocales: [
        Locale("en", "US"),
        Locale("el", "GR"),
        Locale("fr", "FR"),
        Locale("de", "GE")
      ],
      path: "assets/locals",
      saveLocale: true,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          Provider<LanguageProvider>(
            create: (_) => LanguageProvider(),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          title: 'Meteology LiveCams',
          home: GetUnit(),
          debugShowCheckedModeBanner: false,
        ));
  }
}

class GetUnit extends StatefulWidget {
  GetUnit({Key? key}) : super(key: key);

  @override
  _GetUnitState createState() => _GetUnitState();
}

class _GetUnitState extends State<GetUnit> {
  bool? language;

  String? selectedlanguage;
  @override
  void initState() {
    getdata();
    super.initState();
  }

  void getdata() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? sllang = sharedPreferences.getString("apilang");
    bool? languageselected = sharedPreferences.getBool("languageselected");

    if (sllang != null) {
      setState(() {
        selectedlanguage = sllang;
      });
    } else {
      setState(() {
        selectedlanguage = "en";
      });
    }

    if (languageselected != null) {
      setState(() {
        language = languageselected;
      });
    } else {
      setState(() {
        language = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyHomePage(
        selectedlanguage: selectedlanguage,
        language: language,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  String? selectedlanguage;
  bool? language;

  MyHomePage({
    this.selectedlanguage,
    this.language,
  });

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String userst = "nodata";

  // Establish Internet Connection variables
  String _connectionStatus = 'Unknown';

  @override
  void initState() {
    Timer(Duration(seconds: 5), () {
      getsavedata();
    });
    super.initState();
  }

  getsavedata() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? userdata = sharedPreferences.getString("usersavedata");
    print(userdata);
    if (userdata == null) {
      print("running");
    } else {
      setState(() {
        // userModel = UserModel.fromJson(jsonDecode(userdata));

        // var userprovider = Provider.of<UserProvider>(context, listen: false);
        // userprovider.addlogindata(userModel);
      });
      // getuserinfo(userModel.data.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    var kontext = context;
    // var unitprovider = Provider.of<UnitProvider>(context, listen: false);
    var setlanguage = Provider.of<LanguageProvider>(context, listen: false);
    // var usersubstatus =
    //     Provider.of<UserSubscriptionProvier>(context, listen: false);

    setlanguage.setleanguage(widget.selectedlanguage!);

    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Image.asset(
        "assets/splashscreen.png",
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        fit: BoxFit.fill,
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  String? selectedlanguage;
  bool? language;
  MainScreen({
    this.selectedlanguage,
    this.language,
  });
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meteology LiveCams',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: mainwidget(language),
    );
  }

  Widget mainwidget(bool? language) {
    if (language == true) {
      return Center(
        child: Text('True'),
      );
    } else {
      return VideoPlayerApp(language: language);
    }
  }
}

class VideoPlayerApp extends StatelessWidget {
  bool? language;
  VideoPlayerApp({
    this.language,
  });
  @override
  Widget build(BuildContext context) {
    // var unitprovider = Provider.of<UnitProvider>(context, listen: true);
    // print(unitprovider.dateformat);
    return Scaffold(
        body: language == false
            ? Center(child: Text('Ok'))
            : Center(child: Text('No ')));
  }
}

// class VideoPlayerScreen extends StatefulWidget {
//   VideoPlayerScreen({Key key}) : super(key: key);

//   @override
//   _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
// }

// class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
//   VideoPlayerController _videoPlayerController;

//   @override
//   void initState() {
//     super.initState();
//     _videoPlayerController = VideoPlayerController.network(
//       'http://78.46.68.155:8080/qAQF9EFaqkQlIpur8dWhXlS7VtWSU6/hls/eb4Icxt0IU/Vgp6qJOtL6/s.m3u8',
//       // 'https://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_20mb.mp4',
//     )
//       // 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4')
//       ..addListener(() {
//         setState(() {});
//       })
//       ..initialize();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//           child: _videoPlayerController.value.isInitialized
//               ? buildVideoPlayerUi()
//               : CircularProgressIndicator()),
//     );
//   }

//   Widget buildVideoPlayerUi() {
//     return SafeArea(
//       child: SingleChildScrollView(
//         child: Column(
//           children: [
//             AspectRatio(
//               aspectRatio: _videoPlayerController.value.aspectRatio,
//               child: VideoPlayer(
//                 _videoPlayerController,
//               ),
//             ),
//             Text(
//               '${_videoPlayerController.value.position} / ${_videoPlayerController.value.duration}',
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   _videoPlayerController.value.isPlaying
//                       ? _videoPlayerController.pause()
//                       : _videoPlayerController.play();
//                 });
//               },
//               child: Text(
//                   _videoPlayerController.value.isPlaying ? 'Pause' : 'Play'),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
