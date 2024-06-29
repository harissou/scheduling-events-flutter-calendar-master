library event_calendar;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:scheduling_events/services/api-service.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:ui_helper/ui_helper.dart';
import 'login.dart';
import 'models/user.dart';

part 'color-picker.dart';

part 'target.dart';

part 'timezone-picker.dart';

part 'appointment-editor.dart';

part 'doctorpicker.dart';

part 'welcome.dart';

void main() => runApp(const MaterialApp(
      home: EventCalendar(),
      debugShowCheckedModeBanner: false,
    ));

//ignore: must_be_immutable
class EventCalendar extends StatefulWidget {
  const EventCalendar({Key? key}) : super(key: key);

  @override
  EventCalendarState createState() => EventCalendarState();
}

List<Color> _colorCollection = <Color>[];
String? _networkStatusMsg;
final Connectivity _internetConnectivity = new Connectivity();
final bool allowDragAndDrop = true;
List<String> _colorNames = <String>[];
int _selectedColorIndex = 0;
int _selectedTimeZoneIndex = 0;
int _selectedResourceIndex = 0;
List<String> _timeZoneCollection = <String>[];
DataSource _events = DataSource([]);
Meeting? _selectedAppointment;
late DateTime _startDate;
late TimeOfDay _startTime;
late DateTime _endDate;
late TimeOfDay _endTime;
bool _isAllDay = false;
String _subject = '';
String _notes = '';


class EventCalendarState extends State<EventCalendar> {
  EventCalendarState();

  CalendarView _calendarView = CalendarView.month;
  late List<String> eventNameCollection;
  List<Meeting> appointments = [];

  // CalendarDataSource _events=DataSource([]);
  bool isLoading = true;

