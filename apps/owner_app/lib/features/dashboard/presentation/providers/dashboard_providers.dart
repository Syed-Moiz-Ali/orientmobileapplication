import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/data/datasources/owner_remote_adapters.dart';
import 'package:owner_app/features/dashboard/data/datasources/owner_remote_datasource.dart';
import 'package:owner_app/features/dashboard/data/repositories/dashboard_repository_impls.dart';
import 'package:owner_app/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:owner_app/features/dashboard/domain/repositories/dashboard_repositories.dart';

final _ownerRemoteProvider = Provider<OwnerRemoteDataSource>((ref) => OwnerRemoteDataSource(ref.read(apiClientProvider)));

final docExpiryDatasourceProvider = Provider<DocumentExpiryDatasource>((ref) => DocumentExpiryRemoteDatasource(ref.read(_ownerRemoteProvider)));
final jobStatusDatasourceProvider = Provider<JobStatusDatasource>((ref) => JobStatusRemoteDatasource(ref.read(_ownerRemoteProvider)));
final pendingApprovalsDatasourceProvider = Provider<PendingApprovalsDatasource>((ref) => PendingApprovalsRemoteDatasource(ref.read(_ownerRemoteProvider)));
final pendingJobCardsDatasourceProvider = Provider<PendingJobCardsDatasource>((ref) => PendingJobCardsRemoteDatasource(ref.read(_ownerRemoteProvider)));
final activeJobCardsDatasourceProvider = Provider<ActiveJobCardsDatasource>((ref) => ActiveJobCardsRemoteDatasource(ref.read(_ownerRemoteProvider)));
final salesInvoicesDatasourceProvider = Provider<SalesInvoicesDatasource>((ref) => SalesInvoicesRemoteDatasource(ref.read(_ownerRemoteProvider)));

final docExpiryRepositoryProvider = Provider<DocumentExpiryRepository>((ref) => DocumentExpiryRepositoryImpl(ref.watch(docExpiryDatasourceProvider)));
final jobStatusRepositoryProvider = Provider<JobStatusRepository>((ref) => JobStatusRepositoryImpl(ref.watch(jobStatusDatasourceProvider)));
final pendingApprovalsRepositoryProvider = Provider<PendingApprovalsRepository>((ref) => PendingApprovalsRepositoryImpl(ref.watch(pendingApprovalsDatasourceProvider)));
final pendingJobCardsRepositoryProvider = Provider<PendingJobCardsRepository>((ref) => PendingJobCardsRepositoryImpl(ref.watch(pendingJobCardsDatasourceProvider)));
final activeJobCardsRepositoryProvider = Provider<ActiveJobCardsRepository>((ref) => ActiveJobCardsRepositoryImpl(ref.watch(activeJobCardsDatasourceProvider)));
final salesInvoicesRepositoryProvider = Provider<SalesInvoicesRepository>((ref) => SalesInvoicesRepositoryImpl(ref.watch(salesInvoicesDatasourceProvider)));

class DocumentExpiryState extends ListState<DocumentExpiry> {
  const DocumentExpiryState({super.isLoading, super.searchQuery, super.items});

  List<DocumentExpiry> get filtered {
    return filter((d) => d.employeeName.toLowerCase().contains(searchQuery.toLowerCase()) || d.empId.toLowerCase().contains(searchQuery.toLowerCase()));
  }

  int get criticalCount => items.where((d) => d.urgency == ExpiryUrgency.critical).length;
  int get urgentCount => items.where((d) => d.urgency == ExpiryUrgency.urgent).length;
  int get warningCount => items.where((d) => d.urgency == ExpiryUrgency.warning).length;
}

class DocumentExpiryNotifier extends Notifier<DocumentExpiryState> with ListNotifierMixin<DocumentExpiry, DocumentExpiryState> {
  @override
  DocumentExpiryState build() { load(fetcher: () => ref.read(docExpiryRepositoryProvider).getDocuments()); return const DocumentExpiryState(); }
}

class JobStatusState extends ListState<JobStatus> {
  final JobStage? filterStage;
  const JobStatusState({super.isLoading, super.searchQuery, super.items, this.filterStage});

  List<JobStatus> get filtered {
    var result = items;
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      result = items.where((j) => j.customerName.toLowerCase().contains(q) || j.jobCardId.toLowerCase().contains(q) || j.vehicleInfo.toLowerCase().contains(q)).toList();
    }
    if (filterStage != null) result = result.where((j) => j.stage == filterStage).toList();
    return result;
  }

  @override
  JobStatusState copyWith({bool? isLoading, String? searchQuery, List<JobStatus>? items, JobStage? filterStage}) =>
      JobStatusState(isLoading: isLoading ?? this.isLoading, searchQuery: searchQuery ?? this.searchQuery, items: items ?? this.items, filterStage: filterStage ?? this.filterStage);
}

