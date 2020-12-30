import 'package:flutter/material.dart';
import 'package:flutter_app/models/article.dart';
import 'package:flutter_app/models/category.dart';
import 'package:flutter_app/views/widgets/news_block.dart';

/// The view for viewing all saved Articles
///
/// A white bar with the text "Saved" and a scrollable list of Cards underneath
/// Very similar to the main view, but you cannot dismiss/save articles.
/// (because they are already saved)
///
/// This view is very similar from a standard category view, since
/// "saved" is just another category.
class SavedArticleView extends StatefulWidget {

    final Category category;
    SavedArticleView(this.category);

    @override
    _SavedArticleViewState createState() => _SavedArticleViewState();
}

class _SavedArticleViewState extends State<SavedArticleView> {

    List<Article> articles = new List<Article>();

    @override
  void initState() {
      super.initState();
      articles.addAll(widget.category.getArticles());
  }


    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[Text(widget.category.name)]
          ),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
                child: Column(
                  children: <Widget>[
                    // --- Articles
                    Container(
                        padding: EdgeInsets.only(top: 12),
                        child: ListView.builder(
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            itemCount: articles.length,
                            itemBuilder: (context, index) {
                              final article = articles[index];
                              return NewsBlock.fromArticle(article);
                            }
                        )
                    )
                  ],
                )
            ),
          ),
        ),
      );
    }
}
