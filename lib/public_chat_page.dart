import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:social_network/user.dart';
import 'chat_message.dart';
import 'package:image_picker/image_picker.dart';

class ChatPage extends StatefulWidget {
  @override
  State createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {

  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = <ChatMessage>[
    
    
    ChatMessage(
      alignRight: true,
      avatarUrl: 'https://cdn.surfer.com/uploads/2011/02/jeremy_flores_Joli.jpg',
      username: 'jeremyflores22', mediaFile: null,
      text: 'Opa, então.. to aqui no postinho na barra e sem parafina! Alguém tem?'),

    ChatMessage(
      alignRight: true,
      avatarUrl: 'https://paranaportal.uol.com.br/wp-content/uploads/2018/12/12748138-high-1024x683.jpeg',
      username: 'gabrielmedina10', mediaFile: null,
      text: 'Fala, brother! Na paz?'),

    ChatMessage(
      alignRight: true,
      avatarUrl: 'https://cdn.surfer.com/uploads/2011/02/jeremy_flores_Joli.jpg',
      username: 'jeremyflores22', mediaFile: null,
      text: 'E aí galeraa'),
  ];

  void _handleSubmitted(String text) {
    _textController.clear();
    ChatMessage message = ChatMessage(avatarUrl: CurrentUser.instance.photoUrl, username: CurrentUser.instance.username, text: text);
    setState(() => _messages.insert(0, message));
  }

  Future<void> _openCamera(String text) async {

    // Gets (or not) the file from native camera
    File _cameraFile = await ImagePicker.pickImage(source: ImageSource.camera, maxWidth: 800, maxHeight: 600);

    // Clears the text controller
    _textController.clear();

    // Creates a chat message with the cameraFile and rebuilds chat screen
    setState(() => _messages.insert(0, ChatMessage(avatarUrl: CurrentUser.instance.photoUrl, username: CurrentUser.instance.username, text: text, mediaFile: _cameraFile,)));
  }

  Widget _textComposerWidget() {
    
    // Random hint text
    List<String> _randomSpots = ['Barra', 'Joatinga', 'Leblon', 'Arpex', 'Posto 5', 'Cantão', 'Pontão'];
    String _spot = _randomSpots[Random().nextInt(_randomSpots.length)];
    List<String> _randomHintTexts = [
      'Preciso de chave de quilha!!!', 
      'Quem tem parafina?', 
      '$_spot tá clássico!', 
      '$_spot tinha altas hoje de manhã!', 
      'Onde tem onda?', 
      '$_spot tá bom?',
      'Quem surfou, surfou... vento já entrou!',
      'Amanhã promete hein!',
      'Marcio Bill geral sumiu kkkk'
      ];
    String _hintText = _randomHintTexts[Random().nextInt(_randomHintTexts.length)];

    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[

            Flexible(
              child: TextField(
                //onChanged: (_) => setState(() {}), // Used to set camera icon invisible
                decoration:
                  InputDecoration.collapsed(hintText: '$_hintText', hintStyle: TextStyle(color: Colors.grey[400], fontStyle: FontStyle.italic)),
                controller: _textController,
              ),
            ),

            Visibility(
              visible: (_textController.text == null || _textController.text == ''),
              child: Container(
                child: IconButton(
                  icon: Icon(Icons.add_a_photo, color: Colors.black),
                  onPressed: () => _openCamera(_textController.text),
                ),
              ),
            ),
            
            Container(
              child: IconButton(
                icon: Icon(Icons.send, color: Colors.black),
                onPressed: () => _handleSubmitted(_textController.text),
              ),
            )

          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Text('Chat',
          style: const TextStyle(color: Colors.white))),
      body: Column(
        children: <Widget>[

          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.all(8.0),
              reverse: true,
              itemBuilder: (_, int index) => _messages[index],
              itemCount: _messages.length,
            ),
          ),

          Divider(
            height: 1.0,
          ),

          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: _textComposerWidget(),
          ),
          
        ],
      ),
    );
  }
}