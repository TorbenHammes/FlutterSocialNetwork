import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as Math;

import 'package:circular_profile_avatar/circular_profile_avatar.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:image/image.dart' as Img;
import 'package:path_provider/path_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:uuid/uuid.dart';
import 'package:social_network/circular_logo_progress.dart';
import 'package:social_network/user.dart';
import 'package:social_network/report_post.dart';

import 'main.dart';

void _postReportOnFireStore({String mediaUrl, String latitude, String longitude, String countryCode, 
                             String countryName, String state, String city, bool showCity, String neighborhood, bool showNeighborhood,
                             String street, String number, String spot, bool showSpot, int quality, String description, String timeLabel, String dayLabel}) async {
  
  //CollectionReference postsCollectionReference = Firestore.instance.collection('insta_posts');

  /*postsCollectionReference.add({
    "username": CurrentUser.instance.username,
    "mediaUrl": mediaUrl,
    "latitude": latitude == null ? '' : latitude,
    "longitude": longitude == null ? '' : longitude,
    "countryCode": countryCode == null ? '' : countryCode,
    "countryName": countryName == null ? '' : countryName,
    "state": state == null ? '' : state,
    "city": city == null ? '' : city,
    "showCity": showCity,
    "neighborhood": neighborhood == null ? '' : neighborhood,
    "showNeighborhood": showNeighborhood,
    "street": street == null ? '' : street,
    "number": number == null ? '' : number,
    "spot": spot == null ? '' : spot,
    "showSpot": showSpot,
    "quality": quality == null ? -1 : quality,
    "description": description == null ? '' : description,
    "ownerId": CurrentUser.instance.id,
    "likes": {},
    "timestamp": DateTime.now().toString(),
    "daylabel": dayLabel == null ? 'HOJE' : dayLabel,
    "timelabel": timeLabel == null ? '00h00' : timeLabel,
    "deleted": false
  }).then((DocumentReference doc) {
    String _docId = doc.documentID;
    postsCollectionReference.document(_docId).updateData({"postId": _docId});
  });*/
}

Future<String> _uploadImage(var imageFile) async {
  var _uuid = Uuid().v1();
  //StorageReference _ref = FirebaseStorage.instance.ref().child("post_$_uuid.jpg");
  //StorageUploadTask _uploadTask = _ref.putFile(imageFile);

  //String _downloadUrl = await (await _uploadTask.onComplete).ref.getDownloadURL();
  //return _downloadUrl;
}

class ResizedImage {
  final File file;
  final int newWidth;
  final int newHeight;
  final SendPort sendPort;
  
  ResizedImage(this.file, this.sendPort, {this.newWidth = -1, this.newHeight = -1});
}

class UploadPage extends StatefulWidget {

  final Address address;
  final File lastFilePicked;

  const UploadPage({
    this.address,
    this.lastFilePicked,
  });

  _UploadPage createState() => _UploadPage();
}

class _UploadPage extends State<UploadPage> {

  String _latitude;
  String _longitude;
  String _countryCode;
  String _countryName;
  String _state;
  String _city;
  String _neighborhood;
  String _street;
  String _number;
  int _quality;
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _spotController = TextEditingController();

  bool _isUploading = false;
  File _thumbnailImage;
  File _mediumImage;
  File _originalImage;
  double _qualitySliderValue = 2.0;
  bool _showCity = true;
  bool _showNeighborhood = true;
  bool _showSpot = false;
  bool _likedOwnPost = false;

