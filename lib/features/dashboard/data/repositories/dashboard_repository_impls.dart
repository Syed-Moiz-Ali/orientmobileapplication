import 'package:orientmobileapplication/features/dashboard/data/datasources/mock_dashboard_datasources.dart';
import 'package:orientmobileapplication/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:orientmobileapplication/features/dashboard/domain/repositories/dashboard_repositories.dart';

class DocumentExpiryRepositoryImpl implements DocumentExpiryRepository {
  final DocumentExpiryDatasource _ds;
  DocumentExpiryRepositoryImpl(this._ds);
  @override
  Future<List<DocumentExpiry>> getDocuments() => _ds.getDocuments();
}

class JobStatusRepositoryImpl implements JobStatusRepository {
  final JobStatusDatasource _ds;
  JobStatusRepositoryImpl(this._ds);
  @override
  Future<List<JobStatus>> getJobStatuses() => _ds.getJobStatuses();
}

class PendingApprovalsRepositoryImpl implements PendingApprovalsRepository {
  final PendingApprovalsDatasource _ds;
  PendingApprovalsRepositoryImpl(this._ds);
  @override
  Future<List<ApprovalCategory>> getCategories() => _ds.getCategories();
}

class PendingJobCardsRepositoryImpl implements PendingJobCardsRepository {
  final PendingJobCardsDatasource _ds;
  PendingJobCardsRepositoryImpl(this._ds);
  @override
  Future<List<PendingJobCard>> getJobCards() => _ds.getJobCards();
}

class ActiveJobCardsRepositoryImpl implements ActiveJobCardsRepository {
  final ActiveJobCardsDatasource _ds;
  ActiveJobCardsRepositoryImpl(this._ds);
  @override
  Future<List<ActiveJobCard>> getJobCards() => _ds.getJobCards();
}

class SalesInvoicesRepositoryImpl implements SalesInvoicesRepository {
  final SalesInvoicesDatasource _ds;
  SalesInvoicesRepositoryImpl(this._ds);
  @override
  Future<List<SalesInvoice>> getInvoices() => _ds.getInvoices();
}
