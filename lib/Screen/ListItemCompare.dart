import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/src/iterable_extensions.dart';
import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/String.dart';
import 'package:eshop/Model/Section_Model.dart';
import 'package:eshop/Provider/ProductDetailProvider.dart';
import 'package:eshop/Screen/Product_Detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/src/provider.dart';

import '../Helper/Session.dart';

class ListItemCom extends StatefulWidget {
  final Key? key;
  final Product? productList;
  final ValueChanged<bool>? isSelected;
  final int? secPos;
  final int? len, index;

  //int? notificationoffset;

  ListItemCom({
    this.productList,
    this.isSelected,
    this.secPos,
    this.len,
    this.key,
    this.index,

    /*,this.notificationoffset*/
  });

  @override
  _ListItemNotiState createState() => _ListItemNotiState();
}

class _ListItemNotiState extends State<ListItemCom> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return productItem();
  }

  Widget productItem() {
    List<Product> compareList =
        context.read<ProductDetailProvider>().compareList;

    /* if (widget.index! < widget.len!) {*/
    String? offPer;
    double price =
        double.parse(widget.productList!.prVarientList![0].disPrice!);
    if (price == 0) {
      price = double.parse(widget.productList!.prVarientList![0].price!);
    } else {
      double off =
          double.parse(widget.productList!.prVarientList![0].price!) - price;
      offPer = ((off * 100) /
              double.parse(widget.productList!.prVarientList![0].price!))
          .toStringAsFixed(2);
    }

    double width = deviceWidth! * 0.45;
    var extPro =
        compareList.firstWhereOrNull((cp) => cp.id == widget.productList!.id);

    return Container(
        height: 255,
        width: width,
        child: Card(
          elevation: 0.2,
          margin: EdgeInsetsDirectional.only(bottom: 5, end: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  alignment: Alignment.topRight,
                  padding: EdgeInsetsDirectional.only(end: 5.0, top: 5.0),
                  child: InkWell(
                    child: extPro != null
                        ? Icon(
                            Icons.check_circle,
                            color: colors.primary,
                            size: 22,
                          )
                        : Icon(
                            Icons.circle_outlined,
                            color: colors.primary,
                            size: 22,
                          ),
                    onTap: () {
                      setState(() {
                        isSelected = !isSelected;
                        widget.isSelected!(isSelected);
                      });
                    },
                  ),
                ),
                Expanded(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    clipBehavior: Clip.none,
                    children: [
                      Padding(
                          padding: EdgeInsetsDirectional.only(top: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(5),
                                topRight: Radius.circular(5)),
                            child: Hero(
                              tag: "${widget.productList!.id}",
                              child: FadeInImage(
                                image: CachedNetworkImageProvider(
                                    widget.productList!.image!),
                                height: double.maxFinite,
                                width: double.maxFinite,
                                fit: extendImg ? BoxFit.fill : BoxFit.contain,
                                imageErrorBuilder:
                                    (context, error, stackTrace) => erroWidget(
                                  double.maxFinite,
                                ),

                                //errorWidget: (context, url, e) => placeHolder(width),
                                placeholder: placeHolder(
                                  double.maxFinite,
                                ),
                              ),
                            ),
                          )),
                      offPer != null
                          ? Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: colors.red,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text(
                                    offPer + "%",
                                    style: TextStyle(
                                        color: colors.whiteTemp,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 9),
                                  ),
                                ),
                                margin: EdgeInsets.all(5),
                              ),
                            )
                          : Container(),
                      Divider(
                        height: 1,
                      ),
                      /*   Positioned.directional(
                          textDirection: Directionality.of(context),
                          end: 0,
                          bottom: -18,
                          child: Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: productList[index].isFavLoading!
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                        height: 15,
                                        width: 15,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 0.7,
                                        )),
                                  )
                                : InkWell(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        productList[index].isFav == "0"
                                            ? Icons.favorite_border
                                            : Icons.favorite,
                                        size: 15,
                                      ),
                                    ),
                                    onTap: () {

                                      if (CUR_USERID != null) {
                                        productList[index].isFav == "0"
                                            ? _setFav(index)
                                            : _removeFav(index);
                                      } else {
                                        Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                              builder: (context) => Login()),
                                        );
                                      }
                                    },
                                  ),
                          ),
                        ),*/
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: 5.0,
                    top: 5,
                  ),
                  child: Row(
                    children: [
                      RatingBarIndicator(
                        rating: double.parse(widget.productList!.rating!),
                        itemBuilder: (context, index) => Icon(
                          Icons.star_rate_rounded,
                          color: Colors.amber,
                          //color: colors.primary,
                        ),
                        unratedColor: Colors.grey.withOpacity(0.5),
                        itemCount: 5,
                        itemSize: 12.0,
                        direction: Axis.horizontal,
                        itemPadding: EdgeInsets.all(0),
                      ),
                      Text(
                        " (" + widget.productList!.noOfRating! + ")",
                        style: Theme.of(context).textTheme.overline,
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                      start: 5.0, top: 5, bottom: 5),
                  child: Text(
                    widget.productList!.name!,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.fontColor,
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    Text(" " + CUR_CURRENCY! + " " + price.toString() + " ",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.fontColor,
                            fontWeight: FontWeight.bold)),
                    Text(
                      double.parse(widget
                                  .productList!.prVarientList![0].disPrice!) !=
                              0
                          ? CUR_CURRENCY! +
                              "" +
                              widget.productList!.prVarientList![0].price!
                          : "",
                      style: Theme.of(context).textTheme.overline!.copyWith(
                          decoration: TextDecoration.lineThrough,
                          letterSpacing: 0),
                    ),
                  ],
                ),
              ],
            ),
            onTap: () {
              Product model = widget.productList!;
              // widget.notificationoffset = 0;

              Navigator.push(
                context,
                PageRouteBuilder(
                    // transitionDuration: Duration(seconds: 1),
                    pageBuilder: (_, __, ___) => ProductDetail(
                        model: model,
                        secPos: widget.secPos,
                        index: widget.index,
                        list: true
                        //  title: sectionList[secPos].title,
                        )),
              );
            },
          ),
        ));
    /*} else {
        return Container();
      }*/
  }

  /* shimmerCompare() {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.simmerBase,
      highlightColor: Theme.of(context).colorScheme.simmerHigh,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, __) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Container(
              width: deviceWidth! * 0.45,
              height: 255,
              color: Theme.of(context).colorScheme.white,
            )),
        itemCount: 10,
      ),
    );
  }*/