class JobStatusNotifier extends Notifier<JobStatusState> with ListNotifierMixin<JobStatus, JobStatusState> {
  @override
  JobStatusState build() { load(fetcher: () => ref.read(jobStatusRepositoryProvider).getJobStatuses()); return const JobStatusState(); }
  void setFilter(JobStage? stage) => state = state.copyWith(filterStage: stage);
}

class PendingApprovalsState {
  final bool isLoading;
  final List<ApprovalCategory> categories;
  const PendingApprovalsState({this.isLoading = true, this.categories = const []});
  PendingApprovalsState copyWith({bool? isLoading, List<ApprovalCategory>? categories}) => PendingApprovalsState(isLoading: isLoading ?? this.isLoading, categories: categories ?? this.categories);
  int get totalPending => categories.fold(0, (sum, c) => sum + c.count);
}

class PendingApprovalsNotifier extends Notifier<PendingApprovalsState> {
  @override
  PendingApprovalsState build() { load(); return const PendingApprovalsState(); }
  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    state = state.copyWith(isLoading: false, categories: await ref.read(pendingApprovalsRepositoryProvider).getCategories());
  }
}

class PendingJobCardsState extends ListState<PendingJobCard> {
  const PendingJobCardsState({super.isLoading, super.searchQuery, super.items});

  List<PendingJobCard> get filtered {
    return filter((j) => j.customerName.toLowerCase().contains(searchQuery.toLowerCase()) || j.jobCardId.toLowerCase().contains(searchQuery.toLowerCase()) || j.vehicleInfo.toLowerCase().contains(searchQuery.toLowerCase()));
  }

  int get overdueCount => items.where((j) => j.status == PendingJobCardStatus.overdue).length;
  int get pendingCount => items.where((j) => j.status == PendingJobCardStatus.pending).length;
  int get inProgressCount => items.where((j) => j.status == PendingJobCardStatus.inProgress).length;
}

class PendingJobCardsNotifier extends Notifier<PendingJobCardsState> with ListNotifierMixin<PendingJobCard, PendingJobCardsState> {
  @override
  PendingJobCardsState build() { load(fetcher: () => ref.read(pendingJobCardsRepositoryProvider).getJobCards()); return const PendingJobCardsState(); }
}

class ActiveJobCardsState extends ListState<ActiveJobCard> {
  const ActiveJobCardsState({super.isLoading, super.searchQuery, super.items});

  List<ActiveJobCard> get filtered {
    return filter((j) => j.id.toLowerCase().contains(searchQuery.toLowerCase()) || j.customerName.toLowerCase().contains(searchQuery.toLowerCase()) || j.vehicleInfo.toLowerCase().contains(searchQuery.toLowerCase()));
  }
}

class ActiveJobCardsNotifier extends Notifier<ActiveJobCardsState> with ListNotifierMixin<ActiveJobCard, ActiveJobCardsState> {
  @override
  ActiveJobCardsState build() { load(fetcher: () => ref.read(activeJobCardsRepositoryProvider).getJobCards()); return const ActiveJobCardsState(); }
}

class SalesInvoicesState extends ListState<SalesInvoice> {
  const SalesInvoicesState({super.isLoading, super.searchQuery, super.items});

  List<SalesInvoice> get filtered {
    return filter((i) => i.id.toLowerCase().contains(searchQuery.toLowerCase()) || i.customerName.toLowerCase().contains(searchQuery.toLowerCase()));
  }

  double get totalSales => items.fold(0, (sum, i) => sum + i.amount);
}

class SalesInvoicesNotifier extends Notifier<SalesInvoicesState> with ListNotifierMixin<SalesInvoice, SalesInvoicesState> {
  @override
  SalesInvoicesState build() { load(fetcher: () => ref.read(salesInvoicesRepositoryProvider).getInvoices()); return const SalesInvoicesState(); }
}

final documentExpiryProvider = NotifierProvider<DocumentExpiryNotifier, DocumentExpiryState>(DocumentExpiryNotifier.new);
final jobStatusProvider = NotifierProvider<JobStatusNotifier, JobStatusState>(JobStatusNotifier.new);
final pendingApprovalsProvider = NotifierProvider<PendingApprovalsNotifier, PendingApprovalsState>(PendingApprovalsNotifier.new);
final pendingJobCardsProvider = NotifierProvider<PendingJobCardsNotifier, PendingJobCardsState>(PendingJobCardsNotifier.new);
final activeJobCardsProvider = NotifierProvider<ActiveJobCardsNotifier, ActiveJobCardsState>(ActiveJobCardsNotifier.new);
final salesInvoicesProvider = NotifierProvider<SalesInvoicesNotifier, SalesInvoicesState>(SalesInvoicesNotifier.new);