  Widget get _qualitySlider {

    Color _sliderColor;
    String _sliderMainText;
    String _sliderSubText;

    if (_qualitySliderValue == 0.0) {
      _sliderColor = Colors.red[700];
      _sliderMainText = 'Flat';
      _sliderSubText = 'Sem condições!';
    }
    else if (_qualitySliderValue < 1.0) {
      _sliderColor = Colors.orange[700];
      _sliderMainText = 'Ruim';
      _sliderSubText = 'Ter, tem... Mas...';
    }
    else if (_qualitySliderValue < 2.0) {
      _sliderColor = Colors.green[700];
      _sliderMainText = 'Bom';
      _sliderSubText = 'Tá valendo!';
    }
    else {
      _sliderColor = Colors.green[700];
      _sliderMainText = 'Clássico';
      _sliderSubText = 'Só vai, maluco!';
    }


    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
          child: 

          _quality == 3
          
          ? Shimmer.fromColors(
            baseColor: Colors.green[700],
            highlightColor: Colors.green[100],
            child: 
            
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[

                Column( // Slider
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      child: Slider(
                        value: _qualitySliderValue,
                        activeColor: _sliderColor,
                        min: 0.0,
                        max: 2.0,
                        onChanged: (newValue) {
                          if (newValue == 0.0) setState(() { _qualitySliderValue = newValue; _quality = 0; });
                          else if (newValue < 1.0) setState(() { _qualitySliderValue = newValue; _quality = 1; });
                          else if (newValue < 2.0) setState(() { _qualitySliderValue = newValue; _quality = 2; });
                          else setState(() { _qualitySliderValue = newValue; _quality = 3; });
                        },   
                      ),
                    ),
                  ],
                ),

                GestureDetector(
                  onTap: () {
                    if (_qualitySliderValue == 0.0) {
                      setState(() => _qualitySliderValue = 0.66);
                    } 
                    else if (_qualitySliderValue < 1.0) {
                      setState(() => _qualitySliderValue = 1.32);
                    }
                    else if (_qualitySliderValue < 2.0) {
                      setState(() => _qualitySliderValue = 2.0);
                    }
                    else if (_qualitySliderValue == 2.0) {
                      setState(() => _qualitySliderValue = 0.0);
                    }
                    else {
                      setState(() => _qualitySliderValue = 1.32);
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[  

                      Container( // Main text
                        alignment: Alignment.center,
                        child: Text('$_sliderMainText', textAlign: TextAlign.center, style: TextStyle(fontSize: 22)),
                      ),

                      Container( // Subtext
                        alignment: Alignment.center,
                        child: Text('$_sliderSubText', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      ),
                      
                    ],
                  ),
                ),

                

                
              ],
            ),
          )
          
