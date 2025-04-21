import 'package:flutter/material.dart';

class History extends StatelessWidget {
  const History({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: ListView(
          padding: const EdgeInsets.all(15.0),
          children: <Widget>[
            _buildHeaderSection(),
            const SizedBox(height: 2),
            const ImageCard(
              imagePath: 'assets/place/中共一大上海会址.png',
              title: '第一站: 中共一大上海会址',
              description: '中国共产党第一次全国代表大会会址，见证了中国共产党的诞生。',
            ),
            const ImageCard(
              imagePath: 'assets/place/浙江嘉兴南湖红船.png',
              title: '第二站: 浙江嘉兴南湖红船',
              description: '中共一大胜利闭幕地，象征中国革命的源头。',
            ),
            const ImageCard(
              imagePath: 'assets/place/古田会议会址.png',
              title: '第三站: 古田会议会址',
              description: '1929年古田会议的召开地，确立了党对军队的绝对领导。',
            ),
            const ImageCard(
              imagePath: 'assets/place/瑞金革命遗址.png',
              title: '第四站: 瑞金革命遗址',
              description: '中央革命根据地的心脏地带，中华苏维埃共和国的诞生地。',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.only(top: 0, bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '红色足迹',
            style: TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
              color: Colors.red[900],
            ),
          ),
          const Text(
            '探寻中国革命历史的重要地标',
            style: TextStyle(
              fontSize: 15.0,
              color: Color.fromARGB(255, 101, 101, 101),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class ImageCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const ImageCard({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12.0),
              topRight: Radius.circular(12.0),
            ),
            child: Hero(
              tag: imagePath,
              child: Image.asset(
                imagePath,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded) return child;
                  return AnimatedOpacity(
                    opacity: frame == null ? 0 : 1,
                    duration: const Duration(milliseconds: 50),
                    curve: Curves.easeOut,
                    child: child,
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[800],
                  ),
                ),
                const SizedBox(height: 6.0),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 1.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
