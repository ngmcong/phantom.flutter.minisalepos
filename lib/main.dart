import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:minisalepos/viewinward.dart';
import 'package:minisalepos/viewoutward.dart';

import 'viewcustomer.dart';
import 'viewproduct.dart';

void main() => runApp(const PageViewExampleApp());

class PageViewExampleApp extends StatelessWidget {
  const PageViewExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: SafeArea(child: const PageViewExample())),
    );
  }
}

class PageViewExample extends StatefulWidget {
  const PageViewExample({super.key});

  @override
  State<PageViewExample> createState() => _PageViewExampleState();
}

class _PageViewExampleState extends State<PageViewExample>
    with TickerProviderStateMixin {
  late PageController _pageViewController;
  late TabController _tabController;
  bool visibleMenu = true;

  @override
  void initState() {
    super.initState();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _pageViewController = PageController();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _pageViewController.dispose();
    _tabController.dispose();
  }

  Widget menuIconButton() {
    return SizedBox(
      width: 32,
      child: IconButton(
        icon:
            visibleMenu
                ? Image.asset('assets/collapse-icon.png')
                : Image.asset('assets/expand-icon.png'),
        onPressed: () {
          setState(() {
            visibleMenu = !visibleMenu;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Visibility(
          visible: visibleMenu,
          maintainAnimation: true,
          maintainState: true,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 1000),
            curve: Curves.fastOutSlowIn,
            opacity: visibleMenu ? 1 : 0,
            child: Column(
              children: [
                SizedBox(
                  width: 160,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: menuIconButton(),
                  ),
                ),
                Row(
                  children: [
                    SizedBox(
                      height: 80.0,
                      width: 80.0,
                      child: IconButton(
                        onPressed: () {
                          _updateCurrentPageIndex(0);
                        },
                        icon: Image.asset('assets/product-icon.png'),
                      ),
                    ),
                    SizedBox(
                      height: 80.0,
                      width: 80.0,
                      child: IconButton(
                        onPressed: () {
                          _updateCurrentPageIndex(1);
                        },
                        icon: Image.asset('assets/customers-icon.png'),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 80.0,
                      child: const Text(
                        'Sản phẩm',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      width: 80.0,
                      child: const Text(
                        'Khách hàng',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                      height: 80.0,
                      width: 80.0,
                      child: IconButton(
                        onPressed: () {
                          _updateCurrentPageIndex(2);
                        },
                        icon: Image.asset('assets/inward-icon.png'),
                      ),
                    ),
                    SizedBox(
                      height: 80.0,
                      width: 80.0,
                      child: IconButton(
                        onPressed: () {
                          _updateCurrentPageIndex(3);
                        },
                        icon: Image.asset('assets/retail-icon.png'),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 80.0,
                      child: const Text(
                        'Nhập hàng',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      width: 80.0,
                      child: const Text(
                        'Bán hàng',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: Colors.grey, width: 1)),
          ),
          child: Column(
            children: [
              Visibility(visible: !visibleMenu, child: menuIconButton()),
            ],
          ),
        ),
        Expanded(
          child: PageView(
            controller: _pageViewController,
            onPageChanged: _handlePageViewChanged,
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              ProductView(),
              CustomerView(),
              InwardInvoiceView(),
              OutwardInvoiceView(),
            ],
          ),
        ),
      ],
    );
  }

  void _handlePageViewChanged(int currentPageIndex) {
    if (!_isOnDesktopAndWeb) {
      return;
    }
    _tabController.index = currentPageIndex;
  }

  void _updateCurrentPageIndex(int index) {
    _tabController.index = index;
    _pageViewController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  bool get _isOnDesktopAndWeb {
    if (kIsWeb) {
      return true;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return true;
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
        return false;
    }
  }
}

class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.tabController,
    required this.currentPageIndex,
    required this.onUpdateCurrentPageIndex,
    required this.isOnDesktopAndWeb,
  });

  final int currentPageIndex;
  final TabController tabController;
  final void Function(int) onUpdateCurrentPageIndex;
  final bool isOnDesktopAndWeb;

  @override
  Widget build(BuildContext context) {
    if (!isOnDesktopAndWeb) {
      return const SizedBox.shrink();
    }
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            splashRadius: 16.0,
            padding: EdgeInsets.zero,
            onPressed: () {
              if (currentPageIndex == 0) {
                return;
              }
              onUpdateCurrentPageIndex(currentPageIndex - 1);
            },
            icon: const Icon(Icons.arrow_left_rounded, size: 32.0),
          ),
          TabPageSelector(
            controller: tabController,
            color: colorScheme.surface,
            selectedColor: colorScheme.primary,
          ),
          IconButton(
            splashRadius: 16.0,
            padding: EdgeInsets.zero,
            onPressed: () {
              if (currentPageIndex == 2) {
                return;
              }
              onUpdateCurrentPageIndex(currentPageIndex + 1);
            },
            icon: const Icon(Icons.arrow_right_rounded, size: 32.0),
          ),
        ],
      ),
    );
  }
}
