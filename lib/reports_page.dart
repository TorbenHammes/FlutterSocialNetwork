import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_network/activity_feed.dart';
import 'package:social_network/circular_logo_progress.dart';
import 'package:social_network/profile_page.dart';
import 'package:social_network/report_post.dart';
import 'package:social_network/search_page.dart';
import 'package:social_network/user.dart';

class ReportsPage extends StatefulWidget {
  PageController pageController;
  ReportsPage({this.pageController});
  _ReportsPage createState() => _ReportsPage();
}

class _ReportsPage extends State<ReportsPage> with AutomaticKeepAliveClientMixin<ReportsPage> {

  List<ReportPost> _feedData;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Reloads state when opened again

    return Scaffold(
      backgroundColor: Colors.blue[100],
      drawer: _buildDrawer(),
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _buildListViewFeed(),
      ),
    );
  }

  @override
  void initState() {
    print('[ReportsPage] [InitState] START');
    super.initState();
    print('[ReportsPage] [InitState] DONE');
  }

  Widget _buildAppBar() {
    return AppBar(
      centerTitle: false,
      backgroundColor: Colors.blue[900],
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () { Scaffold.of(context).openDrawer(); },
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip);}),
      title: const Text('WaveCheck',
        style: const TextStyle(
          fontFamily: "Raustila-Regular", color: Colors.white, fontSize: 35.0,
          shadows: [
            Shadow(offset: Offset(-1.0, -1.0), color: Colors.black),
            Shadow(offset: Offset(1.0, -1.0), color: Colors.black),
            Shadow(offset: Offset(1.0, 1.0), color: Colors.black),
            Shadow(offset: Offset(-1.0, 1.0), color: Colors.black)])),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.search, color: Colors.white),
          onPressed: () { Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => SearchPage())); }
        ),
        IconButton(
          icon: Icon(Icons.filter_list, color: Colors.white),
          onPressed: () { Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => SearchPage())); }
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        children: <Widget>[

          DrawerHeader(
            decoration: BoxDecoration(color: Colors.orange[400]),
            
            // Outer column with 2 rows
            child: Column(
              children: <Widget>[

                // First row with username
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: <Widget>[

                    Container( // Username
                      margin: EdgeInsets.only(bottom: 10.0), 
                      child: Text('${CurrentUser.instance.username}',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18.0),)
                    ),

                    Container(
                      margin: EdgeInsets.only(bottom: 10.0),
                      color: Colors.red,
                      child: Text('Haole', style: TextStyle(fontSize: 16.0),),
                    )
                  ]
                ),

                // Second row with avatar and etc
                Row(
                  children: <Widget>[

                    Container( // Avatar
                      alignment: FractionalOffset.center, 
                      child: CircularProfileAvatar(
                        imageUrl: CurrentUser.instance.photoUrl,
                        radius: 50.0,             
                        backgroundColor: Colors.transparent,
                        borderWidth: 1,
                        borderColor: Colors.black,
                        elevation: 5.0,
                        cacheImage: false,
                        onTap: () {},
                        initialsText: Text(CurrentUser.instance.displayName != null ? CurrentUser.instance.displayName[0].toUpperCase() : '',
                          style: TextStyle(fontSize: 40, color: Colors.white)
                        ),
                      ),
                    ),

                  ],
                ),
              ],
            ),
            
          ),

          ListTile(
            leading: Icon(Icons.person),
            title: Text('Meu perfil'),
            onTap: () { Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ProfilePage(userId: CurrentUser.instance.id))); }
          ),

          Divider(height: 10.0,),

          ListTile(
            leading: Icon(Icons.star_half),
            title: Text('Novidades'),
            onTap: () { Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ActivityFeedPage())); }
          ),

          Divider(height: 10.0,),

          ListTile(
            leading: Icon(Icons.chat_bubble),
            title: Text('Chat privado'),
            onTap: () { /* Navigator.push(context, MaterialPageRoute(builder: (ctxt) => SecondPage()));*/ },
          ),

          Divider(height: 10.0,),

          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text('Surf shop'),
            onTap: () { /* Navigator.push(context, MaterialPageRoute(builder: (ctxt) => SecondPage()));*/ },
          ),

          Divider(height: 10.0,),

          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Configurações'),
            onTap: () { /* Navigator.push(context, MaterialPageRoute(builder: (ctxt) => SecondPage()));*/ },
          ),

          Divider(height: 10.0,),

          ListTile(
            leading: Icon(Icons.cancel),
            title: Text('Sair'),
            onTap: () { 
              CurrentUser.instance.signOut();
              //Navigator.push(context, MaterialPageRoute(builder: (ctxt) => SecondPage()));
            },
          ),
          
        ],
      )
    );
  }

  Widget _buildListViewFeed() {
    if (CurrentUser.instance.reportsFeed != null) {
      return ListView(
        children: CurrentUser.instance.reportsFeed,
      );
    }
    else {
      CurrentUser.instance.getAndSetReportsFeed().then((onValue) {
        setState((){});
      });
      return Container(
        alignment: FractionalOffset.center,
        child: CircularLogoProgress()
      );
    }
  }

  Future<void> _getReportsFeed() async {
    print('[ReportsPage] [GetReportsFeed] START');

    SharedPreferences _sharedPrefs = await SharedPreferences.getInstance();
    String _url = 'https://us-central1-wavecheck-18d58.cloudfunctions.net/getFeed?uid=' + CurrentUser.instance.id;
    HttpClient _httpClient = HttpClient();
    List<ReportPost> _reportsList = [];
    HttpClientRequest _request;
    HttpClientResponse _response;

    if (CurrentUser.instance.id != '' && CurrentUser.instance.id != null) {

      try {
        _request = await _httpClient.getUrl(Uri.parse(_url));
      } catch (exception) { print('[ReportsPage] [GetReportsFeed] ERROR opening http connection. Exception: $exception'); }

      try {
        _response = await _request.close();
      } catch (exception) { print('[ReportsPage] [GetReportsFeed] ERROR closing request. Exception: $exception'); }

      if (_response != null) {
        if (_response.statusCode == HttpStatus.ok) {
          String _jsonFeed = await _response.transform(utf8.decoder).join();
          _sharedPrefs.setString("feed", _jsonFeed);
          List<Map<String, dynamic>> _listMapFeed = jsonDecode(_jsonFeed).cast<Map<String, dynamic>>();      
          for (var postData in _listMapFeed) // Generate feed
            _reportsList.add(ReportPost.fromJSON(postData));
        } else { print('[ReportsPage] [GetReportsFeed] _response.statusCode != HttpStatus.ok'); }
      } else { print('[ReportsPage] [GetReportsFeed] _response == null'); }
      
        
      if (_reportsList != null) setState(() => _feedData = _reportsList.reversed.toList());
      else setState(() {});
    }

    print('[ReportsPage] [GetReportsFeed] DONE');
  }

  Future<void> _loadReportsFeed() async {

    print('[ReportsPage] [LoadReportsFeed] START');

    // Shared preferences
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    // Feed saved
    String _feedSavedJson = _prefs.getString("feed");
    
    print('[ReportsPage] [LoadReportsFeed] _feedSavedJson: $_feedSavedJson');

    // If has feed saved
    if (_feedSavedJson != null) {
      if (_feedSavedJson.isNotEmpty) {
        List<Map<String, dynamic>> _data = jsonDecode(_feedSavedJson).cast<Map<String, dynamic>>();
        List<ReportPost> _listOfPosts = [];
        for (var postData in _data) // Generate feed
          _listOfPosts.add(ReportPost.fromJSON(postData));
        setState(() {
          _feedData = _listOfPosts.reversed.toList();
        });
      }
    }
    
    // If dont have feed saved
    else {
      await _getReportsFeed();
    }
  }

  Future<Null> _refresh() async {
    await CurrentUser.instance.getAndSetReportsFeed();
    print('[ReportsPage] [Refresh] (FUTURE) setReportsFeed DONE');
    setState(() {});
    return;
  }
}
