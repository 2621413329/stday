typedef ForceReloginCallback = Future<void> Function();

ForceReloginCallback? _forceRelogin;

/// 由 [dioProvider] 注册；在已登录态下 API 失败时清除 token。
void registerForceRelogin(ForceReloginCallback callback) {
  _forceRelogin = callback;
}

Future<void> forceReloginIfNeeded() async {
  await _forceRelogin?.call();
}
