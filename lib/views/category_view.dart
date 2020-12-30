import 'package:flutter/material.dart';
import 'package:flutter_app/controllers/article_persistence_controller.dart';
import 'package:flutter_app/models/article.dart';
import 'package:flutter_app/models/category.dart';
import 'package:flutter_app/views/widgets/news_block.dart';

/// The view for viewing the Articles in a category
///
/// A white bar with the category name and a scrollable list of Cards underneath
/// Very similar to the main view, but you cannot dismiss/save articles.
class CategoryView extends StatefulWidget {

  final Category category;
  List<Article> articles = new List<Article>();
  final ArticlePersistenceController apc;
  final Category saved;
  final Category dismissed;
  CategoryView(this.category, this.apc, this.saved, this.dismissed);

    @override
    _CategoryViewState createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {



    @override
  void initState() {
      super.initState();
      widget.articles.addAll(widget.category.getArticles());
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
                            itemCount: widget.articles.length,
                            itemBuilder: (context, index) {
                              final article = widget.articles[index];
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

    SlideTransition buildDismissible(context, index, animation, direction) {
      final article = widget.articles[index];
      return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset(0, 0),
          ).animate(animation),
          textDirection: direction,
          child: Dismissible(

              key: Key(article.url),
              child: NewsBlock.fromArticle(article),

              onDismissed: (direction) {
                switch(direction) {
                  case DismissDirection.endToStart: //to the left / dismissed
                    setState(() {
                      widget.dismissed.addArticle(widget.articles[index]);
                      widget.articles.removeAt(index);
                    });
                    break;
                  case DismissDirection.startToEnd: //to the right / saved
                    setState(() {
                      Article a = widget.articles[index];
                      widget.saved.addArticle(a);
                      widget.apc.saveArticleToDisk(a); //TODO debug, it is async
                      widget.articles.removeAt(index);
                    });
                    break;
                  default:
                    break;
                }
              },

              background: saveBackground(),
              secondaryBackground: dismissBackground()

          ));
    }
}
