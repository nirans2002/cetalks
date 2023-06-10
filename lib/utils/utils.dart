import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class Utils {
  static StreamTransformer<QuerySnapshot<Map<String, dynamic>>, List<T>>
      transformer<T>(T Function(Map<String, dynamic> json) fromJson) =>
          StreamTransformer<QuerySnapshot<Map<String, dynamic>>,
              List<T>>.fromHandlers(
            handleData: (QuerySnapshot<Map<String, dynamic>> data,
                EventSink<List<T>> sink) {
              final snaps = data.docs.map((doc) {
                final map = doc.data();
                map.addAll({'documentId': doc.id});
                return map;
              }).toList();
              final objects = snaps.map((json) => fromJson(json)).toList();
              sink.add(objects);
            },
          );
}
