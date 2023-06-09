import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridingpartner/screen/splash_screen.dart';
import 'package:ridingpartner/utils/http_override.dart';
import 'package:stack_trace/stack_trace.dart' as stack_trace;

import 'firebase_options.dart';
import 'network/network_helper.dart';

void main() async {
  // 테스트 환경에서만 사용 실제 출시때는 삭제
  HttpOverrides.global = NoCheckCertificateHttpOverrides();

  await dotenv.load(fileName: ".env");
  // MyLocation();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  NetworkHelper();

  FlutterError.demangleStackTrace = (StackTrace stack) {
    if (stack is stack_trace.Trace) return stack.vmTrace;
    if (stack is stack_trace.Chain) return stack.toTrace().vmTrace;
    return stack;
  };

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: SplashScreen());
  }
}
