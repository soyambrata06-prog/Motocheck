class BikeSearchModel {
  final String name;
  final bool isScooter;
  BikeSearchModel(this.name, {this.isScooter = false});
}

class CompanySearchModel {
  final String name;
  final List<BikeSearchModel> bikes;
  bool isExpanded;

  CompanySearchModel(this.name, this.bikes, {this.isExpanded = false});
}

final List<CompanySearchModel> bikeManufacturers = [
  CompanySearchModel('KTM', [
    BikeSearchModel('Duke 200'),
    BikeSearchModel('Duke 390'),
    BikeSearchModel('RC 200'),
  ]),
  CompanySearchModel('Royal Enfield', [
    BikeSearchModel('Classic 350'),
    BikeSearchModel('Hunter 350'),
    BikeSearchModel('Meteor 350'),
  ]),
  CompanySearchModel('TVS', [
    BikeSearchModel('Apache RTR 160'),
    BikeSearchModel('Apache RTR 200'),
    BikeSearchModel('Ntorq 125', isScooter: true),
  ]),
  CompanySearchModel('Bajaj', [
    BikeSearchModel('Pulsar NS200'),
    BikeSearchModel('Pulsar RS200'),
    BikeSearchModel('Pulsar N160'),
  ]),
  CompanySearchModel('BMW Motorrad', [
    BikeSearchModel('S1000RR'),
  ]),
  CompanySearchModel('Honda', [
    BikeSearchModel('CB350'),
    BikeSearchModel('Activa 6G', isScooter: true),
    BikeSearchModel('CBR650R'),
  ]),
  CompanySearchModel('Yamaha', [
    BikeSearchModel('R15 V4'),
    BikeSearchModel('MT-15'),
    BikeSearchModel('Aerox 155', isScooter: true),
  ]),
];
