import 'dart:collection';
import 'dart:math';

import 'operation_queue.dart';


class PlayModel {
  String audioId;
  AudioPlayingStatus status;
  PlayModel(this.audioId, this.status);
}

class TestFuture {

  factory TestFuture() => sharedInstance();
  static TestFuture _instance;
  OperationQueue _queue = OperationQueue(isAutoComplete: false);

  TestFuture._() {
    _init();
  }

  static TestFuture sharedInstance() {
    if (_instance == null) {
      _instance = TestFuture._();
    }
    return _instance;
  }

  _init() {}

  
  
  void newPlayAudio(String audioId, int seconds) {
    _queue.schedule(playAudio, positionalArguments: [audioId, seconds]);
  }

  Future<String> playAudio(String audioId, int seconds) async {
    return await Future.delayed(Duration(seconds: seconds), (){
      _onData(AudioPlayingStatus.playing, audioId);
      return "playAudio -$audioId";
    });
  }
      
  Future<void> _onData(AudioPlayingStatus status, String audioId) async {
    
    switch (status) {
      case AudioPlayingStatus.playing:
       for(int i = 0; i < 1000; i++) {
          await printMessage(audioId, "playing");
        }
        _queue.manualSettingComplete();
        break;

      default: break;
    }
  }

  Future<void> printMessage(String audioId, String status) async {
    List values = [100, 200, 300];
    int v = values[Random().nextInt(values.length)];
    Future.delayed(Duration(milliseconds: v), (){
      print("$audioId is $status");
    });
  }
}
class SoundsUtils {
  static Future<String> playLocalSound(String audioId, int seconds) async {
    //同步
    return Future((){
      TestFuture.sharedInstance().newPlayAudio(audioId, seconds);
    });
    //异步
    // return Future((){
    //   TestFuture.sharedInstance().playAudio(audioId, seconds);
    // });
  }
}

enum AudioPlayingStatus {
  unknown,
  loaded,
  playing,
  finished,
  errorOccured,
  stop
}