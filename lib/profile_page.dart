import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:social_network/circular_logo_progress.dart';
import 'package:social_network/edit_profile_page.dart';
import 'package:social_network/report_post.dart';
import 'package:social_network/user.dart';


// Used in activity_feed, image_post, profile_page and search_page
void openProfile(BuildContext context, String userId) {
  Navigator.of(context).push(MaterialPageRoute<bool>(
    builder: (BuildContext context) => ProfilePage(userId: userId))
  );
}

class ImageTile extends StatelessWidget {
  final ReportPost imagePost;

  ImageTile(this.imagePost);

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _clickedImage(context),
      child: CachedNetworkImage(imageUrl: imagePost.mediaUrl, fit: BoxFit.cover)
    );
  }

  _clickedImage(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<bool>(
      builder: (BuildContext context) {
        return Center(
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Text('Photo',
                style: TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold))),
            body: ListView(
              children: <Widget>[Container(child: imagePost)],
            )
          ),
        );
      }
    ));
  }
}

class ProfilePage extends StatefulWidget {
  final String userId;
  const ProfilePage({this.userId});
  _ProfilePage createState() => _ProfilePage(this.userId);
}

class _ProfilePage extends State<ProfilePage> with AutomaticKeepAliveClientMixin<ProfilePage> {
  final String profileId;
  String currentUserId = CurrentUser.instance.id;
  String view = "grid";
  bool isFollowing = false;
  bool followButtonClicked = false;
  int postCount = 0;
  int followerCount = 0;
  int followingCount = 0;
  _ProfilePage(this.profileId);

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {

    // Reloads state when opened again.
    super.build(context); 

    Widget _buildStatColumn(String label, int number) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(number.toString(), style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
          Container(

            //margin: const EdgeInsets.only(top: 4.0),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14.5,
                fontWeight: FontWeight.w400
              ),
            )
          )
        ],
      );
    }

    Widget _buildFollowButton(
        {String text,
        Color backgroundcolor,
        Color textColor,
        Color borderColor,
        Function function}) {
      return FlatButton(
        onPressed: function,
        child: Container(
          decoration: BoxDecoration(
              color: backgroundcolor,
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(5.0)),
          alignment: Alignment.center,
          child: Text(text,
              style: TextStyle(
                  color: textColor, fontWeight: FontWeight.bold)),
          width: 200.0,
          height: 27.0,
        )
      );
    }

    Widget _buildProfileButton(User user) {
      // Viewing your own profile - should show edit button
      if (currentUserId == profileId) {
        return _buildFollowButton(
          text: "Editar perfil",
          backgroundcolor: Colors.white,
          textColor: Colors.black,
          borderColor: Colors.grey,
          function: _editProfile,
        );
      }

      // already following user - should show unfollow button
      if (isFollowing) {
        return _buildFollowButton(
          text: "Unfollow",
          backgroundcolor: Colors.white,
          textColor: Colors.black,
          borderColor: Colors.grey,
          function: _unfollowUser,
        );
      }

      // does not follow user - should show follow button
      if (!isFollowing) {
        return _buildFollowButton(
          text: "Follow",
          backgroundcolor: Colors.blue,
          textColor: Colors.white,
          borderColor: Colors.blue,
          function: _followUser,
        );
      }

      return _buildFollowButton(
          text: "loading...",
          backgroundcolor: Colors.white,
          textColor: Colors.black,
          borderColor: Colors.grey);
    }

    Row _buildImageViewButtonBar() {

      Color _isActiveButtonColor(String viewName) {
        if (view == viewName) return Colors.blueAccent;
        return Colors.black26;
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.grid_on, color: _isActiveButtonColor("grid"), size: 26),
            onPressed: () => setState(() => view = 'grid')
          ),
          IconButton(
            icon: Icon(Icons.list, color: _isActiveButtonColor("feed"), size: 26),
            onPressed: () => setState(() => view = 'feed')
          ),
          IconButton(
            icon: Icon(Icons.attach_money, color: _isActiveButtonColor("shop"), size: 26),
            onPressed: () => setState(() => view = 'shop')
          ),
        ],
      );
    }

    Container _buildUserPosts() {

      Future<List<ReportPost>> _getPosts() async {
        List<ReportPost> _posts = [];
        /*var snap = await Firestore.instance
            .collection('insta_posts')
            .where('ownerId', isEqualTo: profileId)
            .orderBy("timestamp")
            .getDocuments();
        for (var doc in snap.documents) {
          _posts.add(ReportPost.fromDocument(doc));
        }
        setState(() => postCount = snap.documents.length);*/

        return _posts.reversed.toList();
      }

      return Container(
        child: FutureBuilder<List<ReportPost>>(
          future: _getPosts(),
          builder: (context, snapshot) {

            // Build progress indicator
            if (!snapshot.hasData) 
              return Container(
                alignment: FractionalOffset.center,
                padding: const EdgeInsets.only(top: 10.0),
                child: CircularLogoProgress());

            // Build the grid
            else if (view == "grid") {
              return GridView.count(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                mainAxisSpacing: 1.5,
                crossAxisSpacing: 1.5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: snapshot.data.map((ReportPost imagePost) {
                  return GridTile(child: ImageTile(imagePost));
                }).toList());
            } 
            
            // Build feed
            else if (view == "feed") { 
              return Column(
                children: snapshot.data.map((ReportPost imagePost) {
                  return imagePost;
                }).toList()
              );
            }
          },
        )
      );
    }

    //return StreamBuilder(
    return Builder(
        //stream: Firestore.instance.collection('insta_users').document(profileId).snapshots(),
        //builder: (context, snapshot) {
          //if (!snapshot.hasData) return Container(alignment: FractionalOffset.center, child: CircularLogoProgress());

          //User _profileOwner = User.loadFromDocument(snapshot.data);
          //User _profileOwner = User.loadFromJsonString(jsonString);

          /*if (_profileOwner.followers != null) {
            if (_profileOwner.followers.containsKey(currentUserId) &&
              _profileOwner.followers[currentUserId] &&
              followButtonClicked == false) {
              isFollowing = true;
            }
          }
          else {
            isFollowing = false;
          }*/
        builder: (context) {
          return Scaffold(
            backgroundColor: Colors.blue[100],
            appBar: AppBar(
              backgroundColor: Colors.blue[900],
              title: Text(/*_profileOwner.username*/ CurrentUser.instance.username,
                style: const TextStyle(color: Colors.white))),
            body: ListView(
                children: <Widget>[

                  Padding(
                    padding: const EdgeInsets.all(16.0),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[

                        Column( // Avatar, name, surfer, photographer, etc
                          children: <Widget>[

                            Row( // Avatar
                              children: [
                                
                                Container(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: CircularProfileAvatar(
                                    imageUrl: /*_profileOwner.photoUrl*/ CurrentUser.instance.photoUrl,
                                    radius: 50.0,             
                                    backgroundColor: Colors.transparent,
                                    borderWidth: 1,
                                    borderColor: Colors.black,
                                    elevation: 5.0,
                                    //foregroundColor: Colors.brown.withOpacity(0.5),
                                    cacheImage: true,
                                    onTap: () {},
                                    initialsText: Text( //_profileOwner.displayName != null ? _profileOwner.displayName[0].toUpperCase() :
                                      '',
                                      style: TextStyle(fontSize: 40, color: Colors.white)
                                    ),
                                  ),
                                ),

                              ],
                            ),

                            Row( // Display name
                              children: <Widget>[

                                Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Text(/*_profileOwner.displayName*/ CurrentUser.instance.displayName,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  )
                                ),
                              ],
                            ),

                            Row ( // Surfista, vendedor, fotografo, entusiasta
                              children: <Widget>[

                                Column( 
                                  children: <Widget>[

                                    Row( // Surfista
                                      children: <Widget>[

                                        Container(
                                          padding: EdgeInsets.all(2.0),
                                          alignment: Alignment.center,
                                          child: Text('Surfista', textAlign: TextAlign.center,
                                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700], fontSize: 13),
                                          )
                                        ),
                                      ]
                                    ),

                                    Row( // Vendedor
                                      children: <Widget>[

                                        Container(
                                          padding: EdgeInsets.all(2.0),
                                          alignment: Alignment.center,
                                          child: Text('Vendedor', textAlign: TextAlign.center,
                                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[300], fontSize: 13),
                                          )
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                Column( 
                                  children: <Widget>[

                                    Row( // Fotógrafo
                                      children: <Widget>[

                                        Container(
                                          padding: EdgeInsets.all(2.0),
                                          alignment: Alignment.center,
                                          child: Text('Fotógrafo', textAlign: TextAlign.center,
                                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700], fontSize: 13),
                                          )
                                        ),
                                      ],
                                    ),

                                    Row( // Entusiasta
                                      children: <Widget>[

                                        Container(
                                          padding: EdgeInsets.all(2.0),
                                          alignment: Alignment.center,
                                          child: Text('Entusiasta', textAlign: TextAlign.center,
                                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[300], fontSize: 13),
                                          )
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),

                          ],
                        ),

                        Column( // Stats, bio, follow/edit profile button
                          children: <Widget>[

                            Container (
                              
                              child: Row( // Stats
                                children: <Widget>[
                                  Container(padding: EdgeInsets.only(bottom: 5.0, top: 0.0, right: 5.0, left: 5.0), child: _buildStatColumn("Reports", postCount)),
                                  Container(padding: EdgeInsets.only(bottom: 5.0, top: 0.0, right: 5.0, left: 5.0), child: _buildStatColumn("Seguidores", /*_countFollowings(_profileOwner.followers)*/10)),
                                  Container(padding: EdgeInsets.only(bottom: 5.0, top: 0.0, right: 5.0, left: 5.0), child: _buildStatColumn("Seguindo", /*_countFollowings(_profileOwner.following)*/17)),
                                ],
                              ),
                            ),
                            
                            Container (
                              margin: EdgeInsets.only(bottom: 0.0),
                              child: Row( // Sell stats
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Container(padding: EdgeInsets.only(bottom: 25.0, top: 0.0, right: 6.0, left: 6.0), child: _buildStatColumn("Fotos vendidas", /*_countFollowings(_profileOwner.followers)*/0)),
                                  Container(padding: EdgeInsets.only(bottom: 25.0, top: 0.0, right: 6.0, left: 6.0), child: _buildStatColumn("Itens vendidos", /*_countFollowings(_profileOwner.followers)*/32)),
                                ]
                              ),
                            ),
                            
                            Row( // Bio
                              children: <Widget>[
                                Container( 
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.only(top: 5.0),
                                  child: Text(CurrentUser.instance.bio /*_profileOwner.bio*/),
                                ),
                              ]
                            ),
                            
                            /*Row( // Button
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Container(
                                  child: _buildProfileButton(_profileOwner)
                                ),
                              ]
                            ),*/
                          
                          ],
                        ), 
                      ],
                    ),
  
                  ),
                  Divider(height: 0.0),
                  _buildImageViewButtonBar(),
                  Divider(height: 0.0),
                  _buildUserPosts(),
                ],
              ));
        });
  }

  int _countFollowings(Map followings) {
    
    int _count = 0;

    void _countValues(key, value) {
      if (value) _count += 1;
    }

    // Hacky fix to enable a user's post to appear in their feed without skewing the follower/following count
    if (followings['$profileId'] != null && followings['$profileId']) _count -= 1;

    followings.forEach(_countValues);
    return _count;
  }

  _editProfile() {
    EditProfilePage editPage = EditProfilePage();
    Navigator.of(context).push(MaterialPageRoute<bool>(
      builder: (BuildContext context) {
        return Center(
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.maybePop(context)),
              title: Text('Editar perfil',
                style: TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold)),
              backgroundColor: Colors.white,
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.check,
                    color: Colors.blueAccent),
                  onPressed: () {
                    editPage.applyChanges();
                    Navigator.maybePop(context);})]),
            body: ListView(
              children: <Widget>[
                Container(
                  child: editPage,
                ),
              ],
            )
          ),
        );
      })
    );
  }

  _followUser() {
    print('following user');
    setState(() {
      this.isFollowing = true;
      followButtonClicked = true;
    });

    /*Firestore.instance.document("insta_users/$profileId").updateData({
      // Firestore plugin doesnt support deleting, so it must be nulled / falsed
      'followers.$currentUserId': true
    });*/

    /*Firestore.instance.document("insta_users/$currentUserId").updateData({
      // Firestore plugin doesnt support deleting, so it must be nulled / falsed
      'following.$profileId': true
    });*/

    // Updates activity feed
    /*Firestore.instance
    .collection("insta_a_feed")
    .document(profileId)
    .collection("items")
    .document(currentUserId)
    .setData({
      "ownerId": profileId,
      "username": CurrentUser.instance.username,
      "userId": currentUserId,
      "type": "follow",
      "userProfileImg": CurrentUser.instance.photoUrl,
      "timestamp": DateTime.now().toString()
    });*/
  }

  void _unfollowUser() {
    setState(() {
      isFollowing = false;
      followButtonClicked = true;
    });

    // Firestore plugin doesnt support deleting, so it must be turned to null or false.
    //Firestore.instance.document("insta_users/$profileId").updateData({'followers.$currentUserId': false});
    //Firestore.instance.document("insta_users/$currentUserId").updateData({'following.$profileId': false});
    //Firestore.instance.collection("insta_a_feed").document(profileId).collection("items").document(currentUserId).delete();
  }
}