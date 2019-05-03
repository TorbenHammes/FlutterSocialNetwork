import "package:flutter/material.dart";
import 'user.dart';

class EditProfilePage extends StatelessWidget {
  TextEditingController nameController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  applyChanges() {
    /*Firestore.instance
        .collection('insta_users')
        .document(CurrentUser.instance.id)
        .updateData({
      "displayName": nameController.text,
      "bio": bioController.text,
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        /*future: Firestore.instance
            .collection('insta_users')
            .document(CurrentUser.instance.id)
            .get(),*/
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Container(
                alignment: FractionalOffset.center,
                child: CircularProgressIndicator());

          //User user = User.loadFromDocument(snapshot.data);

          //nameController.text = user.displayName;
          //bioController.text = user.bio;

          nameController.text = '';
          bioController.text = '';

          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(CurrentUser.instance.photoUrl),
                  radius: 50.0,
                ),
              ),
              FlatButton(
                  onPressed: () {
                    changeProfilePhoto(context);
                  },
                  child: Text(
                    "Change Photo",
                    style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold),
                  )),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    buildTextField(name: "Name", controller: nameController),
                    buildTextField(name: "Bio", controller: bioController),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: MaterialButton(
                    onPressed: () => {_logout(context)},
                    child: Text("Logout")

                )
              )
            ],
          );
        });
  }

  Widget buildTextField({String name, TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Text(
            name,
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: name,
          ),
        ),
      ],
    );
  }

  changeProfilePhoto(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Photo'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Changing your profile photo has not been implemented yet'),
              ],
            ),
          ),
        );
      },
    );
  }

  void _logout(BuildContext context) async {
    print("logout");
    //await firebaseAuth.signOut();
    //await googleSignIn.signOut();

    Navigator.pop(context);
  }
}
