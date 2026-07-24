import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';

class TechnicianMockDatasource {
  TechnicianProfileEntity get profile => TechnicianProfileEntity.mock;

  AttendanceSummaryEntity get attendanceSummary => const AttendanceSummaryEntity(
        punchIn: '08:15 AM',
        breakTime: '25 min',
        workHours: '4h 35m',
      );

  List<AssignedJobEntity> get assignedJobs => List.from(AssignedJobEntity.mockData);

  TechnicianStatsEntity get productivity => const TechnicianStatsEntity(
        assignedJobs: 4,
        inProgress: 1,
        completedToday: 1,
        efficiency: 87,
        avgTimePerJob: '1.2 hrs',
        totalHoursWorked: '4h 35m',
      );

  List<TechnicianJobEntity> get jobs => [
        TechnicianJobEntity(
          jobCardNo: 'JC-2026-0423',
          dateOfWork: '2026-04-23',
          startTime: '08:30',
          vehicleBrand: 'Toyota',
          vehicleModel: 'Camry',
          plateNumber: 'ABC-1234',
          status: TechJobStatus.inProgress,
          tasks: [
            WorkTaskEntity(
              id: 1,
              description: 'Engine oil change and filter replacement',
              status: TaskStatus.completed,
              startTime: '08:35',
            ),
            WorkTaskEntity(
              id: 2,
              description: 'Brake pad inspection and replacement',
              status: TaskStatus.inProgress,
              startTime: '09:15',
            ),
            WorkTaskEntity(id: 3, description: 'Tire rotation and alignment check'),
            WorkTaskEntity(id: 4, description: 'Battery voltage test and terminal cleaning'),
          ],
        ),
        TechnicianJobEntity(
          jobCardNo: 'JC-2026-0422',
          dateOfWork: '2026-04-22',
          startTime: '10:00',
          vehicleBrand: 'Honda',
          vehicleModel: 'Accord',
          plateNumber: 'XYZ-5678',
          status: TechJobStatus.completed,
          tasks: [
            WorkTaskEntity(
              id: 1,
              description: 'Full service inspection',
              status: TaskStatus.completed,
              startTime: '10:05',
              endTime: '11:30',
            ),
            WorkTaskEntity(
              id: 2,
              description: 'Air filter replacement',
              status: TaskStatus.completed,
              startTime: '11:35',
              endTime: '12:00',
            ),
            WorkTaskEntity(
              id: 3,
              description: 'Coolant top-up and pressure test',
              status: TaskStatus.completed,
              startTime: '12:05',
              endTime: '12:45',
            ),
          ],
        ),
        TechnicianJobEntity(
          jobCardNo: 'JC-2026-0421',
          dateOfWork: '2026-04-21',
          startTime: '14:30',
          vehicleBrand: 'Ford',
          vehicleModel: 'F-150',
          plateNumber: 'DEF-9012',
          status: TechJobStatus.delayed,
          tasks: [
            WorkTaskEntity(
              id: 1,
              description: 'Transmission fluid change',
              status: TaskStatus.inProgress,
              startTime: '14:35',
            ),
            WorkTaskEntity(id: 2, description: 'Differential oil replacement'),
          ],
        ),
        TechnicianJobEntity(
          jobCardNo: 'JC-2026-0420',
          dateOfWork: '2026-04-20',
          startTime: '09:00',
          vehicleBrand: 'Chevrolet',
          vehicleModel: 'Silverado',
          plateNumber: 'GHI-3456',
          tasks: [
            WorkTaskEntity(id: 1, description: 'Spark plug replacement'),
            WorkTaskEntity(id: 2, description: 'Throttle body cleaning'),
            WorkTaskEntity(id: 3, description: 'PCV valve inspection'),
          ],
        ),
        TechnicianJobEntity(
          jobCardNo: 'JC-2026-0419',
          dateOfWork: '2026-04-19',
          startTime: '11:30',
          vehicleBrand: 'BMW',
          vehicleModel: '328i',
          plateNumber: 'JKL-7890',
          status: TechJobStatus.inProgress,
          tasks: [
            WorkTaskEntity(
              id: 1,
              description: 'DSC sensor calibration',
              status: TaskStatus.completed,
              startTime: '11:35',
              endTime: '12:10',
            ),
            WorkTaskEntity(
              id: 2,
              description: 'Brake fluid flush',
              status: TaskStatus.inProgress,
              startTime: '12:15',
            ),
            WorkTaskEntity(id: 3, description: 'Wheel bearing inspection'),
          ],
        ),
        TechnicianJobEntity(
          jobCardNo: 'JC-2026-0418',
          dateOfWork: '2026-04-18',
          startTime: '15:00',
          vehicleBrand: 'Mercedes',
          vehicleModel: 'C-Class',
          plateNumber: 'MNO-2468',
          tasks: [
            WorkTaskEntity(id: 1, description: 'AC compressor check'),
            WorkTaskEntity(id: 2, description: 'Cabin air filter replacement'),
          ],
        ),
      ];
}
