import 'package:flutter/material.dart';

class PassagePage extends StatelessWidget {
  final String filePath;
  final String title1;

  const PassagePage({
    super.key,
    required this.title1,
    required this.filePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title1),
      ),
      body: FutureBuilder(
        future: loadTextAsset(context, filePath),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              final content = snapshot.data!;
              final titleEndIndex = content.indexOf('\n');
              final title = content.substring(0, titleEndIndex).trim();
              final passage = content.substring(titleEndIndex).trim();
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      passage,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const Center(child: Text("No data found in the file."));
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<String> loadTextAsset(BuildContext context, String path) async {
    return await DefaultAssetBundle.of(context).loadString(path);
  }
}
