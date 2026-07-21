import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/features/dashboard/data/datasources/mock_dashboard_datasources.dart';
import 'package:orientmobileapplication/features/dashboard/data/repositories/dashboard_repository_impls.dart';
import 'package:orientmobileapplication/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:orientmobileapplication/features/dashboard/domain/repositories/dashboard_repositories.dart';

// ── Datasource Providers ──
final docExpiryDatasourceProvider = Provider<MockDocumentExpiryDatasource>((ref) => MockDocumentExpiryDatasource());
final jobStatusDatasourceProvider = Provider<MockJobStatusDatasource>((ref) => MockJobStatusDatasource());
final pendingApprovalsDatasourceProvider = Provider<MockPendingApprovalsDatasource>((ref) => MockPendingApprovalsDatasource());
final pendingJobCardsDatasourceProvider = Provider<MockPendingJobCardsDatasource>((ref) => MockPendingJobCardsDatasource());
final activeJobCardsDatasourceProvider = Provider<MockActiveJobCardsDatasource>((ref) => MockActiveJobCardsDatasource());
final salesInvoicesDatasourceProvider = Provider<MockSalesInvoicesDatasource>((ref) => MockSalesInvoicesDatasource());

// ── Repository Providers ──
final docExpiryRepositoryProvider = Provider<DocumentExpiryRepository>((ref) => DocumentExpiryRepositoryImpl(ref.watch(docExpiryDatasourceProvider)));
final jobStatusRepositoryProvider = Provider<JobStatusRepository>((ref) => JobStatusRepositoryImpl(ref.watch(jobStatusDatasourceProvider)));
final pendingApprovalsRepositoryProvider = Provider<PendingApprovalsRepository>((ref) => PendingApprovalsRepositoryImpl(ref.watch(pendingApprovalsDatasourceProvider)));
final pendingJobCardsRepositoryProvider = Provider<PendingJobCardsRepository>((ref) => PendingJobCardsRepositoryImpl(ref.watch(pendingJobCardsDatasourceProvider)));
final activeJobCardsRepositoryProvider = Provider<ActiveJobCardsRepository>((ref) => ActiveJobCardsRepositoryImpl(ref.watch(activeJobCardsDatasourceProvider)));
final salesInvoicesRepositoryProvider = Provider<SalesInvoicesRepository>((ref) => SalesInvoicesRepositoryImpl(ref.watch(salesInvoicesDatasourceProvider)));

// ── Document Expiry ──
class DocumentExpiryState {
  final bool isLoading;
  final String searchQuery;
  final List<DocumentExpiry> documents;
  const DocumentExpiryState({this.isLoading = true, this.searchQuery = '', this.documents = const []});
  DocumentExpiryState copyWith({bool? isLoading, String? searchQuery, List<DocumentExpiry>? documents}) => DocumentExpiryState(
    isLoading: isLoading ?? this.isLoading,
    searchQuery: searchQuery ?? this.searchQuery,
    documents: documents ?? this.documents,
  );
  List<DocumentExpiry> get filtered {
    if (searchQuery.isEmpty) return documents;
    final q = searchQuery.toLowerCase();
    return documents.where((d) => d.employeeName.toLowerCase().contains(q) || d.empId.toLowerCase().contains(q)).toList();
  }
  int get criticalCount => documents.where((d) => d.urgency == ExpiryUrgency.critical).length;
  int get urgentCount => documents.where((d) => d.urgency == ExpiryUrgency.urgent).length;
  int get warningCount => documents.where((d) => d.urgency == ExpiryUrgency.warning).length;
}

class DocumentExpiryNotifier extends Notifier<DocumentExpiryState> {
  @override
  DocumentExpiryState build() { load(); return const DocumentExpiryState(); }
  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    state = state.copyWith(isLoading: false, documents: await ref.read(docExpiryRepositoryProvider).getDocuments());
  }
  void onSearch(String q) => state = state.copyWith(searchQuery: q);
}
final documentExpiryProvider = NotifierProvider<DocumentExpiryNotifier, DocumentExpiryState>(DocumentExpiryNotifier.new);

// ── Job Status ──
class JobStatusState {
  final bool isLoading;
  final String searchQuery;
  final JobStage? filterStage;
  final List<JobStatus> jobs;
  const JobStatusState({this.isLoading = true, this.searchQuery = '', this.filterStage, this.jobs = const []});
  JobStatusState copyWith({bool? isLoading, String? searchQuery, JobStage? filterStage, List<JobStatus>? jobs}) => JobStatusState(
    isLoading: isLoading ?? this.isLoading, searchQuery: searchQuery ?? this.searchQuery, filterStage: filterStage, jobs: jobs ?? this.jobs,
  );
  List<JobStatus> get filtered {
    var result = jobs;
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      result = result.where((j) => j.customerName.toLowerCase().contains(q) || j.jobCardId.toLowerCase().contains(q) || j.vehicleInfo.toLowerCase().contains(q)).toList();
    }
    if (filterStage != null) result = result.where((j) => j.stage == filterStage).toList();
    return result;
  }
}

