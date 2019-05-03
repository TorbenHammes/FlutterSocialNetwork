import 'package:flutter/material.dart';

import "profile_page.dart";
import "user.dart";

class SearchPage extends StatefulWidget {
  _SearchPage createState() => _SearchPage();
}

class UserSearchItem extends StatelessWidget {
  final User _user;

  const UserSearchItem(this._user);

  @override
  Widget build(BuildContext context) {
    TextStyle boldStyle = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
    );

    return GestureDetector(
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(_user.photoUrl),
            backgroundColor: Colors.grey,
          ),
          title: Text(_user.username, style: boldStyle),
          subtitle: Text(_user.displayName),
        ),
        onTap: () {
          openProfile(context, _user.id);
        });
  }
}

class _SearchPage extends State<SearchPage> with AutomaticKeepAliveClientMixin<SearchPage>{
  //Future<QuerySnapshot> _userDocs;

  @override
  bool get wantKeepAlive => true;

  Widget build(BuildContext context) {
    super.build(context); // Reloads state when opened again

    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Text('Pesquisa',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      
      body: 
      
      //_userDocs == null ? 
      Container(padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0), child: _buildSearchField())
      /* : FutureBuilder<QuerySnapshot>(
        future: _userDocs,
        builder: (context, snapshot) {

          // Loading
          if (!snapshot.hasData) {
            return Stack(
              children: [
                Container(padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0), alignment: FractionalOffset.topCenter, child: _buildSearchField()),
                Center(child: CircularLogoProgress()),
              ]
            );
            
          } 
          
          // Loaded
          else {
            return Stack(
              children: [
                Container(padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0), alignment: FractionalOffset.topCenter, child: _buildSearchField()),
                Container(padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 70.0), alignment: FractionalOffset.center, child: _buildSearchResults(snapshot.data.documents))
              ]
            );
          }
        }
      ),*/
    );
  }

  Widget _buildSearchField() {
    return Form(
      child: TextFormField(
        decoration: InputDecoration(labelText: 'Usuários, picos, escolinhas...'),
        onFieldSubmitted: _submitSearch,
      ),
    );
  }

  /*ListView _buildSearchResults(List<DocumentSnapshot> docs) {
    List<UserSearchItem> _userSearchItems = [];

    docs.forEach((DocumentSnapshot _doc) {
      User _user = User.loadFromDocument(_doc);
      UserSearchItem searchItem = UserSearchItem(_user);
      _userSearchItems.add(searchItem);
    });

    return ListView(
      children: _userSearchItems,
    );
  }*/

  // Ensures state is kept when switching pages
  void _submitSearch(String searchValue) async {
    /*Future<QuerySnapshot> _users = Firestore.instance
        .collection("insta_users")
        .where('displayName', isGreaterThanOrEqualTo: searchValue)
        .getDocuments();

    setState(() {
      _userDocs = _users;
    });*/
  }
}
