import 'dart:async';

import 'package:uproplus/core/data/blocs/bloc_provider.dart';
import 'package:uproplus/core/data/preferences.dart';

class NewsBloc implements BlocBase {

  // Input stream for adding news. We'll call this from our pages.
  final _fetchNewsController = StreamController<String>.broadcast();
  StreamSink<String> get inFetchNews => _fetchNewsController.sink;
  Stream<String> get fetched => _fetchNewsController.stream;

  final _saveNewsController = StreamController<String>.broadcast();
  StreamSink<String> get inSaveNews => _saveNewsController.sink;

  final _newsSavedController = StreamController<bool>.broadcast();
  StreamSink<bool> get _inSaved => _newsSavedController.sink;
  Stream<bool> get saved => _newsSavedController.stream;

  NewsBloc() {
    _saveNewsController.stream.listen(_handleSaveNews);
  }

  @override
  void dispose() {
    _fetchNewsController.close();
    _saveNewsController.close();
    _newsSavedController.close();
  }

  fetchNews() async {
    String news = await PreferencesProvider.get().getNews();
    inFetchNews.add(news);
  }

  void _handleSaveNews(String news) async {
    await PreferencesProvider.get().saveNews(news);

    _inSaved.add(true);
  }
}
