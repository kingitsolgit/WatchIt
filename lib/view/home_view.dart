// import 'package:flutter/material.dart';
// // import 'package:notifyme/services/notification.dart';
// import 'package:provider/provider.dart';
// import 'package:watch_it/services/notification.dart';
// import 'package:wear/wear.dart';

// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   @override
//   void initState() {
//     Provider.of<NotificationService>(context, listen: false).initialize();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WatchShape(builder: (context, shape, child) {
//       print('in watch shape ');
//       return Scaffold(
//         body: SingleChildScrollView(
//           child: Container(
//             child: Center(
//               child: Consumer<NotificationService>(
//                 builder: (context, model, _) => Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       ElevatedButton(
//                         onPressed: () async {
//                           return model.instantNofitication();
//                         },
//                         child: Text('Instant '),
//                       ),
//                       ElevatedButton(
//                         onPressed: () async {
//                           return model.imageNotification();
//                         },
//                         child: Text('Image '),
//                       ),
//                       ElevatedButton(
//                         onPressed: () async {
//                           return model.stylishNotification();
//                         },
//                         child: Text('Media '),
//                       ),
//                       ElevatedButton(
//                         onPressed: () async {
//                           return model.sheduledNotification();
//                         },
//                         child: Text('Scheduled '),
//                       ),
//                       ElevatedButton(
//                         onPressed: () async {
//                           return model.cancelNotification();
//                         },
//                         child: Text('Cancel '),
//                       ),
//                     ]),
//               ),
//             ),
//           ),
//         ),
//       );
//     });
//   }
// }
