/// Lets a tab inside [MainShell] handle the Android back button before the
/// shell does (e.g. "previous question" in the health check).
///
/// The tab sets [handler] in `initState` and clears it in `dispose`. The
/// handler returns true when it used the back press.
class TabBack {
  bool Function()? handler;

  /// Runs the tab's handler; false if there is none or it didn't act.
  bool handle() => handler?.call() ?? false;
}
