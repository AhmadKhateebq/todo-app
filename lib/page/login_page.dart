import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/requests_controller.dart';
import '../controller/state_controller.dart';
import 'component/form_text_field.dart';
import 'home_widget.dart';
import 'splash.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final requestsController = Get.find<RequestsController>();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final isLogin = true.obs;
  var isLoading = false.obs;
  final _formkey = GlobalKey<FormState>();

  final _emailkey = GlobalKey<FormFieldState>();

  final _passkey = GlobalKey<FormFieldState>();

  final formListValidator = FormListValidator();

  bool emailTouched = false;

  bool passwordTouched = false;

  final form = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
                width: Get.width,
                height: Get.height,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.deepPurple,
                    Colors.purple,
                    Colors.purpleAccent,
                    Colors.pinkAccent,
                    Colors.deepOrange,
                    Colors.deepOrangeAccent,
                    Colors.orange,
                    Colors.orangeAccent,
                  ]),
                ),
                child: const Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                    child: Icon(
                      Icons.person,
                      size: 100,
                    ),
                  ),
                )),
            Obx(() => isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : loginForm()),
          ],
        ),
      ),
    );
  }

  Widget loginForm() {
    final emailField = FormTextField(
      label: "Email",
      isPassword: false,
      validator: (text) =>
          requestsController.validateEmail(emailController.text),
      controller: emailController,
    );
    final passwordField = FormTextField(
      label: "Password",
      isPassword: true,
      validator: (text) =>
          requestsController.validatePassword(passwordController.text),
      controller: passwordController,
    );
    formListValidator.add(emailField);
    formListValidator.add(passwordField);
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: (Get.height / 2 - 45),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Login',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: Colors.black87),
              ),
              const SizedBox(
                height: 20,
              ),
              if (form)
                Form(
                  key: _formkey,
                  child: Column(
                    children: [
                      TextFormField(
                        key: _emailkey,
                        onTap: () {
                          emailTouched = true;
                          if (passwordTouched) {
                            _passkey.currentState!.validate();
                          }
                        },
                        controller: emailController,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          floatingLabelStyle:
                              TextStyle(color: Colors.deepPurple),
                          label: Text(
                            "Email",
                            style: TextStyle(
                                fontStyle: FontStyle.italic, fontSize: 15),
                          ),
                        ),
                        validator: (value) =>
                            requestsController.validateEmail(value!)
                                ? null
                                : "Please enter a valid email",
                      ),
                      TextFormField(
                        key: _passkey,
                        onTap: () {
                          passwordTouched = true;
                          if (emailTouched) {
                            _emailkey.currentState!.validate();
                          }
                        },
                        validator: (value) =>
                            requestsController.validatePassword(value!)
                                ? null
                                : "please enter a valid password",
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        controller: passwordController,
                        decoration: const InputDecoration(
                          floatingLabelStyle:
                              TextStyle(color: Colors.deepPurple),
                          border: UnderlineInputBorder(),
                          labelText: 'Password',
                        ),
                      ),
                    ],
                  ),
                ),
              if (!form) emailField,
              if (!form) passwordField,
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(50)),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          shape: const StadiumBorder()),
                      onPressed: () async {
                        isLogin.value = !isLogin.value;
                      },
                      child: Obx(() => Text(isLogin.value
                          ? "Switch to Register"
                          : "Switch to Login")),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        shape: const StadiumBorder()),
                    onPressed: () {
                      if (formListValidator.validateAll()) {
                        loginAndRegister(isLogin.value);
                      }
                      if (form && _formkey.currentState!.validate()) {
                        loginAndRegister(isLogin.value);
                      }
                    },
                    child:
                        Obx(() => Text(isLogin.value ? "Login" : "Register")),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        shape: const StadiumBorder()),
                    onPressed: handleLoginGoogle,
                    icon: const Icon(Icons.login),
                    label: const Text("Login with google"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  handleLoginGoogle() async {
    isLoading.value = true;
    var value = await Get.find<RequestsController>().handleSignIn();
    (Get.find<TodoController>().isLoading());
    value
        ? Get.to(() => Obx(() => Get.find<TodoController>().isLoading().value
            ? const SplashScreen()
            : const HomePage()))
        : {
            Get.snackbar("error", "Wrong email or password"),
            emailController.text = "",
            passwordController.text = ""
          };
  }

  loginAndRegister(bool isLogin) async {
    bool emailValid = requestsController.validateEmail(emailController.text);
    bool passwordValid =
        requestsController.validatePassword(passwordController.text);
    if (emailValid && passwordValid) {
      if (isLogin) {
        await requestsController
            .signIn(emailController.text, passwordController.text)
            .then((value) {
          (Get.find<TodoController>().isLoading());
          value
              ? Get.to(() => Obx(() =>
                  Get.find<TodoController>().isLoading().value
                      ? const SplashScreen()
                      : const HomePage()))
              : {
                  Get.snackbar("error", "Wrong email or password"),
                  emailController.text = "",
                  passwordController.text = ""
                };
        });
      } else {
        await requestsController
            .register(emailController.text, passwordController.text)
            .then((value) {
          (Get.find<TodoController>().isLoading().value);
          value
              ? Get.to(() => Obx(() =>
                  Get.find<TodoController>().isLoading().value
                      ? const SplashScreen()
                      : const HomePage()))
              : Get.snackbar("error", "Wrong email or password");
        });
      }
    } else if (!emailValid && passwordValid) {
      emailController.text = "";
    } else if (!passwordValid && emailValid) {
      passwordController.text = "";
    }
  }
}
