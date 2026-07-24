class ConflictResolver {
  Map<String, dynamic> resolve(
    Map<String, dynamic> local,
    Map<String, dynamic> remote,
  ) {
    final merged = <String, dynamic>{};
    final allKeys = {...local.keys, ...remote.keys};
    for (final key in allKeys) {
      final localVal = local[key];
      final remoteVal = remote[key];
      if (remoteVal != null) {
        merged[key] = remoteVal;
      } else {
        merged[key] = localVal;
      }
    }
    return merged;
  }
}
