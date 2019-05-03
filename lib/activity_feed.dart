import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:social_network/circular_logo_progress.dart';
import 'package:social_network/profile_page.dart';
import 'package:social_network/report_post.dart';
import 'package:social_network/user.dart';

openImage(BuildContext context, String imageId) {
  print("the image id is $imageId");
  Navigator.of(context).push(MaterialPageRoute<bool>(
    builder: (BuildContext context) {
      return Center(
        child: Scaffold(
          backgroundColor: Colors.blue[100],
          appBar: AppBar(
            backgroundColor: Colors.blue[900],
            title: Text('Photo',
              style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold
              )
            ),
          ),
          body: ListView(
            children: <Widget>[
              Container(
                child: ImagePostFromId(id: imageId),
              ),
            ],
          )
        ),
      );
    }
  ));
}

class ActivityFeedItem extends StatelessWidget {
  
  final String username;
  final String userId;
  final String type; // Potential types include 'like', 'follow' and 'comment'.
  final String mediaUrl;
  final String mediaId;
  final String userProfileImg;
  final String comment;

  Widget _mediaPreview = Container();

  String _activityText;
  ActivityFeedItem({
    this.username,
    this.userId,
    this.type,
    this.mediaUrl,
    this.mediaId,
    this.userProfileImg,
    this.comment
  });

  @override
  Widget build(BuildContext context) {

    _configureItem(context);

    Widget _itemText = RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 14.0,
          color: Colors.black),
        children: <TextSpan>[
          TextSpan(text: '$username', style: TextStyle(fontWeight: FontWeight.bold)
            // recognizer: //TODO: tap recognizer for name and activity text 
          ),
          TextSpan(text: '$_activityText'),
        ],
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[

        Padding( // Avatar image
          padding: const EdgeInsets.only(left: 15.0, right: 10.0),
          child: CircleAvatar(
            radius: 23.0,
            backgroundImage: CachedNetworkImageProvider(userProfileImg),
          ),
        ),

        Expanded( // Text with tap response
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[

              Flexible(
                child: GestureDetector(
                  onTap: () => openProfile(context, userId),
                  child: Container(child: _itemText)
                ),
              ),

            ],
          ),
        ),

        Container( // Image or video
          child: Align(
            alignment: AlignmentDirectional.bottomEnd,
            child: Padding(
              child: _mediaPreview,
              padding: EdgeInsets.all(15.0),
            )       
          )
        )


      ],
    );
  }

  /// Configures the media thumbnail tap response.
  void _configureItem(BuildContext context) {
    if (type == "like" || type == "comment") {
      _mediaPreview = GestureDetector(
        onTap: () {
          openImage(context, mediaId);
        },
        child: Container(
          height: 45.0,
          width: 45.0,
          child: AspectRatio(
            aspectRatio: 487 / 451,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fill,
                  alignment: FractionalOffset.topCenter,
                  image: CachedNetworkImageProvider(mediaUrl),
                )
              ),
            ),
          ),
        ),
      );
    }

    if (type == "like") {
      _activityText = " curtiu seu post.";
    } else if (type == "likeReport") {
      _activityText = " curtiu seu report.";
    } else if (type == "likePhoto") {
      _activityText = " curtiu seu photo.";
    } else if (type == "follow") {
      _activityText = " está seguindo você.";
    } else if (type == "comment") {
      _activityText = " commented: $comment";
    } else {
      _activityText = "Error - invalid activityFeed type: $type";
    }
  }
}

class ActivityFeedPage extends StatefulWidget {
  @override
  _ActivityFeedPage createState() => _ActivityFeedPage();
}

class _ActivityFeedPage extends State<ActivityFeedPage> with AutomaticKeepAliveClientMixin<ActivityFeedPage> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Reloads state when opened again
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue[900],
        title: Text('Novidades', style: TextStyle(color: Colors.white))),
      body: _buildActivityFeed(),
    );
  }

  _buildActivityFeed() {
    return Container(
      child: FutureBuilder(
          future: _getFeed(),
          builder: (context, snapshot) {
            if (!snapshot.hasData && snapshot.connectionState != ConnectionState.done)
              return Container(
                alignment: FractionalOffset.center,
                padding: const EdgeInsets.only(top: 15.0),
                child: CircularLogoProgress());
            else {
              if (snapshot.hasData)
                return ListView(padding: EdgeInsets.only(top: 15.0), children: snapshot.data);
              else
                return ListView(padding: EdgeInsets.only(top: 15.0), children: [Text('')]);
            }
          }),
    );
  }

  /// Returns a list of activity items ordered by timestamp.
  Future<List<ActivityFeedItem>> _getFeed() async {

    List<ActivityFeedItem> _items = [];

    if (CurrentUser.instance.id != '' && CurrentUser.instance.id != null) {

      /*var _snap = await Firestore.instance
          .collection('insta_a_feed')
          .document(CurrentUser.instance.id)
          .collection("items")
          .orderBy("timestamp")
          .getDocuments();*/

      /*for (var doc in _snap.documents) {
        _items.add(ActivityFeedItem.fromDocument(doc));
      }*/

      _items.add(ActivityFeedItem(username: 'jeremyflores22', userId: '3', type: 'like', mediaId: '3', 
                                  mediaUrl: 'https://scontent-gig2-1.cdninstagram.com/vp/78a78dd27abe96758c18202dff410246/5D5FF4DB/t51.2885-15/e35/57071105_385978348921376_9149656287479255604_n.jpg?_nc_ht=scontent-gig2-1.cdninstagram.com',
                                  userProfileImg: 'https://cdn.surfer.com/uploads/2011/02/jeremy_flores_Joli.jpg', comment: ''));

      _items.add(ActivityFeedItem(username: 'gabrielmedina10', userId: '2', type: 'comment', mediaId: '2', 
                                  mediaUrl: 'https://scontent-gig2-1.cdninstagram.com/vp/c600117f0d466dc08721afe800e58b21/5D59BD02/t51.2885-15/e35/57353142_478870059522717_6213187490148303088_n.jpg?_nc_ht=scontent-gig2-1.cdninstagram.com',
                                  userProfileImg: 'https://paranaportal.uol.com.br/wp-content/uploads/2018/12/12748138-high-1024x683.jpeg', comment: 'oloko meu'));

      _items.add(ActivityFeedItem(username: 'filipetoledo77', userId: '1', type: 'like', mediaId: '1', 
                                  mediaUrl: 'https://scontent-gig2-1.cdninstagram.com/vp/c46d8fe272e6653ceb445e57464a3c43/5D704FD5/t51.2885-15/e35/57605288_130308241452841_6609715585660438290_n.jpg?_nc_ht=scontent-gig2-1.cdninstagram.com',
                                  userProfileImg: 'http://www.jornaldebrasilia.com.br/wp-content/uploads/2019/04/felipe-toledo-e1556197362159.jpg', comment: ''));

      return _items.reversed.toList();
    }

    return _items;
  }
}
