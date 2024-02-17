import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess/constants.dart';
import 'package:flutter_chess/helper/helper_methods.dart';
import 'package:flutter_chess/models/user_model.dart';
import 'package:flutter_chess/providers/authentication_provider.dart';
import 'package:flutter_chess/service/assets_manager.dart';
import 'package:flutter_chess/widgets/main_auth_button.dart';
import 'package:flutter_chess/widgets/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  File? finalFileImage;
  String fileImageUrl = '';
  late String name;
  late String email;
  late String password;
  bool obscureText = true;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void selectImage({required bool fromCamera}) async {
    finalFileImage = await pickImage(
        fromCamera: fromCamera,
        onFail: (e) {
          // show error message
          showSnackBar(context: context, content: e.toString());
        });

    if (finalFileImage != null) {
      cropImage(finalFileImage!.path);
    } else {
      popCropDialog();
    }
  }

  void cropImage(String path) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      maxHeight: 800,
      maxWidth: 800,
    );

    popCropDialog();

    if (croppedFile != null) {
      setState(() {
        finalFileImage = File(croppedFile.path);
      });
    } else {
      popCropDialog();
    }
  }

  void popCropDialog() {
    Navigator.pop(context);
  }

  void showImagePickerDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Select an Option'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Camera"),
                  onTap: () {
                    // choose image from camera
                    selectImage(fromCamera: true);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.image),
                  title: const Text("Gallery"),
                  onTap: () {
                    // choose image from gallery
                    selectImage(fromCamera: false);
                  },
                ),
              ],
            ),
          );
        });
  }

  // signUp user
  void signUpUser() async {
    final authProvider = context.read<AuthenticationProvider>();
    if (formKey.currentState!.validate()) {
      // save the form
      formKey.currentState!.save();

      UserCredential? userCredential =
          await authProvider.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential != null) {
        // send email verification

        // user has been created - now we save the user to firestore
        print('user crested: ${userCredential.user!.uid}');

        UserModel userModel = UserModel(
          uid: userCredential.user!.uid,
          name: name,
          email: email,
          image: '',
          createdAt: '',
          playerRating: 1200,
        );

        authProvider.saveUserDataToFireStore(
          currentUser: userModel,
          fileImage: finalFileImage,
          onSuccess: () async {
            formKey.currentState!.reset();
            // sign out the user and navigate to the login screen
            // so that he may now sign In
            showSnackBar(
                context: context, content: 'Sign Up successful, Please Login');

            await authProvider.signOutUser().whenComplete(() {
              Navigator.pop(context);
            });
          },
          onFail: (error) {
            showSnackBar(context: context, content: error.toString());
          },
        );
      }
    } else {
      showSnackBar(context: context, content: 'Please fill all fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>();
    return Scaffold(
      body: Center(
          child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 15,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 20,
                ),
                finalFileImage != null
                    ? Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.blue,
                            backgroundImage:
                                FileImage(File(finalFileImage!.path)),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.lightBlue,
                                  border:
                                      Border.all(width: 2, color: Colors.white),
                                  borderRadius: BorderRadius.circular(35)),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    // pick image from camera or galery
                                    showImagePickerDialog();
                                  },
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    : Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.blue,
                            backgroundImage: AssetImage(AssetsManager.userIcon),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.lightBlue,
                                  border:
                                      Border.all(width: 2, color: Colors.white),
                                  borderRadius: BorderRadius.circular(35)),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    // pick image from camera or galery
                                    showImagePickerDialog();
                                  },
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                const SizedBox(
                  height: 40,
                ),
                TextFormField(
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  maxLength: 25,
                  maxLines: 1,
                  decoration: textFormDecoration.copyWith(
                    counterText: '',
                    labelText: 'Enter your name',
                    hintText: 'Enter your name',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your name';
                    } else if (value.length < 3) {
                      return 'Name must be atleast 3 characters';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    name = value.trim();
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  textInputAction: TextInputAction.next,
                  maxLines: 1,
                  decoration: textFormDecoration.copyWith(
                    labelText: 'Enter your email',
                    hintText: 'Enter your email',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your email';
                    } else if (!validateEmail(value)) {
                      return 'Please enter a valid email';
                    } else if (validateEmail(value)) {
                      return null;
                    }
                    return null;
                  },
                  onChanged: (value) {
                    email = value.trim();
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  textInputAction: TextInputAction.done,
                  decoration: textFormDecoration.copyWith(
                    labelText: 'Enter your password',
                    hintText: 'Enter your password',
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscureText = !obscureText;
                        });
                      },
                      icon: Icon(
                        obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                  ),
                  obscureText: obscureText,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a password';
                    } else if (value.length < 8) {
                      return 'Password must be atleast 8 characters';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    password = value;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                authProvider.isLoading
                    ? const CircularProgressIndicator()
                    : MainAuthButton(
                        lable: 'SIGN UP',
                        onPressed: () {
                          // login the user with Email and password
                          signUpUser();
                        },
                        fontSize: 24.0,
                      ),
                const SizedBox(
                  height: 40,
                ),
                HaveAccountWidget(
                  label: 'Have an account?',
                  labelAction: 'Sign In',
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
