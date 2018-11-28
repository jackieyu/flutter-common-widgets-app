import 'dart:async';

import 'package:flutter/material.dart';
import '../routers/application.dart';
import '../common/Style.dart';
import '../model/cat.dart';
import '../model/widget.dart';
import '../widgets/index.dart';
import '../components/widget_item.dart';



enum CateOrWigdet {
  Cat,
  WidgetDemo
}
class CategoryHome extends StatefulWidget {
  CategoryHome(this.name);
  final String name;

  @override
  _CategoryHome createState() => new _CategoryHome();
}

class _CategoryHome extends State<CategoryHome> {
  String title = '';
  // 显示列表 cat or widget;
  List<Cat> categories = [];
  List<WidgetPoint> widgetPoints = [];
  List<Cat> catHistory = new List();

  CatControlModel catControl = new CatControlModel();
  WidgetControlModel widgetControl = new WidgetControlModel();
  // 所有的可用demos;
  List widgetDemosList = new WidgetDemoList().getDemos();

  @override
  void initState() {
    super.initState();
    // 初始化加入顶级的name
    this.getCatByName(widget.name).then((Cat cat) {
      catHistory.add(cat);
      searchCatOrWigdet();
    });
  }

  Future<Cat> getCatByName(String name) async {
    return await catControl.getCatByName(name);
  }
  Future<bool> back() {
    if (catHistory.length == 1) {
      return Future<bool>.value(true);
    }
    catHistory.removeLast();
    searchCatOrWigdet();
    return Future<bool>.value(false);

  }
  void go(Cat cat) {
    catHistory.add(cat);
    searchCatOrWigdet();
  }
  void searchCatOrWigdet() async {
    // 假设进入这个界面的parent一定存在
    Cat parentCat = catHistory.last;

    int depth = catHistory.length;

    // 继续搜索显示下一级depth: depth + 1, parentId: parentCat.id
    List<Cat> _categories = await catControl.getList(new Cat(parentId: parentCat.id));
    List<WidgetPoint> _widgetPoints = new List();
    if (_categories.isEmpty) {
      _widgetPoints = await widgetControl.getList(new WidgetPoint(catId: parentCat.id));
    }


    this.setState(() {
      categories = _categories;
      title  = parentCat.name;
      widgetPoints = _widgetPoints;
    });
  }

  void onCatgoryTap(Cat cat) {
      go(cat);
  }
  void onWidgetTap(WidgetPoint widgetPoint) {
    String targetName = widgetPoint.name;
    String targetRouter = '/category/error/404';
    print("widgetDemosList> ${widgetDemosList}");
    widgetDemosList.forEach((item) {
      // print("targetRouter = item.routerName> ${[item.name,targetName]}");
      if (item.name == targetName) {
        targetRouter = item.routerName;
      }
    });
    print("router> ${targetRouter}");
    Application.router.navigateTo(context, "${targetRouter}");
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: WillPopScope(
          onWillPop: () {
            return back();
        },
        child: new Container(
            child: new CategoryOrWidgetList(
              categorys: categories,
              widgetPoints: widgetPoints,
              onCatgoryTap: onCatgoryTap,
              onWidgetTap: onWidgetTap
            ),
        )
      )
    );
  }
}



class CategoryOrWidgetList extends StatelessWidget {

  List<Cat> categorys = [];
  List<WidgetPoint> widgetPoints = [];

  var onCatgoryTap;
  var onWidgetTap;
  CategoryOrWidgetList({
    this.categorys,
    this.widgetPoints,
    this.onCatgoryTap,
    this.onWidgetTap,
  });

  Widget build(BuildContext context) {
    print("categorys $categorys");
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, //每行2个
          mainAxisSpacing: 0.0, //主轴(竖直)方向间距
          crossAxisSpacing: 0.0, //纵轴(水平)方向间距
          childAspectRatio: 0.8 //纵轴缩放比例
      ),
      itemCount: widgetPoints.length == 0 ? categorys.length : widgetPoints.length,
      itemBuilder: (BuildContext context, int index) {
        if (widgetPoints.length > 0) {
          return new WidgetItem(
            title: widgetPoints[index].name,
            onTap: () {
              onWidgetTap(widgetPoints[index]);
            },
          );
        }
        return new WidgetItem(
          title: categorys[index].name,
          onTap: () {
            onCatgoryTap(categorys[index]);
          },
        );
      },
    );
  }
}







