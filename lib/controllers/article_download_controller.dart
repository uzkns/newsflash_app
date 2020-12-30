import 'dart:convert';

import 'package:flutter_app/models/article.dart';
import "package:http/http.dart" as http;

/// Handles Article downlonding and conversion.
///
/// The Articles are all downloaded from newsapi.org.
/// They come in JSON format and need to be decoded.
class ArticleDownloadController {
    static final String _apiKey = "6e2a35c6466845f5b2b0be20267ed9cd";
    static final String url = "http://newsapi.org/v2/top-headlines?country=de&category=business&apiKey=6e2a35c6466845f5b2b0be20267ed9cd";
    List<Article> articles = new List<Article>();

    //TODO remove lines marked as //DEBUG
    /// Fetches all articles
    ///
    /// The articles will be fetched from newsapi.org and then JSON decoded
    /// into elements of type Article. and saved into the articles List.
    ///
    /// return: void
    Future<void> fetch() async {
        var resp = await http.get(url);

        if (resp.statusCode != 200) {
            return null; //TODO exception
        }

        var jsonResp = jsonDecode(resp.body);

        if (jsonResp["status"] == "ok") {
            jsonResp["articles"].forEach((article) {
                if (article["urlToImage"] != null && article["description"] != null && article["title"] != null) {
                    Article a = new Article(article["source"]["id"],
                                            article["author"],
                                            article["title"],
                                            article["description"],
                                            article["url"],
                                            article["urlToImage"],
                                            DateTime.parse(article["publishedAt"]),
                                            article["content"]
                                           );

                    articles.add(a);
                }
            });

            return articles;
        } else {
            //TODO exception
            return articles;
        }
    }
}

//TODO better controls over URL