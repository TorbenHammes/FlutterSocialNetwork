import 'dart:convert';
import 'dart:math';

import 'package:geocoder/geocoder.dart';
import 'package:meta/meta.dart';
import 'package:social_network/report_post.dart';

class CurrentUser {
  
  // Singleton
  static CurrentUser instance;
  
  // The CurrentUser has:
  String email;
  String id;
  String photoUrl;
  String username;
  String displayName;
  String bio;
  Map followers;
  Map following;
  Address address;
  List<ReportPost> reportsFeed;

  CurrentUser({
    this.username,
    this.id,
    this.photoUrl,
    this.email,
    this.displayName,
    this.bio,
    this.followers,
    this.following,
    this.address,
    this.reportsFeed,
  });

  factory CurrentUser._singletonConstructor({String jsonUserData, Address userLocation}) {

    // Creates from json string
    if (jsonUserData != null && jsonUserData != '') {
      print('[CurrentUser] [Constructor] jsonString != null');
      print('[CurrentUser] [Constructor] creating from jsonString');

      List<dynamic> _userData = jsonDecode(jsonUserData);

      print('[CurrentUser] [Constructor] _userData[0][\'username\']: ${_userData[0]['username']}');

      return CurrentUser(
        bio: '',
        displayName: _userData[0]['displayName'],
        username: _userData[0]['displayName'].replaceAll(RegExp(r"\s+\b|\b\s"), "").toLowerCase().trim() + Random().nextInt(1000000).toString(),
        id: _userData[0]['uid'],
        photoUrl: _userData[0]['photoUrl'],
        followers: {},
        following: {_userData[0]['uid']:true},
        address: userLocation      
      );
    }

    // Unreacheable code
    return CurrentUser(
        bio: 'bio',
        displayName: 'displayName',
        username: 'username',
        id: 'userId',
        photoUrl: 'https://cdn3.volusion.com/h35fd.rs5p2/v/vspfiles/photos/CA70533-2T.jpg?1332441817',
        followers: {},
        following: {'userId': true},
        address: userLocation
      );
  }

  static signInWithGoogle({bool silently = false, @required Address userLocation}) async {

    print('[CurrentUser] [SignInWithGoogle] START');

    /*CurrentUser({
      this.username,
      this.id,
      this.photoUrl,
      this.email,
      this.displayName,
      this.bio,
      this.followers,
      this.following,
      this.address,
      this.reportsFeed,
    });*/

    final String jsonRegisteredUsers = "[" + 

      "{" + // First user registered (the signed CurrentUser)
      "\"username\":\"gustavocontreiras1420397\"," +
      "\"uid\":\"01\"," +
      "\"photoUrl\":\"https://lh3.googleusercontent.com/-ifrcnHkRWqI/AAAAAAAAAAI/AAAAAAAAKWQ/FNv-yby2T9U/s96-c/photo.jpg\"," +
      "\"email\":\"guto.contreiras@gmail.com\"," +
      "\"displayName\":\"Gustavo Contreiras\"," +
      "\"bio\":\"Aluno da PUC-Rio\"" +
      "}," + 

      "{" + // Second user registered
      "\"displayName\":\"Markus Endler\"," +
      "\"email\":\"markus.endler@gmail.com\"," +
      "\"photoUrl\":\"http://www-di.inf.puc-rio.br/~endler/images/Endler-2013.jpg\"," +
      "\"uid\":\"02\"" +
      "}," + 

      "{" + // Third user registered
      "\"displayName\":\"Felipe Carvalho\"," +
      "\"email\":\"felipe.carvalho@gmail.com\"," +
      "\"photoUrl\":\"https://www.w3schools.com/howto/img_avatar.png\"," +
      "\"uid\":\"03\"" +
      "}," +

      "{" + // 04
      "\"displayName\":\"Gabriel Medina\"," +
      "\"email\":\"gabriel.medina@gmail.com\"," +
      "\"photoUrl\":\"https://cdn-istoe-ssl.akamaized.net/wp-content/uploads/sites/14/2016/01/mi_25753405129444161.jpg\"," +
      "\"uid\":\"04\"" +
      "}," +

      "{" + // 05
      "\"displayName\":\"Filipe Toledo\"," +
      "\"email\":\"filipe.toledo@gmail.com\"," +
      "\"photoUrl\":\"http://www.jornaldebrasilia.com.br/wp-content/uploads/2019/04/felipe-toledo-e1556197362159.jpg\"," +
      "\"uid\":\"05\"" +
      "}," +

      "{" + // 06
      "\"displayName\":\"Ítalo Ferreira\"," +
      "\"email\":\"italo.ferreira@gmail.com\"," +
      "\"photoUrl\":\"http://arquivos.tribunadonorte.com.br/fotos/209964.jpg\"," +
      "\"uid\":\"06\"" +
      "}," +

      "{" + // 07
      "\"displayName\":\"Mineirinho\"," +
      "\"email\":\"mineirinho@gmail.com\"," +
      "\"photoUrl\":\"https://static1.purebreak.com.br/articles/8/18/16/8/@/91080-adriano-de-souza-o-mineirinho-e-o-620x0-3.png\"," +
      "\"uid\":\"07\"" +
      "}," +

      "{" + // 08
      "\"displayName\":\"Jesse Mendes\"," +
      "\"email\":\"jesse.mendes@gmail.com\"," +
      "\"photoUrl\":\"https://s3.glbimg.com/v1/AUTH_e23cd0767cb84b2c865c204683cba493/articles/foto_poullenot-aquashot.jpg\"," +
      "\"uid\":\"08\"" +
      "}," +

      "{" + // 09
      "\"displayName\":\"Fulano\"," +
      "\"email\":\"fulano@gmail.com\"," +
      "\"photoUrl\":\"https://www.w3schools.com/w3images/avatar2.png\"," +
      "\"uid\":\"09\"" +
      "}," +

      "{" + // 10
      "\"displayName\":\"Beltrano\"," +
      "\"email\":\"beltrano@gmail.com\"," +
      "\"photoUrl\":\"https://www.w3schools.com/howto/img_avatar.png\"," +
      "\"uid\":\"10\"" +
      "}," +

      "{" + // 11
      "\"displayName\":\"Ciclano\"," +
      "\"email\":\"ciclano@gmail.com\"," +
      "\"photoUrl\":\"https://www.w3schools.com/w3images/avatar2.png\"," +
      "\"uid\":\"11\"" +
      "}" +

    "]";

    await Future.delayed(Duration(milliseconds: 4000));
    
    CurrentUser.instance = CurrentUser._singletonConstructor(jsonUserData: jsonRegisteredUsers);
  
    print('[CurrentUser] [SignInWithGoogle] DONE');
  }

