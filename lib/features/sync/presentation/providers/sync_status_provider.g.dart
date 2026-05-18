// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_status_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$syncStatusReportHash() => r'f846a961fc398e34a9ef2acd56c92182fc61fc67';

/// See also [SyncStatusReport].
@ProviderFor(SyncStatusReport)
final syncStatusReportProvider =
    AutoDisposeAsyncNotifierProvider<
      SyncStatusReport,
      List<TableSyncStats>
    >.internal(
      SyncStatusReport.new,
      name: r'syncStatusReportProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$syncStatusReportHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SyncStatusReport = AutoDisposeAsyncNotifier<List<TableSyncStats>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
