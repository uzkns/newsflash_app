import 'package:flutter/material.dart';
import 'package:flutter_app/controllers/article_categorization_controller.dart';
import 'package:flutter_app/controllers/article_persistence_controller.dart';
import 'package:flutter_app/models/article.dart';
import 'package:flutter_app/models/category.dart';
import 'package:flutter_app/views/widgets/news_block.dart';


/// The view for viewing the Articles in a category
///
/// A white bar with the category name and a scrollable list of Cards underneath
class CategoryView extends StatefulWidget {

  final Category category;
  final ArticlePersistenceController apc;
  final Category saved;

  CategoryView(this.category, this.apc, this.saved);

    @override
    _CategoryViewState createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {

  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();

  @override
    void initState() {
        super.initState();
        ArticleCategorizationController.removeDuplicates(widget.category.getArticles(), widget.saved.getArticles());
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
                        child: AnimatedList(
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            key: listKey,
                            initialItemCount: widget.category.getArticles().length,
                            itemBuilder: (context, index, animation) {
                              return buildDismissible(context, index, animation, null);
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
      final article = widget.category.getArticles()[index];
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
                      widget.category.getArticles().removeAt(index);
                    });
                    break;
                  case DismissDirection.startToEnd: //to the right / saved
                    setState(() {
                      Article a = widget.category.getArticles()[index];
                      widget.saved.addArticle(a);
                      widget.apc.saveArticleToDisk(a);
                      widget.category.getArticles().removeAt(index);
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
