import 'package:owner_app/features/dashboard/data/datasources/owner_remote_adapters.dart';
import 'package:owner_app/features/job_cards/domain/entities/job_card.dart';
import 'package:owner_app/features/job_cards/domain/repositories/job_card_repository.dart';

class JobCardRepositoryImpl implements JobCardRepository {
  final JobCardDatasource _datasource;
  JobCardRepositoryImpl(this._datasource);
  @override
  Future<List<JobCard>> getJobCards() => _datasource.getJobCards();
}
