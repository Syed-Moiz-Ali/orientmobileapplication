import 'package:owner_app/features/dashboard/domain/entities/dashboard_entities.dart';

abstract interface class DocumentExpiryRepository {
  Future<List<DocumentExpiry>> getDocuments();
}

abstract interface class JobStatusRepository {
  Future<List<JobStatus>> getJobStatuses();
}

abstract interface class PendingApprovalsRepository {
  Future<List<ApprovalCategory>> getCategories();
}

abstract interface class PendingJobCardsRepository {
  Future<List<PendingJobCard>> getJobCards();
}

abstract interface class ActiveJobCardsRepository {
  Future<List<ActiveJobCard>> getJobCards();
}

abstract interface class SalesInvoicesRepository {
  Future<List<SalesInvoice>> getInvoices();
}
