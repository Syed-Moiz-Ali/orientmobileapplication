class CustomerProfileResponse {
  final String name; final String firstName; final String avatarInitials; final String memberId;
  const CustomerProfileResponse({this.name='',this.firstName='',this.avatarInitials='',this.memberId=''});
  factory CustomerProfileResponse.fromJson(Map<String,dynamic> j) => CustomerProfileResponse(
    name: j['name']as String? ?? '',firstName: j['firstName']as String? ?? '',
    avatarInitials: j['avatarInitials']as String? ?? '',memberId: j['memberId']as String? ?? '');
}

class VehicleResponse {
  final String id; final String brand; final String model; final String plateNumber;
  final String vin; final String color; final int year; final String mileage;
  final String lastService; final String nextDue; final int healthScore;
  const VehicleResponse({this.id='',this.brand='',this.model='',this.plateNumber='',this.vin='',
    this.color='',this.year=0,this.mileage='',this.lastService='',this.nextDue='',this.healthScore=100});
  factory VehicleResponse.fromJson(Map<String,dynamic> j) => VehicleResponse(
    id: (j['id']??'').toString(),brand: j['brand']as String? ?? '',model: j['model']as String? ?? '',
    plateNumber: j['plateNumber']as String? ?? '',vin: j['vin']as String? ?? '',
    color: j['color']as String? ?? '',year: j['year']as int? ?? 0,mileage: j['mileage']as String? ?? '',
    lastService: j['lastService']as String? ?? '',nextDue: j['nextDue']as String? ?? '',
    healthScore: j['healthScore']as int? ?? 100);
}

class BookingResponse {
  final String service; final String vehicleName; final String plateNumber;
  final String date; final String time; final String status;
  const BookingResponse({this.service='',this.vehicleName='',this.plateNumber='',this.date='',this.time='',this.status='pending'});
  factory BookingResponse.fromJson(Map<String,dynamic> j) => BookingResponse(
    service: j['service']as String? ?? '',vehicleName: j['vehicleName']as String? ?? '',
    plateNumber: j['plateNumber']as String? ?? '',date: j['date']as String? ?? '',
    time: j['time']as String? ?? '',status: j['status']as String? ?? 'pending');
}

class NotificationResponse {
  final String id; final String title; final String body; final String time; final String type; final bool isRead;
  const NotificationResponse({this.id='',this.title='',this.body='',this.time='',this.type='carReady',this.isRead=false});
  factory NotificationResponse.fromJson(Map<String,dynamic> j) => NotificationResponse(
    id: (j['id']??'').toString(),title: j['title']as String? ?? '',body: j['body']as String? ?? '',
    time: j['time']as String? ?? '',type: j['type']as String? ?? 'carReady',isRead: j['isRead']as bool? ?? false);
}

class ActiveServiceResponse {
  final String jobCardId; final String plateNumber; final String vehicleName; final String service;
  final String started; final String estCompletion; final int progressPercent; final String currentStage;
  final String technicianName; final List<ServiceStageDto> stages;
  const ActiveServiceResponse({this.jobCardId='',this.plateNumber='',this.vehicleName='',this.service='',
    this.started='',this.estCompletion='',this.progressPercent=0,this.currentStage='',this.technicianName='',this.stages=const[]});
  factory ActiveServiceResponse.fromJson(Map<String,dynamic> j) => ActiveServiceResponse(
    jobCardId: j['jobCardId']as String? ?? '',plateNumber: j['plateNumber']as String? ?? '',
    vehicleName: j['vehicleName']as String? ?? '',service: j['service']as String? ?? '',
    started: j['started']as String? ?? '',estCompletion: j['estCompletion']as String? ?? '',
    progressPercent: j['progressPercent']as int? ?? 0,currentStage: j['currentStage']as String? ?? '',
    technicianName: j['technicianName']as String? ?? '',
    stages: (j['stages']as List<dynamic>?)?.map((e)=>ServiceStageDto.fromJson(e)).toList()??[]);
}

class ServiceStageDto {
  final String name; final String? time; final String status;
  const ServiceStageDto({this.name='',this.time,this.status='pending'});
  factory ServiceStageDto.fromJson(Map<String,dynamic> j) => ServiceStageDto(
    name: j['name']as String? ?? '',time: j['time']as String?,status: j['status']as String? ?? 'pending');
}

class ServiceTypeResponse {
  final String id; final String name; final String price; final String duration;
  const ServiceTypeResponse({this.id='',this.name='',this.price='',this.duration=''});
  factory ServiceTypeResponse.fromJson(Map<String,dynamic> j) => ServiceTypeResponse(
    id: (j['id']??'').toString(),name: j['name']as String? ?? '',
    price: j['price']as String? ?? '',duration: j['duration']as String? ?? '');
}

class IdResponse {
  final String id;
  const IdResponse({this.id=''});
  factory IdResponse.fromJson(Map<String,dynamic> j) => IdResponse(id: (j['id']??'').toString());
}
