import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:social_network/circular_logo_progress.dart';
import 'package:social_network/comment_screen.dart';
import 'package:social_network/user.dart';

int getLikeCount(var likes) {

    if (likes == null) return 0;

    // Issue is below
    var _vals = likes.values;
    int _count = 0;
    for (var val in _vals) if (val == true) _count++;
    return _count;
  }

void goToComments({BuildContext context, String postId, String ownerId, String mediaUrl}) {
  Navigator.of(context).push(MaterialPageRoute<bool>(
    builder: (BuildContext context) {
      return CommentScreen(
        postId: postId,
        postOwner: ownerId,
        postMediaUrl: mediaUrl,
      );
    }
  ));
}

class ImagePostFromId extends StatelessWidget {
  final String id;

  const ImagePostFromId({this.id});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder( 
      future: getImagePost(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Container(
            alignment: FractionalOffset.center,
            padding: const EdgeInsets.only(top: 10.0),
            child: CircularLogoProgress()
          );
        return snapshot.data;
      }
    );
  }

  getImagePost() async {
    //var document = await Firestore.instance.collection('insta_posts').document(id).get();
    //return ReportPost.fromDocument(document);
  }
}

class ReportPost extends StatefulWidget {

  // Every report post has
  final String mediaUrl;
  final String username;
  final String description;
  final Map likes;
  final String postId;
  final String ownerId;
  final String city;
  final bool showCity;
  final String neighborhood;
  final bool showNeighborhood;
  final String spot;
  final bool showSpot;
  final int quality;
  final String dayLabel;
  final String timeLabel;

  // Default constructor
  const ReportPost({
    this.mediaUrl,
    this.username,
    this.description,
    this.likes,
    this.postId,
    this.ownerId,
    this.city,
    this.showCity,
    this.neighborhood,
    this.showNeighborhood,
    this.spot,
    this.showSpot,
    this.quality,
    this.dayLabel,
    this.timeLabel,
  });

  // Constructor from document
  /*factory ReportPost.fromDocument(DocumentSnapshot document) {
    return ReportPost(
      mediaUrl: document.data['mediaUrl'],
      username: document.data['username'],
      description: document.data['description'],
      likes: document.data['likes'],
      postId: document.documentID,
      ownerId: document.data['ownerId'],
      city: document.data['city'],
      showCity: document.data['showCity'],
      neighborhood: document.data['neighborhood'],
      showNeighborhood: document.data['showNeighborhood'],
      spot: document.data['spot'],
      showSpot: document.data['showSpot'],
      quality: document.data['quality'],
      dayLabel: document.data['daylabel'],
      timeLabel: document.data['timelabel'],
    );
  }*/

  // Constructor from json
  factory ReportPost.fromJSON(Map data) {
    return ReportPost(
      mediaUrl: data['mediaUrl'],
      username: data['username'],
      description: data['description'],
      likes: data['likes'],
      postId: data['postId'],
      ownerId: data['ownerId'],
      city: data['city'],
      showCity: data['showCity'],
      neighborhood: data['neighborhood'],
      showNeighborhood: data['showNeighborhood'],
      spot: data['spot'],
      showSpot: data['showSpot'],
      quality: data['quality'],
      dayLabel: data['daylabel'],
      timeLabel: data['timelabel'],
    );
  }

  // State constructor
  _ReportPostState createState() => _ReportPostState(
    mediaUrl: this.mediaUrl,
    username: this.username,
    description: this.description,
    likes: this.likes,
    likeCount: getLikeCount(this.likes),
    postId: this.postId,
    postOwnerId: this.ownerId,
    city: this.city,
    showCity: this.showCity,
    neighborhood: this.neighborhood,
    showNeighborhood: this.showNeighborhood,
    spot: this.spot,
    showSpot: this.showSpot,
    quality: this.quality,
    day: this.dayLabel,
    hour: this.timeLabel,
  );

  
}

class _ReportPostState extends State<ReportPost> {
  
  // Every report post has these unchangeable variables:
  final String postOwnerId;
  final String postId;
  final String mediaUrl;
  final String username;

  // And these streamed and changeable variables:
  Map likes;
  String city;
  String day;
  String description;
  String hour;
  String neighborhood;
  String spot;
  int likeCount;
  int quality;
  bool showCity;
  bool showNeighborhood;
  bool showSpot;

  // Also, a report post needs a reference to the report on the database
  Container _loadingPlaceHolder = Container(height: 250.0, child: Center(child: CircularLogoProgress()));

  // And a loadingPlaceHolder while loading the report image
  bool _currentUserLiked;

