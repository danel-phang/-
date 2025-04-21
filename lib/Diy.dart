// import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import 'Story.dart';
// import 'package:image/image.dart' as img;

class DiyPage extends StatefulWidget {
  const DiyPage({Key? key}) : super(key: key);

  @override
  _DiyPageState createState() => _DiyPageState();
}

class _DiyPageState extends State<DiyPage> {
  // Selected background product image
  String? selectedProductImage;

  // List to store added SVG elements
  final List<DraggableItem> _items = [];

  // Controller for the scrollable lists
  final ScrollController _svgScrollController = ScrollController();
  final ScrollController _productScrollController = ScrollController();

  // GlobalKey for capturing the canvas as an image
  final GlobalKey _canvasKey = GlobalKey();

  // List to store unlocked SVG elements
  List<StoryItem> _unlockedElements = [];
  bool _isLoading = true;

  // Sample product images
  final List<String> productImages = [
    'assets/sale/product1.png',
    'assets/sale/product2.png',
    'assets/sale/product3.png',
    'assets/sale/product4.png',
    'assets/sale/product5.png',
  ];

  @override
  void initState() {
    super.initState();
    _loadUnlockedElements();
  }

  Future<void> _loadUnlockedElements() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<StoryItem> allStories = [
        StoryItem(
          title: "鲁迅和猫头鹰",
          coverImage: "assets/storyimg/mao.webp",
          element: "猫头鹰",
          elementSvg: "assets/diy/mao.svg",
          isUnlocked: false,
        ),
        StoryItem(
          title: "焦裕禄的藤椅",
          coverImage: "assets/storyimg/yizi.jpg",
          element: "藤椅",
          elementSvg: "assets/diy/yizi.svg",
          isUnlocked: false,
        ),
        StoryItem(
          title: "彭司令拒梨",
          coverImage: "assets/storyimg/peng.jpg",
          element: "梨",
          elementSvg: "assets/diy/li.svg",
          isUnlocked: false,
        ),
      ];

      // 从SharedPreferences加载解锁状态
      final prefs = await SharedPreferences.getInstance();

      for (var i = 0; i < allStories.length; i++) {
        final storyId = allStories[i].title;
        final isUnlocked = prefs.getBool('story_unlocked_$storyId') ?? false;
        allStories[i] = allStories[i].copyWith(isUnlocked: isUnlocked);
      }

      _unlockedElements =
          allStories.where((story) => story.isUnlocked).toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading unlocked elements: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _svgScrollController.dispose();
    _productScrollController.dispose();
    super.dispose();
  }

  void _addSvgElement(String assetPath) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    setState(() {
      _items.add(
        DraggableItem(
          id: id,
          assetPath: assetPath,
          position: Offset(
            MediaQuery.of(context).size.width / 2 - 50,
            MediaQuery.of(context).size.height / 2 - 50,
          ),
          size: const Size(100, 100),
          rotation: 0,
        ),
      );
    });
  }

  void _setProductImage(String imagePath) {
    setState(() {
      selectedProductImage = imagePath;
    });
  }

  void _removeItem(String id) {
    setState(() {
      _items.removeWhere((item) => item.id == id);
    });
  }

  void _updateItem(String id,
      {Offset? position, Size? size, double? rotation}) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      setState(() {
        final item = _items[index];
        _items[index] = item.copyWith(
          position: position ?? item.position,
          size: size ?? item.size,
          rotation: rotation ?? item.rotation,
        );
      });
    }
  }

  Future<void> _captureCanvas() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      RenderRepaintBoundary boundary = _canvasKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();

        // final img.Image? capturedImage = img.decodeImage(pngBytes);
        // if (capturedImage != null) {
        //   // 垂直翻转图像
        //   final flippedImage = img.flipVertical(capturedImage);
        //   pngBytes = Uint8List.fromList(img.encodePng(flippedImage));
        // }

        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }

        showDialog(
          context: context,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.memory(
                    pngBytes,
                    // height: 300,
                    // fit: BoxFit.contain,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    '你的DIY创作已完成!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    '是否要购买这个定制产品?',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _shareCreation(pngBytes);
                        },
                        child: const Text('分享'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('取消'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _proceedToPurchase(pngBytes);
                        },
                        child:
                            const Text('立即购买', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('创建预览失败: $e')),
      );
    }
  }

