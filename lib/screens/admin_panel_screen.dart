import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../services/profile_service.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<UserProfile> _users = [];
  List<Map<String, dynamic>> _reports = [];
  bool _isLoadingUsers = true;
  bool _isLoadingReports = true;
  String _searchQuery = '';
  Map<String, dynamic> _stats = {};

  String get _adminId => ProfileService.currentProfile?.id ?? '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUsers();
    _loadReports();
    _loadStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    final stats = await ApiService.fetchStats();
    setState(() => _stats = stats);
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoadingUsers = true);
    final profilesMap = await ApiService.fetchAllProfiles();
    final users = profilesMap.values.map((data) => UserProfile.fromMap(data as Map<String, dynamic>)).toList();
    setState(() {
      _users = users;
      _isLoadingUsers = false;
    });
  }

  Future<void> _loadReports() async {
    setState(() => _isLoadingReports = true);
    final reports = await ApiService.fetchReports();
    setState(() {
      _reports = reports;
      _isLoadingReports = false;
    });
  }

  List<UserProfile> get _filteredUsers {
    if (_searchQuery.isEmpty) return _users;
    return _users.where((u) => u.name.toLowerCase().contains(_searchQuery.toLowerCase()) || u.email.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  Future<void> _confirmBan(UserProfile user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Блокировка пользователя'),
        content: Text('Вы уверены, что хотите заблокировать ${user.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          TextButton(onPressed: () => Navigator.pop(context, true), style: TextButton.styleFrom(foregroundColor: Colors.orange), child: const Text('Заблокировать')),
        ],
      ),
    );
    if (confirm == true) {
      final success = await ApiService.banUser(_adminId, user.id);
      if (success) {
        _loadUsers();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Пользователь заблокирован')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _confirmDelete(UserProfile user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удаление пользователя'),
        content: Text('Удалить пользователя ${user.name}? Все данные будут удалены безвозвратно.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          TextButton(onPressed: () => Navigator.pop(context, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Удалить')),
        ],
      ),
    );
    if (confirm == true) {
      final success = await ApiService.deleteUser(_adminId, user.id);
      if (success) {
        _loadUsers();
        _loadReports();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Пользователь удалён')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _resolveReport(Map<String, dynamic> report) async {
    final dynamic rawId = report['id'];
    final int reportId;
    if (rawId is int) {
      reportId = rawId;
    } else if (rawId is double) {
      reportId = rawId.toInt();
    } else if (rawId is String) {
      reportId = int.tryParse(rawId) ?? 0;
    } else {
      reportId = 0;
    }
    if (reportId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Некорректный ID жалобы'), backgroundColor: Colors.red));
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Отметить жалобу как решённую'),
        content: const Text('Вы уверены?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Да')),
        ],
      ),
    );
    if (confirm == true) {
      final success = await ApiService.resolveReport(_adminId, reportId);
      if (success) {
        _loadReports();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Жалоба отмечена как решённая')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Администрирование'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Пользователи'),
            Tab(icon: Icon(Icons.report), text: 'Жалобы'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Статистика'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUsersTab(),
          _buildReportsTab(),
          _buildStatsTab(),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Поиск по имени или email',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
        ),
        Expanded(
          child: _isLoadingUsers
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
            itemCount: _filteredUsers.length,
            itemBuilder: (context, index) {
              final user = _filteredUsers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(child: Text(user.name.substring(0, 1).toUpperCase())),
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!user.isAdmin)
                        IconButton(
                          icon: const Icon(Icons.block, color: Colors.orange),
                          onPressed: () => _confirmBan(user),
                          tooltip: 'Заблокировать',
                        ),
                      if (!user.isAdmin)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(user),
                          tooltip: 'Удалить',
                        ),
                      if (user.isAdmin)
                        const Icon(Icons.admin_panel_settings, color: Colors.purple),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReportsTab() {
    return _isLoadingReports
        ? const Center(child: CircularProgressIndicator())
        : _reports.where((r) => r['resolved'] == false).isEmpty
        ? const Center(child: Text('Нет нерешённых жалоб'))
        : ListView.builder(
      itemCount: _reports.length,
      itemBuilder: (context, index) {
        final report = _reports[index];
        if (report['resolved'] == true) return const SizedBox.shrink();
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: const Icon(Icons.report, color: Colors.red),
            title: Text('Жалоба от ${report['from_user']} на ${report['reported_user']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Причина: ${report['reason']}'),
                Text('Сообщение ID: ${report['message_id']}'),
                Text('Время: ${report['timestamp']}'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green),
              onPressed: () => _resolveReport(report),
              tooltip: 'Отметить как решённую',
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Всего пользователей'),
              trailing: Text('${_stats['total_users'] ?? 0}'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Всего сообщений'),
              trailing: Text('${_stats['total_messages'] ?? 0}'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.today),
              title: const Text('Новых за 7 дней'),
              trailing: Text('${_stats['new_users_week'] ?? 0}'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.online_prediction),
              title: const Text('Сейчас онлайн'),
              trailing: Text('${_stats['online_now'] ?? 0}'),
            ),
          ),
        ],
      ),
    );
  }
}