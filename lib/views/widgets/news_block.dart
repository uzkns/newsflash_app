import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/article.dart';
import 'package:flutter_app/views/article_view.dart';


/// An article Card
///
/// A big Card with rounded corners, inside it is an image with a title and a
/// short description underneath.
///
/// These represent the Articles in a list in home.dart view. Clicking on it
/// will take you to the Article view
class NewsBlock extends StatelessWidget {
  final String title, description, urlToImage, url;

  NewsBlock(this.title, this.description, this.urlToImage, this.url);
  static fromArticle(Article a) {
    return new NewsBlock(a.title, a.description, a.urlToImage, a.url);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ArticleView(this.url)
                )
            );
        },

        child: Container(
            margin: EdgeInsets.only(bottom: 4),
            padding: EdgeInsets.symmetric(horizontal: 4),
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(bottomRight: Radius.circular(6),bottomLeft:  Radius.circular(6))
            ),
            child: Card(
                elevation: 3.0,
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Column(
                        children: <Widget>[
                            ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: CachedNetworkImage(
                                    imageUrl: this.urlToImage, fit: BoxFit.cover
                                )
                            ),
                            SizedBox(height: 6),
                            Text(
                                this.title,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500
                                )
                            ),
                            SizedBox(height: 6),
                            Text(
                                this.description,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                ),
                            )
                        ],
                    ),
                ),
            )
        ),
    );
  }
}

/// The background for saving an article by swiping it to the right.
///
/// It is a solid green color with a floppy drive/"save symbol" and
/// the word "Save" written in white.
Widget saveBackground() {
  return Container(
    color: Colors.green,
    child: Align(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Icon(
            Icons.save_outlined,
            color: Colors.white,
          ),
          Text(
            " Save",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
      alignment: Alignment.centerLeft,
    ),
  );
}

/// The background for dismissing an article by swiping it to the left.
///
/// It is a solid red color with a trash can and the word
/// "Dismiss" written in white.
Widget dismissBackground() {
  return Container(
    color: Colors.red,
    child: Align(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Icon(
            Icons.delete,
            color: Colors.white,
          ),
          Text(
            " Dismiss",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.right,
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
      alignment: Alignment.centerRight,
    ),
  );
}