          // _quality != 3 
          : Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[

              Column( // Slider
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    child: Slider(
                      value: _qualitySliderValue,
                      activeColor: _sliderColor,
                      min: 0.0,
                      max: 2.0,
                      onChanged: (newValue) {
                        if (newValue == 0.0) setState(() { _qualitySliderValue = newValue; _quality = 0; });
                        else if (newValue < 1.0) setState(() { _qualitySliderValue = newValue; _quality = 1; });
                        else if (newValue < 2.0) setState(() { _qualitySliderValue = newValue; _quality = 2; });
                        else setState(() { _qualitySliderValue = newValue; _quality = 3; });
                      },   
                    ),
                  ),
                ],
              ),

              GestureDetector(
                onTap: () {
                  if (_qualitySliderValue == 0.0) {
                    setState(() => _qualitySliderValue = 0.66);
                  } 
                  else if (_qualitySliderValue < 1.0) {
                    setState(() => _qualitySliderValue = 1.32);
                  }
                  else if (_qualitySliderValue < 2.0) {
                    setState(() => _qualitySliderValue = 2.0);
                  }
                  else if (_qualitySliderValue == 2.0) {
                    setState(() => _qualitySliderValue = 0.0);
                  }
                  else {
                    setState(() => _qualitySliderValue = 1.32);
                  }
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[  

                    Container( // Main text
                      alignment: Alignment.center,
                      child: Text('$_sliderMainText', textAlign: TextAlign.center, style: TextStyle(fontSize: 22)),
                    ),

                    Container( // Subtext
                      alignment: Alignment.center,
                      child: Text('$_sliderSubText', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    ),
                    
                  ],
                ),
              ),

              
            ],
          ),
        ),

      ],
    );
  }

  Widget build(BuildContext context) {
    print('[UploadPage] [Build] START');

    if (cameraFiles.isEmpty) {
      print (['UploadPage] [Build] ERROR cameraFiles.isEmpty']);
      Navigator.of(context).pop();
    }

    print('[UploadPage] [Build] cameraFiles: $cameraFiles');

    return Scaffold(

      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.blue[100],

      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.red[900],),
          onPressed: () {if (cameraFiles.isNotEmpty) cameraFiles.clear();}),
        title: const Text('Forneça mais detalhes!',
          style: const TextStyle(color: Colors.white)),
        actions: <Widget>[

          IconButton(
            onPressed: () => _postImage(),
            icon: Icon(Icons.check, color: Colors.green[500],)
          )

        ],
      ),

      body: Center(
        child: Stack(
          children: [

            ListView(
              children: <Widget>[
                _buildBody(
                  imageFile: cameraFiles[0],
                  descriptionController: _descriptionController,
                  isUploading: _isUploading
                ),
              ],
            ),

            _isUploading 
            ? Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                    color: Colors.black54, 
                    child: CircularLogoProgress(useText: true),
                  )
                )
              ],
            ) 
            : Container(),

          ]
        ),
      )
    );
  }

  @override
  void dispose() {
    print('[UploadPage] [Dispose] START');
    cameraFiles.clear();
    print('[UploadPage] [Dispose] cameraFiles: $cameraFiles');
    super.dispose();
    print('[UploadPage] [Dispose] DONE');
  }

  @override
  void initState() {
    print('[UploadPage] [InitState] START');

    if (widget.lastFilePicked != null)
      cameraFiles.add(widget.lastFilePicked);

    print('[UploadPage] [InitState] cameraFiles: $cameraFiles');

    if (widget.address != null) {
      //print('[UploadPage] [InitState] widget.address.toMap.toString: ${widget.address.toMap().toString()}');
      _latitude = widget.address.toMap()['coordinates'] != null ? widget.address.toMap()['coordinates']['latitude'].toString() : '';
      _longitude = widget.address.toMap()['coordinates'] != null ? widget.address.toMap()['coordinates']['longitude'].toString() : '';
      _countryCode = widget.address.toMap()['countryCode'] != null ? widget.address.toMap()['countryCode'] : '';
      _countryName = widget.address.toMap()['countryName'] != null ? widget.address.toMap()['countryName'] : '';
      _state = widget.address.toMap()['adminArea'] != null ? widget.address.toMap()['adminArea'] : '';
      _city = widget.address.toMap()['subAdminArea'] != null ? widget.address.toMap()['subAdminArea'] : '';
      _neighborhood = widget.address.toMap()['subLocality'] != null ? widget.address.toMap()['subLocality'] : '';
      _street = widget.address.toMap()['thoroughfare'] != null ? widget.address.toMap()['thoroughfare'] : '';
      _number = widget.address.toMap()['subThoroughfare'] != null ? widget.address.toMap()['subThoroughfare'] : '';
    }

    print('[UploadPage] [InitState] _state: $_state, _city: $_city, _neighborhood: $_neighborhood, _street: $_street, _number: $_number');
    
    super.initState();
    print('[UploadPage] [InitState] DONE');
  }

  Widget _buildBody({File imageFile, TextEditingController descriptionController, bool isUploading}) {

    print('[UploadPage] [BuildBody] imageFile: $imageFile');

    Color _cardColor;

    if (_qualitySliderValue == 0.0) {
      _quality = 0;
      _cardColor = Colors.red[700];
    }
    else if (_qualitySliderValue < 1.0) {
      _quality = 1;
      _cardColor = Colors.orange[700];
    }
    else if (_qualitySliderValue < 2.0) {
      _quality = 2;
      _cardColor = Colors.green[700];
    }
    else {
      _quality = 3;
      _cardColor = Colors.green[700];
    }

    return Column(
      children: <Widget>[

        // Description text field
        Container(
          padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
          child: Form(
            child: TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(top: 2.0, bottom: 2.0),
                labelText: 'Descrição', 
                hintText: 'Meio metro, vento parado, formação boa!',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13))))),

        // Quality slider
        _qualitySlider,

        _buildOptions(),

        Container(padding: EdgeInsets.symmetric(horizontal: 8.0),child: Divider(height: 0.0,)),

        // Owner avatar, owner username, location
        _buildHeaderRow(),

        _quality == 3 
        ? Stack(
          children: <Widget>[
            
            Shimmer.fromColors(
              baseColor: Colors.green[700],
              highlightColor: Colors.green[100],
              child: Card(
                margin: EdgeInsets.only(left: 4.0, top: 8.0, right: 4.0, bottom: 8.0),
                color: _cardColor,
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                  side: BorderSide(width: 2.0)),
                child: Container(
                  margin: EdgeInsets.only(left: 6.0, top: 6.0, right: 6.0, bottom: 6.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0)),
                  child: Stack(
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Image.file(imageFile),
                      )
                    ],
                  ),
                ),
              ),
            ),

            Card(
              margin: EdgeInsets.only(left: 4.0, top: 8.0, right: 4.0, bottom: 8.0),
              color: Colors.transparent,
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
                side: BorderSide(width: 2.0)),
              child: Container(
                margin: EdgeInsets.only(left: 6.0, top: 6.0, right: 6.0, bottom: 6.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0)),
                child: Stack(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: Image.file(imageFile),
                    )
                  ],
                ),
              ),
            ),
          ],
        )

        // Image
        : Card(
          margin: EdgeInsets.only(left: 4.0, top: 8.0, right: 4.0, bottom: 8.0),
          color: _cardColor,
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
            side: BorderSide(width: 2.0)),
          child: Container(
            margin: EdgeInsets.only(left: 6.0, top: 6.0, right: 6.0, bottom: 6.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0)),
            child: Stack(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: Image.file(imageFile),
                )
              ],
            ),
          ),
        ),

        _buildHeartAndBallonRow(),

        _buildDescriptionRow(),

      ]
    );
  }

  Widget _buildDescriptionRow() {
    return Visibility(
      visible: (_descriptionController.text != null && _descriptionController.text != ''),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(left: 16.0, bottom: 8),
            child: Text("${CurrentUser.instance.username} ", style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,))),
          Expanded(child: Text('${_descriptionController.text}')),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {

    double _getAvatarRadius() { // Includes username
      
      bool _hasCity = false;
      bool _hasNeighborhood = false;
      bool _hasSpot = false;

      if (_city != null && _city != '') _hasCity = true;
      if (_neighborhood != null && _neighborhood != '') _hasNeighborhood = true;
      if (_spotController.text != null && _spotController.text != '') _hasSpot = true;

      if ((_hasCity || _hasNeighborhood)) 
        if (_hasSpot) return 23.0;
      else
        if (_hasSpot) return 17.0;
        else return 14.0;
    }

    print('[UploadPage] [BuildHeaderRow] START');

    print('[UploadPage] [BuildHeaderRow] username: ${CurrentUser.instance.username}, city: $_city, neighborhood: $_neighborhood, spot: ${_spotController.text}, quality: $_quality');

    double _avatarRadius = _getAvatarRadius();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[

        Row(
          children: <Widget>[

            // Post owner profile image
            Container(
              padding: EdgeInsets.only(left: 8.0, top: 8.0),
              alignment: Alignment.center,
              child: CircularProfileAvatar(
                imageUrl: CurrentUser.instance.photoUrl,
                radius: _avatarRadius,             
                backgroundColor: Colors.transparent,
                borderWidth: 1,
                borderColor: Colors.black,
                elevation: 5.0,
                cacheImage: true,
              ),
            ),

            // Post owner username and post location
            GestureDetector(
              onTap: () {
                if(_showSpot) _showDefineSpotDialog();
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row ( // Post owner username
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 8.0, top: 8.0),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(fontSize: 15.0, color: Colors.black),
                            children: <TextSpan>[
                              TextSpan(text: '${CurrentUser.instance.username}', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )
                      ),
                    ],
                  ),

                  Row ( // Post location
                    children: <Widget>[

                      Padding(padding: EdgeInsets.only(left: 8.0),),

                      Visibility( // City
                        visible: _showCity,
                        child: Row(
                          children: <Widget>[
                            Text('$_city')
                          ],
                        ),
                      ),

                      Visibility(visible: _showNeighborhood, child: Text(', '), ),

                      Visibility( // Neighborhood
                        visible: _showNeighborhood,
                        child: Row(
                          children: <Widget>[
                            Text('$_neighborhood')
                          ],
                        ),
                      ),

                    ],
                  ),

                  Visibility( // Spot
                    visible: _showSpot,
                    child: Row(
                      children: <Widget>[

                        Padding(padding: EdgeInsets.only(left: 8.0),),

                        Text('${_spotController.text}'),
                      ],
                    )
                  ),
                  
                  
                ]
              ),
            ),

          ],
        ),

        Container(
          padding: EdgeInsets.only(right: 8),
          child: Icon(Icons.more_vert, color: Colors.grey[500]),
        ),

      ],
    );
  }

  String _getTimeLabelValue() {
    String _hours = '00';
    String _minutes = '00';

    if (DateTime.now().hour < 10) _hours = '0${DateTime.now().hour}';
    else _hours = '${DateTime.now().hour}';

    if (DateTime.now().minute < 10) _minutes = '0${DateTime.now().minute}';
    else _minutes = '${DateTime.now().minute}';

    return _hours+'h'+_minutes;
  }
  
  Widget _buildHeartAndBallonRow({String postOwnerId}) {

    

    TextStyle boldStyle = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
    );

    Color heartColor;
    IconData heartIcon;
    

    if (_likedOwnPost) {
      heartColor = Colors.pink;
      heartIcon = FontAwesomeIcons.solidHeart;
    } else {
      heartIcon = FontAwesomeIcons.heart;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[

        Column( // Day and hour
          children: <Widget>[

            Row(
              children: <Widget>[
                
                Container( // Day
                  height: 30.0,
                  padding: EdgeInsets.only(left: 8.0, right: 8.0),
                  margin: EdgeInsets.only(left: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: InkWell(
                    child: Center(
                      child: Text('HOJE',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ),
                ),

                Container( // Hour
                  height: 30.0,
                  padding: EdgeInsets.only(left: 8.0, right: 8.0),
                  margin: EdgeInsets.only(left: 4.0, right: 16.0,),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: InkWell(
                    child: Center(
                      child: Text(_getTimeLabelValue(),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ),
                ),
              ],
            ), 

          ],
        ),

        Container(
          margin: const EdgeInsets.only(left: 8.0),
          child: _likedOwnPost ? Text("1 curtida", style: boldStyle,) : Text("0 curtidas", style: boldStyle),
        ),

        Column( // Heart and balloon
          children: <Widget>[
            Row(
              children: <Widget>[
                // Heart
                Padding(padding: const EdgeInsets.only(left: 16.0, top: 40.0)),
                GestureDetector(child: Icon(heartIcon, size: 25.0, color: heartColor), onTap: () { setState(() => _likedOwnPost = !_likedOwnPost); }),

                // Balloon
                Padding(padding: const EdgeInsets.only(left: 16.0,)),
                GestureDetector(child: const Icon(FontAwesomeIcons.comment, size: 25.0),
                  onTap: () {}
                ),
                Padding(padding: const EdgeInsets.only(left: 8.0,)),
              ],
            )
          ],
        ),

      ],
    );
  }

  Widget _buildOptions() {
    return Container(
      padding: EdgeInsets.only(top: 8, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[

          Row(children: <Widget>[
            Checkbox(value: _showCity, onChanged: (_) {
              setState(() => _showCity = !_showCity);
            }),
            Text('Cidade'),
          ],),

          Row(children: <Widget>[
            Checkbox(value: _showNeighborhood, onChanged: (_) {
              setState(() => _showNeighborhood = !_showNeighborhood);
            }),
            Text('Bairro'),
          ],), 

          _showSpot
          ? Row(
            children: <Widget>[

              IconButton(
                padding: EdgeInsets.only(left: 16),
                icon: Icon(Icons.pin_drop, size: 28, color: Colors.red[800],), 
                onPressed: () {
                  setState(() {_showSpot = false;});
                }
              ),

              GestureDetector(
                onTap: () {
                  setState(() {_showSpot = false;});
                },
                child: Container(
                  margin: EdgeInsets.only(right: 10),
                  child: Column(
                    children: <Widget>[
                      Text('Esconder', style: TextStyle(fontSize: 13)),
                      Text('o pico', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ],
          )

          : Row(
            children: <Widget>[

              IconButton(
                padding: EdgeInsets.only(left: 16),
                icon: Icon(Icons.pin_drop, size: 28, color: _spotController.text != '' ? Colors.green[600] : Colors.blue[600],), 
                onPressed: () {

                  if (_spotController.text == '') {
                    _showDefineSpotDialog();
                  }
                  
                  if (_spotController.text != '' && _spotController.text != null) {
                    setState(() => _showSpot = true);
                  }
                }
              ),

              GestureDetector(
                onTap: () {
                  if (_spotController.text == '') {
                    _showDefineSpotDialog();
                  }

                  if (_spotController.text != '' && _spotController.text != null) {
                    setState(() => _showSpot = true);
                  }
                },
                child: Container(
                  margin: EdgeInsets.only(right: 10),
                  child: Column(
                    children: <Widget>[
                      Text(_spotController.text != '' ? 'Exibir' : 'Definir', style: TextStyle(fontSize: 13)),
                      Text('o pico', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _compressImage({@required String type}) async {

    void _decodeImage(ResizedImage decodedObj) {

      Img.Image newImage;
      
      // decodeImage will identify the format of the image and use the appropriate decoder.
      Img.Image _image = Img.decodeImage(decodedObj.file.readAsBytesSync());

      // Resize the image to a new width x new height thumbnail (maintaining the aspect ratio).
      if (decodedObj.newWidth != null && decodedObj.newHeight == null) {
        newImage = Img.copyResize(_image, decodedObj.newWidth);
      } 
      else if (decodedObj.newWidth != null && decodedObj.newHeight != null) {
        newImage = Img.copyResize(_image, decodedObj.newWidth, decodedObj.newHeight);
      }
      else if (decodedObj.newWidth == null && decodedObj.newHeight != null) {
        newImage = Img.copyResize(_image, _image.width, decodedObj.newHeight);
      }
      else if (decodedObj.newWidth == null && decodedObj.newHeight == null) {
        newImage = Img.copyResize(_image, _image.width);
      }

      // Send back to the receiverPort.
      decodedObj.sendPort.send(newImage);
    }

    print('[UploadPage] [CompressImage] START');

    String _tempDirPath;
    final int _randomNumber = Math.Random().nextInt(10000);
    String _date = DateTime.now().year.toString() + '_' + DateTime.now().month.toString() + '_' + DateTime.now().day.toString() + '_' +
                   DateTime.now().hour.toString() + '_' + DateTime.now().minute.toString() + '_' + DateTime.now().second.toString();

    getTemporaryDirectory().then((onValue) {
      _tempDirPath = onValue.path;
      print('[UploadPage] [CompressImage] (FUTURE) _tempDirPath: $_tempDirPath DONE');
    });
 
    if (type == 'thumbnail') {

      // Decodes and process an image file in a separate thread (isolate) to avoid stalling the main UI thread.

      // Creates a ReceivePort (the only means of communication between isolates).
      ReceivePort receivePortSmall = ReceivePort(); 
      await Isolate.spawn(_decodeImage, ResizedImage(cameraFiles[0], receivePortSmall.sendPort, newWidth: 120));

      // Gets the processed image from the isolate.
      Img.Image _imageResizedToSmall = await receivePortSmall.first;

      print('[UploadPage] [CompressImage] _imageResizedToSmall resolution: ${_imageResizedToSmall.width}x${_imageResizedToSmall.height} DONE');

      // Creates a thumbnail file in JPG format
      File _thumbnailJpg = File('$_tempDirPath/img_small_${_date}_$_randomNumber.jpg')..writeAsBytesSync(Img.encodeJpg(_imageResizedToSmall));

      setState(() => this._thumbnailImage = _thumbnailJpg);
    }

    else if (type == 'medium') {
      ReceivePort receivePortMedium = ReceivePort();
      await Isolate.spawn(_decodeImage, ResizedImage(cameraFiles[0], receivePortMedium.sendPort, newWidth: 500));
      Img.Image _imageResizedToMedium = await receivePortMedium.first;
      print('[UploadPage] [CompressImage] _imageResizedToMedium resolution: ${_imageResizedToMedium.width}x${_imageResizedToMedium.height} DONE');
      File _mediumJpg = File('$_tempDirPath/img_medium_${_date}_$_randomNumber.jpg')..writeAsBytesSync(Img.encodeJpg(_imageResizedToMedium));
      setState(() => this._mediumImage = _mediumJpg);
    }

    else if (type == 'original') {
      ReceivePort receivePortOriginal = ReceivePort();
      await Isolate.spawn(_decodeImage, ResizedImage(cameraFiles[0], receivePortOriginal.sendPort));
      Img.Image _imageNotResized = await receivePortOriginal.first;
      print('[UploadPage] [CompressImage] _imageNotResized resolution: ${_imageNotResized.width}x${_imageNotResized.height} DONE');
      File _originalJpg = File('$_tempDirPath/img_original_${_date}_$_randomNumber.jpg')..writeAsBytesSync(Img.encodeJpg(_imageNotResized));
      setState(() => this._originalImage = _originalJpg);
    }
    
    print('[UploadPage] [CompressImage] DONE');
  }

  /// Creates a new resized image, post it on firebase storage, post on firebase database, 
  /// add to CurrentUser's reportsFeed and deletes the resized image from cellphone. 
  Future<void> _postImage() async {

    print('[UploadPage] [PostImage] START');

    setState(() => _isUploading = true);

    // Compress the image on a separated thread to avoid stalling the UI
    await _compressImage(type: 'medium');

    // Upload image to firebase storage
    _uploadImage(_mediumImage).then((String mediumImageUrl) {

      print('[UploadPage] [PostImage] (FUTURE) mediumImageUrl: $mediumImageUrl DONE');

      // Add report to database
      _postReportOnFireStore(mediaUrl: mediumImageUrl, latitude: _latitude, longitude: _longitude, timeLabel: _getTimeLabelValue(), dayLabel: 'HOJE', countryCode: _countryCode, 
                             countryName: _countryName, state: _state, city: _city, showCity: _showCity, neighborhood: _neighborhood, showNeighborhood: _showNeighborhood, 
                             spot: _spotController.text, showSpot: _showSpot, quality: _quality, description: _descriptionController.text, street: _street, number: _number);

      // Add report to UI
      CurrentUser.instance.reportsFeed.add(ReportPost(mediaUrl: mediumImageUrl, timeLabel: _getTimeLabelValue(), dayLabel: 'HOJE', 
                             city: _city, showCity: _showCity, neighborhood: _neighborhood, showNeighborhood: _showNeighborhood, 
                             spot: _spotController.text, showSpot: _showSpot, quality: _quality, description: _descriptionController.text));
    }).then((_) {

      // Delete the mediumImage file from cellphone
      setState(() { _mediumImage.delete(); });

      print('[UploadPage] [PostImage] (FUTURE) _mediumImage: $_mediumImage DONE');

      // Goes to the last page open
      Navigator.of(context).pop();
    });

    print('[UploadPage] [PostImage] DONE');
  }

  Future<void> _showDefineSpotDialog() async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: true,

      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Ao definir o pico, você pode escolher se deseja exibi-lo publicamente ou prefere escondê-lo para que apenas seus seguidores vejam.', 
            style: TextStyle(fontSize: 16),),
          children: <Widget>[
            SimpleDialogOption(
              child: Container( // Spot text field
                child: Form(
                  onChanged: (() {
                    if (_spotController.text == '') {
                      setState(() {_showSpot = false;});
                    } else {
                      setState(() {_showSpot = true;});
                    }
                    
                  }),
                  child: TextFormField(
                    controller: _spotController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(top: 2.0, bottom: 2.0),
                      labelText: 'Pico', 
                      hintText: 'Pontão, Posto 12, P10, 2W, Cantão, Meio, ...',
                      hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13)
                    )
                  )
                )
              ),
            )
          ],
        );
      },
    );
  }

}