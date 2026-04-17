enum NightModeBehavior { off, on, scheduled, followSystem }

extension NightModeBehaviorStorage on NightModeBehavior {
  String get storageValue {
    switch (this) {
      case NightModeBehavior.off:
        return 'off';
      case NightModeBehavior.on:
        return 'on';
      case NightModeBehavior.scheduled:
        return 'scheduled';
      case NightModeBehavior.followSystem:
        return 'followSystem';
    }
  }

  static NightModeBehavior fromStorageValue(Object? value) {
    if (value is! String) {
      return NightModeBehavior.off;
    }

    switch (value) {
      case 'on':
        return NightModeBehavior.on;
      case 'scheduled':
        return NightModeBehavior.scheduled;
      case 'followSystem':
        return NightModeBehavior.followSystem;
      case 'off':
      default:
        return NightModeBehavior.off;
    }
  }
}
