import 'dart:convert';

import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unicons/unicons.dart';

import '../data/carModel.dart';
import '../services/get_api_services.dart';
import '../widgets/homePage/car.dart';
import '../widgets/homePage/category.dart';
import 'detais_page.dart';

class AccordionPage extends StatefulWidget {
  static const headerStyle = TextStyle(
      color: Color(0xffffffff), fontSize: 18, fontWeight: FontWeight.bold);
  static const contentStyleHeader = TextStyle(
      color: Color(0xff999999), fontSize: 14, fontWeight: FontWeight.w700);
  static const contentStyle = TextStyle(
      color: Color(0xff999999), fontSize: 14, fontWeight: FontWeight.normal);
  static const loremIpsum =
      '''Lorem ipsum is typically a corrupted version of 'De finibus bonorum et malorum', a 1st century BC text by the Roman statesman and philosopher Cicero, with words altered, added, and removed to make it nonsensical and improper Latin.''';
  static const slogan =
      'Do not forget to play around with all sorts of colors, backgrounds, borders, etc.';

  @override
  State<AccordionPage> createState() => _AccordionPageState();
}

class _AccordionPageState extends State<AccordionPage> {
  List<CarModel>? _carsFuture;

  @override
  void initState() {
    super.initState();

    getCarsData();
  }

