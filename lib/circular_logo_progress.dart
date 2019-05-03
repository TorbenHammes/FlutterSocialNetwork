import 'package:circle_wave_progress/circle_wave_progress.dart';
import 'package:flutter/material.dart';

class CircularLogoProgress extends StatelessWidget {
  
  final bool useText;

  const CircularLogoProgress({
    this.useText,
  });

  @override
  Widget build(BuildContext context) {

    bool _useText = useText;

    if (_useText == null) _useText = false;

    return Stack(
      children: <Widget>[
      
        Opacity(
          opacity: 0.7,
          child: Center(
            child: Stack(
              children: <Widget>[

                Container(  //little wave 1
                  child: CircleWaveProgress(
                    size: 32.0, 
                    backgroundColor: Colors.orange[300],
                    waveColor: Colors.blue[900], 
                    borderColor: Colors.transparent, 
                    borderWidth: 0.0, 
                    progress: 24.0,
                  ),
                ),
              

                Container(  //little wave 2
                  child: CircleWaveProgress(
                    size: 32.0, 
                    backgroundColor: Colors.transparent, 
                    waveColor: Colors.blue[600], 
                    borderColor: Colors.black, 
                    borderWidth: 3.0, 
                    progress: 14.0,
                  )
                ),

                Container(  //progress border
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator()
                ),

              ],
            ),
          ),
        ),

        Center(
          child: _useText
          ? Container(
            padding: EdgeInsets.only(top: 55),
            child: Text('Aguarde a série'
            )
          )
          : Container(child: Text('')),
        )

      ],
    );
  }
    
}