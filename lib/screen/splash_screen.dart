import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../provider/auth_provider.dart';
import '../widgets/dialog/permission_dialog.dart';
import 'bottom_nav.dart';

final authProvider = StateNotifierProvider.autoDispose<AuthProvider, User?>(
    (ref) => AuthProvider());

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends ConsumerState<SplashScreen> {
  // 로딩페이지와 동시에 사용
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    if (authState != null) {
      Future.delayed(const Duration(milliseconds: 1500), () async{
        bool result = await backgroundPermissionCheck();
        if(result){
          toMainScreen();
        }
      });
    } else {
      Connectivity().checkConnectivity().then((value) {
        if (value == ConnectivityResult.none) {
          showToastMessage("wifi 상태를 확인해주세요");
        }
      });
    }

    return Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/img_loading.png'),
              fit: BoxFit.cover),
        ),
        child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: FractionalOffset.topCenter,
                    end: FractionalOffset.bottomCenter,
                    colors: [
                  Colors.black.withOpacity(0.0),
                  Colors.white.withOpacity(1.0),
                ])),
            child: Container(
                margin: const EdgeInsets.fromLTRB(40.0, 0.0, 40.0, 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const _Header(),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: 280,
                      child: Visibility(
                          visible: authState == null, child: const _Body()),
                    ),
                    const _Footer()
                  ],
                ))));
  }

  Future<bool> backgroundPermissionCheck() async {
    final pref = await SharedPreferences.getInstance();
    bool permission = pref.getBool('backLocationPermission') ?? false;

    if (!permission) {
      permission = await permissionDialog();

      if (permission) {
        pref.setBool('backLocationPermission', true);
        return true;
      } else {
        showToastMessage("어플 사용을 위해 권한 동의가 필요합니다.");
        permission = await permissionDialog();
        if (permission) {
          pref.setBool('backLocationPermission', true);
          return true;
        }else{
          return false;
        }
      }
    } else {
      return true;
    }
  }

  void showToastMessage(String message) =>
      Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT);

  void toMainScreen() {
    showToastMessage("이 어플은 위치 기반의 사용자 자전거 주행 기록 기능을 지원하기 때문에 앱이 닫혀 있을 때나 사용하지 않을 때도 위치데이터를 수집합니다.");
    if (mounted) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const BottomNavigation()),
              (route) => false);
    }

  }

  Future<bool> permissionDialog() async {
    return await showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: false,
        builder: (BuildContext context) => const PermissionDialog());
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 140.0,
        height: 100.0,
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/icons/logo_white.png')),
            color: Colors.transparent));
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.fromLTRB(0.0, 20.0, 0, 0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                width: 70.0,
                height: 70.0,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/icons/logo_siheung.png')),
                ),
                child: const Scaffold(
                  backgroundColor: Colors.transparent,
                )),
            const SizedBox(
              width: 30,
            ),
            Container(
                width: 125.0,
                height: 100.0,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/icons/logo_tuk.png')),
                ),
                child: const Scaffold(
                  backgroundColor: Colors.transparent,
                )),
          ],
        ));
  }
}

class _Body extends ConsumerWidget {
  const _Body();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        LoginButton(
            onClicked: () {
              ref.read(authProvider.notifier).signInWithGoogle();
            },
            assetPath: "assets/icons/btn_google_login.png"),
        LoginButton(
            onClicked: () {
              ref.read(authProvider.notifier).signInWithNaver();
            },
            assetPath: "assets/icons/btn_naver_login.png"),
        LoginButton(
            onClicked: () {
              ref.read(authProvider.notifier).signInWithKakao();
            },
            assetPath: "assets/icons/btn_kakao_login.png"),
        if (Platform.isIOS)
          LoginButton(
              onClicked: () {
                ref.read(authProvider.notifier).signInWithApple();
              },
              assetPath: "assets/icons/btn_apple_login.png"),
      ],
    );
  }
}

class LoginButton extends StatelessWidget {
  const LoginButton(
      {super.key, required this.onClicked, required this.assetPath});

  final Function() onClicked;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 70.0,
        child: Card(
            elevation: 0,
            color: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            margin: const EdgeInsets.only(top: 10),
            child: InkWell(
                onTap: onClicked,
                child: Ink.image(
                  fit: BoxFit.fitHeight,
                  image: AssetImage(assetPath),
                ))));
  }
}
