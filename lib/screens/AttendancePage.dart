import 'dart:async';
import 'dart:convert';

import 'package:ams/models/AttendanceReportModel.dart';
import 'package:ams/screens/widgets/commonbodyStrecture.dart';
import 'package:ams/screens/widgets/commonwidgets.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AttendancePage extends StatefulWidget {
  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (context) => AttendancePage(),
    );
  }

  //static const routeName = "/AttendancePage";

  @override
  AttendancePageState createState() => AttendancePageState();
}

class AttendancePageState extends State<AttendancePage> {
  // var dts = new DTS(null);
  List<Message> attendanceList = [];
  //var _connectionState = 'Unknown';
  bool internetConn = true;
  Connectivity connectivity;
  StreamSubscription<ConnectivityResult> subscription;
  bool loadingData = false;

  checkConnection() {
    connectivity = Connectivity();
    subscription =
        connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      //_connectionState = result.toString();
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        setState(() {
          internetConn = true;
        });
        print("Internet Connection state is $result");
        getAttendanceReport();
      } else if (result == ConnectivityResult.none) {
        setState(() {
          internetConn = false;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    checkConnection();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  getAttendanceReport() async {
    var client = new http.Client();

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var tokenId = sharedPreferences.getString('userToken' ?? false);
    var userId = sharedPreferences.getInt('userId' ?? false);
    try {
      setState(() {
        loadingData = true;
      });
      String url =
          "http://adevole.com/clients/attendance_app/mobile/attendance_report.php?user_id=$userId&security_key=$tokenId";
      final response = await client.put(url);
      print("Task Response body: ${response.body}");
      if (response.statusCode == 200) {
        var jsonData =
            AttendanceReportModel.fromJson(json.decode(response.body));
        setState(() {
          // dts = DTS(jsonData.message);
          attendanceList = jsonData.message;
          // var tableItemsCount = dts.rowCount;
        });
        setState(() {
          loadingData = false;
        });
      }
    } catch (exception) {
      print(exception);
    }
  }

  Widget _bodyData() => ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 10),
        shrinkWrap: true,
        itemCount: attendanceList.length,
        itemBuilder: (context, index) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RichText(
                    text: TextSpan(
                        text: 'In Address :- ',
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontFamily: 'Comfortaa'),
                        children: [
                          TextSpan(
                              text: attendanceList[index].inAddress ?? '',
                              style: TextStyle(color: Colors.black))
                        ]),
                  ),
                  if((attendanceList[index].outAddress??'').length>0)
                  RichText(
                    text: TextSpan(
                        text: 'Out Address :- ',
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontFamily: 'Comfortaa'),
                        children: [
                          TextSpan(
                              text: attendanceList[index].outAddress ?? '',
                              style: TextStyle(color: Colors.black))
                        ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: RichText(
                      text: TextSpan(
                          text: 'Date :- ',
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontFamily: 'Comfortaa'),
                          children: [
                            TextSpan(
                                text: attendanceList[index].createdDate != null
                                    ? attendanceList[index]
                                        .createdDate
                                        .substring(0, 10)
                                    : '',
                                style: TextStyle(color: Colors.black))
                          ]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Wrap(
                      direction: Axis.horizontal,
                      alignment: WrapAlignment.spaceBetween,
                      runSpacing: 4,
                      spacing: 4,
                      children: <Widget>[
                        RichText(
                          text: TextSpan(
                              text: 'Check In :- ',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontFamily: 'Comfortaa'),
                              children: [
                                TextSpan(
                                    text: attendanceList[index].inTime != null
                                        ? getTime(attendanceList[index].inTime)
                                        : '',
                                    style: TextStyle(color: Colors.black))
                              ]),
                        ),
                        RichText(
                          text: TextSpan(
                              text: 'Check Out :- ',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontFamily: 'Comfortaa'),
                              children: [
                                TextSpan(
                                    text: attendanceList[index].outTime != null
                                        ? getTime(attendanceList[index].outTime)
                                        : '',
                                    style: TextStyle(color: Colors.black))
                              ]),
                        ),
                        RichText(
                          text: TextSpan(
                              text: 'Total :- ',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontFamily: 'Comfortaa'),
                              children: [
                                TextSpan(
                                    text: attendanceList[index].hrsWorked ?? '',
                                    style: TextStyle(color: Colors.black))
                              ]),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      );

  String getTime(String time) {
    var format = intl.DateFormat.jm();
    String _time = format.format(DateTime.parse(time));
    return _time;
  }

  // Widget bodyData() => SingleChildScrollView(
  //       child: PaginatedDataTable(
  //           header: Text(
  //             "Attendance Details",
  //             style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
  //           ),
  //           //rowsPerPage: 20,
  //           columns: <DataColumn>[
  //             DataColumn(label: commonText("Location")),
  //             /*DataColumn(
  //                 label: Expanded(flex: 2,child: commenText("Date"))),*/
  //             DataColumn(label: commonText("Check In")),
  //             DataColumn(label: commonText("Check Out")),
  //             DataColumn(
  //                 label: Expanded(flex: 2, child: commonText("Total Time"))),
  //           ],
  //           source: dts),
  //     );

  @override
  Widget build(BuildContext context) {
    return CommonBodyStructure(
      text: "Attendance Details",
      child: internetConn == false
          ? Center(
              child: noConnection(),
            )
          : loadingData
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : _bodyData(),
    );
  }
}

// class DTS extends DataTableSource {
//   List<Message> reportList;
//   DTS(List<Message> attendanceList) {
//     reportList = attendanceList;
//   }

//   @override
//   DataRow getRow(int index) {
//     return reportList != null
//         ? DataRow.byIndex(
//             index: index,
//             cells: [
//               DataCell(
//                   Container(
//                       width: 200.0,
//                       child: Text(
//                         reportList[index].inAddress != null
//                             ? reportList[index].inAddress
//                             : "",
//                         softWrap: true,
//                       )), onTap: () {
//                 print("Project Location");
//               }),
//               //DataCell(Text(reportList[index].cretaed_date!= null?reportList[index].cretaed_date:""), onTap: (){print("Project Date");}),
//               DataCell(
//                   Text(reportList[index].inTime != null
//                       ? reportList[index].inTime
//                       : ""), onTap: () {
//                 print("Project CHeckIn");
//               }),
//               DataCell(
//                   Text(reportList[index].outTime != null
//                       ? reportList[index].outTime
//                       : ""), onTap: () {
//                 print("Project CHeckOut");
//               }),
//               DataCell(
//                   Text(reportList[index].hrsWorked != null
//                       ? reportList[index].hrsWorked
//                       : ""), onTap: () {
//                 print("Project TotalTime");
//               }),
//             ],
//           )
//         : null;
//   }

//   @override
//   int get rowCount => reportList != null
//       ? reportList.length
//       : 0; // Manipulate this to which ever value you wish

//   @override
//   bool get isRowCountApproximate => false;

//   @override
//   int get selectedRowCount => 0;
// }
