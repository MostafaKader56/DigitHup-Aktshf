import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:e_learning/models/main_data.dart';
import 'package:e_learning/providers/auth.dart';
import 'package:e_learning/providers/meeting.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_zoom_sdk/zoom_options.dart';
import 'package:flutter_zoom_sdk/zoom_view.dart';
import 'package:zego_uikit_prebuilt_video_conference/zego_uikit_prebuilt_video_conference.dart';

class MeetingItem extends StatelessWidget {
  const MeetingItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final meeting = Provider.of<Meeting>(context, listen: false);
    final user = Provider.of<Auth>(context, listen: false);
    TextEditingController passwordController = TextEditingController();
    return InkWell(
      onTap: () {
        if (meeting.type == 'private') {
          AwesomeDialog(
            context: context,
            //animType: AnimType.rightSlide,
            dialogType: DialogType.warning,
            btnOkColor: Theme.of(context).backgroundColor,
            btnOkText: "دخول الغرفة",
            body: Center(
              child: Column(
                children: [
                  const Text(
                    'يجب كتابة كلمة مرور الغرفة',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: context.screenWidth * 0.7,
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextFormField(
                        //autofocus: true,
                        style: Theme.of(context).textTheme.bodyText1,
                        decoration: const InputDecoration(
                          labelText: 'كلمة المرور',
                        ),
                        controller: passwordController,
                        // validator: (val) {
                        //   if (val!.isEmpty) {
                        //     return 'كلمة المرور مطلوبة';
                        //   }
                        //   return null;
                        // },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            btnOkOnPress: () {
              if (passwordController.text == meeting.password) {
                joinMeeting(context,
                    meetingId: meeting.meetingId,
                    meetingPassword: meeting.meetingPassword,
                    name: "${user.authData['name']}${user.userId}");
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("يرجي التآكد من كلمة المرور."),
                ));
              }
            },
          ).show();
        } else {
          // print('-----------------joinMeeting method Started-----------------');
          joinMeeting(context,
              meetingId: meeting.meetingId,
              meetingPassword: meeting.meetingPassword,
              name: "${user.authData['name']}${user.userId}");
        }
      },
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: const Color.fromRGBO(140, 210, 255, 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      FontAwesomeIcons.user,
                      size: 15,
                    ),
                    const SizedBox(width: 10),
                    Text(meeting.teacherName),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      FontAwesomeIcons.galacticRepublic,
                      size: 15,
                    ),
                    const SizedBox(width: 10),
                    Text(meeting.status),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                const Icon(
                  FontAwesomeIcons.video,
                  size: 15,
                ),
                const SizedBox(width: 10),
                Text(meeting.description),
              ],
            ),
            Row(
              children: [
                const Icon(
                  FontAwesomeIcons.clock,
                  size: 15,
                ),
                const SizedBox(width: 10),
                Text("${meeting.time} د"),
              ],
            ),
            Row(
              children: [
                const Icon(
                  FontAwesomeIcons.calendar,
                  size: 15,
                ),
                const SizedBox(width: 10),
                Text(meeting.startAt),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void joinMeeting(BuildContext context,
    {required String meetingId,
    required String meetingPassword,
    String name = 'username'}) {
// Generate userId 6 digit length
// Generate conferenceId with 10 digit length

myMeetingId = meetingId;
username = name;
// print('==============$myMeetingId================');
Navigator.of(context)
              .pushNamed(VideoConferancePage.routeName);
// Navigator.push(
//         context,
//         MaterialPageRoute(
//             builder: (context) =>
//                 VideoConferancePage()));
}

//API KEY & SECRET is required for below methods to work
//Join Meeting With Meeting ID & Password
//TODO: this creditials not working
joinMeeting2(BuildContext context,
    {meetingId, meetingPassword, name = 'username'}) {
  late Timer timer;
  bool _isMeetingEnded(String status) {
    var result = false;
    if (Platform.isAndroid) {
      result = status == "MEETING_STATUS_DISCONNECTING" ||
          status == "MEETING_STATUS_FAILED";
    } else {
      result = status == "MEETING_STATUS_IDLE";
    }
    return result;
  }

  // ZoomOptions zoomOptions = ZoomOptions(
  //   domain: "zoom.us",
  //   appKey: "FnoAY6Y7QNWQ1Q9hS8cZQw", //API KEY FROM ZOOM
  //   appSecret: "6RsjVbPtEkIqSKzKZED4DxMSE3FlmKZ6SpbX", //API SECRET FROM ZOOM
  // );
  ZoomOptions zoomOptions = ZoomOptions(
    domain: "zoom.us",
    appKey: zoomApi, //API KEY FROM ZOOM
    appSecret: zoomSec, //API SECRET FROM ZOOM
  );
  var meetingOptions = ZoomMeetingOptions(
      userId: name,

      /// pass username for join meeting only --- Any name eg:- EVILRATT.
      meetingId: meetingId,

      /// pass meeting id for join meeting only
      meetingPassword: meetingPassword,

      /// pass meeting password for join meeting only
      disableDialIn: "true",
      disableDrive: "true",
      disableInvite: "true",
      disableShare: "true",
      disableTitlebar: "false",
      viewOptions: "true",
      noAudio: "false",
      noDisconnectAudio: "false");

  var zoom = ZoomView();
  zoom.initZoom(zoomOptions).then((results) {
    if (results[0] == 0) {
      zoom.onMeetingStatus().listen((status) {
        if (kDebugMode) {
          print("${"[Meeting Status Stream] : " + status[0]} - " + status[1]);
        }
        if (_isMeetingEnded(status[0])) {
          if (kDebugMode) {
            print("[Meeting Status] :- Ended");
          }
          timer.cancel();
        }
      });
      if (kDebugMode) {
        print("listen on event channel");
      }
      zoom.joinMeeting(meetingOptions).then((joinMeetingResult) {
        timer = Timer.periodic(const Duration(seconds: 2), (timer) {
          zoom.meetingStatus(meetingOptions.meetingId!).then((status) {
            if (kDebugMode) {
              print("${"[Meeting Status Polling] : " + status[0]} - " +
                  status[1]);
            }
          });
        });
      });
    }
  }).catchError((error) {
    print('error with zoom options');
    if (kDebugMode) {
      print(error);
    }
  });
  // else {
  //   if (meetingIdController.text.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //       content: Text("Enter a valid meeting id to continue."),
  //     ));
  //   } else if (meetingPasswordController.text.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //       content: Text("Enter a meeting password to start."),
  //     ));
  //   }
  // }
}

class VideoConferancePage extends StatelessWidget {
  VideoConferancePage({super.key});
  static const routeName = 'VideoConferancePage';


  final String userId = Random().nextInt(900000 + 100000).toString();
/*
ZEGO_APP_ID=1839004996
ZEGO_APP_SIGN=32e9f855c9c970fe400414a01eeb0b365483290b34b8e720176c4cfd589ef79e
*/

  @override
  Widget build(BuildContext context) {
    print('conferanceID: $myMeetingId');
    return SafeArea(
      child: ZegoUIKitPrebuiltVideoConference(
        appID:
            appId, // Fill in the appID that you get from ZEGOCLOUD Admin Console.
        appSign:
            appSign, // Fill in the appSign that you get from ZEGOCLOUD Admin Console.
        userID: userId,
        userName: username,
        conferenceID: myMeetingId,
        config: ZegoUIKitPrebuiltVideoConferenceConfig(),
      ),
    );
  }
}
