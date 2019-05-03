import 'dart:async';
import 'dart:io' show Directory, File, Platform;

import 'package:circle_wave_progress/circle_wave_progress.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_network/public_chat_page.dart';
import 'package:social_network/circular_logo_progress.dart';
import 'package:social_network/location.dart';
import 'package:social_network/reports_page.dart';
import 'package:social_network/upload_page.dart';
import 'package:social_network/user.dart';

void main() {
  print('[Main] START');
  runApp(SocialNetwork());
  print('[Main] DONE');
}

List<File> cameraFiles = new List<File>();
PageController pageController = PageController();

class RootPage extends StatefulWidget {
  RootPage({Key key}) : super(key: key);

  @override
  _RootPage createState() => _RootPage();
}

class SocialNetwork extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WaveCheck',
      theme: ThemeData(primaryIconTheme: IconThemeData(color: Colors.black)),
      home: RootPage(),
    );
  }
}

class _RootPage extends State<RootPage> {
  Address _userLocation;
  int _page = 0;
  bool _loadingIcon = true;
  String _cameraSourceOption = '';

  @override
  Widget build(BuildContext context) {

    print('[RootPage] [Build] START');

    print('[RootPage] [Build] cameraFiles: ${cameraFiles.toString()}');

    if (CurrentUser.instance != null) {

      print('[RootPage] [Build] CurrentUser.instance != null');
      print('[RootPage] [Build] building home screen');
      return _buildHomeScreen();
    }

    print('[RootPage] [Build] CurrentUser.instance == null');
    print('[RootPage] [Build] building login screen, _loadingIcon: $_loadingIcon');
    return _buildLoginScreen();
  }

  @override
  void dispose() {
    pageController.dispose();
    if (cameraFiles.isNotEmpty) cameraFiles.clear();
    super.dispose();
  }

  @override
  void initState() {

    /// Simulates googleSignIn.isSignedIn() method
    Future<bool> isSignedIn() async {
      await Future.delayed(Duration(milliseconds: 3000));
      return false;
    }

    print('[RootPage] [InitState] START');

    getUserLocation().then((location) {
      print('[RootPage] [InitState] (FUTURE) getUserLocation().addressLine: ${location.addressLine} DONE');
      setState(() => _userLocation = location);
    }, onError: (_) => print('[RootPage] [InitState] (FUTURE) getUserLocation() ERROR: _userLocation: $_userLocation'));

    /*GoogleSignIn*/isSignedIn().then((boolean) {
      print('[RootPage] [InitState] (FUTURE) isSignedIn: $boolean DONE');

      // Not signed.
      if (boolean == false) setState(() => _loadingIcon = false);
      
      // Is signed.
      if (boolean == true) {
        CurrentUser.signInWithGoogle(silently: true, userLocation: _userLocation).then((_) {
          print('[RootPage] [InitState] (FUTURE) CurrentUser.instance.id: ${CurrentUser.instance.id}, CurrentUser.instance.username: ${CurrentUser.instance.username} DONE');
          setState(() => _loadingIcon = false);
        });
      }
      
    }); 

    super.initState(); 
    print('[RootPage] [InitState] DONE');  
  }

