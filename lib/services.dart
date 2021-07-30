// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart';
// import 'package:mobile_stylz/BaseUrl/baseurl.dart';
// import 'package:mobile_stylz/Model/myservices.dart';
// import 'package:mobile_stylz/Provider/userdataprovider.dart';
// import 'package:mobile_stylz/Screens/Slots/availableslots.dart';
// import 'package:mobile_stylz/Screens/booking/booking.dart';
// import 'package:provider/provider.dart';

// class Services extends StatefulWidget {
//   String id;
//   Services(this.id);
//   @override
//   _ServicesState createState() => _ServicesState();
// }

// class _ServicesState extends State<Services> {
//   Future<MyServices> getposts(String id) async {
//     var url = Uri.parse("${BaseUrl.baseurl}/service/get-my-services/${id}");
//     final response = await get(url);
//     if (response.statusCode == 200) {
//       return MyServices.fromJson(jsonDecode(response.body));
//     } else {
//       print(response.body);
//     }
//   }

//   Stream<MyServices> getNumbers(Duration refreshTime, var id) async* {
//     while (true) {
//       await Future.delayed(refreshTime);
//       yield await getposts(id);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     var userdata = Provider.of<UserProvider>(context);
//     var userid = userdata.userLoginModel.data[0];

//     return Scaffold(
//       body: StreamBuilder(
//         stream: getNumbers(Duration(milliseconds: 6), widget.id),
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             MyServices myServices = snapshot.data;
//             return ListView.builder(
//               itemCount: myServices.data.length,
//               itemBuilder: (context, index) {
//                 return Padding(
//                   padding: EdgeInsets.only(top: 10),
//                   child: ListTile(
//                     title: Row(
//                       children: [
//                         Text(myServices.data[index].name),
//                         Padding(
//                           padding: EdgeInsets.only(left: 10),
//                         ),
//                         Text(
//                           "\$ ${myServices.data[index].cost}",
//                           style: TextStyle(fontSize: 12),
//                         )
//                       ],
//                     ),
//                     trailing: MaterialButton(
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10.0)),
//                       color: Colors.red,
//                       onPressed: () {
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => AvailableSLots(
//                                     serviceid: myServices.data[index].id,
//                                     userid: widget.id,
//                                     cost: myServices.data[index].cost)));
//                       },
//                       child: Text(
//                         "Book here",
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                     subtitle: Text(
//                       "threeading pending etc",
//                       // myServices.data[index].detail,
//                       style: TextStyle(fontSize: 13),
//                     ),
//                     leading: ClipRRect(
//                       borderRadius: BorderRadius.circular(8.0),
//                       child: Image.network(
//                         "${BaseUrl.baseurl}/${myServices.data[index].preview}",
//                         fit: BoxFit.cover,
//                         height: 80,
//                         width: 70,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             );
//           } else {
//             return Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//         },
//       ),
//     );
//   }
// }
