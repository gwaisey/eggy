import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';

import '../../features/preferences/preferences_view_model.dart';
import '../../shared/ui/app_theme.dart';
import '../../shared/ui/widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Inside your build method, 'watch' the ViewModel
    final prefsVM = context.watch<PreferencesViewModel>();

    return Scaffold(
      backgroundColor: EggyColors.warmWhite,
      appBar: AppBar(
        title: Text('Settings', style: AppTheme.headline.copyWith(fontSize: 20)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        children: [
          _SectionHeader('Default Egg Size'),
          GlassCard(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: EggSize.values.map((size) {
                final selected = prefsVM.eggSize == size;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => prefsVM.setEggSize(size),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected ? EggyColors.onyx : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.egg_rounded, 
                            size: 20, 
                            color: selected ? EggyColors.champagne : EggyColors.onyx.withValues(alpha: 0.2)
                          ),
                          const SizedBox(height: 4),
                          Text(size.name[0].toUpperCase() + size.name.substring(1),
                              style: AppTheme.caption.copyWith(
                                fontSize: 11,
                                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                                color: selected ? Colors.white : EggyColors.onyx.withValues(alpha: 0.4),
                              )),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),
          _SectionHeader('Default Starting Temperature'),
          GlassCard(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: StartTemp.values.map((temp) {
                final selected = prefsVM.startTemp == temp;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => prefsVM.setStartTemp(temp),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: selected ? EggyColors.onyx : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        temp == StartTemp.fridge ? 'Fridge' : 'Room Temp',
                        textAlign: TextAlign.center,
                        style: AppTheme.body.copyWith(
                          fontSize: 14,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                          color: selected ? Colors.white : EggyColors.onyx.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),
          _SectionHeader('Preferences'),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                _ToggleRow(
                  icon: Icons.vibration_outlined,
                  label: 'Haptics',
                  subtitle: 'Tactile doneness snaps',
                  value: prefsVM.hapticEnabled,
                  onChanged: prefsVM.setHaptic,
                ),
                Divider(height: 1, color: EggyColors.onyx.withValues(alpha: 0.05)),
                _ToggleRow(
                  icon: Icons.notifications_outlined,
                  label: 'Notifications',
                  subtitle: 'Push alert when ready',
                  value: prefsVM.notifEnabled,
                  onChanged: prefsVM.setNotif,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.egg_alt_rounded, size: 14, color: EggyColors.liquidGold),
                    const SizedBox(width: 4),
                    Text('eggy v1.0.0', style: AppTheme.caption),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Powered by real egg physics',
                    style: AppTheme.caption.copyWith(
                        color: EggyColors.softCharcoal.withValues(alpha: 0.35))),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(title, style: AppTheme.title.copyWith(fontSize: 15)),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label, subtitle;
  final bool value;
  final void Function(bool) onChanged;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 22, color: EggyColors.liquidGold),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTheme.bodyMedium),
                Text(subtitle, style: AppTheme.caption),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: EggyColors.butterYellow.withValues(alpha: 1.0),
          ),
        ],
      ),
    );
  }
}



