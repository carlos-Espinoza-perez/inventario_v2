// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_sync_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$syncRepositoryHash() => r'f2557c353bb348a9e8554fc503741a684d219052';

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

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SyncRepositoryRef = AutoDisposeFutureProviderRef<SyncRepository>;
String _$autoSyncHash() => r'cff9cd3621d7afc5388769168c92f9934d93fa60';

/// See also [AutoSync].
@ProviderFor(AutoSync)
final autoSyncProvider =
    AutoDisposeAsyncNotifierProvider<AutoSync, SyncState>.internal(
      AutoSync.new,
      name: r'autoSyncProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$autoSyncHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AutoSync = AutoDisposeAsyncNotifier<SyncState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
