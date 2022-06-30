import 'dart:async';
import 'dart:convert';

import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/Constant.dart';
import 'package:eshop/Helper/PushNotificationService.dart';
import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Helper/SqliteData.dart';
import 'package:eshop/Helper/String.dart';
import 'package:eshop/Model/Section_Model.dart';
import 'package:eshop/Provider/HomeProvider.dart';
import 'package:eshop/Provider/UserProvider.dart';
import 'package:eshop/Screen/Cart.dart';
import 'package:eshop/Screen/Favorite.dart';
import 'package:eshop/Screen/Login.dart';
import 'package:eshop/Screen/MyProfile.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:bottom_bar/bottom_bar.dart';

import 'All_Category.dart';
//import 'Cart.dart';
import 'HomePage.dart';
import 'NotificationLIst.dart';
import 'Product_Detail.dart';
import 'Sale.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<Dashboard> {
  int _selBottom = 0;

  PageController _pageController = PageController();
  bool _isNetworkAvail = true;
  var db = new DatabaseHelper();

  @override
  void initState() {
    super.initState();
    initDynamicLinks();
    db.getTotalCartCount(context);
    final pushNotificationService = PushNotificationService(
        context: context, pageController: _pageController);
    pushNotificationService.initialise();

/*    _tabController.addListener(() {
      Future.delayed(Duration(seconds: 0)).then((value) {
        if (_tabController.index == 3) {
          if (CUR_USERID == null) {
            Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => Login(),
                ));
            _tabController.animateTo(0);
          }
        }
      });

      setState(() {
        _selBottom = _tabController.index;
      });
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selBottom != 0) {
          _pageController.animateToPage(0,
              duration: Duration(milliseconds: 1000), curve: Curves.easeInOut);
          return false;
        }
        return true;
      },
      child: Scaffold(
        //extendBody: true,
        backgroundColor: Theme.of(context).colorScheme.lightWhite,
        appBar: _getAppBar(),
        body: PageView(
          controller: _pageController,
          children: [
            HomePage(),
            AllCategory(),
            Sale(),
            //Cart(
            // fromBottom: true,
            //),
            Cart(
              fromBottom: true,
            ),
            MyProfile()
          ],
          onPageChanged: (index) {
            setState(() => _selBottom = index);
          },
        ),

        bottomNavigationBar: _getBottomBar(),
        /* bottomNavigationBar: Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 24,
                spreadRadius: 1)
          ]),
          height: kBottomNavigationBarHeight,
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaY: 8, sigmaX: 8),
                child: Container(
                  height: kBottomNavigationBarHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.4),
                        ],
                        stops: [
                          0.1,
                          1,
                        ]),
                  ),
                  child: _getBottomBar(),
                ),
              ),
            ),
          ),
        ),*/
      ),
    );
  }

  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData? dynamicLink) async {
      final Uri? deepLink = dynamicLink?.link;

      if (deepLink != null) {
        if (deepLink.queryParameters.length > 0) {
          int index = int.parse(deepLink.queryParameters['index']!);

          int secPos = int.parse(deepLink.queryParameters['secPos']!);

          String? id = deepLink.queryParameters['id'];

          String? list = deepLink.queryParameters['list'];

          getProduct(id!, index, secPos, list == "true" ? true : false);
        }
      }
    }, onError: (OnLinkErrorException e) async {
      print(e.message);
    });

    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;
    if (deepLink != null) {
      if (deepLink.queryParameters.length > 0) {
        int index = int.parse(deepLink.queryParameters['index']!);

        int secPos = int.parse(deepLink.queryParameters['secPos']!);

        String? id = deepLink.queryParameters['id'];

        // String list = deepLink.queryParameters['list'];

        getProduct(id!, index, secPos, true);
      }
    }
  }

  Future<void> getProduct(String id, int index, int secPos, bool list) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          ID: id,
        };

        // if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID;
        Response response =
            await post(getProductApi, headers: headers, body: parameter)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];

          List<Product> items = [];

          items =
              (data as List).map((data) => new Product.fromJson(data)).toList();

          Navigator.of(context).push(CupertinoPageRoute(
              builder: (context) => ProductDetail(
                    index: list ? int.parse(id) : index,
                    model: list
                        ? items[0]
                        : sectionList[secPos].productList![index],
                    secPos: secPos,
                    list: list,
                  )));
        } else {
          if (msg != "Products Not Found !") setSnackbar(msg, context);
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      {
        if (mounted)
          setState(() {
            setSnackbar(getTranslated(context, 'NO_INTERNET_DISC')!, context);
          });
      }
    }
  }

  AppBar _getAppBar() {
    String? title;
    if (_selBottom == 1)
      title = getTranslated(context, 'CATEGORY');
    else if (_selBottom == 2)
      title = getTranslated(context, 'OFFER');
    else if (_selBottom == 3)
      title = getTranslated(context, 'MYBAG');
    else if (_selBottom == 4) title = getTranslated(context, 'PROFILE');

    return AppBar(
      elevation: 0,
      centerTitle: false,
      //centerTitle: _selBottom == 0 ? true : false,
      title: _selBottom == 0
          ? SvgPicture.asset(
              'assets/images/titleicon.svg',
              height: 35,
            )
          : Text(
              title!,
              style: TextStyle(
                  color: colors.primary, fontWeight: FontWeight.normal),
            ),

      /* leading: _selBottom == 0
          ? InkWell(
              child: Center(
                  child: SvgPicture.asset(
                imagePath + "search.svg",
                height: 20,
                color: colors.primary,
              )),
              onTap: () {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => Search(),
                    ));
              },
            )
          : null,*/
      // iconTheme: new IconThemeData(color: colors.primary),
      // centerTitle:_curSelected == 0? false:true,
      actions: <Widget>[
        /* _selBottom == 0
            ? Container()
            : IconButton(
                icon: SvgPicture.asset(
                  imagePath + "search.svg",
                  height: 20,
                  color: colors.primary,
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => Search(),
                      ));
                }),*/

        IconButton(
          icon: SvgPicture.asset(
            imagePath + "desel_notification.svg",
            color: colors.primary,
          ),
          onPressed: () {
            CUR_USERID != null
                ? Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => NotificationList(),
                    ))
                : Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => Login(),
                    ));
          },
        ),
        IconButton(
          padding: EdgeInsets.all(0),
          icon: SvgPicture.asset(
            imagePath + "desel_fav.svg",
            color: colors.primary,
          ),
          onPressed: () {
            CUR_USERID != null
                ? Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => Favorite(),
                    ))
                : Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => Login(),
                    ));
          },
        ),
      ],
      backgroundColor: Theme.of(context).colorScheme.lightWhite,
    );
  }

  Widget _getBottomBar() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 10),
      height: context.watch<HomeProvider>().checkIsScrollingDown
          ? 0
          : kBottomNavigationBarHeight,
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))
          /*  boxShadow: [
          BoxShadow(
              color: Theme.of(context).colorScheme.black26, blurRadius: 10)
        ],*/
          ),
      child: BottomBar(
        duration: Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
        selectedIndex: _selBottom,
        onTap: (int index) {
          /* if (CUR_USERID == null && index == 3) {
           */ /* Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => Login(),
                ));
            _pageController.jumpToPage(0);
            setState(() => _selBottom = 0);*/ /*
          } else {*/
          _pageController.jumpToPage(index);
          setState(() => _selBottom = index);
          //  }
        },
        items: <BottomBarItem>[
          BottomBarItem(
            icon: _selBottom == 0
                ? SvgPicture.asset(
                    imagePath + "sel_home.svg",
                    color: colors.primary,
                  )
                : SvgPicture.asset(
                    imagePath + "desel_home.svg",
                    color: colors.primary,
                  ),
            title: Text(getTranslated(context, 'HOME_LBL')!),
            activeColor: colors.primary,
          ),
          BottomBarItem(
              icon: _selBottom == 1
                  ? SvgPicture.asset(
                      imagePath + "category01.svg",
                      color: colors.primary,
                    )
                  : SvgPicture.asset(
                      imagePath + "category.svg",
                      color: colors.primary,
                    ),
              title: Text(getTranslated(context, 'category')!),
              activeColor: colors.primary),
          BottomBarItem(
            icon: _selBottom == 2
                ? SvgPicture.asset(
                    imagePath + "sale02.svg",
                    color: colors.primary,
                  )
                : SvgPicture.asset(
                    imagePath + "sale.svg",
                    color: colors.primary,
                  ),
            title: Text(getTranslated(context, 'SALE')!),
            activeColor: colors.primary,
          ),
          BottomBarItem(
            icon: Selector<UserProvider, String>(
              builder: (context, data, child) {
                return Stack(
                  children: [
                    _selBottom == 3
                        ? SvgPicture.asset(
                            imagePath + "cart01.svg",
                            color: colors.primary,
                          )
                        : SvgPicture.asset(
                            imagePath + "cart.svg",
                            color: colors.primary,
                          ),
                    (data != null && data.isNotEmpty && data != "0")
                        ? new Positioned.directional(
                            end: 0,
                            textDirection: Directionality.of(context),
                            top: 0,
                            child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: colors.primary),
                                child: new Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(3),
                                    child: new Text(
                                      data,
                                      style: TextStyle(
                                          fontSize: 7,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .white),
                                    ),
                                  ),
                                )),
                          )
                        : Container()
                  ],
                );
              },
              selector: (_, homeProvider) => homeProvider.curCartCount,
            ),
            title: Text(getTranslated(context, 'CART')!),
            activeColor: colors.primary,
          ),
          BottomBarItem(
            icon: _selBottom == 4
                ? SvgPicture.asset(
                    imagePath + "profile01.svg",
                    color: colors.primary,
                  )
                : SvgPicture.asset(
                    imagePath + "profile.svg",
                    color: colors.primary,
                  ),
            title: Text('Profile'),
            activeColor: colors.primary,
          ),
        ],
      ),
    );
    //old tabbar
    /*return Material(
        color: Theme.of(context).colorScheme.white,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.white,
            boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.black26, blurRadius: 10)],
          ),
          child: TabBar(
            onTap: (_) {
              if (_tabController.index == 3) {
                if (CUR_USERID == null) {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => Login(),
                      ));
                  _tabController.animateTo(0);
                }
              }
            },
            controller: _tabController,
            tabs: [
              Tab(
                icon: _selBottom == 0
                    ? SvgPicture.asset(imagePath + "sel_home.svg",color: colors.primary,)
                    : SvgPicture.asset(imagePath + "desel_home.svg",color: colors.primary,),
                text:
                    _selBottom == 0 ? getTranslated(context, 'HOME_LBL') : null,
              ),
              Tab(
                icon: _selBottom == 1
                    ? SvgPicture.asset(imagePath + "category01.svg",color: colors.primary,)
                    : SvgPicture.asset(imagePath + "category.svg",color: colors.primary,),
                text:
                    _selBottom == 1 ? getTranslated(context, 'category') : null,
              ),
              Tab(
                icon: _selBottom == 2
                    ? SvgPicture.asset(imagePath + "sale02.svg",color: colors.primary,)
                    : SvgPicture.asset(imagePath + "sale.svg",color: colors.primary,),
                text: _selBottom == 2 ? getTranslated(context, 'SALE') : null,
              ),
              Tab(
                icon: Selector<UserProvider, String>(
                  builder: (context, data, child) {

                    return Stack(
                      children: [
                        Center(
                          child: _selBottom == 3
                              ? SvgPicture.asset(imagePath + "cart01.svg",color: colors.primary,)
                              : SvgPicture.asset(imagePath + "cart.svg",color: colors.primary,),
                        ),
                        (data != null && data.isNotEmpty && data != "0")
                            ? new Positioned.directional(
                                bottom: _selBottom == 3 ? 6 : 20,
                                textDirection: Directionality.of(context),
                                end: 0,
                                child: Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: colors.primary),
                                    child: new Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(3),
                                        child: new Text(
                                          data,
                                          style: TextStyle(
                                              fontSize: 7,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context).colorScheme.white),
                                        ),
                                      ),
                                    )),
                              )
                            : Container()
                      ],
                    );
                  },
                  selector: (_, homeProvider) => homeProvider.curCartCount,
                ),


                text: _selBottom == 3 ? getTranslated(context, 'CART') : null,
              ),
              Tab(
                icon: _selBottom == 4
                    ? SvgPicture.asset(imagePath + "profile01.svg",color: colors.primary,)
                    : SvgPicture.asset(imagePath + "profile.svg",color: colors.primary,),
                text:
                    _selBottom == 4 ? getTranslated(context, 'ACCOUNT') : null,
              ),
            ],
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(color: colors.primary, width: 5.0),
              insets: EdgeInsets.fromLTRB(50.0, 0.0, 50.0, 70.0),
            ),
            labelColor: colors.primary,
          ),
        ));*/
  }

  @override
  void dispose() {
    //   _tabController.dispose();
    super.dispose();
  }
}
