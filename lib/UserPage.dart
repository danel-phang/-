import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  String _name = "张三";
  String _email = "zhangsan@example.com";
  String? _avatarPath;
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = _name;
    _emailController.text = _email;
    _loadAvatarPath();
  }

  Future<void> _loadAvatarPath() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _avatarPath = prefs.getString('avatar_path');
    });
  }

  Future<void> _saveAvatarPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('avatar_path', path);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("选择图片来源"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("拍照"),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("从相册选择"),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final XFile? pickedFile = await picker.pickImage(source: source);
      if (pickedFile == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String fileName =
          'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String localPath = '${appDocDir.path}/$fileName';

      final File localImage = File(localPath);
      await File(pickedFile.path).copy(localPath);

      await _saveAvatarPath(localPath);

      setState(() {
        _avatarPath = localPath;
        _isLoading = false;
      });

      _showSuccessSnackBar("头像更新成功！");
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar("选择图片时出错：$e");
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color.fromARGB(255, 224, 34, 21),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _showEditProfileDialog() async {
    _nameController.text = _name;
    _emailController.text = _email;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("编辑个人资料"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "姓名",
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "邮箱",
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                // const SizedBox(height: 16),
                // TextField(
                //   controller: _phoneController,
                //   decoration: const InputDecoration(
                //     labelText: "手机号",
                //     prefixIcon: Icon(Icons.phone),
                //   ),
                //   keyboardType: TextInputType.phone,
                // ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("取消"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _name = _nameController.text;
                  _email = _emailController.text;
                });
                Navigator.of(context).pop();
                _showSuccessSnackBar("个人资料更新成功！");
              },
              child: const Text("保存"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: const Text("个人中心"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[300],
                                  image: _avatarPath != null
                                      ? DecorationImage(
                                          image: FileImage(File(_avatarPath!)),
                                          fit: BoxFit.cover,
                                        )
                                      : const DecorationImage(
                                          image: AssetImage(
                                              'assets/default_avatar.png'),
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _email,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _showEditProfileDialog,
                          icon: const Icon(
                            Icons.edit,
                            color: Color.fromARGB(255, 215, 28, 15),
                          ),
                          label: const Text("编辑资料",
                              style: TextStyle(
                                fontSize: 16,
                                color: Color.fromARGB(255, 215, 28, 15),
                              )),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[100],
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Account info section
                  // const SizedBox(height: 16),
                  // _buildSectionHeader("账户信息"),
                  // _buildListTile(
                  //   icon: Icons.phone_android,
                  //   title: "手机号码",
                  //   subtitle: _phone,
                  // ),
                  _buildListTile(
                    icon: Icons.security,
                    title: "账户安全",
                    subtitle: "修改密码、安全设置",
                    showDivider: false,
                    onTap: () {},
                  ),

                  // Additional sections
                  const SizedBox(height: 16),
                  _buildSectionHeader("应用设置"),
                  _buildListTile(
                    icon: Icons.notifications_none,
                    title: "通知设置",
                    onTap: () {},
                  ),
                  _buildListTile(
                    icon: Icons.language,
                    title: "语言设置",
                    subtitle: "简体中文",
                    onTap: () {},
                  ),
                  _buildListTile(
                    icon: Icons.color_lens_outlined,
                    title: "主题设置",
                    subtitle: "跟随系统",
                    showDivider: false,
                    onTap: () {},
                  ),

                  const SizedBox(height: 16),
                  _buildSectionHeader("其他"),
                  _buildListTile(
                    icon: Icons.help_outline,
                    title: "帮助中心",
                    onTap: () {},
                  ),
                  _buildListTile(
                    icon: Icons.info_outline,
                    title: "关于我们",
                    showDivider: false,
                    onTap: () {},
                  ),

                  const SizedBox(height: 24),
                  TextButton.icon(
                    onPressed: () {
                      // Handle logout
                    },
                    icon: const Icon(
                      Icons.logout,
                      color: Color.fromARGB(255, 215, 28, 15),
                    ),
                    label: const Text(
                      "退出登录",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 215, 28, 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    bool showDivider = true,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Theme.of(context).primaryColor),
          title: Text(title),
          subtitle: subtitle != null ? Text(subtitle) : null,
          trailing: onTap != null
              ? const Icon(Icons.arrow_forward_ios, size: 16)
              : null,
          onTap: onTap,
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 72,
            endIndent: 16,
            color: Colors.grey[200],
          ),
      ],
    );
  }
}
