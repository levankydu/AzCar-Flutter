import 'package:community_material_icon/community_material_icon.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;

import '../../page/home_page.dart';
import 'car_register.dart';

class FilePickerDemo extends StatefulWidget {
  @override
  _FilePickerDemoState createState() => _FilePickerDemoState();
}

class _FilePickerDemoState extends State<FilePickerDemo> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final _defaultFileNameController = TextEditingController();
  final _dialogTitleController = TextEditingController();
  final _initialDirectoryController = TextEditingController();
  final _fileExtensionController = TextEditingController();
  String? _fileName;
  String? _saveAsFileName;
  List<PlatformFile>? _paths;
  String? _directoryPath;
  String? _extension;
  bool _isLoading = false;
  bool _lockParentWindow = false;
  bool _userAborted = false;
  bool _multiPick = false;
  FileType _pickingType = FileType.any;
  List<PlatformFile>? _pickedFiles;

  @override
  void initState() {
    super.initState();
    _fileExtensionController
        .addListener(() => _extension = _fileExtensionController.text);
  }

  Future<void> _uploadImage() async {
    if (_paths == null || _paths!.isEmpty) {
      print('Chưa chọn ảnh');
      return;
    }
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.1.90:8081/api/auth/upload3'),

    );
    print('paths img count${_paths!.length}');
      var frontImg =
          await http.MultipartFile.fromPath('frontImg', _paths![0].path!);
      var insideImg =
          await http.MultipartFile.fromPath('insideImg', _paths![1].path!);
      var rightImg =
          await http.MultipartFile.fromPath('rightImg', _paths![2].path!);
      var leftImg = await http.MultipartFile.fromPath('leftImg', _paths![3].path!);
      var behindImg = await http.MultipartFile.fromPath('behindImg', _paths![4].path!);
      request.files.add(frontImg);
      request.files.add(insideImg);
    request.files.add(rightImg);
    request.files.add(leftImg);
    request.files.add(behindImg);
      try {
        var response = await request.send();
        if (response.statusCode == 200) {
          print('Upload successful');
          // Handle your response data here if needed
        } else {
          print('Upload failed with status: ${response.statusCode}');
          // Handle error here
        }
      } catch (e) {
        print('Exception during upload: $e');
        // Handle exception here
      }

  }

  void _pickFiles() async {
    _resetState();
    try {
      _directoryPath = null;
      _paths = (await FilePicker.platform.pickFiles(
        compressionQuality: 30,
        type: _pickingType,
        allowMultiple: true,
        onFileLoading: (FilePickerStatus status) => print(status),
        allowedExtensions: (_extension?.isNotEmpty ?? false)
            ? _extension?.replaceAll(' ', '').split(',')
            : null,
        dialogTitle: _dialogTitleController.text,
        initialDirectory: _initialDirectoryController.text,
        lockParentWindow: _lockParentWindow,
      ))
          ?.files;
    } on PlatformException catch (e) {
      _logException('Unsupported operation$e');
    } catch (e) {
      _logException(e.toString());
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _fileName =
          _paths != null ? _paths!.map((e) => e.name).toString() : '...';
      _userAborted = _paths == null;
    });
  }

  void _clearCachedFiles() async {
    _resetState();
    try {
      bool? result = await FilePicker.platform.clearTemporaryFiles();
      _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(
            (result!
                ? 'Temporary files removed with success.'
                : 'Failed to clean temporary files'),
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      );
    } on PlatformException catch (e) {
      _logException('Unsupported operation$e');
    } catch (e) {
      _logException(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _selectFolder() async {
    _resetState();
    try {
      String? path = await FilePicker.platform.getDirectoryPath(
        dialogTitle: _dialogTitleController.text,
        initialDirectory: _initialDirectoryController.text,
        lockParentWindow: _lockParentWindow,
      );
      setState(() {
        _directoryPath = path;
        _userAborted = path == null;
      });
    } on PlatformException catch (e) {
      _logException('Unsupported operation$e');
    } catch (e) {
      _logException(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveFile() async {
    _resetState();
    try {
      String? fileName = await FilePicker.platform.saveFile(
        allowedExtensions: (_extension?.isNotEmpty ?? false)
            ? _extension?.replaceAll(' ', '').split(',')
            : null,
        type: _pickingType,
        dialogTitle: _dialogTitleController.text,
        fileName: _defaultFileNameController.text,
        initialDirectory: _initialDirectoryController.text,
        lockParentWindow: _lockParentWindow,
      );
      setState(() {
        _saveAsFileName = fileName;
        _userAborted = fileName == null;
      });
    } on PlatformException catch (e) {
      _logException('Unsupported operation$e');
    } catch (e) {
      _logException(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _logException(String message) {
    print(message);
    _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _resetState() {
    if (!mounted) {
      return;
    }
    setState(() {
      _isLoading = true;
      _directoryPath = null;
      _fileName = null;
      _paths = null;
      _saveAsFileName = null;
      _userAborted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    ThemeData themeData = Theme.of(context);
    return MaterialApp(
      scaffoldMessengerKey: _scaffoldMessengerKey,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.deepPurple,
        ),
      ),
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Select Image'),
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
                    Get.to(() => CarRegister());
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
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 5.0, right: 5.0),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                  child: Wrap(
                    spacing: 10.0,
                    runSpacing: 10.0,
                    children: <Widget>[
                      SizedBox(
                        width: 120,
                        child: FloatingActionButton.extended(
                            onPressed: () => _pickFiles(),
                            label:
                                Text(_multiPick ? 'Pick files' : 'Pick file '),
                            icon: const Icon(Icons.description)),
                      ),
                      SizedBox(
                        width: 200,
                        child: FloatingActionButton.extended(
                          onPressed: () => _clearCachedFiles(),
                          label: const Text('Clear temporary files'),
                          icon: const Icon(Icons.delete_forever),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(),
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  'Image Picker Result',
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Builder(
                  builder: (BuildContext context) => _isLoading
                      ? Row(
                          children: [
                            Expanded(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 40.0,
                                  ),
                                  child: const CircularProgressIndicator(),
                                ),
                              ),
                            ),
                          ],
                        )
                      : _userAborted
                          ? Row(
                              children: [
                                Expanded(
                                  child: Center(
                                    child: SizedBox(
                                      width: 300,
                                      child: ListTile(
                                        leading: Icon(
                                          Icons.error_outline,
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 40.0),
                                        title: const Text(
                                          'User has aborted the dialog',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : _directoryPath != null
                              ? ListTile(
                                  title: const Text('Directory path'),
                                  subtitle: Text(_directoryPath!),
                                )
                              : _paths != null
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 20.0,
                                      ),
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.50,
                                      child: Scrollbar(
                                          child: ListView.separated(
                                        itemCount:
                                            _paths != null && _paths!.isNotEmpty
                                                ? _paths!.length
                                                : 1,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final bool isMultiPath =
                                              _paths != null &&
                                                  _paths!.isNotEmpty;
                                          final String name = 'File $index: ' +
                                              (isMultiPath
                                                  ? _paths!
                                                      .map((e) => e.name)
                                                      .toList()[index]
                                                  : _fileName ?? '...');
                                          final path = kIsWeb
                                              ? null
                                              : _paths!
                                                  .map((e) => e.path)
                                                  .toList()[index]
                                                  .toString();

                                          return ListTile(
                                            title: Text(
                                              name,
                                            ),
                                            subtitle: Text(path ?? ''),
                                          );
                                        },
                                        separatorBuilder:
                                            (BuildContext context, int index) =>
                                                const Divider(),
                                      )),
                                    )
                                  : _saveAsFileName != null
                                      ? ListTile(
                                          title: const Text('Save file'),
                                          subtitle: Text(_saveAsFileName!),
                                        )
                                      : const SizedBox(),
                ),
                SizedBox(
                  height: 40.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}