import 'dart:convert';
import 'dart:io';

import 'package:flutter_app/models/article.dart';
import 'package:path_provider/path_provider.dart';


/// Handles Article persistence between app restarts.
///
/// All saved Articles will be JSON encoded and written into a local text file.
/// They can then be read again and deserialized upon app launch.
class ArticlePersistenceController {

  /// The path to the local files. These are not visible to the user.
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }


  /// The file in which all saved articles will be written into.
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/saved_articles.json');
  }

  /// Saves a list of Articles to the disk
  ///
  /// The List<Article> will be saved as a JSON encoded String.
  /// Any previous file contents will be overwritten.
  ///
  /// return: The File Handle
  Future<File> saveArticleListToDisk(List<Article> articleList) async {
    final file = await _localFile;

    return file.writeAsString(jsonEncode(articleList), flush : true);
  }

  /// Saves a single Article to the disk
  ///
  /// All Articles are loaded from the File, converted to a List,
  /// the Article will be inserted at the top and the new List is saved again
  /// using ArticlePersistenceController#saveArticleListToDisk()
  ///
  /// return: The File handle
  Future<File> saveArticleToDisk(Article a) async {
    final file = await _localFile;
    List<Article> aList = await loadArticleListFromDisk();
    print(aList.length);
    if (aList.isNotEmpty) {
      //insert the newest article at the top
      aList.insert(0, a);
      saveArticleListToDisk(aList);
      print("Saved articles to disk");
    } else {
      List<Article> emptyList = new List<Article>();
      emptyList.add(a);
      saveArticleListToDisk(emptyList);
      print("Created new list and saved articles to disk");
    }
  }

  /// Loads an Article list from the disk
  ///
  /// OPens the File, reads from it a JSON encoded String containing Articles.
  /// Converts the Articles to a List.
  /// If the List is empty or the file does not yet exist,
  /// a new, empty List will be returned instead of null.
  ///
  /// return: The Article list as a Future
  Future<List<Article>> loadArticleListFromDisk() async {
    try {
      final file = await _localFile;

      // Read the file.
      String contents = await file.readAsString();
      List<Article> list = new List<Article>();
      print(contents);
      List<dynamic> jsonArticles = json.decode(contents);
      for (Map<String, dynamic> a in jsonArticles) {
        list.add(Article.fromJson(a));
      }
      return list;
    } catch (e) {
      print(e);
      return new List<Article>();
    }
  }

  /// Clears the contents the file
  ///
  /// This is a debug method. TODO remove
  Future<File> clear() async {
    final file = await _localFile;
    print("saved");
    List<Article> emptyList = new List<Article>();
    return file.writeAsString(jsonEncode(emptyList), flush : true);

  }

  /// removes duplicates from a List
  ///
  /// the first parameter should be a reference to the list
  /// from which the items should be removed.
  ///
  /// Takes the elements from duplicates and
  /// compares them one-by-one to the elements in list.
  /// If a duplicate is found, it will be removed from list
  ///
  /// return: void
  static void removeDuplicates(List<Article> list, List<Article> duplicates) {
    for (Article a in duplicates) {
      list.remove(a);
    }

  }

}