  void signOut() {}

  Future<void> getAndSetReportsFeed() async {
    print('[CurrentUser] [SetReportsFeed] START');

    List<ReportPost> _reportsFeed = [];

    String _jsonReportsFeed = "[" + 

      "{" + // First report
        '''
        "countryCode":"BR",
        "countryName":"Brasil",
        "city":"Rio de Janeiro",
        "street":"Av. Vieira Souto",
        "daylabel":"HOJE",
        "deleted":false,
        "description":"Sequência pontão do Leblon Fotógrafo @zerodoiszoom #soulbodysurf #leblonbeach #pontaodoleblon #leblonfins #waves #riosurfcheck #surfconnect #bodysurfer #bodysurfing #ocean #rioacademianatural #waveslideculture",
        "latitude":"-22.993363499999997",
        "longitude":"-43.2550519",
        "likes":{
          "01":true,
          "02":true
        },
        "mediaUrl":"https://instagram.fsdu5-1.fna.fbcdn.net/vp/9622d5e9c1c7bf5986209fa0d2bc80ad/5D56D1FE/t51.2885-15/e35/57434245_1014683135402422_3225583039206733224_n.jpg?_nc_ht=instagram.fsdu5-1.fna.fbcdn.net",
        "neighborhood":"São Conrado",
        "number":"40",
        "ownerId":"117644910200781115007",
        "postId":"-LdWFPAeUvJ6jMkhTq5Y",
        "quality":2,
        "state":"Rio de Janeiro",
        "spot":"Posto 12",
        "showCity":true,
        "showNeighborhood":true,
        "showSpot":true,
        "username":"gustavocontreiras1420397",
        "timelabel":"09h04",
        "timestamp":"2019-04-27 09:04:12.645766"
        ''' +
      "}," +

      "{" + // Second report
        '''
        "countryCode":"BR",
        "countryName":"Brasil",
        "city":"Rio de Janeiro",
        "street":"Av. Vieira Souto",
        "daylabel":"ONTEM",
        "deleted":false,
        "description":"Aquele domingo de surf que tem onda boa, mas tem vaca também Hauahauah",
        "latitude":"-22.993363499999997",
        "longitude":"-43.2550519",
        "likes":{
          "01":true,
          "02":true
        },
        "mediaUrl":"https://instagram.fsdu5-1.fna.fbcdn.net/vp/057b793b38e665019a4b890f4ee66cf7/5D75166A/t51.2885-15/e35/56927487_594607004353516_3629591792309381778_n.jpg?_nc_ht=instagram.fsdu5-1.fna.fbcdn.net",
        "neighborhood":"São Conrado",
        "number":"40",
        "ownerId":"117644910200781115007",
        "postId":"-LdWFPAeUvJ6jMkhTq5Y",
        "quality":2,
        "state":"Rio de Janeiro",
        "spot":"Grumari",
        "showCity":true,
        "showNeighborhood":true,
        "showSpot":true,
        "username":"surfgirl123",
        "timelabel":"10h00",
        "timestamp":"2019-04-27 09:04:12.645766"
        ''' +
      "}," +

      "{" + // Third report
        '''
        "countryCode":"BR",
        "countryName":"Brasil",
        "city":"Rio de Janeiro",
        "street":"Av. Vieira Souto",
        "daylabel":"HOJE",
        "deleted":false,
        "description":"Tem umas ondas!",
        "latitude":"-22.993363499999997",
        "longitude":"-43.2550519",
        "likes":{
          "01":true,
          "02":true
        },
        "mediaUrl":"https://firebasestorage.googleapis.com/v0/b/wavecheck-18d58.appspot.com/o/post_24aedf00-5970-11e9-de03-0d3a48bcfb5e.jpg?alt=media&token=a0e1319a-a1b5-4857-a544-df36a7cd481e",
        "neighborhood":"São Conrado",
        "number":"40",
        "ownerId":"117644910200781115007",
        "postId":"-LdWFPAeUvJ6jMkhTq5Y",
        "quality":2,
        "state":"Rio de Janeiro",
        "spot":"Posto 12",
        "showCity":true,
        "showNeighborhood":true,
        "showSpot":true,
        "username":"gustavocontreiras1420397",
        "timelabel":"09h04",
        "timestamp":"2019-04-27 09:04:12.645766"
        ''' +
      "}," +

      "{" + // 04
        '''
        "countryCode":"BR",
        "countryName":"Brasil",
        "city":"Rio de Janeiro",
        "street":"Av. Vieira Souto",
        "daylabel":"HOJE",
        "deleted":false,
        "description":"Tem umas ondas!",
        "latitude":"-22.993363499999997",
        "longitude":"-43.2550519",
        "likes":{
          "01":true,
          "02":true
        },
        "mediaUrl":"https://firebasestorage.googleapis.com/v0/b/wavecheck-18d58.appspot.com/o/post_24aedf00-5970-11e9-de03-0d3a48bcfb5e.jpg?alt=media&token=a0e1319a-a1b5-4857-a544-df36a7cd481e",
        "neighborhood":"São Conrado",
        "number":"40",
        "ownerId":"117644910200781115007",
        "postId":"-LdWFPAeUvJ6jMkhTq5Y",
        "quality":2,
        "state":"Rio de Janeiro",
        "spot":"Posto 12",
        "showCity":true,
        "showNeighborhood":true,
        "showSpot":true,
        "username":"gustavocontreiras1420397",
        "timelabel":"09h04",
        "timestamp":"2019-04-27 09:04:12.645766"
        ''' +
      "}," +

      "{" + // 05
        '''
        "countryCode":"BR",
        "countryName":"Brasil",
        "city":"Rio de Janeiro",
        "street":"Av. Vieira Souto",
        "daylabel":"HOJE",
        "deleted":false,
        "description":"Tem umas ondas!",
        "latitude":"-22.993363499999997",
        "longitude":"-43.2550519",
        "likes":{
          "01":true,
          "02":true
        },
        "mediaUrl":"https://firebasestorage.googleapis.com/v0/b/wavecheck-18d58.appspot.com/o/post_24aedf00-5970-11e9-de03-0d3a48bcfb5e.jpg?alt=media&token=a0e1319a-a1b5-4857-a544-df36a7cd481e",
        "neighborhood":"São Conrado",
        "number":"40",
        "ownerId":"117644910200781115007",
        "postId":"-LdWFPAeUvJ6jMkhTq5Y",
        "quality":2,
        "state":"Rio de Janeiro",
        "spot":"Posto 12",
        "showCity":true,
        "showNeighborhood":true,
        "showSpot":true,
        "username":"gustavocontreiras1420397",
        "timelabel":"09h04",
        "timestamp":"2019-04-27 09:04:12.645766"
        ''' +
      "}," +

      "{" + // 06
        '''
        "countryCode":"BR",
        "countryName":"Brasil",
        "city":"Rio de Janeiro",
        "street":"Av. Vieira Souto",
        "daylabel":"HOJE",
        "deleted":false,
        "description":"Tem umas ondas!",
        "latitude":"-22.993363499999997",
        "longitude":"-43.2550519",
        "likes":{
          "01":true,
          "02":true
        },
        "mediaUrl":"https://firebasestorage.googleapis.com/v0/b/wavecheck-18d58.appspot.com/o/post_24aedf00-5970-11e9-de03-0d3a48bcfb5e.jpg?alt=media&token=a0e1319a-a1b5-4857-a544-df36a7cd481e",
        "neighborhood":"São Conrado",
        "number":"40",
        "ownerId":"117644910200781115007",
        "postId":"-LdWFPAeUvJ6jMkhTq5Y",
        "quality":2,
        "state":"Rio de Janeiro",
        "spot":"Posto 12",
        "showCity":true,
        "showNeighborhood":true,
        "showSpot":true,
        "username":"gustavocontreiras1420397",
        "timelabel":"09h04",
        "timestamp":"2019-04-27 09:04:12.645766"
        ''' +
      "}," +

      "{" + // 07
        '''
        "countryCode":"BR",
        "countryName":"Brasil",
        "city":"Rio de Janeiro",
        "street":"Av. Vieira Souto",
        "daylabel":"HOJE",
        "deleted":false,
        "description":"Tem umas ondas!",
        "latitude":"-22.993363499999997",
        "longitude":"-43.2550519",
        "likes":{
          "01":true,
          "02":true
        },
        "mediaUrl":"https://firebasestorage.googleapis.com/v0/b/wavecheck-18d58.appspot.com/o/post_24aedf00-5970-11e9-de03-0d3a48bcfb5e.jpg?alt=media&token=a0e1319a-a1b5-4857-a544-df36a7cd481e",
        "neighborhood":"São Conrado",
        "number":"40",
        "ownerId":"117644910200781115007",
        "postId":"-LdWFPAeUvJ6jMkhTq5Y",
        "quality":2,
        "state":"Rio de Janeiro",
        "spot":"Posto 12",
        "showCity":true,
        "showNeighborhood":true,
        "showSpot":true,
        "username":"gustavocontreiras1420397",
        "timelabel":"09h04",
        "timestamp":"2019-04-27 09:04:12.645766"
        ''' +
      "}" +
      
    "]";

    List<Map<String, dynamic>> _reportsFeedMap = jsonDecode(_jsonReportsFeed).cast<Map<String, dynamic>>();

    for (var _report in _reportsFeedMap) {
       _reportsFeed.add(
        ReportPost(
          city: _report['city'], 
          dayLabel: _report['daylabel'], 
          description: _report['description'], 
          likes: {}, 
          mediaUrl: _report['mediaUrl'],
          neighborhood: _report['neighborhood'], 
          ownerId: _report['ownerId'],   
          postId: _report['postId'], 
          quality: _report['quality'], 
          spot: _report['spot'],  
          showCity: _report['showCity'],  
          showNeighborhood: _report['showNeighborhood'], 
          showSpot: _report['showSpot'], 
          timeLabel: _report['timelabel'],  
          username: _report['username']
        )
      );
    }

    CurrentUser.instance.reportsFeed = _reportsFeed.toList();
    print('[CurrentUser] [SetReportsFeed] DONE');
  }
}

class User {

  final String email;
  final String id;
  final String photoUrl;
  final String username;
  final String displayName;
  final String bio;
  final Map followers;
  final Map following;
  
  const User({
    this.username,
    this.id,
    this.photoUrl,
    this.email,
    this.displayName,
    this.bio,
    this.followers,
    this.following,
  });

  /// Used to load other users
  /*factory User.loadFromDocument(DocumentSnapshot document) {
    //print ('[User] [Constructor] [LoadFromDocument] document.data: ${document.data}');
    return User(
      email: document.data['email'],
      username: document.data['username'],
      photoUrl: document.data['photoURL'],
      id: document.documentID,
      displayName: document.data['displayName'],
      bio: document.data['bio'] == null ? '' : document.data['bio'],
      followers: document.data['followers'],
      following: document.data['following'],
    );
  }*/
}