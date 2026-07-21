import 'package:orientmobileapplication/features/job_cards/domain/entities/job_card.dart';

abstract interface class JobCardRepository {
  Future<List<JobCard>> getJobCards();
}
