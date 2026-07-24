import 'dart:ui';

enum SearchMode { byVehicleReg, byCustomer }

class CustomerTag {
  final String label;
  final Color color;

  const CustomerTag({required this.label, required this.color});
}

const List<CustomerTag> kCustomerTags = [
  CustomerTag(label: 'Corporate', color: Color(0xFF1A7FDB)),
  CustomerTag(label: 'Premium',   color: Color(0xFFAD1457)),
];

const List<String> kCustomerGroups = [
  'Retail', 'Corporate', 'Fleet', 'Insurance', 'VIP',
];

const List<String> kGenders = ['Male', 'Female', 'Other'];

const List<String> kAddresses = [
  'Dubai', 'Abu Dhabi', 'Sharjah', 'Ajman',
  'Ras Al Khaimah', 'Fujairah', 'Umm Al Quwain',
];

const List<String> kCarBrands = [
  'GMC','AC','AICAR','AITO','AIWAYS','AM General','AMG','AVANTI',
  'AVATR','Abarth','Acura','Alfa Romeo','Aston Martin','Audi',
  'BAIC','BMW','BYD','Bentley','Bugatti','Buick',
  'Cadillac','Changan','Chery','Chevrolet','Chirey','Chrysler',
  'Citroen','DAF','DAYUN','DENZA','DFSK','Dacia','Daewoo',
  'Daihatsu','Datsun','Delorean','Dodge',
  'Ferrari','Fiat','Ford','Foton',
  'Genesis','GMC','Geely','Great Wall',
  'Honda','Hummer','Hyundai',
  'Infiniti','Isuzu',
  'Jaguar','Jeep',
  'Kia',
  'Lamborghini','Land Rover','Lexus','Lincoln',
  'MG','Mahindra','Maserati','Mazda','McLaren',
  'Mercedes-Benz','Mini','Mitsubishi',
  'Nissan',
  'Opel',
  'Peugeot','Porsche',
  'Ram','Range Rover','Renault','Rolls-Royce',
  'SEAT','Subaru','Suzuki',
  'Tesla','Toyota',
  'VW','Volkswagen','Volvo',
];

const List<String> kNissanModels = [
  'Nissan City DIESEL','Nissan 180SX PETROL','Nissan 180SX DIESEL',
  'Nissan 300ZX PETROL','Nissan 300ZX DIESEL','Nissan 350Z PETROL',
  'Nissan 350Z DIESEL','Nissan AD PETROL','Nissan AD DIESEL',
  'Nissan AD EXPERT PETROL','Nissan AD EXPERT DIESEL','Nissan Acty PETROL',
  'Nissan Altima PETROL','Nissan Armada PETROL','Nissan Frontier PETROL',
  'Nissan Kicks PETROL','Nissan Maxima PETROL','Nissan Murano PETROL',
  'Nissan Navara DIESEL','Nissan Note PETROL','Nissan Patrol PETROL',
  'Nissan Patrol DIESEL','Nissan Pathfinder PETROL','Nissan Rogue PETROL',
  'Nissan Sentra PETROL','Nissan Sunny PETROL','Nissan Tiida PETROL',
  'Nissan Titan PETROL','Nissan X-Trail PETROL','Nissan X-Trail DIESEL',
  'Nissan Xterra PETROL','Nissan Z PETROL',
];

const Map<String, List<String>> kModelsByBrand = {
  'Nissan': kNissanModels,
  'Toyota': [
    'Toyota Camry PETROL','Toyota Camry HYBRID','Toyota Corolla PETROL',
    'Toyota Fortuner PETROL','Toyota Fortuner DIESEL','Toyota Hilux PETROL',
    'Toyota Hilux DIESEL','Toyota Land Cruiser PETROL','Toyota Land Cruiser DIESEL',
    'Toyota Prado PETROL','Toyota Prado DIESEL','Toyota RAV4 PETROL',
    'Toyota RAV4 HYBRID','Toyota Rush PETROL','Toyota Yaris PETROL',
  ],
  'Honda': [
    'Honda Accord PETROL','Honda City PETROL','Honda Civic PETROL',
    'Honda CR-V PETROL','Honda HR-V PETROL','Honda Odyssey PETROL',
    'Honda Pilot PETROL',
  ],
};

List<String> modelsForBrand(String brand) {
  return kModelsByBrand[brand] ??
      ['$brand Model A PETROL', '$brand Model B DIESEL', '$brand Model C PETROL'];
}

List<String> get kModelYears =>
    List.generate(20, (i) => '${2029 - i}');

const List<String> kCylinders = ['2','3','4','5','6','8','10','12','16'];

const List<String> kInsuranceProviders = [
  'Al Sagr Insurance','AXA Insurance','Orient Insurance',
  'Dubai Insurance','Emirates Insurance','RSA Insurance',
  'Oman Insurance','Noor Takaful','Salama Insurance',
];

class VehicleCustomerFormModel {
  SearchMode searchMode = SearchMode.byCustomer;
  String customerSearch = '';

  bool isB2B = false;
  String customerName = '';
  String phoneNumber = '';
  String email = '';
  String customerGroup = '';
  List<String> selectedTags = [];
  String gender = '';
  String address = '';
  String taxNumber = '';
  String groupTaxNumber = '';
  String occupation = '';
  String organisation = '';
  String source = '';

  String registrationNumber = '';
  String vin = '';
  String make = '';
  String model = '';
  String modelYear = '';
  String purchaseDate = '';
  String cylinders = '';
  String engineCapacity = '';
  String vehicleColor = '';
  String engineNumber = '';
  String insuranceProvider = '';
  String insuranceTaxNumber = '';
  String insuranceAddress = '';
  String policyNumber = '';
  String insuranceExpiryDate = '';

  String odometerReading = '';
  int fuelLevel = 5;
  bool customerConsent = false;
}