  Widget _buildHomeScreen() {
    print('[RootPage] [BuildHomeScreen]');
    return Scaffold(
      backgroundColor: Colors.blue[100],
      body: PageView(
        controller: pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [

          // Page 0. Page controller is needed to manipulate top bar.
          Container(child: ReportsPage(pageController: pageController)),

          // Page 1.
          Container(
            child: Scaffold(
              backgroundColor: Colors.blue[100],
              appBar: AppBar(
                backgroundColor: Colors.blue[900],
                title: Text('Previsões',
                  style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold
                  )
                ),
              ),
              body: Center(child: Container(child: Text('Forecast page'),)),
            )
          ),

          // Page 2. Just exist to have the same number of pages and buttons on bottom bar.
          Container(),

          // Page 3.
          Container(
            child: Scaffold(
              backgroundColor: Colors.blue[100],
              appBar: AppBar(
                backgroundColor: Colors.blue[900],
                title: Text('Câmeras ao vivo',
                  style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold
                  )
                ),
              ),
              body: Center(child: Container(child: Text('Livecams page'),)),
            )
          ),

          // Page 4.
          Container(child: ChatPage()),
        ],
      ),

      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: Colors.blue[900],
        activeColor: Colors.orange, 
        currentIndex: _page,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem( // Page 0
            icon: Icon(Icons.library_books, color: (_page == 0 && _cameraSourceOption == '') ? Colors.orange[400] : Colors.black),
            title: Text('Reports', style: TextStyle(color: (_page == 0 && _cameraSourceOption == '') ? Colors.orange[400] : Colors.black),)),
          BottomNavigationBarItem( // Page 1
            icon: Icon(Icons.flare, color: (_page == 1 && _cameraSourceOption == '') ? Colors.orange[400] : Colors.black),
            title: Text('Previsões', style: TextStyle(color: (_page == 1 && _cameraSourceOption == '') ? Colors.orange[400] : Colors.black),),
            backgroundColor: Colors.white),
          BottomNavigationBarItem( // Page 2
            icon: Icon(Icons.camera /*Icons.party_mode*/, size: 48, color: (_page == 2 && _cameraSourceOption != '') ? Colors.orange[400] : Colors.black),
            title: Container(height: 0.0)),
          BottomNavigationBarItem( // Page 3
            icon: Icon(Icons.videocam, color: (_page == 3 && _cameraSourceOption == '') ? Colors.orange[400] : Colors.black),
            title: Text('Câmeras', style: TextStyle(color: (_page == 3 && _cameraSourceOption == '') ? Colors.orange[400] : Colors.black))),
          BottomNavigationBarItem( // Page 4
            icon: Icon(Icons.chat, color: (_page == 4 && _cameraSourceOption == '') ? Colors.orange[400] : Colors.black),
            title: Text('Chat', style: TextStyle(color: (_page == 4 && _cameraSourceOption == '') ? Colors.orange[400] : Colors.black),)
          ),
        ],

        onTap: (buttonTapped) async { // On tap bottom navigation bar

          print('[RootPage] [BuildHomeScreen] [OnBottomNavTap] buttonTapped: $buttonTapped, _page: $_page');

          // Didn't tapped camera button
          if (buttonTapped != 2) {
            if (buttonTapped != this._page) {
              setState(() { // Rebuild to colour button
                this._cameraSourceOption = '';
                this._page = buttonTapped;
              });
              pageController.jumpToPage(buttonTapped); // Change page view
            }
          }

          // Tapped camera button
          else {

            print('[RootPage] [BuildHomeScreen] [OnBottomNavTap] camera button tapped');

            final int _lastPage = this._page;

            setState(() { // Rebuild to colour the camera button
              this._cameraSourceOption = 'waitingToChoose';
              this._page = buttonTapped;
            }); 
            File _filePicked;
            await _showCameraDialog(); // Show dialog with options

            print('[RootPage] [BuildHomeScreen] [OnBottomNavTap] _cameraSourceOption: $_cameraSourceOption');

            if (_cameraSourceOption == 'photoFromCamera') // Chose 'Tirar foto'
              _filePicked = await ImagePicker.pickImage(source: ImageSource.camera, maxWidth: 1920, maxHeight: 1920);

            else if (_cameraSourceOption == 'photoFromGallery') // Chose 'Escolher da galeria'
              _filePicked = await ImagePicker.pickImage(source: ImageSource.gallery, maxWidth: 1920, maxHeight: 1920);

            else if (_cameraSourceOption == 'videoFromCamera') // Chose 'Gravar vídeo'
              _filePicked = await ImagePicker.pickVideo(source: ImageSource.camera); 

            else if (_cameraSourceOption == 'videoFromGallery') // Chose 'Gravar vídeo'
              _filePicked = await ImagePicker.pickVideo(source: ImageSource.gallery); 

            if (_filePicked == null) { // If canceled image picker, uncolour the camera button
              print('[RootPage] [BuildHomeScreen] [OnBottomNavTap] _filePicked == null');
              setState(() {
                this._cameraSourceOption = '';
                this._page = _lastPage;
              });
            }
            else{ // If didn't canceled image picker

              print('[RootPage] [BuildHomeScreen] [OnBottomNavTap] _filePicked.path: ${_filePicked.path}');

              // If the file picked is a mp4 video
              if (_filePicked.path.substring((_filePicked.path.length)-3, _filePicked.path.length) == 'mp4') {
                print('[RootPage] [BuildHomeScreen] [OnBottomNavTap] _filePicked == mp4 video');
                setState(() {
                  this._cameraSourceOption = '';
                  this._page = _lastPage;
                });
                Navigator.of(context).push(MaterialPageRoute( // Push upload screen with the file and the user location
                  builder: (BuildContext context) => UploadPage(lastFilePicked: _filePicked, address: _userLocation,))
                );
              }

              // If the file picked is a photo
              else {

                print('[RootPage] [BuildHomeScreen] AAAAAAAAAAA');

                File _croppedFile = await ImageCropper.cropImage(sourcePath: _filePicked.path, ratioX: 1.0, ratioY: 1.0, maxWidth: 600, maxHeight: 600, toolbarTitle: 'Recorte a imagem', toolbarColor: Colors.blue[900]);

                if (_croppedFile != null) { // If didn't canceled image cropper
                  print('[RootPage] [BuildHomeScreen] _croppedFile: $_croppedFile');
                  setState(() {
                    this._cameraSourceOption = '';
                    this._page = _lastPage;
                  });
                  Navigator.of(context).push(MaterialPageRoute( // Push upload screen with the file and the user location
                    builder: (BuildContext context) => UploadPage(lastFilePicked: _croppedFile, address: _userLocation,))
                  );
                }

                else { // If canceled image cropper
                  print('[RootPage] [BuildHomeScreen] [OnBottomNavTap] _croppedFile == null');
                  setState(() {
                    this._cameraSourceOption = '';
                    this._page = _lastPage;
                  });
                }
              }
            }
          }
        },
      ),
    );
  }

  Widget _buildLoginScreen() {
    print('[RootPage] [BuildLoginScreen]');
    return Scaffold(
      backgroundColor: Colors.blue[500],
      body: GestureDetector(
        onTap: _onClickLogin,
        child: Stack(
          children: <Widget>[
            
            Center(
              child: Container(  // Back wave
                child: CircleWaveProgress(
                  size: 256.0, 
                  backgroundColor: Colors.orange[300], 
                  waveColor: Colors.blue[900], 
                  borderColor: Colors.transparent, 
                  borderWidth: 0.0, 
                  progress: 24.0,
                )
              ),
            ),
          
            Center(
              child: Container(  // Front wave
                child: CircleWaveProgress(
                  size: 256.0, 
                  backgroundColor: Colors.transparent, 
                  waveColor: Colors.blue[600], 
                  borderColor: Colors.black, 
                  borderWidth: 3.0, 
                  progress: 14.0,
                )
              ),
            ),

            Center(
              child: Container(  // Title
                padding: EdgeInsets.only(bottom: 48.0),
                child: const Text('WaveCheck',
                  style: const TextStyle(
                    fontFamily: "Raustila-Regular", color: Colors.black, fontSize: 64.0, 
                    shadows: [
                      Shadow(offset: Offset(-0.5, -0.5), color: Colors.orange),
                      Shadow(offset: Offset(0.5, -0.5), color: Colors.orange),
                      Shadow(offset: Offset(0.5, 0.5), color: Colors.orange),
                      Shadow(offset: Offset(-0.5, 0.5), color: Colors.orange),
                    ]
                  )
                ),
              ),
            ),

            Center(
              child: Container(  // Subtitle
                padding: EdgeInsets.only(top: 34.0),
                child: const Text('Sua onda começa aqui!',
                  style: const TextStyle(
                    fontFamily: "Raustila-Regular", color: Colors.black, fontSize: 32.0, 
                    shadows: [
                      Shadow(offset: Offset(-0.5, -0.5), color: Colors.orange),
                      Shadow(offset: Offset(0.5, -0.5), color: Colors.orange),
                      Shadow(offset: Offset(0.5, 0.5), color: Colors.orange),
                      Shadow(offset: Offset(-0.5, 0.5), color: Colors.orange),
                    ]
                  )
                ),
              ),
            ),

            Center(
              child: Container(  // Tip
                padding: EdgeInsets.only(top: 285.0),
                child: Visibility(
                  visible: !_loadingIcon,
                    child: const Text('Toque na tela para se conectar',
                      style: const TextStyle(color: Colors.black, fontSize: 11.0
                    )
                  )
                ),
              ),
            ),

            Center(
              child: Container(  // Progress indicator
                padding: EdgeInsets.only(top: 480.0),
                alignment: Alignment.bottomCenter,
                child: Visibility(
                  visible: _loadingIcon, 
                  child: CircularLogoProgress(useText: true,)
                ),
              ),
            ),
            
          ],
        ),
      ),
    );
  }

  void _onClickLogin() async {
    print('[RootPage] [OnClickLogin] START');
    setState(() => _loadingIcon = true);
    await CurrentUser.signInWithGoogle(userLocation: _userLocation);  
    setState(() => _loadingIcon = false);
    print('[RootPage] [OnClickLogin] CurrentUser.instance.toString: ${CurrentUser.instance.toString()}');
    print('[RootPage] [OnClickLogin] DONE');
  }

  _showCameraDialog() async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: true,

      builder: (BuildContext context) {

        double _containerHeight = 32.0;
        const double _fontSize = 20.0;

        return SimpleDialog(
          contentPadding: EdgeInsets.all(8.0),
          title: Container(padding: EdgeInsets.only(bottom: 8.0),alignment: FractionalOffset.center, child:Text('Enviar um report', style: TextStyle(fontSize: 24.0))),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16.0))),
          children: <Widget>[
            Divider(height: 0.0),
            SimpleDialogOption(
              child: Container(
                alignment: FractionalOffset.center,
                height: _containerHeight, child: const Text('Tirar foto', style: TextStyle(fontSize: _fontSize))),
              onPressed: () {
                setState(() {
                  _cameraSourceOption = 'photoFromCamera';
                });
                Navigator.pop(context);
              }),
            Divider(height: 0.0),
            SimpleDialogOption(
              child: Container(
                alignment: FractionalOffset.center,
                height: _containerHeight, child: const Text('Escolher foto da galeria', style: TextStyle(fontSize: _fontSize))),
              onPressed: () {
                setState(() {
                  _cameraSourceOption = 'photoFromGallery';
                });
                Navigator.pop(context);
              }),
            Divider(height: 0.0),
            SimpleDialogOption(
              child: Container(
                alignment: FractionalOffset.center,
                height: _containerHeight, child: const Text('Gravar vídeo', style: TextStyle(fontSize: _fontSize))),
              onPressed: () {
                setState(() {
                  _cameraSourceOption = 'videoFromCamera';
                });
                Navigator.pop(context);
              }),
            Divider(height: 0.0),
            SimpleDialogOption(
              child: Container(
                alignment: FractionalOffset.center,
                height: _containerHeight, child: const Text('Escolher vídeo da galeria', style: TextStyle(fontSize: _fontSize))),
              onPressed: () {
                setState(() {
                  _cameraSourceOption = 'videoFromGallery';
                });
                Navigator.pop(context);
              }),
            Divider(height: 0.0),
            SimpleDialogOption(
              child: Container(
                padding: EdgeInsets.only(top: 8.0),
                alignment: FractionalOffset.center,
                height: _containerHeight, child: const Text('Voltar', style: TextStyle(fontSize: _fontSize, color: Colors.red))),
              onPressed: () {
                setState(() {
                  _cameraSourceOption = '';
                });
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

}