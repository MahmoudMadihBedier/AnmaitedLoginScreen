import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';


import 'Animation_enum.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Artboard? riveArtboard;
  late RiveAnimationController controllerIdle;
  late RiveAnimationController controllerHandsUp;
  late RiveAnimationController controllerHandsDown;
  late RiveAnimationController controllerLookLeft;
  late RiveAnimationController controllerLookRight;
  late RiveAnimationController controllerSuccess;
  late RiveAnimationController controllerFail;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String testEmail = "omar@gmail.com";
  String testPassword = "123456";
  final passwordFocusNode = FocusNode();

  bool isLookingLeft = false;
  bool isLookingRight = false;

  void removeAllControllers() {
    riveArtboard?.artboard.removeController(controllerIdle);
    riveArtboard?.artboard.removeController(controllerHandsUp);
    riveArtboard?.artboard.removeController(controllerHandsDown);
    riveArtboard?.artboard.removeController(controllerLookLeft);
    riveArtboard?.artboard.removeController(controllerLookRight);
    riveArtboard?.artboard.removeController(controllerSuccess);
    riveArtboard?.artboard.removeController(controllerFail);
    isLookingLeft = false;
    isLookingRight = false;
  }

  void addSpecifcAnimationAction(
      RiveAnimationController<dynamic> neededAnimationAction) {
    removeAllControllers();
    riveArtboard?.artboard.addController(neededAnimationAction);
  }

  @override
  void dispose() {
    passwordFocusNode.removeListener;
    super.dispose();
  }


  

  void checkForPasswordFocusNodeToChangeAnimationState() {
    passwordFocusNode.addListener(() {
      if (passwordFocusNode.hasFocus) {
        addSpecifcAnimationAction(controllerHandsUp);
      } else if (!passwordFocusNode.hasFocus) {
        addSpecifcAnimationAction(controllerHandsDown);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    controllerIdle = SimpleAnimation(AnimationEnum.idle.name);
    controllerHandsUp = SimpleAnimation(AnimationEnum.Hands_up.name);
    controllerHandsDown = SimpleAnimation(AnimationEnum.hands_down.name);
    controllerLookRight = SimpleAnimation(AnimationEnum.Look_down_right.name);
    controllerLookLeft = SimpleAnimation(AnimationEnum.Look_down_left.name);
    controllerSuccess = SimpleAnimation(AnimationEnum.success.name);
    controllerFail = SimpleAnimation(AnimationEnum.fail.name);

    loadRiveFileWithItsStates();

    checkForPasswordFocusNodeToChangeAnimationState();
  }

  void loadRiveFileWithItsStates() {
    rootBundle.load('assets/login_animation.riv').then(
      (data) {
        final file = RiveFile.import(data);
        final artboard = file.mainArtboard;
        artboard.addController(controllerIdle);
        setState(() {
          riveArtboard = artboard;
        });
      },
    );
  }

  void validateEmailAndPassword() {
    Future.delayed(const Duration(seconds: 1), () {
      if (formKey.currentState!.validate()) {
        addSpecifcAnimationAction(controllerSuccess);
      } else {
        addSpecifcAnimationAction(controllerFail);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Animated Login')),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width / 20),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 3,
              child: riveArtboard == null
                  ? const SizedBox.shrink()
                  : Rive(
                      artboard: riveArtboard!,
                    ),
            ),
            Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                    validator: (value) =>
                        value != testEmail ? "Wrong email" : null,
                    onChanged: (value) {
                      if (value.isNotEmpty &&
                          value.length < 16 &&
                          !isLookingLeft) {
                        addSpecifcAnimationAction(controllerLookLeft);
                      } else if (value.isNotEmpty &&
                          value.length > 16 &&
                          !isLookingRight) {
                        addSpecifcAnimationAction(controllerLookRight);
                      }
                    },
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 25,
                  ),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                    focusNode: passwordFocusNode,
                    validator: (value) =>
                        value != testPassword ? "Wrong password" : null,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 18,
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width / 8,
                    ),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        shape: const StadiumBorder(),
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        passwordFocusNode.unfocus();

                        validateEmailAndPassword();
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
