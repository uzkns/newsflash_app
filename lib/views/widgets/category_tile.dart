import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/controllers/article_persistence_controller.dart';
import 'package:flutter_app/models/category.dart';

import '../category_view.dart';

/// A Category tile
///
/// A small square box with rounded corners and an image and text in it,
/// created out of a Category.
///
/// In the home.dart view these will appear at the top of the Article list.
/// clicking it will take you to the Category view for it's category.
class CategoryTile extends StatelessWidget {

    final Category c;
    final ArticlePersistenceController apc;
    final Category saved;

    CategoryTile(this.c, this.apc, this.saved);


    @override
    Widget build(BuildContext context) {
        return GestureDetector(

          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CategoryView(this.c, this.apc, this.saved)
                )
            );
          },

          child: Container(
              margin: EdgeInsets.only(right: 10, left: 10),
              child: Stack(
                  children: <Widget>[
                      ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: CachedNetworkImage(imageUrl: c.imgUrl, width: 150, height: 60, fit: BoxFit.cover)
                      ),
                      Container(
                          alignment: Alignment.center,
                          width: 150, height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            color: Colors.black26,
                          ),
                          child: Text(c.name, style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500
                              ),
                          ),
                      )
                  ]
              )
          ),
        );
    }


}