  @override
  void initState() {
    _calendarView = CalendarView.month;
    _initializeEventColor();

    // getDataFromWeb().then((result) {
    //   debugPrint('ssssssssssss:$result');
    //
    //   appointments = result;
    //   _events = DataSource(appointments);
    //   debugPrint('aaaaaaaaaaaaaaaaaa:$_events');
    //
    //   isLoading = false;
    //
    // });

    _selectedAppointment = null;
    _selectedColorIndex = 0;
    _selectedTimeZoneIndex = 0;
    _subject = '';
    _notes = '';
    getDataFromWeb();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          title: new Text("bienvenue"),
        ),
        resizeToAvoidBottomInset: false,
        body: Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
            child: getEventCalendar(_calendarView, onCalendarTapped)));
  }

  Widget getEventCalendar(
      CalendarView _calendarView, CalendarTapCallback calendarTapCallback) {
    return Container(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Container(
                    child: SfCalendar(
                  initialDisplayDate: DateTime(2017, 05, 01),
                  view: _calendarView,
                  onTap: calendarTapCallback,
                  allowDragAndDrop: true,
                  onDragStart: dragStart,
                  onDragEnd: dragEnd,
                  allowViewNavigation: true,
                  monthViewSettings: MonthViewSettings(
                      appointmentDisplayMode:
                          MonthAppointmentDisplayMode.appointment),
                  allowedViews: <CalendarView>[
                    CalendarView.day,
                    CalendarView.week,
                    CalendarView.workWeek,
                    CalendarView.month,
                    CalendarView.schedule
                  ],
                  dataSource: _events,
                )),
              ));
    //   Container(
    //   child: FutureBuilder<List<Meeting>>(
    //     future: getDataFromWeb(),
    //     builder: (BuildContext context, AsyncSnapshot<List<Meeting>> snapshot) {
    //       if (snapshot.data != null && snapshot.hasData) {
    //         return SafeArea(
    //           child: Container(
    //               child: SfCalendar(
    //             initialDisplayDate: DateTime(2017, 05, 01),
    //             view: _calendarView,
    //             onTap: calendarTapCallback,
    //             allowDragAndDrop: true,
    //             allowViewNavigation: true,
    //             monthViewSettings: MonthViewSettings(
    //                 appointmentDisplayMode:
    //                     MonthAppointmentDisplayMode.appointment),
    //             allowedViews: <CalendarView>[
    //               CalendarView.day,
    //               CalendarView.week,
    //               CalendarView.workWeek,
    //               CalendarView.month,
    //               CalendarView.schedule
    //             ],
    //             dataSource: _events,
    //           )),
    //         );
    //       } else {
    //         return Container(
    //           child: Center(
    //             child: Column(children:[
    //               Text(snapshot.hasError.toString()),
    //               Text(snapshot.error.toString()),
    //               CircularProgressIndicator(),
    //             ]),
    //           ),
    //         );
    //       }
    //     },
    //   ),
    // );
  }

  void dragEnd(AppointmentDragEndDetails appointmentDragEndDetails) {
    dynamic appointment = appointmentDragEndDetails.appointment!;
    CalendarResource? sourceResource = appointmentDragEndDetails.sourceResource;
    CalendarResource? targetResource = appointmentDragEndDetails.targetResource;
    DateTime? droppingTime = appointmentDragEndDetails.droppingTime;
  }

  void dragStart(AppointmentDragStartDetails appointmentDragStartDetails) {
    dynamic appointment = appointmentDragStartDetails.appointment;
    CalendarResource? resource = appointmentDragStartDetails.resource;
  }

  Future<List<Meeting>> getDataFromWeb() async {
    print("GETTING DATA FROM WEB");
    var data = await http.get(Uri.parse(
        "https://js.syncfusion.com/demos/ejservices/api/Schedule/LoadData"));
    var jsonData = json.decode(data.body);

    final List<Meeting> appointmentData = [];
    final Random random = new Random();
    for (var data in jsonData) {
      Meeting meetingData = Meeting(
          id: data['Id'],
          eventName: data['Subject'],
          from: _convertDateFromString(
            data['StartTime'],
          ),
          to: _convertDateFromString(data['EndTime']),
          background: _colorCollection[random.nextInt(9)],
          isAllDay: data['AllDay'], ids: []);
      appointmentData.add(meetingData);
    }
    setState(() {
      _events = DataSource(appointmentData);
      isLoading = false;
      setListeners();
    });
    return Future.value(appointmentData);
  }

  void setListeners() {
    _events.addListener((action, meetings) {
      if (action == CalendarDataSourceAction.add) {
        //TODO: ADD OR UPDATE API CALL THEN SETSTATE
        ApiService.postinfomeeting(meetings);
        setState(() {
          meetings.forEach((element) => _events.appointments!.add(element));
        });
      } else if (action == CalendarDataSourceAction.remove) {
        //TODO: DELETE API CALL THEN SET STATE
        setState(() {
          meetings.forEach((meeting) {
            _events.appointments!.removeWhere((element) {
              return element.id == meeting.id;
            });
          });
        });
      }
    });
  }

  DateTime _convertDateFromString(String date) {
    return DateTime.parse(date);
  }

  void onCalendarViewChange(String value) {
    if (value == 'Day') {
      _calendarView = CalendarView.day;
    } else if (value == 'Week') {
      _calendarView = CalendarView.week;
    } else if (value == 'Work week') {
      _calendarView = CalendarView.workWeek;
    } else if (value == 'Month') {
      _calendarView = CalendarView.month;
    } else if (value == 'Timeline day') {
      _calendarView = CalendarView.timelineDay;
    } else if (value == 'Timeline week') {
      _calendarView = CalendarView.timelineWeek;
    } else if (value == 'Timeline work week') {
      _calendarView = CalendarView.timelineWorkWeek;
    }

    setState(() {});
  }

  void onCalendarTapped(CalendarTapDetails calendarTapDetails) {
    if (calendarTapDetails.targetElement != CalendarElement.calendarCell &&
        calendarTapDetails.targetElement != CalendarElement.appointment) {
      return;
    }

    setState(() {
      _selectedAppointment = null;
      _isAllDay = false;
      _selectedColorIndex = 0;
      _selectedTimeZoneIndex = 0;
      _subject = '';
      _notes = '';
      if (_calendarView == CalendarView.month) {
        _calendarView = CalendarView.day;
      } else {
        if (calendarTapDetails.appointments != null &&
            calendarTapDetails.appointments!.length == 1) {
          final Meeting meetingDetails = calendarTapDetails.appointments![0];
          _startDate = meetingDetails.from;
          _endDate = meetingDetails.to;
          _isAllDay = meetingDetails.isAllDay;
          _selectedColorIndex =
              _colorCollection.indexOf(meetingDetails.background);
          _selectedTimeZoneIndex = meetingDetails.startTimeZone == ''
              ? 0
              : _timeZoneCollection.indexOf(meetingDetails.startTimeZone);
          _subject = meetingDetails.eventName == '(No title)'
              ? ''
              : meetingDetails.eventName;
          _notes = meetingDetails.description;
          _selectedAppointment = meetingDetails;
          // TO DO
          // Navigator.push<Widget>(
          //   context,
          //   MaterialPageRoute(
          //       builder: (BuildContext context) => AppointmentEditor(get user from datand put it here)),
          //);
        } else {
          final DateTime date = calendarTapDetails.date!;
          _startDate = date;
          _endDate = date.add(const Duration(hours: 1));
        }
        _startTime =
            TimeOfDay(hour: _startDate.hour, minute: _startDate.minute);
        _endTime = TimeOfDay(hour: _endDate.hour, minute: _endDate.minute);
        Navigator.push<Widget>(
          context,
          MaterialPageRoute(builder: (BuildContext context) => MyHomePage()),
        );
      }
    });
  }

  void _initializeEventColor() {
    _colorCollection = <Color>[];
    _colorCollection.add(const Color(0xFF0F8644));
    _colorCollection.add(const Color(0xFF8B1FA9));
    _colorCollection.add(const Color(0xFFD20100));
    _colorCollection.add(const Color(0xFFFC571D));
    _colorCollection.add(const Color(0xFF85461E));
    _colorCollection.add(const Color(0xFFFF00FF));
    _colorCollection.add(const Color(0xFF3D4FB5));
    _colorCollection.add(const Color(0xFFE47C73));
    _colorCollection.add(const Color(0xFF636363));

    _colorNames = <String>[];
    _colorNames.add('Green');
    _colorNames.add('Purple');
    _colorNames.add('Red');
    _colorNames.add('Orange');
    _colorNames.add('Caramel');
    _colorNames.add('Magenta');
    _colorNames.add('Blue');
    _colorNames.add('Peach');
    _colorNames.add('Gray');

    _timeZoneCollection = <String>[];
    _timeZoneCollection.add('Default Time');
    _timeZoneCollection.add('AUS Central Standard Time');
    _timeZoneCollection.add('AUS Eastern Standard Time');
    _timeZoneCollection.add('Afghanistan Standard Time');
    _timeZoneCollection.add('Alaskan Standard Time');
    _timeZoneCollection.add('Arab Standard Time');
    _timeZoneCollection.add('Arabian Standard Time');
    _timeZoneCollection.add('Arabic Standard Time');
    _timeZoneCollection.add('Argentina Standard Time');
    _timeZoneCollection.add('Atlantic Standard Time');
    _timeZoneCollection.add('Azerbaijan Standard Time');
    _timeZoneCollection.add('Azores Standard Time');
    _timeZoneCollection.add('Bahia Standard Time');
    _timeZoneCollection.add('Bangladesh Standard Time');
    _timeZoneCollection.add('Belarus Standard Time');
    _timeZoneCollection.add('Canada Central Standard Time');
    _timeZoneCollection.add('Cape Verde Standard Time');
    _timeZoneCollection.add('Caucasus Standard Time');
    _timeZoneCollection.add('Cen. Australia Standard Time');
    _timeZoneCollection.add('Central America Standard Time');
    _timeZoneCollection.add('Central Asia Standard Time');
    _timeZoneCollection.add('Central Brazilian Standard Time');
    _timeZoneCollection.add('Central Europe Standard Time');
    _timeZoneCollection.add('Central European Standard Time');
    _timeZoneCollection.add('Central Pacific Standard Time');
    _timeZoneCollection.add('Central Standard Time');
    _timeZoneCollection.add('China Standard Time');
    _timeZoneCollection.add('Dateline Standard Time');
    _timeZoneCollection.add('E. Africa Standard Time');
    _timeZoneCollection.add('E. Australia Standard Time');
    _timeZoneCollection.add('E. South America Standard Time');
    _timeZoneCollection.add('Eastern Standard Time');
    _timeZoneCollection.add('Egypt Standard Time');
    _timeZoneCollection.add('Ekaterinburg Standard Time');
    _timeZoneCollection.add('FLE Standard Time');
    _timeZoneCollection.add('Fiji Standard Time');
    _timeZoneCollection.add('GMT Standard Time');
    _timeZoneCollection.add('GTB Standard Time');
    _timeZoneCollection.add('Georgian Standard Time');
    _timeZoneCollection.add('Greenland Standard Time');
    _timeZoneCollection.add('Greenwich Standard Time');
    _timeZoneCollection.add('Hawaiian Standard Time');
    _timeZoneCollection.add('India Standard Time');
    _timeZoneCollection.add('Iran Standard Time');
    _timeZoneCollection.add('Israel Standard Time');
    _timeZoneCollection.add('Jordan Standard Time');
    _timeZoneCollection.add('Kaliningrad Standard Time');
    _timeZoneCollection.add('Korea Standard Time');
    _timeZoneCollection.add('Libya Standard Time');
    _timeZoneCollection.add('Line Islands Standard Time');
    _timeZoneCollection.add('Magadan Standard Time');
    _timeZoneCollection.add('Mauritius Standard Time');
    _timeZoneCollection.add('Middle East Standard Time');
    _timeZoneCollection.add('Montevideo Standard Time');
    _timeZoneCollection.add('Morocco Standard Time');
    _timeZoneCollection.add('Mountain Standard Time');
    _timeZoneCollection.add('Mountain Standard Time (Mexico)');
    _timeZoneCollection.add('Myanmar Standard Time');
    _timeZoneCollection.add('N. Central Asia Standard Time');
    _timeZoneCollection.add('Namibia Standard Time');
    _timeZoneCollection.add('Nepal Standard Time');
    _timeZoneCollection.add('New Zealand Standard Time');
    _timeZoneCollection.add('Newfoundland Standard Time');
    _timeZoneCollection.add('North Asia East Standard Time');
    _timeZoneCollection.add('North Asia Standard Time');
    _timeZoneCollection.add('Pacific SA Standard Time');
    _timeZoneCollection.add('Pacific Standard Time');
    _timeZoneCollection.add('Pacific Standard Time (Mexico)');
    _timeZoneCollection.add('Pakistan Standard Time');
    _timeZoneCollection.add('Paraguay Standard Time');
    _timeZoneCollection.add('Romance Standard Time');
    _timeZoneCollection.add('Russia Time Zone 10');
    _timeZoneCollection.add('Russia Time Zone 11');
    _timeZoneCollection.add('Russia Time Zone 3');
    _timeZoneCollection.add('Russian Standard Time');
    _timeZoneCollection.add('SA Eastern Standard Time');
    _timeZoneCollection.add('SA Pacific Standard Time');
    _timeZoneCollection.add('SA Western Standard Time');
    _timeZoneCollection.add('SE Asia Standard Time');
    _timeZoneCollection.add('Samoa Standard Time');
    _timeZoneCollection.add('Singapore Standard Time');
    _timeZoneCollection.add('South Africa Standard Time');
    _timeZoneCollection.add('Sri Lanka Standard Time');
    _timeZoneCollection.add('Syria Standard Time');
    _timeZoneCollection.add('Taipei Standard Time');
    _timeZoneCollection.add('Tasmania Standard Time');
    _timeZoneCollection.add('Tokyo Standard Time');
    _timeZoneCollection.add('Tonga Standard Time');
    _timeZoneCollection.add('Turkey Standard Time');
    _timeZoneCollection.add('US Eastern Standard Time');
    _timeZoneCollection.add('US Mountain Standard Time');
    _timeZoneCollection.add('UTC');
    _timeZoneCollection.add('UTC+12');
    _timeZoneCollection.add('UTC-02');
    _timeZoneCollection.add('UTC-11');
    _timeZoneCollection.add('Ulaanbaatar Standard Time');
    _timeZoneCollection.add('Venezuela Standard Time');
    _timeZoneCollection.add('Vladivostok Standard Time');
    _timeZoneCollection.add('W. Australia Standard Time');
    _timeZoneCollection.add('W. Central Africa Standard Time');
    _timeZoneCollection.add('W. Europe Standard Time');
    _timeZoneCollection.add('West Asia Standard Time');
    _timeZoneCollection.add('West Pacific Standard Time');
    _timeZoneCollection.add('Yakutsk Standard Time');
  }

  void _checkNetworkStatus() {
    _internetConnectivity.onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        _networkStatusMsg = result.toString();
        if (_networkStatusMsg == "ConnectivityResult.mobile") {
          _networkStatusMsg =
              "You are connected to mobile network, loading calendar data ....";
        } else if (_networkStatusMsg == "ConnectivityResult.wifi") {
          _networkStatusMsg =
              "You are connected to wifi network, loading calendar data ....";
        } else {
          _networkStatusMsg =
              "Internet connection may not be available. Connect to another network";
        }
      });
    });
  }
}

