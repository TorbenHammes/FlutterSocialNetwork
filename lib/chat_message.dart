import 'dart:io';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {

  // Every chat message has
  final String avatarUrl;
  final String username;
  final String text;
  final File mediaFile;
  final bool alignRight;

  // Constructor
  ChatMessage({
    this.text, 
    this.avatarUrl, 
    this.username, 
    this.mediaFile, 
    this.alignRight
  });

  TextStyle boldStyle = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );

  @override
  Widget build(BuildContext context) {

    print ('[ChatMessage] [Build] mediaFile: $mediaFile');

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: alignRight == true ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[

          (alignRight == false || alignRight == null) 
          ? Container( // If is aligned left, avatar comes first
            margin: const EdgeInsets.only(right: 8.0),
            child: CircularProfileAvatar(
              imageUrl: avatarUrl,
              radius: 18.0,             
              backgroundColor: Colors.transparent,
              borderWidth: 1,
              borderColor: Colors.black,
              elevation: 5.0,
              cacheImage: true,
              onTap: () => {},
              initialsText: Text(username != null ? username[0].toUpperCase() : '',
                style: TextStyle(fontSize: 18, color: Colors.white)
              ),
            ),
          )
          : Column( // If is aligned right, message comes first
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(username, style: boldStyle),
              Container(
                margin: const EdgeInsets.only(top: 5.0),
                child: mediaFile == null 
                ? Text(text) 
                /*: Container(
                  child: AspectRatio(
                    aspectRatio: 487 / 451,
                    child: Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                        fit: BoxFit.fill,
                        alignment: FractionalOffset.topCenter,
                        image: FileImage(mediaFile),
                      )),
                    ),
                  ),
                )*/
                : Container(
                  child: Image.file(mediaFile)
                )
              )
            ],
          ),

          (alignRight == false || alignRight == null)
          ? Column( // If is aligned left, message comes second
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(username, style: boldStyle),
              Container(
                margin: const EdgeInsets.only(top: 5.0),
                child: mediaFile == null ? Text(text) 
                : Container(
                  //child: new AspectRatio(
                    //aspectRatio: 487 / 451,
                    child: new Container(
                      decoration: new BoxDecoration(
                          image: new DecorationImage(
                        fit: BoxFit.fill,
                        alignment: FractionalOffset.topCenter,
                        image: new FileImage(mediaFile,scale: 1.0),
                      )),
                    ),
                  //),
                )
              )
            ],
          )      
          : Container( // If is aligned right, avatar comes second
            margin: const EdgeInsets.only(left: 8.0),
            child: CircularProfileAvatar(
              imageUrl: avatarUrl,
              radius: 18.0,             
              backgroundColor: Colors.transparent,
              borderWidth: 1,
              borderColor: Colors.black,
              elevation: 5.0,
              cacheImage: true,
              onTap: () => {},
              initialsText: Text(username != null ? username[0] : '',
                style: TextStyle(fontSize: 18, color: Colors.white)
              ),
            ),
          ),
  
        ],
      ),
    );
  }
}