import 'package:flutter/material.dart';
import 'package:mov/screens/drawer_screen.dart';
import 'package:mov/screens/finder_screen.dart';
import 'package:mov/utils/constants.dart';
import 'package:mov/utils/file_manager.dart' as file;
import 'package:mov/utils/navi.dart' as navi;
import 'package:mov/utils/scroll_top_with_controller.dart' as scrollTop;
import 'package:mov/utils/toast_alert.dart' as alert;
import 'package:mov/widgets/bottom_navigation.dart';
import 'package:mov/widgets/bottom_navigation_item.dart';
import 'package:mov/widgets/custom_loading_spin_kit_ring.dart';
import 'package:mov/widgets/custom_main_appbar_content.dart';
import 'package:mov/widgets/movie_card.dart';
import 'package:mov/widgets/movie_card_container.dart';
import 'package:mov/widgets/shadowless_floating_button.dart';
import 'package:sizer/sizer.dart';
import 'package:mov/services/movie.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  //for custom drawer opening
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  //for scroll upping
  ScrollController? _scrollController;
  bool showBackToTopButton = false;
  Color? themeColor;
  int? activeInnerPageIndex;
  List<MovieCard>? _movieCards;
  bool showSlider = true;
  String title = kHomeScreenTitleText;
  int bottomBarIndex = 1;

  Future<void> loadData() async {
    MovieModel movieModel = MovieModel();
    _movieCards = (bottomBarIndex == 1)
        ? await movieModel.getMovies(
      moviesType: MoviePageType.values[activeInnerPageIndex!],
      themeColor: themeColor!,
    )
        : await movieModel.getFavorites(
        themeColor: themeColor!, bottomBarIndex: bottomBarIndex);
    setState(() {
      scrollTop.scrollToTop(_scrollController!);
      showBackToTopButton = false;
    });
  }

  void pageSwitcher(int index) {
    setState(() {
      bottomBarIndex = (index == 2) ? 2 : 1;
      title = (index == 2) ? kFavoriteScreenTitleText : kHomeScreenTitleText;
      showSlider = !(index == 2);
      _movieCards = null;
      loadData();
    });
  }

  void movieCategorySwitcher(int index) {
    setState(() {
      activeInnerPageIndex = index;
      _movieCards = null;
      loadData();
    });
  }

  void loginButtonPressed() {
    Navigator.pushNamed(context, '/login');
  }

  void registerButtonPressed() {
    Navigator.pushNamed(context, '/register');
  }

  @override
  void initState() {
    super.initState();
    () async {
      themeColor = await file.currentTheme();
      print(themeColor);
      _scrollController = ScrollController()
        ..addListener(() {
          setState(() {
            showBackToTopButton = (_scrollController!.offset >= 200);
          });
        });
      activeInnerPageIndex = 0;
      setState(() {
        loadData();
      });
    }();
  }

  @override
  void dispose() {
    if (_scrollController != null) _scrollController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (themeColor == null)
        ? CustomLoadingSpinKitRing(loadingColor: themeColor)
        : Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        shadowColor: Colors.transparent.withOpacity(0.1),
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: kAppBarColor,
        bottom: PreferredSize(
          child: CustomMainAppBarContent(
            showSlider: showSlider,
            title: title,
            activeButtonIndex: activeInnerPageIndex!,
            activeColor: themeColor!,
            buttonFistOnPressed: (index) =>
                movieCategorySwitcher(index),
            buttonSecondOnPressed: (index) =>
                movieCategorySwitcher(index),
            buttonThirdOnPressed: (index) =>
                movieCategorySwitcher(index),
            searchOnPressed: () => navi.newScreen(
              context: context,
              newScreen: () => FinderScreen(
                themeColor: themeColor!,
              ),
            ),
          ),
          preferredSize:
          Size.fromHeight((bottomBarIndex == 1) ? 16.0.h : 7.h),
        ),
      ),
      body: (_movieCards == null)
          ? CustomLoadingSpinKitRing(loadingColor: themeColor)
          : (_movieCards!.length == 0)
          ? Center(child: Text(k404Text))
          : MovieCardContainer(
        scrollController: _scrollController!,
        themeColor: themeColor!,
        movieCards: _movieCards!,
      ),
      bottomNavigationBar: BottomNavigation(
        activeColor: themeColor!,
        index: bottomBarIndex,
        children: [
          BottomNavigationItem(
            icon: Icon(Icons.more_horiz),
            iconSize: 35.sp,
            onPressed: () =>
                _scaffoldKey.currentState!.openDrawer(),
          ),
          BottomNavigationItem(
            icon: Icon(Icons.videocam),
            iconSize: 28.sp,
            onPressed: () {
              pageSwitcher(1);
            },
          ),
          BottomNavigationItem(
              icon: Icon(Icons.bookmark_sharp),
              iconSize: 23.sp,
              onPressed: () {
                pageSwitcher(2);
              }),
        ],
      ),
      drawerEnableOpenDragGesture: false,
      drawer: DrawerScreen(
        colorChanged: (color) {
          themeColor = color;
          setState(() {
            alert.toastAlert(
                message: kAppliedTheme, themeColor: themeColor);
          });
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: loginButtonPressed,
            backgroundColor: Colors.white,
            child: Icon(Icons.login),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: registerButtonPressed,
            backgroundColor: Colors.white,
            child: Icon(Icons.person_add),
          ),
        ],
      ),
    );
  }
}
