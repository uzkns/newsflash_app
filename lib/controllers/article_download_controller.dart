import 'dart:convert';

import 'package:flutter_app/models/article.dart';
import "package:http/http.dart" as http;

/// Handles Article downlonding and conversion.
///
/// The Articles are all downloaded from newsapi.org.
/// They come in JSON format and need to be decoded.
class ArticleDownloadController {
    static final String _apiKey = "6e2a35c6466845f5b2b0be20267ed9cd";
    String _url;
    List<Article> articles = new List<Article>();
    String _endpoint;
    final String articleCategory;
    final String countryCode;
    final String searchKeyword;


    /// Constructor to get the top headlines for the given Category and country.
    /// a search keyword can be passed aswell.
    ArticleDownloadController.getTopHeadlines(this.articleCategory, this.countryCode, this.searchKeyword) {
        this._endpoint = "v2/top-headlines";
        _buildURL();
    }

    /// Constructor to get every headline for the given Category and country.
    /// a search keyword can be passed aswell.
    ArticleDownloadController.getEverything(this.articleCategory, this.countryCode, this.searchKeyword) {
        this._endpoint = "v2/everything";
        _buildURL();
    }


    /// Builds the URL from the parameters given to the constructor.
    void _buildURL() {
        this._url = "http://newsapi.org/" + this._endpoint + "?";

        if (articleCategory != "") {
            this._url = this._url + "category=" + this.articleCategory + "&";
        }

        if (this.countryCode != "") {
            this._url = this._url + "country=" + this.countryCode + "&";
        }

        if (this.searchKeyword != "") {
            this._url = this._url + "q=" + this.searchKeyword + "&";
        }

        this._url = this._url + "apiKey=" + _apiKey;
    }

    /// Fetches all articles
    ///
    /// The articles will be fetched from newsapi.org and then JSON decoded
    /// into elements of type Article. and saved into the articles List.
    ///
    /// return: void
    Future<void> fetch() async {
        var resp = await http.get(_url);

        if (resp.statusCode != 200) {
            return;
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
            //TODO remove
            print("Downloaded all articles for category " + this.articleCategory);
            return;
        } else {
            return;
        }
    }
}