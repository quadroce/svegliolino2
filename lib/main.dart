import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'dart:async';
import 'package:flutter/material.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:svegliolino2/notifications.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
/* import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
 */

void main() async {
  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  await AndroidAlarmManager.initialize();
  tz.initializeTimeZones();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter TimePicker',
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.grey,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  TimeOfDay selectedTime = TimeOfDay.now();

  final player = AudioCache(fixedPlayer: AudioPlayer());
  int checkButton = 0;
  NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Svegliolino"),
      ),
      body: Column(
        children: [
          Image.asset('assets/images/lino.jpg'),
          Row(
            //crossAxisAlignment: CrossAxisAlignment.center,
            //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: IconButton(
                    icon: const Icon(
                      Icons.access_alarm_rounded,
                      size: 80,
                    ),
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.center,
                    tooltip: 'Metti la sveglia Ruoppolo!',
                    onPressed: () async {
                      _selectTime(context);
                    }),
              ),
            ],
          ),
          const SizedBox(
            width: 32.0,
            height: 32.0,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  " ${selectedTime.hour}:${selectedTime.minute}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 25),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ElevatedButton(
                    onPressed: () async {
                      player.fixedPlayer?.stop();
                      checkButton = 1;
                    },
                    style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                        shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 5.0,
                              color: Colors.white,
                            ),
                            borderRadius: BorderRadius.circular(360)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 60, vertical: 60),
                        textStyle: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    child: const Text("Stop")),
              ),
              Expanded(
                  child: ElevatedButton(
                onPressed: () async {
                  //  await _notificationService.scheduleNotifications();
                  player.fixedPlayer?.stop();
                  checkButton = 0;
                  selectedTime =
                      selectedTime.add(selectedTime.hour, selectedTime.minute);
                },
                style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                    side: const BorderSide(
                      width: 5.0,
                      color: Colors.white,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(360)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 60, vertical: 60),
                    textStyle: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                child: const Text('Snooze'),
              )),
            ],
          ),
          Row(
            children: const [
              Expanded(
                  child: Text(
                "Circuito Z di Rigore",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 25),
              )),
            ],
          )
        ],
      ),
    );
  }

  _selectTime(BuildContext context) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      initialEntryMode: TimePickerEntryMode.dial,
    );

    if (timeOfDay != null && timeOfDay != selectedTime) {
      setState(() {
        selectedTime = timeOfDay;
      });
      checkButton = 0;
    }

    const tenSec = Duration(seconds: 10);
    Timer.periodic(tenSec, (Timer t) => checkTimer(selectedTime));
  }

  late final AudioCache player2;
  checkTimer(TimeOfDay selectedTime) {
    int alarmId = 1;

    final DateTime timeSystem;
    timeSystem = DateTime.now();
    /* print('time ${timeSystem.hour}' ' + ' ' ${timeSystem.minute}');
    print('selected ${selectedTime.hour}'

        ' + '
        ' ${selectedTime.minute}'
        '+'
        '$checkButton'); */

    if (timeSystem.hour == selectedTime.hour &&
        timeSystem.minute == selectedTime.minute &&
        checkButton == 0) {
      AndroidAlarmManager.oneShotAt(
          DateTime(selectedTime.hour, selectedTime.minute),
          alarmId,
          //fireAlarm(player));
          fireAlarm(player),
          // rescheduleOnReboot: true,
          allowWhileIdle: true);
      checkButton = 1;
    }
  }
}

/* const NotificationDetails platformChannelSpecifics = 
  NotificationDetails(android: androidPlatformChannelSpecifics); */

fireAlarm(player2) {
  // print('ha funzioneo ${DateTime.now()} +2');
  //  String audioasset = "assets/sounds/svegliolino.mp3";

  player2.play('sounds/svegliolino.mp3');
}

extension TimeOfDayExtension on TimeOfDay {
  TimeOfDay add(int hour, int minute) {
    Random rnd;
    int min = 1;
    int max = 5;
    rnd = Random();
    minute = minute + rnd.nextInt(max - min);
    if (minute >= 60) {
      minute = minute - 60;
      hour = hour + 1;
    }

    return replacing(hour: hour, minute: minute);
  }
}