  // And has these internal flags to colour the heart icon and popup a centered heart when liking
  bool _showHeart = false;
  TextStyle _boldStyle = TextStyle(color: Colors.black, fontWeight: FontWeight.bold);

  // And has a bold style for texts
  TextEditingController _newCityController = TextEditingController();

  // And text editing controllers to change city, neighborhood, spot and description
  TextEditingController _newNeighborhoodController = TextEditingController();
  TextEditingController _newSpotController = TextEditingController();
  TextEditingController _newDescriptionController = TextEditingController();
  _ReportPostState({
    this.postOwnerId,
    this.postId,
    this.mediaUrl,
    this.username, 
    this.description,
    this.likes,
    this.likeCount,
    this.neighborhood,
    this.showNeighborhood,
    this.spot,
    this.showSpot,
    this.city,
    this.showCity,
    this.quality,
    this.day,
    this.hour,
  });

  @override
  Widget build(BuildContext context) {

    Widget _buildDescriptionRow({@required String description}) {
      return Visibility(
        visible: (description != null && description != ''),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            Expanded(
              
              child: Container(
                margin: const EdgeInsets.only(left: 16.0, bottom: 8.0, top: 8.0),
                child: RichText(
                  text: TextSpan(
                    children: <TextSpan> [

                      TextSpan(text: '$username', style: _boldStyle),

                      description != null && description != '' 
                      ? TextSpan(text: ' $description', style: TextStyle(color: Colors.black))
                      : TextSpan(text: ''),

                    ]
                  )
                ),
              ),
            ),

          ],
        ),
      );
    }

    Widget _buildHeaderRow() {

      double _getAvatarRadius() { // Includes username
        
        bool _hasCity = false;
        bool _hasNeighborhood = false;
        bool _hasSpot = false;

        if (this.showCity == true && this.city != null) _hasCity = true;
        if (this.showNeighborhood  == true && this.neighborhood != null) _hasNeighborhood = true;
        if (this.showSpot  == true && this.spot != null) _hasSpot = true;

        if ((_hasCity || _hasNeighborhood)) {
          if (_hasSpot) {
            return 23.0;
          }
        }
        else {
          if (_hasSpot) {
            return 17.0;
          } else {
            return 14.0;
          }
        }

        return 17.0;
      }

      print('[ReportPost] [BuildHeaderRow] START');

      double _avatarRadius = _getAvatarRadius();

      print('[ReportPost] [BuildHeaderRow] $username | $city ($showCity) | $neighborhood ($showNeighborhood) | $spot ($showSpot) | $quality | $description');

      bool _showComma = (neighborhood != null && neighborhood != '' && showNeighborhood == true) && (city != null && city != '' && showCity == true);

      return Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Height adjustment
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Width adjustment
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
        
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                  Container(
                    padding: EdgeInsets.only(left: 8.0, top: 8.0),
                    alignment: Alignment.center,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Row ( // Post owner username
                          children: <Widget>[
                            Container(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(fontSize: 15.0, color: Colors.black),
                                  children: <TextSpan>[
                                    TextSpan(text: '$username', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              )
                            ),
                          ],
                        ),

                        Row ( // Post location
                          children: <Widget>[

                            Visibility( // City
                              visible: (city != null && city != '' && showCity == true),
                              child: Row(
                                children: <Widget>[
                                  Text('$city')
                                ],
                              ),
                            ),

                            Visibility(visible: _showComma, child: Text(', '), ),

                            Visibility( // Neighborhood
                              visible: (this.neighborhood != null && this.neighborhood != '' && showNeighborhood == true),
                              child: Row(
                                children: <Widget>[
                                  Text('$neighborhood')
                                ],
                              ),
                            ),

                          ],
                        ),

                        Visibility( // Spot
                          visible: spot != null && spot != '' && showSpot == true,
                          child: Row(
                            children: <Widget>[
                              Text('$spot'),
                            ],
                          )
                        ),
                            
                      ]
                    ),
                  )
                ],
              ),

              

            ],
          ),

          Column( // Options
            children: <Widget>[
              GestureDetector(
                onTap: () async => await _showOptionsDialog(context),
                child: Container(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(Icons.more_vert, color: Colors.grey[700]),
                ),
              )
            ],
          ),

        ],
      );
    }

    print('[ReportPost] [Build] START');

    // Checks if CurrentUser liked this report
    _currentUserLiked = likes[CurrentUser.instance.id] == true;

    print('[ReportPost] [Build] _currentUserLiked: $_currentUserLiked');

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[

        // Owner avatar, owner username, city, neighborhood, spot and options
        _buildHeaderRow(),

        // Report
        _buildLikeableCard(quality: this.quality),

        // Daylabel, timelabel, likes, heart, balloon and send
        _buildHeartAndBalloonRow(day: this.day, hour: this.hour, likes: this.likes, likeCount: this.likeCount, currentUserLiked: _currentUserLiked),

        // Username and description
        _buildDescriptionRow(description: this.description),

      ],
    );
  }

  

  

  Widget _buildHeartAndBalloonRow({@required String day, @required String hour, @required Map likes, @required int likeCount, @required bool currentUserLiked}) {

    Color _heartColor;
    IconData _heartIcon;

    if (currentUserLiked) {
      _heartColor = Colors.pink;
      _heartIcon = FontAwesomeIcons.solidHeart;
    } else {
      _heartIcon = FontAwesomeIcons.heart;
    }

    return Container(
      padding: EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[

          Column( // Day and hour
            children: <Widget>[

              Row(
                children: <Widget>[
                  
                  Container( // Day
                    height: 30.0,
                    padding: EdgeInsets.only(left: 8.0, right: 8.0),
                    margin: EdgeInsets.only(left: 0.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: InkWell(
                      child: Center(
                        child: Text('$day',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ),
                  ),

                  Container( // Hour
                    height: 30.0,
                    padding: EdgeInsets.only(left: 8.0, right: 8.0),
                    margin: EdgeInsets.only(left: 4.0, right: 0.0,),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: InkWell(
                      child: Center(
                        child: Text('$hour',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ),
                  ),
                ],
              ), 

            ],
          ),

          Column( // Known likes avatars and like count
            children: <Widget>[

              Row(
                children: <Widget>[

                  // Known likes avatars
                  Visibility(
                    visible: likeCount > 2,
                    child: Stack(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(left: 32),
                          child: CircleAvatar(
                            backgroundColor: Colors.grey, radius: 12,
                            backgroundImage: null,),),
                        Container(
                          padding: EdgeInsets.only(left: 16),
                          child: CircleAvatar(
                            backgroundColor: Colors.purpleAccent, radius: 12,
                            backgroundImage: null,),),
                        Container(
                          padding: EdgeInsets.only(left: 0),
                          child: CircleAvatar(
                            backgroundColor: Colors.indigo, radius: 12,
                            backgroundImage: null,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Like count
                  Container(
                    margin: const EdgeInsets.only(left: 8.0),
                    child: likeCount != 1 ? Text("$likeCount curtidas",style: _boldStyle,) : Text("$likeCount curtida",style: _boldStyle,),
                  ),
                ],
              ),

              
            ],
          ),

          Column( // Heart and balloon
            children: <Widget>[
              Row(
                children: <Widget>[
      
                  GestureDetector( // Heart
                    onTap: () => _toggleLike(),
                    child: Stack(
                      children: <Widget>[
                        Icon(_heartIcon, 
                          size: 25.0, 
                          color: _heartColor
                        ),
                        Icon(FontAwesomeIcons.heart, 
                          size: 25.0, 
                        ),
                      ],
                    ),
                    
                            
                  ),

                  GestureDetector( // Balloon
                    onTap: () => goToComments(context: context, postId: postId, ownerId: postOwnerId, mediaUrl: mediaUrl),
                    child: Container(padding: EdgeInsets.only(left:8.0), child: const Icon(FontAwesomeIcons.comment, size: 25.0)),
                    
                  ),

                  GestureDetector( // Send
                    child: Container(padding: EdgeInsets.only(left:4.0), child: const Icon(Icons.arrow_forward_ios, size: 22.0)),
                    onTap: () => goToComments(context: context, postId: postId, ownerId: postOwnerId, mediaUrl: mediaUrl)
                  ),

                ],
              )
            ],
          ),

        ],
      ),
    );
  }

  Widget _buildLikeableCard({@required int quality}) {

    Color _cardColor = Colors.grey[600];

    if (quality == 0.0) {
      _cardColor = Colors.red[700];
    }
    else if (quality == 1.0) {
      _cardColor = Colors.orange[700];
    }
    else if (quality == 2.0) {
      _cardColor = Colors.green[700];
    }
    else {
      _cardColor = Colors.green[700];
    }

    return GestureDetector(
      onDoubleTap: () => _toggleLike(),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[

          // FadeInImage.memoryNetwork(placeholder: kTransparentImage, image: mediaUrl),

          this.quality == 3 
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
                          child: 
                            CachedNetworkImage(imageUrl: mediaUrl, placeholder: _loadingPlaceHolder, errorWidget: Icon(Icons.error),)
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
                        child: 
                          CachedNetworkImage(imageUrl: mediaUrl, placeholder: _loadingPlaceHolder, errorWidget: Icon(Icons.error),)
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
                    child: 
                      CachedNetworkImage(imageUrl: mediaUrl, placeholder: _loadingPlaceHolder, errorWidget: Icon(Icons.error),)
                  )
                ],
              ),
            ),
          ),

          _showHeart
          ? Positioned(
            child: Opacity(
              opacity: 0.75,
              child: Icon(
                FontAwesomeIcons.solidHeart,
                size: 80.0,
                color: Colors.pink
              )
            )
          )
          : Container(),
          
        ],
      ),
    ); 
  } 

  // Should be turned into a stateful widget to make checkbox changeable
    Future<void> _showOptionsDialog(BuildContext context) async {

      Future<void> _showEditDescriptionDialog(BuildContext context) async {

        void _editDescription(String newDescription) {

          String _currentDescription = this.description;

          // Check if changes were made
          if (newDescription != _currentDescription) {

            // Edit on UI
            setState(() => this.description = newDescription); 
          } 
        }
      
        return showDialog(
          context: context,
          barrierDismissible: true,

          builder: (BuildContext context) {      
            return Dialog(
              child: Container(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[             
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Descrição',
                        hintText: 'Meio metro com séries maiores',
                        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13)
                      ),
                      controller: _newDescriptionController,
                    ),
                    FlatButton(
                      child: Text("Salvar"),
                      onPressed: (){
                        _editDescription(_newDescriptionController.text);
                        Navigator.pop(context);
                      },
                    )
                  ]
                ),
              )
            );
          }
        );
      }

      Future<void> _showEditCityDialog(BuildContext context) async {
        
        void _editCity(String newCity) {

          String _currentCity = this.city;

          // Check if changes were made
          if (newCity != _currentCity) {

            // Edit on UI
            setState(() => this.city = newCity); 
          } 
        }

        return showDialog(
          context: context,
          barrierDismissible: true,

          builder: (BuildContext context) {      
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16.0))),
              child: Container(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[             
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Cidade',
                        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13)
                      ),
                      controller: _newCityController,
                    ),
                    FlatButton(
                      child: Text("Salvar"),
                      onPressed: (){
                        _editCity(_newCityController.text);
                        Navigator.pop(context);
                      },
                    )
                  ]
                ),
              )
            );
          }
        );
      }

      Future<void> _showEditNeighborhoodDialog(BuildContext context) async {
        
        void _editNeighborhood(String newNeighborhood) {

          String _currentNeighborhood = this.neighborhood;

          // Check if changes were made
          if (newNeighborhood != _currentNeighborhood) {

            // Edit on UI
            setState(() => this.neighborhood = newNeighborhood); 
          } 
        }

        return showDialog(
          context: context,
          barrierDismissible: true,

          builder: (BuildContext context) {      
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16.0))),
              child: Container(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[             
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Bairro',
                        hintText: "",
                        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13)
                      ),
                      controller: _newNeighborhoodController,
                    ),
                    FlatButton(
                      child: Text("Salvar"),
                      onPressed: (){
                        _editNeighborhood(_newNeighborhoodController.text);
                        Navigator.pop(context);
                      },
                    )
                  ]
                ),
              )
            );
          }
        );
      }
      
      Future<void> _showEditSpotDialog(BuildContext context) async {
      
        void _editSpot(String newSpot) {

          String _currentSpot = this.spot;

          // Check if changes were made
          if (newSpot != _currentSpot) {

            // Edit on UI
            setState(() => this.spot = newSpot); 
          } 
        }

        return showDialog(
          context: context,
          barrierDismissible: true,

          builder: (BuildContext context) {      
            return Dialog(
              child: Container(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[             
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Pico',
                        hintText: "",
                        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13)
                      ),
                      controller: _newSpotController,
                    ),
                    FlatButton(
                      child: Text("Salvar"),
                      onPressed: () {
                        _editSpot(_newSpotController.text);
                        Navigator.pop(context);
                      },
                    )
                  ]
                ),
              )
            );
          }
        );
      }

      return showDialog<Null>(
        context: context,
        barrierDismissible: true,

        builder: (BuildContext context) {

          void _toggleCity() {

            bool _showCity = this.showCity;

            _showCity == true 
            ? print('[ReportPost] [ToggleCity] hiding')
            : print('[ReportPost] [ToggleCity] showing');

            // Toggle on UI
            setState(() => this.showCity = !_showCity);  
          }

          void _toggleNeighborhood() {

            bool _showNeighborhood = this.showNeighborhood;

            _showNeighborhood == true 
            ? print('[ReportPost] [ToggleNeighborhood] hiding')
            : print('[ReportPost] [ToggleNeighborhood] showing');

            // Toggle on UI
            setState(() => this.showNeighborhood = !_showNeighborhood);  
          }
          
          void _toggleSpot() {

            bool _showSpot = this.showSpot;

            _showSpot == true 
            ? print('[ReportPost] [ToggleSpot] hiding')
            : print('[ReportPost] [ToggleSpot] showing');

            // Toggle on UI
            setState(() => this.showSpot = !_showSpot);  
          }

          double _containerHeight = 32.0;
          TextStyle _textStyle = TextStyle(fontSize: 20.0);

          return SimpleDialog(
            contentPadding: EdgeInsets.all(8.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16.0))),
            title: Container(padding: EdgeInsets.only(bottom: 8.0),alignment: FractionalOffset.center, child:Text('Definições', style: TextStyle(fontSize: 24.0))),
            children: <Widget>[

              Divider(height: 0.0,),

              SimpleDialogOption( // Edit city and show city checkbox
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[

                  Container(
                    width: 150,
                    alignment: FractionalOffset.center,
                    height: _containerHeight, child: Text('Editar cidade', style: _textStyle)),

                  Container(
                    width: 50,
                    alignment: FractionalOffset.center,
                    height: _containerHeight, child: Checkbox(value: this.showCity, onChanged: (boolean) {
                      setState(() => this.showCity = boolean);
                    })),
                ],
              ),
                onPressed: () => _showEditCityDialog(context),
              ),

              Divider(height: 0.0,),

              SimpleDialogOption( // Edit neighborhood and show neighborhood checkbox
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[

                  Container(
                    width: 150,
                    alignment: FractionalOffset.center,
                    height: _containerHeight, child: Text('Editar bairro', style: _textStyle),),

                  Container(
                    width: 50,
                    alignment: FractionalOffset.center,
                    height: _containerHeight, child: Checkbox(value: this.showNeighborhood, onChanged: (boolean) {
                      setState(() => this.showNeighborhood = boolean);
                    })),
                ],
              ),
                onPressed: () => _showEditNeighborhoodDialog(context),
              ),

              Divider(height: 0.0,),

              SimpleDialogOption( // Edit spot and show spot checkbox
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[

                  Container(
                    width: 150,
                    alignment: FractionalOffset.center,
                    height: _containerHeight, child: Text('Editar pico', style: _textStyle),),

                  Container(
                    width: 50,
                    alignment: FractionalOffset.center,
                    height: _containerHeight, child: Checkbox(value: this.showSpot, onChanged: (boolean) {
                      setState(() => this.showSpot = boolean);
                    })),
                ],
              ),
                onPressed: () => _showEditSpotDialog(context),
              ),

              Divider(height: 0.0,),

              SimpleDialogOption( // Edit description
              child: Container(
                alignment: FractionalOffset.center,
                height: _containerHeight, child: Text('Editar descrição', style: _textStyle),),
                onPressed: () => _showEditDescriptionDialog(context),
              ),

              Divider(height: 0.0,),

              SimpleDialogOption( // Delete report
                child: Container(
                  padding: EdgeInsets.only(top: 8.0),
                  alignment: FractionalOffset.center,
                  height: _containerHeight, 
                  child: Text('Excluir report', style: TextStyle(fontSize: 20.0, color: Colors.red))),
                onPressed: () {
                  CurrentUser.instance.getAndSetReportsFeed().then((_) {
                    print('[ReportPost] [ShowDialogOptions] [DeleteReport] (FUTURE) setReportsFeed DONE');
                    
                  });
                  Navigator.pop(context);
                },
              ),

            ],
          );
        },
      );
    }

  void _toggleLike() {

    bool _liked = likes[CurrentUser.instance.id] == true;

    if (_liked) {
      print('[ReportPost] [ToggleLike] disliking');

      setState(() {
        likeCount = likeCount - 1;
        _currentUserLiked = false;
        likes[CurrentUser.instance.id] = false;
      });
    }

    if (!_liked) {
      print('[ReportPost] [ToggleLike] liking');

      setState(() {
        likeCount = likeCount + 1;
        _currentUserLiked = true;
        likes[CurrentUser.instance.id] = true;
        _showHeart = true;
      });
      
      Timer(const Duration(milliseconds: 500), () { 
        setState(() => _showHeart = false);
      });
    }
  }
}