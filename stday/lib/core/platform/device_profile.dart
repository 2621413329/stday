import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 终端形态：用于布局与渲染管线分流。
enum AppTerminal {
  web,
  mobilePhone,
  mobileTablet,
  desktop,
}

/// 当前设备的布局与渲染能力快照。
class DeviceProfile {
  const DeviceProfile({
    required this.terminal,
    required this.logicalSize,
    required this.devicePixelRatio,
  });

  final AppTerminal terminal;
  final Size logicalSize;
  final double devicePixelRatio;

  factory DeviceProfile.fromContext(BuildContext context) {
    final mq = MediaQuery.sizeOf(context);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return DeviceProfile(
      terminal: _detectTerminal(mq),
      logicalSize: mq,
      devicePixelRatio: dpr,
    );
  }

  factory DeviceProfile.fromSize(Size size, {double devicePixelRatio = 1}) {
    return DeviceProfile(
      terminal: _detectTerminal(size),
      logicalSize: size,
      devicePixelRatio: devicePixelRatio,
    );
  }

  static AppTerminal _detectTerminal(Size size) {
    if (kIsWeb) return AppTerminal.web;
    if (_isDesktopPlatform) return AppTerminal.desktop;
    if (size.shortestSide >= 600) return AppTerminal.mobileTablet;
    return AppTerminal.mobilePhone;
  }

  static bool get _isDesktopPlatform {
    if (kIsWeb) return false;
    try {
      return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    } on Object {
      return defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS;
    }
  }

  bool get supportsFlame3DNative {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
    } on Object {
      return false;
    }
  }

  /// Web / 桌面强制 2D；Android / iOS / macOS 原生端可按能力走 3D。
  bool get preferCanvas2D =>
      terminal == AppTerminal.web ||
      terminal == AppTerminal.desktop;

  bool get preferCompactIsland =>
      terminal == AppTerminal.mobilePhone || logicalSize.width <= 520;

  double get desktopFrameWidth => 390;
  double get tabletMaxWidth => 720;

  bool get isWideLayout => logicalSize.width > 520;
}

/// 岛屿渲染策略：按终端 + 构建模式 + 运行时失败回退决定 2D/3D。
class IslandRenderPolicy {
  IslandRenderPolicy._();

  static bool _disabledAfterFailure = false;

  /// Release 默认开启 3D（Android/iOS 手机）；关闭：
  /// `--dart-define=ENABLE_ISLAND_3D=false`
  static const enable3DInRelease = bool.fromEnvironment(
    'ENABLE_ISLAND_3D',
    defaultValue: true,
  );

  static bool shouldUse3D({
    required DeviceProfile profile,
    required bool prefer3D,
  }) {
    if (_disabledAfterFailure) return false;
    if (!prefer3D) return false;
    if (!profile.supportsFlame3DNative) return false;
    if (profile.preferCanvas2D) return false;
    if (kReleaseMode) return enable3DInRelease;
    return true;
  }

  static void disable3DAfterFailure() => _disabledAfterFailure = true;
}