class DataSource extends CalendarDataSource<Meeting> {
  DataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  Meeting convertAppointmentToObject(
      Meeting customData, Appointment appointment) {
    return Meeting(
        from: appointment.startTime,
        to: appointment.endTime,
        description: appointment.notes!,
        endTimeZone: appointment.endTimeZone!,
        eventName: appointment.subject,
        startTimeZone: appointment.startTimeZone!,
        background: appointment.color,
        isAllDay: appointment.isAllDay,
        id: int.parse(appointment.id.toString()),
        ids: []
    );
  }


  @override
  int getId(int index) => appointments![index].id;

  @override
  bool isAllDay(int index) => appointments![index].isAllDay;

  @override
  String getSubject(int index) => appointments![index].eventName;

  @override
  String getStartTimeZone(int index) => appointments![index].startTimeZone;

  @override
  String getNotes(int index) => appointments![index].description;

  @override
  String getEndTimeZone(int index) => appointments![index].endTimeZone;


  @override
  Color getColor(int index) => appointments![index].background;

  @override
  DateTime getStartTime(int index) => appointments![index].from;

  @override
  DateTime getEndTime(int index) => appointments![index].to;

  @override
  List<Object> getResourceIds(int index) {
    return appointments![index].ids;
  }
}

class Meeting {
  Meeting(
      {
        required this.id,
      required this.from,
      required this.to,
      this.background = Colors.green,
      this.isAllDay = false,
      this.eventName = '',
      this.startTimeZone = '',
      this.endTimeZone = '',
      required this.ids,
      this.description = ''});

  final int id;
  final String eventName;
  final DateTime from;
  final DateTime to;
  final Color background;
  final bool isAllDay;
  final String startTimeZone;
  final String endTimeZone;
  final String description;
  final List<String> ids;

}

class Prospects {
  Prospects(
      {required this.id,
      this.nom = '',
      this.prenom = '',
      this.email = '',
      this.adresse = ''});

  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String adresse;
}