//list of notification shown
/*Widget listItem1() {
    // NotificationModel model = wi[index];

    DateTime time1 = DateTime.parse(widget.userNoti!.date!);

    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: 5.0,
        bottom: 10.0,
      ),
      child: Container(
        decoration: BoxDecoration(
            color:,
            boxShadow: <BoxShadow>[
              BoxShadow(
                  blurRadius: 10.0,
                  offset: const Offset(5.0, 5.0),
                  color:
                  Theme
                      .of(context)
                      .colorScheme
                      .fontColor
                      .withOpacity(0.1),
                  spreadRadius: 1.0),
            ],
            borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              isSelected
                  ? Icon(
                Icons.check_circle,
                color: colors.primary,
                size: 22,
              )
                  : Container(),
              Padding(
                  padding: EdgeInsetsDirectional.only(start: 10.0),
                  child: widget.userNoti!.type == "comment"
                      ? Icon(Icons.message,
                      color: Theme
                          .of(context)
                          .colorScheme
                          .darkColor)
                      : SvgPicture.asset(
                    "assets/images/likefilled_button.svg",
                    semanticsLabel: 'like icon',
                    color: Theme
                        .of(context)
                        .colorScheme
                        .darkColor,
                    height: 22,
                    width: 22,
                  )),
              Expanded(
                  child: Padding(
                    padding:
                    const EdgeInsetsDirectional.only(start: 13.0, end: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(widget.userNoti!.message!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme
                                .of(context)
                                .textTheme
                                .subtitle1
                                ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme
                                    .of(context)
                                    .colorScheme
                                    .fontColor
                                    .withOpacity(0.9),
                                fontSize: 15.0,
                                letterSpacing: 0.1)),
                        Padding(
                            padding: const EdgeInsetsDirectional.only(top: 8.0),
                            child: Text(convertToAgo(time1, 2)!,
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .caption
                                    ?.copyWith(
                                    fontWeight: FontWeight.normal,
                                    color: Theme
                                        .of(context)
                                        .colorScheme
                                        .fontColor
                                        .withOpacity(0.7),
                                    fontSize: 11)))
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }*/
}
