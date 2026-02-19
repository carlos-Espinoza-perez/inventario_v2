// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_sync_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$syncRepositoryHash() => r'78e0e5982e3641df836569a4220525bf9cff94b9';

/// See also [syncRepository].
@ProviderFor(syncRepository)
final syncRepositoryProvider =
    AutoDisposeFutureProvider<SyncRepository>.internal(
  syncRepository,
  name: r'syncRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$syncRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SyncRepositoryRef = AutoDisposeFutureProviderRef<SyncRepository>;
String _$autoSyncHash() => r'33ce39c999959afa1aff365510c199401ccdeb9f';

/// See also [AutoSync].
@ProviderFor(AutoSync)
final autoSyncProvider =
    AutoDisposeAsyncNotifierProvider<AutoSync, SyncState>.internal(
  AutoSync.new,
  name: r'autoSyncProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$autoSyncHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AutoSync = AutoDisposeAsyncNotifier<SyncState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
