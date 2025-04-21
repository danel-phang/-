import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const LongMarchApp());
}

class LongMarchApp extends StatelessWidget {
  const LongMarchApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Long March Journey',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.notoSansTextTheme(),
      ),
      home: const LongMarchGame(),
    );
  }
}

class LongMarchGame extends StatefulWidget {
  const LongMarchGame({Key? key}) : super(key: key);

  @override
  _LongMarchGameState createState() => _LongMarchGameState();
}

class _LongMarchGameState extends State<LongMarchGame>
    with TickerProviderStateMixin {
  int _currentNodeIndex = 0;
  bool _isRolling = false;
  bool _isMoving = false;
  int _diceValue = 1;
  late AnimationController _diceController;
  Offset _playerPosition = Offset.zero;

  // Define waypoints between nodes for more realistic movement
  final Map<String, List<Offset>> _routeWaypoints = {
    '0-1': [
      const Offset(0.80, 0.684),
      const Offset(
          0.70, 0.684), // Intermediate point between Ruijin and Xiangjiang
    ],
    // '1-2': [
    //   Offset(0.68, 0.65), // Intermediate point between Xiangjiang and Zunyi
    //   Offset(0.60, 0.60),
    // ],
    // '2-3': [
    //   Offset(0.50, 0.52), // Intermediate point between Zunyi and Chishui
    // ],
    // '3-4': [
    //   Offset(0.42, 0.44), // Intermediate point between Chishui and Jinshajiang
    // ],
    '4-5': [
      const Offset(0.3, 0.678),
      const Offset(
          0.13, 0.678) // Intermediate point between Jinshajiang and Daduhe
    ],
    // '5-6': [
    //   Offset(0.27, 0.28), // Intermediate point between Daduhe and Ludingqiao
    // ],
    // '6-7': [
    //   Offset(0.22, 0.23), // Intermediate point between Ludingqiao and Xueshan
    // ],
    // '7-8': [
    //   Offset(0.18, 0.20), // Intermediate point between Xueshan and Maogong
    // ],
    // '8-9': [
    //   Offset(0.16, 0.18), // Intermediate point between Maogong and Caodi
    // ],
    // '9-10': [
    //   Offset(0.13, 0.14), // Intermediate point between Caodi and Lazikou
    // ],
    // '10-11': [
    //   Offset(0.10, 0.10), // Intermediate point between Lazikou and Dahui
    // ],
    // '11-12': [
    //   Offset(0.07, 0.07), // Intermediate point between Dahui and Yanan
    // ],
  };

  String _currentPlayerAsset = 'assets/player/player1.png';
  bool _showPlayerSelector = false;
  final List<String> _playerOptions = [
    'assets/player/player1.png',
    'assets/player/player2.png',
    'assets/player/player3.png',
    'assets/player/player4.png',
    'assets/player/player5.png',
  ];

  void _selectPlayer(String assetPath) {
    setState(() {
      _currentPlayerAsset = assetPath;
      _showPlayerSelector = false;
    });
  }

  final List<MapNode> _nodes = [
    MapNode(
      id: 0,
      name: "瑞金",
      position: const Offset(0.9, 0.685), // Adjusted position
      story: "1934年10月，中央红军从江西瑞金出发，开始了举世闻名的长征。",
      imageAsset: "assets/long_march/ruijin.jpg",
    ),
    MapNode(
      id: 1,
      name: "血战湘江",
      position: const Offset(0.665, 0.675), // Adjusted position
      story: "1934年11月，红军在湘江边与国民党军激战，壮烈牺牲了许多同志，打开了长征的序幕。",
      imageAsset: "assets/long_march/xiangjiang.png",
    ),
    MapNode(
      id: 2,
      name: "遵义会议",
      position: const Offset(0.415, 0.6), // Adjusted position
      story: "1935年1月，红军占领贵州遵义，并在此召开了著名的遵义会议，确立了毛泽东在党内的领导地位。",
      imageAsset: "assets/long_march/zunyi.jpg",
    ),
    MapNode(
      id: 3,
      name: "四渡赤水",
      position: const Offset(0.334, 0.582), // Adjusted position
      story: "1935年1月至3月，红军四次渡过赤水河，以灵活机动的战略战术，彻底摆脱了国民党军队的围追堵截。",
      imageAsset: "assets/long_march/chishui.png",
    ),
    MapNode(
      id: 4,
      name: "巧渡金沙江",
      position: const Offset(0.38, 0.618), // Adjusted position
      story: "1935年5月，红军在云南境内巧妙渡过金沙江，粉碎了敌人企图将红军消灭在江边的计划。",
      imageAsset: "assets/long_march/jinshajiang.jpg",
    ),
    MapNode(
      id: 5,
      name: "强渡大渡河",
      position: const Offset(0.127, 0.586), // Adjusted position
      story: "1935年5月，红军在四川境内强渡大渡河，重演了曾经彝族首领小叶丹反抗清军的壮举。",
      imageAsset: "assets/long_march/daduhe.jpg",
    ),
    MapNode(
      id: 6,
      name: "飞夺泸定桥",
      position: const Offset(0.145, 0.54), // Adjusted position
      story: "1935年5月29日，红军突破敌人重重防守，成功夺取泸定桥，创造了中国革命史上的奇迹。",
      imageAsset: "assets/long_march/ludingqiao.png",
    ),
    MapNode(
      id: 7,
      name: "翻雪山",
      position: const Offset(0.175, 0.503), // Adjusted position
      story: "1935年6月，红军翻越终年积雪的夹金山，战士们冒着严寒和缺氧的危险，展现了革命军队的坚强意志。",
      imageAsset: "assets/long_march/xueshan.jpg",
    ),
    MapNode(
      id: 8,
      name: "懋功会师",
      position: const Offset(0.16, 0.474), // Adjusted position
      story: "1935年6月，红军主力与红四方面军在四川懋功会师，实现了长征的第一次胜利会师。",
      imageAsset: "assets/long_march/maogong.jpg",
    ),
    MapNode(
      id: 9,
      name: "过草地",
      position: const Offset(0.189, 0.436), // Adjusted position
      story: "1935年8月，红军经过了茫茫草地的艰难跋涉，战胜了饥饿、疾病和恶劣环境，展现了不屈的革命精神。",
      imageAsset: "assets/long_march/caodi.jpg",
    ),
    MapNode(
      id: 10,
      name: "腊子口战役",
      position: const Offset(0.245, 0.386), // Adjusted position
      story: "1935年9月，红军在甘肃腊子口击败国民党军队的围追堵截，为长征的胜利开辟了道路。",
      imageAsset: "assets/long_march/lazi.jpg",
    ),
    MapNode(
      id: 11,
      name: "大会师",
      position: const Offset(0.34, 0.342), // Adjusted position
      story: "1936年10月，红一、二、四方面军在甘肃会宁地区胜利会师，标志着长征的胜利结束。",
      imageAsset: "assets/long_march/dahui.jpg",
    ),
    MapNode(
      id: 12,
      name: "延安",
      position: const Offset(0.545, 0.312), // Adjusted position
      story: "1937年1月，中央红军到达陕北延安，建立了革命根据地，为抗日战争和解放战争奠定了基础。",
      imageAsset: "assets/long_march/yanan.jpg",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _diceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    // Initialize player position to the first node
    _playerPosition = _nodes[0].position;
  }

  @override
  void dispose() {
    _diceController.dispose();
    super.dispose();
  }

  void _rollDice() {
    if (_isRolling || _isMoving) return;

    setState(() {
      _isRolling = true;
    });

    _diceController.forward(from: 0.0).then((_) {
      final random = Random();
      final newValue = random.nextInt(6) + 1;

      setState(() {
        _diceValue = newValue;
        _isRolling = false;
        _movePlayer(newValue);
      });
    });
  }

  // Modified to move player along waypoints
  void _movePlayer(int steps) {
    if (_currentNodeIndex + steps >= _nodes.length) {
      steps = _nodes.length - 1 - _currentNodeIndex;
    }

    if (steps <= 0) return;

    setState(() {
      _isMoving = true;
    });

    // First get to next node through waypoints
    _moveAlongPath(_currentNodeIndex, _currentNodeIndex + 1, 0, () {
      setState(() {
        _currentNodeIndex++;
      });

      if (_currentNodeIndex < _nodes.length && steps > 1) {
        _movePlayer(steps - 1);
      } else {
        setState(() {
          _isMoving = false;
        });

        _showStoryDialog(_nodes[_currentNodeIndex]);
      }
    });
  }

  // Move along waypoints between nodes
  void _moveAlongPath(int fromNodeIndex, int toNodeIndex,
      int currentWaypointIndex, VoidCallback onCompleted) {
    String pathKey = '$fromNodeIndex-$toNodeIndex';
    List<Offset> waypoints = _routeWaypoints[pathKey] ?? [];

    if (currentWaypointIndex < waypoints.length) {
      // Move to next waypoint
      setState(() {
        _playerPosition = waypoints[currentWaypointIndex];
      });

      Future.delayed(const Duration(milliseconds: 300), () {
        _moveAlongPath(
            fromNodeIndex, toNodeIndex, currentWaypointIndex + 1, onCompleted);
      });
    } else {
      // Move to destination node
      setState(() {
        _playerPosition = _nodes[toNodeIndex].position;
      });

      Future.delayed(const Duration(milliseconds: 300), onCompleted);
    }
  }

  void _showStoryDialog(MapNode node) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 16,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  node.imageAsset,
                  fit: BoxFit.cover,
                  height: 200,
                  width: double.infinity,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        node.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        node.story,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('继续旅程'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          InteractiveViewer(
            boundaryMargin: const EdgeInsets.all(20),
            minScale: 0.5,
            maxScale: 4.0,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/long_march/LongMarch.png',
                        fit: BoxFit.contain,
                      ),
                    ),

                    // 节点
                    ..._nodes.map((node) => Positioned(
                          left: node.position.dx * constraints.maxWidth,
                          top: node.position.dy * constraints.maxHeight,
                          child: Stack(
                            children: [
                              // Node circle
                              Container(
                                width: 13,
                                height: 13,
                                decoration: BoxDecoration(
                                  color: node.id <= _currentNodeIndex
                                      ? Colors.red
                                      : Colors.grey,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                              // Node name label
                              Positioned(
                                top: 12,
                                left: -20,
                                width: 60,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    node.name,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: node.id <= _currentNodeIndex
                                          ? Colors.red
                                          : Colors.black54,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),

                    // 玩家标记 - position is now controlled directly
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      left: _playerPosition.dx * constraints.maxWidth - 10,
                      top: _playerPosition.dy * constraints.maxHeight + 12,
                      child: Image.asset(
                        _currentPlayerAsset,
                        width: 35,
                        height: 35,
                      )
                          .animate(target: _isMoving ? 1 : 0)
                          .scaleXY(end: 1.2, duration: 300.ms)
                          .then()
                          .scaleXY(end: 1.0, duration: 300.ms),
                    ),
                  ],
                );
              },
            ),
          ),
          // 地图标题
          Positioned(
            top: 5,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 50),
              child: const Text(
                '重走长征路',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 196, 11, 11),
                ),
              ),
            ),
          ),

          // 骰子
          Positioned(
            bottom: 40,
            right: 20,
            child: GestureDetector(
              onTap: _rollDice,
              child: AnimatedBuilder(
                animation: _diceController,
                builder: (context, child) {
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      // ..setEntry(3, 2, 0.001) // 透视效果
                      ..rotateX(_diceController.value * 4 * pi)
                      ..rotateY(_diceController.value * 4 * pi)
                      ..rotateZ(_diceController.value * 2 * pi),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        image: _isRolling
                            ? null
                            : DecorationImage(
                                image: AssetImage(
                                    'assets/dice/dice$_diceValue.png'),
                                fit: BoxFit.cover,
                              ),
                      ),
                      child: _isRolling
                          ? AnimatedBuilder(
                              animation: _diceController,
                              builder: (context, _) {
                                final tempFace =
                                    ((_diceController.value * 18) % 6).floor() +
                                        1;
                                return Image.asset(
                                  'assets/dice/dice$tempFace.png',
                                  width: 80,
                                  height: 80,
                                );
                              },
                            )
                          : Container(),
                    ),
                  );
                },
              ),
            ),
          ),

          Positioned(
            top: 55,
            right: 8,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.32,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '当前位置:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _nodes[_currentNodeIndex].name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '下一站:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentNodeIndex < _nodes.length - 1
                        ? _nodes[_currentNodeIndex + 1].name
                        : '旅程结束',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _currentNodeIndex < _nodes.length - 1
                          ? Colors.blue
                          : Colors.green,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    '游戏说明:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '点击右下角骰子，按点数前进，重温长征艰辛历程。',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // 确保内容左对齐
              children: [
                if (_showPlayerSelector)
                  Container(
                    width: 200,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '选择角色',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 203, 34, 22),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.start, // 确保角色图标左对齐
                          children: _playerOptions
                              .map((asset) => GestureDetector(
                                    onTap: () => _selectPlayer(asset),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: _currentPlayerAsset == asset
                                              ? Colors.red
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Image.asset(
                                        asset,
                                        width: 40,
                                        height: 40,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ).animate().slide(
                      duration: 100.ms,
                      begin: const Offset(0, 1),
                      end: Offset.zero),

                // 修改后的头像按钮，使用Container固定尺寸并保持一致布局
                Container(
                  alignment: Alignment.centerLeft, // 确保头像左对齐
                  width: 110, // 固定宽度
                  height: 110, // 固定高度
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showPlayerSelector = !_showPlayerSelector;
                      });
                    },
                    child: Container(
                      child: Image.asset(
                        _currentPlayerAsset,
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MapNode {
  final int id;
  final String name;
  final Offset position;
  final String story;
  final String imageAsset;

  MapNode({
    required this.id,
    required this.name,
    required this.position,
    required this.story,
    required this.imageAsset,
  });
}