// 分享创作
  void _shareCreation(Uint8List imageBytes) {
    // TODO: 实现分享功能，可以使用share_plus等插件
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('分享功能即将上线')),
    );
  }

  void _proceedToPurchase(Uint8List imageBytes) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('开始购买流程'),
        content: const Text('你的DIY创作已准备好，即将进入购买流程...'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigator.of(context).push(MaterialPageRoute(
              //   builder: (context) => PurchasePage(imageData: imageBytes),
              // ));
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DIY 创作'),
        backgroundColor: const ui.Color.fromARGB(255, 255, 252, 252),
        toolbarHeight: 45.0, // Increased app bar height
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _captureCanvas,
            iconSize: 28.0,
            tooltip: '保存创作',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                RepaintBoundary(
                  key: _canvasKey,
                  child: Container(
                    color: Colors.grey[200],
                    width: double.infinity,
                    height: double.infinity,
                    child: Stack(
                      children: [
                        if (selectedProductImage != null)
                          Positioned.fill(
                            child: Image.asset(
                              selectedProductImage!,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ..._items.map((item) => DraggableSvgElement(
                              item: item,
                              onPositionChanged: (offset) =>
                                  _updateItem(item.id, position: offset),
                              onSizeChanged: (size) =>
                                  _updateItem(item.id, size: size),
                              onRotationChanged: (angle) =>
                                  _updateItem(item.id, rotation: angle),
                              onRemove: () => _removeItem(item.id),
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 16.0, bottom: 8.0),
                      child: Text(
                        '选择DIY商品',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        controller: _productScrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: productImages.length,
                        itemBuilder: (context, index) {
                          final imagePath = productImages[index];
                          final isSelected = selectedProductImage == imagePath;

                          return GestureDetector(
                            onTap: () => _setProductImage(imagePath),
                            child: Container(
                              width: 80,
                              height: 80,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected ? Colors.blue : Colors.grey,
                                  width: isSelected ? 3 : 1,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(7.0),
                                child: Image.asset(
                                  imagePath,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                      child: Row(
                        children: [
                          const Text(
                            '已解锁元素',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${_unlockedElements.length}个)',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 80,
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _unlockedElements.isEmpty
                              ? const Center(
                                  child: Text(
                                    '暂无已解锁元素，请先阅读故事解锁元素',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  controller: _svgScrollController,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _unlockedElements.length,
                                  itemBuilder: (context, index) {
                                    final element = _unlockedElements[index];

                                    return GestureDetector(
                                      onTap: () =>
                                          _addSvgElement(element.elementSvg),
                                      child: Container(
                                        width: 80,
                                        height: 80,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                              color: Colors.grey[400]!),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: SvgPicture.asset(
                                                element.elementSvg,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              element.element,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black87,
                                              ),
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DraggableItem {
  final String id;
  final String assetPath;
  final Offset position;
  final Size size;
  final double rotation;

  const DraggableItem({
    required this.id,
    required this.assetPath,
    required this.position,
    required this.size,
    required this.rotation,
  });

  DraggableItem copyWith({
    String? id,
    String? assetPath,
    Offset? position,
    Size? size,
    double? rotation,
  }) {
    return DraggableItem(
      id: id ?? this.id,
      assetPath: assetPath ?? this.assetPath,
      position: position ?? this.position,
      size: size ?? this.size,
      rotation: rotation ?? this.rotation,
    );
  }
}

class DraggableSvgElement extends StatefulWidget {
  final DraggableItem item;
  final Function(Offset) onPositionChanged;
  final Function(Size) onSizeChanged;
  final Function(double) onRotationChanged;
  final VoidCallback onRemove;

  const DraggableSvgElement({
    Key? key,
    required this.item,
    required this.onPositionChanged,
    required this.onSizeChanged,
    required this.onRotationChanged,
    required this.onRemove,
  }) : super(key: key);

  @override
  _DraggableSvgElementState createState() => _DraggableSvgElementState();
}

class _DraggableSvgElementState extends State<DraggableSvgElement> {
  late Offset _position;
  late Size _size;
  late double _rotation;

  @override
  void initState() {
    super.initState();
    _position = widget.item.position;
    _size = widget.item.size;
    _rotation = widget.item.rotation;
  }

  @override
  void didUpdateWidget(DraggableSvgElement oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.position != widget.item.position) {
      _position = widget.item.position;
    }
    if (oldWidget.item.size != widget.item.size) {
      _size = widget.item.size;
    }
    if (oldWidget.item.rotation != widget.item.rotation) {
      _rotation = widget.item.rotation;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _position += details.delta;
          });
          widget.onPositionChanged(_position);
        },
        child: Stack(
          children: [
            Transform.rotate(
              angle: _rotation,
              child: SizedBox(
                width: _size.width,
                height: _size.height,
                child: SvgPicture.asset(
                  widget.item.assetPath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    double newWidth =
                        (_size.width + details.delta.dx).clamp(30.0, 300.0);
                    double newHeight =
                        (_size.height + details.delta.dy).clamp(30.0, 300.0);
                    _size = Size(newWidth, newHeight);
                  });
                  widget.onSizeChanged(_size);
                },
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.zoom_out_map,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: GestureDetector(
                onPanUpdate: (details) {
                  final centerX = _size.width / 2;
                  final centerY = _size.height / 2;

                  final angle = math.atan2(
                    details.localPosition.dy - centerY,
                    details.localPosition.dx - centerX,
                  );

                  setState(() {
                    _rotation = angle;
                  });
                  widget.onRotationChanged(_rotation);
                },
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.rotate_right,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              child: GestureDetector(
                onTap: widget.onRemove,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
