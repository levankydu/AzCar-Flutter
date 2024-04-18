import 'package:az_car_flutter_app/data/user_model.dart';
import 'package:az_car_flutter_app/page/home_page.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:unicons/unicons.dart';
import 'package:intl/intl.dart';
import '../constant_user_profile_screen.dart';
import '../services/get_api_services.dart';
import 'login_register_page.dart';
import 'package:date_format_field/date_format_field.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({Key? key}) : super(key: key);
  static String routeName = 'MyProfileScreen';

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  String emailLogin = '';
  UserModel? user;
  bool _isLoading = false;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  String selected = 'Female';

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<UserModel?> getUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool checkValue = prefs.containsKey('emailLogin');
    if (checkValue) {
      final String action = prefs.getString('emailLogin')!;
      var model = await ApiService.getUserByEmail(action);
      if (model != null) {
        setState(() {
          user = model;
          _isLoading = true;
        });
        setState(() {
          _isLoading = true;
        });
        await Future.delayed(Duration(seconds: 2));
        setState(() {
          _isLoading = false;
        });
      }
      return model;
    }
    return null;
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Sign Out'),
          content: Text('Are you sure you want to sign out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                });
                await Future.delayed(Duration(seconds: 2));
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                await prefs.clear();
                Get.to(() => HomePage());
                setState(() {
                  _isLoading = false;
                });
              },
              child: Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        bottomOpacity: 0.0,
        elevation: 0.0,
        shadowColor: Colors.transparent,
        backgroundColor: themeData.colorScheme.background,
        leading: Padding(
          padding: EdgeInsets.only(
            left: size.width * 0.05,
          ),
          child: SizedBox(
            height: size.height * 0.1,
            width: size.width * 0.1,
            child: Container(
              decoration: BoxDecoration(
                color: themeData.colorScheme.background.withOpacity(0.03),
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: GestureDetector(
                onTap: () {
                  Get.to(() => HomePage());
                },
                child: Icon(
                  CommunityMaterialIcons.arrow_left_bold_circle,
                  color: themeData.secondaryHeaderColor,
                  size: 40,
                ),
              ),
            ),
          ),
        ),
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leadingWidth: size.width * 0.15,
        title: Image.asset(
          alignment: Alignment.bottomCenter,
          themeData.brightness == Brightness.dark
              ? 'assets/images/logo-azcar.png'
              : 'assets/images/logo-azcar.png',
          height: size.height * 0.05,
          width: size.width * 0.35,
        ),
        centerTitle: true,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              right: size.width * 0.05,
            ),
            child: SizedBox(
              height: size.width * 0.1,
              width: size.width * 0.1,
              child: Container(
                decoration: BoxDecoration(
                  color: themeData.colorScheme.background.withOpacity(0.03),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: user == null
          ? Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: size.height * 0.02,
                    left: size.width * 0.06,
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Welcome to AzCar, ',
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(
                        color: themeData.secondaryHeaderColor,
                        fontSize: size.width * 0.06,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: size.height * 0.01,
                    left: size.width * 0.06,
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Click SigIn to continue',
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(
                        color: themeData.secondaryHeaderColor,
                        fontSize: size.width * 0.035,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: size.height * 0.03,
                    left: size.width * 0.04,
                    bottom: size.height * 0.025,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 30),
                      child: AnimatedButton(
                        height: 70,
                        width: MediaQuery.of(context).size.width / 2,
                        text: 'Log in',
                        isReverse: true,
                        selectedTextColor: Colors.black,
                        transitionType: TransitionType.LEFT_TO_RIGHT,
                        backgroundColor: themeData.secondaryHeaderColor,
                        borderColor: themeData.secondaryHeaderColor,
                        borderRadius: 50,
                        borderWidth: 2,
                        onPress: () {
                          Get.to(() => LoginSignupScreen());
                        },
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Container(
              color: kOtherColor,
              child: Column(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          top: size.height * 0.02,
                          left: size.width * 0.06,
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Welcome back, ',
                            textAlign: TextAlign.left,
                            style: GoogleFonts.poppins(
                              color: themeData.secondaryHeaderColor,
                              fontSize: size.width * 0.06,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: size.height * 0.01,
                          left: size.width * 0.06,
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            user!.email!,
                            textAlign: TextAlign.left,
                            style: GoogleFonts.poppins(
                              color: themeData.secondaryHeaderColor,
                              fontSize: size.width * 0.035,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: size.height * 0.03,
                          left: size.width * 0.04,
                          bottom: size.height * 0.025,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 5),
                    width: 100.w,
                    height:
                        SizerUtil.deviceType == DeviceType.tablet ? 19.h : 15.h,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      image: DecorationImage(
                          image: AssetImage(
                              'assets/images/profile-background.jpg'),
                          fit: BoxFit.fitWidth),
                      borderRadius: kBottomBorderRadius,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: SizerUtil.deviceType == DeviceType.tablet
                              ? 12.w
                              : 13.w,
                          backgroundColor: kSecondaryColor,
                          child: ClipOval(
                            child: Image(
                              image: NetworkImage(user != null
                                  ? '${ApiService.baseUrl}/user/profile/flutter/avatar/${user?.image}'
                                  : 'https://media.istockphoto.com/id/1300845620/vector/user-icon-flat-isolated-on-white-background-user-symbol-vector-illustration.jpg?s=612x612&w=0&k=20&c=yBeyba0hUkh14_jgv1OKqIH0CCSWU_4ckRkAoy2p73o='),
                              fit: BoxFit.cover, // Adjust the fit as needed
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        ),
                        kWidthSizedBox,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                        ),
                      ],
                    ),
                  ),
                  sizedBox,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        child: ProfileDetailRow(
                            title: 'First Name', value: user!.firstName),
                        onTap: () {
                          showModalBottomSheet<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return SizedBox(
                                  height: 200,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        const Text('Edit new FirstName'),
                                        Column(
                                          children: [
                                            TextFormField(
                                              controller: firstNameController,
                                              decoration: const InputDecoration(
                                                icon: Icon(Icons.person),
                                                hintText:
                                                    'What is your first name?',
                                                labelText: 'Name *',
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                ElevatedButton(
                                                    child: const Text('Save'),
                                                    onPressed: () async {
                                                      setState(() {
                                                        user!.firstName =
                                                            firstNameController
                                                                .text;
                                                      });
                                                      Navigator.pop(context);
                                                      await ApiService.editUser(
                                                          user!);
                                                    }),
                                                ElevatedButton(
                                                  child: const Text('Close'),
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              });
                        },
                      ),
                      GestureDetector(
                        child: ProfileDetailRow(
                            title: 'Last Name', value: user!.lastName),
                        onTap: () {
                          showModalBottomSheet<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return SizedBox(
                                  height: 200,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        const Text('Edit new LastName'),
                                        Column(
                                          children: [
                                            TextFormField(
                                              controller: lastNameController,
                                              decoration: const InputDecoration(
                                                icon: Icon(Icons.person),
                                                hintText:
                                                    'What is your last name?',
                                                labelText: 'Name *',
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                ElevatedButton(
                                                    child: const Text('Save'),
                                                    onPressed: () async {
                                                      setState(() {
                                                        user!.lastName =
                                                            lastNameController
                                                                .text;
                                                      });
                                                      Navigator.pop(context);
                                                      await ApiService.editUser(
                                                          user!);
                                                    }),
                                                ElevatedButton(
                                                  child: const Text('Close'),
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              });
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        child: ProfileDetailRow(
                            title: 'Gender', value: user!.gender),
                        onTap: () {
                          showModalBottomSheet<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return SizedBox(
                                  height: 200,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        const Text('Edit new Gender'),
                                        Column(
                                          children: [
                                            SizedBox(
                                              width: size.width / 2,
                                              child: DropdownButtonFormField<
                                                  String>(
                                                value: selected,
                                                items: ['Female', 'Male']
                                                    .map((label) =>
                                                        DropdownMenuItem(
                                                          value: label,
                                                          child: Text(label),
                                                        ))
                                                    .toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    selected = value!;
                                                    genderController.text =
                                                        value;
                                                  });
                                                },
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                ElevatedButton(
                                                  child: const Text('Save'),
                                                  onPressed: () async {
                                                    setState(() {
                                                      user!.gender =
                                                          genderController.text;
                                                    });
                                                    Navigator.pop(context);
                                                    await ApiService.editUser(
                                                        user!);
                                                  },
                                                ),
                                                ElevatedButton(
                                                  child: const Text('Close'),
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              });
                        },
                      ),
                      GestureDetector(
                        child: ProfileDetailRow(
                          title: 'Date of Birth',
                          value: user!.dob != null
                              ? DateFormat('dd-MM-yyyy').format(user!.dob!)
                              : 'N/A',
                        ),
                        onTap: () {
                          showModalBottomSheet<void>(
                            context: context,
                            builder: (BuildContext context) {
                              DateTime? selectedDate = user!
                                  .dob; // Khởi tạo selectedDate với giá trị ban đầu từ user.dob

                              return SizedBox(
                                height: 200,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      const Text('Edit new Dob'),
                                      Column(
                                        children: [
                                          DateFormatField(
                                            initialDate: user!.dob,
                                            type: DateFormatType.type4,
                                            decoration: const InputDecoration(
                                              labelStyle: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                fontStyle: FontStyle.italic,
                                              ),
                                              border: InputBorder.none,
                                              labelText: 'Date',
                                            ),
                                            onComplete: (DateTime? newDate) {
                                              setState(() {
                                                selectedDate =
                                                    newDate; // Cập nhật selectedDate với giá trị mới từ newDate
                                              });
                                            },
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              ElevatedButton(
                                                child: const Text('Save'),
                                                onPressed: () async {
                                                  // Lưu lại ngày tháng mới cho user
                                                  if (selectedDate != null) {
                                                    setState(() {
                                                      user!.dob =
                                                          selectedDate; // Cập nhật user.dob với selectedDate mới
                                                    });
                                                    Navigator.pop(context);
                                                    await ApiService.editUser(
                                                        user!);
                                                    setState(
                                                            () {}); // Cập nhật giao diện
                                                  }
                                                },
                                              ),
                                              ElevatedButton(
                                                child: const Text('Close'),
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  sizedBox,
                  ProfileDetailColumn(
                    title: 'Email',
                    value: user!.email!,
                  ),
                  GestureDetector(
                    child: ProfileDetailColumn(
                      title: 'Phone Number',
                      value: user!.phone,
                    ),
                    onTap: () {
                      showModalBottomSheet<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return SizedBox(
                              height: 200,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    const Text('Edit new Phone'),
                                    Column(
                                      children: [
                                        TextFormField(
                                          controller: phoneController,
                                          decoration: const InputDecoration(
                                            icon: Icon(Icons.person),
                                            hintText:
                                                'What is your phone number you want?',
                                            labelText: 'Phone *',
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ElevatedButton(
                                                child: const Text('Save'),
                                                onPressed: () async {
                                                  setState(() {
                                                    user!.phone =
                                                        phoneController.text;
                                                  });
                                                  Navigator.pop(context);
                                                  await ApiService.editUser(
                                                      user!);
                                                }),
                                            ElevatedButton(
                                              child: const Text('Close'),
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          });
                    },
                  ),
                  _isLoading
                      ? LoadingAnimationWidget.horizontalRotatingDots(
                          color: themeData.secondaryHeaderColor,
                          size: 50,
                        )
                      : Padding(
                          padding: EdgeInsets.only(top: 30),
                          child: AnimatedButton(
                            height: 70,
                            width: MediaQuery.of(context).size.width / 2,
                            text: 'Log out',
                            isReverse: true,
                            selectedTextColor: Colors.black,
                            transitionType: TransitionType.LEFT_TO_RIGHT,
                            backgroundColor: themeData.secondaryHeaderColor,
                            borderColor: themeData.secondaryHeaderColor,
                            borderRadius: 50,
                            borderWidth: 2,
                            onPress: () => _confirmSignOut(context),
                          ),
                        ),
                ],
              ),
            ),
    );
  }
}

class ProfileDetailRow extends StatelessWidget {
  const ProfileDetailRow({Key? key, required this.title, required this.value})
      : super(key: key);
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; //check the size of device
    ThemeData themeData = Theme.of(context);
    return SizedBox(
      width: 40.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: kTextBlackColor,
                          fontSize: SizerUtil.deviceType == DeviceType.tablet
                              ? 7.sp
                              : 9.sp,
                        ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 3.w),
                    child: Icon(
                      UniconsLine.edit,
                      color: themeData.secondaryHeaderColor,
                      size: size.height * 0.015,
                    ),
                  ),
                ],
              ),
              kHalfSizedBox,
              Text(value, style: Theme.of(context).textTheme.bodySmall),
              kHalfSizedBox,
              SizedBox(
                width: 35.w,
                child: Divider(
                  thickness: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileDetailColumn extends StatelessWidget {
  const ProfileDetailColumn(
      {Key? key, required this.title, required this.value})
      : super(key: key);
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    Size size = MediaQuery.of(context).size; //
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: kTextBlackColor,
                        fontSize: SizerUtil.deviceType == DeviceType.tablet
                            ? 7.sp
                            : 11.sp,
                      ),
                ),
                Padding(
                    padding: EdgeInsets.only(left: 3.w),
                    child: Icon(
                      UniconsLine.edit,
                      color: themeData.secondaryHeaderColor,
                      size: size.height * 0.015,
                    ))
              ],
            ),
            kHalfSizedBox,
            Text(value, style: Theme.of(context).textTheme.bodySmall),
            kHalfSizedBox,
            SizedBox(
              width: 92.w,
              child: Divider(
                thickness: 1.0,
              ),
            )
          ],
        ),
      ],
    );
  }
}
