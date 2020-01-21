import 'dart:async';

abstract class StreamWithValue<T> {
  T get value;
  bool get hasValue;

  /// Any changes to [value], in the form of a stream.
  /// The current [value] itself typically is not sent upon [Stream.listen] to
  /// [updates], although this detail is implementation defined.
  Stream<T> get updates;
}

typedef _Converter<TInput, TOutput> = TOutput Function(TInput event);

class _MappedStreamWithValue<TInput, TOutput>
    implements StreamWithValue<TOutput> {
  final StreamWithValue<TInput> _inputStream;
  final _Converter<TInput, TOutput> _convert;

  _MappedStreamWithValue(this._inputStream, this._convert);

  TOutput get value =>
      _inputStream.hasValue ? _convert(_inputStream.value) : null;
  bool get hasValue => _inputStream.hasValue;

  Stream<TOutput> get updates => _inputStream.updates.mapPerEvent(_convert);
}

/// We want [StreamWithValue] to be usable as an interface, rather than forcing
/// users to inherit from it, since it has no state.
/// Any implementations that can be useful are provided via this extension
/// instead.
extension StreamWithValueExtensions<TInput> on StreamWithValue<TInput> {
  StreamWithValue<TOutput> map<TOutput>(_Converter<TInput, TOutput> convert) =>
      _MappedStreamWithValue(this, convert);
}

extension MapPerEvent<TInput> on Stream<TInput> {
  /// Like [map], but calls [convert] once per event, and not per listener.
  Stream<TOutput> mapPerEvent<TOutput>(_Converter<TInput, TOutput> convert) {
    StreamController<TOutput> controller;
    StreamSubscription<TInput> subscription;

    void onListen() {
      subscription = listen((event) => controller.add(convert(event)),
          onError: controller.addError, onDone: controller.close);
    }

    if (isBroadcast) {
      controller = StreamController<TOutput>.broadcast(
          onListen: onListen,
          onCancel: () => subscription.cancel(),
          sync: true);
    } else {
      controller = StreamController<TOutput>(
          onListen: onListen,
          onPause: () => subscription.pause(),
          onResume: () => subscription.resume(),
          onCancel: () => subscription.cancel(),
          sync: true);
    }

    return controller.stream;
  }
}

/// [StreamWithValue] implementation that wraps a [Stream] and keeps the latest
/// value that was received from it. Beware that for "push" model, where a
/// (typically broadcast) stream pushes data even when it's not listened to,
/// the [value] will not be tracked if there are no listeners on [updates].
// Why not use BehaviorSubject?
// 1. It incapsulates all of: stream, value and add(), i.e. requires another
//    interface / wrapper to expose read-only properties: stream and value.
// 2. If you already have a stream that you want to turn into BehaviorSubject,
//    you have to subscribe to that stream, create a BehaviorSubject, add values
//    to BehaviorSubject and when done, close both stream subscription and
//    BehaviorSubject. This is cumbersome.
// 3. It replays the value to all new stream subscribers, which is redundant
//    when passing value as initialData to StreamBuilder. Passing initialData
//    if it's available is important to avoid unnecessary blinking.
class StreamWithLatestValue<T> implements StreamWithValue<T> {
  Stream<T> _stream;
  bool _hasLatestValue = false;
  T _latestValue;

  StreamWithLatestValue(Stream<T> sourceStream, {T initialValue}) {
    if (initialValue != null) {
      _latestValue = initialValue;
      _hasLatestValue = true;
    }
    _stream = sourceStream.mapPerEvent((value) {
      _latestValue = value;
      _hasLatestValue = true;
      return value;
    });
  }

  @override
  Stream<T> get updates => _stream;

  @override
  T get value => _latestValue;

  @override
  bool get hasValue => _hasLatestValue;
}
