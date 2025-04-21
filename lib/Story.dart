import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const PartyStoriesApp());
}

class PartyStoriesApp extends StatelessWidget {
  const PartyStoriesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: '党纪故事集',
      debugShowCheckedModeBanner: false,
      home: StoriesHomePage(),
    );
  }
}

class StoriesHomePage extends StatefulWidget {
  const StoriesHomePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _StoriesHomePageState createState() => _StoriesHomePageState();
}

class _StoriesHomePageState extends State<StoriesHomePage> {
  late List<StoryItem> stories;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeStories();
  }

  Future<void> _initializeStories() async {
    // Initialize the list of stories
    stories = [
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
        coverImage: "assets/storyimg/li.jpg",
        element: "梨",
        elementSvg: "assets/diy/li.svg",
        isUnlocked: false,
      ),
    ];

    await _loadUnlockedStatus();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadUnlockedStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      for (var i = 0; i < stories.length; i++) {
        final storyId = stories[i].title;
        final isUnlocked = prefs.getBool('story_unlocked_$storyId') ?? false;
        stories[i] = stories[i].copyWith(isUnlocked: isUnlocked);
      }
    } catch (e) {
      debugPrint('Error loading unlocked status: $e');
    }
  }

  Future<void> _saveUnlockedStatus(StoryItem story) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('story_unlocked_${story.title}', story.isUnlocked);
    } catch (e) {
      debugPrint('Error saving unlocked status: $e');
    }
  }

  List<StoryItem> get unlockedElements =>
      stories.where((story) => story.isUnlocked).toList();

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 95.0,
            pinned: false,
            backgroundColor: const Color.fromARGB(255, 248, 236, 236),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: const Color(0xFFF5F5F5),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_stories,
                        color: Color.fromARGB(255, 180, 20, 20),
                        size: 60,
                      ),
                      Text(
                        '阅读故事后解锁元素，用于diy文创',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 176, 32, 32),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final story = stories[index];
                return StoryCard(
                  story: story,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StoryDetailPage(
                          story: story,
                          onComplete: () async {
                            setState(() {
                              final updatedStory =
                                  story.copyWith(isUnlocked: true);
                              stories[index] = updatedStory;
                            });
                            await _saveUnlockedStatus(stories[index]);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
              childCount: stories.length,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 7),
                  const Text(
                    '已解锁元素',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '已解锁 ${unlockedElements.length} 个元素，可用于diy文创',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  unlockedElements.isEmpty
                      ? Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.lock_outline,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '阅读故事解锁元素',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 85,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: unlockedElements.length,
                            itemBuilder: (context, index) {
                              final element = unlockedElements[index];
                              return UnlockedElementCard(element: element);
                            },
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StoryItem {
  final String title;
  final String coverImage;
  final String element;
  final String elementSvg; 
  final bool isUnlocked;

  StoryItem({
    required this.title,
    required this.coverImage,
    required this.element,
    required this.elementSvg,
    this.isUnlocked = false,
  });

  StoryItem copyWith({
    String? title,
    String? coverImage,
    String? element,
    String? elementSvg,
    bool? isUnlocked,
  }) {
    return StoryItem(
      title: title ?? this.title,
      coverImage: coverImage ?? this.coverImage,
      element: element ?? this.element,
      elementSvg: elementSvg ?? this.elementSvg,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}

class StoryCard extends StatelessWidget {
  final StoryItem story;
  final VoidCallback onTap;

  const StoryCard({
    Key? key,
    required this.story,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisSize: MainAxisSize.min,
              children: [
                // 封面图片区域
                Container(
                  height: 220,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Image.asset(
                    story.coverImage,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 标题
                            Text(
                              story.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Row(
                              children: [
                                Icon(
                                  story.isUnlocked
                                      ? Icons.check_circle
                                      : Icons.lock_outline,
                                  size: 18,
                                  color: story.isUnlocked
                                      ? Colors.green
                                      : Colors.black45,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  story.isUnlocked
                                      ? '已解锁「${story.element}」元素'
                                      : '阅读后解锁「${story.element}」元素',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: story.isUnlocked
                                        ? Colors.green
                                        : Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // 主题图标放在右侧 图标
                      Container(
                        width: 50,
                        height: 50,
                        // decoration: BoxDecoration(
                        //   color: story.color,
                        //   shape: BoxShape.circle,
                        // ),
                        child: Center(
                          child: SvgPicture.asset(
                            story.elementSvg,
                            width: 35,
                            height: 35,
                            // colorFilter: const ColorFilter.mode(
                            //   Colors.white,
                            //   BlendMode.srcIn,
                            // ),
                          ),
                        ),
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
}

class StoryDetailPage extends StatefulWidget {
  final StoryItem story;
  final VoidCallback onComplete;

  const StoryDetailPage({
    Key? key,
    required this.story,
    required this.onComplete,
  }) : super(key: key);

  @override
  _StoryDetailPageState createState() => _StoryDetailPageState();
}

class _StoryDetailPageState extends State<StoryDetailPage> {
  bool _reachedEnd = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_checkScrollPosition);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_checkScrollPosition);
    _scrollController.dispose();
    super.dispose();
  }

  void _checkScrollPosition() {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 200) {
      setState(() {
        _reachedEnd = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 140.0,
            pinned: true,
            // 故事页面顶部
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                widget.story.title,
                style: const TextStyle(
                  color: Color.fromARGB(255, 58, 56, 56),
                  fontWeight: FontWeight.w500,
                  fontSize: 17.0,
                ),
                textAlign: TextAlign.center,
              ),
              background: Container(
                color: const Color(0xFFF5F5F5),
                child: Center(
                  child: SvgPicture.asset(
                    widget.story.elementSvg,
                    width: 70,
                    height: 70,
                    // colorFilter: const ColorFilter.mode(
                    //   Colors.white,
                    //   BlendMode.srcIn,
                    // ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStoryContent(widget.story.title),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _reachedEnd
          ? Container(
              height: 55,
              width: double.infinity,
              decoration: const BoxDecoration(
                // 透明
                color: Colors.white,
              ),
              child: Center(
                child: ElevatedButton(
                  onPressed: widget.story.isUnlocked
                      ? null
                      : () {
                          widget.onComplete();
                          _showUnlock(context);
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 9,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    widget.story.isUnlocked
                        ? '元素已解锁'
                        : '解锁「${widget.story.element}」元素',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  void _showUnlock(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: SizedBox(
          height: 250,
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  // color: widget.story.color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  widget.story.elementSvg,
                  width: 80,
                  height: 80,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '恭喜！你已解锁',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '「${widget.story.element}」',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  // color: widget.story.color,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '现在可以在diy文创中使用这个元素',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('关闭'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('返回'),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryContent(String title) {
    if (title == "鲁迅和猫头鹰") {
      return const Column(
        children: [
          Text(
            '''民间有谚语云：夜猫子进宅，没事不来。在一般人的印象当中，猫头鹰绝对不是一种吉祥的鸟儿，也更不会有人喜欢它。然而鲁迅先生对猫头鹰却情有独钟，一九二四年，鲁迅先生作过一首名为《我的失恋》的小诗，在诗中，先生写道：


我的所爱在山腰；

想去寻她山太高，

低头无法泪沾袍。

爱人赠我百蝶巾；

回她什么：猫头鹰。

从此翻脸不理我，

不知何故兮使我心惊。

为什么要把猫头鹰作为礼物送给所爱的人呢？鲁迅先生的老同学许寿裳在《我所认识的鲁迅》一书中谈到《我的失恋》这首诗，也提到猫头鹰。他说，读者一见到猫头鹰等等，也许只会“觉得有趣而已，殊不知猫头鹰是他自己所钟爱的，……还是一本正经，没有什么做作。”

当年与鲁迅先生比较接近的沈尹默在《回忆伟大的鲁迅》一文中也说，鲁迅“在大庭广众中，有时会凝然冷坐，不言不笑，衣冠又一向不甚修饰，毛发蓬蓬然，有人替他起了个绰号，叫猫头鹰。这个鸟和壁虎，鲁迅对于他们都不甚讨厌，实际上，毋宁说，还有点喜欢。”

原来鲁迅先生是很喜爱猫头鹰的，除了写诗外，鲁迅先生还不止一次地画过猫头鹰。北京图书馆藏有鲁迅于一九O九年前后，在杭州师范教书时手中的一些笔记和抄本。其中有他手订的一个小本子，这个本子宽16厘米，长11.5厘米，里面记有一些书名和一些人的地址，显然这是鲁迅先生日常备用的一本笔记。就是在这小本子的封面右上角，鲁迅先生自己手绘了一只猫头鹰作为装饰。

一九二七年，鲁迅先生的杂文集《坟》出版了，他自己又自作了一幅画作为封面，最主要的装饰图案还是猫头鹰。画中的猫头鹰站立在方框的右上角，歪着头，一眼圆睁，一眼紧闭，似乎正在凝神注视着什么。两眼之上还有两撮耸立的羽毛，最下则是两支锋利的爪了。这幅图画曾经作为《坟》的扉页印于书中。

鲁迅先生为什么要对人见人厌的猫头鹰情有独钟呢？原来他本身就是一个旧社会的叛逆者，他鄙视一切传统的封建道德，对很多事物常常一反常态地有着独特大胆的见解，甚至被人诬为大逆不道。鲁迅先生在《且介亭杂文二集.序言》中曾经说过：“我有时决不想在言论界求得胜利，因为我的言论有时是枭鸣，报告着不大吉利的事，我的言中，是大家会有不幸的。”

鲁迅先生在《谈蝙蝠》中还说：“人们对于夜里出来的动物，总不免有些讨厌它，大约因为他偏不睡觉，和自己的习惯不同，而且在错夜的沉睡或微行中，怕他会窥见什么秘密吧。”他还告诫人们不要只“欢迎喜鹊，憎恶枭鸟”，不要“只捡一点吉祥之兆来陶醉自己”。

鲁迅先生还说过，他不希罕娇嫩鸟雀的那些令人怜爱、使人陶醉的鸣唱，却热烈地期待着“只要一叫而人们大低震悚的怪鸱的真正的恶声！”

由此看来鲁迅先生的猫头鹰情结，也正缘于他以猫头鹰自喻，向黑暗制度的发起挑战的宣言书！''',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      );
    } else if (title == "焦裕禄的藤椅") {
      return const Column(
        children: [
          Text(
            '''　　55年前的2月7日清晨，长篇通讯《县委书记的榜样——焦裕禄》在中央人民广播电台播出。焦裕禄的名字和他带领全县干部群众与自然灾害顽强拼搏的事迹，从此传遍大江南北。

　　2014年3月18日，在河南省兰考县委常委扩大会议上，习近平总书记动情地回忆说：“我当时上初中一年级，政治课老师在念这篇通讯的过程中几度哽咽，多次泣不成声，同学们也流下眼泪。特别是念到焦裕禄同志肝癌晚期仍坚持工作，用一根棍子顶着肝部，藤椅右边被顶出一个大窟窿时，我受到深深震撼。”

　　让总书记深深震撼的那把藤椅，如今陈列在兰考县焦裕禄纪念馆里。藤椅上的大窟窿，仿佛在无声地诉说着焦裕禄当年在兰考工作的400多个日夜。

　　焦裕禄1922年出生，1946年加入中国共产党。解放战争后期，随军离开山东，到河南尉氏县工作。1953年到1962年，在洛阳矿山机器制造厂担任车间主任、科长。

　　1962年冬天，正是兰考县遭受内涝、风沙、盐碱“三害”最严重的时刻，上级选派焦裕禄到兰考工作，先后任县委第二书记、书记。焦裕禄到兰考上任前，党组织与他谈话时讲，兰考有三最，第一最苦，第二最穷，第三最难，要他在思想上做好经受最严峻考验的准备。当时如果焦裕禄不去兰考，他完全有正当理由。据他的妻子徐俊雅回忆，他在尉氏的时候就有肝病，肝就已经开始疼了，但是焦裕禄却对上级组织说：感谢党把我派到最困难的地方，越是困难的地方，越能锻炼人，不改变兰考的面貌，我决不离开这里。

　　为了早日根除“三害”，焦裕禄到兰考后，就立下“拼上老命大干一场，决心改变兰考面貌”的誓言，没日没夜地拼命工作。

　　1963年2月，兰考县除“三害”工作全面铺开。焦裕禄亲自带队下去搞调查，许多同志劝他不要下去，待在家听汇报，可是焦裕禄却说，“吃别人嚼过的馍没有味道”。他抽调120名干部、群众、技术员组成“三害”调查队，在全县大规模战风沙、斗内涝、治盐碱。三个月的时间里，焦裕禄不顾重病缠身，带领大家跑了120多个大队，行程5000余里，终于掌握了“三害”的第一手资料，在此基础上闯出了治理“三害”的新路子。

　　1964年春天，正当兰考人民同涝、沙、碱斗争胜利前进的时候，焦裕禄的肝病却越发重了。很多人都发现，无论开会、作报告，他经常把右脚踩在椅子上，用右膝顶住肝部。焦裕禄纪念园管理处副主任董亚娜介绍说：焦裕禄桌子上、床边放着的小东西日渐增多，茶缸盖、鸡毛掸子、长把刷子都是用来压迫止痛的。他棉袄上的第二和第三个扣子是不扣的，左手经常揣在怀里。人们留心观察，原来他越来越多地用左手按着时时作痛的肝部，或者用一根硬东西顶在右边的椅靠上。日子久了，他办公室那把藤椅的右边就被顶出了一个大窟窿。

　　病痛缓解以后，焦裕禄亲自动手，用藤条把藤椅上的窟窿一点点补好。但不久，藤椅又被顶破。工作太忙时，他就让子女来帮着修补藤椅。同志们和家人都劝他注意休息，要他好好疗养一下，他却总是笑着说：“病是个欺软怕硬的东西，你压住它，它就不欺侮你了。”

　　这样一把藤椅，为何始终没有被换掉？“坐在破椅子上不能革命吗？”焦裕禄这样说。

　　心中激荡着理想和信仰，生死便显得不再那么重要。就在这把藤椅上，焦裕禄写下了生命中最后一篇文章《兰考人民多奇志，敢教日月换新天》的提纲。

　　长期的劳累和一再拖延，焦裕禄的肝病越来越严重。1964年3月底，焦裕禄被送往医院，一个多月后病逝，年仅42岁。生命最后时刻，焦裕禄说的是“我没有完成党交给我的任务”，想的还是兰考人民，还是治“三害”，“活着我没有治好沙丘，死了也要看着兰考人民把沙丘治好”。

　　焦裕禄以“生也沙丘，死也沙丘，父老生死系”的赤诚，以“心中装着全体人民、唯独没有他自己”的公仆情怀，诠释着亲民爱民、艰苦奋斗、科学求实、迎难而上、无私奉献的焦裕禄精神。焦裕禄去世了，但焦裕禄精神仍在延续。50多年来，兰考一直在大力传承、弘扬和践行焦裕禄精神，特别是党的十八大以来，在党的坚强领导下，兰考城乡面貌和人民生活发生了翻天覆地的变化，兰考人民在根治“三害”的道路上接续奋斗，并取得了决定性胜利。2017年，兰考摘掉了贫困帽子，提前兑现了脱贫的庄严承诺。今年2月25日，全国脱贫攻坚总结表彰大会举行，中共兰考县委荣获全国脱贫攻坚先进集体。如今，拼搏、开放、生态、幸福成了兰考追赶跨越的新标签。历经半个多世纪的焦裕禄精神，其生命力在新时代迸发出特有的朴实魅力。''',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      );
    } else if (title == "彭司令拒梨") {
      return const Column(
        children: [
          Text(
            '''如今，彭雪枫将军已经离开我们75年了，但他心系群众、严明治军、廉洁奉公的很多故事仍广为流传，其中“彭司令拒梨”的故事更是家喻户晓。

1940年9月的一天，彭雪枫率领新四军第六支队在司令部驻地新兴集集会纪念“五卅”运动15周年，突然遭遇附近的日伪军偷袭。彭雪枫临危不惧，他站在主席台上鼓舞大家说，敌人从哪里来，我们就叫他滚回哪里去！

广大指战员在他机智果敢的指挥下，与日伪军浴血奋战到黄昏，毙伤敌伪军300多人，敌人狼狈逃离了新兴集。群众知道部队打胜仗的消息后欢欣不已，纷纷奔走相告，并商议着要去慰问子弟兵。大家都说天气炎热，不如送点土特产砀山梨子给战士们解解渴、消消暑，表达一点心意。乡亲们将一筐筐酥梨肩扛担挑到了部队驻地，见了战士们不由分说，将梨摆满桌上、地上，一个劲地叫战士们赶快来吃。

九月的砀山梨子格外香甜诱人，再加上乡亲们的一番盛情，有些战士就忍不住吃了起来。恰巧这时彭雪枫司令员赶来了，他一再感谢乡亲们的深情厚谊，但表示梨子坚决不能要，并把部队集合起来，严肃地批评吃了梨子的战士，说我们是人民的子弟兵，是人民养育了我们，为了人民利益与日伪军打仗是我们应尽的职责，不能因为打了胜仗就骄傲自满、高高在上，让群众感恩戴德。

他说，吃一个梨子算不了什么大事，但万恶都从小处起，“不拿群众一针一线”不是随便说着玩的，要时时警醒，处处落实。群众现在还很困难，收获一点梨子不容易，说不定还指望用这梨子换钱买些生活用品，咱们就是再渴也不能吃这砀山梨。他的语气虽很严厉，但其中饱含的军民鱼水之情，真挚而深沉，在场的每一个指战员都深受教育，一致表示要把梨子送还给乡亲们。吃了梨子的战士感到非常羞愧，主动照价赔偿。乡亲们见此，也都被感动得不得了，不好再坚持，只得听从彭司令的安排。

此事越传越广，方圆几百里的老百姓都说，彭司令带部队打了胜仗，保卫了咱们，却连一个梨子都舍不得吃，真是天下少有啊！这支部队在彭雪枫率领下，纪律严明，英勇顽强，在巩固和扩大淮北革命根据地的战斗中，取得了一个又一个胜利，是一支名副其实的威武之师、文明之师、胜利之师。''',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      );
    }

    // Default return for any other title
    return const Column(
      children: [
        Text("故事内容正在编写中..."),
      ],
    );
  }
}

class UnlockedElementCard extends StatelessWidget {
  final StoryItem element;

  const UnlockedElementCard({
    Key? key,
    required this.element,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            element.elementSvg,
            width: 36,
            height: 36,
          ),
          const SizedBox(height: 8),
          Text(
            element.element,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