class JobStatusNotifier extends Notifier<JobStatusState> {
  @override
  JobStatusState build() { load(); return const JobStatusState(); }
  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    state = state.copyWith(isLoading: false, jobs: await ref.read(jobStatusRepositoryProvider).getJobStatuses());
  }
  void onSearch(String q) => state = state.copyWith(searchQuery: q);
  void setFilter(JobStage? stage) => state = state.copyWith(filterStage: stage);
}
final jobStatusProvider = NotifierProvider<JobStatusNotifier, JobStatusState>(JobStatusNotifier.new);

// ── Pending Approvals ──
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
final pendingApprovalsProvider = NotifierProvider<PendingApprovalsNotifier, PendingApprovalsState>(PendingApprovalsNotifier.new);

// ── Pending Job Cards ──
class PendingJobCardsState {
  final bool isLoading;
  final String searchQuery;
  final List<PendingJobCard> jobCards;
  const PendingJobCardsState({this.isLoading = true, this.searchQuery = '', this.jobCards = const []});
  PendingJobCardsState copyWith({bool? isLoading, String? searchQuery, List<PendingJobCard>? jobCards}) => PendingJobCardsState(
    isLoading: isLoading ?? this.isLoading, searchQuery: searchQuery ?? this.searchQuery, jobCards: jobCards ?? this.jobCards,
  );
  List<PendingJobCard> get filtered {
    if (searchQuery.isEmpty) return jobCards;
    final q = searchQuery.toLowerCase();
    return jobCards.where((j) => j.customerName.toLowerCase().contains(q) || j.jobCardId.toLowerCase().contains(q) || j.vehicleInfo.toLowerCase().contains(q)).toList();
  }
  int get overdueCount => jobCards.where((j) => j.status == JobCardStatus.overdue).length;
  int get pendingCount => jobCards.where((j) => j.status == JobCardStatus.pending).length;
  int get inProgressCount => jobCards.where((j) => j.status == JobCardStatus.inProgress).length;
}

class PendingJobCardsNotifier extends Notifier<PendingJobCardsState> {
  @override
  PendingJobCardsState build() { load(); return const PendingJobCardsState(); }
  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    state = state.copyWith(isLoading: false, jobCards: await ref.read(pendingJobCardsRepositoryProvider).getJobCards());
  }
  void onSearch(String q) => state = state.copyWith(searchQuery: q);
}
final pendingJobCardsProvider = NotifierProvider<PendingJobCardsNotifier, PendingJobCardsState>(PendingJobCardsNotifier.new);

// ── Active Job Cards ──
class ActiveJobCardsState {
  final bool isLoading;
  final String searchQuery;
  final List<ActiveJobCard> jobCards;
  const ActiveJobCardsState({this.isLoading = true, this.searchQuery = '', this.jobCards = const []});
  ActiveJobCardsState copyWith({bool? isLoading, String? searchQuery, List<ActiveJobCard>? jobCards}) => ActiveJobCardsState(
    isLoading: isLoading ?? this.isLoading, searchQuery: searchQuery ?? this.searchQuery, jobCards: jobCards ?? this.jobCards,
  );
  List<ActiveJobCard> get filtered {
    if (searchQuery.isEmpty) return jobCards;
    final q = searchQuery.toLowerCase();
    return jobCards.where((j) => j.id.toLowerCase().contains(q) || j.customerName.toLowerCase().contains(q) || j.vehicleInfo.toLowerCase().contains(q)).toList();
  }
}

class ActiveJobCardsNotifier extends Notifier<ActiveJobCardsState> {
  @override
  ActiveJobCardsState build() { load(); return const ActiveJobCardsState(); }
  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    state = state.copyWith(isLoading: false, jobCards: await ref.read(activeJobCardsRepositoryProvider).getJobCards());
  }
  void onSearch(String q) => state = state.copyWith(searchQuery: q);
}
final activeJobCardsProvider = NotifierProvider<ActiveJobCardsNotifier, ActiveJobCardsState>(ActiveJobCardsNotifier.new);

// ── Sales Invoices ──
class SalesInvoicesState {
  final bool isLoading;
  final String searchQuery;
  final List<SalesInvoice> invoices;
  const SalesInvoicesState({this.isLoading = true, this.searchQuery = '', this.invoices = const []});
  SalesInvoicesState copyWith({bool? isLoading, String? searchQuery, List<SalesInvoice>? invoices}) => SalesInvoicesState(
    isLoading: isLoading ?? this.isLoading, searchQuery: searchQuery ?? this.searchQuery, invoices: invoices ?? this.invoices,
  );
  List<SalesInvoice> get filtered {
    if (searchQuery.isEmpty) return invoices;
    final q = searchQuery.toLowerCase();
    return invoices.where((i) => i.id.toLowerCase().contains(q) || i.customerName.toLowerCase().contains(q)).toList();
  }
  double get totalSales => invoices.fold(0, (sum, i) => sum + i.amount);
}

class SalesInvoicesNotifier extends Notifier<SalesInvoicesState> {
  @override
  SalesInvoicesState build() { load(); return const SalesInvoicesState(); }
  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    state = state.copyWith(isLoading: false, invoices: await ref.read(salesInvoicesRepositoryProvider).getInvoices());
  }
  void onSearch(String q) => state = state.copyWith(searchQuery: q);
}
final salesInvoicesProvider = NotifierProvider<SalesInvoicesNotifier, SalesInvoicesState>(SalesInvoicesNotifier.new);