  Future<List<CarModel>?> getCarsData() async {
    final carList = await ApiService.getAllCars();
    if (carList!.isNotEmpty) {
      final List<Map<String, dynamic>> jsonList =
          carList.map((car) => car.toJson()).toList();
      final String encodedCarList = json.encode(jsonList);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('carList', encodedCarList);
      setState(() {
        _carsFuture = carList;
      });
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; //check the size of device
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      body: Accordion(
        headerBorderColor: Colors.blueGrey,
        headerBorderColorOpened: Colors.transparent,
        // headerBorderWidth: 1,
        headerBackgroundColorOpened: Colors.green,
        contentBackgroundColor: Colors.white,
        contentBorderColor: Colors.green,
        contentBorderWidth: 2,
        contentHorizontalPadding: 0,
        scaleWhenAnimating: true,
        openAndCloseAnimation: true,
        headerPadding: const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
        sectionOpeningHapticFeedback: SectionHapticFeedback.heavy,
        sectionClosingHapticFeedback: SectionHapticFeedback.light,
        children: [
          AccordionSection(
            isOpen: false,
            contentVerticalPadding: 20,
            leftIcon:
                const Icon(Icons.text_fields_rounded, color: Colors.white),
            header: const Text('Simple Text', style: AccordionPage.headerStyle),
            content: const Text(AccordionPage.loremIpsum,
                style: AccordionPage.contentStyle),
          ),
          AccordionSection(
            isOpen: false,
            leftIcon: const Icon(Icons.input, color: Colors.white),
            header: const Text('Text Field & Button',
                style: AccordionPage.headerStyle),
            contentHorizontalPadding: 40,
            contentVerticalPadding: 20,
            content: const MyInputForm(),
          ),
          AccordionSection(
            isOpen: false,
            leftIcon: const Icon(Icons.child_care_rounded, color: Colors.white),
            header: const Text('Nested Accordion',
                style: AccordionPage.headerStyle),
            content: const MyNestedAccordion(),
          ),
          AccordionSection(
            isOpen: false,
            leftIcon: const Icon(Icons.shopping_cart, color: Colors.white),
            header: const Text('DataTable', style: AccordionPage.headerStyle),
            content: const MyDataTable(),
          ),

          AccordionSection(
            isOpen: true,
            leftIcon: const Icon(Icons.car_rental, color: Colors.white),
            header: const Text('My Registered Cars', style: AccordionPage.headerStyle),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: size.height * 0.001,
                    left: size.width * 0.05,
                  ),
                  child: Text(
                    'My Cars',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: themeData.secondaryHeaderColor,
                      fontWeight: FontWeight.bold,
                      fontSize: size.width * 0.055,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: size.height * 0.03,
                    right: size.width * 0.05,
                  ),
                ),
              ],
            ),
                Padding(
                  padding: EdgeInsets.only(
                    top: size.height * 0.01,
                    left: size.width * 0.03,
                    right: size.width * 0.03,
                  ),
                  child: SizedBox(
                    height: size.width * 0.55,
                    width: _carsFuture!.length * size.width * 0.5 * 1.03,
                    child: ListView.builder(
                      primary: false,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: _carsFuture?.length,
                      itemBuilder: (context, i) {
                        return Padding(
                          padding: EdgeInsets.only(
                            right: size.width * 0.03,
                          ),
                          child: Center(
                            child: SizedBox(
                              height: size.width * 0.55,
                              width: size.width * 0.5,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: themeData.cardColor,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(
                                      20,
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: size.width * 0.02,
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      Get.to(DetailsPage(
                                        car:  _carsFuture![i],
                                      ));
                                    },
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: size.height * 0.01,
                                          ),
                                          child: Align(
                                            alignment: Alignment.topCenter,
                                            child:
                                            AspectRatio(

                                              aspectRatio: 2.0,
                                              child: Image(
                                                image: NetworkImage(_carsFuture![i].images.isNotEmpty
                                                    ? '${ApiService.baseUrl}/home/availablecars/flutter/img/${_carsFuture![i].images[0].urlImage.toString()}'
                                                    : 'https://media.istockphoto.com/id/1300845620/vector/user-icon-flat-isolated-on-white-background-user-symbol-vector-illustration.jpg?s=612x612&w=0&k=20&c=yBeyba0hUkh14_jgv1OKqIH0CCSWU_4ckRkAoy2p73o='),
                                                fit: BoxFit.cover, // Adjust the fit as needed
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: size.height * 0.01,
                                          ),
                                          child: Text(
                                            _carsFuture![i].licensePlates,
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.poppins(
                                              color: themeData.secondaryHeaderColor,
                                              fontSize: size.width * 0.05,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${_carsFuture![i].carmodel.model}-${_carsFuture![i].carmodel.year}',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            color: themeData.secondaryHeaderColor,
                                            fontSize: size.width * 0.03,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              '${_carsFuture![i].price}\$',
                                              style: GoogleFonts.poppins(
                                                color: themeData.secondaryHeaderColor,
                                                fontSize: size.width * 0.06,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '/per day',
                                              style: GoogleFonts.poppins(
                                                color: themeData.primaryColor.withOpacity(0.8),
                                                fontSize: size.width * 0.03,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const Spacer(),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                right: size.width * 0.025,
                                              ),
                                              child: SizedBox(
                                                height: size.width * 0.1,
                                                width: size.width * 0.1,
                                                child: Container(
                                                  decoration: const BoxDecoration(
                                                    color: Color(0xff3b22a1),
                                                    borderRadius: BorderRadius.all(
                                                      Radius.circular(
                                                        10,
                                                      ),
                                                    ),
                                                  ),
                                                  child: const Icon(
                                                    UniconsLine.credit_card,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          AccordionSection(
            isOpen: false,
            leftIcon: const Icon(Icons.circle_outlined, color: Colors.black54),
            rightIcon: const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.black54,
              size: 20,
            ),
            headerBackgroundColor: Colors.transparent,
            headerBackgroundColorOpened: Colors.amber,
            headerBorderColor: Colors.black54,
            headerBorderColorOpened: Colors.black54,
            headerBorderWidth: 1,
            contentBackgroundColor: Colors.amber,
            contentBorderColor: Colors.black54,
            contentBorderWidth: 1,
            contentVerticalPadding: 30,
            header: const Text('Custom: Header with Border',
                style: TextStyle(
                    color: Colors.black54,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.label_important_outline_rounded,
                  size: 50,
                ).paddingOnly(right: 20),
                const Flexible(
                  child: Text(
                    AccordionPage.slogan,
                    maxLines: 4,
                    style: TextStyle(color: Colors.black45, fontSize: 17),
                  ),
                ),
              ],
            ),
          ),
          AccordionSection(
            isOpen: false,
            leftIcon: const Icon(Icons.circle, color: Colors.white),
            headerBackgroundColor: Colors.deepOrange,
            headerBackgroundColorOpened: Colors.brown,
            headerBorderWidth: 1,
            contentBackgroundColor: Colors.brown,
            contentBorderWidth: 0,
            contentVerticalPadding: 30,
            header: const Text('Custom: Other Colors',
                style: AccordionPage.headerStyle),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.label_important_outline_rounded,
                  size: 50,
                  color: Colors.white54,
                ).paddingOnly(right: 20),
                const Flexible(
                  child: Text(
                    AccordionPage.slogan,
                    maxLines: 4,
                    style: TextStyle(color: Colors.white54, fontSize: 17),
                  ),
                ),
              ],
            ),
          ),
          AccordionSection(
            isOpen: false,
            leftIcon: const Icon(Icons.circle, color: Colors.white),
            headerBackgroundColor: Colors.green[900],
            headerBackgroundColorOpened: Colors.lightBlue,
            headerBorderColorOpened: Colors.yellow,
            headerBorderWidth: 10,
            contentBackgroundColor: Colors.lightBlue,
            contentBorderColor: Colors.yellow,
            contentBorderWidth: 10,
            contentVerticalPadding: 30,
            header: const Text('Custom: Heavy Borders',
                style: AccordionPage.headerStyle),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.label_important_outline_rounded,
                  size: 50,
                  color: Colors.white54,
                ).paddingOnly(right: 20),
                const Flexible(
                  child: Text(
                    AccordionPage.slogan,
                    maxLines: 4,
                    style: TextStyle(color: Colors.white54, fontSize: 17),
                  ),
                ),
              ],
            ),
          ),
          AccordionSection(
            isOpen: false,
            leftIcon: const Icon(Icons.circle, color: Colors.white),
            headerBorderRadius: 30,
            headerBackgroundColor: Colors.purple,
            headerBackgroundColorOpened: Colors.purple,
            headerBorderColorOpened: Colors.white,
            headerBorderWidth: 2,
            contentBackgroundColor: Colors.purple,
            contentBorderColor: Colors.white,
            contentBorderWidth: 2,
            contentBorderRadius: 100,
            contentVerticalPadding: 30,
            header: const Text('Custom: Very Round',
                style: AccordionPage.headerStyle),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.label_important_outline_rounded,
                  size: 50,
                  color: Colors.white54,
                ).paddingOnly(right: 20),
                const Flexible(
                  child: Text(
                    AccordionPage.slogan,
                    maxLines: 4,
                    style: TextStyle(color: Colors.white54, fontSize: 17),
                  ),
                ),
              ],
            ),
          ),
          AccordionSection(
            isOpen: false,
            leftIcon: const Icon(Icons.circle, color: Colors.white),
            headerBorderRadius: 0,
            headerBackgroundColor: Colors.black87,
            headerBackgroundColorOpened: Colors.black87,
            headerBorderColorOpened: const Color(0xffaaaaaa),
            headerBorderWidth: 1,
            contentBackgroundColor: Colors.black54,
            contentBorderColor: const Color(0xffaaaaaa),
            contentBorderWidth: 1,
            contentBorderRadius: 0,
            contentVerticalPadding: 30,
            header: const Text('Android', style: AccordionPage.headerStyle),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.label_important_outline_rounded,
                  size: 50,
                  color: Colors.white54,
                ).paddingOnly(right: 20),
                const Flexible(
                  child: Text(
                    AccordionPage.slogan,
                    maxLines: 4,
                    style: TextStyle(color: Colors.white54, fontSize: 17),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MyInputForm extends StatelessWidget //__
{
  const MyInputForm({super.key});

  @override
  Widget build(context) //__
  {
    return Column(
      children: [
        TextFormField(
          decoration: InputDecoration(
            label: const Text('Some text goes here ...'),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ).marginOnly(bottom: 10),
        ElevatedButton(
          onPressed: () {},
          child: const Text('Submit'),
        )
      ],
    );
  }
}

class MyDataTable extends StatelessWidget //__
{
  const MyDataTable({super.key});

  @override
  Widget build(context) //__
  {
    return DataTable(
      sortAscending: true,
      sortColumnIndex: 1,
      showBottomBorder: false,
      columns: const [
        DataColumn(
            label: Text('ID', style: AccordionPage.contentStyleHeader),
            numeric: true),
        DataColumn(
            label:
                Text('Description', style: AccordionPage.contentStyleHeader)),
        DataColumn(
            label: Text('Price', style: AccordionPage.contentStyleHeader),
            numeric: true),
      ],
      rows: const [
        DataRow(
          cells: [
            DataCell(Text('1',
                style: AccordionPage.contentStyle, textAlign: TextAlign.right)),
            DataCell(Text('Fancy Product', style: AccordionPage.contentStyle)),
            DataCell(Text(r'$ 199.99',
                style: AccordionPage.contentStyle, textAlign: TextAlign.right))
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('2',
                style: AccordionPage.contentStyle, textAlign: TextAlign.right)),
            DataCell(
                Text('Another Product', style: AccordionPage.contentStyle)),
            DataCell(Text(r'$ 79.00',
                style: AccordionPage.contentStyle, textAlign: TextAlign.right))
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('3',
                style: AccordionPage.contentStyle, textAlign: TextAlign.right)),
            DataCell(
                Text('Really Cool Stuff', style: AccordionPage.contentStyle)),
            DataCell(Text(r'$ 9.99',
                style: AccordionPage.contentStyle, textAlign: TextAlign.right))
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('4',
                style: AccordionPage.contentStyle, textAlign: TextAlign.right)),
            DataCell(Text('Last Product goes here',
                style: AccordionPage.contentStyle)),
            DataCell(Text(r'$ 19.99',
                style: AccordionPage.contentStyle, textAlign: TextAlign.right))
          ],
        ),
      ],
    );
  }
}

class MyNestedAccordion extends StatelessWidget //__
{
  const MyNestedAccordion({super.key});

  @override
  Widget build(context) //__
  {
    return Accordion(
      paddingListTop: 0,
      paddingListBottom: 0,
      maxOpenSections: 1,
      headerBackgroundColorOpened: Colors.black54,
      headerPadding: const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
      children: [
        AccordionSection(
          isOpen: true,
          leftIcon: const Icon(Icons.insights_rounded, color: Colors.white),
          headerBackgroundColor: Colors.black38,
          headerBackgroundColorOpened: Colors.black54,
          header:
              const Text('Nested Section #1', style: AccordionPage.headerStyle),
          content: const Text(AccordionPage.loremIpsum,
              style: AccordionPage.contentStyle),
          contentHorizontalPadding: 20,
          contentBorderColor: Colors.black54,
        ),
        AccordionSection(
          isOpen: true,
          leftIcon: const Icon(Icons.compare_rounded, color: Colors.white),
          header:
              const Text('Nested Section #2', style: AccordionPage.headerStyle),
          headerBackgroundColor: Colors.black38,
          headerBackgroundColorOpened: Colors.black54,
          contentBorderColor: Colors.black54,
          content: const Row(
            children: [
              Icon(Icons.compare_rounded,
                  size: 120, color: Colors.orangeAccent),
              Flexible(
                  flex: 1,
                  child: Text(AccordionPage.loremIpsum,
                      style: AccordionPage.contentStyle)),
            ],
          ),
        ),
      ],
    );
  }
}
