import 'dart:async';

import 'dart:collection';

class OperationQueueEntry {
  Function function;
  List positionalArguments;
  Map<Symbol, dynamic> namedArguments;
  Completer completer;
  OperationQueueEntry(this.function, this.positionalArguments, this.namedArguments, this.completer);
}

class OperationQueue {
  Queue<OperationQueueEntry> _queue = Queue();
  Completer _activeCompleter;
  bool isAutoComplete;
  OperationQueue({this.isAutoComplete = true});

  Future schedule(Function function, {List positionalArguments, Map<Symbol, dynamic> namedArguments}) {
    var operation = OperationQueueEntry(function, positionalArguments, namedArguments, Completer());
    
    bool queueIsEmpty = _queue.isEmpty;
    _queue.add(operation);

    if(_activeCompleter == null || _activeCompleter.isCompleted && queueIsEmpty) {
      _runNext();
    }

    return operation.completer.future;
  }

  void _runNext(){
    if (_queue.isNotEmpty) {
      var operation = _queue.first;
      _activeCompleter = operation.completer;
      print("_runNext : $_activeCompleter");
      Function.apply(operation.function, operation.positionalArguments, operation.namedArguments).then((value){
        operation.completer.future.then((_){
          _queue.removeFirst();
          _runNext();
        });
        if(isAutoComplete) {
          operation.completer.complete(value);
        }
      }).catchError((error){
        operation.completer.future.then((_){
          _queue.removeFirst();
          _runNext();
        });
        if(isAutoComplete) {
          operation.completer.complete(error);
        }
      });
    }
  }

  void manualSettingComplete({dynamic value}) {
    print("manualSetting : $_activeCompleter");
    _activeCompleter?.complete(value);
  }

  bool get isActive {
    if (_activeCompleter == null){
      return _queue.isNotEmpty;
    } else {
      return !(_queue.isEmpty && _activeCompleter.isCompleted);
    }
  }
}