import 'package:flutter/material.dart';

import '../../../services/progress_service.dart';
import '../../../services/theme_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ============================================================
  // PROFILE
  // ============================================================

  String userName = 'MindCare User';

  // ============================================================
  // SETTINGS
  // ============================================================

  bool soundEnabled = true;
  bool notificationsEnabled = true;
  String themeMode = 'System';

  // ============================================================
  // PROGRESS
  // ============================================================

  late Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();

    _profileFuture = _initializeProfile();
  }

  // ============================================================
  // LOAD + INITIALIZE PROFILE
  // ============================================================

  Future<Map<String, dynamic>> _initializeProfile() async {
    final data = await _loadProfile();

    if (mounted) {
      userName =
          data['userName'] as String? ?? 'MindCare User';

      soundEnabled =
          data['soundEnabled'] as bool? ?? true;

      notificationsEnabled =
          data['notificationsEnabled'] as bool? ?? true;

      themeMode =
          data['themeMode'] as String? ?? 'System';
    }

    return data;
  }

  // ============================================================
  // LOAD PROFILE
  // ============================================================

  Future<Map<String, dynamic>> _loadProfile() async {
    final meditationSessions =
        await ProgressService.getMeditationSessions();

    final meditationMinutes =
        await ProgressService.getMeditationMinutes();

    final unwindSessions =
        await ProgressService.getUnwindSessions();

    final currentStreak =
        await ProgressService.getCurrentStreak();

    final name =
        await ProgressService.getUserName();

    final sound =
        await ProgressService.getSoundEnabled();

    final notifications =
        await ProgressService.getNotificationsEnabled();

    final theme =
        await ProgressService.getThemeMode();

    final weeklyActivity =
        await ProgressService.getThisWeekActivity();

    return {
      'meditationSessions': meditationSessions,
      'meditationMinutes': meditationMinutes,
      'unwindSessions': unwindSessions,
      'currentStreak': currentStreak,
      'userName': name,
      'soundEnabled': sound,
      'notificationsEnabled': notifications,
      'themeMode': theme,
      'weeklyActivity': weeklyActivity,
    };
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refreshProfile() async {
    final future = _loadProfile();

    setState(() {
      _profileFuture = future;
    });

    final data = await future;

    if (!mounted) {
      return;
    }

    setState(() {
      userName =
          data['userName'] as String? ?? 'MindCare User';

      soundEnabled =
          data['soundEnabled'] as bool? ?? true;

      notificationsEnabled =
          data['notificationsEnabled'] as bool? ?? true;

      themeMode =
          data['themeMode'] as String? ?? 'System';
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7FC),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w500,
            color: Color(0xFF202534),
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF673AB7),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Unable to load profile.',
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _refreshProfile,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final data = snapshot.data ?? {};

            final meditationSessions =
                data['meditationSessions'] as int? ?? 0;

            final meditationMinutes =
                data['meditationMinutes'] as int? ?? 0;

            final unwindSessions =
                data['unwindSessions'] as int? ?? 0;

            final currentStreak =
                data['currentStreak'] as int? ?? 0;

            final weeklyActivity =
                (data['weeklyActivity'] as List<dynamic>?)
                        ?.map(
                          (value) => value as int,
                        )
                        .toList() ??
                    List<int>.filled(7, 0);

            return RefreshIndicator(
              color: const Color(0xFF673AB7),
              onRefresh: _refreshProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(
                  20,
                  10,
                  20,
                  30,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(),

                    const SizedBox(height: 28),

                    _buildSectionTitle(
                      icon: Icons.bar_chart_rounded,
                      title: 'Your Progress',
                    ),

                    const SizedBox(height: 14),

                    _buildProgressGrid(
                      meditationSessions:
                          meditationSessions,
                      meditationMinutes:
                          meditationMinutes,
                      unwindSessions:
                          unwindSessions,
                      currentStreak:
                          currentStreak,
                    ),

                    const SizedBox(height: 26),

                    _buildWeeklyProgress(
                      weeklyActivity,
                    ),

                    const SizedBox(height: 30),

                    _buildSectionTitle(
                      icon: Icons.settings_outlined,
                      title: 'Preferences',
                    ),

                    const SizedBox(height: 14),

                    _buildSettingsCard(),

                    const SizedBox(height: 30),

                    _buildSectionTitle(
                      icon: Icons.info_outline,
                      title: 'About',
                    ),

                    const SizedBox(height: 14),

                    _buildAboutCard(),

                    const SizedBox(height: 20),

                    const Center(
                      child: Text(
                        'MindCare',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF9E9E9E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Center(
                      child: Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF7651C9),
            Color(0xFF5E35B1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF673AB7)
                .withValues(alpha: 0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 78,
            width: 78,
            decoration: BoxDecoration(
              color:
                  Colors.white.withValues(alpha: 0.20),
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    Colors.white.withValues(alpha: 0.45),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 45,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Your MindCare journey',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color:
                        Colors.white.withValues(alpha: 0.80),
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 12),

                GestureDetector(
                  onTap: _showEditProfileDialog,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withValues(alpha: 0.18),
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 15,
                          color: Colors.white,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Edit Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ],
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

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF673AB7),
          size: 24,
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF202020),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PROGRESS GRID
  // ============================================================

  Widget _buildProgressGrid({
    required int meditationSessions,
    required int meditationMinutes,
    required int unwindSessions,
    required int currentStreak,
  }) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.45,
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          icon: Icons.self_improvement,
          title: 'Meditation',
          value: '$meditationSessions',
          subtitle: 'sessions',
          color: const Color(0xFF673AB7),
        ),

        _buildStatCard(
          icon: Icons.timer_outlined,
          title: 'Meditation Time',
          value: '$meditationMinutes',
          subtitle: 'minutes',
          color: const Color(0xFF3F51B5),
        ),

        _buildStatCard(
          icon:
              Icons.local_fire_department_rounded,
          title: 'Current Streak',
          value: '$currentStreak',
          subtitle: 'days',
          color: const Color(0xFFFF8F00),
        ),

        _buildStatCard(
          icon: Icons.spa_outlined,
          title: 'Unwind',
          value: '$unwindSessions',
          subtitle: 'sessions',
          color: const Color(0xFF43A047),
        ),
      ],
    );
  }

  // ============================================================
  // STAT CARD
  // ============================================================

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color:
                  color.withValues(alpha: 0.11),
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: color,
              size: 25,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 3),

                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 22,
                        color: color,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(width: 4),

                    Flexible(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom: 2,
                        ),
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            color:
                                Colors.grey.shade500,
                          ),
                        ),
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

  // ============================================================
  // THIS WEEK
  // ============================================================

  Widget _buildWeeklyProgress(
    List<int> values,
  ) {
    const days = [
      'M',
      'T',
      'W',
      'T',
      'F',
      'S',
      'S',
    ];

    final safeValues =
        List<int>.generate(
      7,
      (index) {
        if (index < values.length) {
          return values[index];
        }

        return 0;
      },
    );

    final maxValue =
        safeValues.fold<int>(
      0,
      (max, value) =>
          value > max ? value : max,
    );

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'This Week',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            maxValue == 0
                ? '$userName has no mindfulness activity yet'
                : '$userName\'s mindfulness activity',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 22),

          SizedBox(
            height: 130,
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.end,
              mainAxisAlignment:
                  MainAxisAlignment.spaceAround,
              children: List.generate(
                7,
                (index) {
                  final value =
                      safeValues[index];

                  double normalized = 0;

                  if (maxValue > 0) {
                    normalized =
                        value / maxValue;
                  }

                  return Column(
                    mainAxisAlignment:
                        MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Align(
                          alignment:
                              Alignment.bottomCenter,
                          child: Container(
                            width: 25,
                            height: maxValue == 0
                                ? 6
                                : 90 * normalized,
                            decoration:
                                BoxDecoration(
                              color:
                                  const Color(
                                0xFF673AB7,
                              ).withValues(
                                alpha:
                                    value == 0
                                        ? 0.10
                                        : 0.18 +
                                            (normalized *
                                                0.65),
                              ),
                              borderRadius:
                                  BorderRadius.circular(
                                10,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        days[index],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              FontWeight.w600,
                          color:
                              Colors.grey.shade600,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SETTINGS
  // ============================================================

  Widget _buildSettingsCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // SOUND
          _buildSwitchTile(
            icon: Icons.volume_up_outlined,
            title: 'Sound',
            subtitle:
                'Play meditation and unwind sounds',
            value: soundEnabled,
            onChanged: (value) async {
              await ProgressService
                  .setSoundEnabled(value);

              if (!mounted) {
                return;
              }

              setState(() {
                soundEnabled = value;
              });
            },
          ),

          _buildDivider(),

          // NOTIFICATIONS
          _buildSwitchTile(
            icon:
                Icons.notifications_none_rounded,
            title: 'Notifications',
            subtitle:
                'Mindfulness reminders and updates',
            value: notificationsEnabled,
            onChanged: (value) async {
              await ProgressService
                  .setNotificationsEnabled(
                value,
              );

              if (!mounted) {
                return;
              }

              setState(() {
                notificationsEnabled = value;
              });
            },
          ),

          _buildDivider(),

          // APPEARANCE
          _buildSettingsTile(
            icon: Icons.dark_mode_outlined,
            title: 'Appearance',
            subtitle: themeMode,
            onTap: _showThemeDialog,
          ),

          _buildDivider(),

          // RESET
          _buildSettingsTile(
            icon: Icons.restart_alt_rounded,
            title: 'Reset Progress',
            subtitle:
                'Clear your meditation and unwind progress',
            iconColor: Colors.redAccent,
            onTap: _showResetDialog,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SWITCH TILE
  // ============================================================

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 17,
        vertical: 13,
      ),
      child: Row(
        children: [
          _buildSettingsIcon(
            icon,
            const Color(0xFF673AB7),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          Switch.adaptive(
            value: value,
            activeTrackColor:
                const Color(0xFF673AB7),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SETTINGS TILE
  // ============================================================

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor =
        const Color(0xFF673AB7),
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(22),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 17,
          vertical: 16,
        ),
        child: Row(
          children: [
            _buildSettingsIcon(
              icon,
              iconColor,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade500,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SETTINGS ICON
  // ============================================================

  Widget _buildSettingsIcon(
    IconData icon,
    Color color,
  ) {
    return Container(
      height: 43,
      width: 43,
      decoration: BoxDecoration(
        color:
            color.withValues(alpha: 0.10),
        borderRadius:
            BorderRadius.circular(13),
      ),
      child: Icon(
        icon,
        color: color,
        size: 22,
      ),
    );
  }

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 74,
      endIndent: 17,
      color: Colors.grey.shade200,
    );
  }

  // ============================================================
  // ABOUT
  // ============================================================

  Widget _buildAboutCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.favorite_outline,
            title: 'About MindCare',
            subtitle:
                'Learn more about the app',
            onTap: _showAboutDialog,
          ),

          _buildDivider(),

          _buildSettingsTile(
            icon:
                Icons.privacy_tip_outlined,
            title: 'Privacy',
            subtitle:
                'Your privacy and data',
            onTap: _showPrivacyDialog,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EDIT PROFILE / NAME
  // ============================================================

  Future<void> _showEditProfileDialog() async {
  final String? newName = await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return EditProfileDialog(
        currentName:
            userName == 'MindCare User' ? '' : userName,
      );
    },
  );

  if (newName == null) {
    return;
  }

  final cleanedName = newName.trim();

  if (cleanedName.isEmpty) {
    return;
  }

  // Save AFTER the dialog has completely closed.
  await ProgressService.setUserName(cleanedName);

  if (!mounted) {
    return;
  }

  setState(() {
    userName = cleanedName;
  });
}

  // ============================================================
  // APPEARANCE
  // ============================================================

  Future<void> _showThemeDialog() async {
    final selected =
        await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title:
              const Text('Appearance'),

          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              _buildThemeOption(
                dialogContext,
                'System',
                Icons.settings_suggest_outlined,
              ),

              _buildThemeOption(
                dialogContext,
                'Light',
                Icons.light_mode_outlined,
              ),

              _buildThemeOption(
                dialogContext,
                'Dark',
                Icons.dark_mode_outlined,
              ),
            ],
          ),
        );
      },
    );

    if (selected == null) {
      return;
    }

    await ThemeController.setTheme(
      selected,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      themeMode = selected;
    });
  }

  // ============================================================
  // THEME OPTION
  // ============================================================

  Widget _buildThemeOption(
    BuildContext dialogContext,
    String value,
    IconData icon,
  ) {
    final selected =
        themeMode == value;

    return ListTile(
      leading: Icon(
        icon,
        color: selected
            ? const Color(0xFF673AB7)
            : Colors.grey.shade600,
      ),

      title: Text(value),

      trailing: selected
          ? const Icon(
              Icons.check_circle,
              color:
                  Color(0xFF673AB7),
            )
          : null,

      onTap: () {
        Navigator.pop(
          dialogContext,
          value,
        );
      },
    );
  }

  // ============================================================
  // RESET PROGRESS
  // ============================================================

  Future<void> _showResetDialog() async {
    final shouldReset =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title:
              const Text('Reset Progress?'),

          content: const Text(
            'This will reset your meditation '
            'sessions, meditation time, '
            'streak, unwind sessions and '
            'weekly activity history.\n\n'
            'Your name and preferences will '
            'not be deleted.',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child:
                  const Text('Cancel'),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Reset',
                style: TextStyle(
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldReset != true) {
      return;
    }

    await ProgressService.resetProgress();

    if (!mounted) {
      return;
    }

    await _refreshProfile();

    if (!mounted) {
      return;
    }

    final messenger =
        ScaffoldMessenger.of(context);

    messenger.showSnackBar(
      const SnackBar(
        content: Text(
          'Progress has been reset.',
        ),
      ),
    );
  }

  // ============================================================
  // ABOUT DIALOG
  // ============================================================

  void _showAboutDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title:
              const Text('About MindCare'),

          content: const Text(
            'MindCare is a wellness application '
            'designed to help you relax, meditate, '
            'listen to calming sounds and build '
            'healthy mindfulness habits.',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child:
                  const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // PRIVACY DIALOG
  // ============================================================

  void _showPrivacyDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title:
              const Text('Privacy'),

          content: const Text(
            'Your MindCare activity is stored '
            'locally on this device to provide '
            'your progress and wellness experience.',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child:
                  const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class EditProfileDialog extends StatefulWidget {
  final String currentName;

  const EditProfileDialog({
    super.key,
    required this.currentName,
  });

  @override
  State<EditProfileDialog> createState() =>
      _EditProfileDialogState();
}

class _EditProfileDialogState
    extends State<EditProfileDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(
      text: widget.currentName,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final name = _controller.text.trim();

    if (name.isEmpty) {
      return;
    }

    // Only return the name.
    //
    // DO NOT dispose the controller here.
    // Flutter will call dispose() when the
    // dialog widget is actually removed.
    Navigator.of(context).pop(name);
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Edit Profile',
      ),

      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization:
            TextCapitalization.words,
        maxLength: 30,
        decoration: const InputDecoration(
          labelText: 'Name',
          hintText: 'Enter your name',
          prefixIcon: Icon(
            Icons.person_outline,
          ),
          border: OutlineInputBorder(),
        ),
      ),

      actions: [
        TextButton(
          onPressed: _cancel,
          child: const Text(
            'Cancel',
          ),
        ),

        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor:
                const Color(0xFF673AB7),
          ),
          onPressed: _save,
          child: const Text(
            'Save',
          ),
        ),
      ],
    );
  }
}

