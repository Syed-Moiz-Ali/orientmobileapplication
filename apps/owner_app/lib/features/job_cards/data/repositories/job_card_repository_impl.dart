import 'package:owner_app/features/job_cards/data/datasources/mock_job_card_datasource.dart';
import 'package:owner_app/features/job_cards/domain/entities/job_card.dart';
import 'package:owner_app/features/job_cards/domain/repositories/job_card_repository.dart';

class JobCardRepositoryImpl implements JobCardRepository {
  final JobCardDatasource _datasource;
  JobCardRepositoryImpl(this._datasource);
  @override
  Future<List<JobCard>> getJobCards() => _datasource.getJobCards();
}
